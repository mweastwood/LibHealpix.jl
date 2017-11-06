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

function read_coordsys(filename)
    file = fits_open_file(filename)
    fits_movabs_hdu(file, 2)
    coordsys, _ = fits_read_key_str(file, "COORDSYS")
    fits_close_file(file)
    coordsys
end

function create_bad_healpix_fits_1(filename, map::HealpixMap{Float64})
    # create a FITS file with no ORDERING keyword
    tform = "1D"
    nside = Int32(map.nside)
    file = fits_create_file(filename)
    fits_create_img(file, Int16, Int[])
    fits_write_date(file)
    fits_movabs_hdu(file, 1)
    fits_create_binary_tbl(file, length(map), [("SIGNAL", tform, "")], "BINTABLE")
    fits_write_key(file, "PIXTYPE",  "HEALPIX", "HEALPIX pixelization")
    fits_write_key(file, "NSIDE",    nside,     "Resolution parameter for HEALPIX")
    fits_write_col(file, 1, 1, 1, map.pixels)
    fits_close_file(file)
end

function create_bad_healpix_fits_2(filename, map::HealpixMap{Float64})
    # create a FITS file with a bogus value for the ORDERING keyword
    tform = "1D"
    order = "potato"
    nside = Int32(map.nside)
    file = fits_create_file(filename)
    fits_create_img(file, Int16, Int[])
    fits_write_date(file)
    fits_movabs_hdu(file, 1)
    fits_create_binary_tbl(file, length(map), [("SIGNAL", tform, "")], "BINTABLE")
    fits_write_key(file, "PIXTYPE",  "HEALPIX", "HEALPIX pixelization")
    fits_write_key(file, "ORDERING", order,     "Pixel ordering scheme (either RING or NESTED)")
    fits_write_key(file, "NSIDE",    nside,     "Resolution parameter for HEALPIX")
    fits_write_col(file, 1, 1, 1, map.pixels)
    fits_close_file(file)
end

function create_bad_healpix_fits_3(filename, map::HealpixMap{Float64})
    # create a FITS file with a bogus value for tform
    tform = "1X"
    order = isring(map) ? "RING" : "NESTED"
    nside = Int32(map.nside)
    file = fits_create_file(filename)
    fits_create_img(file, Int16, Int[])
    fits_write_date(file)
    fits_movabs_hdu(file, 1)
    fits_create_binary_tbl(file, length(map), [("SIGNAL", tform, "")], "BINTABLE")
    fits_write_key(file, "PIXTYPE",  "HEALPIX", "HEALPIX pixelization")
    fits_write_key(file, "ORDERING", order,     "Pixel ordering scheme (either RING or NESTED)")
    fits_write_key(file, "NSIDE",    nside,     "Resolution parameter for HEALPIX")
    fits_write_col(file, 1, 1, 1, map.pixels)
    fits_close_file(file)
end

@testset "io.jl" begin
    @testset "writehealpix / readhealpix" begin
        for T in (Float32, Float64), Map in (RingHealpixMap, NestHealpixMap)
            nside = 16
            filename = tempname()*".fits"
            map = Map(T, nside)
            for i = 1:length(map)
                map[i] = rand()
            end
            @test writehealpix(filename, map) == map
            @test readhealpix(filename) == map
            @test_throws LibHealpixException writehealpix(filename, map)
            @test writehealpix(filename, map, replace=true) == map
            @test readhealpix(filename) == map
            @test writehealpix(filename, map, coordsys="G", replace=true) == map
            @test read_coordsys(filename) == "G"
            rm(filename)
        end

        for T in (Int32, Int64), Map in (RingHealpixMap, NestHealpixMap)
            nside = 16
            filename = tempname()*".fits"
            map = Map(T, nside)
            @test_throws LibHealpixException writehealpix(filename, map)
        end

        map = RingHealpixMap(Float64, 4)
        filename = tempname()
        create_bad_healpix_fits_1(filename, map)
        @test map == readhealpix(filename) # should generate a warning, but assumes ring ordering
        rm(filename)

        map = RingHealpixMap(Float64, 4)
        filename = tempname()
        create_bad_healpix_fits_2(filename, map)
        @test_throws LibHealpixException readhealpix(filename)
        rm(filename)

        map = RingHealpixMap(Float64, 4)
        filename = tempname()
        create_bad_healpix_fits_3(filename, map)
        @test_throws LibHealpixException readhealpix(filename)
        rm(filename)
    end
end

