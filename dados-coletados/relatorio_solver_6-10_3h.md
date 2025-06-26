# Relatório - Formulações Simplificadas para Trabalho Balanceado

**Data:** 2025-06-23T10:44:43.428
**Tempo total:** 721.72 minutos
**Instâncias processadas:** 5

## Comparação de Métodos

| Instância | n | m | Heur. Gulosa | Heur. Contig. | Solver Simples | Solver Melhor. | Melhor | Tempo Total (s) |
|-----------|---|---|--------------|---------------|----------------|----------------|--------|-----------------|
| tba6.txt | 37 | 13 | 0.541499 | 3.033838 | 0.335046 | 0.652391 | N/A | 10824.38 |
| tba7.txt | 32 | 14 | 0.291729 | 2.236101 | 0.2 | 0.871117 | N/A | 10800.79 |
| tba8.txt | 27 | 11 | 0.845763 | 2.462655 | 0.845763 | 0.974094 | N/A | 10800.28 |
| tba9.txt | 22 | 10 | 0.351203 | 1.671454 | 0.281871 | 0.583828 | N/A | 71.34 |
| tba10.txt | 42 | 10 | 0.787509 | 3.737025 | 0.566733 | 2.290799 | N/A | 10806.43 |

## Gaps Relativos ao Melhor Método (%)

| Instância | Gap Gulosa | Gap Contiguidade | Gap Simples | Gap Melhorado |
|-----------|------------|------------------|-------------|---------------|
| tba6.txt | N/A | N/A | N/A | N/A |
| tba7.txt | N/A | N/A | N/A | N/A |
| tba8.txt | N/A | N/A | N/A | N/A |
| tba9.txt | N/A | N/A | N/A | N/A |
| tba10.txt | N/A | N/A | N/A | N/A |

## Análise Detalhada: tba6.txt (n=37, m=13)
### Gaps Relativos ao Melhor Método

### Resumo de Performance
- **Heurística Gulosa:** 0.541499 (0.0ms)
- **Heurística c/ Contiguidade:** 3.033838 (735.0ms)
- **Solver Simples:** 0.335046 (21.57s)
  - Violações de contiguidade: 21
- **Solver Melhorado:** 0.652391 (10800.68s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.4718
  - Heurística Contiguidade: 0.7985
  - Solver Simples: 0.0923
  - Solver Melhorado: 0.4175
- **Operadores utilizados:**
  - Heurística Gulosa: 12/13
  - Heurística Contiguidade: 12/13
  - Solver Simples: 13/13
  - Solver Melhorado: 13/13
- **Impacto da contiguidade:** +460.27% no makespan
- **Mudanças realizadas:** 12 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 482
  - Restrições: 50
  - Timeout: 1200s
- **Solver Melhorado:**
  - Variáveis: 482
  - Restrições: 8240
  - Restrições de contiguidade: 8190
  - Timeout: 10800s

## Análise Detalhada: tba7.txt (n=32, m=14)
### Gaps Relativos ao Melhor Método

### Resumo de Performance
- **Heurística Gulosa:** 0.291729 (0.0ms)
- **Heurística c/ Contiguidade:** 2.236101 (1.0ms)
- **Solver Simples:** 0.2 (0.42s)
  - Violações de contiguidade: 16
- **Solver Melhorado:** 0.871117 (10800.36s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.2892
  - Heurística Contiguidade: 0.4043
  - Solver Simples: 0.0502
  - Solver Melhorado: 0.6513
- **Operadores utilizados:**
  - Heurística Gulosa: 14/14
  - Heurística Contiguidade: 14/14
  - Solver Simples: 14/14
  - Solver Melhorado: 14/14
- **Impacto da contiguidade:** +666.5% no makespan
- **Mudanças realizadas:** 14 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 449
  - Restrições: 46
  - Timeout: 1200s
- **Solver Melhorado:**
  - Variáveis: 449
  - Restrições: 6556
  - Restrições de contiguidade: 6510
  - Timeout: 10800s

## Análise Detalhada: tba8.txt (n=27, m=11)
### Gaps Relativos ao Melhor Método

### Resumo de Performance
- **Heurística Gulosa:** 0.845763 (0.0ms)
- **Heurística c/ Contiguidade:** 2.462655 (0.0ms)
- **Solver Simples:** 0.845763 (0.1s)
  - Violações de contiguidade: 15
- **Solver Melhorado:** 0.974094 (10800.18s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.337
  - Heurística Contiguidade: 0.6434
  - Solver Simples: 0.1947
  - Solver Melhorado: 0.2418
- **Operadores utilizados:**
  - Heurística Gulosa: 11/11
  - Heurística Contiguidade: 11/11
  - Solver Simples: 11/11
  - Solver Melhorado: 11/11
- **Impacto da contiguidade:** +191.18% no makespan
- **Mudanças realizadas:** 10 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 298
  - Restrições: 38
  - Timeout: 1200s
- **Solver Melhorado:**
  - Variáveis: 298
  - Restrições: 3613
  - Restrições de contiguidade: 3575
  - Timeout: 10800s

## Análise Detalhada: tba9.txt (n=22, m=10)
### Gaps Relativos ao Melhor Método

### Resumo de Performance
- **Heurística Gulosa:** 0.351203 (0.0ms)
- **Heurística c/ Contiguidade:** 1.671454 (0.0ms)
- **Solver Simples:** 0.281871 (0.02s)
  - Violações de contiguidade: 7
- **Solver Melhorado:** 0.583828 (71.32s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.2297
  - Heurística Contiguidade: 0.419
  - Solver Simples: 0.1074
  - Solver Melhorado: 0.355
- **Operadores utilizados:**
  - Heurística Gulosa: 10/10
  - Heurística Contiguidade: 10/10
  - Solver Simples: 10/10
  - Solver Melhorado: 10/10
- **Impacto da contiguidade:** +375.92% no makespan
- **Mudanças realizadas:** 10 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 221
  - Restrições: 32
  - Timeout: 1200s
- **Solver Melhorado:**
  - Variáveis: 221
  - Restrições: 2132
  - Restrições de contiguidade: 2100
  - Timeout: 10800s

## Análise Detalhada: tba10.txt (n=42, m=10)
### Gaps Relativos ao Melhor Método

### Resumo de Performance
- **Heurística Gulosa:** 0.787509 (0.0ms)
- **Heurística c/ Contiguidade:** 3.737025 (1.0ms)
- **Solver Simples:** 0.566733 (6.14s)
  - Violações de contiguidade: 30
- **Solver Melhorado:** 2.290799 (10800.29s)
  - Contiguidade perfeita: true

### Métricas Adicionais
- **Balanceamento (CV):**
  - Heurística Gulosa: 0.3467
  - Heurística Contiguidade: 0.4689
  - Solver Simples: 0.0545
  - Solver Melhorado: 0.4992
- **Operadores utilizados:**
  - Heurística Gulosa: 10/10
  - Heurística Contiguidade: 10/10
  - Solver Simples: 10/10
  - Solver Melhorado: 10/10
- **Impacto da contiguidade:** +374.54% no makespan
- **Mudanças realizadas:** 10 operadores

### Informações Técnicas
- **Solver Simples:**
  - Variáveis: 421
  - Restrições: 52
  - Timeout: 1200s
- **Solver Melhorado:**
  - Variáveis: 421
  - Restrições: 8252
  - Restrições de contiguidade: 8200
  - Timeout: 10800s

## Informações Gerais

### Métodos Avaliados
1. **Heurística Gulosa:** Atribuição tarefa por tarefa ao operador com menor makespan
2. **Heurística c/ Contiguidade:** Reorganização da solução gulosa para garantir contiguidade
3. **Solver Simples:** MILP sem restrições de contiguidade
4. **Solver Melhorado:** MILP com restrições de contiguidade simplificadas

### Configurações
- **Solver:** GLPK
- **Timeout Solver Simples:** 1200s
- **Timeout Solver Melhorado:** 10800s
- **Sistema:** x86_64-w64-mingw32
- **Julia:** 1.11.5
