# Library

```@meta
CurrentModule = LibHealpix
DocTestSetup = quote
    using LibHealpix
end
```

## Pixel Functions

```@docs
nside2npix
npix2nside
nside2nring
ang2vec
vec2ang
nest2ring
ring2nest
ang2pix_nest
ang2pix_ring
pix2ang_nest
pix2ang_ring
vec2pix_nest
vec2pix_ring
pix2vec_nest
pix2vec_ring
```

## Healpix Maps

```@docs
HealpixMap
RingHealpixMap
NestHealpixMap
writehealpix
readhealpix
ang2pix
pix2ang
vec2pix
pix2vec
LibHealpix.UNSEEN
LibHealpix.interpolate
query_disc
```

## Spherical Harmonic Coefficients

```@docs
Alm
lm
@lm
```

## Spherical Harmonic Transforms

```@docs
map2alm
alm2map
```

## Visualization

```@docs
mollweide
```

