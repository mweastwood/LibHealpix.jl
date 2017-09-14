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

# Functions in this file are translated from C++ to Julia (mostly verbatim) from Healpix_cxx.
# Healpix_cxx is licensed under GPL-2.0 or later, and is developed by the Max-Planck-Institut fuer
# Astrophysik.

doc"""
Returns the number of the next ring to the north of $z=\cos(θ)$.  It may return 0; in this case $z$
lies north of all rings.

Note that in some cases, due to floating point rounding errors, the ring may be south of $z$.
"""
function ring_above(nside, z)
    az = abs(z)
    if az < 2/3 # equatorial region
        return trunc(Int, nside*(2-1.5*z))
    else
        ring = trunc(Int, nside*sqrt(3*(1-az)))
        return z>0 ? ring : 4nside-ring-1
    end
end

doc"""
Returns useful information about a given ring of the map.

- `ring` - the ring number (the number of the first ring is 1)
- `startpix` - the number of the first pixel in the ring
  (NOTE: this is always given in the RING numbering scheme!)
- `ringpix` - the number of pixels in the ring
- `θ` - the colatitude (in radians) of the ring
- `shifted` - if `true`, the center of the first pixel is not at $ϕ=0$
"""
function ring_info2(nside, ring)
    northring = ring>2nside ? 4nside-ring : ring
    npix   = nside2npix(nside) # total number of pixels
    npface = nside*nside       # number of pixels per face
    ncap   = (npface-nside)<<1 # number of pixels in the polar cap
    fact2 = 4/npix
    fact1 = (nside<<1)*fact2
    if northring < nside
        tmp = northring*northring*fact2
        cosθ = 1 - tmp
        sinθ = sqrt(tmp*(2-tmp))
        θ = atan2(sinθ, cosθ)
        ringpix = 4northring
        shifted = true
        startpix = 2northring*(northring - 1)
    else
        θ = acos((2nside-northring)*fact1)
        ringpix = 4nside
        shifted = ((northring-nside) & 1) == 0
        startpix = ncap + (northring-nside)*ringpix
    end
    if northring != ring # southern hemisphere
        θ = π - θ
        startpix = npix - startpix - ringpix
    end
    startpix+1, ringpix, θ, shifted
end

