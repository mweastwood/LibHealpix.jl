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

    # We need pkg-config to compile the wrapper, but we can grab that from Homebrew as well
    try
        run(`pkg-config --version`)
    catch
        Homebrew.add("pkg-config")
    end
end

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
                  `autoreconf --install`
                  `./configure --prefix=$(usrdir(libchealpix))`
                  `make install`
              end
          end), libchealpix)

provides(SimpleBuild,
         (@build_steps begin
              GetSources(libchealpix)
              @build_steps begin
                  ChangeDirectory(joinpath(libhealpix_src_directory, "src", "cxx", "autotools"))
                  `autoreconf --install`
                  `./configure --prefix=$(usrdir(libhealpix_cxx))`
                  `make install`
              end
          end), libhealpix_cxx)

function joinpath_variable(path1, path2)
    if path1 == ""
        return path2
    elseif path2 == ""
        return path1
    else
        return string(path1, ":", path2)
    end
end

pkg_config_path = get(ENV, "PKG_CONFIG_PATH", "")
deps_pkg_config_path = joinpath(libdir(libhealpix_cxx), "pkgconfig")
pkg_config_path = joinpath_variable(deps_pkg_config_path, pkg_config_path)
if is_apple()
    brew_pkg_config_path = joinpath(Homebrew.prefix(), "lib", "pkgconfig")
    pkg_config_path = joinpath_variable(brew_pkg_config_path, pkg_config_path)
end

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

