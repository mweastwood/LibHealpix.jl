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
    Healpix_Map<double>* newMap(double* vec_map, size_t nside, int order)
    {
        size_t npix = 12*nside*nside;
        // Pack the pixel values into Healpix's arr container
        arr<double> arr_map(npix);
        for (size_t i = 0; i < npix; ++i)
            arr_map[i] = vec_map[i];
        // Create the Healpix_Map container
        Healpix_Ordering_Scheme scheme = static_cast<Healpix_Ordering_Scheme>(order);
        Healpix_Map<double>* map = new Healpix_Map<double>(arr_map, scheme);
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
    int order(Healpix_Map<double>* map) {return map->Scheme();}

    double interpolate(Healpix_Map<double>* map, double theta, double phi) {
        pointing ptg = pointing(theta, phi);
        fix_arr<int,4> pix = fix_arr<int,4>();
        fix_arr<double,4> wgt = fix_arr<double,4>();
        map->get_interpol(ptg, pix, wgt);
        return wgt[0]*(*map)[pix[0]] + wgt[1]*(*map)[pix[1]]
                + wgt[2]*(*map)[pix[2]] + wgt[3]*(*map)[pix[3]];
    }
}

