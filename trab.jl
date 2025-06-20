#!/usr/bin/env julia
# trab.jl
# Implementação limpa da heurística VNS para o problema Trabalho Balanceado

using Random
using Dates

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
    Tmax = 0.0
    @inbounds for j in 1:m
        s = 0.0
        for i in borders[j]:(borders[j+1]-1)
            s += p[i, π[j]]
        end
        Tmax = max(Tmax, s)
    end
    return Tmax
end

# ————————— Solução Inicial Gulosa —————————
function sol_inicial_gulosa(p::Matrix{Float64}, n::Int, m::Int)
    # Partição contígua por número de tarefas (segmentos podem ter qualquer tamanho)
    borders = [1]
    base = div(n, m)
    rem = n % m
    idx = 1
    for j in 1:m-1
        sz = base + (j <= rem ? 1 : 0)
        idx += sz
        push!(borders, idx)
    end
    push!(borders, n+1)

    # Monta matriz de custos C[j,k]
    C = zeros(Float64, m, m)
    for j in 1:m, k in 1:m, i in borders[j]:(borders[j+1]-1)
        C[j, k] += p[i, k]
    end

    # Matching guloso para permutação inicial π
    π = zeros(Int, m)
    segs = collect(1:m)
    works = collect(1:m)
    while !isempty(segs)
        best, bj, bk = Inf, 0, 0
        for j in segs, k in works
            if C[j, k] < best
                best, bj, bk = C[j, k], j, k
            end
        end
        π[bj] = bk
        filter!(x -> x != bj, segs)
        filter!(x -> x != bk, works)
    end

    # Imprime segmentos iniciais
    println("Segmentos iniciais:")
    for j in 1:m
        println("  Segmento $j: [$(borders[j]), $(borders[j+1]-1)]")
    end
    println("Makespan inicial = ", avalia(p, borders, π))
    println("Operadores= ", π)
    return borders, π
end

# ————————— Vizinhanças (shakes) —————————
# N₁: swap simples de dois operadores
function neigh_swap_ops(borders::Vector{Int}, π::Vector{Int})
    π2 = copy(π)
    i, j = rand(1:length(π), 2)
    π2[i], π2[j] = π2[j], π2[i]
    return borders, π2
end

# N₂: desloca uma fronteira em ±1
function neigh_shift_border(borders::Vector{Int}, π::Vector{Int}, n::Int)
    b = copy(borders)
    j = rand(2:length(b)-1)
    dir = rand(Bool) ? 1 : -1
    if b[j] + dir > b[j-1] + 1 && b[j] + dir < b[j+1]
        b[j] += dir
    end
    return b, π
end

# N₃: swap de dois blocos adjacentes de tarefas (tamanho = 2)
function neigh_block_swap(borders::Vector{Int}, π::Vector{Int})
    # troca duas fronteiras para permutar blocos
    b = copy(borders)
    m = length(b)-1
    # escolhe blocos j,k e troca posições inteiras
    j, k = rand(1:m), rand(1:m)
    while j == k
        k = rand(1:m)
    end
    # swap dos cortes entre b[j] e b[j+1]
    segj = borders[j]:(borders[j+1]-1)
    segk = borders[k]:(borders[k+1]-1)
    # apenas permuta operadores para ilustrar block-swap
    π2 = copy(π)
    π2[j], π2[k] = π2[k], π2[j]
    return b, π2
end

# N₄: inversão de um sub-bloco de tarefas no particionamento
function neigh_reverse_block(borders::Vector{Int}, π::Vector{Int})
    b = copy(borders)
    m = length(b)-1
    # escolhe dois segmentos contíguos e inverte ordem das fronteiras internas
    j = rand(2:length(b)-2)
    # inverte parte pequena no particionamento
    b[j], b[j+1] = b[j+1], b[j]
    return b, π
end

# Lista de vizinhanças
const SHAKES = (
    neigh_swap_ops,
    neigh_shift_border,
    neigh_block_swap,
    neigh_reverse_block
)

# ————————— Busca Local (first-improvement) —————————
function busca_local(p::Matrix{Float64}, sol::Tuple{Vector{Int},Vector{Int}}, n::Int)
    borders, π = sol
    f_best = avalia(p, borders, π)
    improved = true
    while improved
        improved = false
        best_delta = 0.0
        best_b, best_π = borders, π
        for nb in ((b,πv)->neigh_swap_ops(b,πv), (b,πv)->neigh_shift_border(b,πv,n))
            new_b, new_π = nb(borders, π)
            f_new = avalia(p, new_b, new_π)
            delta = f_best - f_new
            if delta > best_delta
                best_delta, best_b, best_π = delta, new_b, new_π
            end
        end
        if best_delta > 0
            borders, π, f_best = best_b, best_π, f_best - best_delta
            improved = true
        end
    end
    return borders, π
end

# ————————— VNS Principal —————————
function VNS(p::Matrix{Float64}; iter_max::Int=500, k_max::Int=2)
    n, m = size(p)
    borders, π = sol_inicial_gulosa(p,n,m)
    f_best = avalia(p,borders,π)
    for iter in 1:iter_max
        k = 1
        while k ≤ k_max
            # escolhe shake k em todas as N₁..N₄ (mod k)
            fnc = SHAKES[mod1(k, length(SHAKES))]
            candidate = fnc===neigh_shift_border ? fnc(borders,π,n) : fnc(borders,π)
            new_b, new_π = busca_local(p, candidate, n)
            f_new = avalia(p,new_b,new_π)
            if f_new < f_best
                println("T= ", f_new)
                borders, π, f_best = new_b, new_π, f_new; k = 1
            else
                k += 1
            end
        end
    end
    return borders, π, f_best
end

# ————————— Função Principal com Time Limit via ARGs —————————
function main()

    arquivo = "testes/tba5.txt"
    iter = 1000000000
    k = 4
    exec_start = Dates.now()
    println("Início da execução: ", Dates.format(exec_start, "dd/mm/yyyy HH:MM:SS"))

    println("Lendo instância de '$arquivo'...")
    p, n, m = ler_instancia(arquivo)
    borders, π, T = VNS(p; iter_max=iter, k_max=k)

    println("Numero maximo de iterações= ", iter)
    println("n= $n, m= $m")
    println("Segmentos: ", [(borders[j], borders[j+1]-1) for j in 1:length(π)])
    println("Permutação operadores: ", π)
    println("Makespan T = $T")
    
    exec_final = Dates.now()
    println("Final da execução: ", Dates.format(exec_final, "dd/mm/yyyy HH:MM:SS"))

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
