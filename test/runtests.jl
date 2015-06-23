using HEALPix
using Base.Test

srand(123)

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

let nside = 16
    npix = HEALPix.nside2npix(nside)
    map = HEALPixMap(rand(npix))
    alm = map2alm(map,lmax=25,mmax=25)

    # Note that the algorithm used by alm2map/map2alm isn't
    # particularly accurate, hence the rough tolerance
    map1 = alm2map(alm)
    map2 = alm2map(map2alm(map1))
    @test vecnorm(HEALPix.pixels(map1)-HEALPix.pixels(map2))/vecnorm(HEALPix.pixels(map1)) < 0.01
end

# Test FITS I/O
let nside = 16
    filename = tempname()*".fits"
    map = HEALPixMap(Float32,nside)
    for i = 1:length(map)
        map[i] = rand()
    end
    writehealpix(filename,map)
    newmap = readhealpix(filename)
    @test map == newmap
end

