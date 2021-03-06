using MagicDicts
using Test

@testset "MagicDicts.jl" begin
    
    let 
        D = MagicDict()
        D['A', 'A'] = rand()
        D['A', 'B'] = rand()
        D['B', 'A'] = rand()
        @test all(D['A', 'A':'B'] .== [D['A', 'A'],D['A', 'B']])
        @test all(D['A', ['A','B']] .== [D['A', 'A'],D['A', 'B']])
        @test all(D['A':'B', 'A'] .== [D['A', 'A'],D['B', 'A']])
        @test all(D[['A','B'], 'A'] .== [D['A', 'A'],D['B', 'A']])
        D['C', 'A':'B'] = rand()
        @test all(D['C', 'A':'B'] .== D['C', 'A'])
        D[collect(1:10), 'A':'B'] = rand()
        @test all(D[collect(1:10), 'A':'B'] .== D[1, 'A'])
        D = MagicDict()
        D[1,2,3,4] = rand()
        @test haskey(D, 1)
        @test haskey(D, 1, 2)
        @test haskey(D, 1, 2, 3)
        @test haskey(D, 1, 2, 3, 4)
        @test !haskey(D, 1, 3, 4)
    end
end
