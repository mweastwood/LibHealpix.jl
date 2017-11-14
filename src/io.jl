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

"""
    writehealpix(filename, map)

Write the `HealpixMap` to disk as a FITS image.

**Arguments:**

- `filename` - the name of the output file (eg. `"/path/to/healpix.fits"`)
- `map` - the Healpix map to write

**Keyword Arguments:**

- `coordsys` - the coordinate system of the map (one of `"G"` galactic, `"E"` ecliptic, or `"C"`
    celestial)
- `replace` - if set to true, the output file will be automatically overwritten if it exists

**See also:** [`readhealpix`](@ref)
"""
function writehealpix(filename, map::HealpixMap; coordsys::String = "", replace::Bool=false)
    if !replace && isfile(filename)
        err("file already exists (use replace=true to automatically overwrite)")
    end

    verify_map_consistency(map)
    if eltype(map) == Float32
        tform = "1E"
    elseif eltype(map) == Float64
        tform = "1D"
    else
        err("only single and double precision floats can be saved to a FITS file")
    end
    order = isring(map) ? "RING" : "NESTED"
    nside = Int32(map.nside)

    file = replace ? fits_clobber_file(filename) : fits_create_file(filename)
    try
        fits_create_img(file, Int16, Int[])
        fits_write_date(file)
        fits_movabs_hdu(file, 1)
        fits_create_binary_tbl(file, length(map), [("SIGNAL", tform, "")], "BINTABLE")
        fits_write_key(file, "PIXTYPE",  "HEALPIX", "HEALPIX pixelization")
        fits_write_key(file, "ORDERING", order,     "Pixel ordering scheme (either RING or NESTED)")
        fits_write_key(file, "NSIDE",    nside,     "Resolution parameter for HEALPIX")
        if coordsys != ""
            fits_write_key(file, "COORDSYS", coordsys,  "Pixelization coordinate system")
            fits_write_comment(file, "G = galactic, E = ecliptic, C = celestial = equatorial")
        end
        fits_write_col(file, 1, 1, 1, map.pixels)
    finally
        fits_close_file(file)
    end

    map
end

"""
    readhealpix(filename)

Read a `HealpixMap` (stored as a FITS image) from disk.

**Arguments:**

- `filename` - the name of the input file (eg. `"/path/to/healpix.fits"`)

**See also:** [`writehealpix`](@ref)
"""
function readhealpix(filename)
    file = fits_open_file(filename) # readonly by default
    try
        hdutype = fits_movabs_hdu(file, 2)
        hdutype == :binary_table || err("expected a binary table")
        tform, tform_comment = fits_read_key_str(file, "TFORM1")
        if tform == "1E"
            T = Float32
        elseif tform == "1D"
            T = Float64
        else
            err("the binary table must store either single or double precision floats")
        end

        naxes, naxis_comment = fits_read_key_lng(file, "NAXIS")
        naxis, nfound = fits_read_keys_lng(file, "NAXIS", 1, naxes)
        nfound == naxes || err("NAXIS header keywords are inconsistent")

        nside, nside_comment = fits_read_key_lng(file, "NSIDE")
        npix = nside2npix(nside)
        npix % naxis[2] == 0 || err("the NSIDE keyword is inconsistent with the number of pixels")

        pixels = zeros(T, npix)
        fits_read_col(file, 1, 1, 1, pixels)

        if readhealpix_isring(file)
            return RingHealpixMap{T}(nside, pixels)
        else
            return NestHealpixMap{T}(nside, pixels)
        end

    finally
        fits_close_file(file)
    end
end

"read the ORDERING keyword with proper error handling"
function readhealpix_isring(file) :: Bool
    local ordering
    try
        ordering, _ = fits_read_key_str(file, "ORDERING")
    catch e
        if e isa ErrorException
            warn("the ORDERING keyword does not exist, assuming RING")
            return true
        else
            rethrow(e)
        end
    end
    if ordering == "RING"
        return true
    elseif ordering == "NESTED"
        return false
    else
        err("unknown value for the ORDERING keyword")
    end
end

