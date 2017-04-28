using BinDeps

BinDeps.@setup

libchealpix = library_dependency("libchealpix")

provides(AptGet, Dict("libchealpix-dev" => libchealpix, "libchealpix0" => libchealpix))

version = "3.30"
date = "2015Oct08"
tar = "Healpix_$(version)_$date.tar.gz"
url = "http://downloads.sourceforge.net/project/healpix/Healpix_$version/$tar"
libhealpix_src_directory = joinpath(BinDeps.depsdir(libchealpix), "src", "Healpix_$version")

provides(Sources, URI(url), libchealpix, unpacked_dir="Healpix_$version")
provides(SimpleBuild,
         (@build_steps begin
              GetSources(libchealpix)
              @build_steps begin
                  @build_steps begin
                      ChangeDirectory(joinpath(libhealpix_src_directory, "src", "C", "autotools"))
                      `autoreconf --install`
                      `./configure --prefix=$(usrdir(libchealpix))`
                      `make install`
                  end
              end
          end), libchealpix, os = :Unix)

BinDeps.@install Dict(:libchealpix => :libchealpix)

