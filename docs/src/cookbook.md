# Cookbook

## Creating a Map
```julia
using LibHealpix
nside = 16
map = HealpixMap(Float64, nside)
for i = 1:length(map)
    map[i] = i
end
```

## Spherical Harmonic Transforms
```julia
using LibHealpix
lmax = mmax = 10
alm = Alm(Complex128, lmax, mmax)
for m = 0:mmax, l = m:lmax
    alm[l,m] = l + m
end
nside = 16
map = alm2map(alm, nside)
blm = map2alm(map, lmax, mmax)
```

## FITS I/O
```julia
using LibHealpix
map = readhealpix("map.fits")
writehealpix("othermap.fits", map)
```

## Visualization
```julia
using LibHealpix
using PyPlot # for imshow(...)
map = HealpixMap(Float64, nside)
for i = 1:length(map)
    map[i] = rand()
end
img = mollweide(map)
imshow(img)
```

