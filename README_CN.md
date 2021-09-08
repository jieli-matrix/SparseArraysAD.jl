# NiSparseArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jieli-matrix.github.io/NiSparseArrays.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jieli-matrix.github.io/NiSparseArrays.jl/dev)
[![Build Status](https://github.com/jieli-matrix/NiSparseArrays.jl/workflows/CI/badge.svg)](https://github.com/jieli-matrix/NiSparseArrays.jl/actions)
[![Coverage](https://codecov.io/gh/jieli-matrix/NiSparseArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jieli-matrix/NiSparseArrays.jl)

[英文版本](README.md)

这是开源软件供应链点亮计划-暑期2021仓库。`NiSparseArrays` 通过[`NiLang`](https://giggleliu.github.io/NiLang.jl/dev/)以可逆编程地形式对 [`SparseArrays`](https://docs.julialang.org/en/v1/stdlib/SparseArrays/)进行实现。 

## 背景

稀疏矩阵在科学计算中应用广泛，但是在Julia语言里面却没有很好的软件包实现对稀疏矩阵的自动微分，这个项目将会使用可逆嵌入式语言 `NiLang.jl` 通过对 Julia Base 里的稀疏矩阵操作的改写实现对其自动微分。我们将会把生成的自动微分规则接入到 Julia 生态中最流行的自动微分规则库 ChainRules 中。

## 安装 

``` shell
git clone https://github.com/jieli-matrix/NiSparseArrays.jl.git
# git clone https://gitlab.summer-ospp.ac.cn/summer2021/210370152.git
```

在julia (>=1.6) REPL 中键入 ] 然后输入

``` julia
git clone 
pkg> add NiSparseArrays 
```

## API一览  

| API             | 描述        |
| ---------------- | --------------- |
| `function imul!(C::StridedVecOrMat, A::AbstractSparseMatrix{T}, B::DenseInputVecOrMat, α::Number, β::Number) where T`   | 稀疏矩阵与稠密矩阵乘法 |
|`function imul!(C::StridedVecOrMat, xA::Adjoint{T, <:AbstractSparseMatrix}, B::DenseInputVecOrMat, α::Number, β::Number) where T` |  共轭稀疏矩阵与稠密矩阵乘法|
|`function imul!(C::StridedVecOrMat, X::DenseMatrixUnion, A::AbstractSparseMatrix{T}, α::Number, β::Number) where T`| 稠密矩阵与稀疏矩阵乘法 |
|`function imul!(C::StridedVecOrMat, X::Adjoint{T1, <:DenseMatrixUnion}, A::AbstractSparseMatrix{T2}, α::Number, β::Number) where {T1, T2}`| 共轭稠密矩阵与稀疏矩阵乘法 |
|`imul!(C::StridedVecOrMat, X::DenseMatrixUnion, xA::Adjoint{T, <:AbstractSparseMatrix}, α::Number, β::Number) where T`|稠密矩阵与共轭稀疏矩阵乘法 |
|`function idot(r, x::AbstractVector, A::AbstractSparseMatrix{T1}, y::AbstractVector{T2}) where {T1, T2}` | 稀疏矩阵与稠密向量的点积|
|`function idot(r, x::SparseVector, A::AbstractSparseMatrix{T1}, y::SparseVector{T2}) where {T1, T2}`| 稀疏矩阵与稀疏向量的点积|

API还在不断扩充中...

## 一个简单的用例

这里我们用一个最小的用例去展示如何使用`NiSparseArrays`去加速`Zygote`梯度。更多测试用例，可前往`examples`文件夹查看。

``` julia 
julia> using SparseArrays, LinearAlgebra, Random, BenchmarkTools

julia> A = sprand(1000, 1000, 0.1);

julia> x = rand(1000);

julia> using Zygote

julia> @btime Zygote.gradient((A, x) -> sum(A*x), $A, $x)
  15.065 ms (27 allocations: 8.42 MiB)

julia> using NiSparseArrays

julia> @btime Zygote.gradient((A, x) -> sum(A*x), $A, $x)
  644.035 μs (32 allocations: 3.86 MiB)
```

你会发现使用`NiSparseArrays`不仅能够加速计算过程，还能够节省内存分配——这是因为我们的实现在梯度计算的过程中能够保持类型不变，而不是像`Zygote`的原始实现将其转换为`dense array`。

## 贡献

欢迎提出Issue和PR👏

## 许可证

MIT许可证