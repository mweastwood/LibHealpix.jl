@testset "map.jl" begin
    let
        @test_throws DimensionMismatch HealpixMap{Float64,2,LibHealpix.ring}(zeros(Float64,5))

        nside′ = 16
        npix′ = nside2npix(nside′)

        map = HealpixMap(nside′,LibHealpix.ring,zeros(npix′))
        @test npix(map) == npix′ == length(map)
        @test nside(map) == nside′
        @test isring(map)
        @test !isnest(map)

        map = HealpixMap(Float64,nside′)
        @test npix(map) == npix′ == length(map)
        @test nside(map) == nside′
        @test isring(map)
        @test !isnest(map)
        @test pixels(map) == zeros(Float64,npix′)

        map = HealpixMap(Float64,nside′,LibHealpix.nest)
        @test npix(map) == npix′ == length(map)
        @test nside(map) == nside′
        @test !isring(map)
        @test isnest(map)
        @test pixels(map) == zeros(Float64,npix′)

        map = HealpixMap(zeros(npix′))
        @test npix(map) == npix′ == length(map)
        @test nside(map) == nside′
        @test isring(map)
        @test !isnest(map)

        map = HealpixMap(zeros(npix′), LibHealpix.nest)
        @test npix(map) == npix′ == length(map)
        @test nside(map) == nside′
        @test !isring(map)
        @test isnest(map)
    end

    let
        for order in (LibHealpix.ring, LibHealpix.nest)
            map = HealpixMap(Float64, 512, order)
            rand!(map.pixels)
            map′ = LibHealpix.to_julia(LibHealpix.to_cxx(map))
            @test map == map′
        end
    end

    let nside = 16
        filename = tempname()*".fits"
        map = HealpixMap(Float32,nside)
        for i = 1:length(map)
            map[i] = rand()
        end
        writehealpix(filename,map)
        newmap = readhealpix(filename)
        @test map == newmap
        @test_throws ErrorException writehealpix(filename,map)

        # try with nest ordering instead
        filename = tempname()*".fits"
        map = HealpixMap(pixels(map), LibHealpix.nest)
        writehealpix(filename,map)
        newmap = readhealpix(filename)
        @test map == newmap
        @test_throws ErrorException writehealpix(filename,map)
    end
end

