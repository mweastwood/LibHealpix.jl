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

@testset "rings.jl" begin
    @testset "ring_above" begin
        z = cos(0.8410686705679303)
        @test LibHealpix.ring_above(1, z) === 1
        @test LibHealpix.ring_above(1, nextfloat(z)) === 0

        z = cos(1.5707963267948966)
        @test LibHealpix.ring_above(1, z) === 2
        @test_broken LibHealpix.ring_above(1, nextfloat(z)) === 1

        z = cos(2.300523983021863)
        @test LibHealpix.ring_above(1, z) === 3
        @test LibHealpix.ring_above(1, nextfloat(z)) === 2

        @test LibHealpix.ring_above(1, +1) === 0
        @test LibHealpix.ring_above(1,  0) === 2
        @test LibHealpix.ring_above(1, -1) === 3
    end

    @testset "ring_info2" begin
        nside = 4
        npix  = nside2npix( nside)
        nring = nside2nring(nside)
        for ring = 1:nring
            startpix, ringpix, θ, shifted = LibHealpix.ring_info2(nside, ring)
            stoppix = startpix + ringpix - 1
            @test startpix ≥ 1
            @test stoppix ≤ npix
            start_θ, start_ϕ = pix2ang_ring(nside, startpix)
            stop_θ, stop_ϕ = pix2ang_ring(nside, stoppix)
            @test isapprox(start_θ, θ, atol=1e-15)
            @test isapprox(stop_θ, θ, atol=1e-15)
            @test start_ϕ < stop_ϕ
            if shifted
                @test start_ϕ == π/ringpix
            else
                @test start_ϕ == 0
            end
        end
    end
end

