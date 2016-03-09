@testset "alm.jl" begin
    let
        @test_throws DomainError Alm{Complex128,5,10}(zeros(Complex128,5))
        @test_throws DimensionMismatch Alm{Complex128,10,5}(zeros(Complex128,5))

        lmax′ = 10
        mmax′ = 5
        N = LibHealpix.num_alm(lmax′,mmax′)

        alm = Alm{Complex128,lmax′,mmax′}(zeros(Complex128,N))
        @test lmax(alm) == lmax′
        @test mmax(alm) == mmax′

        alm = Alm(Complex128,lmax′,mmax′)
        @test lmax(alm) == lmax′
        @test mmax(alm) == mmax′
        @test coefficients(alm) == zeros(Complex128,N)
        alm[0,0] = 1
        @test alm[0,0] == coefficients(alm)[1] == 1

        x = complex(rand(N),rand(N))
        y = complex(rand(N),rand(N))
        alm1 = Alm(lmax′,mmax′,x)
        alm2 = Alm(lmax′,mmax′,y)
        @test coefficients(alm1+alm2) == x+y
        @test coefficients(alm1-alm2) == x-y
    end

    let
        alm = Alm(Complex128, 5, 5)
        rand!(alm.alm)
        alm′ = LibHealpix.to_julia(LibHealpix.to_cxx(alm))
        @test alm == alm′
    end
end

