# Getting Started

```julia
julia> Pkg.add("LibHealpix")
julia> Pkg.test("LibHealpix")
```

LibHealpix.jl is a registered Julia package and can be installed by running
`Pkg.add("LibHealpix")` from the Julia REPL. You can verify that the package is installed and
functioning correctly by running `Pkg.test("LibHealpix")`.

## Troubleshooting the Installation

Verify that `libcfitsio`, `libchealpix`, and `libhealpix_cxx` are all installed and available in the
linker's search path.

```bash
# On Ubuntu these dependencies can be installed using apt
$ sudo apt-get update
$ sudo apt-get install cfitsio-dev
$ sudo apt-get install libchealpix-dev    # v16.04 and later only
$ sudo apt-get install libhealpix-cxx-dev # v16.04 and later only

# On OSX these dependencies can be installed using Homebrew
$ brew update
$ brew install homebrew/science/cfitsio
$ brew install homebrew/science/healpix
```

After these dependencies are installed make sure to rebuild the package by running

```julia
julia> Pkg.build("LibHealpix")
```

If you continue to have problems installing the package, please open a [Github
issue](https://github.com/mweastwood/LibHealpix.jl/issues/). In the text
please include the details of your operating system, Julia version, and
LibHealpix.jl version.

