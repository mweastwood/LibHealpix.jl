// Copyright (c) 2015, 2016 Michael Eastwood
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

#include <alm.h>
#include <healpix_map.h>
#include <alm_healpix_tools.h>

extern "C" {
    void map2alm(Healpix_Map<double>* map, Alm<xcomplex<double> >* alm, int num_iter)
    {
        arr<double> weight(2*map->Nside(),1.0);
        map2alm_iter(*map,*alm,num_iter,weight);
    }

    void alm2map(Alm<xcomplex<double> >* alm, Healpix_Map<double>* map)
    {
        alm2map<double>(*alm,*map);
    }
}

