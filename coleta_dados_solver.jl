#!/usr/bin/env julia
# coleta_dados_solver.jl
# Coleta sistemática de dados com formulação simplificada

using JuMP, GLPK, Printf, Dates, Statistics

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
        return p, n, m
    end
end

# ————————— HEURÍSTICA GULOSA COM COLETA DE DADOS —————————
function heuristica_gulosa_dados(p::Matrix{Float64}, n::Int, m::Int)
    tempo_inicio = time()
    
    # Inicializar
    operadores_tempo = zeros(Float64, m)
    operadores_tarefas = [Int[] for _ in 1:m]
    decisoes_por_tarefa = []
    
    # Para cada tarefa, escolher o operador que resulta no menor makespan
    for i in 1:n
        melhor_op = 1
        melhor_tempo = operadores_tempo[1] + p[i, 1]
        tempos_opcoes = Float64[]
        
        for k in 1:m
            tempo_total = operadores_tempo[k] + p[i, k]
            push!(tempos_opcoes, tempo_total)
            if tempo_total < melhor_tempo
                melhor_tempo = tempo_total
                melhor_op = k
            end
        end
        
        # Atribuir tarefa ao melhor operador
        push!(operadores_tarefas[melhor_op], i)
        operadores_tempo[melhor_op] += p[i, melhor_op]
        
        # Métricas de decisão
        push!(decisoes_por_tarefa, (
            tarefa = i,
            operador_escolhido = melhor_op,
            tempo_escolhido = p[i, melhor_op],
            makespan_resultante = melhor_tempo,
            opcoes_tempo = copy(tempos_opcoes)
        ))
    end
    
    tempo_total = time() - tempo_inicio
    makespan = maximum(operadores_tempo)
    
    # Calcular métricas adicionais
    balanceamento = std(operadores_tempo) / mean(operadores_tempo)  # Coeficiente de variação
    utilizacao = [length(operadores_tarefas[k]) for k in 1:m]
    operadores_usados = count(t -> t > 0, operadores_tempo)
    
    return Dict(
        :tipo => "heuristica_gulosa",
        :makespan => makespan,
        :tempo_execucao => tempo_total,
        :operadores_tempo => operadores_tempo,
        :operadores_tarefas => operadores_tarefas,
        :balanceamento => balanceamento,
        :utilizacao => utilizacao,
        :operadores_usados => operadores_usados,
        :decisoes => decisoes_por_tarefa
    )
end

# ————————— HEURÍSTICA COM CONTIGUIDADE COM DADOS —————————
function heuristica_contiguidade_dados(p::Matrix{Float64}, n::Int, m::Int)
    tempo_inicio = time()
    
    # Primeiro, resolver sem contiguidade
    resultado_gulosa = heuristica_gulosa_dados(p, n, m)
    tarefas_por_op = resultado_gulosa[:operadores_tarefas]
    
    # Reorganizar para garantir contiguidade
    ordem_ops = sort(1:m, by = k -> isempty(tarefas_por_op[k]) ? Inf : minimum(tarefas_por_op[k]))
    
    # Reagrupar tarefas de forma contígua
    nova_atribuicao = [Int[] for _ in 1:m]
    tarefa_atual = 1
    mudancas_realizadas = 0
    
    for k in ordem_ops
        if !isempty(tarefas_por_op[k])
            num_tarefas = length(tarefas_por_op[k])
            tarefas_originais = copy(tarefas_por_op[k])
            
            # Atribuir tarefas sequenciais
            for _ in 1:num_tarefas
                if tarefa_atual <= n
                    push!(nova_atribuicao[k], tarefa_atual)
                    tarefa_atual += 1
                end
            end
            
            # Contar mudanças
            if nova_atribuicao[k] != sort(tarefas_originais)
                mudancas_realizadas += 1
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
    
    tempo_total = time() - tempo_inicio
    novo_makespan = maximum(novos_tempos)
    
    # Métricas de transformação
    perda_qualidade = 100 * (novo_makespan - resultado_gulosa[:makespan]) / resultado_gulosa[:makespan]
    novo_balanceamento = std(novos_tempos) / mean(novos_tempos)
    
    return Dict(
        :tipo => "heuristica_contiguidade",
        :makespan => novo_makespan,
        :tempo_execucao => tempo_total,
        :operadores_tempo => novos_tempos,
        :operadores_tarefas => nova_atribuicao,
        :balanceamento => novo_balanceamento,
        :mudancas_realizadas => mudancas_realizadas,
        :perda_qualidade => perda_qualidade,
        :makespan_original => resultado_gulosa[:makespan]
    )
end

# ————————— SOLVER SIMPLES COM DADOS —————————
function solver_simples_dados(p::Matrix{Float64}, n::Int, m::Int; solver_time_limit=600)
    tempo_inicio = time()
    
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    set_silent(model)
    
    @variable(model, y[i=1:n, k=1:m], Bin)
    @variable(model, T >= 0)
    
    @objective(model, Min, T)
    
    @constraint(model, [i=1:n], sum(y[i,k] for k=1:m) == 1)
    @constraint(model, [k=1:m], sum(p[i,k] * y[i,k] for i=1:n) <= T)
    
    num_vars = num_variables(model)
    num_constrs = num_constraints(model; count_variable_in_set_constraints=false)
    
    optimize!(model)
    
    tempo_solver = time() - tempo_inicio
    status = termination_status(model)
    
    # Forçar limpeza para evitar bug do GLPK
    try
        finalize(model)
    catch
    end
    
    # Forçar limpeza para evitar bug do GLPK
    try
        finalize(model)
    catch
    end
    
    resultado = Dict(
        :tipo => "solver_simples",
        :status => status,
        :tempo_execucao => tempo_solver,
        :num_variaveis => num_vars,
        :num_restricoes => num_constrs,
        :timeout_configurado => solver_time_limit
    )
    
    if status == MOI.OPTIMAL || status == MOI.TIME_LIMIT || status == MOI.FEASIBLE_POINT
        if has_values(model)
            makespan = objective_value(model)
            y_sol = value.(y)
            
            # Extrair solução
            operadores_tempo = zeros(Float64, m)
            operadores_tarefas = [Int[] for _ in 1:m]
            
            for k in 1:m
                tarefas = [i for i in 1:n if y_sol[i,k] > 0.5]
                if !isempty(tarefas)
                    operadores_tarefas[k] = tarefas
                    operadores_tempo[k] = sum(p[i,k] for i in tarefas)
                end
            end
            
            # Verificar contiguidade
            violacoes_contiguidade = 0
            for k in 1:m
                if length(operadores_tarefas[k]) > 1
                    tarefas_ordenadas = sort(operadores_tarefas[k])
                    for i in 1:length(tarefas_ordenadas)-1
                        if tarefas_ordenadas[i+1] - tarefas_ordenadas[i] > 1
                            violacoes_contiguidade += 1
                        end
                    end
                end
            end
            
            # Métricas adicionais
            balanceamento = length(operadores_tempo) > 1 ? std(operadores_tempo) / mean(operadores_tempo) : 0.0
            operadores_usados = count(t -> t > 0, operadores_tempo)
            
            resultado[:makespan] = makespan
            resultado[:operadores_tempo] = operadores_tempo
            resultado[:operadores_tarefas] = operadores_tarefas
            resultado[:violacoes_contiguidade] = violacoes_contiguidade
            resultado[:balanceamento] = balanceamento
            resultado[:operadores_usados] = operadores_usados
            resultado[:solucao_valida] = true
        else
            resultado[:solucao_valida] = false
        end
    else
        resultado[:solucao_valida] = false
    end
    
    return resultado
end

# ————————— SOLVER MELHORADO COM DADOS —————————
function solver_melhorado_dados(p::Matrix{Float64}, n::Int, m::Int; solver_time_limit=3600)
    tempo_inicio = time()
    
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    set_silent(model)
    
    @variable(model, y[i=1:n, k=1:m], Bin)
    @variable(model, T >= 0)
    
    @objective(model, Min, T)
    
    # Restrições básicas
    @constraint(model, [i=1:n], sum(y[i,k] for k=1:m) == 1)
    @constraint(model, [k=1:m], sum(p[i,k] * y[i,k] for i=1:n) <= T)
    
    # Restrições de contiguidade
    num_contiguidade = 0
    for k in 1:m
        for i in 1:n-1
            for j in i+2:n
                @constraint(model, y[i,k] - y[i+1,k] + y[j,k] <= 1)
                num_contiguidade += 1
            end
        end
    end
    
    num_vars = num_variables(model)
    num_constrs = num_constraints(model; count_variable_in_set_constraints=false)
    
    optimize!(model)
    
    tempo_solver = time() - tempo_inicio
    status = termination_status(model)
    
    resultado = Dict(
        :tipo => "solver_melhorado",
        :status => status,
        :tempo_execucao => tempo_solver,
        :num_variaveis => num_vars,
        :num_restricoes => num_constrs,
        :restricoes_contiguidade => num_contiguidade,
        :timeout_configurado => solver_time_limit
    )
    
    if status == MOI.OPTIMAL || status == MOI.TIME_LIMIT || status == MOI.FEASIBLE_POINT
        if has_values(model)
            makespan = objective_value(model)
            y_sol = value.(y)
            
            # Extrair e validar solução
            operadores_tempo = zeros(Float64, m)
            operadores_tarefas = [Int[] for _ in 1:m]
            contiguidade_perfeita = true
            
            for k in 1:m
                tarefas = [i for i in 1:n if y_sol[i,k] > 0.5]
                if !isempty(tarefas)
                    operadores_tarefas[k] = sort(tarefas)
                    operadores_tempo[k] = sum(p[i,k] for i in tarefas)
                    
                    # Verificar contiguidade
                    if length(tarefas) > 1
                        for i in 1:length(operadores_tarefas[k])-1
                            if operadores_tarefas[k][i+1] - operadores_tarefas[k][i] > 1
                                contiguidade_perfeita = false
                                break
                            end
                        end
                    end
                end
            end
            
            balanceamento = length(operadores_tempo) > 1 ? std(operadores_tempo) / mean(operadores_tempo) : 0.0
            operadores_usados = count(t -> t > 0, operadores_tempo)
            
            resultado[:makespan] = makespan
            resultado[:operadores_tempo] = operadores_tempo
            resultado[:operadores_tarefas] = operadores_tarefas
            resultado[:contiguidade_perfeita] = contiguidade_perfeita
            resultado[:balanceamento] = balanceamento
            resultado[:operadores_usados] = operadores_usados
            resultado[:solucao_valida] = true
        else
            resultado[:solucao_valida] = false
        end
    else
        resultado[:solucao_valida] = false
    end
    
    return resultado
end

# ————————— EXECUTAR EXPERIMENTOS PARA UMA INSTÂNCIA —————————
function executar_instancia_completa(instancia::String, p::Matrix{Float64}, n::Int, m::Int)
    println("Processando $instancia (n=$n, m=$m)...")
    tempo_inicio_total = time()
    
    resultados = Dict(
        :instancia => instancia,
        :n => n,
        :m => m,
        :timestamp => Dates.now()
    )
    
    # 1. Heurística gulosa
    print("Heurística gulosa... ")
    resultado_gulosa = heuristica_gulosa_dados(p, n, m)
    println("Makespan: $(round(resultado_gulosa[:makespan], digits=6)) ($(round(resultado_gulosa[:tempo_execucao]*1000, digits=1))ms)")
    resultados[:heuristica_gulosa] = resultado_gulosa
    
    # 2. Heurística com contiguidade
    print("Heurística c/ contiguidade... ")
    resultado_contiguidade = heuristica_contiguidade_dados(p, n, m)
    println("Makespan: $(round(resultado_contiguidade[:makespan], digits=6)) ($(round(resultado_contiguidade[:tempo_execucao]*1000, digits=1))ms)")
    resultados[:heuristica_contiguidade] = resultado_contiguidade
    
    # 3. Solver simples
    print("Solver simples... ")
    resultado_simples = solver_simples_dados(p, n, m; solver_time_limit=600)
    if resultado_simples[:solucao_valida]
        status_msg = resultado_simples[:status] == MOI.OPTIMAL ? "ÓTIMO" : "TIMEOUT"
        println("Makespan: $(round(resultado_simples[:makespan], digits=6)) ($(round(resultado_simples[:tempo_execucao], digits=2))s) [$status_msg]")
    else
        println("$(resultado_simples[:status])")
    end
    resultados[:solver_simples] = resultado_simples
    
    # 4. Solver melhorado
    print("Solver melhorado... ")
    resultado_melhorado = solver_melhorado_dados(p, n, m; solver_time_limit=3600)
    if resultado_melhorado[:solucao_valida]
        status_msg = resultado_melhorado[:status] == MOI.OPTIMAL ? "ÓTIMO" : "TIMEOUT"
        println("Makespan: $(round(resultado_melhorado[:makespan], digits=6)) ($(round(resultado_melhorado[:tempo_execucao], digits=2))s) [$status_msg]")
    else
        println("$(resultado_melhorado[:status])")
    end
    resultados[:solver_melhorado] = resultado_melhorado
    
    resultados[:tempo_total_instancia] = time() - tempo_inicio_total
    println("Tempo total: $(round(resultados[:tempo_total_instancia], digits=2))s\\n")
    
    return resultados
end

# ————————— EXECUTAR TODOS OS EXPERIMENTOS —————————
function executar_experimentos_completos()
    println("=== COLETA DE DADOS - SOLVER SIMPLIFICADO ===")
    println("Data/Hora: $(Dates.now())")
    println()
    
    # CONTROLE DE INSTÂNCIAS AQUI
    instancias = ["tba$i.txt" for i in 1:5]  # 1:5 e 6:10
    
    todos_resultados = []
    tempo_total_experimento = @elapsed begin
        for instancia in instancias
            caminho = "testes/$instancia"
            
            if !isfile(caminho)
                println("Arquivo não encontrado: $caminho")
                continue
            end
            
            # Ler instância
            p, n, m = ler_instancia(caminho)
            
            # Executar todos os métodos
            resultado_instancia = executar_instancia_completa(instancia, p, n, m)
            push!(todos_resultados, resultado_instancia)
            
            # SALVAR PARCIALMENTE após cada instância
            salvar_resultados_parciais(todos_resultados, "backup_parcial.md")
        end
    end
    
    println("Todos os experimentos concluídos!")
    println("Tempo total: $(round(tempo_total_experimento/60, digits=2)) minutos")
    
    return todos_resultados, tempo_total_experimento
end

# ————————— SALVAR RESULTADOS PARCIAIS —————————
function salvar_resultados_parciais(resultados::Vector, arquivo::String)
    if isempty(resultados)
        return
    end
    
    open(arquivo, "w") do io
        println(io, "# Backup Parcial - $(Dates.now())")
        println(io, "")
        println(io, "| Instância | n | m | Gulosa | Contiguidade | Solver Simples | Solver Melhorado |")
        println(io, "|-----------|---|---|--------|--------------|----------------|------------------|")
        
        for resultado in resultados
            inst = resultado[:instancia]
            n, m = resultado[:n], resultado[:m]
            
            gulosa = round(resultado[:heuristica_gulosa][:makespan], digits=6)
            contiguidade = round(resultado[:heuristica_contiguidade][:makespan], digits=6)
            
            simples = resultado[:solver_simples][:solucao_valida] ? 
                      round(resultado[:solver_simples][:makespan], digits=6) : "FALHA"
            
            melhorado = resultado[:solver_melhorado][:solucao_valida] ? 
                        round(resultado[:solver_melhorado][:makespan], digits=6) : "FALHA"
            
            println(io, "| $inst | $n | $m | $gulosa | $contiguidade | $simples | $melhorado |")
        end
    end
end

# ————————— GERAR RELATÓRIO FINAL —————————
function gerar_relatorio_final(resultados::Vector, tempo_total::Float64; arquivo_saida="relatorio_solver_simplificado.md")
    open(arquivo_saida, "w") do io
        println(io, "# Relatório - Formulações Simplificadas para Trabalho Balanceado")
        println(io, "")
        println(io, "**Data:** $(Dates.now())")
        println(io, "**Tempo total:** $(round(tempo_total/60, digits=2)) minutos")
        println(io, "**Instâncias processadas:** $(length(resultados))")
        println(io, "")
        
        # Tabela comparativa principal
        println(io, "## Comparação de Métodos")
        println(io, "")
        println(io, "| Instância | n | m | Heur. Gulosa | Heur. Contig. | Solver Simples | Solver Melhor. | Tempo Total (s) |")
        println(io, "|-----------|---|---|--------------|---------------|----------------|----------------|-----------------|")
        
        for resultado in resultados
            inst = resultado[:instancia]
            n, m = resultado[:n], resultado[:m]
            tempo_total_inst = round(resultado[:tempo_total_instancia], digits=2)
            
            gulosa = round(resultado[:heuristica_gulosa][:makespan], digits=6)
            contiguidade = round(resultado[:heuristica_contiguidade][:makespan], digits=6)
            
            simples = resultado[:solver_simples][:solucao_valida] ? 
                      "$(round(resultado[:solver_simples][:makespan], digits=6))" : 
                      "$(resultado[:solver_simples][:status])"
            
            melhorado = resultado[:solver_melhorado][:solucao_valida] ? 
                        "$(round(resultado[:solver_melhorado][:makespan], digits=6))" : 
                        "$(resultado[:solver_melhorado][:status])"
            
            println(io, "| $inst | $n | $m | $gulosa | $contiguidade | $simples | $melhorado | $tempo_total_inst |")
        end
        println(io, "")
        
        # Análise detalhada por instância
        for resultado in resultados
            instancia = resultado[:instancia]
            n, m = resultado[:n], resultado[:m]
            
            println(io, "## Análise Detalhada: $instancia (n=$n, m=$m)")
            println(io, "")
            
            # Resumo dos resultados
            hg = resultado[:heuristica_gulosa]
            hc = resultado[:heuristica_contiguidade]
            ss = resultado[:solver_simples]
            sm = resultado[:solver_melhorado]
            
            println(io, "### Resumo de Performance")
            println(io, "- **Heurística Gulosa:** $(round(hg[:makespan], digits=6)) ($(round(hg[:tempo_execucao]*1000, digits=1))ms)")
            println(io, "- **Heurística c/ Contiguidade:** $(round(hc[:makespan], digits=6)) ($(round(hc[:tempo_execucao]*1000, digits=1))ms)")
            
            if ss[:solucao_valida]
                println(io, "- **Solver Simples:** $(round(ss[:makespan], digits=6)) ($(round(ss[:tempo_execucao], digits=2))s)")
                if haskey(ss, :violacoes_contiguidade)
                    println(io, "  - Violações de contiguidade: $(ss[:violacoes_contiguidade])")
                end
            else
                println(io, "- **Solver Simples:** FALHA ($(ss[:status]))")
            end
            
            if sm[:solucao_valida]
                println(io, "- **Solver Melhorado:** $(round(sm[:makespan], digits=6)) ($(round(sm[:tempo_execucao], digits=2))s)")
                println(io, "  - Contiguidade perfeita: $(sm[:contiguidade_perfeita])")
            else
                println(io, "- **Solver Melhorado:** FALHA ($(sm[:status]))")
            end
            println(io, "")
            
            # Métricas adicionais
            println(io, "### Métricas Adicionais")
            println(io, "- **Balanceamento (CV):**")
            println(io, "  - Heurística Gulosa: $(round(hg[:balanceamento], digits=4))")
            println(io, "  - Heurística Contiguidade: $(round(hc[:balanceamento], digits=4))")
            if ss[:solucao_valida]
                println(io, "  - Solver Simples: $(round(ss[:balanceamento], digits=4))")
            end
            if sm[:solucao_valida]
                println(io, "  - Solver Melhorado: $(round(sm[:balanceamento], digits=4))")
            end
            
            println(io, "- **Operadores utilizados:**")
            println(io, "  - Heurística Gulosa: $(hg[:operadores_usados])/$m")
            println(io, "  - Heurística Contiguidade: $(count(t -> t > 0, hc[:operadores_tempo]))/$m")
            if ss[:solucao_valida]
                println(io, "  - Solver Simples: $(ss[:operadores_usados])/$m")
            end
            if sm[:solucao_valida]
                println(io, "  - Solver Melhorado: $(sm[:operadores_usados])/$m")
            end
            
            # Impacto da contiguidade
            if haskey(hc, :perda_qualidade)
                println(io, "- **Impacto da contiguidade:** +$(round(hc[:perda_qualidade], digits=2))% no makespan")
                println(io, "- **Mudanças realizadas:** $(hc[:mudancas_realizadas]) operadores")
            end
            
            println(io, "")
            
            # Informações técnicas dos solvers
            println(io, "### Informações Técnicas")
            println(io, "- **Solver Simples:**")
            println(io, "  - Variáveis: $(ss[:num_variaveis])")
            println(io, "  - Restrições: $(ss[:num_restricoes])")
            println(io, "  - Timeout: $(ss[:timeout_configurado])s")
            
            println(io, "- **Solver Melhorado:**")
            println(io, "  - Variáveis: $(sm[:num_variaveis])")
            println(io, "  - Restrições: $(sm[:num_restricoes])")
            if haskey(sm, :restricoes_contiguidade)
                println(io, "  - Restrições de contiguidade: $(sm[:restricoes_contiguidade])")
            end
            println(io, "  - Timeout: $(sm[:timeout_configurado])s")
            println(io, "")
        end
        
        # Informações gerais
        println(io, "## Informações Gerais")
        println(io, "")
        println(io, "### Métodos Avaliados")
        println(io, "1. **Heurística Gulosa:** Atribuição tarefa por tarefa ao operador com menor makespan")
        println(io, "2. **Heurística c/ Contiguidade:** Reorganização da solução gulosa para garantir contiguidade")
        println(io, "3. **Solver Simples:** MILP sem restrições de contiguidade")
        println(io, "4. **Solver Melhorado:** MILP com restrições de contiguidade simplificadas")
        println(io, "")
        println(io, "### Configurações")
        println(io, "- **Solver:** GLPK")
        println(io, "- **Timeout Solver Simples:** 600s")
        println(io, "- **Timeout Solver Melhorado:** 3600")
        println(io, "- **Sistema:** $(Sys.MACHINE)")
        println(io, "- **Julia:** $(VERSION)")
    end
    
    println("Relatório final salvo em: $arquivo_saida")
end

# ————————— FUNÇÃO PRINCIPAL —————————
function main()
    println("Iniciando experimentos com formulações simplificadas...")
    
    # Executar experimentos
    resultados, tempo_total = executar_experimentos_completos()
    
    # Gerar relatório final
    gerar_relatorio_final(resultados, tempo_total)
    
    println("Experimentos concluídos!")
    println("Verifique os arquivos:")
    println("   - relatorio_solver_simplificado.md (relatório final)")
    println("   - backup_parcial.md (backup de segurança)")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end