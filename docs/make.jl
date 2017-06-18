# Copyright (c) 2015-2017 Michael Eastwood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

using Documenter, LibHealpix

makedocs(
    format = :html,
    sitename = "LibHealpix.jl",
    authors = "Michael Eastwood",
    linkcheck = true,
    html_prettyurls = !("local" in ARGS),
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "getting-started.md",
            "cookbook.md"
        ],
        "Library" => "library.md"
    ]
)

deploydocs(
    repo = "github.com/mweastwood/LibHealpix.jl.git",
    julia = "0.6",
    osname = "linux",
    target = "build",
    deps = nothing,
    make = nothing
)

