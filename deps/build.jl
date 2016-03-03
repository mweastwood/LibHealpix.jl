using BinDeps
@BinDeps.setup

chealpix       = library_dependency("libchealpix",       runtime = true)
healpix_cxx    = library_dependency("libhealpix_cxx",    runtime = false)
healpixwrapper = library_dependency("libhealpixwrapper", runtime = true, depends = [healpix_cxx])

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    #provides(Homebrew.HB, "cfitsio", cfitsio, os = :Darwin)
end

provides(AptGet, Dict("libchealpix-dev" => chealpix,
                      "libhealpix-cxx-dev" => healpix_cxx))

# Linux build from source

@BinDeps.install Dict(:chealpix => :libchealpix, :healpixwrapper => :libhealpixwrapper)


#=
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
run(`./build_healpix.sh`)

# Build the HEALPix wrapper
println("Building the HEALPix wrapper...")
dir = joinpath(depsdir,"src")
run(`make -C $dir`)
run(`make -C $dir install`)
=#

