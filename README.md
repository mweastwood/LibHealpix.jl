# HEALPix

[![Build Status](https://travis-ci.org/mweastwood/HEALPix.jl.svg?branch=master)](https://travis-ci.org/mweastwood/HEALPix.jl)
[![Coverage Status](https://coveralls.io/repos/mweastwood/HEALPix.jl/badge.svg?branch=master)](https://coveralls.io/r/mweastwood/HEALPix.jl?branch=master)

> HEALPix is an acronym for Hierarchical Equal Area isoLatitude Pixelization of a sphere.
> As suggested in the name, this pixelization produces a subdivision of a spherical
> surface in which each pixel covers the same surface area as every other pixel.

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

## Development
This package is very much a work in progress. Only a small part of the HEALPix library is currently wrapped.
Please open issues or pull requests for missing functionality.

