# Copyright (c) 2015-2017 Michael Eastwood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

for (T, suffix) in ((Float32, "_float"), (Float64, "_double"))
    map2alm_name = "map2alm"*suffix
    alm2map_name = "alm2map"*suffix

    @eval function map2alm(map::RingHealpixMap{$T}, lmax::Integer, mmax::Integer;
                           iterations::Integer=0)
        coefficients = zeros(Complex{$T}, ncoeff(lmax, mmax))
        ccall(($map2alm_name, libhealpixwrapper), Void,
              (Cint, Cint, Ptr{$T}, Cint, Cint, Cint, Ptr{Complex{$T}}),
              map.nside, ring, map.pixels, lmax, mmax, iterations, coefficients)
        Alm(lmax, mmax, coefficients)
    end

    @eval function alm2map(alm::Alm{Complex{$T}}, nside::Integer)
        pixels = zeros($T, nside2npix(nside))
        ccall(($alm2map_name, libhealpixwrapper), Void,
              (Cint, Cint, Ptr{Complex{$T}}, Cint, Ptr{$T}),
              alm.lmax, alm.mmax, alm.coefficients, nside, pixels)
        RingHealpixMap(nside, pixels)
    end
end

doc"""
    map2alm(map, lmax, mmax)

Compute the spherical harmonic coefficients of the given Healpix map by means of a spherical
harmonic transform.

**Arguments:**

- `map` - the input Healpix map (must be ring ordered)
- `lmax` - the maximum value for the $l$ quantum number
- `mmax` - the maximum value for the $m$ quantum number

**Keyword Arguments:**

- `iterations` - the number of iterations to perform

!!! note
    Set `iterations` to something greater than 0 if more precision is required.

**Usage:**

```jldoctest
julia> map = RingHealpixMap(Float64, 4)
       map[:] = 1
       alm = map2alm(map, 1, 1)
       @lm alm[0, 0]
3.5449077018110318 + 0.0im
```

**See Also:** [`alm2map`](@ref)
""" map2alm

"""
    alm2map(alm, nside)

Compute the Healpix map corresponding to the given spherical harmonic coefficients by means of an
inverse spherical harmonic transform.

**Arguments:**

- `alm` - the input list of spherical harmonic coefficients
- `nside` - the resolution of the output Healpix map

**Usage:**

```jldoctest
julia> alm = Alm(Complex128, 1, 1)
       @lm alm[0, 0] = 1
       map = alm2map(alm, 1)
12-element LibHealpix.RingHealpixMap{Float64}:
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
 0.282095
```

**See Also:** [`map2alm`](@ref)
""" alm2map

