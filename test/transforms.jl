@testset "transforms.jl" begin
    let nside = 16, lmax = 25, mmax = 25
        npix = nside2npix(nside)
        map = HealpixMap(rand(npix))
        alm = map2alm(map, lmax, mmax)

        # Note that the algorithm used by map2alm isn't particularly great
        # with no iterations (hence the rough tolerance)
        map1 = alm2map(alm, nside)
        map2 = alm2map(map2alm(map1, lmax, mmax), nside)
        @test vecnorm(pixels(map1)-pixels(map2))/vecnorm(pixels(map1)) < 1e-2

        # With more iterations we should be able to do better
        map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 1), nside)
        @test vecnorm(pixels(map1)-pixels(map2))/vecnorm(pixels(map1)) < 1e-3
        map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 2), nside)
        @test vecnorm(pixels(map1)-pixels(map2))/vecnorm(pixels(map1)) < 1e-4
        map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 3), nside)
        @test vecnorm(pixels(map1)-pixels(map2))/vecnorm(pixels(map1)) < 1e-5
        map2 = alm2map(map2alm(map1, lmax, mmax, iterations = 10), nside)
        @test vecnorm(pixels(map1)-pixels(map2))/vecnorm(pixels(map1)) < 1e-12
    end
end

