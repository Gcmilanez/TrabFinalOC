# Integrantes do Grupo

- Giovanni Milanez
- Gleydson de Sousa Campos

## Problema e Meta Heurística

- Problema do Trabalho Balanceado
- Variable Neighborhood Search (VNS)

## Dependências julia para solver genérico GLPK

- julia -e 'using Pkg; Pkg.add(["JuMP", "GLPK"])'

## Execução do código com meta-heurística VNS e solver genérico

- julia vns.jl <arquivo_base> [iter_max] [num_runs]
- julia solver <arquivo_base> [tempo_simples] [tempo_melhorado]

