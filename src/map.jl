# Copyright (c) 2015 Michael Eastwood
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
    HealpixMap{T<:AbstractFloat,nside,order}

This type holds a list of pixel values. Each pixel corresponds to an
equal-area region on the surface of a sphere as is defined by the
Healpix projection.

Construction of this type will throw a `DimensionMismatch` exception
if the incorrect number of pixels are provided for the given value
of `nside`. Use the function `nside2npix` to compute the appropriate
number of pixels.

The type parameter `order` must be one of either `LibHealpix.ring`
or `LibHealpix.nest`. This defines whether pixels should be ordered
by equal latitude rings (useful for spherical harmonic transforms)
or by a nested scheme where adjacent pixels are likely to be nearby
in memory.
"""
type HealpixMap{T<:AbstractFloat,nside,order}
    pixels::Vector{T}
    function HealpixMap(vec)
        N = nside2npix(nside)
        N == length(vec) || throw(DimensionMismatch("Expected $N pixels with nside=$nside."))
        new(vec)
    end
end

"""
    HealpixMap(nside,order,pixels)

Construct a `HealpixMap` with the given list of pixel values.
"""
HealpixMap{T}(nside::Int,order::Order,vec::Vector{T}) = HealpixMap{T,nside,order}(vec)
"""
    HealpixMap(T,nside,order=LibHealpix.ring)

Construct a `HealpixMap` where all the coefficients are initialized to `zero(T)`.
"""
HealpixMap{T}(::Type{T},nside::Int,order::Order=ring) = HealpixMap{T,nside,order}(zeros(T,nside2npix(nside)))

"""
    HealpixMap(pixels;order=LibHealpix.ring)

Construct a `HealpixMap` with the given list of pixel values.
The value of `nside` is inferred from the number of pixels.
"""
function HealpixMap{T}(vec::Vector{T};order::Order=ring)
    nside = npix2nside(length(vec))
    nside < 0 && throw(DimensionMismatch("The supplied list of pixels does not have a valid length."))
    HealpixMap(nside,order,vec)
end

pixels(map::HealpixMap) = map.pixels
length(map::HealpixMap) = length(pixels(map))
getindex(map::HealpixMap,i) = pixels(map)[i]
setindex!(map::HealpixMap,x,i) = pixels(map)[i] = x

nside{T,_nside,order}(map::HealpixMap{T,_nside,order}) = _nside
npix(map::HealpixMap) = nside2npix(nside(map))
nring(map::HealpixMap) = 4nside(map)-1

isring{T,nside,order}(map::HealpixMap{T,nside,order}) = order == ring
isnest{T,nside,order}(map::HealpixMap{T,nside,order}) = order == nest

getindex{T,nside}(map::HealpixMap{T,nside,ring},θ,ϕ) = getindex(map,ang2pix_ring(nside,θ,ϕ))
getindex{T,nside}(map::HealpixMap{T,nside,nest},θ,ϕ) = getindex(map,ang2pix_nest(nside,θ,ϕ))

for op in (:+,:-,:.*,:./)
    @eval $op(lhs::HealpixMap,rhs::HealpixMap) = HealpixMap($op(pixels(lhs),pixels(rhs)))
end

*(lhs::Number,rhs::HealpixMap) = HealpixMap(lhs*pixels(rhs))
*(lhs::HealpixMap,rhs::Number) = rhs*lhs

function ==(lhs::HealpixMap,rhs::HealpixMap)
    nside(lhs) == nside(rhs) && isring(lhs) == isring(rhs) && pixels(lhs) == pixels(rhs)
end

"""
    writehealpix(filename,map::HealpixMap;coordsys="C",replace=false)

Write the `HealpixMap` to disk as a FITS image. If the file already exists,
an `ErrorException` is thrown, but this behavior may be overwritten
by specifying `replace=true`. The `coordsys` keyword specifies the
coordinate system of the given `HealpixMap`, but this is currently
not retrieved by the corresponding `readhealpix` function.
"""
function writehealpix(filename,map::HealpixMap;
                      coordsys::ASCIIString = "C",
                      replace::Bool = false)
    isdir(filename) && error("$filename is a directory")
    if isfile(filename)
        if replace
            rm(filename)
        else
            error("$filename already exists")
        end
    end
    # TODO: check return value
    ccall(("write_healpix_map",libchealpix),Cint,
          (Ptr{Cfloat},Clong,Ptr{Cchar},Cchar,Ptr{Cchar}),
          pointer(Vector{Cfloat}(pixels(map))),
          nside(map),pointer(filename),
          isnest(map),pointer(coordsys))
end

"""
    readhealpix(filename) -> HealpixMap

Read a `HealpixMap` (stored as a FITS image) from disk.
"""
function readhealpix(filename)
    nside = Ref{Clong}()
    # Make sure we're allocating enough space for
    # these strings (so that they don't overwrite
    # and corrupt Julia's memory, oops).
    # All the credit goes to Yichao Yu for finding this.
    # see: https://github.com/JuliaLang/julia/issues/11945
    coordsys = zeros(UInt8,10)
    ordering = zeros(UInt8,10)
    ptr = ccall(("read_healpix_map",libchealpix),Ptr{Cfloat},
                (Ptr{Cchar},Ref{Clong},Ptr{UInt8},Ptr{UInt8}),
                pointer(filename),nside,pointer(coordsys),pointer(ordering))
    HealpixMap(nside[],bytestring(ordering)[1:4] == "RING"? ring : nest,
               pointer_to_array(ptr,nside2npix(nside[]),true))
end

################################################################################
# C++ wrapper methods

type HealpixMap_cxx
    ptr::Ptr{Void}
end

function delete(map_cxx::HealpixMap_cxx)
    ccall(("deleteMap",libhealpixwrapper),Void,
          (Ptr{Void},),pointer(map_cxx))
end

pointer(map_cxx::HealpixMap_cxx) = map_cxx.ptr

for f in (:nside,:npix)
    @eval $f(map_cxx::HealpixMap_cxx) = ccall(($(string(f)),libhealpixwrapper),Cint,(Ptr{Void},),pointer(map_cxx))
end

function to_cxx(map::HealpixMap)
    N = nside(map)
    map_cxx = HealpixMap_cxx(ccall(("newMap",libhealpixwrapper),Ptr{Void},
                                   (Ptr{Cdouble},Csize_t),
                                   pixels(map),Csize_t(N)))
    finalizer(map_cxx,delete)
    map_cxx
end

function to_julia(map_cxx::HealpixMap_cxx)
    # TODO: check and propagate the ordering of the C++ map
    N = nside(map_cxx)
    output = Array{Cdouble}(nside2npix(N))
    ccall(("map2julia",libhealpixwrapper),Void,
          (Ptr{Void},Ptr{Cdouble}),
          pointer(map_cxx),pointer(output))
    HealpixMap(output)
end

