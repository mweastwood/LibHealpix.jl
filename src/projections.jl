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

"""
    mollweide(map, size=(512, 1024))

Create a Mollweide projected image of the given Healpix map.

!!! note
    The image values will be set to zero outside of the projection area.

**Arguments:**

- `map` - the input Healpix map
- `size` - the size of the output image

**Usage:**

```jldoctest
julia> map = RingHealpixMap(Int, 1)
       map[:] = 1
       mollweide(map, (10, 20))
10×20 Array{Int64,2}:
 0  0  0  0  0  0  1  1  1  1  1  1  1  1  0  0  0  0  0  0
 0  0  0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0  0  0
 0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0
 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1
 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1
 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1
 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1
 0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0
 0  0  0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0  0  0
 0  0  0  0  0  0  1  1  1  1  1  1  1  1  0  0  0  0  0  0
```
"""
function mollweide(map::HealpixMap, size=(512, 1024))
    img = zeros(eltype(map), reverse(size))
    δx = 4/size[2]
    δy = 2/size[1]
    x = linspace(-2+δx/2, 2-δx/2, size[2])
    y = linspace(-1+δy/2, 1-δy/2, size[1])
    for j = 1:size[1]
        sinΩ = -y[j]
        cosΩ = sqrt(1-sinΩ^2)
        Ω = asin(sinΩ)
        for i = 1:size[2]
            lat  = asin((2Ω + 2sinΩ*cosΩ)/π)
            long = π * x[i] / (2cosΩ)
            if -π < long < π
                θ = π/2 - lat
                ϕ = 2π - mod2pi(long + 2π)
                pix = ang2pix(map, θ, ϕ)
                img[i, j] = map[pix]
            else
                img[i, j] = 0
            end
        end
    end
    img.'
end

