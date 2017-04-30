// Copyright (c) 2015-2017 Michael Eastwood
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

#include <iostream>
#include <cstring>
using namespace std;

#include <complex>
#include <xcomplex.h>
#include <arr.h>

#include <healpix_map.h>
#include <alm.h>
#include <alm_healpix_tools.h>

// Note:
//
// The two functions `construct_healpix_map` and `construct_alm` both return by value. At first
// glance this implies that we need a large copy operation to pass the return value. However, the
// copy-elision optimization allows the compiler to avoid this copy operation.
//
// http://en.cppreference.com/w/cpp/language/copy_elision

template <typename T>
Healpix_Map<T> construct_healpix_map(int nside, int order, T* pixels)
{
    arr<double> arr_pixels(pixels, 12*nside*nside);
    Healpix_Ordering_Scheme ordering_scheme = static_cast<Healpix_Ordering_Scheme>(order);
    Healpix_Map<double> map(arr_pixels, ordering_scheme);
    return map;
}

template <typename T>
Alm<xcomplex<T> > construct_alm(int lmax, int mmax, complex<T>* coefficients)
{
    size_t length = Alm_Base::Num_Alms(lmax, mmax);
    xcomplex<double>* reinterpreted_coefficients
        = reinterpret_cast<xcomplex<double>* >(coefficients);
    arr<xcomplex<double> > arr_coefficients(reinterpreted_coefficients, length);
    Alm<xcomplex<double> > alm(lmax, mmax);
    alm.Set(arr_coefficients, lmax, mmax);
    return alm;
}


extern "C" {
    void map2alm(int nside, int order, double* pixels,
                 int lmax, int mmax, int iterations,
                 complex<double>* coefficients)
    {
        auto map = construct_healpix_map(nside, order, pixels);
        auto alm = construct_alm(lmax, mmax, coefficients);
        arr<double> weights(2*nside, 1.0);
        map2alm_iter(map, alm, iterations, weights);
    }

    void alm2map(int lmax, int mmax, complex<double>* coefficients, // Alm input
                 int nside, double* pixels)
    {
        auto alm = construct_alm(lmax, mmax, coefficients);
        auto map = construct_healpix_map(nside, 0, pixels); // 0 is ring ordered
        alm2map(alm, map);
    }

    //double interpolate(Healpix_Map<double>* map, double theta, double phi) {
    //    pointing ptg = pointing(theta, phi);
    //    fix_arr<int,4> pix = fix_arr<int,4>();
    //    fix_arr<double,4> wgt = fix_arr<double,4>();
    //    map->get_interpol(ptg, pix, wgt);
    //    return wgt[0]*(*map)[pix[0]] + wgt[1]*(*map)[pix[1]]
    //            + wgt[2]*(*map)[pix[2]] + wgt[3]*(*map)[pix[3]];
    //}
}

