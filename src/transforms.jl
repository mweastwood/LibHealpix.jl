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

for (T, suffix) in ((Float32, "_float"), (Float64, "_double"))
    @eval function map2alm(map::RingHealpixMap{$T}, lmax::Int, mmax::Int; iterations::Int=0)
        coefficients = zeros(Complex{$T}, ncoeff(lmax, mmax))
        ccall(("map2alm"*suffix, libhealpixwrapper), Void,
              (Cint, Cint, Ptr{$T}, Cint, Cint, Cint, Ptr{Complex{$T}}),
              map.nside, map.order, map.pixels, lmax, mmax, iterations, coefficients)
        Alm(lmax, mmax, coefficients)
    end

    @eval function alm2map(alm::Alm{Complex{$T}}, nside::Int)
        pixels = zeros($T, nside2npix(nside))
        ccall(("alm2map"*suffix, libhealpixwrapper), Void,
              (Cint, Cint, Ptr{Complex{$T}}, Cint, Ptr{$T}),
              alm.lmax, alm.mmax, alm.coefficients, nside, pixels)
        RingHealpixMap(nside, pixels)
    end
end

