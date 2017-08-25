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

__precompile__()

module LibHealpix

export LibHealpixException

# pixel.jl
export nside2npix, npix2nside, nside2nring
export ang2vec, vec2ang
export nest2ring, ring2nest
export ang2pix_nest, ang2pix_ring, pix2ang_nest, pix2ang_ring
export vec2pix_nest, vec2pix_ring, pix2vec_nest, pix2vec_ring

# map.jl
export HealpixMap, RingHealpixMap, NestHealpixMap
export ang2pix, pix2ang, vec2pix, pix2vec
export isring, isnest
export query_disc

# alm.jl
export Alm, @lm, lm

# transforms.jl
export map2alm, alm2map

# projections.jl
export mollweide

# io.jl
export writehealpix, readhealpix

using StaticArrays
using FITSIO.Libcfitsio
using MacroTools # needed for @lm

if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("LibHealpix is not properly installed. Please run Pkg.build(\"LibHealpix\")")
end

struct LibHealpixException <: Exception
    message :: String
end

err(message) = throw(LibHealpixException(message))

function Base.show(io::IO, exception::LibHealpixException)
    print(io, "LibHealpixException: ", exception.message)
end

include("pixel.jl")
include("rings.jl")
include("map.jl")
include("alm.jl")
include("transforms.jl")
include("projections.jl")
include("io.jl")

end

