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

export HealpixMap, ring, nest
export Alm
export writehealpix, readhealpix
export map2alm, alm2map
export mollweide

using StaticArrays

if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("LibHealpix not properly installed. Please run Pkg.build(\"LibHealpix\")")
end

include("pixel.jl")
include("map.jl")
include("alm.jl")
include("transforms.jl")
#include("mollweide.jl")

end

