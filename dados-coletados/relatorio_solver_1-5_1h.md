# Relatório - Formulações Simplificadas para Trabalho Balanceado

**Data:** 2025-06-22T23:27:34.699
**Tempo total:** 250.72 minutos
**Instâncias processadas:** 5

## Comparação de Métodos

| Instância | n | m | Heur. Gulosa | Heur. Contig. | Solver Simples | Solver Melhor. | Tempo Total (s) |
|-----------|---|---|--------------|---------------|----------------|----------------|-----------------|
| tba1.txt | 37 | 13 | 0.32691 | 3.194825 | 0.299338 | 1.20602 | 4208.14 |
| tba2.txt | 32 | 15 | 0.538921 | 2.20088 | 0.38648 | 0.943201 | 3600.36 |
| tba3.txt | 27 | 13 | 0.30762 | 2.941513 | 0.30762 | 0.490612 | 3600.28 |
| tba4.txt | 22 | 15 | 0.363398 | 1.684731 | 0.307003 | 0.307003 | 0.76 |
| tba5.txt | 42 | 10 | 1.033627 | 3.910764 | 0.568384 | 2.466943 | 3633.92 |

## Análise Detalhada: tba1.txt (n=37, m=13)

### Resumo de Performance
- **Heurística Gulosa:** 0.32691 (0.0ms)
- **Heurística c/ Contiguidade:** 3.194825 (246.4ms)
- **Solver Simples:** 0.299338 (607.16s)
  - Violações de contiguidade: 23
- **Solver Melhorado:** 1.20602 (3600.28s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.177
  - Heurística Contiguidade: 0.5798
  - Solver Simples: 0.129
  - Solver Melhorado: 0.5965
- **Operadores utilizados:**
  - Heurística Gulosa: 13/13
  - Heurística Contiguidade: 13/13
  - Solver Simples: 13/13
  - Solver Melhorado: 13/13
- **Impacto da contiguidade:** +877.28% no makespan
- **Mudanças realizadas:** 13 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 482
  - Restrições: 50
  - Timeout: 600s
- **Solver Melhorado:**
  - Variáveis: 482
  - Restrições: 8240
  - Restrições de contiguidade: 8190
  - Timeout: 3600s

## Análise Detalhada: tba2.txt (n=32, m=15)

### Resumo de Performance
- **Heurística Gulosa:** 0.538921 (0.0ms)
- **Heurística c/ Contiguidade:** 2.20088 (0.1ms)
- **Solver Simples:** 0.38648 (0.23s)
  - Violações de contiguidade: 16
- **Solver Melhorado:** 0.943201 (3600.13s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.5541
  - Heurística Contiguidade: 0.5072
  - Solver Simples: 0.3137
  - Solver Melhorado: 0.5855
- **Operadores utilizados:**
  - Heurística Gulosa: 15/15
  - Heurística Contiguidade: 15/15
  - Solver Simples: 15/15
  - Solver Melhorado: 15/15
- **Impacto da contiguidade:** +308.39% no makespan
- **Mudanças realizadas:** 15 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 481
  - Restrições: 47
  - Timeout: 600s
- **Solver Melhorado:**
  - Variáveis: 481
  - Restrições: 7022
  - Restrições de contiguidade: 6975
  - Timeout: 3600s

## Análise Detalhada: tba3.txt (n=27, m=13)

### Resumo de Performance
- **Heurística Gulosa:** 0.30762 (0.0ms)
- **Heurística c/ Contiguidade:** 2.941513 (0.1ms)
- **Solver Simples:** 0.30762 (0.12s)
  - Violações de contiguidade: 13
- **Solver Melhorado:** 0.490612 (3600.16s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.2849
  - Heurística Contiguidade: 0.6143
  - Solver Simples: 0.4344
  - Solver Melhorado: 0.3705
- **Operadores utilizados:**
  - Heurística Gulosa: 13/13
  - Heurística Contiguidade: 13/13
  - Solver Simples: 13/13
  - Solver Melhorado: 13/13
- **Impacto da contiguidade:** +856.22% no makespan
- **Mudanças realizadas:** 13 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 352
  - Restrições: 40
  - Timeout: 600s
- **Solver Melhorado:**
  - Variáveis: 352
  - Restrições: 4265
  - Restrições de contiguidade: 4225
  - Timeout: 3600s

## Análise Detalhada: tba4.txt (n=22, m=15)

### Resumo de Performance
- **Heurística Gulosa:** 0.363398 (0.0ms)
- **Heurística c/ Contiguidade:** 1.684731 (0.1ms)
- **Solver Simples:** 0.307003 (0.02s)
  - Violações de contiguidade: 9
- **Solver Melhorado:** 0.307003 (0.74s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.6568
  - Heurística Contiguidade: 0.8966
  - Solver Simples: 0.7064
  - Solver Melhorado: 0.4543
- **Operadores utilizados:**
  - Heurística Gulosa: 15/15
  - Heurística Contiguidade: 15/15
  - Solver Simples: 13/15
  - Solver Melhorado: 14/15
- **Impacto da contiguidade:** +363.6% no makespan
- **Mudanças realizadas:** 15 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 331
  - Restrições: 37
  - Timeout: 600s
- **Solver Melhorado:**
  - Variáveis: 331
  - Restrições: 3187
  - Restrições de contiguidade: 3150
  - Timeout: 3600s

## Análise Detalhada: tba5.txt (n=42, m=10)

### Resumo de Performance
- **Heurística Gulosa:** 1.033627 (0.0ms)
- **Heurística c/ Contiguidade:** 3.910764 (0.1ms)
- **Solver Simples:** 0.568384 (33.66s)
  - Violações de contiguidade: 29
- **Solver Melhorado:** 2.466943 (3600.25s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.3286
  - Heurística Contiguidade: 0.4171
  - Solver Simples: 0.0515
  - Solver Melhorado: 0.4609
- **Operadores utilizados:**
  - Heurística Gulosa: 10/10
  - Heurística Contiguidade: 10/10
  - Solver Simples: 10/10
  - Solver Melhorado: 10/10
- **Impacto da contiguidade:** +278.35% no makespan
- **Mudanças realizadas:** 10 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 421
  - Restrições: 52
  - Timeout: 600s
- **Solver Melhorado:**
  - Variáveis: 421
  - Restrições: 8252
  - Restrições de contiguidade: 8200
  - Timeout: 3600s

## Informações Gerais

### Métodos Avaliados
1. **Heurística Gulosa:** Atribuição tarefa por tarefa ao operador com menor makespan
2. **Heurística c/ Contiguidade:** Reorganização da solução gulosa para garantir contiguidade
3. **Solver Simples:** MILP sem restrições de contiguidade
4. **Solver Melhorado:** MILP com restrições de contiguidade simplificadas

### Configurações
- **Solver:** GLPK
- **Timeout Solver Simples:** 600s
- **Timeout Solver Melhorado:** 3600
- **Sistema:** x86_64-linux-gnu
- **Julia:** 1.11.5
