# Copyright (c) 2015-2017 Michael Eastwood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
    nside2npix(nside)

Compute the number of pixels in a Healpix map with the given value of `nside`.

**Arguments:**

- `nside` - the Healpix resolution parameter

**Usage:**

```jldoctest
julia> nside2npix(4)
192

julia> nside2npix(256)
786432
```

**See Also:** [`npix2nside`](@ref), [`nside2nring`](@ref)
"""
Base.@pure nside2npix(nside::Integer) = 12nside*nside

"""
    npix2nside(npix)

Compute the value of the `nside` parameter for a Healpix map with the given number of pixels.

**Arguments:**

- `npix` - the number of pixels in the map

**Usage:**

```jldoctest
julia> npix2nside(192)
4

julia> npix2nside(786432)
256
```

**See Also:** [`nside2npix`](@ref), [`nside2nring`](@ref)
"""
function npix2nside(npix::Integer)
    nside = isqrt(npix÷12)
    nside2npix(nside) == npix || err("the given number of pixels is invalid")
    nside
end

"""
    nside2nring(nside)

Compute the number of equal latitude rings in the Healpix map with the given value of `nside`.

**Arguments:**

- `nside` - the Healpix resolution parameter

**Usage:**

```jldoctest
julia> nside2nring(4)
15

julia> nside2nring(256)
1023
```

**See Also:** [`nside2npix`](@ref), [`npix2nside`](@ref)
"""
Base.@pure nside2nring(nside::Integer) = 4nside - 1

"""
    UnitVector

This struct represents a unit 3-vector. The normalization requirement is enforced by the inner
constructor.

**Fields:**

- `x` - the `x` component of the unit vector
- `y` - the `y` component of the unit vector
- `z` - the `z` component of the unit vector
"""
struct UnitVector <: FieldVector{3, Float64}
    x :: Float64
    y :: Float64
    z :: Float64
    function UnitVector(x, y, z)
        normalization = hypot(x, y, z)
        normalization > 0 || err("vector must not have zero norm")
        new(x/normalization, y/normalization, z/normalization)
    end
end

function UnitVector(vec::AbstractVector)
    length(vec) == 3 || err("length of a unit vector must be 3")
    UnitVector(vec[1], vec[2], vec[3])
end

UnitVector(vec::UnitVector) = vec

doc"""
    verify_angles(θ, ϕ)

Spherical coordinates expect $θ ∈ [0,π]$, and $ϕ ∈ [0,2π)$.  This function simply checks and
enforces these expectations.
"""
function verify_angles(θ, ϕ)
    θ_float = float(θ)
    ϕ_float = float(ϕ)
    0 ≤ θ_float ≤ π || err("spherical coordinates require 0 ≤ θ ≤ π")
    ϕ_float = mod2pi(ϕ_float)
    θ_float, ϕ_float
end

doc"""
    ang2vec(theta, phi)

Compute the Cartesian unit vector to the spherical coordinates $(θ, ϕ)$.

**Arguments:**

- `theta` - the inclination angle $θ$
- `phi` - the azimuthal angle $ϕ$

**Usage:**

```jldoctest
julia> ang2vec(0, 0)
3-element LibHealpix.UnitVector:
 0.0
 0.0
 1.0

julia> ang2vec(π/2, π/2)
3-element LibHealpix.UnitVector:
 6.12323e-17
 1.0
 6.12323e-17
```

**See Also:** [`vec2ang`](@ref)
"""
function ang2vec(θ, ϕ)
    θ′, ϕ′ = verify_angles(θ, ϕ)
    s = sin(θ′)
    x = s*cos(ϕ′)
    y = s*sin(ϕ′)
    z = cos(θ′)
    UnitVector(x, y, z)
end

doc"""
    vec2ang(vec)

Compute the spherical coordinates $(θ, ϕ)$ from the given unit vector.

**Arguments:**

- `vec` - the input Cartesian unit vector

**Usage:**

```jldoctest
julia> vec2ang([1, 0, 0])
(1.5707963267948966, 0.0)

julia> vec2ang([0, 1, 0])
(1.5707963267948966, 1.5707963267948966)

julia> vec2ang([0, 0, 1])
(0.0, 0.0)
```

**See Also:** [`ang2vec`](@ref)
"""
function vec2ang(vec)
    vec′ = UnitVector(vec)
    θ = acos(vec′.z)
    ϕ = atan2(vec′.y, vec′.x)
    ϕ = mod2pi(ϕ)
    θ, ϕ
end

for f in (:nest2ring, :ring2nest)
    @eval function $f(nside::Integer, ipix::Integer)
        ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
        ipixoutptr = Ref{Clong}(0)
        ccall(($(string(f)), libchealpix), Void, (Clong, Clong, Ref{Clong}),
              nside, ipix, ipixoutptr)
        ipixoutptr[] + 1 # Add one to convert to a 1-indexed scheme
    end
end

for f in (:ang2pix_nest, :ang2pix_ring)
    @eval function $f(nside::Integer, θ::Real, ϕ::Real)
        θ′, ϕ′ = verify_angles(θ, ϕ)
        ipixptr = Ref{Clong}(0)
        ccall(($(string(f)), libchealpix), Void, (Clong, Cdouble, Cdouble, Ref{Clong}),
              nside, θ′, ϕ′, ipixptr)
        ipixptr[] + 1 # Add one to convert to a 1-indexed scheme
    end
end

for f in (:pix2ang_nest, :pix2ang_ring)
    @eval function $f(nside::Integer, ipix::Integer)
        ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
        θptr = Ref{Cdouble}(0.0)
        ϕptr = Ref{Cdouble}(0.0)
        ccall(($(string(f)), libchealpix), Void, (Clong, Clong, Ref{Cdouble}, Ref{Cdouble}),
              nside, ipix, θptr, ϕptr)
        θptr[], ϕptr[]
    end
end

for f in (:vec2pix_nest, :vec2pix_ring)
    @eval function $f(nside::Integer, vec::AbstractVector)
        vec′ = UnitVector(vec)
        ipixptr = Ref{Clong}(0)
        ccall(($(string(f)), libchealpix), Void, (Clong, Ptr{Cdouble}, Ref{Clong}),
              nside, vec′, ipixptr)
        ipixptr[] + 1 # Add one to convert to a 1-indexed scheme
    end
end

for f in (:pix2vec_nest, :pix2vec_ring)
    @eval function $f(nside::Integer, ipix::Integer)
        ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
        vec = Ref{UnitVector}(UnitVector(0, 0, 1))
        ccall(($(string(f)), libchealpix), Void, (Clong, Clong, Ptr{Cdouble}),
              nside, ipix, vec)
        vec[]
    end
end

"""
    nest2ring(nside, ipix)

Convert the given pixel index from the nested to the ring indexing scheme.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ipix` - the pixel index (nested scheme)

**Usage:**

```jldoctest
julia> nest2ring(256, 1)
391809

julia> nest2ring(256, 2)
390785
```

**See Also:** [`ring2nest`](@ref)
"""
nest2ring

"""
    ring2nest(nside, ipix)

Convert the given pixel index from the ring to the nested indexing scheme.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ipix` - the pixel index (ring scheme)

**Usage:**

```jldoctest
julia> ring2nest(256, 1)
65536

julia> ring2nest(256, 2)
131072
```

**See Also:** [`nest2ring`](@ref)
"""
ring2nest

doc"""
    ang2pix_nest(nside, theta, phi)

Compute the pixel index (in the nested scheme) that contains the point on the sphere given by the
spherical coordinates $(θ, ϕ)$.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `theta` - the inclination angle $θ$
- `phi` - the azimuthal angle $ϕ$

**Usage:**

```jldoctest
julia> ang2pix_nest(256, 0, 0)
65536

julia> ang2pix_nest(256, π/2, π/2)
354987
```

**See Also:** [`ang2pix_ring`](@ref), [`pix2ang_nest`](@ref), [`pix2ang_ring`](@ref)
"""
ang2pix_nest

doc"""
    ang2pix_ring(nside, theta, phi)

Compute the pixel index (in the ring scheme) that contains the point on the sphere given by the
spherical coordinates $(θ, ϕ)$.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `theta` - the inclination angle $θ$
- `phi` - the azimuthal angle $ϕ$

**Usage:**

```jldoctest
julia> ang2pix_ring(256, 0, 0)
1

julia> ang2pix_ring(256, π/2, π/2)
392961
```

**See Also:** [`ang2pix_nest`](@ref), [`pix2ang_nest`](@ref), [`pix2ang_ring`](@ref)
"""
ang2pix_ring

doc"""
    pix2ang_nest(nside, ipix)

Compute the spherical coordinates $(θ, ϕ)$ corresponding to the given pixel center.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ipix` - the pixel index (nested scheme)

**Usage:**

```jldoctest
julia> pix2ang_nest(256, 1)
(1.5681921571847817, 0.7853981633974483)

julia> pix2ang_nest(256, 2)
(1.5655879699137618, 0.7884661249732196)
```

**See Also:** [`pix2ang_ring`](@ref), [`ang2pix_nest`](@ref), [`ang2pix_ring`](@ref)
"""
pix2ang_nest

doc"""
    pix2ang_ring(nside, ipix)

Compute the spherical coordinates $(θ, ϕ)$ corresponding to the given pixel center.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ipix` - the pixel index (ring scheme)

**Usage:**

```jldoctest
julia> pix2ang_ring(256, 1)
(0.0031894411211228764, 0.7853981633974483)

julia> pix2ang_ring(256, 2)
(0.0031894411211228764, 2.356194490192345)
```

**See Also:** [`pix2ang_nest`](@ref), [`ang2pix_nest`](@ref), [`ang2pix_ring`](@ref)
"""
pix2ang_ring

"""
    vec2pix_nest(nside, vec)

Compute the pixel index (in the nested scheme) that contains the point on the sphere given by the
Cartesian unit vector.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `vec` - the input Cartesian unit vector

**Usage:**

```jldoctest
julia> vec2pix_nest(256, [1, 0, 0])
289451

julia> vec2pix_nest(256, [0, 1, 0])
354987

julia> vec2pix_nest(256, [0, 0, 1])
65536
```

**See Also:** [`vec2pix_ring`](@ref), [`pix2vec_nest`](@ref), [`pix2vec_ring`](@ref)
"""
vec2pix_nest

"""
    vec2pix_ring(nside, vec)

Compute the pixel index (in the ring scheme) that contains the point on the sphere given by the
Cartesian unit vector.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `vec` - the input Cartesian unit vector

**Usage:**

```jldoctest
julia> vec2pix_ring(256, [1, 0, 0])
392705

julia> vec2pix_ring(256, [0, 1, 0])
392961

julia> vec2pix_ring(256, [0, 0, 1])
1
```

**See Also:** [`vec2pix_nest`](@ref), [`pix2vec_nest`](@ref), [`pix2vec_ring`](@ref)
"""
vec2pix_ring

"""
    pix2vec_nest(nside, ipix)

Compute the Cartesian unit vector corresponding to the given pixel center.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ipix` - the pixel index (nested scheme)

**Usage:**

```jldoctest
julia> pix2vec_nest(256, 1)
3-element LibHealpix.UnitVector:
 0.707104
 0.707104
 0.00260417

julia> pix2vec_nest(256, 2)
3-element LibHealpix.UnitVector:
 0.704925
 0.709263
 0.00520833
```

**See Also:** [`pix2vec_ring`](@ref), [`vec2pix_nest`](@ref), [`vec2pix_ring`](@ref)
"""
pix2vec_nest

"""
    pix2vec_ring(nside, ipix)

Compute the Cartesian unit vector corresponding to the given pixel center.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ipix` - the pixel index (ring scheme)

**Usage:**

```jldoctest
julia> pix2vec_ring(256, 1)
3-element LibHealpix.UnitVector:
 0.00225527
 0.00225527
 0.999995

julia> pix2vec_ring(256, 2)
3-element LibHealpix.UnitVector:
 -0.00225527
  0.00225527
  0.999995
```

**See Also:** [`pix2vec_nest`](@ref), [`vec2pix_nest`](@ref), [`vec2pix_ring`](@ref)
"""
pix2vec_ring

