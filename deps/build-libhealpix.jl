using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libhealpix_cxx"], :libhealpix_cxx),
    LibraryProduct(prefix, String["libchealpix"], :libchealpix),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/mweastwood/LibHealpixBuilder/releases/download/v3.31-1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/LibHealpix.aarch64-linux-gnu.tar.gz", "224138eb763f57d65c50cfcf5e5eb5c78d9d1a55155b3e15522e8a220dd44052"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/LibHealpix.arm-linux-gnueabihf.tar.gz", "9015fafd6e5ef62e41ac981397d21f18e9a478bea88b15709156a4bdb8e6539d"),
    Linux(:i686, :glibc) => ("$bin_prefix/LibHealpix.i686-linux-gnu.tar.gz", "9f381eb58d7c2e3ceed92271dc01e28e240313fc25d7932467c22510ce485cbc"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/LibHealpix.powerpc64le-linux-gnu.tar.gz", "55293a22e1700eead663e1982fa27655548608cd299fda5cf7fc024ca4f59ae7"),
    MacOS(:x86_64) => ("$bin_prefix/LibHealpix.x86_64-apple-darwin14.tar.gz", "9104424b10c208135d6ef942f9107bba89b05a66a91690eb050590178762d1fb"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/LibHealpix.x86_64-linux-gnu.tar.gz", "38016ca41b738bcb522136e6590dd489638464ade315af4b68e117f0a9de2217"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
