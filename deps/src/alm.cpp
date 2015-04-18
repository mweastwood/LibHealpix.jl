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

#include <complex>
#include <xcomplex.h>
#include <arr.h>
#include <alm.h>

using std::complex;

extern "C" {
    size_t num_alm(size_t lmax, size_t mmax) {return Alm_Base::Num_Alms(lmax,mmax);}

    Alm<xcomplex<double> >* newAlm(complex<double>* vec_alm, size_t lmax, size_t mmax)
    {
        size_t nalm = num_alm(lmax,mmax);
        // Pack the alms into HEALPix's arr container
        arr<xcomplex<double> > arr_alm(num_alm(lmax,mmax));
        for (uint i = 0; i < nalm; ++i)
            arr_alm[i] = xcomplex<double>(vec_alm[i]);
        // Create the Alm container
        Alm<xcomplex<double> >* alm = new Alm<xcomplex<double> >(lmax,mmax);
        alm->Set(arr_alm,lmax,mmax);
        return alm;
    }
    void deleteAlm(Alm<xcomplex<double> >* alm) {delete alm;}
    void alm2julia(Alm<xcomplex<double> >* alm, complex<double>* output)
    {
        arr<xcomplex<double> > arr_alm = alm->Alms();
        for (uint i = 0; i < arr_alm.size(); ++i)
            output[i] = arr_alm[i];
    }
    int lmax(Alm<xcomplex<double> >* alm) {return alm->Lmax();}
    int mmax(Alm<xcomplex<double> >* alm) {return alm->Mmax();}
}

