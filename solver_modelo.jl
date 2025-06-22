#!/usr/bin/env julia
# solver_modelo.jl
# Formulação matemática para Trabalho Balanceado usando JuMP

using JuMP, GLPK, Printf

# ————————— Leitura da instância (mesma função do VNS) —————————
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
        return p, n, m
    end
end

# ————————— Modelo Matemático —————————
function resolver_com_solver(p::Matrix{Float64}, n::Int, m::Int; solver_time_limit=300)
    # Criar modelo
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    
    # Variáveis de decisão
    @variable(model, x[i=1:n, s=1:m], Bin)  # x[i,s] = 1 se tarefa i pertence ao segmento s
    @variable(model, z[s=1:m, k=1:m], Bin)  # z[s,k] = 1 se segmento s é atribuído ao operador k
    @variable(model, w[i=1:n, s=1:m, k=1:m], Bin)  # variável auxiliar para linearização
    @variable(model, T >= 0)  # makespan
    
    # Função objetivo: minimizar makespan
    @objective(model, Min, T)
    
    # ————————— RESTRIÇÕES —————————
    
    # (1) Cada tarefa pertence a exatamente um segmento
    @constraint(model, [i=1:n], sum(x[i,s] for s=1:m) == 1)
    
    # (2) Cada segmento recebe exatamente um operador
    @constraint(model, [s=1:m], sum(z[s,k] for k=1:m) == 1)
    
    # (3) Cada operador atua em apenas um segmento
    @constraint(model, [k=1:m], sum(z[s,k] for s=1:m) == 1)
    
    # (4) Relacionamento entre tarefas, segmentos e operadores
    # w[i,s,k] ≤ x[i,s]
    @constraint(model, [i=1:n, s=1:m, k=1:m], w[i,s,k] <= x[i,s])
    # w[i,s,k] ≤ z[s,k]  
    @constraint(model, [i=1:n, s=1:m, k=1:m], w[i,s,k] <= z[s,k])
    # w[i,s,k] ≥ x[i,s] + z[s,k] - 1
    @constraint(model, [i=1:n, s=1:m, k=1:m], w[i,s,k] >= x[i,s] + z[s,k] - 1)
    
    # (5) Cálculo do tempo total por segmento (limitado pelo makespan)
    @constraint(model, [s=1:m], 
        sum(sum(p[i,k] * w[i,s,k] for k=1:m) for i=1:n) <= T)
    
    # (6) Definição do tempo total (redundante mas pode ajudar o solver)
    @constraint(model, T >= 0)
    
    # (7) Segmentos contíguos (sem lacunas)
    # Definir variáveis auxiliares para os pontos de corte
    @variable(model, b[s=1:m+1], Int)  # b[s] = índice da primeira tarefa do segmento s
    
    # Fixar bordas
    @constraint(model, b[1] == 1)      # primeiro segmento começa na tarefa 1
    @constraint(model, b[m+1] == n+1)  # último "segmento" termina após tarefa n
    
    # Ordenação das bordas: b[s] ≤ b[s+1]
    @constraint(model, [s=1:m], b[s] <= b[s+1])
    
    # Ligação com as tarefas: x[i,s] = 1 ⟺ b[s] ≤ i ≤ b[s+1]-1
    # Como isso não é linear, vamos usar:
    # Se x[i,s] = 1, então b[s] ≤ i ≤ b[s+1]-1
    @constraint(model, [i=1:n, s=1:m], 
        b[s] <= i + (1 - x[i,s]) * n)
    @constraint(model, [i=1:n, s=1:m], 
        i <= b[s+1] - 1 + (1 - x[i,s]) * n)
    
    # ————————— RESOLVER —————————
    println("Resolvendo modelo com GLPK...")
    println("Variáveis: $(num_variables(model))")
    println("Restrições: $(num_constraints(model; count_variable_in_set_constraints=false))")
    
    optimize!(model)
    
    # ————————— RESULTADOS —————————
    status = termination_status(model)
    println("Status: $status")
    
    if status == MOI.OPTIMAL || status == MOI.TIME_LIMIT
        makespan = objective_value(model)
        println("Makespan encontrado: ", @sprintf("%.3f", makespan))
        
        # Extrair solução
        x_sol = value.(x)
        z_sol = value.(z)
        b_sol = value.(b)
        
        # Mostrar segmentos e operadores
        println("\nSolução:")
        for s in 1:m
            # Encontrar tarefas do segmento s
            tarefas = [i for i in 1:n if x_sol[i,s] > 0.5]
            # Encontrar operador do segmento s
            operador = findfirst(k -> z_sol[s,k] > 0.5, 1:m)
            
            if !isempty(tarefas)
                inicio, fim = minimum(tarefas), maximum(tarefas)
                tempo_seg = sum(p[i, operador] for i in tarefas)
                println("Segmento $s: tarefas ($inicio, $fim) → Operador $operador (tempo: $(tempo_seg))")
            end
        end
        
        return makespan, x_sol, z_sol, b_sol
    else
        println("Não foi possível encontrar solução ótima.")
        println("Status: $status")
        return nothing
    end
end

# ————————— Versão simplificada (sem contiguidade explícita) —————————
function resolver_simplificado(p::Matrix{Float64}, n::Int, m::Int; solver_time_limit=300)
    # Modelo mais simples: apenas atribuição tarefa→operador
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    
    # Variáveis: y[i,k] = 1 se tarefa i é feita pelo operador k
    @variable(model, y[i=1:n, k=1:m], Bin)
    @variable(model, T >= 0)  # makespan
    
    # Objetivo
    @objective(model, Min, T)
    
    # Cada tarefa é feita por exatamente um operador
    @constraint(model, [i=1:n], sum(y[i,k] for k=1:m) == 1)
    
    # Makespan: tempo de cada operador ≤ T
    @constraint(model, [k=1:m], sum(p[i,k] * y[i,k] for i=1:n) <= T)
    
    println("Resolvendo modelo simplificado...")
    optimize!(model)
    
    status = termination_status(model)
    if status == MOI.OPTIMAL
        makespan = objective_value(model)
        y_sol = value.(y)
        
        println("Makespan (sem contiguidade): ", @sprintf("%.3f", makespan))
        
        # Mostrar atribuições
        for k in 1:m
            tarefas = [i for i in 1:n if y_sol[i,k] > 0.5]
            tempo = isempty(tarefas) ? 0.0 : sum(p[i,k] for i in tarefas)
            if !isempty(tarefas)  # só mostra operadores que receberam tarefas
                println("Operador $k: tarefas $tarefas (tempo: $tempo)")
            end
        end
        
        return makespan, y_sol
    else
        println("Falha na resolução: $status")
        return nothing
    end
end

# ————————— Main —————————
function main()
    arquivo = "testes/tba9.txt"
    println("Lendo instância: $arquivo")
    p, n, m = ler_instancia(arquivo)
    
    println("n=$n tarefas, m=$m operadores")
    println()
    
    # Tentar primeiro o modelo simplificado (sem contiguidade)
    println("=== MODELO SIMPLIFICADO (sem contiguidade) ===")
    resultado_simples = resolver_simplificado(p, n, m; solver_time_limit=60)
    
    println()
    println("=== MODELO COMPLETO (com contiguidade) ===")
    # Depois o modelo completo
    resultado_completo = resolver_com_solver(p, n, m; solver_time_limit=3600)
    
    return resultado_simples, resultado_completo
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end