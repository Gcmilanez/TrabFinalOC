Os arquivos de entrega estão na pasta "essenciais" e consistem basicamente nos códigos do solver genérico e do VNS, e
também o relatório final do trabalho.

Dentro da pasta extras, encontram-se os dados que nós coletamos durante o estudo, os codigos auxiliares usados pra coleta
de dados, e a heuristica inicial sequencial (alternativa) para o VNS e os slides usado para apresentação em aula, e se 
encontram organizados da seguinte forma:

📁 extras
│
├── 📂 codigo-aux
│   ├── 📂 scrits-coleta-dados
│   │   └── coleta_dados_vns.jl 
│   │   └── coleta_dados_solver.jl
│   │
│   └── 📂 SI-deterministica
│       └── VNS-SI-deterministica.jl
│ 
│
├── 📂 dados coletados
│   ├── 📂 1-hora-solver-1a5
│   │   └── relatorio_solver_1-5_1h.md
│   │
│   ├── 📂 3-horas-solver-todas
│   │   └── relatorio_solver_1-5_3h.md
│   │   └── relatorio_solver_6-10_3h.md
│   │
│   ├── 📂 VNS-10-Interações-deterministico
│   │   └── deterministica.md
│   │
│   └── 📂 VNS-30-interações
│       └── relatorio_vns-30-interacoes.md
│
│
└── 📂 slides
       └── VNS + TB.pdf

OBS.: os codigos da pasta scrits-coleta-dados não funcionam através da linha de comando, para rodar usamos sequencialmente
os 3 seguintes comandos:
1 julia
2 include("<nome do arquivo>")
3 main ()

isso rodará os scripts nas mesmas condições que nós rodamos para coletar os dados