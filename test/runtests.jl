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
    vec = LibHealpix.pix2vec_nest(nside,pix)
    @test LibHealpix.vec2pix_nest(nside,vec) == pix
    vec = LibHealpix.pix2vec_ring(nside,pix)
    @test LibHealpix.vec2pix_ring(nside,vec) == pix
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

# Test HealpixMap
let
    @test_throws DimensionMismatch HealpixMap{Float64,2,LibHealpix.ring}(zeros(Float64,5))

    nside′ = 16
    npix′ = nside2npix(nside′)

    map = HealpixMap(nside′,LibHealpix.ring,zeros(npix′))
    @test npix(map) == npix′ == length(map)
    @test nside(map) == nside′
    @test isring(map)
    @test !isnest(map)

    map = HealpixMap(Float64,nside′)
    @test npix(map) == npix′ == length(map)
    @test nside(map) == nside′
    @test isring(map)
    @test !isnest(map)
    @test pixels(map) == zeros(Float64,npix′)

    map = HealpixMap(Float64,nside′,LibHealpix.nest)
    @test npix(map) == npix′ == length(map)
    @test nside(map) == nside′
    @test !isring(map)
    @test isnest(map)
    @test pixels(map) == zeros(Float64,npix′)

    map = HealpixMap(zeros(npix′))
    @test npix(map) == npix′ == length(map)
    @test nside(map) == nside′
    @test isring(map)
    @test !isnest(map)

    map = HealpixMap(zeros(npix′);order=LibHealpix.nest)
    @test npix(map) == npix′ == length(map)
    @test nside(map) == nside′
    @test !isring(map)
    @test isnest(map)
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
    @test_throws ErrorException writehealpix(filename,map)

    # try with nest ordering instead
    filename = tempname()*".fits"
    map = HealpixMap(pixels(map);order=LibHealpix.nest)
    writehealpix(filename,map)
    newmap = readhealpix(filename)
    @test map == newmap
    @test_throws ErrorException writehealpix(filename,map)
end

# Test Alm
let
    @test_throws DomainError Alm{Complex128,5,10}(zeros(Complex128,5))
    @test_throws DimensionMismatch Alm{Complex128,10,5}(zeros(Complex128,5))

    lmax′ = 10
    mmax′ = 5
    N = LibHealpix.num_alm(lmax′,mmax′)

    alm = Alm{Complex128,lmax′,mmax′}(zeros(Complex128,N))
    @test lmax(alm) == lmax′
    @test mmax(alm) == mmax′

    alm = Alm(Complex128,lmax′,mmax′)
    @test lmax(alm) == lmax′
    @test mmax(alm) == mmax′
    @test coefficients(alm) == zeros(Complex128,N)
    alm[0,0] = 1
    @test alm[0,0] == coefficients(alm)[1] == 1

    x = complex(rand(N),rand(N))
    y = complex(rand(N),rand(N))
    alm1 = Alm(lmax′,mmax′,x)
    alm2 = Alm(lmax′,mmax′,y)
    @test coefficients(alm1+alm2) == x+y
    @test coefficients(alm1-alm2) == x-y
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

