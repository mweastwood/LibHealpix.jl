# News

## v0.2.3

*2017-08-26*

* implement `interpolate` in Julia (fixes a bug for interpolation near phi=2pi and provides a 30% speed boost)
* use `verify_angles` in `query_disc` and `interpolate`
* update to Healpix 3.31

## v0.2.2

*2017-08-11*

* implement `query_disc` for getting a list of all pixels interior to a disc
* widen the signature of most pixel functions to `Integer`
* fix the Mac build (`cfitsio` was moved away from the `science` tap)

## v0.2.1

*2017-07-09*

* The package build system has been revamped.
* `cfitsio` is now correctly treated as a dependency of this package.
* On OSX the package will install `healpix` and `cfitsio` using `Homebrew.jl`.
* On Linux, we can fall back to pre-compiled shared libraries under certain conditions.
* Pre-compiled libraries (x86_64 only) are hosted at:
  https://bintray.com/mweastwood/LibHealpix.jl/dependencies

## v0.2.0

*2017-06-18*

* Complete package re-write. The package is now compatible with Julia v0.6 only.
* `HealpixMap` has been split into `RingHealpixMap` and `NestHealpixMap`. Both of these are subtypes
  of `AbstractVector` now, and `nside` is no longer a type parameter.
* `Alm` is now a subtype of `AbstractVector` and `lmax`/`mmax` are no longer type parameters.
* Indexing an Alm object by `l` and `m` now requires the `@lm` macro in order to play nicely with
  the `AbstractVector` interface
* Alm and both `HealpixMap`s implement custom broadcasting
* New `QuantumNumberIterator` that allows for easy iterating over values of `l` and `m`
* Pixel functions that return a unit vector will now return a static 3 element array
* Some functions that worked only with Float32 (reading/writing fits files) or Float64 (spherical
  harmonic transforms) now work with either.
* Build system now uses `BinDeps`
* No longer using `Ptr{Void}` fields because they do not play nicely with Julia's GC
* Lots of documentation improvements

