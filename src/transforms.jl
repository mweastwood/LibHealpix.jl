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

function map2alm(map::HealpixMap, lmax::Int, mmax::Int; iterations::Int=0)
    isring(map) || error("The input HealpixMap must have ring ordering.")
    nalm = num_alm(lmax, mmax)
    map_cxx = map |> to_cxx
    alm_cxx = Alm(lmax, mmax, zeros(Complex128, nalm)) |> to_cxx
    ccall(("map2alm",libhealpixwrapper), Void, (Ptr{Void}, Ptr{Void}, Cint), map_cxx, alm_cxx, iterations)
    alm_cxx |> to_julia
end

function alm2map(alm::Alm, nside::Int)
    npix = nside2npix(nside)
    alm_cxx = alm |> to_cxx
    map_cxx = HealpixMap(zeros(Cdouble, npix)) |> to_cxx
    ccall(("alm2map", libhealpixwrapper), Void, (Ptr{Void}, Ptr{Void}), alm_cxx, map_cxx)
    map_cxx |> to_julia
end

@deprecate map2alm(map; lmax=100, mmax=100) map2alm(map, lmax, mmax)
@deprecate alm2map(alm; nside=32) alm2map(alm, nside)

