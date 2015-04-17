// Copyright (c) 2015 Michael Eastwood
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <arr.h>
#include <healpix_map.h>

extern "C" {
    Healpix_Map<double>* newMap(double* vec_map, size_t nside)
    {
        size_t npix = 12*nside*nside;
        // Pack the pixel values into HEALPix's arr container
        arr<double> arr_map(npix);
        for (uint i = 0; i < npix; ++i)
            arr_map[i] = vec_map[i];
        // Create the Healpix_Map container
        Healpix_Map<double>* map = new Healpix_Map<double>(arr_map,RING);
        return map;
    }
    void deleteMap(Healpix_Map<double>* map) {delete map;}
    void map2julia(Healpix_Map<double>* map, double* output)
    {
        for (int i = 0; i < map->Npix(); ++i)
            output[i] = (*map)[i];
    }
    int nside(Healpix_Map<double>* map) {return map->Nside();}
    int npix(Healpix_Map<double>* map) {return map->Npix();}
}

