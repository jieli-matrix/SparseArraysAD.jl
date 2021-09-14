# # [How to port rules generated by NiSparseArrays to Zygote](@id power_method)
#
# In this demo we'll show how to insert NiSparseArrays's sparse gradient implementation to boost Zygote's gradient.
using Zygote
using SparseArrays, LinearAlgebra
using BenchmarkTools

# find max eigenvalue by power method
function power_max_eigen(A, x, target; niter=100)
    for i=1:niter
        x = A * x
        x /= norm(x)
    end
    return abs(x' * target)
end

# find min eigenvalue by shift power method
function power_min_eigen(A, x, target, λ; niter=100)
    A = λ*I - A 
    for i=1:niter
        x = A * x
        x /= norm(x)
    end
    return abs(x' * target)
end

# generate test data
A = sprand(5000, 5000, 0.1)
x = randn(5000)
target = randn(5000)
λ = 2

# Zygote is able to generate correct gradient for sparse matrix and dense vectors
# in computation form of dense arrays  
@btime max_ga_z, max_gx_z, max_gt_z = Zygote.gradient(power_max_eigen, $A, $x, $target) #12.954 s (4272 allocations: 27.91 GiB)
@btime min_ga_z, min_gx_z, min_gt_z = Zygote.gradient(power_min_eigen, $A, $x, $target, λ) # 12.343 s (4349 allocations: 28.00 GiB)
max_ga_z, max_gx_z, max_gt_z = Zygote.gradient(power_max_eigen, A, x, target)
min_ga_z, min_gx_z, min_gt_z = Zygote.gradient(power_min_eigen, A, x, target, λ)

using NiSparseArrays
# The gradient generated by NiSparseArrays is much faster
# since it keeps the orginal type in computation process 
@btime max_ga, max_gx, max_gt = Zygote.gradient(power_max_eigen, $A, $x, $target) # 6.180 s (5072 allocations: 16.75 GiB)
@btime min_ga, min_gx, min_gt = Zygote.gradient(power_min_eigen, $A, $x, $target, λ) #  7.289 s (5149 allocations: 16.86 GiB)
max_ga, max_gx, max_gt = Zygote.gradient(power_max_eigen, A, x, target)
min_ga, min_gx, min_gt = Zygote.gradient(power_min_eigen, A, x, target, λ)

using Test

# check the results generated by Zygote and NiSparseArrays are consistent
@testset begin
    @testset "power method for max eigenvalue" begin
        @test max_ga_z ≈ max_ga
        @test max_gx_z ≈ max_gx
        @test max_gt_z ≈ max_gt
    end
    @testset "power method for min eigenvalue" begin
        @test min_ga_z ≈ min_ga
        @test min_gx_z ≈ min_gx
        @test min_gt_z ≈ min_gt
    end
end