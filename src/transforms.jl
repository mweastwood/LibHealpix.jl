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

#function map2alm(map::HEALPixMap;lmax::Int=100,mmax::Int=100)
#end

function alm2map(alm::Alm;nside::Int=32)
    npix = nside2npix(nside)
    alm_cxx = alm |> to_cxx
    map_cxx = HEALPixMap(zeros(Cdouble,npix)) |> to_cxx
    ccall(("alm2map",libhealpixwrapper),Void,
          (Ptr{Void},Ptr{Void}),
          pointer(alm_cxx),pointer(map_cxx))
    map_cxx |> to_julia
end

