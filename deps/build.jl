module Apt
    using Compat # for readstring
    can_use() = try success(`apt-get -v`) catch exception false end
    find(pkg) = startswith(readstring(`apt-cache showpkg $pkg`), "Package: $pkg")
    function install(pkg)
        println("Running `sudo apt-get install $pkg`)")
        run(`sudo apt-get install $pkg`)
    end
end

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    import Homebrew
end

# First install the dependencies

function manually_build_healpix()
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

@linux_only begin
    if Apt.can_use()
        Apt.find("libcfitsio3-dev") && Apt.install("libcfitsio3-dev")
        if Apt.find("libchealpix-dev") && Apt.find("libhealpix-cxx-dev")
            Apt.install("libchealpix-dev")
            Apt.install("libchealpix-dev")
        else
            manually_build_healpix()
        end
    else
        manually_build_healpix()
    end
end

@osx_only begin
    Homebrew.add("homebrew/science/healpix")
end

# Then build the wrapper

println("Building the HEALPix wrapper...")
# TODO: make this use autotools or something
depsdir = dirname(@__FILE__)
dir = joinpath(depsdir, "src")
run(`make -C $dir`)
run(`make -C $dir install`)

