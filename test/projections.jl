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

@testset "projections.jl" begin
    @testset "mollweide" begin
        nside = 16
        for Map in (RingHealpixMap, NestHealpixMap)
            map = Map(Float64, nside)
            map[:] = 1
            img = mollweide(map)
            @test size(img) == (512, 1024)

            # Verify that the image is unity inside and zero outside
            N = 512
            expected_img = zeros(N, 2N)
            x = linspace(-2+1/N,2-1/N,2N)
            y = linspace(-1+1/N,1-1/N,1N)
            for j = 1:N, i = 1:2N
                if x[i]^2 + 4y[j]^2 > 4
                    expected_img[j, i] = 0
                else
                    expected_img[j, i] = 1
                end
            end
            @test img == expected_img
        end
    end
end

