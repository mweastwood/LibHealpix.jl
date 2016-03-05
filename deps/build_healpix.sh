#!/bin/bash

PWD=`pwd`
PREFIX=$PWD/usr
HEALPIXDIR=$PWD/downloads/Healpix_3.30

cd $HEALPIXDIR/src/C/autotools
autoreconf --install
./configure --prefix=$PREFIX
make install

cd $HEALPIXDIR/src/cxx/autotools
autoreconf --install
./configure --prefix=$PREFIX
make install

