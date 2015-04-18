#!/bin/sh

HEALPIXDIR=downloads/Healpix_3.20

cp config.gcc_with_fpic $HEALPIXDIR/src/cxx/config
cd $HEALPIXDIR
mkdir -p include
mkdir -p lib

# (the configure script says something goes wrong at the end, but it seems to work anyway)
./configure -L << EOF
2
gcc
-O2 -Wall
ar -rsv
n
y
n
0
EOF

./configure -L << EOF
4


2
n
0
EOF

make c-all
make cpp-all

