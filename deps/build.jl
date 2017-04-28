using BinDeps

BinDeps.@setup

libchealpix       = library_dependency("libchealpix")
libhealpix_cxx    = library_dependency("libhealpix_cxx")
libhealpixwrapper = library_dependency("libhealpixwrapper")

provides(AptGet, Dict("libchealpix-dev" => libchealpix,
                      "libhealpix-cxx-dev" => libhealpix_cxx))

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
                  `./configure --prefix=$(usrdir(libchealpix))`
                  `make install`
              end
          end), libhealpix_cxx)

libhealpixwrapper_src_directory = joinpath(BinDeps.depsdir(libhealpixwrapper), "src", "wrapper")

provides(SimpleBuild,
         (@build_steps begin
              ChangeDirectory(libhealpixwrapper_src_directory)
              `make`
              `make install`
          end), libhealpixwrapper)

BinDeps.@install Dict(:libchealpix => :libchealpix, :libhealpixwrapper => :libhealpixwrapper)

