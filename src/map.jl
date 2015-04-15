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

type HEALPixMap{T<:FloatingPoint,nside,ring}
    map::Vector{T}
    function HEALPixMap(vec)
        if npix2nside(length(vec)) != nside
            error("HEALPixMap with nside=$nside must have length $(nside2npix(nside)).")
        end
        new(vec)
    end
end

HEALPixMap{T}(nside::Int,ring::Bool,vec::Vector{T}) = HEALPixMap{T,nside,ring}(vec)

function HEALPixMap{T}(vec::Vector{T};ring::Bool=true)
    nside = npix2nside(length(vec))
    if nside == -1
        error("The supplied vector does not have a valid length.")
    end
    HEALPixMap(nside,ring,vec)
end

length(map::HEALPixMap) = length(map.map)
getindex(map::HEALPixMap,i) = map.map[i]
setindex!(map::HEALPixMap,x,i) = map.map[i] = x

nside{T,_nside,ring}(map::HEALPixMap{T,_nside,ring}) = _nside
npix(map::HEALPixMap) = nside2npix(nside(map))
nring(map::HEALPixMap) = 4nside(map)-1

isring{T,nside,ring}(map::HEALPixMap{T,nside,ring}) = ring
isnest{T,nside,ring}(map::HEALPixMap{T,nside,ring}) = !ring

getindex{T,nside}(map::HEALPixMap{T,nside,true},θ,ϕ) = getindex(map,ang2pix_ring(nside,θ,ϕ))
getindex{T,nside}(map::HEALPixMap{T,nside,false},θ,ϕ) = getindex(map,ang2pix_nest(nside,θ,ϕ))

