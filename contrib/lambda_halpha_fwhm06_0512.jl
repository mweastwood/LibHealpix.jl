using LibHealpix
using FITSIO
using PyPlot

filename = tempname()*".fits"
url = "https://lambda.gsfc.nasa.gov/data/foregrounds/halpha/lambda_halpha_fwhm06_0512.fits"
local img
try
    download(url, filename)
    fits = FITS(filename)
    hdu = fits[2]
    map = NestHealpixMap(read(hdu, "TEMPERATURE"))
    img = mollweide(map)
finally
    isfile(filename) && rm(filename)
end

figure(figsize=(10,5))
imshow(log.(img), origin="upper", interpolation="nearest", cmap=get_cmap("magma"))
gca()[:set_aspect]("equal")
tight_layout()
axis("off")
gca()[:get_xaxis]()[:set_visible](false)
gca()[:get_yaxis]()[:set_visible](false)
savefig(joinpath(dirname(@__FILE__), "lambda_halpha_fwhm06_0512.png"),
        bbox_inches="tight", transparent=true)

