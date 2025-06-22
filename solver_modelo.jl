#!/usr/bin/env julia
# solver_melhorado.jl
# Formulação para Trabalho Balanceado

using JuMP, GLPK, Printf

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

# ————————— FORMULAÇÃO COM CONTIGUIDADE SIMPLES —————————
function resolver_melhorado(p::Matrix{Float64}, n::Int, m::Int; solver_time_limit=300)
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    
    # Desabilitar saída verbosa do GLPK para evitar spam
    set_silent(model)
    
    # Variáveis principais
    @variable(model, y[i=1:n, k=1:m], Bin)  # y[i,k] = 1 se tarefa i é feita pelo operador k
    @variable(model, T >= 0)  # makespan
    
    # Função objetivo
    @objective(model, Min, T)
    
    # ————————— RESTRIÇÕES BÁSICAS —————————
    
    # (1) Cada tarefa é executada por exatamente um operador
    @constraint(model, [i=1:n], sum(y[i,k] for k=1:m) == 1)
    
    # (2) Makespan: tempo total de cada operador ≤ T  
    @constraint(model, [k=1:m], sum(p[i,k] * y[i,k] for i=1:n) <= T)
    
    # ————————— RESTRIÇÕES DE CONTIGUIDADE —————————
    # se operador k executa tarefa i mas não i+1, 
    # então não pode executar nenhuma tarefa j > i+1
    for k in 1:m
        for i in 1:n-1
            for j in i+2:n
                @constraint(model, y[i,k] - y[i+1,k] + y[j,k] <= 1)
            end
        end
    end
    
    println("Resolvendo modelo melhorado...")
    println("Variáveis: $(num_variables(model))")
    println("Restrições: $(num_constraints(model; count_variable_in_set_constraints=false))")
    
    # Configurar callback para capturar melhor solução durante timeout
    melhor_makespan = Inf
    melhor_solucao = nothing
    
    # Resolver
    optimize!(model)
    
    status = termination_status(model)
    println("Status: $status")
    
    # Verificar se encontrou alguma solução viável (mesmo com timeout)
    if status == MOI.OPTIMAL || status == MOI.TIME_LIMIT || status == MOI.FEASIBLE_POINT
        if has_values(model)
            makespan = objective_value(model)
            y_sol = value.(y)
            
            println("Makespan encontrado: ", @sprintf("%.3f", makespan))
            
            # Verificar se a solução respeita contiguidade
            contiguidade_ok = true
            println("\nSolução:")
            for k in 1:m
                tarefas = [i for i in 1:n if y_sol[i,k] > 0.5]
                if !isempty(tarefas)
                    tempo = sum(p[i,k] for i in tarefas)
                    
                    # Verificar contiguidade
                    if length(tarefas) > 1
                        tarefas_ordenadas = sort(tarefas)
                        for i in 1:length(tarefas_ordenadas)-1
                            if tarefas_ordenadas[i+1] - tarefas_ordenadas[i] > 1
                                contiguidade_ok = false
                                break
                            end
                        end
                    end
                    
                    inicio, fim = minimum(tarefas), maximum(tarefas)
                    println("Operador $k: tarefas ($inicio-$fim) → tempo: $(round(tempo, digits=3))")
                end
            end
            
            if !contiguidade_ok
                println("ATENÇÃO: Solução pode não respeitar contiguidade perfeitamente")
            end
            
            return makespan, y_sol
        else
            println("Modelo não possui valores de solução válidos")
        end
    else
        println("Falha na resolução: $status")
    end
    
    return nothing
end

# ————————— HEURÍSTICA CONSTRUTIVA GULOSA —————————
function heuristica_gulosa(p::Matrix{Float64}, n::Int, m::Int)
    println("Executando heurística gulosa...")
    
    # Inicializar
    operadores_tempo = zeros(Float64, m)
    operadores_tarefas = [Int[] for _ in 1:m]
    
    # Para cada tarefa, escolher o operador que resulta no menor makespan
    for i in 1:n
        melhor_op = 1
        melhor_tempo = operadores_tempo[1] + p[i, 1]
        
        for k in 2:m
            tempo_total = operadores_tempo[k] + p[i, k]
            if tempo_total < melhor_tempo
                melhor_tempo = tempo_total
                melhor_op = k
            end
        end
        
        # Atribuir tarefa ao melhor operador
        push!(operadores_tarefas[melhor_op], i)
        operadores_tempo[melhor_op] += p[i, melhor_op]
    end
    
    makespan = maximum(operadores_tempo)
    
    println("Makespan heurística: ", @sprintf("%.3f", makespan))
    println("\nSolução heurística:")
    for k in 1:m
        if !isempty(operadores_tarefas[k])
            println("Operador $k: tarefas $(operadores_tarefas[k]) (tempo: $(round(operadores_tempo[k], digits=3)))")
        end
    end
    
    return makespan, operadores_tarefas, operadores_tempo
end

# ————————— HEURÍSTICA MELHORADA COM CONTIGUIDADE —————————
function heuristica_com_contiguidade(p::Matrix{Float64}, n::Int, m::Int)
    println("Executando heurística com contiguidade...")
    
    # Primeiro, resolver sem contiguidade
    makespan_inicial, tarefas_por_op, tempos = heuristica_gulosa(p, n, m)
    
    # Reorganizar para garantir contiguidade
    # Ordenar operadores por início médio de suas tarefas
    ordem_ops = sort(1:m, by = k -> isempty(tarefas_por_op[k]) ? Inf : minimum(tarefas_por_op[k]))
    
    # Reagrupar tarefas de forma contígua
    nova_atribuicao = [Int[] for _ in 1:m]
    tarefa_atual = 1
    
    for k in ordem_ops
        if !isempty(tarefas_por_op[k])
            num_tarefas = length(tarefas_por_op[k])
            # Atribuir tarefas sequenciais
            for _ in 1:num_tarefas
                if tarefa_atual <= n
                    push!(nova_atribuicao[k], tarefa_atual)
                    tarefa_atual += 1
                end
            end
        end
    end
    
    # Calcular novo makespan
    novos_tempos = zeros(Float64, m)
    for k in 1:m
        if !isempty(nova_atribuicao[k])
            novos_tempos[k] = sum(p[i, k] for i in nova_atribuicao[k])
        end
    end
    
    novo_makespan = maximum(novos_tempos)
    
    println("Makespan com contiguidade: ", @sprintf("%.3f", novo_makespan))
    println("\nSolução com contiguidade:")
    for k in 1:m
        if !isempty(nova_atribuicao[k])
            inicio, fim = minimum(nova_atribuicao[k]), maximum(nova_atribuicao[k])
            println("Operador $k: tarefas ($inicio-$fim) (tempo: $(round(novos_tempos[k], digits=3)))")
        end
    end
    
    return novo_makespan, nova_atribuicao, novos_tempos
end

# ————————— MODELO SIMPLES (SEM CONTIGUIDADE) —————————
function resolver_simples(p::Matrix{Float64}, n::Int, m::Int; solver_time_limit=60)
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    set_silent(model)  # Reduzir output
    
    @variable(model, y[i=1:n, k=1:m], Bin)
    @variable(model, T >= 0)
    
    @objective(model, Min, T)
    
    @constraint(model, [i=1:n], sum(y[i,k] for k=1:m) == 1)
    @constraint(model, [k=1:m], sum(p[i,k] * y[i,k] for i=1:n) <= T)
    
    println("Resolvendo modelo simples (sem contiguidade)...")
    optimize!(model)
    
    status = termination_status(model)
    
    # Aceitar soluções mesmo com timeout
    if status == MOI.OPTIMAL || status == MOI.TIME_LIMIT || status == MOI.FEASIBLE_POINT
        if has_values(model)
            makespan = objective_value(model)
            y_sol = value.(y)
            
            println("Makespan (sem contiguidade): ", @sprintf("%.3f", makespan))
            println("Status: $status")
            
            for k in 1:m
                tarefas = [i for i in 1:n if y_sol[i,k] > 0.5]
                if !isempty(tarefas)
                    tempo = sum(p[i,k] for i in tarefas)
                    println("Operador $k: tarefas $tarefas (tempo: $(round(tempo, digits=3)))")
                end
            end
            
            return makespan, y_sol
        end
    end
    
    println("Falha na resolução: $status")
    return nothing
end

# ————————— Main —————————
function main()
    # Você pode mudar o arquivo aqui
    arquivo = "testes/tba1.txt" 
    
    println("Lendo instância: $arquivo")
    p, n, m = ler_instancia(arquivo)
    
    println("n=$n tarefas, m=$m operadores")
    println("="^50)
    
    # 1. Heurística gulosa (rápida)
    println("\n1. HEURÍSTICA GULOSA")
    resultado_gulosa = heuristica_gulosa(p, n, m)
    
    # 2. Heurística com contiguidade
    println("\n2. HEURÍSTICA COM CONTIGUIDADE")
    resultado_contiguidade = heuristica_com_contiguidade(p, n, m)
    
    # 3. Modelo simples (sem contiguidade)
    println("\n3. SOLVER SIMPLES")
    resultado_simples = resolver_simples(p, n, m; solver_time_limit=120)
    
    # 4. Modelo melhorado (com contiguidade)
    println("\n4. SOLVER MELHORADO")
    resultado_melhorado = resolver_melhorado(p, n, m; solver_time_limit=850)
    
    println("\n" * "="^50)
    println("RESUMO DOS RESULTADOS:")
    if resultado_gulosa !== nothing
        println("Heurística gulosa: $(round(resultado_gulosa[1], digits=3))")
    end
    if resultado_contiguidade !== nothing
        println("Heurística c/ contiguidade: $(round(resultado_contiguidade[1], digits=3))")
    end
    if resultado_simples !== nothing
        println("Solver simples: $(round(resultado_simples[1], digits=3))")
    end
    if resultado_melhorado !== nothing
        println("Solver melhorado: $(round(resultado_melhorado[1], digits=3))")
    end
    
    return resultado_gulosa, resultado_contiguidade, resultado_simples, resultado_melhorado
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end