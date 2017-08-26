using BinDeps

BinDeps.@setup

libcfitsio        = library_dependency("libcfitsio", aliases=["libcfitsio.so.5"])
libchealpix       = library_dependency("libchealpix", aliases=["libchealpix.so.0"],
                                       depends=[libcfitsio])
libhealpix_cxx    = library_dependency("libhealpix_cxx", aliases=["libhealpix_cxx.so.0"],
                                       depends=[libcfitsio])
libhealpixwrapper = library_dependency("libhealpixwrapper", depends=[libhealpix_cxx])

has_pkg_config = try
    readstring(`pkg-config --version`)
    true
catch
    false
end

has_libtool = if is_linux()
    # TODO: a more thorough search for libtool.m4?
    isfile("/usr/share/aclocal/libtool.m4") || isfile("/usr/local/share/aclocal/libtool.m4")
else
    false
end

provides(AptGet, Dict("libcfitsio3-dev"    => libcfitsio,
                      "libchealpix-dev"    => libchealpix,     # Xenial and later only
                      "libhealpix-cxx-dev" => libhealpix_cxx)) # Xenial and later only

if is_apple()
    using Homebrew
    provides(Homebrew.HB, "cfitsio", libcfitsio, os=:Darwin)
    provides(Homebrew.HB, "homebrew/science/healpix", [libchealpix, libhealpix_cxx], os=:Darwin)
    if !has_pkg_config
        Homebrew.add("pkg-config")
        has_pkg_config = true
    end
end

function ⊕(path1, path2)
    if path1 == ""
        return path2
    elseif path2 == ""
        return path1
    else
        return string(path1, ":", path2)
    end
end

usr = joinpath(BinDeps.depsdir(libhealpixwrapper), "usr")
libs    = joinpath(usr, "lib")
headers = joinpath(usr, "include")

c_include_path = headers ⊕ get(ENV, "C_INCLUDE_PATH", "")
cplus_include_path = headers ⊕ get(ENV, "CPLUS_INCLUDE_PATH", "")
ld_library_path = libs ⊕  get(ENV, "LD_LIBRARY_PATH", "")
pkg_config_path = joinpath(libs, "pkgconfig") ⊕ get(ENV, "PKG_CONFIG_PATH", "")

if is_apple()
    pkg_config_path = joinpath(Homebrew.prefix(), "lib", "pkgconfig") ⊕ pkg_config_path
end

env = copy(ENV)
env["C_INCLUDE_PATH"] = c_include_path
env["CPLUS_INCLUDE_PATH"] = cplus_include_path
env["LD_LIBRARY_PATH"] = ld_library_path
env["PKG_CONFIG_PATH"] = pkg_config_path

ORIGIN = raw"\$$ORIGIN"

url = "http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3410.tar.gz"
libcfitsio_src_directory = joinpath(BinDeps.depsdir(libcfitsio), "src", "cfitsio")

provides(Sources, URI(url), libcfitsio, unpacked_dir="cfitsio")

provides(SimpleBuild,
         (@build_steps begin
              GetSources(libcfitsio)
              @build_steps begin
                  ChangeDirectory(joinpath(libcfitsio_src_directory))
                  `./configure --prefix=$usr`
                  `make shared install`
              end
          end), libcfitsio)

version = "3.31"
date = "2016Aug26"
tar = "Healpix_$(version)_$date.tar.gz"
url = "http://downloads.sourceforge.net/project/healpix/Healpix_$version/$tar"
libhealpix_src_directory = joinpath(BinDeps.depsdir(libchealpix), "src", "Healpix_$version")

provides(Sources, URI(url), [libchealpix, libhealpix_cxx, libhealpixwrapper],
         unpacked_dir="Healpix_$version")

if has_libtool
    provides(SimpleBuild,
             (@build_steps begin
                  GetSources(libchealpix)
                  @build_steps begin
                      ChangeDirectory(joinpath(libhealpix_src_directory, "src", "C", "autotools"))
                      setenv(`autoreconf --install`, env)
                      setenv(`./configure --prefix=$usr`, env)
                      # Note to self: I have no idea why I need the extra \$ here and not for
                      # libhealpix_cxx.so below. It appears to be necessary though.
                      setenv(`make install LDFLAGS='-Wl,-rpath,\$$ORIGIN'`, env)
                  end
              end), libchealpix)

    provides(SimpleBuild,
             (@build_steps begin
                  GetSources(libchealpix)
                  @build_steps begin
                      ChangeDirectory(joinpath(libhealpix_src_directory, "src", "cxx", "autotools"))
                      setenv(`autoreconf --install`, env)
                      setenv(`./configure --prefix=$usr`, env)
                      setenv(`make install LDFLAGS="-Wl,-rpath,$ORIGIN"`, env)
                  end
              end), libhealpix_cxx)
end

libhealpixwrapper_src_directory = joinpath(BinDeps.depsdir(libhealpixwrapper), "src", "wrapper")

if has_pkg_config
    provides(SimpleBuild,
             (@build_steps begin
                  ChangeDirectory(libhealpixwrapper_src_directory)
                  `make PKG_CONFIG_PATH=$pkg_config_path`
                  `make install`
              end), libhealpixwrapper)
end

if Sys.ARCH == :x86_64
    # TODO: cross-compile for x86
    provides(Binaries,
             URI("https://dl.bintray.com/mweastwood/LibHealpix.jl/dependencies-v0.2.3-0.tar.gz"),
             [libcfitsio, libchealpix, libhealpix_cxx, libhealpixwrapper],
             SHA="aee83f5f36cd48d3cf9e00dbb6231ef09a9eb26aca5b2e30c542ada0a0656b29",
             os=:Linux)
end

# https://github.com/JuliaLang/BinDeps.jl/pull/163
is_linux() && push!(BinDeps.defaults, BinDeps.Binaries)
try
    BinDeps.@install Dict(:libchealpix => :libchealpix, :libhealpixwrapper => :libhealpixwrapper)
finally
    is_linux() && pop!(BinDeps.defaults)
end

