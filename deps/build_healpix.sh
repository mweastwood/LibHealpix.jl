#!/bin/bash

HEALPIXDIR=downloads/Healpix_3.30

cp config/config.gcc_with_fpic $HEALPIXDIR/src/cxx/config
cd $HEALPIXDIR
mkdir -p include
mkdir -p lib

# patch the configure script to search the correct directory on Travis
patch hpxconfig_functions.sh ../../patches/hpxconfig_functions.patch

bash ./configure -L << EOF
2
gcc
-O2 -Wall
ar -rsv
y



y
n
0
EOF

bash ./configure -L << EOF
4


2
n
0
EOF

# patch the C Makefile to link libcfitsio into libchealpix
patch src/C/subs/Makefile ../../patches/src_C_subs_Makefile.patch

make c-all
make cpp-all
cp lib/* ../../usr/lib

