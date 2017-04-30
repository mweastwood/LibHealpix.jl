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

function map2alm(map::HealpixMap, lmax::Int, mmax::Int; iterations::Int=0)
    map.order == ring || error("The input HealpixMap must have ring ordering.")
    coefficients = zeros(Complex128, ncoeff(lmax, mmax))
    ccall(("map2alm", libhealpixwrapper), Void,
          (Cint, Cint, Ptr{Float64}, Cint, Cint, Cint, Ptr{Complex128}),
          map.nside, map.order, map.pixels, lmax, mmax, iterations, coefficients)
    Alm(lmax, mmax, coefficients)
end

function alm2map(alm::Alm, nside::Int)
    pixels = zeros(Float64, nside2npix(nside))
    ccall(("alm2map", libhealpixwrapper), Void,
          (Cint, Cint, Ptr{Complex128}, Cint, Ptr{Float64}),
          alm.lmax, alm.mmax, alm.coefficients, nside, pixels)
    HealpixMap(nside, ring, pixels)
end

