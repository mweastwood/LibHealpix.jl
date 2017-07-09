#!/bin/bash

set -eu
cd `dirname $0`

VERSION=v0.2.1-0
TARBALL=dependencies-$VERSION.tar.gz

mkdir -p usr/lib
cp libcfitsio.so.5 usr/lib
cp libchealpix.so.0 usr/lib
cp libhealpix_cxx.so.0 usr/lib
cp libhealpixwrapper.so usr/lib
tar -czvf $TARBALL usr
curl -T $TARBALL -umweastwood:$BINTRAY_API_KEY \
    https://api.bintray.com/content/mweastwood/LibHealpix.jl/dependencies/$VERSION/$TARBALL
echo
sha256sum $TARBALL
rm -rf usr

