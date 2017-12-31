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
    abstract type HealpixMap{T<:Number} <: AbstractVector{T}

This abstract type represents a Healpix equal-area pixelization of the sphere.

**Subtypes:**

- [`RingHealpixMap`](@ref) - a `HealpixMap` where pixels are ordered along rings of constant
    latitude. This ordering should be used for performing spherical harmonic transforms.
- [`NestHealpixMap`](@ref) - a `HealpixMap` where nearby pixels also tend to be nearby in memory.
"""
abstract type HealpixMap{T<:Number} <: AbstractVector{T} end

for Map in (:RingHealpixMap, :NestHealpixMap)
    @eval struct $Map{T<:Number} <: HealpixMap{T}
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

    @eval function $Map(pixels::AbstractVector{T}) where T
        nside = npix2nside(length(pixels))
        $Map{T}(nside, pixels)
    end

    @eval function $Map(nside::Integer, pixels::AbstractVector{T}) where T
        $Map{T}(nside, pixels)
    end
end

"""
    struct RingHealpixMap{T<:Number} <: HealpixMap{T}

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

**See also:** [`HealpixMap`](@ref), [`NestHealpixMap`](@ref), [`Alm`](@ref)
"""
RingHealpixMap

"""
    struct NestHealpixMap{T<:Number} <: HealpixMap{T}

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

**See also:** [`HealpixMap`](@ref), [`RingHealpixMap`](@ref), [`Alm`](@ref)
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
- `theta` - the inclination angle $θ$ (in radians)
- `phi` - the azimuthal angle $ϕ$ (in radians)

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
    # TODO: account for the differences in ordering so that we can compare RingHealpixMaps with
    # NestHealpixMaps (expensive, but would be nice to have)
    ordering(lhs) == ordering(rhs) && lhs.nside == rhs.nside && lhs.pixels == rhs.pixels
end

# In general, HealpixMaps can only be == to other HealpixMaps because the ordering is important. The
# AbstractVector fallback will simply compare the two vectors element-wise. This behavior is
# undesirable so we override it here.
Base.:(==)(lhs::HealpixMap, rhs::AbstractVector) = false
Base.:(==)(lhs::AbstractVector, rhs::HealpixMap) = false

# Custom broadcasting
Base.Broadcast.broadcast_indices(::Type{<:HealpixMap}, map) = indices(map)
Base.Broadcast._containertype(::Type{<:RingHealpixMap}) = RingHealpixMap
Base.Broadcast._containertype(::Type{<:NestHealpixMap}) = NestHealpixMap
Base.Broadcast.promote_containertype(::Type{Any}, ::Type{T}) where {T<:HealpixMap} = T
Base.Broadcast.promote_containertype(::Type{T}, ::Type{Any}) where {T<:HealpixMap} = T
Base.Broadcast.promote_containertype(::Type{Array}, ::Type{T}) where {T<:HealpixMap} = T
Base.Broadcast.promote_containertype(::Type{T}, ::Type{Array}) where {T<:HealpixMap} = T

function Base.Broadcast.promote_containertype(::Type{RingHealpixMap}, ::Type{NestHealpixMap})
    err("cannot broadcast a ring ordered map with a nest ordered map")
end

function Base.Broadcast.promote_containertype(::Type{NestHealpixMap}, ::Type{RingHealpixMap})
    err("cannot broadcast a ring ordered map with a nest ordered map")
end

function Base.Broadcast.broadcast_c(f, ::Type{T}, args...) where T<:HealpixMap
    nside  = broadcast_nside(args...)
    pixels = broadcast_pixels(args...)
    T(nside, broadcast(f, pixels...))
end

@inline broadcast_nside(x, y, z...) = _broadcast_nside(_nside(x), broadcast_nside(y, z...))
@inline broadcast_nside(x, y) = _broadcast_nside(_nside(x), _nside(y))
@inline broadcast_nside(x) = _nside(x)
@inline _broadcast_nside(nside::Integer, ::Void) = nside
@inline _broadcast_nside(::Void, nside::Integer) = nside
@inline function _broadcast_nside(nside1::Integer, nside2::Integer)
    nside1 == nside2 || err("cannot broadcast two Healpix maps with different nsides")
    nside1
end
@inline _nside(map::HealpixMap) = map.nside
@inline _nside(other) = nothing

@inline broadcast_pixels(x, y...) = (_pixels(x), broadcast_pixels(y...)...)
@inline broadcast_pixels(x) = (_pixels(x),)
@inline _pixels(map::HealpixMap) = map.pixels
@inline _pixels(other) = other

"""
    LibHealpix.UNSEEN()

Get the sentinal value indicating a blind or masked pixel.
"""
UNSEEN() = -1.6375e30

function interpolate_cxx(map::HealpixMap{Float32}, θ, ϕ)
    # this function is used to test the Julia implementation
    θ′, ϕ′ = verify_angles(θ, ϕ)
    ccall(("interpolate_float", libhealpixwrapper), Cfloat,
          (Cint, Cint, Ptr{Cfloat}, Cdouble, Cdouble),
          map.nside, ordering(map), map.pixels, θ′, ϕ′)
end

function interpolate_cxx(map::HealpixMap{Float64}, θ, ϕ)
    # this function is used to test the Julia implementation
    θ′, ϕ′ = verify_angles(θ, ϕ)
    ccall(("interpolate_double", libhealpixwrapper), Cdouble,
          (Cint, Cint, Ptr{Cdouble}, Cdouble, Cdouble),
          map.nside, ordering(map), map.pixels, θ′, ϕ′)
end

function _interpolate_left_right(map, ring, θ, ϕ)
    startpix, ringpix, θ′, shifted = ring_info2(map.nside, ring)
    δ = 0.5shifted
    dϕ = 2π / ringpix

    # pixel to the left of the interpolation point
    i1 = floor(Int, ϕ/dϕ - δ)
    ϕ1 = (i1 + δ)*dϕ
    weight = (ϕ - ϕ1)/dϕ
    i1 = mod(i1, ringpix)

    # pixel to the right of the interpolation point
    i2 = mod(i1 + 1, ringpix)

    θ′, startpix+i1, startpix+i2, weight
end

doc"""
    LibHealpix.interpolate(map, theta, phi)

Linearly interpolate the Healpix map at the given spherical coordinates $(θ, ϕ)$.

**Arguments:**

- `map` - the input Healpix map
- `theta` - the inclination angle $θ$ (in radians)
- `phi` - the azimuthal angle $ϕ$ (in radians)

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
function interpolate(map, θ, ϕ)
    T = eltype(map)
    S = float(real(T))
    npix = length(map)
    pix = MVector(0, 0, 0, 0)
    wgt = MVector(zero(S), zero(S), zero(S), zero(S))
    θ, ϕ = verify_angles(θ, ϕ)
    z = cos(θ)
    ring1 = ring_above(map.nside, z)
    ring2 = ring1 + 1

    if ring1 > 0
        # ring above the interpolation point
        θ1, pix[1], pix[2], weight = _interpolate_left_right(map, ring1, θ, ϕ)
        wgt[1] = 1 - weight
        wgt[2] = weight
    end

    if ring2 < 4map.nside
        # ring below the interpolation point
        θ2, pix[3], pix[4], weight = _interpolate_left_right(map, ring2, θ, ϕ)
        wgt[3] = 1 - weight
        wgt[4] = weight
    end

    if ring1 == 0
        # north pole
        pix[1] = (pix[3]+1)&3 + 1
        pix[2] = (pix[4]+1)&3 + 1
        weight = θ / θ2
        fac = (1 - weight)/4
        wgt[1] = fac
        wgt[2] = fac
        wgt[3] = wgt[3]*weight + fac
        wgt[4] = wgt[4]*weight + fac
    elseif ring2 == 4map.nside
        # south pole
        pix[3] = (pix[1]+1)&3 + npix - 3
        pix[4] = (pix[2]+1)&3 + npix - 3
        weight = (θ - θ1)/(π - θ1)
        fac = weight/4
        wgt[1] = wgt[1]*(1-weight) + fac
        wgt[2] = wgt[2]*(1-weight) + fac
        wgt[3] = fac
        wgt[4] = fac
    else
        weight = (θ - θ1)/(θ2 - θ1)
        wgt[1] *= 1 - weight
        wgt[2] *= 1 - weight
        wgt[3] *= weight
        wgt[4] *= weight
    end

    # convert to ring coordinates if necessary
    if ordering(map) == nest
        for idx = 1:4
            pix[idx] = ring2nest(map.nside, pix[idx])
        end
    end

    # compute the interpolation from the pixels and weights
    numerator   = zero(T)
    denominator = zero(S)
    for idx = 1:4
        val = map[pix[idx]]
        wval = wgt[idx]
        if val != UNSEEN()
            numerator   += wval * val
            denominator += wval
        end
    end
    numerator / denominator
end

doc"""
    query_disc(nside, ordering, theta, phi, radius; inclusive=true)
    query_disc(map, theta, phi, radius; inclusive=true)

Return a list of all pixels contained within a circular disc of the given radius.

**Arguments:**

- `nside` - the Healpix resolution parameter
- `ordering` - the ordering of the Healpix map (either `LibHealpix.ring` or `LibHealpix.nest`
- `theta` - the inclination angle $θ$ (in radians)
- `phi` - the azimuthal angle $ϕ$ (in radians)
- `radius` - the radius of the disc (in radians)
- `map` - the input Healpix map (`nside` and `ordering` will be inferred from the map)

**Keyword Arguments:**

- `inclusive` - if set to `true pixels partially contained within the disc will be included,
    otherwise they are excluded

**Usage:**

```jldoctest
julia> query_disc(512, LibHealpix.ring, 0, 0, deg2rad(10/60), inclusive=false)
4-element Array{Int32,1}:
 1
 2
 3
 4

julia> query_disc(512, LibHealpix.ring, 0, 0, deg2rad(10/60), inclusive=true) |> length
24
```
"""
function query_disc(nside, ordering, θ, ϕ, radius; inclusive=true)
    θ′, ϕ′ = verify_angles(θ, ϕ)
    len = Ref{Cint}()
    ptr = ccall(("query_disc", libhealpixwrapper), Ptr{Cint},
                (Cint, Cint, Cdouble, Cdouble, Cdouble, Bool, Ref{Cint}),
                nside, ordering, θ′, ϕ′, radius, inclusive, len)
    arr = unsafe_wrap(Array, ptr, len[], true)
    arr .+= Cint(1) # convert to 1-based indexing
    arr
end

function query_disc(map::HealpixMap, θ, ϕ, radius; inclusive=true)
    query_disc(map.nside, ordering(map), θ, ϕ, radius, inclusive=inclusive)
end

