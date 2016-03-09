using LibHealpix
if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

srand(123)
@testset "LibHealpix Tests" begin
    include("pixel.jl")
    include("map.jl")
    include("alm.jl")
    include("transforms.jl")
    include("mollweide.jl")
end

