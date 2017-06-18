# Cookbook

This page contains a few examples that demonstrate how to work with LibHealpix.jl.  All of these
examples should be preceded by `using LibHealpix` in order to load the package.

```@meta
DocTestSetup = quote
    using LibHealpix
end
```

## Creating a Map

In this example we will create a low-resolution Healpix map. We will number the pixels and visualize
it in the terminal using the [`mollweide`](@ref) function to create a Mollweide projected image of
the map.

```jldoctest
julia> nside = 1 # lowest resolution map possible
       map = RingHealpixMap(Int, nside)
       map[:] = 1:length(map)
       map
12-element LibHealpix.RingHealpixMap{Int64}:
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12

julia> mollweide(map, (10, 20))
10×20 Array{Int64,2}:
 0   0   0   0   0   0   2   2  1  1   4   4   3   3   0   0   0   0   0  0
 0   0   0   2   2   2   1   1  1  1   4   4   4   4   3   3   3   0   0  0
 0   7   2   2   2   6   1   1  1  1   4   4   4   4   8   3   3   3   7  0
 7   2   2   2   6   6   1   1  1  5   5   4   4   4   8   8   3   3   3  7
 7   7   2   6   6   6   6   1  5  5   5   5   4   8   8   8   8   3   7  7
 7   7  10   6   6   6   6   9  5  5   5   5  12   8   8   8   8  11   7  7
 7  10  10  10   6   6   9   9  9  5   5  12  12  12   8   8  11  11  11  7
 0   7  10  10  10   6   9   9  9  9  12  12  12  12   8  11  11  11   7  0
 0   0   0  10  10  10   9   9  9  9  12  12  12  12  11  11  11   0   0  0
 0   0   0   0   0   0  10  10  9  9  12  12  11  11   0   0   0   0   0  0
```

## Spherical Harmonic Transforms

Spherical harmonic transforms are accomplished using the [`map2alm`](@ref) and [`alm2map`](@ref)
functions. In this example we will create a map from its spherical harmonic coefficients using
[`alm2map`](@ref), and then compute its spherical harmonic coefficients with [`map2alm`](@ref). In
the latter step notice that we can obtain more accuracy by using more iterations.

```julia
julia> lmax = mmax = 1
       alm = Alm(Complex128, lmax, mmax)
       @lm alm[0, 0] = 1
       @lm alm[1, 0] = 2
       @lm alm[1, 1] = 0+3im
       alm
3-element LibHealpix.Alm{Complex{Float64}}:
 1.0+0.0im
 2.0+0.0im
 0.0+3.0im

julia> nside = 1
       map = alm2map(alm, nside)
12-element LibHealpix.RingHealpixMap{Float64}:
  2.02611 
  2.02611 
 -0.158984
 -0.158984
  0.282095
  2.35506 
  0.282095
 -1.79087 
  0.723173
  0.723173
 -1.46192 
 -1.46192 

julia> new_alm = map2alm(map, lmax, mmax)
3-element LibHealpix.Alm{Complex{Float64}}:
         1.0+0.0im    
     1.77778+0.0im    
 1.79636e-16+3.16667im

julia> new_alm = map2alm(map, lmax, mmax, iterations=3)
3-element LibHealpix.Alm{Complex{Float64}}:
         1.0+0.0im    
      1.9997+0.0im    
 2.83224e-16+2.99997im
```

## FITS I/O

Healpix maps can be written to disk as a FITS image using the [`writehealpix`](@ref) function or
read from disk using the [`readhealpix`](@ref) function. In this example we will generate a random
Healpix map, write it to a temporary file, and then read it back from disk. The two maps should be
identical.

```jldoctest
julia> nside = 256
       map = NestHealpixMap(Float64, nside)
       map[:] = rand(length(map))
       filename = tempname()*".fits"
       writehealpix(filename, map)
       new_map = readhealpix(filename)
       map == new_map
true
```

!!! note
    If you run into errors reading a FITS-formatted Healpix image, it may be the case that the map
    is stored in a way that is inconsistent with the format defined by `libchealpix`. You should be
    able to manually read in the map using [FITSIO.jl](https://github.com/JuliaAstro/FITSIO.jl). You
    will need to find the appropriate HDU and table column in the FITS file.

