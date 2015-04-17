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

type Alm{T<:Complex,lmax,mmax}
    alm::Vector{T}
    function Alm(vec)
        if length(vec) != num_alm(lmax,mmax)
            error("Alm with lmax=$lmax and mmax=$mmax must have length $(num_alm(lmax,mmax)).")
        end
        new(vec)
    end
end

Alm{T}(lmax::Int,mmax::Int,vec::Vector{T}) = Alm{T,lmax,mmax}(vec)

function num_alm(lmax::Csize_t,mmax::Csize_t)
    mmax > lmax && error("must have mmax ≤ lmax")
    ccall(("num_alm",libhealpixwrapper),Csize_t,
          (Csize_t,Csize_t),lmax,mmax)
end
num_alm(lmax,mmax) = num_alm(Csize_t(lmax),Csize_t(mmax))

coefficients(alm::Alm) = alm.alm
length(alm::Alm) = length(coefficients(alm))
getindex(alm::Alm,i) = coefficients(alm)[i]
setindex!(alm::Alm,x,i) = coefficients(alm)[i] = x

lmax{T,l,m}(alm::Alm{T,l,m}) = l
mmax{T,l,m}(alm::Alm{T,l,m}) = m

################################################################################
# C++ wrapper methods

type Alm_cxx
    ptr::Ptr{Void}
end

function delete(alm_cxx::Alm_cxx)
    ccall(("deleteAlm",libhealpixwrapper),Void,
          (Ptr{Void},),pointer(alm_cxx))
end

pointer(alm_cxx::Alm_cxx) = alm_cxx.ptr

function to_cxx(alm::Alm)
    l = lmax(alm)
    m = mmax(alm)
    alm_cxx = Alm_cxx(ccall(("newAlm",libhealpixwrapper),Ptr{Void},
                            (Ptr{Complex128},Csize_t,Csize_t),
                            pointer(coefficients(alm)),Csize_t(l),Csize_t(m)))
    finalizer(alm_cxx,delete)
    alm_cxx
end

