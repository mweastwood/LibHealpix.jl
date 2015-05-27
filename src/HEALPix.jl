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

module HEALPix

export HEALPixMap, pixels, nside, npix, nring, isring, isnest
export Alm, coefficients, lmax, mmax
export npix2nside, nside2npix
export map2alm, alm2map
export mollweide

import Base: length, getindex, setindex!, pointer

const libchealpix = joinpath(dirname(@__FILE__),"../deps/downloads/Healpix_3.20/lib/libchealpix.so")
const libhealpixwrapper = joinpath(dirname(@__FILE__),"../deps/libhealpixwrapper.so")

const UNDEF = -1.6375e30 # Defined by the Healpix standard

include("pixel.jl")
include("map.jl")
include("alm.jl")
include("transforms.jl")
include("mollweide.jl")

end

