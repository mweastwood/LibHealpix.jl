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

doc"""
    struct Alm{T<:Number} <: AbstractVector{T}

This type holds a vector of spherical harmonic coefficients.

**Fields:**

- `lmax` - the maximum value for the $l$ quantum number
- `mmax` - the maximum value for the $m$ quantum number (note that $m ≤ l$)
- `coefficients` - the list of spherical harmonic coefficients

**Constructors:**

    Alm(T, lmax, mmax)

Construct an `Alm` object that will store all spherical harmonic coefficients with element type `T`,
$l ≤ lₘₐₓ$, and $m ≤ mₘₐₓ$. All of the coefficients will be initialized to zero.

    Alm(lmax, mmax, coefficients)

Construct an `Alm` object with the given list of initial coefficients corresponding to $l ≤ lₘₐₓ$,
and $m ≤ mₘₐₓ$. A `LibHealpixException` will be thrown if too many or too few coefficients are
provided.

**Usage:**

```jldoctest
julia> alm = Alm(Complex128, 10, 10)
       for (l, m) in lm(alm)
           @lm alm[l, m] = l * m
       end
       @lm(alm[10, 5]) == 50
true
```

!!! note
    The `lm` function is used to iterate over the spherical harmonic quantum numbers $l$ and $m$.

!!! note
    The `@lm` macro is used to index into an `Alm` object when given the spherical harmonic quantum
    numbers $l$ and $m$.

**See also:** [`RingHealpixMap`](@ref), [`NestHealpixMap`](@ref), [`lm`](@ref), [`@lm`](@ref)
"""
struct Alm{T<:Number} <: AbstractVector{T}
    lmax :: Int
    mmax :: Int
    coefficients :: Vector{T}
    function Alm{T}(lmax, mmax, coefficients) where T
        lmax ≥ mmax || err("lmax must be ≥ mmax")
        N = ncoeff(lmax, mmax)
        N == length(coefficients) || err("expected $N coefficients with lmax=$lmax and mmax=$mmax")
        new(lmax, mmax, coefficients)
    end
end

function Alm(::Type{T}, lmax::Int, mmax::Int) where T
    Alm{T}(lmax, mmax, zeros(T, ncoeff(lmax, mmax)))
end

function Alm(lmax::Int, mmax::Int, coefficients::AbstractVector{T}) where T
    Alm{T}(lmax, mmax, coefficients)
end

"""
    ncoeff(lmax, mmax)

Compute the number of spherical harmonic coefficients with `l ≤ lmax` and `m ≤ mmax`.
"""
ncoeff(lmax, mmax) = length(lm(lmax, mmax))

# Implement the AbstractArray interface
Base.length(alm::Alm) = length(alm.coefficients)
Base.size(alm::Alm) = (length(alm.coefficients),)
Base.getindex(alm::Alm, index::Int) = alm.coefficients[index]
Base.setindex!(alm::Alm, value, index::Int) = alm.coefficients[index] = value
Base.IndexStyle(::Alm) = Base.IndexLinear()
Base.similar(alm::Alm{T}) where {T} = Alm(T, alm.lmax, alm.mmax)

# Additionally we would like to allow indexing by the quantum numbers `l` and `m`. Unfortunately
# this is not straightforward. We chose to make `Alm <: AbstractVector` because this allows `Alm` to
# behave as if it is a regular `Vector` in a large number of situations, which is convenient.
# Unfortunately the `getindex` method with two indices already has a meaning for `AbstractVector`s.
#
# Consider:
#     julia> x = [1, 2, 3];
#
#     julia> x[2]
#     2
#
#     julia> x[2, 1]
#     2
#
# You are allowed to index into an `AbstractVector` with as many trailing ones as you like.
#
# This precludes the possibility of using
#     getindex(::Alm, index) -> index by coefficient order
#     getindex(::Alm, l, m)  -> index by value of the quantum numbers l and m
#
# Therefore we will use a macro to write
#     @lm alm[l, m]         -> getindex_lm(alm, l, m)
#     @lm alm[l, m] = value -> setindex_lm!(alm, value, l, m)
#
# This gets us pretty close to the desired syntax without breaking any assumptions about how
# indexing into `AbstractVector`s works within Julia.
#
# References:
# - https://discourse.julialang.org/t/custom-indexing-for-an-abstractvector-breaks-display-but-not-show/3813
# - https://github.com/JuliaLang/julia/issues/14770

Base.@propagate_inbounds function lm2index(lmax, l, m)
    @boundscheck m ≥ 0 || err("m must be ≥ 0")
    @boundscheck l ≥ m || err("l must be ≥ m")
    @boundscheck lmax ≥ l || err("lmax must be ≥ l")
    (m * (2lmax - m + 3)) ÷ 2 + l - m + 1
end

getindex_lm(alm::Alm, ::Colon, ::Colon) = alm[:]
getindex_lm(alm::Alm, l::Integer, m::Integer) = alm[lm2index(alm.lmax, l, m)]
function getindex_lm(alm::Alm, ::Colon, m::Integer)
    collect(alm[lm2index(alm.lmax, l, m)] for l in m:alm.lmax)
end
function getindex_lm(alm::Alm, l::Integer, ::Colon)
    collect(alm[lm2index(alm.lmax, l, m)] for m in 0:min(alm.mmax, l))
end

setindex_lm!(alm::Alm, value, ::Colon, ::Colon) = alm[:] = value
setindex_lm!(alm::Alm, value, l::Integer, m::Integer) = alm[lm2index(alm.lmax, l, m)] = value
function setindex_lm!(alm::Alm, value, ::Colon, m::Integer)
    for (l, idx) in zip(m:alm.lmax, eachindex(value))
        alm[lm2index(alm.lmax, l, m)] = value[idx]
    end
end
function setindex_lm!(alm::Alm, value, l::Integer, ::Colon)
    for (m, idx) in zip(0:min(alm.mmax, l), eachindex(value))
        alm[lm2index(alm.lmax, l, m)] = value[idx]
    end
end

doc"""
    @lm

This macro is used to index an `Alm` object when given the values for quantum numbers $l$ and $m$.

**Usage**

```jldoctest
julia> alm = Alm(Int, 2, 1)
       for (l, m) in lm(alm)
           @lm alm[l, m] = l + m
       end

julia> @lm alm[1, 1]
2

julia> @lm alm[1, :] # all coefficients with l == 1
2-element Array{Int64,1}:
 1
 2

julia> @lm alm[:, 1] # all coefficients with m == 1
2-element Array{Int64,1}:
 2
 3
```

**Background**

`Alm` implements the `AbstractVector` interface which allows the type to be used in place of a
standard `Vector` in many cases. This generally makes sense because `Alm` is simply a wrapper around
a standard `Vector`.

However, one consequence of being an `AbstractVector` is that the two-element `getindex` function
already has a meaning and therefore `alm[l, m]` *cannot* be used to mean "give me the coefficient
corresponding to the quantum numbers $l$ and $m$". Instead `@lm alm[l, m]` calls a separate function
that does give you the coefficient for $l$ and $m$.

**See Also:** [`Alm`](@ref), [`lm`](@ref)
"""
macro lm(expr)
    colon = :(:)
    if @capture(expr, alm_[l_, m_])
        # getindex
        @esc alm l m
        return quote
            getindex_lm($alm, $l, $m)
        end
    elseif @capture(expr, alm_[l_, m_] = value_)
        # setindex!
        @esc alm l m value
        return quote
            setindex_lm!($alm, $value, $l, $m)
        end
    else
        err("@lm usage examples: `@lm alm[l, m]` or `@lm alm[l, m] = value`")
    end
end

# Iterate over spherical harmonic quantum numbers

struct QuantumNumberIterator
    lmax :: Int
    mmax :: Int
    function QuantumNumberIterator(lmax, mmax)
        lmax ≥ mmax || err("lmax must be ≥ mmax")
        new(lmax, mmax)
    end
end

Base.start(iter::QuantumNumberIterator) = 0, 0

function Base.next(iter::QuantumNumberIterator, state)
    l, m = state
    if l == iter.lmax
        l′ = m + 1
        m′ = m + 1
    else
        l′ = l + 1
        m′ = m
    end
    (l, m), (l′, m′)
end

function Base.done(iter::QuantumNumberIterator, state)
    l, m = state
    m > iter.mmax
end

Base.length(iter::QuantumNumberIterator) = ((2iter.lmax + 2 - iter.mmax) * (iter.mmax + 1)) ÷ 2
Base.eltype(::Type{QuantumNumberIterator}) = Tuple{Int, Int}

doc"""
    lm(lmax, mmax)
    lm(alm)

Construct an interator for iterating over all possible values of the spherical harmonic quantum
numbers $l ≤ lₘₐₓ$ and $m ≤ mₘₐₓ$.

**Arguments:**

- `lmax` - the maximum value of $l$
- `mmax` - the maximum value of $m$
- `alm` - if an `Alm` object is provided, `lmax` and `mmax` will be inferred from the corresponding
    fields

**Usage:**

```jldoctest
julia> for (l, m) in lm(2, 1)
           @show l, m
       end
(l, m) = (0, 0)
(l, m) = (1, 0)
(l, m) = (2, 0)
(l, m) = (1, 1)
(l, m) = (2, 1)
```

**See Also:** [`Alm`](@ref), [`@lm`](@ref)
"""
lm(lmax, mmax) = QuantumNumberIterator(lmax, mmax)
lm(alm::Alm) = lm(alm.lmax, alm.mmax)

function Base.:(==)(lhs::Alm, rhs::Alm)
    lhs.lmax == rhs.lmax && lhs.mmax == rhs.mmax && lhs.coefficients == rhs.coefficients
end

# In general, Alms can only be == to other Alms because the meaning of the coefficients is
# important. The AbstractVector fallback will simply compare the two vectors element-wise.  However
# two Alms can be element-wise the same, but different if lmax and mmax are different.  This
# behavior is therefore undesirable so we override it here.
Base.:(==)(lhs::Alm, rhs::AbstractVector) = false
Base.:(==)(lhs::AbstractVector, rhs::Alm) = false

# Custom broadcasting
Base.Broadcast.broadcast_indices(::Type{<:Alm}, alm) = indices(alm)
Base.Broadcast._containertype(::Type{<:Alm}) = Alm
Base.Broadcast.promote_containertype(::Type{Any}, ::Type{Alm}) = Alm
Base.Broadcast.promote_containertype(::Type{Alm}, ::Type{Any}) = Alm
Base.Broadcast.promote_containertype(::Type{Array}, ::Type{Alm}) = Alm
Base.Broadcast.promote_containertype(::Type{Alm}, ::Type{Array}) = Alm

function Base.Broadcast.broadcast_c(f, ::Type{Alm}, args...)
    lmax = broadcast_lmax(args...)
    mmax = broadcast_mmax(args...)
    coefficients = broadcast_coefficients(args...)
    Alm(lmax, mmax, broadcast(f, coefficients...))
end

@inline broadcast_lmax(x, y, z...) = _broadcast_lmax(_lmax(x), broadcast_lmax(y, z...))
@inline broadcast_lmax(x, y) = _broadcast_lmax(_lmax(x), _lmax(y))
@inline broadcast_lmax(x) = _lmax(x)
@inline _broadcast_lmax(lmax::Integer, ::Void) = lmax
@inline _broadcast_lmax(::Void, lmax::Integer) = lmax
@inline function _broadcast_lmax(lmax1::Integer, lmax2::Integer)
    lmax1 == lmax2 || err("cannot broadcast two Alms with different values for lmax")
    lmax1
end
@inline _lmax(alm::Alm) = alm.lmax
@inline _lmax(other) = nothing

@inline broadcast_mmax(x, y, z...) = _broadcast_mmax(_mmax(x), broadcast_mmax(y, z...))
@inline broadcast_mmax(x, y) = _broadcast_mmax(_mmax(x), _mmax(y))
@inline broadcast_mmax(x) = _mmax(x)
@inline _broadcast_mmax(mmax::Integer, ::Void) = mmax
@inline _broadcast_mmax(::Void, mmax::Integer) = mmax
@inline function _broadcast_mmax(mmax1::Integer, mmax2::Integer)
    mmax1 == mmax2 || err("cannot broadcast two Alms with different values for mmax")
    mmax1
end
@inline _mmax(alm::Alm) = alm.mmax
@inline _mmax(other) = nothing

@inline broadcast_coefficients(x, y...) = (_coefficients(x), broadcast_coefficients(y...)...)
@inline broadcast_coefficients(x) = (_coefficients(x),)
@inline _coefficients(alm::Alm) = alm.coefficients
@inline _coefficients(other) = other

