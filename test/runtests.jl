using HEALPix
using Base.Test

for nside = 1:5
    @test nside2npix(nside) == 12*nside^2
end

