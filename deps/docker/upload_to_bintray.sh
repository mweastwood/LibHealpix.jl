#!/bin/bash

set -eu
cd `dirname $0`

VERSION=v0.2.3-0
TARBALL=dependencies-$VERSION.tar.gz

tar -czvf $TARBALL usr
curl -T $TARBALL -umweastwood:$BINTRAY_API_KEY \
    https://api.bintray.com/content/mweastwood/LibHealpix.jl/dependencies/$VERSION/$TARBALL
echo
sha256sum $TARBALL

