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
    verify_angles(θ, ϕ)

Spherical coordinates expect $θ ∈ [0,π]$, and $ϕ ∈ [0,2π)$.  This function simply checks and
enforces these expectations.
"""
function verify_angles(θ, ϕ)
    θ_float = float(θ)
    ϕ_float = float(ϕ)
    0 ≤ θ_float ≤ π || throw(DomainError())
    ϕ_float = mod2pi(ϕ_float)
    θ_float, ϕ_float
end

"""
    verify_unit_vector(vec)

Check that the vector has length 3 and normalize the vector.
"""
function verify_unit_vector(vec)
    length(vec) == 3 || throw(ArgumentError("length of a unit vector must be 3"))
    normalization = norm(vec)
    normalization > 0 || throw(ArgumentError("vector must not have zero norm"))
    SVector(vec[1]/normalization, vec[2]/normalization, vec[3]/normalization)
end

"""
    nside2npix(nside)

Compute the number of pixels in a Healpix map with the given value of nside.
"""
Base.@pure nside2npix(nside::Integer) = 12*nside*nside

"""
    npix2nside(npix)

Compute the value of the parameter nside for a Healpix map with the given number of pixels.
"""
function npix2nside(npix::Integer)
    nside = isqrt(npix÷12)
    nside2npix(nside) == npix || throw(ArgumentError("the given number of pixels is invalid"))
    nside
end

"""
    ang2vec(θ, ϕ)

Compute the Cartesian unit vector to the spherical coordinates (θ, ϕ).
"""
function ang2vec(θ, ϕ)
    θ′, ϕ′ = verify_angles(θ, ϕ)
    s = sin(θ′)
    x = s*cos(ϕ′)
    y = s*sin(ϕ′)
    z = cos(θ′)
    SVector(x, y, z)
end

"""
    vec2ang(vec)

Compute the spherical coordinates (θ, ϕ) from the given vector.
"""
function vec2ang(vec)
    vec = verify_unit_vector(vec)
    θ = acos(vec[3])
    ϕ = atan2(vec[2], vec[1])
    ϕ = mod2pi(ϕ)
    θ, ϕ
end

types = (Clong == Clonglong)? (:Clong,) : (:Clong, :Clonglong)
for T in types
    # Append "64" to the ccall function name when defining for Clonglong
    # (note we omit this suffix from the Julia function name -- just let dispatch take care of it)
    funcname(f) = (T == :Clong)? string(f) : string(f)*"64"

    for f in (:nest2ring, :ring2nest)
        @eval function $f(nside::$T, ipix::$T)
            ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
            ipixoutptr = Ref{$T}(0)
            ccall(($(funcname(f)), libchealpix), Void, ($T, $T, Ref{$T}),
                  nside, ipix, ipixoutptr)
            ipixoutptr[] + 1 # Add one to convert to a 1-indexed scheme
        end
    end

    for f in (:ang2pix_nest, :ang2pix_ring)
        @eval function $f(nside::$T, θ::Cdouble, ϕ::Cdouble)
            θ, ϕ = verify_angles(θ, ϕ)
            ipixptr = Ref{$T}(0)
            ccall(($(funcname(f)), libchealpix), Void, ($T, Cdouble, Cdouble, Ref{$T}),
                  nside, θ, ϕ, ipixptr)
            ipixptr[] + 1 # Add one to convert to a 1-indexed scheme
        end
    end

    for f in (:pix2ang_nest, :pix2ang_ring)
        @eval function $f(nside::$T, ipix::$T)
            ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
            θptr = Ref{Cdouble}(0.0)
            ϕptr = Ref{Cdouble}(0.0)
            ccall(($(funcname(f)), libchealpix), Void, ($T, $T, Ref{Cdouble}, Ref{Cdouble}),
                  nside, ipix, θptr, ϕptr)
            θptr[], ϕptr[]
        end
    end

    for f in (:vec2pix_nest, :vec2pix_ring)
        @eval function $f(nside::$T, vec::AbstractVector{Cdouble})
            ipixptr = Ref{$T}(0)
            ccall(($(funcname(f)), libchealpix), Void, ($T, Ptr{Cdouble}, Ref{$T}),
                  nside, vec, ipixptr)
            ipixptr[] + 1 # Add one to convert to a 1-indexed scheme
        end
    end

    for f in (:pix2vec_nest, :pix2vec_ring)
        @eval function $f(nside::$T, ipix::$T)
            ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
            vec = Ref{SVector{3, Cdouble}}(SVector(0, 0, 0))
            ccall(($(funcname(f)), libchealpix), Void, ($T, $T, Ptr{Cdouble}),
                  nside, ipix, vec)
            vec[]
        end
    end
end

