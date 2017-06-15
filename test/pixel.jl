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

@testset "pixel.jl" begin
    @testset "verify_angles" begin
        @test LibHealpix.verify_angles(0, 0) === (0.0, 0.0)
        @test LibHealpix.verify_angles(π, 0) === (1π, 0.0)
        @test LibHealpix.verify_angles(0, π) === (0.0, 1π)
        @test LibHealpix.verify_angles(π, π) === (1π, 1π)
        @test LibHealpix.verify_angles(0, 2π) === (0.0, 2π)
        @test LibHealpix.verify_angles(π, 2π) === (1π, 2π)
        @test LibHealpix.verify_angles(0, 3π) === (0.0, mod2pi(3π))
        @test LibHealpix.verify_angles(π, 3π) === (1π, mod2pi(3π))
        @test_throws LibHealpixException LibHealpix.verify_angles(4, 0)
        @test_throws LibHealpixException LibHealpix.verify_angles(π + 2eps(Float64), 0)
        @inferred LibHealpix.verify_angles(0, 0)
        @inferred LibHealpix.verify_angles(0.0, 0)
        @inferred LibHealpix.verify_angles(0, 0.0)
        @inferred LibHealpix.verify_angles(0.0, 0.0)
        @inferred LibHealpix.verify_angles(π, π)
        @inferred LibHealpix.verify_angles(0.0, π)
        @inferred LibHealpix.verify_angles(π, 0.0)
    end

    @testset "UnitVector" begin
        @test LibHealpix.UnitVector([1, 0, 0]) === LibHealpix.UnitVector(1, 0, 0)
        @test LibHealpix.UnitVector([0, 1, 0]) === LibHealpix.UnitVector(0, 1, 0)
        @test LibHealpix.UnitVector([0, 0, 1]) === LibHealpix.UnitVector(0, 0, 1)
        @test LibHealpix.UnitVector([2, 0, 0]) === LibHealpix.UnitVector(1, 0, 0)
        @test LibHealpix.UnitVector([0, 2, 0]) === LibHealpix.UnitVector(0, 1, 0)
        @test LibHealpix.UnitVector([0, 0, 2]) === LibHealpix.UnitVector(0, 0, 1)
        @test LibHealpix.UnitVector([1, 1, 1]) ===
                LibHealpix.UnitVector(1/sqrt(3), 1/sqrt(3), 1/sqrt(3))
        @test_throws LibHealpixException LibHealpix.UnitVector([1, 0])
        @test_throws LibHealpixException LibHealpix.UnitVector([1, 0, 0, 0])
        @test_throws LibHealpixException LibHealpix.UnitVector([0, 0, 0])
        @inferred LibHealpix.UnitVector([1, 0, 0])
    end

    @testset "nside2npix" begin
        # These test cases come from https://lambda.gsfc.nasa.gov/toolbox/tb_pixelcoords.cfm
        @test nside2npix(1) == 12
        @test nside2npix(2) == 48
        @test nside2npix(4) == 192
        @test nside2npix(8) == 768
        @test nside2npix(16) == 3072
        @test nside2npix(32) == 12288
        @test nside2npix(64) == 49152
        @test nside2npix(128) == 196608
        @test nside2npix(256) == 786432
        @test nside2npix(512) == 3145728
        @test nside2npix(1024) == 12582912
        @inferred nside2npix(64)
    end

    @testset "npix2nside" begin
        # These test cases come from https://lambda.gsfc.nasa.gov/toolbox/tb_pixelcoords.cfm
        @test npix2nside(12) == 1
        @test npix2nside(48) == 2
        @test npix2nside(192) == 4
        @test npix2nside(768) == 8
        @test npix2nside(3072) == 16
        @test npix2nside(12288) == 32
        @test npix2nside(49152) == 64
        @test npix2nside(196608) == 128
        @test npix2nside(786432) == 256
        @test npix2nside(3145728) == 512
        @test npix2nside(12582912) == 1024
        @test_throws LibHealpixException npix2nside(11)
        @test_throws LibHealpixException npix2nside(13)
        @inferred npix2nside(49152)
    end

    @testset "nside2nring" begin
        @test nside2nring(2) == 7
        @test nside2nring(4) == 15
        @test nside2nring(256) == 1023
    end

    @testset "ang2vec" begin
        @test ang2vec(0, 0) === LibHealpix.UnitVector(0, 0, 1)
        @test ang2vec(π, 0) ≈ LibHealpix.UnitVector(0, 0, -1)
        @test ang2vec(π/2, 0) ≈ LibHealpix.UnitVector(1, 0, 0)
        @test ang2vec(π/2, π) ≈ LibHealpix.UnitVector(-1, 0, 0)
        @test ang2vec(π/2, π/2) ≈ LibHealpix.UnitVector(0, 1, 0)
        @test ang2vec(π/2, 3π/2) ≈ LibHealpix.UnitVector(0, -1, 0)
        @test_throws LibHealpixException ang2vec(2π, 0)
        @inferred ang2vec(0, 0)
        @inferred ang2vec(0.0, 0.0)
        @inferred ang2vec(π, π)
    end

    @testset "vec2ang" begin
        ≈(lhs::Tuple, rhs::Tuple) = isapprox(lhs[1], rhs[1]) && isapprox(lhs[2], rhs[2])
        @test vec2ang([+1, 0, 0]) ≈ (π/2, 0)
        @test vec2ang([-1, 0, 0]) ≈ (π/2, π)
        @test vec2ang([0, +1, 0]) ≈ (π/2, π/2)
        @test vec2ang([0, -1, 0]) ≈ (π/2, 3π/2)
        @test vec2ang([0, 0, +1]) ≈ (0, 0)
        @test vec2ang([0, 0, -1]) ≈ (π, 0)
        @test_throws LibHealpixException vec2ang([1, 0, 0, 0])
        @inferred vec2ang([1, 0, 0])
        @inferred vec2ang([1.0, 0.0, 0.0])
    end

    @testset "nest2ring / ring2nest" begin
        for nside in (32, 128, 512)
            npix = nside2npix(nside)
            for pixel in (1, 123, 4000, 10000, npix)
                @test nest2ring(nside, ring2nest(nside, pixel)) == pixel
            end
        end
        @inferred nest2ring(128, 1)
        @inferred ring2nest(128, 1)
    end

    @testset "pix2ang / ang2pix" begin
        for nside in (32, 128, 512)
            npix = nside2npix(nside)
            for pixel in (1, 123, 4000, 10000, npix)
                θ, ϕ = pix2ang_nest(nside, pixel)
                @test ang2pix_nest(nside, θ, ϕ) == pixel
                θ, ϕ = pix2ang_ring(nside, pixel)
                @test ang2pix_ring(nside, θ, ϕ) == pixel
            end
        end
        @inferred pix2ang_nest(128, 1)
        @inferred pix2ang_ring(128, 1)
        @inferred ang2pix_nest(128, 0.0, 0.0)
        @inferred ang2pix_ring(128, 0.0, 0.0)
    end

    @testset "pix2vec / vec2pix" begin
        for nside in (32, 128, 512)
            npix = nside2npix(nside)
            for pixel in (1, 123, 4000, 10000, npix)
                vec = pix2vec_nest(nside, pixel)
                @test vec2pix_nest(nside, vec) == pixel
                vec = pix2vec_ring(nside, pixel)
                @test vec2pix_ring(nside, vec) == pixel
            end
        end
        @inferred pix2vec_nest(128, 1)
        @inferred pix2vec_ring(128, 1)
        @inferred vec2pix_nest(128, [1.0, 0.0, 0.0])
        @inferred vec2pix_ring(128, [1.0, 0.0, 0.0])
    end
end

