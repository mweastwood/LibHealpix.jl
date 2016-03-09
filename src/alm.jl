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

"""
    Alm{T<:Complex, lmax, mmax}

This type holds a vector of spherical harmonic coefficients.

Construction of this type will throw a `DomainError` exception if `mmax > lmax`.
A `DimensionMismatch` exception will be thrown if the provided
list of coefficients is not the correct length.

    Alm(lmax, mmax, coefficients)

Construct an `Alm` object with the given list of coefficients.

    Alm(T, lmax, mmax)

Construct an `Alm` object where all the coefficients are initialized to `zero(T)`.
"""
immutable Alm{T<:Complex,lmax,mmax}
    alm :: Vector{T}
    function Alm(vec)
        lmax ≥ mmax || throw(DomainError())
        N = num_alm(lmax,mmax)
        N == length(vec) || throw(DimensionMismatch("Expected $N coefficients with lmax=$lmax and mmax=$mmax."))
        new(vec)
    end
end

Alm{T}(lmax::Int,mmax::Int,vec::Vector{T}) = Alm{T,lmax,mmax}(vec)
Alm{T}(::Type{T},lmax::Int,mmax::Int) = Alm{T,lmax,mmax}(zeros(T,num_alm(lmax,mmax)))

"""
    num_alm(lmax, mmax)

Compute the number of spherical harmonic coefficients with `l ≤ lmax`
and `m ≤ mmax`.
"""
function num_alm(lmax::Csize_t, mmax::Csize_t)
    lmax ≥ mmax || throw(DomainError())
    ccall(("num_alm", libhealpixwrapper), Csize_t, (Csize_t, Csize_t), lmax, mmax)
end
num_alm(lmax,mmax) = num_alm(Csize_t(lmax),Csize_t(mmax))

coefficients(alm::Alm) = alm.alm
length(alm::Alm) = length(coefficients(alm))
getindex(alm::Alm, i) = coefficients(alm)[i]
setindex!(alm::Alm, x, i) = coefficients(alm)[i] = x

lmax{T, l, m}(alm::Alm{T, l, m}) = l
mmax{T, l, m}(alm::Alm{T, l, m}) = m

function getindex(alm::Alm, l, m)
    absm = abs(m)
    output = alm[div(absm*(2lmax(alm)-absm+3),2)+l-absm+1]
    ifelse(m ≥ 0, output, (-1)^absm*conj(output))
end

function setindex!(alm::Alm, x, l, m)
    absm = abs(m)
    x = ifelse(m ≥ 0, x, (-1)^absm*conj(x))
    alm[div(absm*(2lmax(alm)-absm+3),2)+l-absm+1] = x
end

for op in (:+,:-)
    @eval function $op(lhs::Alm, rhs::Alm)
        Alm(lmax(lhs), mmax(lhs), $op(coefficients(lhs), coefficients(rhs)))
    end
end

*(lhs::Number, rhs::Alm) = Alm(lmax(rhs), mmax(rhs), lhs * coefficients(rhs))
*(lhs::Alm, rhs::Number) = rhs * lhs

function ==(lhs::Alm, rhs::Alm)
    lmax(lhs) == lmax(rhs) && mmax(lhs) == mmax(rhs) && coefficients(lhs) == coefficients(rhs)
end

################################################################################
# C++ wrapper methods

type Alm_cxx
    ptr :: Ptr{Void}
end

Base.unsafe_convert(::Type{Ptr{Void}}, alm_cxx::Alm_cxx) = alm_cxx.ptr

function delete(alm_cxx::Alm_cxx)
    ccall(("deleteAlm",libhealpixwrapper), Void, (Ptr{Void},), alm_cxx)
end

for f in (:lmax,:mmax)
    @eval function $f(alm_cxx::Alm_cxx)
        ccall(($(string(f)), libhealpixwrapper), Cint, (Ptr{Void},), alm_cxx)
    end
end

function to_cxx(alm::Alm)
    l = lmax(alm)
    m = mmax(alm)
    alm_cxx = ccall(("newAlm", libhealpixwrapper), Ptr{Void}, (Ptr{Complex128}, Csize_t, Csize_t),
                    coefficients(alm), l, m) |> Alm_cxx
    finalizer(alm_cxx, delete)
    alm_cxx
end

function to_julia(alm_cxx::Alm_cxx)
    l = lmax(alm_cxx)
    m = mmax(alm_cxx)
    coef = Array{Complex128}(num_alm(l, m))
    ccall(("alm2julia", libhealpixwrapper), Void, (Ptr{Void},Ptr{Complex128}), alm_cxx, coef)
    Alm(Int(l), Int(m), coef)
end

