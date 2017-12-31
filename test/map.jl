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
        for Map in (RingHealpixMap, NestHealpixMap)
            nside = 4
            npix = nside2npix(nside)
            pixels = randn(npix)
            zero_pixels = zeros(npix)

            map = @inferred Map(Float64, nside)
            @test map != map.pixels
            @test map.nside === nside
            @test map.pixels == zero_pixels
            @test eltype(map) == Float64

            map = @inferred Map(pixels)
            @test map != map.pixels
            @test map.nside === nside
            @test map.pixels == pixels
            @test eltype(map) == Float64

            @test_throws LibHealpixException Map(randn(npix+1))
        end
    end

    @testset "isring/isnest" begin
        map = RingHealpixMap(Float64, 4)
        @test isring(map)
        @test !isnest(map)

        map = NestHealpixMap(Float64, 4)
        @test !isring(map)
        @test isnest(map)
    end

    @testset "indexing" begin
        for Map in (RingHealpixMap, NestHealpixMap)
            nside = 4
            npix = nside2npix(nside)
            pixels = randn(npix)
            map = Map(copy(pixels))

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
    end

    @testset "arithmetic" begin
        for Map in (RingHealpixMap, NestHealpixMap)
            nside = 4
            npix = nside2npix(nside)
            a = randn()
            map1 = Map(randn( npix))
            map2 = Map(randn( npix))
            map3 = Map(randn(4npix))

            @test map1 + map2 == Map(nside, map1.pixels + map2.pixels)
            @test map1 - map2 == Map(nside, map1.pixels - map2.pixels)
            @test map1 .* map2 == Map(nside, map1.pixels .* map2.pixels)
            @test map1 ./ map2 == Map(nside, map1.pixels ./ map2.pixels)
            @inferred map1 + map2
            @inferred map1 - map2

            @test_throws DimensionMismatch map1 * map2
            @test_throws DimensionMismatch map1 / map2
            @test_throws DimensionMismatch map1 + map3
            @test_throws DimensionMismatch map1 - map3

            @test map1 + a == Map(nside, map1.pixels + a)
            @test map1 - a == Map(nside, map1.pixels - a)
            @test map1 * a == Map(nside, map1.pixels * a)
            @test map1 / a == Map(nside, map1.pixels / a)
            @test a + map1 == Map(nside, a + map1.pixels)
            @test a - map1 == Map(nside, a - map1.pixels)
            @test a * map1 == Map(nside, a * map1.pixels)
            @test a ./ map1 == Map(nside, a ./ map1.pixels)
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

        nside = 4
        npix = nside2npix(nside)
        map1 = RingHealpixMap(randn(npix))
        map2 = NestHealpixMap(randn(npix))
        @test_throws LibHealpixException map1 + map2
        @test_throws LibHealpixException map1 - map2
    end

    @testset "ang2pix / pix2ang / vec2pix / pix2vec" begin
        for nside in (32, 128, 512)
            map = RingHealpixMap(Float64, nside)
            @test ang2pix(map, 0, 0) === ang2pix_ring(nside, 0, 0)
            @test ang2pix(map, 1, 1) === ang2pix_ring(nside, 1, 1)
            @test pix2ang(map, 1) === pix2ang_ring(nside, 1)
            @test pix2ang(map, 100) === pix2ang_ring(nside, 100)
            @test vec2pix(map, [0, 0, 1]) === vec2pix_ring(nside, [0, 0, 1])
            @test vec2pix(map, [0, 1, 0]) === vec2pix_ring(nside, [0, 1, 0])
            @test pix2vec(map, 1) === pix2vec_ring(nside, 1)
            @test pix2vec(map, 100) === pix2vec_ring(nside, 100)

            map = NestHealpixMap(Float64, nside)
            @test ang2pix(map, 0, 0) === ang2pix_nest(nside, 0, 0)
            @test ang2pix(map, 1, 1) === ang2pix_nest(nside, 1, 1)
            @test pix2ang(map, 1) === pix2ang_nest(nside, 1)
            @test pix2ang(map, 100) === pix2ang_nest(nside, 100)
            @test vec2pix(map, [0, 0, 1]) === vec2pix_nest(nside, [0, 0, 1])
            @test vec2pix(map, [0, 1, 0]) === vec2pix_nest(nside, [0, 1, 0])
            @test pix2vec(map, 1) === pix2vec_nest(nside, 1)
            @test pix2vec(map, 100) === pix2vec_nest(nside, 100)
        end
    end

    @testset "verify_map_consistency" begin
        # test that this correctly identifies when the user has shot themselves in the foot
        for Map in (RingHealpixMap, NestHealpixMap)
            map = Map(Float64, 4)
            resize!(map.pixels, 10)
            @test_throws LibHealpixException LibHealpix.verify_map_consistency(map)
        end
    end

    @testset "custom broadcasting" begin
        for Map in (RingHealpixMap, NestHealpixMap)
            nside = 4
            npix = nside2npix(nside)
            pixels = randn(npix)
            map = Map(nside, pixels)

            f(a, b, c) = a + b * c

            @test sin.(map) == Map(nside, sin.(pixels))
            @test (map .< 0) == Map(nside, pixels .< 0)
            @test f.(1, 1, map) == Map(nside, f.(1, 1, pixels))
            @test f.(1, map, map) == Map(nside, f.(1, pixels, pixels))
            @test f.(map, map, map) == Map(nside, f.(pixels, pixels, pixels))
            @inferred broadcast(f, map, map, map)

            map1 = Map(nside, randn(npix))
            map2 = deepcopy(map1)
            map1 .+= 1
            @test map1 == map2 .+ 1
            map1 .= sin.(map1)
            @test map1 == sin.(map2 .+ 1)
        end
    end

    @testset "interpolate" begin
        add2pi(θ, ϕ) = (θ, ϕ+2π)
        sub2pi(θ, ϕ) = (θ, ϕ-2π)
        for T in (Float32, Float64), M in (RingHealpixMap, NestHealpixMap)
            map = M(T, 2)
            map[:] = rand(T, length(map))
            if LibHealpix.ordering(map) == LibHealpix.ring
                expected = (map[1] + map[2] + map[3] + map[4])/4
            else
                expected = (map[4] + map[8] + map[12] + map[16])/4
            end
            @test isapprox(LibHealpix.interpolate(map, 0, 0), T(expected), atol=2e-15)

            interpolation = [LibHealpix.interpolate(map, pix2ang(map, idx)...)
                                for idx = 1:length(map)]
            @test all(isapprox.(map, interpolation, atol=2e-15))

            interpolation = [LibHealpix.interpolate(map, add2pi(pix2ang(map, idx)...)...)
                                for idx = 1:length(map)]
            @test all(isapprox.(map, interpolation, atol=2e-15))

            interpolation = [LibHealpix.interpolate(map, sub2pi(pix2ang(map, idx)...)...)
                                for idx = 1:length(map)]
            @test all(isapprox.(map, interpolation, atol=2e-15))

            # Check the interpolation procedure against the C++ implementation
            # (note the C++ implementation seems to have a bug near 2π, so we don't test exactly
            # there, but that case should be covered above)
            for θ in (0.0, 1.0, π/2, 2.0, π), ϕ in (0.0, 1.0, π, 4.0, 2π-0.001)
                @test isapprox(LibHealpix.interpolate(map, θ, ϕ),
                               LibHealpix.interpolate_cxx(map, θ, ϕ), atol=2e-15)
            end
        end
    end

    @testset "query_disc" begin
        function check_query(nside, ordering, θ, ϕ, radius, pixel)
            vec = ang2vec(θ, ϕ)
            if ordering == LibHealpix.ring
                vec′ = pix2vec_ring(nside, pixel)
            else
                vec′ = pix2vec_nest(nside, pixel)
            end
            distance = acos(clamp(dot(vec, vec′), -1, 1))
            distance < radius
        end

        nside = 256
        for (ordering, map) in ((LibHealpix.ring, RingHealpixMap(Float64, nside)),
                                (LibHealpix.nest, NestHealpixMap(Float64, nside)))
            for (θ, ϕ) in ((0, 0), (π, 2π), (π/2, π), (0.1, 0.3), (2.0, 3.0))
                radius = deg2rad(1)
                inclusive_pixels = query_disc(nside, ordering, θ, ϕ, radius)
                exclusive_pixels = query_disc(nside, ordering, θ, ϕ, radius, inclusive=false)
                @test length(inclusive_pixels) > length(exclusive_pixels)
                @test inclusive_pixels == query_disc(map, θ, ϕ, radius)
                @test exclusive_pixels == query_disc(map, θ, ϕ, radius, inclusive=false)
                @test all(check_query.(nside, ordering, θ, ϕ, radius, exclusive_pixels))
            end
        end
    end
end

