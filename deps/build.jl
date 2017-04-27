using BinDeps

BinDeps.@setup

libchealpix = library_dependency("libchealpix")

provides(AptGet, Dict("libchealpix-dev" => libchealpix, "libchealpix0" => libchealpix))

BinDeps.@install Dict(:libchealpix => :libchealpix)

