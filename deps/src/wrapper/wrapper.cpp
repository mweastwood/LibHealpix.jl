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
    arr<T> arr_pixels(pixels, 12*nside*nside);
    Healpix_Ordering_Scheme ordering_scheme = static_cast<Healpix_Ordering_Scheme>(order);
    auto map = Healpix_Map<T>();
    map.Set(arr_pixels, ordering_scheme);
    return map;
}

template <typename T>
Alm<xcomplex<T> > construct_alm(int lmax, int mmax, complex<T>* coefficients)
{
    size_t length = Alm_Base::Num_Alms(lmax, mmax);
    xcomplex<T>* reinterpreted_coefficients
        = reinterpret_cast<xcomplex<T>* >(coefficients);
    arr<xcomplex<T> > arr_coefficients(reinterpreted_coefficients, length);
    auto alm = Alm<xcomplex<T> >();
    alm.Set(arr_coefficients, lmax, mmax);
    return alm;
}

template <typename T>
void map2alm(int nside, int order, T* pixels,
             int lmax, int mmax, int iterations,
             complex<T>* coefficients)
{
    auto map = construct_healpix_map(nside, order, pixels);
    auto alm = construct_alm(lmax, mmax, coefficients);
    map2alm_iter(map, alm, iterations);
}

template <typename T>
void alm2map(int lmax, int mmax, complex<T>* coefficients,
             int nside, T* pixels)
{
    auto alm = construct_alm(lmax, mmax, coefficients);
    auto map = construct_healpix_map(nside, 0, pixels); // 0 is ring ordered
    alm2map(alm, map);
}

template <typename T>
T interpolate(int nside, int order, T* pixels, double theta, double phi)
{
    auto map = construct_healpix_map(nside, order, pixels);
    auto ptg = pointing(theta, phi);
    auto pix = fix_arr<int, 4>();    // the index of the 4 nearest pixels
    auto wgt = fix_arr<double, 4>(); // the weights for the 4 nearest pixels
    map.get_interpol(ptg, pix, wgt);
    return wgt[0]*map[pix[0]] + wgt[1]*map[pix[1]]
            + wgt[2]*map[pix[2]] + wgt[3]*map[pix[3]];
}

extern "C" {
    void map2alm_float(int nside, int order, float* pixels,
                       int lmax, int mmax, int iterations,
                       complex<float>* coefficients)
    {
        map2alm(nside, order, pixels, lmax, mmax, iterations, coefficients);
    }

    void map2alm_double(int nside, int order, double* pixels,
                        int lmax, int mmax, int iterations,
                        complex<double>* coefficients)
    {
        map2alm(nside, order, pixels, lmax, mmax, iterations, coefficients);
    }

    void alm2map_float(int lmax, int mmax, complex<float>* coefficients,
                       int nside, float* pixels)
    {
        alm2map(lmax, mmax, coefficients, nside, pixels);
    }

    void alm2map_double(int lmax, int mmax, complex<double>* coefficients,
                        int nside, double* pixels)
    {
        alm2map(lmax, mmax, coefficients, nside, pixels);
    }

    float interpolate_float(int nside, int order, float* pixels,
                            double theta, double phi)
    {
        return interpolate(nside, order, pixels, theta, phi);
    }

    double interpolate_double(int nside, int order, double* pixels,
                              double theta, double phi)
    {
        return interpolate(nside, order, pixels, theta, phi);
    }
}

