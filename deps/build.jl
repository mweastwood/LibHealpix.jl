depsdir = dirname(@__FILE__)

# Download the HEALPix source
println("Downloading the HEALPix source...")
version = "3.20"
gz = "Healpix_$(version)_2014Dec05.tar.gz"
url = "http://downloads.sourceforge.net/project/healpix/Healpix_$version/$gz"
dir = joinpath(depsdir,"downloads")

run(`mkdir -p $dir`)
run(`curl -o $(joinpath(dir,gz)) -L $url`)
run(`tar -xzf $(joinpath(dir,gz)) -C $dir`)

# Build the HEALPix wrapper
println("Building the HEALPix wrapper...")
dir = joinpath(depsdir,"src")
run(`make -C $dir`)
run(`make -C $dir install`)

