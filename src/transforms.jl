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

type Alm
    ptr::Ptr{Void}
end

function Alm(vec::Vector{Complex128},lmax::Int,mmax::Int)
    num_alm(lmax,mmax) == length(vec) || error("length of vector inconsistent with given lmax, mmax")
    alm = Alm(ccall(("newAlm",libhealpixwrapper),Ptr{Void},
                    (Ptr{Complex128},Csize_t,Csize_t),
                    pointer(vec),Csize_t(lmax),Csize_t(mmax)))
    finalizer(alm,delete_alm)
    alm
end

function delete_alm(alm::Alm)
    ccall(("deleteAlm",libhealpixwrapper),Void,
          (Ptr{Void},),alm.ptr)
end

function num_alm(lmax::Int,mmax::Int)
    mmax > lmax && error("must have mmax ≤ lmax")
    Int(ccall(("num_alm",libhealpixwrapper),Csize_t,
              (Csize_t,Csize_t),
              Csize_t(lmax),Csize_t(mmax)))
end

type HEALPixMap_cxx
    ptr::Ptr{Void}
end

function HEALPixMap_cxx(vec::Vector{Float64})
    nside = npix2nside(length(vec))
    map = HEALPixMap_cxx(ccall(("newMap",libhealpixwrapper),Ptr{Void},
                               (Ptr{Complex128},Csize_t),
                               pointer(vec),Csize_t(nside)))
    finalizer(map,delete_map)
    map
end

function delete_map(map::HEALPixMap_cxx)
    ccall(("deleteMap",libhealpixwrapper),Void,
          (Ptr{Void},),map.ptr)
end

#function map2alm(map::HEALPixMap;lmax::Int=100,mmax::Int=100)
#end

function alm2map(alm_vec::Vector{Complex128};nside::Int=32)
    lmax = 1 # hard coded for now
    mmax = 1 # hard coded for now
    npix = nside2npix(nside)

    alm = Alm(alm_vec,lmax,mmax)
    map = HEALPixMap_cxx(zeros(Cdouble,npix))
    output = zeros(Cdouble,npix)
    ccall(("alm2map",libhealpixwrapper),Void,
          (Ptr{Void},Ptr{Void}),
          alm.ptr,map.ptr)
    ccall(("map2julia",libhealpixwrapper),Void,
          (Ptr{Void},Ptr{Cdouble}),
          map.ptr,pointer(output))
    HEALPixMap(nside,true,output)
end

