using HEALPix
using Base.Test

for nside = 1:5
    npix = 12*nside^2
    @test HEALPix.nside2npix(nside) == npix
    @test HEALPix.npix2nside(npix) == nside
end

for θ in [0.5:0.5:3.0;], ϕ in [0.0:1.0:6.0;]
    vec = HEALPix.ang2vec(θ,ϕ)
    θ′,ϕ′ = HEALPix.vec2ang(vec)
    @test_approx_eq θ θ′
    @test_approx_eq ϕ ϕ′
end

let nside = 16
    for i = 1:HEALPix.nside2npix(nside)
        @test HEALPix.nest2ring(nside,HEALPix.ring2nest(nside,i)) == i
    end
end

