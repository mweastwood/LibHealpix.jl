using Compat

# First build the Healpix library

@linux_only begin
    apt = try
        success(`apt-get -v`)
        # ok we have apt, but do the healpix packages exist?
        search_for_libchealpix    = readstring(`apt-cache showpkg libchealpix-dev`)
        search_for_libhealpix_cxx = readstring(`apt-cache showpkg libhealpix-cxx-dev`)
        # the following test is brittle a more thorough test of the output should be added
        !isempty(search_for_libchealpix) && !isempty(search_for_libhealpix_cxx)
    catch exception
        false
    end

    if apt
        println("Running `sudo apt-get install libchealpix-dev`")
        run(`sudo apt-get install libchealpix-dev`)
        println("Running `sudo apt-get install libhealpix-cxx-dev`")
        run(`sudo apt-get install libhealpix-cxx-dev`)
    else
        println("Manually downloading and building the Healpix library")
        depsdir = dirname(@__FILE__)
        version = "3.30"
        date = "2015Oct08"
        tar = "Healpix_$(version)_$date.tar.gz"
        url = "http://downloads.sourceforge.net/project/healpix/Healpix_$version/$tar"
        dir = joinpath(depsdir, "downloads")
        run(`mkdir -p $dir`)
        run(`curl -o $(joinpath(dir, tar)) -L $url`)
        run(`tar -xzf $(joinpath(dir, tar)) -C $dir`)
        run(`./build_healpix.sh`)
    end
end

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    println("Installing healpix from the Homebrew/science tap")
    Homebrew.add("homebrew/science/healpix")
end

# Then build the wrapper

println("Building the HEALPix wrapper...")
# TODO: make this use autotools or something
depsdir = dirname(@__FILE__)
dir = joinpath(depsdir, "src")
run(`make -C $dir`)
run(`make -C $dir install`)

