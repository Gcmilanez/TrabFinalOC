# Relatório de Experimentos - VNS para Trabalho Balanceado

**Data:** 2025-06-22T04:40:19.412
**Configuração:** 15 execuções por instância, 5M iterações máximas

## Resumo Geral

| Instância | n  | m  | Melhor   | Pior     | Média    | Desvio   | Tempo Médio (s) |
|-----------|----|----|----------|----------|----------|----------|-----------------|
| tba1.txt  | 37 | 13 | 0.570785 | 0.858134 | 0.713198 | 0.127714 | 76.54           |
| tba10.txt | 42 | 10 | 1.326099 | 1.829441 | 1.408175 | 0.161976 | 72.89           |
| tba2.txt  | 32 | 15 | 0.522532 | 0.721227 | 0.657947 | 0.057966 | 71.12           |
| tba3.txt  | 27 | 13 | 0.489258 | 0.739384 | 0.539684 | 0.068486 | 66.99           |
| tba4.txt  | 22 | 15 | 0.307003 | 0.531776 | 0.321988 | 0.058036 | 67.46           |
| tba5.txt  | 42 | 10 | 1.491399 | 1.811768 | 1.542567 | 0.109578 | 74.64           |
| tba6.txt  | 37 | 13 | 0.56668  | 0.745814 | 0.637741 | 0.053396 | 74.03           |
| tba7.txt  | 32 | 14 | 0.643892 | 0.882055 | 0.738903 | 0.094859 | 72.77           |
| tba8.txt  | 27 | 11 | 0.845763 | 0.929058 | 0.875921 | 0.031974 | 70.99           |
| tba9.txt  | 22 | 10 | 0.583828 | 0.68     | 0.624214 | 0.03122  | 70.94           |

## tba1.txt (n=37, m=13)

### Estatísticas
- **Makespan:** min=0.570785, max=0.858134, média=0.713198
- **Tempo total:** min=70.1s, max=81.152s, média=76.535s
- **Tempo até melhor solução:** min=0.0s, max=0.016s, média=0.001s
- **Avaliações:** min=25000045, max=25000118, média=2.5000061e7

### Melhor Solução (Execução 4)
- **Makespan:** 0.5707850000000001
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 3) → Operador 12
  - Segmento 2: tarefas (4, 4) → Operador 2
  - Segmento 3: tarefas (5, 7) → Operador 11
  - Segmento 4: tarefas (8, 9) → Operador 6
  - Segmento 5: tarefas (10, 13) → Operador 5
  - Segmento 6: tarefas (14, 16) → Operador 8
  - Segmento 7: tarefas (17, 20) → Operador 13
  - Segmento 8: tarefas (21, 22) → Operador 1
  - Segmento 9: tarefas (23, 24) → Operador 4
  - Segmento 10: tarefas (25, 27) → Operador 7
  - Segmento 11: tarefas (28, 30) → Operador 9
  - Segmento 12: tarefas (31, 33) → Operador 10
  - Segmento 13: tarefas (34, 37) → Operador 3

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.688049 | 70.1 | 0.016 | 25000057 | 22 |
| 2 | 0.688049 | 71.599 | 0.0 | 25000050 | 16 |
| 3 | 0.594135 | 76.565 | 0.0 | 25000059 | 19 |
| 4 | 0.570785 | 81.152 | 0.0 | 25000118 | 33 |
| 5 | 0.858134 | 74.741 | 0.0 | 25000055 | 18 |
| 6 | 0.858134 | 78.356 | 0.0 | 25000048 | 15 |
| 7 | 0.858134 | 77.177 | 0.0 | 25000045 | 19 |
| 8 | 0.594135 | 79.609 | 0.0 | 25000086 | 26 |
| 9 | 0.858134 | 76.098 | 0.0 | 25000045 | 15 |
| 10 | 0.636218 | 77.904 | 0.0 | 25000048 | 20 |
| 11 | 0.570785 | 78.883 | 0.0 | 25000063 | 20 |
| 12 | 0.570785 | 77.832 | 0.0 | 25000062 | 23 |
| 13 | 0.858134 | 73.883 | 0.0 | 25000055 | 17 |
| 14 | 0.636218 | 77.966 | 0.0 | 25000080 | 24 |
| 15 | 0.858134 | 76.161 | 0.0 | 25000048 | 17 |

## tba10.txt (n=42, m=10)

### Estatísticas
- **Makespan:** min=1.326099, max=1.829441, média=1.408175
- **Tempo total:** min=69.996s, max=75.195s, média=72.894s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000032, max=25000100, média=2.5000063e7

### Melhor Solução (Execução 2)
- **Makespan:** 1.3260990000000001
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 6) → Operador 4
  - Segmento 2: tarefas (7, 9) → Operador 6
  - Segmento 3: tarefas (10, 14) → Operador 1
  - Segmento 4: tarefas (15, 21) → Operador 7
  - Segmento 5: tarefas (22, 25) → Operador 2
  - Segmento 6: tarefas (26, 28) → Operador 9
  - Segmento 7: tarefas (29, 33) → Operador 5
  - Segmento 8: tarefas (34, 37) → Operador 8
  - Segmento 9: tarefas (38, 39) → Operador 3
  - Segmento 10: tarefas (40, 42) → Operador 10

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 1.339576 | 74.71 | 0.0 | 25000071 | 29 |
| 2 | 1.326099 | 72.807 | 0.0 | 25000065 | 24 |
| 3 | 1.326099 | 72.605 | 0.0 | 25000040 | 16 |
| 4 | 1.326099 | 73.884 | 0.0 | 25000059 | 19 |
| 5 | 1.326099 | 75.022 | 0.0 | 25000064 | 25 |
| 6 | 1.339576 | 70.562 | 0.0 | 25000054 | 19 |
| 7 | 1.326099 | 72.262 | 0.0 | 25000052 | 18 |
| 8 | 1.339576 | 75.195 | 0.0 | 25000065 | 25 |
| 9 | 1.601365 | 69.996 | 0.0 | 25000070 | 25 |
| 10 | 1.829441 | 71.709 | 0.0 | 25000059 | 18 |
| 11 | 1.339576 | 73.767 | 0.0 | 25000100 | 34 |
| 12 | 1.339576 | 75.089 | 0.0 | 25000063 | 22 |
| 13 | 1.326099 | 72.342 | 0.0 | 25000088 | 27 |
| 14 | 1.697775 | 71.796 | 0.0 | 25000032 | 10 |
| 15 | 1.339576 | 71.672 | 0.0 | 25000057 | 22 |

## tba2.txt (n=32, m=15)

### Estatísticas
- **Makespan:** min=0.522532, max=0.721227, média=0.657947
- **Tempo total:** min=67.02s, max=77.261s, média=71.12s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000030, max=25000095, média=2.5000059e7

### Melhor Solução (Execução 15)
- **Makespan:** 0.522532
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 1) → Operador 4
  - Segmento 2: tarefas (2, 3) → Operador 14
  - Segmento 3: tarefas (4, 5) → Operador 7
  - Segmento 4: tarefas (6, 8) → Operador 9
  - Segmento 5: tarefas (9, 10) → Operador 15
  - Segmento 6: tarefas (11, 12) → Operador 12
  - Segmento 7: tarefas (13, 13) → Operador 11
  - Segmento 8: tarefas (14, 16) → Operador 8
  - Segmento 9: tarefas (17, 17) → Operador 3
  - Segmento 10: tarefas (18, 18) → Operador 2
  - Segmento 11: tarefas (19, 22) → Operador 5
  - Segmento 12: tarefas (23, 24) → Operador 1
  - Segmento 13: tarefas (25, 27) → Operador 10
  - Segmento 14: tarefas (28, 29) → Operador 13
  - Segmento 15: tarefas (30, 32) → Operador 6

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.706464 | 74.462 | 0.0 | 25000050 | 20 |
| 2 | 0.652527 | 77.261 | 0.0 | 25000050 | 17 |
| 3 | 0.706464 | 73.832 | 0.0 | 25000058 | 22 |
| 4 | 0.622532 | 76.518 | 0.0 | 25000035 | 13 |
| 5 | 0.622532 | 69.543 | 0.0 | 25000089 | 26 |
| 6 | 0.721227 | 67.02 | 0.0 | 25000047 | 19 |
| 7 | 0.622532 | 68.361 | 0.0 | 25000067 | 22 |
| 8 | 0.706464 | 69.825 | 0.0 | 25000095 | 34 |
| 9 | 0.606713 | 73.692 | 0.0 | 25000085 | 29 |
| 10 | 0.706464 | 71.363 | 0.0 | 25000068 | 22 |
| 11 | 0.622532 | 70.993 | 0.0 | 25000050 | 17 |
| 12 | 0.721227 | 68.391 | 0.0 | 25000036 | 15 |
| 13 | 0.622532 | 68.296 | 0.0 | 25000030 | 12 |
| 14 | 0.706464 | 68.908 | 0.0 | 25000056 | 20 |
| 15 | 0.522532 | 68.341 | 0.0 | 25000068 | 21 |

## tba3.txt (n=27, m=13)

### Estatísticas
- **Makespan:** min=0.489258, max=0.739384, média=0.539684
- **Tempo total:** min=64.291s, max=74.095s, média=66.991s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000033, max=25000080, média=2.5000055e7

### Melhor Solução (Execução 7)
- **Makespan:** 0.48925799999999997
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 1) → Operador 11
  - Segmento 2: tarefas (2, 4) → Operador 7
  - Segmento 3: tarefas (5, 8) → Operador 1
  - Segmento 4: tarefas (9, 9) → Operador 3
  - Segmento 5: tarefas (10, 12) → Operador 2
  - Segmento 6: tarefas (13, 13) → Operador 6
  - Segmento 7: tarefas (14, 15) → Operador 9
  - Segmento 8: tarefas (16, 17) → Operador 13
  - Segmento 9: tarefas (18, 19) → Operador 4
  - Segmento 10: tarefas (20, 21) → Operador 5
  - Segmento 11: tarefas (22, 23) → Operador 8
  - Segmento 12: tarefas (24, 24) → Operador 10
  - Segmento 13: tarefas (25, 27) → Operador 12

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.490612 | 66.075 | 0.0 | 25000060 | 22 |
| 2 | 0.490612 | 64.291 | 0.0 | 25000075 | 26 |
| 3 | 0.739384 | 65.089 | 0.0 | 25000042 | 15 |
| 4 | 0.534709 | 65.679 | 0.0 | 25000046 | 14 |
| 5 | 0.517435 | 66.449 | 0.0 | 25000050 | 18 |
| 6 | 0.534709 | 66.058 | 0.0 | 25000057 | 20 |
| 7 | 0.489258 | 65.705 | 0.0 | 25000064 | 25 |
| 8 | 0.534709 | 65.595 | 0.0 | 25000050 | 16 |
| 9 | 0.611963 | 66.787 | 0.0 | 25000037 | 12 |
| 10 | 0.490612 | 65.757 | 0.0 | 25000050 | 15 |
| 11 | 0.489258 | 67.14 | 0.0 | 25000080 | 24 |
| 12 | 0.534709 | 74.095 | 0.0 | 25000064 | 23 |
| 13 | 0.534709 | 68.832 | 0.0 | 25000070 | 20 |
| 14 | 0.490612 | 67.732 | 0.0 | 25000033 | 13 |
| 15 | 0.611963 | 69.588 | 0.0 | 25000044 | 17 |

## tba4.txt (n=22, m=15)

### Estatísticas
- **Makespan:** min=0.307003, max=0.531776, média=0.321988
- **Tempo total:** min=63.678s, max=72.396s, média=67.462s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000015, max=25000055, média=2.5000034e7

### Melhor Solução (Execução 1)
- **Makespan:** 0.307003
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 1) → Operador 13
  - Segmento 2: tarefas (2, 3) → Operador 11
  - Segmento 3: tarefas (4, 4) → Operador 14
  - Segmento 4: tarefas (5, 7) → Operador 7
  - Segmento 5: tarefas (8, 8) → Operador 15
  - Segmento 6: tarefas (9, 10) → Operador 1
  - Segmento 7: tarefas (11, 13) → Operador 3
  - Segmento 8: tarefas (14, 14) → Operador 4
  - Segmento 9: tarefas (15, 15) → Operador 5
  - Segmento 10: tarefas (16, 16) → Operador 8
  - Segmento 11: tarefas (17, 18) → Operador 6
  - Segmento 12: tarefas (19, 19) → Operador 9
  - Segmento 13: tarefas (20, 20) → Operador 12
  - Segmento 14: tarefas (21, 21) → Operador 2
  - Segmento 15: tarefas (22, 22) → Operador 10

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.307003 | 68.206 | 0.0 | 25000026 | 9 |
| 2 | 0.307003 | 66.065 | 0.0 | 25000048 | 15 |
| 3 | 0.307003 | 63.678 | 0.0 | 25000038 | 13 |
| 4 | 0.307003 | 66.579 | 0.0 | 25000034 | 12 |
| 5 | 0.307003 | 64.929 | 0.0 | 25000048 | 17 |
| 6 | 0.307003 | 66.287 | 0.0 | 25000055 | 20 |
| 7 | 0.307003 | 64.882 | 0.0 | 25000041 | 14 |
| 8 | 0.307003 | 66.899 | 0.0 | 25000029 | 10 |
| 9 | 0.307003 | 70.673 | 0.0 | 25000027 | 9 |
| 10 | 0.307003 | 71.998 | 0.0 | 25000028 | 12 |
| 11 | 0.307003 | 67.46 | 0.0 | 25000027 | 13 |
| 12 | 0.307003 | 72.396 | 0.0 | 25000020 | 8 |
| 13 | 0.307003 | 66.545 | 0.0 | 25000037 | 15 |
| 14 | 0.307003 | 69.72 | 0.0 | 25000015 | 4 |
| 15 | 0.531776 | 65.609 | 0.0 | 25000032 | 12 |

## tba5.txt (n=42, m=10)

### Estatísticas
- **Makespan:** min=1.491399, max=1.811768, média=1.542567
- **Tempo total:** min=70.101s, max=80.117s, média=74.635s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000032, max=25000087, média=2.5000056e7

### Melhor Solução (Execução 1)
- **Makespan:** 1.4913990000000001
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 6) → Operador 8
  - Segmento 2: tarefas (7, 11) → Operador 10
  - Segmento 3: tarefas (12, 14) → Operador 1
  - Segmento 4: tarefas (15, 19) → Operador 7
  - Segmento 5: tarefas (20, 21) → Operador 2
  - Segmento 6: tarefas (22, 27) → Operador 5
  - Segmento 7: tarefas (28, 31) → Operador 3
  - Segmento 8: tarefas (32, 35) → Operador 6
  - Segmento 9: tarefas (36, 39) → Operador 4
  - Segmento 10: tarefas (40, 42) → Operador 9

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 1.491399 | 70.101 | 0.0 | 25000037 | 14 |
| 2 | 1.500176 | 73.734 | 0.0 | 25000049 | 20 |
| 3 | 1.500176 | 70.865 | 0.0 | 25000051 | 17 |
| 4 | 1.491399 | 71.234 | 0.0 | 25000046 | 20 |
| 5 | 1.512124 | 70.814 | 0.0 | 25000075 | 27 |
| 6 | 1.491399 | 71.121 | 0.0 | 25000059 | 24 |
| 7 | 1.512124 | 72.272 | 0.0 | 25000032 | 10 |
| 8 | 1.811768 | 74.651 | 0.0 | 25000087 | 32 |
| 9 | 1.512124 | 76.196 | 0.0 | 25000086 | 25 |
| 10 | 1.811768 | 76.451 | 0.0 | 25000052 | 19 |
| 11 | 1.491399 | 78.134 | 0.0 | 25000044 | 17 |
| 12 | 1.512124 | 77.248 | 0.0 | 25000044 | 19 |
| 13 | 1.500176 | 76.521 | 0.0 | 25000041 | 17 |
| 14 | 1.500176 | 80.068 | 0.0 | 25000079 | 27 |
| 15 | 1.500176 | 80.117 | 0.0 | 25000055 | 20 |

## tba6.txt (n=37, m=13)

### Estatísticas
- **Makespan:** min=0.56668, max=0.745814, média=0.637741
- **Tempo total:** min=70.031s, max=79.26s, média=74.033s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000037, max=25000091, média=2.5000061e7

### Melhor Solução (Execução 7)
- **Makespan:** 0.56668
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 4) → Operador 7
  - Segmento 2: tarefas (5, 6) → Operador 9
  - Segmento 3: tarefas (7, 8) → Operador 8
  - Segmento 4: tarefas (9, 12) → Operador 12
  - Segmento 5: tarefas (13, 14) → Operador 6
  - Segmento 6: tarefas (15, 16) → Operador 10
  - Segmento 7: tarefas (17, 18) → Operador 4
  - Segmento 8: tarefas (19, 21) → Operador 13
  - Segmento 9: tarefas (22, 23) → Operador 2
  - Segmento 10: tarefas (24, 27) → Operador 3
  - Segmento 11: tarefas (28, 31) → Operador 5
  - Segmento 12: tarefas (32, 33) → Operador 1
  - Segmento 13: tarefas (34, 37) → Operador 11

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.745814 | 72.676 | 0.0 | 25000054 | 21 |
| 2 | 0.637799 | 75.824 | 0.0 | 25000064 | 22 |
| 3 | 0.652391 | 78.156 | 0.0 | 25000044 | 14 |
| 4 | 0.652391 | 77.869 | 0.0 | 25000037 | 19 |
| 5 | 0.599931 | 79.26 | 0.0 | 25000057 | 20 |
| 6 | 0.733931 | 70.031 | 0.0 | 25000077 | 26 |
| 7 | 0.56668 | 70.836 | 0.0 | 25000091 | 26 |
| 8 | 0.578194 | 70.92 | 0.0 | 25000053 | 21 |
| 9 | 0.652391 | 72.43 | 0.0 | 25000044 | 15 |
| 10 | 0.575433 | 71.202 | 0.0 | 25000090 | 29 |
| 11 | 0.576187 | 75.194 | 0.0 | 25000049 | 15 |
| 12 | 0.652391 | 77.347 | 0.0 | 25000074 | 24 |
| 13 | 0.637799 | 73.576 | 0.0 | 25000071 | 26 |
| 14 | 0.652391 | 71.377 | 0.0 | 25000057 | 19 |
| 15 | 0.652391 | 73.798 | 0.0 | 25000060 | 21 |

## tba7.txt (n=32, m=14)

### Estatísticas
- **Makespan:** min=0.643892, max=0.882055, média=0.738903
- **Tempo total:** min=68.117s, max=79.648s, média=72.775s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000026, max=25000089, média=2.5000051e7

### Melhor Solução (Execução 1)
- **Makespan:** 0.643892
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 2) → Operador 2
  - Segmento 2: tarefas (3, 4) → Operador 11
  - Segmento 3: tarefas (5, 7) → Operador 9
  - Segmento 4: tarefas (8, 9) → Operador 14
  - Segmento 5: tarefas (10, 11) → Operador 12
  - Segmento 6: tarefas (12, 13) → Operador 5
  - Segmento 7: tarefas (14, 17) → Operador 13
  - Segmento 8: tarefas (18, 19) → Operador 6
  - Segmento 9: tarefas (20, 20) → Operador 7
  - Segmento 10: tarefas (21, 23) → Operador 8
  - Segmento 11: tarefas (24, 26) → Operador 4
  - Segmento 12: tarefas (27, 30) → Operador 3
  - Segmento 13: tarefas (31, 31) → Operador 10
  - Segmento 14: tarefas (32, 32) → Operador 1

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.643892 | 68.117 | 0.0 | 25000064 | 21 |
| 2 | 0.643892 | 68.968 | 0.0 | 25000042 | 17 |
| 3 | 0.693194 | 70.678 | 0.0 | 25000052 | 19 |
| 4 | 0.693194 | 70.962 | 0.0 | 25000038 | 11 |
| 5 | 0.693194 | 72.963 | 0.0 | 25000056 | 19 |
| 6 | 0.718347 | 70.423 | 0.0 | 25000079 | 24 |
| 7 | 0.882055 | 72.065 | 0.0 | 25000059 | 20 |
| 8 | 0.738836 | 78.481 | 0.0 | 25000089 | 27 |
| 9 | 0.643892 | 76.658 | 0.0 | 25000049 | 16 |
| 10 | 0.704161 | 69.525 | 0.0 | 25000039 | 13 |
| 11 | 0.882055 | 79.648 | 0.0 | 25000039 | 17 |
| 12 | 0.738836 | 70.118 | 0.0 | 25000026 | 11 |
| 13 | 0.643892 | 72.972 | 0.0 | 25000041 | 14 |
| 14 | 0.882055 | 73.983 | 0.0 | 25000052 | 19 |
| 15 | 0.882055 | 76.062 | 0.0 | 25000044 | 14 |

## tba8.txt (n=27, m=11)

### Estatísticas
- **Makespan:** min=0.845763, max=0.929058, média=0.875921
- **Tempo total:** min=67.248s, max=80.543s, média=70.989s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000027, max=25000071, média=2.5000048e7

### Melhor Solução (Execução 1)
- **Makespan:** 0.845763
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 1) → Operador 8
  - Segmento 2: tarefas (2, 2) → Operador 2
  - Segmento 3: tarefas (3, 3) → Operador 10
  - Segmento 4: tarefas (4, 7) → Operador 6
  - Segmento 5: tarefas (8, 8) → Operador 9
  - Segmento 6: tarefas (9, 14) → Operador 5
  - Segmento 7: tarefas (15, 16) → Operador 4
  - Segmento 8: tarefas (17, 18) → Operador 3
  - Segmento 9: tarefas (19, 21) → Operador 1
  - Segmento 10: tarefas (22, 24) → Operador 7
  - Segmento 11: tarefas (25, 27) → Operador 11

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.845763 | 71.136 | 0.0 | 25000051 | 19 |
| 2 | 0.887153 | 75.069 | 0.0 | 25000051 | 21 |
| 3 | 0.845763 | 72.231 | 0.0 | 25000045 | 16 |
| 4 | 0.887153 | 80.543 | 0.0 | 25000049 | 21 |
| 5 | 0.929058 | 68.12 | 0.0 | 25000061 | 19 |
| 6 | 0.887153 | 71.39 | 0.0 | 25000055 | 19 |
| 7 | 0.845763 | 69.908 | 0.0 | 25000052 | 18 |
| 8 | 0.887153 | 72.552 | 0.0 | 25000027 | 12 |
| 9 | 0.905875 | 71.443 | 0.0 | 25000029 | 13 |
| 10 | 0.845763 | 69.095 | 0.0 | 25000071 | 23 |
| 11 | 0.845763 | 67.248 | 0.0 | 25000050 | 18 |
| 12 | 0.845763 | 67.798 | 0.0 | 25000053 | 22 |
| 13 | 0.845763 | 72.559 | 0.0 | 25000039 | 16 |
| 14 | 0.929058 | 67.681 | 0.0 | 25000044 | 14 |
| 15 | 0.905875 | 68.066 | 0.0 | 25000039 | 17 |

## tba9.txt (n=22, m=10)

### Estatísticas
- **Makespan:** min=0.583828, max=0.68, média=0.624214
- **Tempo total:** min=66.13s, max=76.655s, média=70.935s
- **Tempo até melhor solução:** min=0.0s, max=0.0s, média=0.0s
- **Avaliações:** min=25000025, max=25000060, média=2.5000042e7

### Melhor Solução (Execução 1)
- **Makespan:** 0.583828
- **Tempo até encontrar:** 0.0s
- **Segmentação e Operadores:**
  - Segmento 1: tarefas (1, 2) → Operador 7
  - Segmento 2: tarefas (3, 6) → Operador 8
  - Segmento 3: tarefas (7, 8) → Operador 2
  - Segmento 4: tarefas (9, 12) → Operador 5
  - Segmento 5: tarefas (13, 13) → Operador 6
  - Segmento 6: tarefas (14, 14) → Operador 3
  - Segmento 7: tarefas (15, 16) → Operador 4
  - Segmento 8: tarefas (17, 18) → Operador 10
  - Segmento 9: tarefas (19, 20) → Operador 1
  - Segmento 10: tarefas (21, 22) → Operador 9

### Resultados Detalhados

| Exec | Makespan | Tempo Total (s) | Tempo Melhor Sol (s) | Avaliações | Melhorias |
|------|----------|-----------------|---------------------|------------|-----------|
| 1 | 0.583828 | 69.81 | 0.0 | 25000045 | 18 |
| 2 | 0.583828 | 73.216 | 0.0 | 25000059 | 20 |
| 3 | 0.640664 | 75.619 | 0.0 | 25000044 | 14 |
| 4 | 0.640836 | 67.011 | 0.0 | 25000036 | 13 |
| 5 | 0.583828 | 66.13 | 0.0 | 25000054 | 21 |
| 6 | 0.640664 | 68.864 | 0.0 | 25000034 | 12 |
| 7 | 0.583828 | 72.905 | 0.0 | 25000051 | 15 |
| 8 | 0.640664 | 76.655 | 0.0 | 25000028 | 14 |
| 9 | 0.640664 | 70.498 | 0.0 | 25000060 | 20 |
| 10 | 0.68 | 68.385 | 0.0 | 25000025 | 9 |
| 11 | 0.640664 | 74.295 | 0.0 | 25000055 | 15 |
| 12 | 0.638248 | 71.96 | 0.0 | 25000033 | 13 |
| 13 | 0.640836 | 69.28 | 0.0 | 25000029 | 12 |
| 14 | 0.640836 | 69.656 | 0.0 | 25000034 | 12 |
| 15 | 0.583828 | 69.746 | 0.0 | 25000037 | 15 |

## Informações Técnicas

- **Algoritmo:** Variable Neighborhood Search (VNS)
- **Vizinhanças:** 5 tipos (swap, shift±1, shift±δ, expand+bestop, expand_delta+bestop)
- **Busca Local:** First-improvement
- **Critério de parada:** 5M iterações
- **Linguagem:** Julia 1.11.5

**Tempo total do experimento:** 179.59 minutos
