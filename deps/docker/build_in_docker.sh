#!/bin/bash

set -eu
cd `dirname $0`

docker create -it --name libhealpixjl tkelman/c6g6
docker start libhealpixjl
docker cp build.sh libhealpixjl:/tmp
docker exec libhealpixjl /tmp/build.sh

rm -rf usr/lib
mkdir -p usr/lib
docker cp -L libhealpixjl:/usr/local/lib64/libstdc++.so.6 usr/lib
docker cp -L libhealpixjl:/usr/local/lib64/libgomp.so.1 usr/lib
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libcfitsio.so.5 usr/lib
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libchealpix.so.0 usr/lib
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libhealpix_cxx.so.0 usr/lib
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libhealpixwrapper.so usr/lib

docker rm -f libhealpixjl

