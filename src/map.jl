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
    abstract type HealpixMap{T<:AbstractFloat} <: AbstractVector{T}

This abstract type represents a Healpix equal-area pixelization of the sphere.

**Subtypes:**

- [`RingHealpixMap`](@ref) - a `HealpixMap` where pixels are ordered along rings of constant
    latitude. This ordering should be used for performing spherical harmonic transforms.
- [`NestHealpixMap`](@ref) - a `HealpixMap` where nearby pixels also tend to be nearby in memory.
"""
abstract type HealpixMap{T<:AbstractFloat} <: AbstractVector{T} end

for Map in (:RingHealpixMap, :NestHealpixMap)
    @eval struct $Map{T<:AbstractFloat} <: HealpixMap{T}
        nside :: Int
        pixels :: Vector{T}
        function $Map{T}(nside, pixels) where T
            N = nside2npix(nside)
            N == length(pixels) || err("expected $N pixels with nside=$nside")
            new(nside, pixels)
        end
    end

    @eval function $Map(::Type{T}, nside::Integer) where T
        pixels = zeros(T, nside2npix(nside))
        $Map{T}(nside, pixels)
    end

    @eval function $Map(pixels::Vector{T}) where T
        nside = npix2nside(length(pixels))
        $Map{T}(nside, pixels)
    end

    @eval function $Map(nside::Integer, pixels::Vector{T}) where T
        $Map{T}(nside, pixels)
    end
end

"""
    struct RingHealpixMap{T<:AbstractFloat} <: HealpixMap{T}

This type represents a Healpix equal-area pixelization of the sphere where pixels are ordered along
rings of constant latitude.

**Fields:**

- `nside` - the Healpix resolution parameter
- `pixels` - the list of pixel values

**Constructors:**

    RingHealpixMap(T, nside)

Construct a `RingHealpixMap` with the element type `T` and resolution parameter `nside`. All of the
pixels will be set to zero initially.

    RingHealpixMap(pixels)

Construct a `RingHealpixMap` with the given list of pixel values. The resolution parameter `nside`
will be inferred from the number of pixels. However a `LibHealpixException` will be thrown if given
an invalid number of pixels.

    RingHealpixMap(nside, pixels)

Construct a `RingHealpixMap` with the given resolution parameter `nside` and initial list of pixel
values. This constructor is cheaper than `RingHealpixMap(pixels)` if the correct value of `nside` is
already known.

**Usage:**

```jldoctest
julia> map = RingHealpixMap(Float64, 256)
       for idx = 1:length(map)
           map[idx] = randn()
       end
       map + map == 2map
true
```

**See also:** [`HealpixMap`](@ref), [`NestHealpixMap`](@ref)
"""
RingHealpixMap

"""
    struct NestHealpixMap{T<:AbstractFloat} <: HealpixMap{T}

This type represents a Healpix equal-area pixelization of the sphere where nearby pixels also tend
to be nearby in memory.

**Fields:**

- `nside` - the Healpix resolution parameter
- `pixels` - the list of pixel values

**Constructors:**

    NestHealpixMap(T, nside)

Construct a `NestHealpixMap` with the element type `T` and resolution parameter `nside`. All of the
pixels will be set to zero initially.

    NestHealpixMap(pixels)

Construct a `NestHealpixMap` with the given list of pixel values. The resolution parameter `nside`
will be inferred from the number of pixels. However a `LibHealpixException` will be thrown if given
an invalid number of pixels.

    NestHealpixMap(nside, pixels)

Construct a `NestHealpixMap` with the given resolution parameter `nside` and initial list of pixel
values. This constructor is cheaper than `NestHealpixMap(pixels)` if the correct value of `nside` is
already known.

**Usage:**

```jldoctest
julia> map = NestHealpixMap(Float64, 256)
       for idx = 1:length(map)
           map[idx] = randn()
       end
       map + map == 2map
true
```

**See also:** [`HealpixMap`](@ref), [`RingHealpixMap`](@ref)
"""
NestHealpixMap

"""
    verify_map_consistency(map::HealpixMap)
    verify_map_consistency(nside, npix)

These functions verify that the map has the correct number of pixels for the given value of the
`nside` parameter. A `LibHealpixException` is thrown if the map is inconsistent.

Note that we need this function because the user can shoot themself in the foot by doing something
silly like `resize!(map.pixels, ...)` to change the number of pixels in their map even after they've
constructed the map with a given value for `nside`.
"""
verify_map_consistency(map::HealpixMap) = verify_map_consistency(map.nside, length(map.pixels))

function verify_map_consistency(nside, npix)
    expected_npix = nside2npix(nside)
    if expected_npix != npix
        err("got $npix pixels while expecting $expected_npix pixels (nside=$nside)")
    end
end

function verify_maps_are_consistent(lhs, rhs)
    ordering(lhs) == ordering(rhs) || err("maps must have the same ordering")
    lhs.nside == rhs.nside || err("maps must have the same number of pixels")
end

# Implement the AbstractArray interface
Base.length(map::HealpixMap) = length(map.pixels)
Base.size(map::HealpixMap) = (length(map.pixels),)
Base.getindex(map::HealpixMap, pixel::Int) = map.pixels[pixel]
Base.setindex!(map::HealpixMap, value, pixel::Int) = map.pixels[pixel] = value
Base.IndexStyle(::HealpixMap) = Base.IndexLinear()
Base.eltype(map::HealpixMap{T}) where {T} = T
Base.similar(map::Map) where {Map <: HealpixMap} = Map(eltype(Map), map.nside)

@enum Ordering ring nest
ordering(map::RingHealpixMap) = ring
ordering(map::NestHealpixMap) = nest
isring(map::HealpixMap) = ordering(map) == ring
isnest(map::HealpixMap) = ordering(map) == nest

ang2pix(map::RingHealpixMap, θ, ϕ) = ang2pix_ring(map.nside, θ, ϕ)
ang2pix(map::NestHealpixMap, θ, ϕ) = ang2pix_nest(map.nside, θ, ϕ)
pix2ang(map::RingHealpixMap, ipix) = pix2ang_ring(map.nside, ipix)
pix2ang(map::NestHealpixMap, ipix) = pix2ang_nest(map.nside, ipix)
vec2pix(map::RingHealpixMap, vec)  = vec2pix_ring(map.nside, vec)
vec2pix(map::NestHealpixMap, vec)  = vec2pix_nest(map.nside, vec)
pix2vec(map::RingHealpixMap, ipix) = pix2vec_ring(map.nside, ipix)
pix2vec(map::NestHealpixMap, ipix) = pix2vec_nest(map.nside, ipix)

doc"""
    ang2pix(map, theta, phi)

Compute the pixel index that contains the point on the sphere given by the spherical coordinates
$(θ, ϕ)$.

**Arguments:**

- `map` - the input Healpix map
- `theta` - the inclination angle $θ$
- `phi` - the azimuthal angle $ϕ$

**Usage:**

```jldoctest
julia> ang2pix(RingHealpixMap(Float64, 256), π/2, π/2)
392961

julia> ang2pix(NestHealpixMap(Float64, 256), π/2, π/2)
354987
```

**See Also:** [`pix2ang`](@ref), [`ang2pix_nest`](@ref), [`ang2pix_ring`](@ref)
"""
ang2pix

doc"""
    pix2ang(map, ipix)

Compute the spherical coordinates $(θ, ϕ)$ corresponding to the given pixel center.

**Arguments:**

- `map` - the input Healpix map
- `ipix` - the pixel index

**Usage:**

```jldoctest
julia> pix2ang(RingHealpixMap(Float64, 256), 1)
(0.0031894411211228764, 0.7853981633974483)

julia> pix2ang(NestHealpixMap(Float64, 256), 1)
(1.5681921571847817, 0.7853981633974483)
```

**See Also:** [`ang2pix`](@ref), [`pix2ang_nest`](@ref), [`pix2ang_ring`](@ref)
"""
pix2ang

"""
    vec2pix(map, vec)

Compute the pixel index that contains the point on the sphere given by the Cartesian unit vector.

**Arguments:**

- `map` - the input Healpix map
- `vec` - the input Cartesian unit vector

**Usage:**

```jldoctest
julia> vec2pix(RingHealpixMap(Float64, 256), [0, 0, 1])
1

julia> vec2pix(NestHealpixMap(Float64, 256), [0, 0, 1])
65536
```

**See Also:** [`pix2vec`](@ref), [`vec2pix_nest`](@ref), [`vec2pix_ring`](@ref)
"""
vec2pix

"""
    pix2vec(map, ipix)

Compute the Cartesian unit vector corresponding to the given pixel center.

**Arguments:**

- `map` - the input Healpix map
- `ipix` - the pixel index (nested scheme)

**Usage:**

```jldoctest
julia> pix2vec(RingHealpixMap(Float64, 256), 1)
3-element LibHealpix.UnitVector:
 0.00225527
 0.00225527
 0.999995

julia> pix2vec(NestHealpixMap(Float64, 256), 1)
3-element LibHealpix.UnitVector:
 0.707104
 0.707104
 0.00260417
```

**See Also:** [`vec2pix`](@ref), [`pix2vec_nest`](@ref), [`pix2vec_ring`](@ref)
"""
pix2vec

function Base.:(==)(lhs::HealpixMap, rhs::HealpixMap)
    ordering(lhs) == ordering(rhs) &&
        lhs.nside == rhs.nside && lhs.pixels == rhs.pixels
end

for operator in (:+, :-)
    @eval function Base.$operator(lhs::HealpixMap, rhs::HealpixMap)
        verify_maps_are_consistent(lhs, rhs)
        typeof(lhs)(lhs.nside, $operator(lhs.pixels, rhs.pixels))
    end

    @eval function Base.$operator(lhs::Map, rhs::Real) where Map <: HealpixMap
        typeof(lhs)(lhs.nside, $operator(lhs.pixels, rhs))
    end

    @eval function Base.$operator(lhs::Real, rhs::HealpixMap)
        typeof(rhs)(rhs.nside, $operator(lhs, rhs.pixels))
    end
end

for operator in (:*, :/)
    @eval function Base.broadcast(::typeof(Base.$operator), lhs::HealpixMap, rhs::HealpixMap)
        verify_maps_are_consistent(lhs, rhs)
        typeof(lhs)(lhs.nside, broadcast($operator, lhs.pixels, rhs.pixels))
    end

    @eval function Base.broadcast(::typeof(Base.$operator), lhs::HealpixMap, rhs::Real)
        typeof(lhs)(lhs.nside, broadcast($operator, lhs.pixels, rhs))
    end

    @eval function Base.broadcast(::typeof(Base.$operator), lhs::Real, rhs::HealpixMap)
        typeof(rhs)(rhs.nside, broadcast($operator, lhs, rhs.pixels))
    end
end

function interpolate(map::HealpixMap{Float32}, θ, ϕ)
    ccall(("interpolate_float", libhealpixwrapper), Cfloat,
          (Cint, Cint, Ptr{Cfloat}, Cdouble, Cdouble),
          map.nside, ordering(map), map.pixels, θ, ϕ)
end

function interpolate(map::HealpixMap{Float64}, θ, ϕ)
    ccall(("interpolate_double", libhealpixwrapper), Cdouble,
          (Cint, Cint, Ptr{Cdouble}, Cdouble, Cdouble),
          map.nside, ordering(map), map.pixels, θ, ϕ)
end

doc"""
    interpolate(map, theta, phi)

Linearly interpolate the Healpix map at the given spherical coordinates $(θ, ϕ)$.

**Arguments:**

- `map` - the input Healpix map
- `theta` - the inclination angle $θ$
- `phi` - the azimuthal angle $ϕ$

**Usage:**

```jldoctest
julia> healpixmap = RingHealpixMap(Float64, 256)
       for idx = 1:length(healpixmap)
           healpixmap[idx] = idx
       end
       LibHealpix.interpolate(healpixmap, 0, 0)
2.5
```

**See Also:** [`ang2pix`](@ref)
"""
interpolate

