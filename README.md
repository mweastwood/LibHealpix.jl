# LibHealpix.jl

LibHealpix.jl is a Julia wrapper of the Healpix library.

The Healpix library defines a pixelization of the sphere that is equal-area (each pixel covers the
same area as every other pixel) and isolatitude (pixels are arranged along rings of constant
latitude). Healpix was born from the need to rapidly compute angular power spectra for Cosmic
Microwave Background experiments (ie. WMAP and Planck) and is widely used in astronomy and
astrophysics.

[K.M. Górski, Eric Hivon, A.J. Banday, B.D. Wandelt, F.K. Hansen, M. Reinecke, M. Bartelmann, 2005,
ApJ 622, 759](http://adsabs.harvard.edu/cgi-bin/nph-bib_query?bibcode=2005ApJ...622..759G)

[![LibHealpix](http://pkg.julialang.org/badges/LibHealpix_0.6.svg)](http://pkg.julialang.org/detail/LibHealpix)
[![Build Status](https://travis-ci.org/mweastwood/LibHealpix.jl.svg?branch=master)](https://travis-ci.org/mweastwood/LibHealpix.jl)
[![codecov](https://codecov.io/gh/mweastwood/LibHealpix.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mweastwood/LibHealpix.jl)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1048406.svg)](https://doi.org/10.5281/zenodo.1048406)

**Documentation:** http://mweastwood.info/LibHealpix.jl/stable/

**Author:** Michael Eastwood

**License:** GPLv3+

## Installation

```julia
Pkg.add("LibHealpix")
```

## Examples

[![OVRO-LWA Sky Map](docs/src/assets/ovro-lwa-sky-map.png)](https://arxiv.org/abs/1711.00466)

[![Dust Map](docs/src/assets/lambda_fds_dust_94GHz.png)](https://lambda.gsfc.nasa.gov/product/foreground/dust_map.cfm)

[![Halpha Map](docs/src/assets/lambda_halpha_fwhm06_0512.png)](https://lambda.gsfc.nasa.gov/product/foreground/halpha_map.cfm)

