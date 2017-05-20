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

@testset "alm.jl" begin
    @testset "constructors" begin
        lmax = 5
        mmax = 2
        coefficients = rand(Complex128, ncoeff(lmax, mmax))
        zero_coefficients = zeros(Complex128, ncoeff(lmax, mmax))

        alm = @inferred Alm(lmax, mmax, coefficients)
        @test alm.lmax === lmax
        @test alm.mmax === mmax
        @test alm.coefficients == coefficients

        alm = @inferred Alm(Complex128, lmax, mmax)
        @test alm.lmax === lmax
        @test alm.mmax === mmax
        @test alm.coefficients == zero_coefficients
    end

    @testset "indexing" begin
        lmax = 10
        mmax = 5
        coefficients = rand(Complex128, ncoeff(lmax, mmax))
        alm = Alm(lmax, mmax, coefficients)

        @test alm[1] === coefficients[1]
        @test alm[end] === coefficients[end]
        @test alm[4:5:end] == coefficients[4:5:end]
        @test alm[abs.(alm) .> 0.5] == coefficients[abs.(coefficients) .> 0.5]

        @test LibHealpix.lm2index(lmax, 0, 0) === 1
        @test LibHealpix.lm2index(lmax, 1, 0) === 2
        @test LibHealpix.lm2index(lmax, 1, 1) === lmax + 2
        @test LibHealpix.lm2index(lmax, 2, 1) === lmax + 3
        @test LibHealpix.lm2index(lmax, lmax, mmax) === ncoeff(lmax, mmax)
        @test_throws LibHealpixException LibHealpix.lm2index(lmax, 0, 1)
        @test_throws LibHealpixException LibHealpix.lm2index(lmax, lmax+1, 0)

            #map[1] = 2
            #@test map[1] == 2
            #map[end] = 2
            #@test map[end] == 2
            #map[4:5:end] = 2
            #@test all(map[4:5:end] .== 2)
            #map[map .> 0] = 2
            #@test all(map[map .> 0] .== 2)
    end

    #let
    #    @test_throws DomainError Alm{Complex128,5,10}(zeros(Complex128,5))
    #    @test_throws DimensionMismatch Alm{Complex128,10,5}(zeros(Complex128,5))

    #    lmax′ = 10
    #    mmax′ = 5
    #    N = LibHealpix.num_alm(lmax′,mmax′)

    #    alm = Alm{Complex128,lmax′,mmax′}(zeros(Complex128,N))
    #    @test lmax(alm) == lmax′
    #    @test mmax(alm) == mmax′
    #    @test length(alm) == length(coefficients(alm)) == LibHealpix.num_alm(lmax′,mmax′)

    #    alm = Alm(Complex128,lmax′,mmax′)
    #    @test lmax(alm) == lmax′
    #    @test mmax(alm) == mmax′
    #    @test coefficients(alm) == zeros(Complex128,N)
    #    @test length(alm) == length(coefficients(alm)) == LibHealpix.num_alm(lmax′,mmax′)
    #end

    #let lmax = 10, mmax = 5
    #    N = LibHealpix.num_alm(lmax,mmax)
    #    alm = Alm(Complex128,lmax,mmax)
    #    alm[0,0] = 1
    #    @test alm[0,0] == alm[1] == coefficients(alm)[1] == 1
    #    alm[2] = 2
    #    @test alm[1,0] == alm[2] == coefficients(alm)[2] == 2

    #    a = rand(Complex128)
    #    x = complex(rand(N),rand(N))
    #    y = complex(rand(N),rand(N))
    #    alm1 = Alm(lmax,mmax,x)
    #    alm2 = Alm(lmax,mmax,y)
    #    @test coefficients(alm1+alm2) == x+y
    #    @test coefficients(alm1-alm2) == x-y
    #    @test coefficients(a*alm1) == coefficients(alm1*a) == a*x
    #end

    #let
    #    alm = Alm(Complex128, 5, 5)
    #    rand!(alm.alm)
    #    alm′ = LibHealpix.to_julia(LibHealpix.to_cxx(alm))
    #    @test alm == alm′
    #end
end

