@testset "mollweide.jl" begin
    let nside = 5
        map = HealpixMap(Float64, nside)
        for i = 1:length(map)
            map[i] = 1.0
        end
        img = mollweide(map)'
        N = size(img,2)
        expected_img = zeros(2N,1N)
        # Verify that the image is unity inside and zero outside
        x = linspace(-2+1/N,2-1/N,2N)
        y = linspace(-1+1/N,1-1/N,1N)
        for j = 1:N, i = 1:2N
            if x[i]^2 + 4y[j]^2 > 4
                expected_img[i,j] = 0
            else
                expected_img[i,j] = 1
            end
        end
        @test img == expected_img
    end
end

