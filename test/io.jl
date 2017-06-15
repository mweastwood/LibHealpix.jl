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

function read_coordsys(filename)
    file = fits_open_file(filename)
    fits_movabs_hdu(file, 2)
    coordsys, _ = fits_read_key_str(file, "COORDSYS")
    fits_close_file(file)
    coordsys
end

@testset "io.jl" begin
    @testset "writehealpix / readhealpix" begin
        for T in (Float32, Float64), Map in (RingHealpixMap, NestHealpixMap)
            nside = 16
            filename = tempname()*".fits"
            map = Map(T, nside)
            for i = 1:length(map)
                map[i] = rand()
            end
            @test writehealpix(filename, map) == map
            @test readhealpix(filename) == map
            @test_throws LibHealpixException writehealpix(filename, map)
            @test writehealpix(filename, map, replace=true) == map
            @test readhealpix(filename) == map
            @test writehealpix(filename, map, coordsys="G", replace=true) == map
            @test read_coordsys(filename) == "G"
            rm(filename)
        end

        for T in (Int32, Int64), Map in (RingHealpixMap, NestHealpixMap)
            nside = 16
            filename = tempname()*".fits"
            map = Map(T, nside)
            @test_throws LibHealpixException writehealpix(filename, map)
        end
    end
end

