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
        @test_throws DomainError LibHealpix.verify_angles(4, 0)
        @test_throws DomainError LibHealpix.verify_angles(π + 2eps(Float64), 0)
        @inferred LibHealpix.verify_angles(0, 0)
        @inferred LibHealpix.verify_angles(0.0, 0)
        @inferred LibHealpix.verify_angles(0, 0.0)
        @inferred LibHealpix.verify_angles(0.0, 0.0)
        @inferred LibHealpix.verify_angles(π, π)
        @inferred LibHealpix.verify_angles(0.0, π)
        @inferred LibHealpix.verify_angles(π, 0.0)
    end

    @testset "verify_unit_vector" begin
        @test LibHealpix.verify_unit_vector([1, 0, 0]) === SVector(1.0, 0.0, 0.0)
        @test LibHealpix.verify_unit_vector([0, 1, 0]) === SVector(0.0, 1.0, 0.0)
        @test LibHealpix.verify_unit_vector([0, 0, 1]) === SVector(0.0, 0.0, 1.0)
        @test LibHealpix.verify_unit_vector([2, 0, 0]) === SVector(1.0, 0.0, 0.0)
        @test LibHealpix.verify_unit_vector([0, 2, 0]) === SVector(0.0, 1.0, 0.0)
        @test LibHealpix.verify_unit_vector([0, 0, 2]) === SVector(0.0, 0.0, 1.0)
        @test LibHealpix.verify_unit_vector([1, 1, 1]) === SVector(1, 1, 1)/sqrt(3)
        @test LibHealpix.verify_unit_vector(SVector(1, 0, 0)) === SVector(1.0, 0.0, 0.0)
        @test LibHealpix.verify_unit_vector(SVector(0, 1, 0)) === SVector(0.0, 1.0, 0.0)
        @test LibHealpix.verify_unit_vector(SVector(0, 0, 1)) === SVector(0.0, 0.0, 1.0)
        @test LibHealpix.verify_unit_vector(SVector(2, 0, 0)) === SVector(1.0, 0.0, 0.0)
        @test LibHealpix.verify_unit_vector(SVector(0, 2, 0)) === SVector(0.0, 1.0, 0.0)
        @test LibHealpix.verify_unit_vector(SVector(0, 0, 2)) === SVector(0.0, 0.0, 1.0)
        @test LibHealpix.verify_unit_vector(SVector(1, 1, 1)) === SVector(1, 1, 1)/sqrt(3)
        @test_throws ArgumentError LibHealpix.verify_unit_vector([1, 0])
        @test_throws ArgumentError LibHealpix.verify_unit_vector([1, 0, 0, 0])
        @test_throws ArgumentError LibHealpix.verify_unit_vector([0, 0, 0])
        @test_throws ArgumentError LibHealpix.verify_unit_vector(SVector(1, 0))
        @test_throws ArgumentError LibHealpix.verify_unit_vector(SVector(1, 0, 0, 0))
        @test_throws ArgumentError LibHealpix.verify_unit_vector(SVector(0, 0, 0))
        @inferred LibHealpix.verify_unit_vector([1, 0, 0])
        @inferred LibHealpix.verify_unit_vector([1.0, 0.0, 0.0])
        @inferred LibHealpix.verify_unit_vector(SVector(1, 0, 0))
        @inferred LibHealpix.verify_unit_vector(SVector(1.0, 0.0, 0.0))
    end

    @testset "nside2npix" begin
        # These test cases come from https://lambda.gsfc.nasa.gov/toolbox/tb_pixelcoords.cfm
        @test LibHealpix.nside2npix(1) == 12
        @test LibHealpix.nside2npix(2) == 48
        @test LibHealpix.nside2npix(4) == 192
        @test LibHealpix.nside2npix(8) == 768
        @test LibHealpix.nside2npix(16) == 3072
        @test LibHealpix.nside2npix(32) == 12288
        @test LibHealpix.nside2npix(64) == 49152
        @test LibHealpix.nside2npix(128) == 196608
        @test LibHealpix.nside2npix(256) == 786432
        @test LibHealpix.nside2npix(512) == 3145728
        @test LibHealpix.nside2npix(1024) == 12582912
        @inferred LibHealpix.nside2npix(64)
    end

    @testset "npix2nside" begin
        # These test cases come from https://lambda.gsfc.nasa.gov/toolbox/tb_pixelcoords.cfm
        @test LibHealpix.npix2nside(12) == 1
        @test LibHealpix.npix2nside(48) == 2
        @test LibHealpix.npix2nside(192) == 4
        @test LibHealpix.npix2nside(768) == 8
        @test LibHealpix.npix2nside(3072) == 16
        @test LibHealpix.npix2nside(12288) == 32
        @test LibHealpix.npix2nside(49152) == 64
        @test LibHealpix.npix2nside(196608) == 128
        @test LibHealpix.npix2nside(786432) == 256
        @test LibHealpix.npix2nside(3145728) == 512
        @test LibHealpix.npix2nside(12582912) == 1024
        @test_throws ArgumentError LibHealpix.npix2nside(11)
        @test_throws ArgumentError LibHealpix.npix2nside(13)
        @inferred LibHealpix.npix2nside(49152)
    end

    @testset "ang2vec" begin
        @test LibHealpix.ang2vec(0, 0) === SVector(0.0, 0.0, 1.0)
        @test LibHealpix.ang2vec(π, 0) ≈ SVector(0.0, 0.0, -1.0)
        @test LibHealpix.ang2vec(π/2, 0) ≈ SVector(1.0, 0.0, 0.0)
        @test LibHealpix.ang2vec(π/2, π) ≈ SVector(-1.0, 0.0, 0.0)
        @test LibHealpix.ang2vec(π/2, π/2) ≈ SVector(0.0, 1.0, 0.0)
        @test LibHealpix.ang2vec(π/2, 3π/2) ≈ SVector(0.0, -1.0, 0.0)
        @test_throws DomainError LibHealpix.ang2vec(2π, 0)
        @inferred LibHealpix.ang2vec(0, 0)
        @inferred LibHealpix.ang2vec(0.0, 0.0)
        @inferred LibHealpix.ang2vec(π, π)
    end

    @testset "vec2ang" begin
        ≈(lhs::Tuple, rhs::Tuple) = isapprox(lhs[1], rhs[1]) && isapprox(lhs[2], rhs[2])
        @test LibHealpix.vec2ang([+1, 0, 0]) ≈ (π/2, 0)
        @test LibHealpix.vec2ang([-1, 0, 0]) ≈ (π/2, π)
        @test LibHealpix.vec2ang([0, +1, 0]) ≈ (π/2, π/2)
        @test LibHealpix.vec2ang([0, -1, 0]) ≈ (π/2, 3π/2)
        @test LibHealpix.vec2ang([0, 0, +1]) ≈ (0, 0)
        @test LibHealpix.vec2ang([0, 0, -1]) ≈ (π, 0)
        @test_throws ArgumentError LibHealpix.vec2ang([1, 0, 0, 0])
        @inferred LibHealpix.vec2ang([1, 0, 0])
        @inferred LibHealpix.vec2ang([1.0, 0.0, 0.0])
        @inferred LibHealpix.vec2ang(SVector(1, 0, 0))
        @inferred LibHealpix.vec2ang(SVector(1.0, 0.0, 0.0))
    end

    @testset "nest2ring / ring2nest" begin
        for nside in (32, 128, 512)
            npix = LibHealpix.nside2npix(nside)
            for pixel in (1, 123, 4000, 10000, npix)
                @test LibHealpix.nest2ring(nside, LibHealpix.ring2nest(nside, pixel)) == pixel
            end
        end
        @inferred LibHealpix.nest2ring(128, 1)
        @inferred LibHealpix.ring2nest(128, 1)
    end

    @testset "pix2ang / ang2pix" begin
        for nside in (32, 128, 512)
            npix = LibHealpix.nside2npix(nside)
            for pixel in (1, 123, 4000, 10000, npix)
                θ, ϕ = LibHealpix.pix2ang_nest(nside, pixel)
                @test LibHealpix.ang2pix_nest(nside, θ, ϕ) == pixel
                θ, ϕ = LibHealpix.pix2ang_ring(nside, pixel)
                @test LibHealpix.ang2pix_ring(nside, θ, ϕ) == pixel
            end
        end
        @inferred LibHealpix.pix2ang_nest(128, 1)
        @inferred LibHealpix.pix2ang_ring(128, 1)
        @inferred LibHealpix.ang2pix_nest(128, 0.0, 0.0)
        @inferred LibHealpix.ang2pix_ring(128, 0.0, 0.0)
    end

    @testset "pix2vec / vec2pix" begin
        for nside in (32, 128, 512)
            npix = LibHealpix.nside2npix(nside)
            for pixel in (1, 123, 4000, 10000, npix)
                vec = LibHealpix.pix2vec_nest(nside, pixel)
                @test LibHealpix.vec2pix_nest(nside, vec) == pixel
                vec = LibHealpix.pix2vec_ring(nside, pixel)
                @test LibHealpix.vec2pix_ring(nside, vec) == pixel
            end
        end
        @inferred LibHealpix.pix2vec_nest(128, 1)
        @inferred LibHealpix.pix2vec_ring(128, 1)
        @inferred LibHealpix.vec2pix_nest(128, [1.0, 0.0, 0.0])
        @inferred LibHealpix.vec2pix_ring(128, [1.0, 0.0, 0.0])
    end
end

