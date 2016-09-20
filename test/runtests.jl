using LibHealpix
using Base.Test

srand(123)
@testset "LibHealpix Tests" begin
    include("pixel.jl")
    include("map.jl")
    include("alm.jl")
    include("transforms.jl")
    include("mollweide.jl")
end

