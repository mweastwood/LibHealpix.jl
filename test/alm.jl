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
        coefficients = rand(Complex128, LibHealpix.ncoeff(lmax, mmax))
        zero_coefficients = zeros(Complex128, LibHealpix.ncoeff(lmax, mmax))

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
        coefficients = rand(Complex128, LibHealpix.ncoeff(lmax, mmax))
        alm = Alm(lmax, mmax, coefficients)
        @test length(alm) == length(coefficients)

        @test alm[1] === coefficients[1]
        @test alm[end] === coefficients[end]
        @test alm[4:5:end] == coefficients[4:5:end]
        @test alm[abs.(alm) .> 0.5] == coefficients[abs.(coefficients) .> 0.5]

        alm[1] = 2
        @test alm[1] == 2
        alm[end] = 2
        @test alm[end] == 2
        alm[4:5:end] = 2
        @test all(alm[4:5:end] .== 2)
        alm[abs.(alm) .> 0.5] = 2
        @test all(alm[abs.(alm) .> 0.5] .== 2)

        @test LibHealpix.lm2index(lmax, 0, 0) === 1
        @test LibHealpix.lm2index(lmax, 1, 0) === 2
        @test LibHealpix.lm2index(lmax, 1, 1) === lmax + 2
        @test LibHealpix.lm2index(lmax, 2, 1) === lmax + 3
        @test LibHealpix.lm2index(lmax, lmax, mmax) === LibHealpix.ncoeff(lmax, mmax)
        @test_throws LibHealpixException LibHealpix.lm2index(lmax, 0, -1)
        @test_throws LibHealpixException LibHealpix.lm2index(lmax, 0, 1)
        @test_throws LibHealpixException LibHealpix.lm2index(lmax, lmax+1, 0)

        lmax = 3
        mmax = 2
        coefficients = [0, 1, 2, 3, 2, 3, 4, 4, 5]
        alm = Alm(lmax, mmax, coefficients)
        for m = 0:mmax, l = m:lmax
            @test @lm(alm[l, m]) == m + l
            @lm alm[l, m] = m * l
            @test @lm(alm[l, m]) == m * l
        end

        lmax = 3
        mmax = 2
        coefficients = [0, 1, 2, 3, 2, 3, 4, 4, 5]
        alm = Alm(lmax, mmax, coefficients)
        @test @lm(alm[0, :]) == [0]
        @test @lm(alm[1, :]) == [1, 2]
        @test @lm(alm[2, :]) == [2, 3, 4]
        @test @lm(alm[3, :]) == [3, 4, 5]
        @test @lm(alm[:, 0]) == [0, 1, 2, 3]
        @test @lm(alm[:, 1]) == [2, 3, 4]
        @test @lm(alm[:, 2]) == [4, 5]
        @test @lm(alm[:, :]) == alm[:] == coefficients

        coefficients = rand(Int, 9)
        @lm alm[:, :] = coefficients
        @test @lm(alm[:, :]) == alm[:] == coefficients

        coefficients = rand(Int, 2)
        @lm alm[1, :] = coefficients
        @test @lm(alm[1, :]) == coefficients

        coefficients = rand(Int, 3)
        @lm alm[:, 1] = coefficients
        @test @lm(alm[:, 1]) == coefficients
    end

    @testset "iteration" begin
        lmax = 23
        mmax = 11
        alm = Alm(Int, lmax, mmax)

        expected_l = [l for m = 0:mmax for l = m:lmax]
        expected_m = [m for m = 0:mmax for l = m:lmax]
        @test [l for (l, m) in lm(lmax, mmax)] == expected_l
        @test [m for (l, m) in lm(lmax, mmax)] == expected_m
        @test [l for (l, m) in lm(alm)] == expected_l
        @test [m for (l, m) in lm(alm)] == expected_m
        @test length(lm(lmax, mmax)) == length(lm(alm)) == length(expected_l)
        @inferred collect(lm(lmax, mmax))
        @inferred collect(lm(alm))
    end

    @testset "arithmetic" begin
        lmax = 23
        mmax = 11
        alm1 = Alm(Complex128, lmax, mmax)
        alm2 = Alm(Complex128, lmax, mmax)
        rand!(alm1.coefficients)
        rand!(alm2.coefficients)

        @test alm1 + alm2 == Alm(lmax, mmax, alm1.coefficients + alm2.coefficients)
        @test alm1 - alm2 == Alm(lmax, mmax, alm1.coefficients - alm2.coefficients)
        @test alm1 .* alm2 == Alm(lmax, mmax, alm1.coefficients .* alm2.coefficients)
        @test alm1 ./ alm2 == Alm(lmax, mmax, alm1.coefficients ./ alm2.coefficients)

        a = rand(Complex128)
        @test alm1 + a == Alm(lmax, mmax, alm1.coefficients + a)
        @test alm1 - a == Alm(lmax, mmax, alm1.coefficients - a)
        @test alm1 * a == Alm(lmax, mmax, alm1.coefficients * a)
        @test alm1 / a == Alm(lmax, mmax, alm1.coefficients / a)
        @test a + alm1 == Alm(lmax, mmax, a + alm1.coefficients)
        @test a - alm1 == Alm(lmax, mmax, a - alm1.coefficients)
        @test a * alm1 == Alm(lmax, mmax, a * alm1.coefficients)
        @test a ./ alm1 == Alm(lmax, mmax, a ./ alm1.coefficients)

        @test mean([alm1, alm2]) == (alm1 + alm2)/2
    end

    @testset "custom broadcasting" begin
        lmax = 23
        mmax = 11
        alm = Alm(Complex128, lmax, mmax)
        rand!(alm.coefficients)
        coefficients = copy(alm.coefficients)

        f(a, b, c) = a + b * c

        @test sin.(alm) == Alm(lmax, mmax, sin.(coefficients))
        @test (abs.(alm) .< 0.5) == Alm(lmax, mmax, abs.(coefficients) .< 0.5)
        @test f.(1, 1, alm) == Alm(lmax, mmax, f.(1, 1, coefficients))
        @test f.(1, alm, alm) == Alm(lmax, mmax, f.(1, coefficients, coefficients))
        @test f.(alm, alm, alm) == Alm(lmax, mmax, f.(coefficients, coefficients, coefficients))
        @inferred broadcast(f, alm, alm, alm)

        alm1 = Alm(Complex128, lmax, mmax)
        rand!(alm1.coefficients)
        alm2 = deepcopy(alm1)
        alm1 .+= 1
        @test alm1 == alm2 .+ 1
        alm1 .= sin.(alm1)
        @test alm1 == sin.(alm2 .+ 1)
    end
end

