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

type HEALPixMap{T<:FloatingPoint,nside,order}
    pixels::Vector{T}
    function HEALPixMap(vec)
        if npix2nside(length(vec)) != nside
            error("HEALPixMap with nside=$nside must have length $(nside2npix(nside)).")
        end
        new(vec)
    end
end

HEALPixMap{T}(nside::Int,order::Order,vec::Vector{T}) = HEALPixMap{T,nside,order}(vec)
HEALPixMap{T}(::Type{T},nside::Int,order::Order=ring) = HEALPixMap{T,nside,order}(zeros(T,nside2npix(nside)))

function HEALPixMap{T}(vec::Vector{T};order::Order=ring)
    nside = npix2nside(length(vec))
    if nside == -1
        error("The supplied vector does not have a valid length.")
    end
    HEALPixMap(nside,order,vec)
end

pixels(map::HEALPixMap) = map.pixels
length(map::HEALPixMap) = length(pixels(map))
getindex(map::HEALPixMap,i) = pixels(map)[i]
setindex!(map::HEALPixMap,x,i) = pixels(map)[i] = x

nside{T,_nside,order}(map::HEALPixMap{T,_nside,order}) = _nside
npix(map::HEALPixMap) = nside2npix(nside(map))
nring(map::HEALPixMap) = 4nside(map)-1

isring{T,nside,order}(map::HEALPixMap{T,nside,order}) = order == ring
isnest{T,nside,order}(map::HEALPixMap{T,nside,order}) = order == nest

getindex{T,nside}(map::HEALPixMap{T,nside,ring},θ,ϕ) = getindex(map,ang2pix_ring(nside,θ,ϕ))
getindex{T,nside}(map::HEALPixMap{T,nside,nest},θ,ϕ) = getindex(map,ang2pix_nest(nside,θ,ϕ))

for op in (:+,:-,:.*,:./)
    @eval $op(lhs::HEALPixMap,rhs::HEALPixMap) = HEALPixMap($op(pixels(lhs),pixels(rhs)))
end

*(lhs::Number,rhs::HEALPixMap) = HEALPixMap(lhs*pixels(rhs))
*(lhs::HEALPixMap,rhs::Number) = rhs*lhs

################################################################################
# C++ wrapper methods

type HEALPixMap_cxx
    ptr::Ptr{Void}
end

function delete(map_cxx::HEALPixMap_cxx)
    ccall(("deleteMap",libhealpixwrapper),Void,
          (Ptr{Void},),pointer(map_cxx))
end

pointer(map_cxx::HEALPixMap_cxx) = map_cxx.ptr

for f in (:nside,:npix)
    @eval $f(map_cxx::HEALPixMap_cxx) = ccall(($(string(f)),libhealpixwrapper),Cint,(Ptr{Void},),pointer(map_cxx))
end

function to_cxx(map::HEALPixMap)
    N = nside(map)
    map_cxx = HEALPixMap_cxx(ccall(("newMap",libhealpixwrapper),Ptr{Void},
                                   (Ptr{Complex128},Csize_t),
                                   pointer(pixels(map)),Csize_t(N)))
    finalizer(map_cxx,delete)
    map_cxx
end

function to_julia(map_cxx::HEALPixMap_cxx)
    # TODO: check and propagate the ordering of the C++ map
    N = nside(map_cxx)
    output = Array{Cdouble}(nside2npix(N))
    ccall(("map2julia",libhealpixwrapper),Void,
          (Ptr{Void},Ptr{Cdouble}),
          pointer(map_cxx),pointer(output))
    HEALPixMap(output)
end

