# News

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
