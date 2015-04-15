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

################################################################################
# Pixel operations

for T in (:Clong,:Clonglong)
    # Append "64" to the ccall function name when defining for Clonglong
    # (note we omit this suffix from the Julia function name -- just let dispatch take care of it)
    funcname(f) = (T==:Clong)? string(f) : string(f)*"64"

    for f in (:ang2pix_nest,:ang2pix_ring)
        @eval function $f(nside::$T,theta::Cdouble,phi::Cdouble)
            ipixptr = Array($T,1)
            ccall(($(funcname(f)),libchealpix),Void,($T,Cdouble,Cdouble,Ptr{$T}),nside,theta,phi,ipixptr)
            ipixptr[1] + 1 # Add one to convert to a 1-indexed scheme
        end
    end

    for f in (:pix2ang_nest,:pix2ang_ring)
        @eval function $f(nside::$T,ipix::$T)
            ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
            thetaptr = Array(Cdouble,1)
            phiptr   = Array(Cdouble,1)
            ccall(($(funcname(f)),libchealpix),Void,($T,$T,Ptr{Cdouble},Ptr{Cdouble}),nside,ipix,thetaptr,phiptr)
            thetaptr[1],phiptr[1]
        end
    end

    for f in (:nest2ring,:ring2nest)
        @eval function $f(nside::$T,ipix::$T)
            ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
            ipixoutptr = Array($T,1)
            ccall(($(funcname(f)),libchealpix),Void,($T,$T,Ptr{$T}),nside,ipix,ipixoutptr)
            ipixoutptr[1] + 1 # Add one to convert to a 1-indexed scheme
        end
    end

    for f in (:nside2npix,:npix2nside)
        @eval $f(x::$T) = ccall(($(funcname(f)),libchealpix),$T,($T,),x)
    end

    for f in (:vec2pix_nest,:vec2pix_ring)
        @eval function $f(nside::$T,vec::Vector{Cdouble})
            ipixptr = Array($T,1)
            ccall(($(funcname(f)),libchealpix),Void,($T,Ptr{Cdouble},Ptr{$T}),nside,vec,ipixptr)
            ipixptr[1] + 1 # Add one to convert to a 1-indexed scheme
        end
    end

    for f in (:pix2vec_nest,:pix2vec_ring)
        @eval function $f(nside::$T,ipix::$T)
            ipix -= 1 # Subtract one to convert back to a 0-indexed scheme
            vec = Array(Cdouble,3)
            ccall(($(funcname(f)),libchealpix),Void,($T,$T,Ptr{Cdouble}),nside,ipix,vec)
            vec
        end
    end
end

function ang2vec(theta::Cdouble,phi::Cdouble)
    vec = Array(Cdouble,3)
    ccall(("ang2vec",libchealpix),Void,(Cdouble,Cdouble,Ptr{Cdouble}),theta,phi,vec)
    vec
end

function vec2ang(vec::Vector{Cdouble})
    thetaptr = Array(Cdouble,1)
    phiptr   = Array(Cdouble,1)
    ccall(("vec2ang",libchealpix),Void,(Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}),vec,thetaptr,phiptr)
    thetaptr[1],phiptr[1]
end

