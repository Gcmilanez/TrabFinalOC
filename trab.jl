#!/usr/bin/env julia
# trab.jl
# Implementação limpa da heurística VNS para o problema Trabalho Balanceado

using Random
using Printf
# Definindo semente fixa para reproducibilidade
Random.seed!(314159265)

# ————————— Leitura da instância —————————
function ler_instancia(caminho::String)
    open(caminho, "r") do io
        # Número de tarefas (n) e operadores (m)
        n = parse(Int, first(split(strip(readline(io)))))
        m = parse(Int, first(split(strip(readline(io)))))
        # Pula cabeçalho e tempos padrão
        readline(io)
        # Armazena, mas não usa diretamente
        std = Float64[]
        while length(std) < n
            append!(std, parse.(Float64, split(strip(readline(io)))))
        end
        # Pula descrição da matriz p
        readline(io)
        # Lê matriz p[i,k]
        p = zeros(Float64, n, m)
        for k in 1:m
            vals = Float64[]
            while length(vals) < n
                append!(vals, parse.(Float64, split(strip(readline(io)))))
            end
            p[:, k] = vals
        end
        return p, n, m
    end
end

# ————————— Avaliação de solução —————————
function avalia(p::Matrix{Float64}, borders::Vector{Int}, π::Vector{Int})
    m = length(π)
    Tjs = [sum(p[i, π[j]] for i in borders[j]:(borders[j+1]-1)) for j in 1:m]
    return maximum(Tjs)
end

# ————————— Solução Inicial Gulosa —————————
function sol_inicial_gulosa(p::Matrix{Float64}, n::Int, m::Int)
    min_times = [minimum(p[i, :]) for i in 1:n]
    T_ideal = sum(min_times) / m
    borders = [1]
    idx = 1
    for j in 1:m-1
        load = 0.0
        while idx <= n - (m - j) && load < T_ideal
            load += min_times[idx]
            idx += 1
        end
        push!(borders, idx)
    end
    push!(borders, n+1)
    C = zeros(Float64, m, m)
    for j in 1:m, k in 1:m
        C[j, k] = sum(p[i, k] for i in borders[j]:(borders[j+1]-1))
    end
    segments = collect(1:m)
    workers  = collect(1:m)
    π = zeros(Int, m)
    while !isempty(segments)
        best_val, best_j, best_k = Inf, 0, 0
        for j in segments, k in workers
            if C[j, k] < best_val
                best_val, best_j, best_k = C[j, k], j, k
            end
        end
        π[best_j] = best_k
        filter!(x -> x != best_j, segments)
        filter!(x -> x != best_k, workers)
    end
    println("Segmentos iniciais:")
    for j in 1:m
        println("  Segmento ", j, ": begin=", borders[j], ", end=", borders[j+1]-1)
    end
    return borders, π
end

# ————————— Vizinhanças —————————
function neigh_swap_ops(borders::Vector{Int}, π::Vector{Int}, n::Int)
    π2 = copy(π)
    m = length(π)
    i, j = rand(1:m, 2)
    π2[i], π2[j] = π2[j], π2[i]
    return borders, π2
end

function neigh_shift_border(borders::Vector{Int}, π::Vector{Int}, n::Int)
    b = copy(borders)
    j = rand(2:length(b)-1)
    dir = rand(Bool) ? 1 : -1
    if b[j] + dir > b[j-1] + 1 && b[j] + dir < b[j+1]
        b[j] += dir
    end
    return b, π
end

const NEIGHBORHOODS = (neigh_swap_ops, neigh_shift_border)

# ————————— Busca Local (first-improvement) —————————
function busca_local(p::Matrix{Float64}, sol::Tuple{Vector{Int},Vector{Int}}, n::Int)
    borders, π = sol
    f_best = avalia(p, borders, π)
    improved = true
    while improved
        improved = false
        for nb in NEIGHBORHOODS
            new_b, new_π = nb(borders, π, n)
            f_new = avalia(p, new_b, new_π)
            if f_new < f_best
                borders, π, f_best = new_b, new_π, f_new
                improved = true
                break
            end
        end
    end
    return borders, π
end

# ————————— VNS Principal —————————
function VNS(p::Matrix{Float64}; iter_max::Int=500, k_max::Int=2)
    n, m = size(p)
    borders, π = sol_inicial_gulosa(p, n, m)
    f_best = avalia(p, borders, π)
    for _ in 1:iter_max
        k = 1
        while k ≤ k_max
            candidate = k == 1 ? neigh_swap_ops(borders, π, n) : neigh_shift_border(borders, π, n)
            new_b, new_π = busca_local(p, candidate, n)
            f_new = avalia(p, new_b, new_π)
            if f_new < f_best
                @printf("Makespan T = %.3f\n", f_new)
                borders, π, f_best = new_b, new_π, f_new
                k = 1
            else
                k += 1
            end
        end
    end
    return borders, π, f_best
end

# ————————— Função Principal —————————
function main()
    arquivo = isempty(ARGS) ? "testes/tba1.txt" : ARGS[1]
    println("Lendo instância de '$arquivo'...")
    p, n, m = ler_instancia(arquivo)
    borders, π, T = VNS(p; iter_max=100000000, k_max=2)
    println("n= $n, m= $m")
    println("Segmentos: ", [(borders[j], borders[j+1]-1) for j in 1:length(π)])
    println("Permutação operadores: ", π)
    println("Makespan T = $T")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
