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

"""
    mollweide(map::HealpixMap)

Create an image of the map through the use of a Mollweide projection.
The image will be zero in the region outside of the projection area.
"""
function mollweide(map::HealpixMap)
    N = 2nring(map)
    img = zeros(2N,N)
    δ = 2/N
    x = linspace(-2+δ/2,2-δ/2,2N)
    y = linspace(-1+δ/2,1-δ/2,1N)
    for j = 1:N
        sinΩ = y[j]
        cosΩ = sqrt(1-sinΩ^2)
        Ω = asin(sinΩ)
        for i = 1:2N
            lat  = asin((2Ω + 2sinΩ*cosΩ)/π)
            long = π * x[i] / (2cosΩ)
            -π < long < π || continue
            θ = π/2 - lat
            ϕ = 2π - mod2pi(long + 2π)
            pix = ang2pix(map, θ, ϕ)
            img[i,j] = map[pix]
        end
    end
    img'
end

