#!/usr/bin/env julia
# trab.jl
# VNS aprimorado para Trabalho Balanceado com vizinhanças diversificadas

using Random, Printf
# Semente fixa para reproducibilidade
#Random.seed!(9)

# ————————— Leitura da instância —————————
function ler_instancia(caminho::String)
    open(caminho, "r") do io
        n = parse(Int, first(split(strip(readline(io)))))
        m = parse(Int, first(split(strip(readline(io)))))
        readline(io)
        std = Float64[]
        while length(std) < n
            append!(std, parse.(Float64, split(strip(readline(io)))))
        end
        readline(io)
        p = zeros(Float64, n, m)
        for k in 1:m
            vals = Float64[]
            while length(vals) < n
                append!(vals, parse.(Float64, split(strip(readline(io)))))
            end
            p[:, k] = vals
        end
        #println("p= ",p)
        #println("n= ",n)
        #println("m= ",m)
        return p, n, m
    end
end

# ————————— Avaliação de solução —————————
function avalia(p::Matrix{Float64}, borders::Vector{Int}, π::Vector{Int})
    Tjs = [sum(p[i, π[j]] for i in borders[j]:(borders[j+1]-1)) for j in 1:length(π)]
    return maximum(Tjs)
end

# ————————— Solução Inicial Gulosa —————————
function sol_inicial_gulosa(p::Matrix{Float64}, n::Int, m::Int)
    # 1) Gera m-1 pontos de corte aleatórios distintos entre 2 e n
    perm_cuts = randperm(n-1) .+ 1
    cuts = sort(perm_cuts[1:m-1])
    borders = [1; cuts; n+1]

    # 2) Atribui operadores aleatoriamente: permutação de 1:m
    π = collect(randperm(m))
    return borders, π
end

# ————————— Vizinhanças (Shakes) —————————
# 1) troca de dois operadores aleatórios
function neigh_swap(p, borders::Vector{Int}, π::Vector{Int}, n::Int)
    π2 = copy(π); m = length(π)
    i = rand(1:m)
    j = rand(1:m-1)
    while j == i
        j = rand(1:m-1)
    end
    π2[i], π2[j] = π2[j], π2[i]
    return borders, π2
end

# 2) shift de fronteira em ±1 (primeiro, último ou interior)
function neigh_shift1(p, borders::Vector{Int}, π::Vector{Int}, n::Int)
    b = copy(borders)
    mseg = length(b) - 1
    jseg = rand(1:mseg)
    if jseg == 1
        # aumenta fim do primeiro segmento
        if b[2] + 1 < b[3]
            b[2] += 1
        end
    elseif jseg == mseg
        # diminui início do último segmento
        if b[mseg] - 1 > b[mseg-1]
            b[mseg] -= 1
        end
    else
        # interior: move fronteira entre jseg e jseg+1
        idx = jseg + 1
        dir = rand(Bool) ? 1 : -1
        if b[idx] + dir > b[idx-1] + 1 && b[idx] + dir < b[idx+1]
            b[idx] += dir
        end
    end
    return b, π
end

# 3) shift de fronteira em ±δ 
function neigh_shift_delta(p, borders::Vector{Int}, π::Vector{Int}, n::Int; δ_max=4)
    b = copy(borders)
    mseg = length(b) - 1
    jseg = rand(1:mseg)
    δ = 0
    while δ == 0
        δ = rand(-δ_max:δ_max)
    end
    if jseg == 1
        # ajusta fim do primeiro segmento
        newb = clamp(b[2] + δ, b[1] + 1, b[3] - 1)
        b[2] = newb
    elseif jseg == mseg
        # ajusta início do último segmento
        newb = clamp(b[mseg] + δ, b[mseg-1] + 1, b[mseg+1] - 1)
        b[mseg] = newb
    else
        # interior: move fronteira entre jseg e jseg+1
        idx = jseg + 1
        b[idx] = clamp(b[idx] + δ, b[idx-1] + 1, b[idx+1] - 1)
    end
    return b, π
end

# 4) expand1_bestop: shift ±1 e reatribui melhor operador 
function neigh_expand_bestop(p::Matrix{Float64}, borders::Vector{Int}, π::Vector{Int}, n::Int)
    # aplica shift ±1
    b, π2 = neigh_shift1(p, borders, π, n)
    mseg = length(b) - 1
    jseg = rand(1:mseg)
    start_i, end_i = b[jseg], b[jseg+1] - 1
    best_k, best_val = π2[jseg], Inf
    for k in 1:length(π2)
        val = sum(p[i, k] for i in start_i:end_i)
        if val < best_val
            best_val, best_k = val, k
        end
    end
    # troca para manter unicidade
    j2 = findfirst(x->x==best_k, π2)
    π2[j2], π2[jseg] = π2[jseg], π2[j2]
    return b, π2
end

# 5) expand_delta_bestop: shift ±δ e reatribui melhor operador (primeiro, último ou interior)
function neigh_expand_delta_bestop(p::Matrix{Float64}, borders::Vector{Int}, π::Vector{Int}, n::Int; δ_max=4)
    # aplica shift ±δ
    b, π2 = neigh_shift_delta(p, borders, π, n; δ_max=δ_max)
    mseg = length(b) - 1
    jseg = rand(1:mseg)
    start_i, end_i = b[jseg], b[jseg+1] - 1
    best_k, best_val = π2[jseg], Inf
    for k in 1:length(π2)
        val = sum(p[i, k] for i in start_i:end_i)
        if val < best_val
            best_val, best_k = val, k
        end
    end
    # troca para manter unicidade
    j2 = findfirst(x->x==best_k, π2)
    π2[j2], π2[jseg] = π2[jseg], π2[j2]
    return b, π2
end

# lista de vizinhanças de shake 
const NEIGHS = (
    neigh_swap,
    neigh_shift1,
    neigh_shift_delta,
    neigh_expand_bestop,
    neigh_expand_delta_bestop, 
)

# ————————— Busca Local (first-improvement) —————————
function busca_local(p::Matrix{Float64}, sol::Tuple{Vector{Int},Vector{Int}}, n::Int)
    # sol é (borders, π)
    borders, π = sol
    f_best = avalia(p, borders, π)
    improved = true
    # percorre todas as vizinhanças de shake como busca local
    while improved
        improved = false
        for nb in NEIGHS
            new_b, new_π = nb(p, borders, π, n)
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

# ————————— VNS Principal ————————— —————————
function VNS(p::Matrix{Float64}; iter_max::Int=1_000_000)
    n, m = size(p)
    borders, π = sol_inicial_gulosa(p, n, m)
    f_best = avalia(p, borders, π)
    k_max = length(NEIGHS)
    for it in 1:iter_max
        k = 1
        while k ≤ k_max
            candidate = NEIGHS[k](p, borders, π, n) 
            new_b, new_π  = busca_local(p, candidate, n)
            f_new = avalia(p, new_b, new_π)
            if f_new < f_best
                f_best, borders, π = f_new, new_b, new_π
                k = 1
            else
                k += 1
            end
        end
    end
    return borders, π, f_best
end

# ————————— Main —————————
function main()
    arquivo = "testes/tba1.txt"
    println("Lendo instancia: ",arquivo)
    p,n,m = ler_instancia(arquivo)

    best_borders = []
    best_op= []
    bestT = Inf

    #testa 100 amostras do VNS até achar sol ótima
    for i in 1:100
        borders,π,T = VNS(p; iter_max=5000000)                            
        if T < bestT
            best_borders = borders
            best_op= π
            bestT = T
        end
        println("iteração ",i, " T= ", T)
    end

    println("Resultado final: Makespan = ",@sprintf("%.3f",T))
    for i in 1:m
        println("Segmento: ",(best_borders[i], best_borders[i+1]-1), " Operador= ", best_op[i])
    end
end

if abspath(PROGRAM_FILE)==@__FILE__
    main()
end
