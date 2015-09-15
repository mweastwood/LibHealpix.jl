using LibHealpix
using Base.Test

srand(123)

for nside = 1:5
    npix = 12*nside^2
    @test LibHealpix.nside2npix(nside) == npix
    @test LibHealpix.npix2nside(npix) == nside
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
end

let nside = 16
    for i = 1:LibHealpix.nside2npix(nside)
        @test LibHealpix.nest2ring(nside,LibHealpix.ring2nest(nside,i)) == i
    end
end

let nside = 16
    npix = LibHealpix.nside2npix(nside)
    map = HealpixMap(rand(npix))
    alm = map2alm(map,lmax=25,mmax=25)

    # Note that the algorithm used by alm2map/map2alm isn't
    # particularly accurate, hence the rough tolerance
    map1 = alm2map(alm)
    map2 = alm2map(map2alm(map1))
    @test vecnorm(LibHealpix.pixels(map1)-LibHealpix.pixels(map2))/vecnorm(LibHealpix.pixels(map1)) < 0.01
end

# Test FITS I/O
let nside = 16
    filename = tempname()*".fits"
    map = HealpixMap(Float32,nside)
    for i = 1:length(map)
        map[i] = rand()
    end
    writehealpix(filename,map)
    newmap = readhealpix(filename)
    @test map == newmap
end

# Test the Mollweide projection
let nside = 5
    map = HealpixMap(Float64,nside)
    for i = 1:length(map)
        map[i] = 1.0
    end
    img = mollweide(map)'
    # Verify that the image is unity inside and zero outside
    N = size(img,2)
    x = linspace(-2+1/N,2-1/N,2N)
    y = linspace(-1+1/N,1-1/N,1N)
    for j = 1:N, i = 1:2N
        if x[i]^2 + 4y[j]^2 > 4
            @test img[i,j] == 0
        else
            @test img[i,j] == 1
        end
    end
end

