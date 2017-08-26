#!/bin/bash

set -e
mkdir -p /tmp/libhealpixjl
cd /tmp/libhealpixjl

M4_URL="http://ftpmirror.gnu.org/m4/m4-1.4.9.tar.gz"
AUTOCONF_URL="http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz"
AUTOMAKE_URL="https://ftpmirror.gnu.org/gnu/automake/automake-1.15.tar.gz"
LIBTOOL_URL="http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz"
PKG_CONFIG_URL="https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.0-linux-x86_64.tar.gz"

yum install perl -y

# Install build dependencies manually to avoid inadvertantly pulling in an older version of gcc
# using yum. Or something else silly along those lines.

function configure_and_make {
    mkdir $1 && cd $1
    curl -L -o $1.tar.gz $2
    tar xf $1.tar.gz --strip-components 1
    ./configure $3
    make install
    cd ..
}

configure_and_make m4 $M4_URL
configure_and_make autoconf $AUTOCONF_URL
configure_and_make automake $AUTOMAKE_URL
configure_and_make libtool $LIBTOOL_URL
configure_and_make pkg-config $PKG_CONFIG_URL "--with-internal-glib"

# Now install Julia so that we can just run build.jl!

curl -L -o julia.tar.gz $JULIA_URL
tar xf julia.tar.gz --strip-components 1

JULIA=/tmp/libhealpixjl/bin/julia

$JULIA -e 'Pkg.init()'
$JULIA -e 'Pkg.add("BinDeps")'
$JULIA -e 'Pkg.clone("https://github.com/mweastwood/LibHealpix.jl.git")'
$JULIA -e 'Pkg.checkout("LibHealpix")'
$JULIA -e 'Pkg.build("LibHealpix")'
$JULIA -e 'Pkg.test("LibHealpix")'

