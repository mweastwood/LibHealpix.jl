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

export ang2pix_nest, ang2pix_ring
export pix2ang_nest, pix2ang_ring
export nest2ring, ring2nest
export nside2npix, npix2nside
export vec2pix_nest, vec2pix_ring
export pix2vec_nest, pix2vec_ring
export ang2vec, vec2ang

const libchealpix = "libchealpix"

const NULL = -1.6375e30 # Defined by the Healpix standard (?)

type HealpixMap{T<:FloatingPoint,ring}
    signal::Vector{T}
    nside::Int
    coordsys::ASCIIString
end

include("pixel.jl")

end

