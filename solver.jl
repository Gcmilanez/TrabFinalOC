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
            solucao_detalhada = []
            
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
                    push!(solucao_detalhada, (k, inicio, fim, tempo))
                    println("Operador $k: tarefas ($inicio-$fim) → tempo: $(round(tempo, digits=3))")
                end
            end
            
            if !contiguidade_ok
                println("ATENÇÃO: Solução pode não respeitar contiguidade perfeitamente")
            end
            
            return makespan, y_sol, solucao_detalhada, string(status), contiguidade_ok
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
    
    solucao_detalhada = []
    for k in 1:m
        if !isempty(operadores_tarefas[k])
            inicio, fim = minimum(operadores_tarefas[k]), maximum(operadores_tarefas[k])
            push!(solucao_detalhada, (k, inicio, fim, operadores_tempo[k]))
            println("Operador $k: tarefas $(operadores_tarefas[k]) (tempo: $(round(operadores_tempo[k], digits=3)))")
        end
    end
    
    return makespan, operadores_tarefas, operadores_tempo, solucao_detalhada
end

# ————————— HEURÍSTICA MELHORADA COM CONTIGUIDADE —————————
function heuristica_com_contiguidade(p::Matrix{Float64}, n::Int, m::Int)
    println("Executando heurística com contiguidade...")
    
    # Primeiro, resolver sem contiguidade
    makespan_inicial, tarefas_por_op, tempos, _ = heuristica_gulosa(p, n, m)
    
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
    
    solucao_detalhada = []
    for k in 1:m
        if !isempty(nova_atribuicao[k])
            inicio, fim = minimum(nova_atribuicao[k]), maximum(nova_atribuicao[k])
            push!(solucao_detalhada, (k, inicio, fim, novos_tempos[k]))
            println("Operador $k: tarefas ($inicio-$fim) (tempo: $(round(novos_tempos[k], digits=3)))")
        end
    end
    
    return novo_makespan, nova_atribuicao, novos_tempos, solucao_detalhada
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
            
            solucao_detalhada = []
            for k in 1:m
                tarefas = [i for i in 1:n if y_sol[i,k] > 0.5]
                if !isempty(tarefas)
                    tempo = sum(p[i,k] for i in tarefas)
                    inicio, fim = minimum(tarefas), maximum(tarefas)
                    push!(solucao_detalhada, (k, inicio, fim, tempo))
                    println("Operador $k: tarefas $tarefas (tempo: $(round(tempo, digits=3)))")
                end
            end
            
            return makespan, y_sol, solucao_detalhada, string(status)
        end
    end
    
    println("Falha na resolução: $status")
    return nothing
end

# ————————— FUNÇÃO PARA SALVAR RESULTADOS —————————
function salvar_resultados(arquivo_base::String, resultado_gulosa, resultado_contiguidade, resultado_simples, resultado_melhorado, tempo_simples::Int, tempo_melhorado::Int)
    base = splitext(basename(arquivo_base))[1]  # ex: "tba1"
    outdir = "output"
    isdir(outdir) || mkpath(outdir)
    output_file = joinpath(outdir, "solver_$(base)_$(tempo_simples)s_$(tempo_melhorado)s.txt")
    
    open(output_file, "w") do io
        println(io, "=== RESULTADOS SOLVER PARA $(arquivo_base) ===")
        println(io, "Tempo limite simples: $(tempo_simples)s")
        println(io, "Tempo limite melhorado: $(tempo_melhorado)s")
        println(io, "")
        
        # Resumo dos makespans
        println(io, "=== RESUMO MAKESPANS ===")
        if resultado_gulosa !== nothing
            println(io, "Heurística gulosa:          ", @sprintf("%.3f", resultado_gulosa[1]))
        end
        if resultado_contiguidade !== nothing
            println(io, "Heurística c/ contiguidade: ", @sprintf("%.3f", resultado_contiguidade[1]))
        end
        if resultado_simples !== nothing
            println(io, "Solver simples ($(resultado_simples[4])): ", @sprintf("%.3f", resultado_simples[1]))
        end
        if resultado_melhorado !== nothing
            println(io, "Solver melhorado ($(resultado_melhorado[4])): ", @sprintf("%.3f", resultado_melhorado[1]))
            if length(resultado_melhorado) >= 5
                println(io, "Contiguidade respeitada: ", resultado_melhorado[5] ? "SIM" : "NÃO")
            end
        end
        println(io, "")
        
        # Melhor solução encontrada - sempre do modelo melhorado se disponível
        println(io, "=== MELHOR SOLUÇÃO ENCONTRADA MODELO COMPLETO ===")
        if resultado_melhorado !== nothing
            println(io, "Método: Solver melhorado (modelo completo)")
            println(io, "Makespan ótimo: ", @sprintf("%.3f", resultado_melhorado[1]))
            if length(resultado_melhorado) >= 5
                println(io, "Contiguidade respeitada: ", resultado_melhorado[5] ? "SIM" : "NÃO")
            end
            println(io, "Status: $(resultado_melhorado[4])")
            println(io, "")
            
            for (k, inicio, fim, tempo) in resultado_melhorado[3]
                println(io, "Operador $(k): tarefas ($(inicio)–$(fim)) → tempo: ", @sprintf("%.3f", tempo))
            end
        else
            # Fallback caso o modelo melhorado falhe
            melhor_makespan = Inf
            melhor_metodo = ""
            melhor_solucao = nothing
            
            if resultado_gulosa !== nothing && resultado_gulosa[1] < melhor_makespan
                melhor_makespan = resultado_gulosa[1]
                melhor_metodo = "Heurística gulosa"
                melhor_solucao = resultado_gulosa[4]
            end
            
            if resultado_contiguidade !== nothing && resultado_contiguidade[1] < melhor_makespan
                melhor_makespan = resultado_contiguidade[1]
                melhor_metodo = "Heurística com contiguidade"
                melhor_solucao = resultado_contiguidade[4]
            end
            
            if resultado_simples !== nothing && resultado_simples[1] < melhor_makespan
                melhor_makespan = resultado_simples[1]
                melhor_metodo = "Solver simples"
                melhor_solucao = resultado_simples[3]
            end
            
            println(io, "Método: $(melhor_metodo) (fallback)")
            println(io, "Makespan ótimo: ", @sprintf("%.3f", melhor_makespan))
            println(io, "")
            
            if melhor_solucao !== nothing
                for (k, inicio, fim, tempo) in melhor_solucao
                    println(io, "Operador $(k): tarefas ($(inicio)–$(fim)) → tempo: ", @sprintf("%.3f", tempo))
                end
            end
        end
        println(io, "")
        
        # Detalhes de cada método
        println(io, "=== DETALHES POR MÉTODO ===")
        
        if resultado_gulosa !== nothing
            println(io, "")
            println(io, "--- Heurística Gulosa ---")
            println(io, "Makespan: ", @sprintf("%.3f", resultado_gulosa[1]))
            for (k, inicio, fim, tempo) in resultado_gulosa[4]
                println(io, "Operador $(k): tarefas ($(inicio)–$(fim)) → tempo: ", @sprintf("%.3f", tempo))
            end
        end
        
        if resultado_contiguidade !== nothing
            println(io, "")
            println(io, "--- Heurística com Contiguidade ---")
            println(io, "Makespan: ", @sprintf("%.3f", resultado_contiguidade[1]))
            for (k, inicio, fim, tempo) in resultado_contiguidade[4]
                println(io, "Operador $(k): tarefas ($(inicio)–$(fim)) → tempo: ", @sprintf("%.3f", tempo))
            end
        end
        
        if resultado_simples !== nothing
            println(io, "")
            println(io, "--- Solver Simples ---")
            println(io, "Makespan: ", @sprintf("%.3f", resultado_simples[1]))
            println(io, "Status: $(resultado_simples[4])")
            for (k, inicio, fim, tempo) in resultado_simples[3]
                println(io, "Operador $(k): tarefas ($(inicio)–$(fim)) → tempo: ", @sprintf("%.3f", tempo))
            end
        end
        
        if resultado_melhorado !== nothing
            println(io, "")
            println(io, "--- Solver Melhorado ---")
            println(io, "Makespan: ", @sprintf("%.3f", resultado_melhorado[1]))
            println(io, "Status: $(resultado_melhorado[4])")
            if length(resultado_melhorado) >= 5
                println(io, "Contiguidade respeitada: ", resultado_melhorado[5] ? "SIM" : "NÃO")
            end
            for (k, inicio, fim, tempo) in resultado_melhorado[3]
                println(io, "Operador $(k): tarefas ($(inicio)–$(fim)) → tempo: ", @sprintf("%.3f", tempo))
            end
        end
    end
    
    println("Resultados salvos em: ", output_file)
    return output_file
end

# ————————— Main —————————
function main()
    # Parâmetros de entrada
    if length(ARGS) < 1
        println("Uso: julia solver_melhorado.jl <arquivo_base> [tempo_simples] [tempo_melhorado]")
        println("Ex: julia solver_melhorado.jl tba1.txt 120 600")
        exit(1)
    end
    
    # Arquivo de entrada
    input_base = ARGS[1]  # ex: "tba1.txt"
    input_file = joinpath("testes", input_base)
    
    # Tempos limite (opcionais)
    tempo_simples = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 120
    tempo_melhorado = length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 600
    
    println("Lendo instância: $input_file")
    p, n, m = ler_instancia(input_file)
    
    println("n=$n tarefas, m=$m operadores")
    println("Tempo limite simples: $(tempo_simples)s")
    println("Tempo limite melhorado: $(tempo_melhorado)s")
    println("="^50)
    
    # 1. Heurística gulosa (rápida)
    println("\n1. HEURÍSTICA GULOSA")
    resultado_gulosa = heuristica_gulosa(p, n, m)
    
    # 2. Heurística com contiguidade
    println("\n2. HEURÍSTICA COM CONTIGUIDADE")
    resultado_contiguidade = heuristica_com_contiguidade(p, n, m)
    
    # 3. Modelo simples (sem contiguidade)
    println("\n3. SOLVER SIMPLES")
    resultado_simples = resolver_simples(p, n, m; solver_time_limit=tempo_simples)
    
    # 4. Modelo melhorado (com contiguidade)
    println("\n4. SOLVER MELHORADO")
    resultado_melhorado = resolver_melhorado(p, n, m; solver_time_limit=tempo_melhorado)
    
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
    
    # Salvar resultados
    salvar_resultados(input_base, resultado_gulosa, resultado_contiguidade, resultado_simples, resultado_melhorado, tempo_simples, tempo_melhorado)
    
    return resultado_gulosa, resultado_contiguidade, resultado_simples, resultado_melhorado
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end