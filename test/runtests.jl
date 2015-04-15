using HEALPix
using Base.Test

for nside = 1:5
    npix = 12*nside^2
    @test nside2npix(nside) == npix
    @test npix2nside(npix) == nside
end

