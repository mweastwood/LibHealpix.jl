#!/bin/bash

# usage: ./upload_to_bintray.sh <libname> <version> <filename>
# example: ./upload_to_bintray.sh libcfitsio v3.410-0 libcfitsio.so.5

set -eu
cd `dirname $0`

LIBNAME=$1
VERSION=$2
FILENAME=$3

curl -T $FILENAME -umweastwood:$BINTRAY_API_KEY \
    https://api.bintray.com/content/mweastwood/LibHealpix.jl/$LIBNAME/$VERSION/$FILENAME
echo

