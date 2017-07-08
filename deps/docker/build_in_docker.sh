#!/bin/bash

set -eu
cd `dirname $0`

docker create -it --name libhealpixjl tkelman/c6g6
docker start libhealpixjl
docker cp build.sh libhealpixjl:/tmp
docker exec libhealpixjl /tmp/build.sh
docker cp -L libhealpixjl:/root/.julia/v0.6/LibHealpix/deps/usr .

