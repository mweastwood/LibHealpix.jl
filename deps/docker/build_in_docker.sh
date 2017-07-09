#!/bin/bash

set -eu
cd `dirname $0`

docker create -it --name libhealpixjl tkelman/c6g6
docker start libhealpixjl
docker cp build.sh libhealpixjl:/tmp
docker exec libhealpixjl /tmp/build.sh

docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libcfitsio.so.5 .
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libchealpix.so.0 .
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libhealpix_cxx.so.0 .
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr/lib/libhealpixwrapper.so .

docker rm -f libhealpixjl

