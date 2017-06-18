using LibHealpix
using PyPlot

nside = 8
map = NestHealpixMap(Float64, nside)
map[:] = 1:length(map)
img = mollweide(map)
img[img .== 0] = NaN

figure(figsize=(10,5))
imshow(img, origin="upper", interpolation="nearest", cmap=get_cmap("magma"))
gca()[:set_aspect]("equal")
tight_layout()
axis("off")
gca()[:get_xaxis]()[:set_visible](false)
gca()[:get_yaxis]()[:set_visible](false)
savefig(joinpath(dirname(@__FILE__), "nest_healpix_map.png"),
        bbox_inches="tight", transparent=true)

