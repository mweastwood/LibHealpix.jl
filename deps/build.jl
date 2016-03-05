module Apt
    using Compat # for readstring
    can_use() = try success(`apt-get -v`) catch exception false end
    find(pkg) = startswith(readstring(`apt-cache showpkg $pkg`), "Package: $pkg")
    function install(pkg)
        info("Running `sudo apt-get install $pkg`)")
        run(`sudo apt-get install $pkg`)
    end
end

module Homebrew
    can_use() = try success(`brew -v`) catch exception false end
    function install(pkg)
        info("Running `brew install $pkg`")
        run(`brew install $pkg`)
    end
end

# First install the dependencies

function manually_build_healpix()
    info("Manually downloading and building the Healpix library")
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
    if Homebrew.can_use()
        Homebrew.install("cfitsio")
    end
    manually_build_healpix()
end

# Then build the wrapper

info("Building the HEALPix wrapper")
depsdir = dirname(@__FILE__)
dir = joinpath(depsdir, "src")
ENV["MY_PKG_CONFIG_PATH"] = joinpath(depsdir, "usr", "lib", "pkgconfig")
run(`make -C $dir`)
run(`make -C $dir install`)

