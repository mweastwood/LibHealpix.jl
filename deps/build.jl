using BinDeps

BinDeps.@setup

libcfitsio        = library_dependency("libcfitsio")
libchealpix       = library_dependency("libchealpix", depends=[libcfitsio])
libhealpix_cxx    = library_dependency("libhealpix_cxx", depends=[libcfitsio])
libhealpixwrapper = library_dependency("libhealpixwrapper", depends=[libhealpix_cxx])

provides(AptGet, Dict("libcfitsio3-dev"    => libcfitsio,
                      "libchealpix-dev"    => libchealpix,     # Xenial and later only
                      "libhealpix-cxx-dev" => libhealpix_cxx)) # Xenial and later only

if is_apple()
    using Homebrew
    provides(Homebrew.HB, "homebrew/science/cfitsio", libcfitsio, os=:Darwin)
    provides(Homebrew.HB, "homebrew/science/healpix", [libchealpix, libhealpix_cxx], os=:Darwin)
    try
        run(`pkg-config --version`)
    catch
        Homebrew.add("pkg-config")
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

version = "3.30"
date = "2015Oct08"
tar = "Healpix_$(version)_$date.tar.gz"
url = "http://downloads.sourceforge.net/project/healpix/Healpix_$version/$tar"
libhealpix_src_directory = joinpath(BinDeps.depsdir(libchealpix), "src", "Healpix_$version")

provides(Sources, URI(url), [libchealpix, libhealpix_cxx, libhealpixwrapper],
         unpacked_dir="Healpix_$version")

provides(SimpleBuild,
         (@build_steps begin
              GetSources(libchealpix)
              @build_steps begin
                  ChangeDirectory(joinpath(libhealpix_src_directory, "src", "C", "autotools"))
                  setenv(`autoreconf --install`, env) # user might not be able to run `autoreconf`
                  setenv(`./configure --prefix=$usr`, env)
                  setenv(`make install LDFLAGS="-Wl,-rpath,$libs"`, env)
              end
          end), libchealpix)

provides(SimpleBuild,
         (@build_steps begin
              GetSources(libchealpix)
              @build_steps begin
                  ChangeDirectory(joinpath(libhealpix_src_directory, "src", "cxx", "autotools"))
                  setenv(`autoreconf --install`, env) # user might not be able to run `autoreconf`
                  setenv(`./configure --prefix=$usr`, env)
                  setenv(`make install LDFLAGS="-Wl,-rpath,$libs"`, env)
              end
          end), libhealpix_cxx)

libhealpixwrapper_src_directory = joinpath(BinDeps.depsdir(libhealpixwrapper), "src", "wrapper")

provides(SimpleBuild,
         (@build_steps begin
              ChangeDirectory(libhealpixwrapper_src_directory)
              `make PKG_CONFIG_PATH=$pkg_config_path`
              `make install`
          end), libhealpixwrapper)

# Binary providers on linux?
# Ref: https://github.com/JuliaLang/BinDeps.jl/pull/163

BinDeps.@install Dict(:libchealpix => :libchealpix, :libhealpixwrapper => :libhealpixwrapper)

