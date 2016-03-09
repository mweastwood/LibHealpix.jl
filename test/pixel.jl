@testset "pixel.jl" begin
    for nside = 1:5
        npix = 12*nside^2
        @test nside2npix(nside) == npix
        @test npix2nside(npix) == nside
    end

    for θ in [0.5:0.5:3.0;], ϕ in [0.0:1.0:6.0;]
        vec = LibHealpix.ang2vec(θ,ϕ)
        θ′,ϕ′ = LibHealpix.vec2ang(vec)
        @test θ ≈ θ′
        @test ϕ ≈ ϕ′
    end

    let nside = 512
        pix = 123
        θ,ϕ = LibHealpix.pix2ang_nest(nside,pix)
        @test LibHealpix.ang2pix_nest(nside,θ,ϕ) == pix
        θ,ϕ = LibHealpix.pix2ang_ring(nside,pix)
        @test LibHealpix.ang2pix_ring(nside,θ,ϕ) == pix
        vec = LibHealpix.pix2vec_nest(nside,pix)
        @test LibHealpix.vec2pix_nest(nside,vec) == pix
        vec = LibHealpix.pix2vec_ring(nside,pix)
        @test LibHealpix.vec2pix_ring(nside,vec) == pix
    end

    let nside = 4
        for i = 1:LibHealpix.nside2npix(nside)
            @test LibHealpix.nest2ring(nside,LibHealpix.ring2nest(nside,i)) == i
        end
    end
end

