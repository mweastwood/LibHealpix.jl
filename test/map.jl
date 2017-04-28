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

@testset "map.jl" begin
    @testset "constructors" begin
        nside = 4
        npix = LibHealpix.nside2npix(nside)
        pixels = randn(npix)
        zero_pixels = zeros(npix)

        for order in (ring, nest)
            map = HealpixMap(Float64, nside, order)
            @test map.nside === nside
            @test map.order === order
            @test map.pixels == zero_pixels
            @inferred HealpixMap(Float64, nside, order)

            map = HealpixMap(nside, order, pixels)
            @test map.nside === nside
            @test map.order === order
            @test map.pixels == pixels
            @inferred HealpixMap(nside, order, pixels)

            map = HealpixMap(order, pixels)
            @test map.nside === nside
            @test map.order === order
            @test map.pixels == pixels
            @inferred HealpixMap(order, pixels)

            @test_throws ArgumentError HealpixMap(nside, order, randn(npix+1))
        end
    end

    @testset "indexing" begin
        nside = 4
        npix = LibHealpix.nside2npix(nside)
        pixels = randn(npix)
        map = HealpixMap(nside, ring, copy(pixels))

        @test map[1] === pixels[1]
        @test map[end] === pixels[end]
        @test map[4:5:end] == pixels[4:5:end]
        @test map[map .> 0] == pixels[pixels .> 0]

        map[1] = 2
        @test map[1] == 2
        map[end] = 2
        @test map[end] == 2
        map[4:5:end] = 2
        @test all(map[4:5:end] .== 2)
        map[map .> 0] = 2
        @test all(map[map .> 0] .== 2)
    end

    @testset "arithmetic" begin
        nside = 4
        npix = LibHealpix.nside2npix(nside)
        a = randn()
        map1 = HealpixMap( nside, ring, randn( npix))
        map2 = HealpixMap( nside, ring, randn( npix))
        map3 = HealpixMap(2nside, ring, randn(4npix))
        map4 = HealpixMap( nside, nest, randn( npix))

        @test map1 + map2 == HealpixMap(nside, ring, map1.pixels + map2.pixels)
        @test map1 - map2 == HealpixMap(nside, ring, map1.pixels - map2.pixels)
        @test map1 .* map2 == HealpixMap(nside, ring, map1.pixels .* map2.pixels)
        @test map1 ./ map2 == HealpixMap(nside, ring, map1.pixels ./ map2.pixels)
        @test_throws DimensionMismatch map1 * map2
        @test_throws DimensionMismatch map1 / map2
        @inferred map1 + map2
        @inferred map1 - map2

        @test_throws DimensionMismatch map1 + map3
        @test_throws DimensionMismatch map1 - map3
        @test_throws ArgumentError map1 + map4
        @test_throws ArgumentError map1 - map4

        @test map1 + a == HealpixMap(nside, ring, map1.pixels + a)
        @test map1 - a == HealpixMap(nside, ring, map1.pixels - a)
        @test map1 * a == HealpixMap(nside, ring, map1.pixels * a)
        @test map1 / a == HealpixMap(nside, ring, map1.pixels / a)
        @test a + map1 == HealpixMap(nside, ring, a + map1.pixels)
        @test a - map1 == HealpixMap(nside, ring, a - map1.pixels)
        @test a * map1 == HealpixMap(nside, ring, a * map1.pixels)
        @test a ./ map1 == HealpixMap(nside, ring, a ./ map1.pixels)
        @inferred map1 + a
        @inferred map1 - a
        @inferred map1 * a
        @inferred map1 / a
        @inferred a + map1
        @inferred a - map1
        @inferred a * map1
        @inferred a ./ map1

        @test mean([map1, map2]) == (map1 + map2)/2
    end

    @testset "FITS I/O" begin
        nside = 16
        filename = tempname()*".fits"
        map = HealpixMap(Float32, nside, ring)
        for i = 1:length(map)
            map[i] = rand()
        end
        writehealpix(filename, map)
        newmap = readhealpix(filename)
        @test map == newmap
        @test_throws ErrorException writehealpix(filename, map)
        @test writehealpix(filename, map, replace=true) == map

        filename = tempname()*".fits"
        map = HealpixMap(Float32, nside, nest)
        for i = 1:length(map)
            map[i] = rand()
        end
        writehealpix(filename, map)
        newmap = readhealpix(filename)
        @test map == newmap
        @test_throws ErrorException writehealpix(filename, map)
        @test writehealpix(filename, map, replace=true) == map
    end

    #let
    #    for order in (LibHealpix.ring, LibHealpix.nest)
    #        map = HealpixMap(Float64, 512, order)
    #        rand!(map.pixels)
    #        map′ = LibHealpix.to_julia(LibHealpix.to_cxx(map))
    #        @test map == map′
    #    end
    #end

    #let
    #    map = HealpixMap(Float64, 4)
    #    map[1] = rand()
    #    map[2] = rand()
    #    map[3] = rand()
    #    map[4] = rand()
    #    expected = (map[1] + map[2] + map[3] + map[4])/4
    #    @test LibHealpix.interpolate(map, 0.0, 0.0) == expected
    #    @test LibHealpix.interpolate(map, [0.0, 0.0], [0.0, 0.0]) == [expected, expected]
    #end

end

