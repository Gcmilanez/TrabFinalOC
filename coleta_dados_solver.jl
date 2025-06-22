#!/usr/bin/env julia
# coleta_dados_solver.jl
# Coleta sistemática de dados do Solver para Trabalho Balanceado

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

# ————————— Solver com coleta detalhada de dados —————————
function resolver_instancia_completo(p::Matrix{Float64}, n::Int, m::Int, instancia_nome::String; solver_time_limit=18000)
    println("Iniciando resolução de $instancia_nome...")
    tempo_inicio_total = time()
    
    resultado = Dict(
        :instancia => instancia_nome,
        :n => n,
        :m => m,
        :tempo_inicio => Dates.now(),
        :solver_timeout => solver_time_limit
    )
    
    # ————————— BOUND INFERIOR (modelo relaxado) —————————
    println("Calculando bound inferior (modelo sem contiguidade)...")
    tempo_bound = @elapsed begin
        model_bound = Model(GLPK.Optimizer)
        set_time_limit_sec(model_bound, 300)  # 5 min para bound
        
        @variable(model_bound, y[i=1:n, k=1:m], Bin)
        @variable(model_bound, T_bound >= 0)
        @objective(model_bound, Min, T_bound)
        @constraint(model_bound, [i=1:n], sum(y[i,k] for k=1:m) == 1)
        @constraint(model_bound, [k=1:m], sum(p[i,k] * y[i,k] for i=1:n) <= T_bound)
        
        optimize!(model_bound)
        
        if termination_status(model_bound) == MOI.OPTIMAL
            resultado[:bound_inferior] = objective_value(model_bound)
            resultado[:tempo_bound] = tempo_bound
            
            # Extração da solução relaxada
            y_sol = value.(y)
            atribuicoes_relaxadas = []
            for k in 1:m
                tarefas_k = [i for i in 1:n if y_sol[i,k] > 0.5]
                if !isempty(tarefas_k)
                    tempo_k = sum(p[i,k] for i in tarefas_k)
                    push!(atribuicoes_relaxadas, (operador=k, tarefas=tarefas_k, tempo=tempo_k))
                end
            end
            resultado[:solucao_relaxada] = atribuicoes_relaxadas
            println("Bound inferior: $(round(resultado[:bound_inferior], digits=6)) ($(round(tempo_bound, digits=2))s)")
        else
            resultado[:bound_inferior] = nothing
            resultado[:tempo_bound] = tempo_bound
            println("Falha no cálculo do bound ($(round(tempo_bound, digits=2))s)")
        end
    end
    
    # ————————— MODELO COMPLETO (com contiguidade) —————————
    println("Resolvendo modelo completo (timeout: $(solver_time_limit/3600)h)...")
    tempo_inicio_modelo = time()
    
    model = Model(GLPK.Optimizer)
    set_time_limit_sec(model, solver_time_limit)
    
    # Variáveis de decisão
    @variable(model, x[i=1:n, s=1:m], Bin)  # x[i,s] = 1 se tarefa i pertence ao segmento s
    @variable(model, z[s=1:m, k=1:m], Bin)  # z[s,k] = 1 se segmento s é atribuído ao operador k
    @variable(model, w[i=1:n, s=1:m, k=1:m], Bin)  # variável auxiliar para linearização
    @variable(model, T >= 0)  # makespan
    @variable(model, b[s=1:m+1], Int)  # pontos de corte
    
    # Função objetivo
    @objective(model, Min, T)
    
    # Restrições
    @constraint(model, [i=1:n], sum(x[i,s] for s=1:m) == 1)
    @constraint(model, [s=1:m], sum(z[s,k] for k=1:m) == 1)
    @constraint(model, [k=1:m], sum(z[s,k] for s=1:m) == 1)
    @constraint(model, [i=1:n, s=1:m, k=1:m], w[i,s,k] <= x[i,s])
    @constraint(model, [i=1:n, s=1:m, k=1:m], w[i,s,k] <= z[s,k])
    @constraint(model, [i=1:n, s=1:m, k=1:m], w[i,s,k] >= x[i,s] + z[s,k] - 1)
    @constraint(model, [s=1:m], sum(sum(p[i,k] * w[i,s,k] for k=1:m) for i=1:n) <= T)
    @constraint(model, b[1] == 1)
    @constraint(model, b[m+1] == n+1)
    @constraint(model, [s=1:m], b[s] <= b[s+1])
    @constraint(model, [i=1:n, s=1:m], b[s] <= i + (1 - x[i,s]) * n)
    @constraint(model, [i=1:n, s=1:m], i <= b[s+1] - 1 + (1 - x[i,s]) * n)
    
    # Informações do modelo
    num_vars = num_variables(model)
    num_constrs = num_constraints(model; count_variable_in_set_constraints=false)
    println("Modelo: $num_vars variáveis, $num_constrs restrições")
    
    resultado[:num_variaveis] = num_vars
    resultado[:num_restricoes] = num_constrs
    
    # Resolver
    optimize!(model)
    
    tempo_solver = time() - tempo_inicio_modelo
    status = termination_status(model)
    
    resultado[:status_solver] = status
    resultado[:tempo_solver] = tempo_solver
    resultado[:tempo_fim] = Dates.now()
    
    # ————————— ANÁLISE DOS RESULTADOS —————————
    if status == MOI.OPTIMAL
        println("SOLUÇÃO ÓTIMA encontrada!")
        resultado[:makespan_otimo] = objective_value(model)
        resultado[:gap_final] = 0.0
        
        # Extrair solução detalhada
        x_sol = value.(x)
        z_sol = value.(z)
        b_sol = value.(b)
        
        segmentos = []
        operadores = []
        tempos_segmentos = []
        
        for s in 1:m
            tarefas = [i for i in 1:n if x_sol[i,s] > 0.5]
            if !isempty(tarefas)
                inicio, fim = minimum(tarefas), maximum(tarefas)
                operador = findfirst(k -> z_sol[s,k] > 0.5, 1:m)
                tempo_seg = sum(p[i, operador] for i in tarefas)
                
                push!(segmentos, (inicio=inicio, fim=fim, tarefas=tarefas))
                push!(operadores, operador)
                push!(tempos_segmentos, tempo_seg)
            end
        end
        
        resultado[:segmentos] = segmentos
        resultado[:operadores] = operadores
        resultado[:tempos_segmentos] = tempos_segmentos
        resultado[:pontos_corte] = Int.(round.(b_sol))
        
        # Verificação da solução
        makespan_verificado = maximum(tempos_segmentos)
        resultado[:makespan_verificado] = makespan_verificado
        
    elseif status == MOI.TIME_LIMIT
        println("TIMEOUT atingido!")
        try
            melhor_solucao = objective_value(model)
            resultado[:melhor_solucao_timeout] = melhor_solucao
            
            if resultado[:bound_inferior] !== nothing
                gap = 100 * (melhor_solucao - resultado[:bound_inferior]) / resultado[:bound_inferior]
                resultado[:gap_timeout] = gap
                println("Melhor solução: $(round(melhor_solucao, digits=6)), Gap: $(round(gap, digits=2))%")
            else
                println("Melhor solução: $(round(melhor_solucao, digits=6))")
            end
        catch
            println("Nenhuma solução factível encontrada no timeout")
            resultado[:melhor_solucao_timeout] = nothing
        end
        
    else
        println("Falha na resolução: $status")
        resultado[:erro] = string(status)
    end
    
    resultado[:tempo_total] = time() - tempo_inicio_total
    
    println("Tempo total: $(round(resultado[:tempo_total], digits=2))s")
    println()
    
    return resultado
end

# ————————— Execução dos experimentos —————————
function executar_experimentos_solver()
    println("=== COLETA DE DADOS - SOLVER (GLPK) ===")
    println("Data/Hora: $(Dates.now())")
    println("Configuração: Timeout 5h por instância")
    println()
    
    instancias = ["tba$i.txt" for i in 1:2]    # numero de arquivos a serem rodados todos -> 1:10
    resultados = []
    
    tempo_total_experimento = @elapsed begin
        for instancia in instancias
            caminho = "testes/$instancia"
            
            if !isfile(caminho)
                println("Arquivo não encontrado: $caminho")
                continue
            end
            
            # Ler instância
            p, n, m = ler_instancia(caminho)
            println("$instancia: n=$n tarefas, m=$m operadores")
            
            # Resolver
            resultado = resolver_instancia_completo(p, n, m, instancia; solver_time_limit=18000)
            push!(resultados, resultado)
        end
    end
    
    println("Todos os experimentos concluídos!")
    println("Tempo total: $(round(tempo_total_experimento/3600, digits=2)) horas")
    
    return resultados, tempo_total_experimento
end

# ————————— Geração de relatório —————————
function gerar_relatorio_solver(resultados::Vector, tempo_total::Float64; arquivo_saida="relatorio_solver.md")
    open(arquivo_saida, "w") do io
        println(io, "# Relatório de Experimentos - Solver (GLPK)")
        println(io, "")
        println(io, "**Data:** $(Dates.now())")
        println(io, "**Solver:** GLPK (GNU Linear Programming Kit)")
        println(io, "**Timeout:** 5 horas por instância")
        println(io, "**Tempo total do experimento:** $(round(tempo_total/3600, digits=2)) horas")
        println(io, "")
        
        # Resumo executivo
        println(io, "## Resumo Executivo")
        println(io, "")
        otimas = count(r -> get(r, :status_solver, nothing) == MOI.OPTIMAL for r in resultados)
        timeouts = count(r -> get(r, :status_solver, nothing) == MOI.TIME_LIMIT for r in resultados)
        falhas = length(resultados) - otimas - timeouts
        
        println(io, "- **Instâncias processadas:** $(length(resultados))")
        println(io, "- **Soluções ótimas:** $otimas")
        println(io, "- **Timeouts:** $timeouts")
        println(io, "- **Falhas:** $falhas")
        println(io, "")
        
        # Tabela principal
        println(io, "## Resultados por Instância")
        println(io, "")
        println(io, "| Instância | n | m | Bound Inferior | Status | Makespan | Gap (%) | Tempo Solver (s) | Vars | Restrições |")
        println(io, "|-----------|---|---|----------------|--------|----------|---------|------------------|------|------------|")
        
        for resultado in resultados
            instancia = resultado[:instancia]
            n, m = resultado[:n], resultado[:m]
            bound = resultado[:bound_inferior]
            status = resultado[:status_solver]
            
            makespan = if status == MOI.OPTIMAL
                resultado[:makespan_otimo]
            elseif status == MOI.TIME_LIMIT && haskey(resultado, :melhor_solucao_timeout)
                resultado[:melhor_solucao_timeout]
            else
                nothing
            end
            
            gap = if haskey(resultado, :gap_timeout)
                "$(round(resultado[:gap_timeout], digits=2))"
            elseif status == MOI.OPTIMAL
                "0.00"
            else
                "N/A"
            end
            
            tempo = round(resultado[:tempo_solver], digits=2)
            vars = resultado[:num_variaveis]
            restrs = resultado[:num_restricoes]
            
            bound_str = bound === nothing ? "N/A" : "$(round(bound, digits=6))"
            makespan_str = makespan === nothing ? "N/A" : "$(round(makespan, digits=6))"
            
            println(io, "| $instancia | $n | $m | $bound_str | $status | $makespan_str | $gap | $tempo | $vars | $restrs |")
        end
        println(io, "")
        
        # Detalhes por instância
        for resultado in resultados
            instancia = resultado[:instancia]
            n, m = resultado[:n], resultado[:m]
            
            println(io, "## Detalhes: $instancia (n=$n, m=$m)")
            println(io, "")
            
            # Informações gerais
            println(io, "### Informações Gerais")
            println(io, "- **Início:** $(resultado[:tempo_inicio])")
            println(io, "- **Fim:** $(resultado[:tempo_fim])")
            println(io, "- **Timeout configurado:** $(resultado[:solver_timeout])s ($(round(resultado[:solver_timeout]/3600, digits=1))h)")
            println(io, "- **Variáveis:** $(resultado[:num_variaveis])")
            println(io, "- **Restrições:** $(resultado[:num_restricoes])")
            println(io, "")
            
            # Bound inferior
            println(io, "### Bound Inferior (Modelo Relaxado)")
            if resultado[:bound_inferior] !== nothing
                println(io, "- **Valor:** $(resultado[:bound_inferior])")
                println(io, "- **Tempo de cálculo:** $(round(resultado[:tempo_bound], digits=2))s")
                println(io, "- **Solução relaxada:**")
                for atrib in resultado[:solucao_relaxada]
                    println(io, "  - Operador $(atrib[:operador]): tarefas $(atrib[:tarefas]) (tempo: $(round(atrib[:tempo], digits=6)))")
                end
            else
                println(io, "- **Status:** Falha no cálculo")
                println(io, "- **Tempo tentativa:** $(round(resultado[:tempo_bound], digits=2))s")
            end
            println(io, "")
            
            # Resultado do modelo completo
            println(io, "### Modelo Completo")
            println(io, "- **Status:** $(resultado[:status_solver])")
            println(io, "- **Tempo de resolução:** $(round(resultado[:tempo_solver], digits=2))s")
            
            if resultado[:status_solver] == MOI.OPTIMAL
                println(io, "- **Makespan ótimo:** $(resultado[:makespan_otimo])")
                println(io, "- **Verificação:** $(resultado[:makespan_verificado])")
                println(io, "")
                println(io, "#### Solução Ótima")
                for (i, seg) in enumerate(resultado[:segmentos])
                    op = resultado[:operadores][i]
                    tempo = resultado[:tempos_segmentos][i]
                    println(io, "- **Segmento $i:** tarefas ($(seg[:inicio]), $(seg[:fim])) → Operador $op (tempo: $(round(tempo, digits=6)))")
                end
                println(io, "")
                println(io, "- **Pontos de corte:** $(resultado[:pontos_corte])")
                
            elseif resultado[:status_solver] == MOI.TIME_LIMIT
                if haskey(resultado, :melhor_solucao_timeout)
                    println(io, "- **Melhor solução encontrada:** $(resultado[:melhor_solucao_timeout])")
                    if haskey(resultado, :gap_timeout)
                        println(io, "- **Gap final:** $(round(resultado[:gap_timeout], digits=2))%")
                    end
                else
                    println(io, "- **Resultado:** Nenhuma solução factível encontrada")
                end
            end
            
            println(io, "")
            println(io, "- **Tempo total (incluindo bound):** $(round(resultado[:tempo_total], digits=2))s")
            println(io, "")
        end
        
        # Informações técnicas
        println(io, "## Informações Técnicas")
        println(io, "")
        println(io, "### Formulação Matemática")
        println(io, "- **Tipo:** Programação Linear Inteira Mista (MILP)")
        println(io, "- **Objetivo:** Minimizar makespan")
        println(io, "- **Restrições principais:**")
        println(io, "  - Cada tarefa pertence a exatamente um segmento")
        println(io, "  - Cada segmento é atribuído a exatamente um operador")
        println(io, "  - Cada operador atua em exatamente um segmento")
        println(io, "  - Segmentos devem ser contíguos (sem lacunas)")
        println(io, "  - Definição do makespan")
        println(io, "")
        println(io, "### Configurações do Solver")
        println(io, "- **Solver:** GLPK (GNU Linear Programming Kit)")
        println(io, "- **Versão Julia:** $(VERSION)")
        println(io, "- **Timeout:** 5 horas (18000 segundos)")
        println(io, "- **Bound:** Modelo relaxado sem contiguidade (5 min timeout)")
        println(io, "")
        println(io, "### Reproducibilidade")
        println(io, "- **Sistema:** $(Sys.MACHINE)")
        println(io, "- **Data de execução:** $(Dates.now())")
        println(io, "- **Comando:** `julia coleta_dados_solver.jl`")
    end
    
    println("Relatório do solver salvo em: $arquivo_saida")
end

# ————————— Função principal —————————
function main()
    println("Iniciando coleta de dados do solver...")
    
    # Executar experimentos
    resultados, tempo_total = executar_experimentos_solver()
    
    # Gerar relatório
    gerar_relatorio_solver(resultados, tempo_total)
    
    println("Coleta de dados do solver concluída!")
    println("Verifique o arquivo 'relatorio_solver.md' para os resultados detalhados.")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end