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

@enum Order ring nest

"""
    HealpixMap{T<:AbstractFloat}

This type represents a map of the sky represented with the Healpix equal-area pixelization of the
sphere.

Construction of this type will throw an `ArgumentError` exception if the incorrect number of pixels
are provided for the given value of `nside`. Use the function `nside2npix` to compute the
appropriate number of pixels.

# Fields

* `nside` - the number of pixels along the side of each face.
* `order` - must be either `ring` or `nest`. This defines whether pixels should be ordered by equal
            latitude rings (useful for spherical harmonic transforms) or by a nested scheme where
            adjacent pixels are likely to be nearby in memory.
* `pixels` - the list of pixel values. Note that the number of pixels must be consistent with the
             value of `nside` and the ordering of the pixels is specified by `order`.

# Constructors

    HealpixMap(nside, order, pixels)

Construct a `HealpixMap` with the given list of pixel values.

    HealpixMap(T, nside, order)

Construct a `HealpixMap` where all the coefficients are initialized to `zero(T)`.

    HealpixMap(order, pixels)

Construct a `HealpixMap` with the given list of pixel values.  The value of `nside` is inferred from
the number of pixels.
"""
struct HealpixMap{T<:AbstractFloat} <: AbstractVector{T}
    nside :: Int
    order :: Order
    pixels :: Vector{T}
    function HealpixMap{T}(nside, order, pixels) where T
        N = nside2npix(nside)
        N == length(pixels) || throw(ArgumentError("Expected $N pixels with nside=$nside."))
        new(nside, order, pixels)
    end
end

function HealpixMap(nside::Integer, order::Order, pixels::Vector{T}) where T
    HealpixMap{T}(nside, order, pixels)
end

function HealpixMap(::Type{T}, nside::Integer, order::Order) where T
    HealpixMap{T}(nside, order, zeros(T, nside2npix(nside)))
end

function HealpixMap(order::Order, pixels::Vector{T}) where T
    nside = npix2nside(length(pixels))
    HealpixMap(nside, order, pixels)
end

# Implement the AbstractArray interface
Base.length(map::HealpixMap) = length(map.pixels)
Base.size(map::HealpixMap) = (length(map.pixels),)
Base.getindex(map::HealpixMap, pixel::Int) = map.pixels[pixel]
Base.setindex!(map::HealpixMap, value, pixel::Int) = map.pixels[pixel] = value
Base.IndexStyle(::HealpixMap) = Base.IndexLinear()
Base.similar(map::HealpixMap{T}) where {T} = HealpixMap(T, map.nside, map.order)

function Base.:(==)(lhs::HealpixMap, rhs::HealpixMap)
    lhs.nside == rhs.nside && lhs.order == rhs.order && lhs.pixels == rhs.pixels
end

for operator in (:+, :-)
    @eval function Base.$operator(lhs::HealpixMap, rhs::HealpixMap)
        lhs.nside == rhs.nside || throw(DimensionMismatch())
        lhs.order == rhs.order || throw(ArgumentError("maps must have the same ordering"))
        HealpixMap(lhs.nside, lhs.order, $operator(lhs.pixels, rhs.pixels))
    end

    @eval function Base.$operator(lhs::HealpixMap, rhs::Number)
        HealpixMap(lhs.nside, lhs.order, $operator(lhs.pixels, rhs))
    end

    @eval function Base.$operator(lhs::Number, rhs::HealpixMap)
        HealpixMap(rhs.nside, rhs.order, $operator(lhs, rhs.pixels))
    end
end

for operator in (:*, :/)
    @eval function Base.broadcast(::typeof(Base.$operator), lhs::HealpixMap, rhs::HealpixMap)
        lhs.nside == rhs.nside || throw(DimensionMismatch())
        lhs.order == rhs.order || throw(ArgumentError("maps must have the same ordering"))
        HealpixMap(lhs.nside, lhs.order, broadcast($operator, lhs.pixels, rhs.pixels))
    end

    @eval function Base.broadcast(::typeof(Base.$operator), lhs::HealpixMap, rhs::Number)
        HealpixMap(lhs.nside, lhs.order, broadcast($operator, lhs.pixels, rhs))
    end

    @eval function Base.broadcast(::typeof(Base.$operator), lhs::Number, rhs::HealpixMap)
        HealpixMap(rhs.nside, rhs.order, broadcast($operator, lhs, rhs.pixels))
    end
end

function ang2pix(map::HealpixMap, θ, ϕ)
    if map.order == ring
        return ang2pix_ring(map.nside, θ, ϕ)
    else
        return ang2pix_nest(map.nside, θ, ϕ)
    end
end

function test(map::HealpixMap{Float64})
    @show map.pixels
    ccall(("test", libhealpixwrapper), Void, (Cint, Cint, Ptr{Float64},),
          map.nside, map.order, map.pixels)
end

#function interpolate(map::HealpixMap, θ::Float64, ϕ::Float64)
#    interpolate(to_cxx(map), θ, ϕ)
#end
#
#function interpolate(map::HealpixMap, θlist::Vector, ϕlist::Vector)
#    map_cxx = to_cxx(map)
#    Float64[interpolate(map_cxx, Float64(θ), Float64(ϕ)) for (θ, ϕ) in zip(θlist, ϕlist)]
#end

"""
    writehealpix(filename, map::HealpixMap; coordsys="C", replace=false)

Write the `HealpixMap` to disk as a FITS image.

The `coordsys` keyword specifies the coordinate system of the given `HealpixMap`, but this is
currently not retrieved by the corresponding `readhealpix` function.

If the file already exists, an `ErrorException` is thrown, but this behavior may be overwritten by
specifying `replace=true`.
"""
function writehealpix(filename, map::HealpixMap; coordsys::String = "C", replace::Bool = false)
    isdir(filename) && error("$filename is a directory")
    if isfile(filename)
        if replace
            rm(filename)
        else
            error("$filename already exists")
        end
    end
    pixels = Vector{Cfloat}(map.pixels)
    ccall(("write_healpix_map", libchealpix), Void,
          (Ptr{Cfloat}, Clong, Cstring, Cchar, Cstring),
          pixels, map.nside, filename, map.order == nest, coordsys)
    map
end

"""
    readhealpix(filename)

Read a `HealpixMap` (stored as a FITS image) from disk.
"""
function readhealpix(filename) :: HealpixMap
    nside = Ref{Clong}()
    # Make sure we're allocating enough space for these strings (so that they don't overwrite and
    # corrupt Julia's memory, oops).  All the credit goes to Yichao Yu for finding this.
    # see: https://github.com/JuliaLang/julia/issues/11945
    coordsys = zeros(UInt8, 10)
    ordering = zeros(UInt8, 10)
    ptr = ccall(("read_healpix_map", libchealpix), Ptr{Cfloat},
                (Cstring, Ref{Clong}, Ptr{UInt8}, Ptr{UInt8}),
                filename, nside, coordsys, ordering)
    HealpixMap(nside[], String(ordering[1:4]) == "RING"? ring : nest,
               unsafe_wrap(Array, ptr, nside2npix(nside[]), true))
end

#################################################################################
## C++ wrapper methods
#
#type HealpixMap_cxx
#    ptr :: Ptr{Void}
#end
#
#Base.unsafe_convert(::Type{Ptr{Void}}, map_cxx::HealpixMap_cxx) = map_cxx.ptr
#
#function delete(map_cxx::HealpixMap_cxx)
#    ccall(("deleteMap", libhealpixwrapper), Void, (Ptr{Void},), map_cxx)
#end
#
#for f in (:nside, :npix)
#    @eval function $f(map_cxx::HealpixMap_cxx)
#        ccall(($(string(f)), libhealpixwrapper), Cint, (Ptr{Void},), map_cxx)
#    end
#end
#
#function order(map_cxx::HealpixMap_cxx)
#    ccall(("order", libhealpixwrapper), Cint, (Ptr{Void},), map_cxx) |> Order
#end
#
#function to_cxx(map::HealpixMap)
#    map_cxx = ccall(("newMap",libhealpixwrapper), Ptr{Void}, (Ptr{Cdouble}, Csize_t, Cint),
#                    Vector{Float64}(pixels(map)), nside(map), order(map)) |> HealpixMap_cxx
#    finalizer(map_cxx, delete)
#    map_cxx
#end
#
#function to_julia(map_cxx::HealpixMap_cxx)
#    pix = Array{Cdouble}(npix(map_cxx))
#    ccall(("map2julia", libhealpixwrapper), Void, (Ptr{Void}, Ptr{Cdouble}), map_cxx, pix)
#    HealpixMap(pix, order(map_cxx))
#end
#
#function interpolate(map_cxx::HealpixMap_cxx, θ::Float64, ϕ::Float64)
#    θ, ϕ = verify_angles(θ, ϕ)
#    output = ccall(("interpolate", libhealpixwrapper), Cdouble,
#                   (Ptr{Void}, Cdouble, Cdouble), map_cxx, θ, ϕ)
#    output
#end

