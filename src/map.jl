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

abstract type HealpixMap{T<:AbstractFloat} <: AbstractVector{T} end
@enum Ordering ring nest

#"""
#    HealpixMap{T<:AbstractFloat}
#
#This type represents a map of the sky represented with the Healpix equal-area pixelization of the
#sphere.
#
#Construction of this type will throw an `ArgumentError` exception if the incorrect number of pixels
#are provided for the given value of `nside`. Use the function `nside2npix` to compute the
#appropriate number of pixels.
#
## Fields
#
#* `nside` - the number of pixels along the side of each face.
#* `order` - must be either `ring` or `nest`. This defines whether pixels should be ordered by equal
#            latitude rings (useful for spherical harmonic transforms) or by a nested scheme where
#            adjacent pixels are likely to be nearby in memory.
#* `pixels` - the list of pixel values. Note that the number of pixels must be consistent with the
#             value of `nside` and the ordering of the pixels is specified by `order`.
#
## Constructors
#
#    HealpixMap(order, nside, pixels)
#
#Construct a `HealpixMap` with the given list of pixel values.
#
#    HealpixMap(T, order, nside)
#
#Construct a `HealpixMap` where all the coefficients are initialized to `zero(T)`.
#
#    HealpixMap(order, pixels)
#
#Construct a `HealpixMap` with the given list of pixel values.  The value of `nside` is inferred from
#the number of pixels.
#"""

for Map in (:RingHealpixMap, :NestHealpixMap)
    @eval struct $Map{T<:AbstractFloat} <: HealpixMap{T}
        nside :: Int
        pixels :: Vector{T}
        function $Map{T}(nside, pixels) where T
            N = nside2npix(nside)
            N == length(pixels) || throw(ArgumentError("Expected $N pixels with nside=$nside."))
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
end

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
        msg = "got $npix pixels while expecting $expected_npix pixels (nside=$nside)"
        throw(LibHealpixException(msg))
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

ordering(map::RingHealpixMap) = ring
ordering(map::NestHealpixMap) = nest
isring(map::HealpixMap) = ordering(map) == ring
isnest(map::HealpixMap) = ordering(map) == nest

macro verify_maps_are_consistent(map1, map2)
    output = quote
        ordering(lhs) == ordering(rhs) || throw(ArgumentError("maps must have the same ordering"))
        lhs.nside == rhs.nside || throw(DimensionMismatch("maps must have the same number of pixels"))
    end
end

ang2pix(map::RingHealpixMap, θ, ϕ) = ang2pix_ring(map.nside, θ, ϕ)
ang2pix(map::NestHealpixMap, θ, ϕ) = ang2pix_nest(map.nside, θ, ϕ)
pix2ang(map::RingHealpixMap, ipix) = ang2pix_ring(map.nside, ipix)
pix2ang(map::NestHealpixMap, ipix) = ang2pix_nest(map.nside, ipix)
vec2pix(map::RingHealpixMap, vec)  = ang2pix_ring(map.nside, vec)
vec2pix(map::NestHealpixMap, vec)  = ang2pix_nest(map.nside, vec)
pix2vec(map::RingHealpixMap, ipix) = ang2pix_ring(map.nside, ipix)
pix2vec(map::NestHealpixMap, ipix) = ang2pix_nest(map.nside, ipix)

function Base.:(==)(lhs::HealpixMap, rhs::HealpixMap)
    ordering(lhs) == ordering(rhs) &&
        lhs.nside == rhs.nside && lhs.pixels == rhs.pixels
end

for operator in (:+, :-)
    @eval function Base.$operator(lhs::HealpixMap, rhs::HealpixMap)
        @verify_maps_are_consistent lhs rhs
        typeof(lhs)(lhs.nside, $operator(lhs.pixels, rhs.pixels))
    end

    @eval function Base.$operator(lhs::Map, rhs::Number) where Map <: HealpixMap
        typeof(lhs)(ordering(lhs), lhs.nside, $operator(lhs.pixels, rhs))
    end

    @eval function Base.$operator(lhs::Number, rhs::HealpixMap)
        typeof(rhs)(ordering(rhs), rhs.nside, $operator(lhs, rhs.pixels))
    end
end

for operator in (:*, :/)
    @eval function Base.broadcast(::typeof(Base.$operator), lhs::HealpixMap, rhs::HealpixMap)
        @verify_maps_are_consistent lhs rhs
        typeof(lhs)(lhs.nside, broadcast($operator, lhs.pixels, rhs.pixels))
    end

    @eval function Base.broadcast(::typeof(Base.$operator), lhs::HealpixMap, rhs::Number)
        typeof(lhs)(lhs.nside, broadcast($operator, lhs.pixels, rhs))
    end

    @eval function Base.broadcast(::typeof(Base.$operator), lhs::Number, rhs::HealpixMap)
        typeof(rhs)(rhs.nside, broadcast($operator, lhs, rhs.pixels))
    end
end

#function interpolate(map::HealpixMap, θ::Float64, ϕ::Float64)
#    interpolate(to_cxx(map), θ, ϕ)
#end

#function interpolate(map::HealpixMap, θlist::Vector, ϕlist::Vector)
#    map_cxx = to_cxx(map)
#    Float64[interpolate(map_cxx, Float64(θ), Float64(ϕ)) for (θ, ϕ) in zip(θlist, ϕlist)]
#end
#function interpolate(map, θ::Float64, ϕ::Float64)
#    θ, ϕ = verify_angles(θ, ϕ)
#    output = ccall(("interpolate", libhealpixwrapper), Cdouble,
#                   (Ptr{Void}, Cdouble, Cdouble), map_cxx, θ, ϕ)
#    output
#end

