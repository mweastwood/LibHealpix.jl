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

@testset "mollweide.jl" begin
    let nside = 5
        map = HealpixMap(Float64, nside, ring)
        for i = 1:length(map)
            map[i] = 1.0
        end
        img = mollweide(map)'
        N = size(img,2)
        expected_img = zeros(2N,1N)
        # Verify that the image is unity inside and zero outside
        x = linspace(-2+1/N,2-1/N,2N)
        y = linspace(-1+1/N,1-1/N,1N)
        for j = 1:N, i = 1:2N
            if x[i]^2 + 4y[j]^2 > 4
                expected_img[i,j] = 0
            else
                expected_img[i,j] = 1
            end
        end
        @test img == expected_img
    end
end

