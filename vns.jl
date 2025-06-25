#!/usr/bin/env julia
# trab_dados_completos.jl
# VNS com coleta completa de dados para análise comparativa

using Random, Printf, Dates, Statistics

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

# ————————— Avaliação de solução —————————
function avalia(p::Matrix{Float64}, borders::Vector{Int}, π::Vector{Int})
    Tjs = [sum(p[i, π[j]] for i in borders[j]:(borders[j+1]-1)) for j in 1:length(π)]
    return maximum(Tjs)
end

# ————————— SOLUÇÃO INICIAL SEQUENCIAL (NOVA) —————————
function solucao_inicial_sequencial(p::Matrix{Float64}, n::Int, m::Int)
    """
    Gera solução inicial dividindo tarefas sequencialmente entre operadores.
    Esta é a solução de referência (SI) para cálculo dos gaps.
    """
    # Distribuição uniforme das tarefas
    tarefas_por_operador = div(n, m)
    tarefas_extras = n % m
    
    # Construir fronteiras dos segmentos
    borders = [1]
    tarefa_atual = 1
    
    for i in 1:m
        # Operadores iniciais ganham uma tarefa extra se houver resto
        num_tarefas = tarefas_por_operador + (i <= tarefas_extras ? 1 : 0)
        tarefa_atual += num_tarefas
        push!(borders, tarefa_atual)
    end
    
    # Atribuição sequencial de operadores (1, 2, 3, ..., m)
    π = collect(1:m)
    
    # Calcular makespan da solução inicial
    makespan = avalia(p, borders, π)
    
    return borders, π, makespan
end

# ————————— Solução Inicial Gulosa (original) —————————
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

# 5) expand_delta_bestop: shift ±δ e reatribui melhor operador
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

# ————————— VNS com Coleta de Dados Completa ————————— 
function VNS_dados_completos(p::Matrix{Float64}; iter_max::Int=1_000_000)
    n, m = size(p)
    tempo_inicio = time()
    
    # Gerar solução inicial
    borders, π = sol_inicial_gulosa(p, n, m)
    f_best = avalia(p, borders, π)
    
    # Dados para coleta
    historico_makespan = [f_best]
    tempo_melhor_solucao = 0.0
    melhor_borders = copy(borders)
    melhor_π = copy(π)
    iteracoes_melhoria = Int[]
    
    k_max = length(NEIGHS)
    
    for it in 1:iter_max
        k = 1
        while k ≤ k_max
            candidate = NEIGHS[k](p, borders, π, n) 
            new_b, new_π = busca_local(p, candidate, n)
            f_new = avalia(p, new_b, new_π)
            
            if f_new < f_best
                f_best = f_new
                borders, π = new_b, new_π
                melhor_borders, melhor_π = copy(new_b), copy(new_π)
                tempo_melhor_solucao = time() - tempo_inicio
                push!(historico_makespan, f_best)
                push!(iteracoes_melhoria, it)
                k = 1
            else
                k += 1
            end
        end
    end
    
    tempo_total = time() - tempo_inicio
    
    return Dict(
        :makespan_final => f_best,
        :borders_final => melhor_borders,
        :operadores_final => melhor_π,
        :tempo_total => tempo_total,
        :tempo_melhor_solucao => tempo_melhor_solucao,
        :historico_makespan => historico_makespan,
        :iteracoes_melhoria => iteracoes_melhoria,
        :num_melhorias => length(iteracoes_melhoria)
    )
end

# ————————— Coleta Dados Comparativos de uma Instância ————————— 
function analisar_instancia_completa(caminho_instancia::String, nome_instancia::String; 
                                   iter_max::Int=5_000_000, num_execucoes::Int=30)
    println("=== Analisando $nome_instancia ===")
    
    # Ler instância
    p, n, m = ler_instancia(caminho_instancia)
    println("Dimensões: n=$n tarefas, m=$m operadores")
    
    # 1. CALCULAR SOLUÇÃO INICIAL SEQUENCIAL (SI)
    borders_seq, π_seq, SI = solucao_inicial_sequencial(p, n, m)
    println("Solução Inicial Sequencial (SI): $(round(SI, digits=6))")
    
    # 2. EXECUTAR VNS MÚLTIPLAS VEZES
    println("Executando VNS $num_execucoes vezes...")
    resultados_vns = []
    melhor_makespan_geral = Inf
    melhor_resultado_geral = nothing
    
    for exec in 1:num_execucoes
        print("Execução $exec/$num_execucoes... ")
        resultado = VNS_dados_completos(p; iter_max=iter_max)
        push!(resultados_vns, resultado)
        
        if resultado[:makespan_final] < melhor_makespan_geral
            melhor_makespan_geral = resultado[:makespan_final]
            melhor_resultado_geral = resultado
        end
        
        println("SF=$(round(resultado[:makespan_final], digits=6)) ($(round(resultado[:tempo_total], digits=1))s)")
    end
    
    # 3. CALCULAR ESTATÍSTICAS DO VNS
    makespans = [r[:makespan_final] for r in resultados_vns]
    tempos = [r[:tempo_total] for r in resultados_vns]
    tempos_melhor = [r[:tempo_melhor_solucao] for r in resultados_vns]
    
    stats_vns = Dict(
        :melhor => minimum(makespans),
        :pior => maximum(makespans),
        :media => mean(makespans),
        :desvio => std(makespans),
        :tempo_medio => mean(tempos),
        :tempo_melhor_medio => mean(tempos_melhor)
    )
    
    # 4. VALORES DE REFERÊNCIA (BKV) - valores conhecidos
    BKV = Dict(
        "tba1" => 0.56, "tba2" => 0.52, "tba3" => 0.48, "tba4" => 0.31, "tba5" => 1.49,
        "tba6" => 0.57, "tba7" => 0.59, "tba8" => 0.85, "tba9" => 0.58, "tba10" => 1.33
    )
    
    nome_base = replace(nome_instancia, ".txt" => "")
    BKV_valor = get(BKV, nome_base, nothing)
    
    # 5. CALCULAR GAPS
    SF = stats_vns[:melhor]  # Melhor solução encontrada pelo VNS
    
    gap_melhoria = 100 * (SI - SF) / SI  # Quanto melhorou em relação à inicial
    gap_otimalidade = BKV_valor !== nothing ? 100 * (SF - BKV_valor) / BKV_valor : nothing
    
    # 6. CONSOLIDAR RESULTADOS
    resultado_final = Dict(
        :instancia => nome_instancia,
        :n => n,
        :m => m,
        :SI => SI,  # Solução Inicial
        :SF => SF,  # Solução Final (melhor VNS)
        :BKV => BKV_valor,  # Best Known Value
        :gap_melhoria => gap_melhoria,  # (SI-SF)/SI * 100
        :gap_otimalidade => gap_otimalidade,  # (SF-BKV)/BKV * 100
        :stats_vns => stats_vns,
        :melhor_solucao => melhor_resultado_geral,
        :todas_execucoes => resultados_vns
    )
    
    # 7. IMPRIMIR RESUMO
    println("\n--- RESUMO $nome_instancia ---")
    println("SI (Sequencial): $(round(SI, digits=6))")
    println("SF (Melhor VNS): $(round(SF, digits=6))")
    if BKV_valor !== nothing
        println("BKV (Ótimo):     $(round(BKV_valor, digits=6))")
        println("Gap otimalidade: $(round(gap_otimalidade, digits=2))%")
    end
    println("Gap melhoria:    $(round(gap_melhoria, digits=2))%")
    println("VNS Média:       $(round(stats_vns[:media], digits=6)) ± $(round(stats_vns[:desvio], digits=6))")
    println("Tempo médio:     $(round(stats_vns[:tempo_medio], digits=1))s")
    println()
    
    return resultado_final
end

# ————————— Função para Executar Todas as Instâncias ————————— 
function executar_experimento_completo(; iter_max::Int=5_000_000, num_execucoes::Int=30)
    println("=== EXPERIMENTO COMPLETO - VNS TRABALHO BALANCEADO ===")
    println("Data/Hora: $(Dates.now())")
    println("Configuração: $num_execucoes execuções por instância, $iter_max iterações máximas")
    println()
    
    instancias = ["tba$i.txt" for i in 1:10]
    resultados_todas = []
    tempo_total_experimento = @elapsed begin
        for instancia in instancias
            caminho = joinpath("testes", instancia)
            if isfile(caminho)
                resultado = analisar_instancia_completa(caminho, instancia; 
                                                      iter_max=iter_max, 
                                                      num_execucoes=num_execucoes)
                push!(resultados_todas, resultado)
            else
                println("Arquivo não encontrado: $caminho")
            end
        end
    end
    
    # Gerar tabela comparativa final
    gerar_tabela_comparativa(resultados_todas, tempo_total_experimento)
    
    return resultados_todas
end

# ————————— Geração da Tabela Comparativa Final ————————— 
function gerar_tabela_comparativa(resultados::Vector, tempo_total::Float64)
    println("\n" * "="^80)
    println("TABELA COMPARATIVA FINAL")
    println("="^80)
    
    # Cabeçalho
    println("| Instância | n×m    | SI      | SF      | BKV     | Gap Melh.% | Gap Ótim.% | Tempo(s) |")
    println("|-----------|--------|---------|---------|---------|------------|------------|----------|")
    
    # Dados
    for r in resultados
        inst = r[:instancia]
        dim = "$(r[:n])×$(r[:m])"
        SI = @sprintf("%.3f", r[:SI])
        SF = @sprintf("%.3f", r[:SF])
        BKV = r[:BKV] !== nothing ? @sprintf("%.3f", r[:BKV]) : "N/A"
        gap_melh = @sprintf("%.1f", r[:gap_melhoria])
        gap_otim = r[:gap_otimalidade] !== nothing ? @sprintf("%.1f", r[:gap_otimalidade]) : "N/A"
        tempo = @sprintf("%.1f", r[:stats_vns][:tempo_medio])
        
        println("| $inst     | $dim | $SI   | $SF   | $BKV   | $gap_melh     | $gap_otim     | $tempo   |")
    end
    
    println()
    println("Legendas:")
    println("SI  = Solução Inicial (sequencial)")
    println("SF  = Solução Final (melhor VNS)")  
    println("BKV = Best Known Value (ótimo conhecido)")
    println("Gap Melh. = (SI-SF)/SI × 100 (quanto melhorou)")
    println("Gap Ótim. = (SF-BKV)/BKV × 100 (distância do ótimo)")
    println()
    println("Tempo total do experimento: $(round(tempo_total/60, digits=2)) minutos")
end

# ————————— Main ————————— 
function main()
    if length(ARGS) >= 1 && ARGS[1] == "completo"
        # Executar experimento completo
        iter_max = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 5_000_000
        num_exec = length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 30
        executar_experimento_completo(iter_max=iter_max, num_execucoes=num_exec)
    
    elseif length(ARGS) >= 1
        # Executar instância individual  
        input_base = ARGS[1]
        input_file = joinpath("testes", input_base)
        iter_max = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 5_000_000
        num_runs = length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 50
        
        # Análise individual detalhada
        resultado = analisar_instancia_completa(input_file, input_base; 
                                              iter_max=iter_max, 
                                              num_execucoes=num_runs)
        
        # Salvar resultados detalhados
        base = replace(input_base, ".txt" => "")
        output_dir = "output"
        isdir(output_dir) || mkpath(output_dir)
        
        # Arquivo de solução
        open(joinpath(output_dir, "analise_$(base).txt"), "w") do io
            println(io, "=== ANÁLISE COMPLETA $input_base ===")
            println(io, "Solução Inicial: $(resultado[:SI])")
            println(io, "Solução Final: $(resultado[:SF])")
            println(io, "Melhor Solução:")
            melhor = resultado[:melhor_solucao]
            for j in 1:resultado[:m]
                start_task = melhor[:borders_final][j]
                end_task = melhor[:borders_final][j+1] - 1
                op = melhor[:operadores_final][j]
                println(io, "  Segmento $j: tarefas ($start_task-$end_task) → Operador $op")
            end
        end
        
    else
        println("Uso:")
        println("  julia trab_dados_completos.jl completo [iter_max] [num_exec]  # Todas as instâncias")
        println("  julia trab_dados_completos.jl tba1.txt [iter_max] [num_runs]  # Instância individual")
        println()
        println("Exemplos:")
        println("  julia trab_dados_completos.jl completo 5000000 30")
        println("  julia trab_dados_completos.jl tba1.txt 5000000 50")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end