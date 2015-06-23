# HEALPix

[![Build Status](https://travis-ci.org/mweastwood/HEALPix.jl.svg?branch=master)](https://travis-ci.org/mweastwood/HEALPix.jl)
[![Coverage Status](https://coveralls.io/repos/mweastwood/HEALPix.jl/badge.svg?branch=master)](https://coveralls.io/r/mweastwood/HEALPix.jl?branch=master)

> HEALPix is an acronym for Hierarchical Equal Area isoLatitude Pixelization of a sphere.
> As suggested in the name, this pixelization produces a subdivision of a spherical
> surface in which each pixel covers the same surface area as every other pixel.

![A HEALPixMap in Mollweide projection](example.png)

## Getting Started

To get started using HEALPix, run:
```julia
Pkg.add("HEALPix")
Pkg.build("HEALPix")
Pkg.test("HEALPix")
using HEALPix
```

The build process will attempt to download and build the [HEALPix](http://healpix.jpl.nasa.gov/) library.

## Examples

### Creating a Map
```julia
using HEALPix
nside = 16
map = HEALPixMap(Float64,nside)
for i = 1:length(map)
    map[i] = i
end
```

### Spherical Harmonic Transforms
```julia
using HEALPix
lmax = mmax = 10
alm = Alm(Complex128,lmax,mmax)
for m = 0:mmax, l = m:lmax
    alm[l,m] = l + m
end
map = alm2map(alm,nside=16)
blm = map2alm(map,lmax=20,mmax=20)
```

### FITS I/O
```julia
using HEALPix
map = readhealpix("map.fits")
writehealpix("othermap.fits",map)
```

### Visualization
```julia
using HEALPix
using PyPlot # for imshow(...)
map = HEALPixMap(Float64,nside)
for i = 1:length(map)
    map[i] = rand()
end
img = mollweide(map)
imshow(img)
```

## Development
This package is very much a work in progress. Only a small part of the HEALPix library is currently wrapped.
Please open issues or pull requests for missing functionality.

