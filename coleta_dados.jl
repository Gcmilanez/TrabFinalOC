#!/usr/bin/env julia
# coleta_dados.jl
# Script para coleta sistemática de dados do VNS

using Random, Printf, Dates, Statistics

# ————————— Funções do VNS —————————
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

# ————————— VNS Dados—————————
function VNS_com_dados(p::Matrix{Float64}; iter_max::Int=5_000_000)
    n, m = size(p)
    borders, π = sol_inicial_gulosa(p, n, m)
    f_best = avalia(p, borders, π)
    k_max = length(NEIGHS)
    
    # Dados para coleta
    historico = Float64[]  # evolução do makespan
    melhorias = Int[]      # iterações onde houve melhoria
    tempo_inicio = time()
    tempo_melhor_sol = nothing
    melhor_borders = copy(borders)
    melhor_π = copy(π)
    avaliacoes = 0
    
    push!(historico, f_best)
    
    for it in 1:iter_max
        k = 1
        while k ≤ k_max
            candidate = NEIGHS[k](p, borders, π, n) 
            new_b, new_π = busca_local(p, candidate, n)
            f_new = avalia(p, new_b, new_π)
            avaliacoes += 1
            
            if f_new < f_best
                # Nova melhor solução encontrada!
                if tempo_melhor_sol === nothing
                    tempo_melhor_sol = time() - tempo_inicio
                end
                
                f_best, borders, π = f_new, new_b, new_π
                melhor_borders, melhor_π = copy(new_b), copy(new_π)
                push!(historico, f_best)
                push!(melhorias, it)
                k = 1
            else
                k += 1
            end
        end
    end
    
    tempo_total = time() - tempo_inicio
    if tempo_melhor_sol === nothing
        tempo_melhor_sol = tempo_total
    end
    
    return (
        makespan = f_best,
        borders = melhor_borders,
        operadores = melhor_π,
        tempo_total = tempo_total,
        tempo_melhor_sol = tempo_melhor_sol,
        historico = historico,
        melhorias = melhorias,
        avaliacoes = avaliacoes,
        iteracoes_total = iter_max
    )
end

# ————————— Experimentos completos —————————
function executar_experimentos()
    println("=== COLETA DE DADOS VNS - TRABALHO BALANCEADO ===")
    println("Data/Hora: $(Dates.now())")
    println()
    
    # Configurações
    instancias = ["tba$i.txt" for i in 1:10]
    num_execucoes = 15
    iter_max = 5_000_000
    
    # Estrutura para armazenar todos os resultados
    resultados = Dict()
    
    for instancia in instancias
        caminho = "testes/$instancia"
        println("Processando $instancia...")
        
        if !isfile(caminho)
            println("Arquivo não encontrado: $caminho")
            continue
        end
        
        # Ler instância
        p, n, m = ler_instancia(caminho)
        println("n=$n tarefas, m=$m operadores")
        
        # Executar experimentos
        resultados_instancia = []
        tempo_total_instancia = @elapsed begin
            for exec in 1:num_execucoes
                print("Execução $exec/$num_execucoes... ")
                resultado = VNS_com_dados(p; iter_max=iter_max)
                push!(resultados_instancia, resultado)
                println("Makespan: $(round(resultado.makespan, digits=6)) ($(round(resultado.tempo_total, digits=3))s)")
            end
        end
        
        # Armazenar resultados
        resultados[instancia] = (
            dados_instancia = (n=n, m=m),
            execucoes = resultados_instancia,
            tempo_total_instancia = tempo_total_instancia
        )
        
        println("Concluído em $(round(tempo_total_instancia, digits=2))s")
        println()
    end
    
    return resultados
end

# ————————— Geração de relatório —————————
function gerar_relatorio(resultados::Dict; arquivo_saida="relatorio_vns.md")
    open(arquivo_saida, "w") do io
        println(io, "# Relatório de Experimentos - VNS para Trabalho Balanceado")
        println(io, "")
        println(io, "**Data:** $(Dates.now())")
        println(io, "**Configuração:** 15 execuções por instância, 5M iterações máximas")
        println(io, "")
        
        # Resumo geral
        println(io, "## Resumo Geral")
        println(io, "")
        println(io, "| Instância | n | m | Melhor | Pior | Média | Desvio | Tempo Médio (s) |")
        println(io, "|-----------|---|---|---------|------|-------|--------|-----------------|")
        
        for instancia in sort(collect(keys(resultados)))
            dados = resultados[instancia]
            execucoes = dados.execucoes
            n, m = dados.dados_instancia.n, dados.dados_instancia.m
            
            makespans = [ex.makespan for ex in execucoes]
            tempos = [ex.tempo_total for ex in execucoes]
            
            melhor = minimum(makespans)
            pior = maximum(makespans)
            media = mean(makespans)
            desvio = std(makespans)
            tempo_medio = mean(tempos)
            
            println(io, "| $instancia | $n | $m | $(round(melhor,digits=6)) | $(round(pior,digits=6)) | $(round(media,digits=6)) | $(round(desvio,digits=6)) | $(round(tempo_medio,digits=2)) |")
        end
        
        println(io, "")
        
        # Detalhes por instância
        for instancia in sort(collect(keys(resultados)))
            dados = resultados[instancia]
            execucoes = dados.execucoes
            n, m = dados.dados_instancia.n, dados.dados_instancia.m
            
            println(io, "## $instancia (n=$n, m=$m)")
            println(io, "")
            
            # Estatísticas
            makespans = [ex.makespan for ex in execucoes]
            tempos_totais = [ex.tempo_total for ex in execucoes]
            tempos_melhor = [ex.tempo_melhor_sol for ex in execucoes]
            avaliacoes = [ex.avaliacoes for ex in execucoes]
            
            println(io, "### Estatísticas")
            println(io, "- **Makespan:** min=$(round(minimum(makespans),digits=6)), max=$(round(maximum(makespans),digits=6)), média=$(round(mean(makespans),digits=6))")
            println(io, "- **Tempo total:** min=$(round(minimum(tempos_totais),digits=3))s, max=$(round(maximum(tempos_totais),digits=3))s, média=$(round(mean(tempos_totais),digits=3))s")
            println(io, "- **Tempo até melhor solução:** min=$(round(minimum(tempos_melhor),digits=3))s, max=$(round(maximum(tempos_melhor),digits=3))s, média=$(round(mean(tempos_melhor),digits=3))s")
            println(io, "- **Avaliações:** min=$(minimum(avaliacoes)), max=$(maximum(avaliacoes)), média=$(round(mean(avaliacoes),digits=0))")
            println(io, "")
            
            # Melhor solução encontrada
            idx_melhor = argmin(makespans)
            melhor_exec = execucoes[idx_melhor]
            
            println(io, "### Melhor Solução (Execução $idx_melhor)")
            println(io, "- **Makespan:** $(melhor_exec.makespan)")
            println(io, "- **Tempo até encontrar:** $(round(melhor_exec.tempo_melhor_sol, digits=3))s")
            println(io, "- **Segmentação e Operadores:**")
            for i in 1:m
                inicio, fim = melhor_exec.borders[i], melhor_exec.borders[i+1]-1
                op = melhor_exec.operadores[i]
                println(io, "  - Segmento $i: tarefas ($inicio, $fim) → Operador $op")
            end
            println(io, "")
            
            # Tabela de resultados detalhados
            println(io, "### Resultados Detalhados")
            println(io, "")
            println(io, "| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |")
            println(io, "|------|----------|-----------------|---------------------|------------|-----------|")
            
            for (i, ex) in enumerate(execucoes)
                println(io, "| $i | $(round(ex.makespan,digits=6)) | $(round(ex.tempo_total,digits=3)) | $(round(ex.tempo_melhor_sol,digits=3)) | $(ex.avaliacoes) | $(length(ex.melhorias)) |")
            end
            println(io, "")
        end
        
        # Informações técnicas
        println(io, "## Informações Técnicas")
        println(io, "")
        println(io, "- **Algoritmo:** Variable Neighborhood Search (VNS)")
        println(io, "- **Vizinhanças:** 5 tipos (swap, shift±1, shift±δ, expand+bestop, expand_delta+bestop)")
        println(io, "- **Busca Local:** First-improvement")
        println(io, "- **Critério de parada:** $(div(5_000_000, 1_000_000))M iterações")
        println(io, "- **Linguagem:** Julia $(VERSION)")
        println(io, "")
        
        tempo_total_experimento = sum(dados.tempo_total_instancia for dados in values(resultados))
        println(io, "**Tempo total do experimento:** $(round(tempo_total_experimento/60, digits=2)) minutos")
    end
    
    println("Relatório salvo em: $arquivo_saida")
end

# ————————— Função principal —————————
function main()
    println("Iniciando coleta de dados...")
    
    # Executar todos os experimentos
    resultados = executar_experimentos()
    
    # Gerar relatório
    gerar_relatorio(resultados)
    
    println("Experimentos concluídos!")
    println("Verifique o arquivo 'relatorio_vns.md' para os resultados detalhados.")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end