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

@testset "transforms.jl" begin
    @testset "alm2map / map2alm" begin
        for T in (Float32, Float64)
            lmax = 25
            mmax = 25
            nside = 16
            map = RingHealpixMap(rand(T, nside2npix(nside)))
            alm = map2alm(map, lmax, mmax)
            @test alm.lmax === lmax
            @test alm.mmax === mmax
            @test eltype(alm) == Complex{T}

            # Note that the algorithm used by map2alm isn't particularly great with no iterations
            # (hence the rough tolerance)
            map1 = alm2map(alm, nside)
            map2 = alm2map(map2alm(map1, lmax, mmax), nside)
            @test norm(map1 - map2) / norm(map1) < 1e-2
            @test map1.nside === nside
            @test eltype(map1) == T

            # With more iterations we should be able to do better
            map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 1), nside)
            @test norm(map1 - map2) / norm(map1) < 1e-3
            map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 2), nside)
            @test norm(map1 - map2) / norm(map1) < 1e-4
            map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 3), nside)
            @test norm(map1 - map2) / norm(map1) < 1e-5
            if T == Float64
                map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 10), nside)
                @test norm(map1 - map2) / norm(map1) < 1e-12
            end

            @inferred alm2map(alm, nside)
            @inferred map2alm(map, lmax, mmax)
        end
    end
end

