# Prova-2-Paradigmas
Problemas Lógicos usando Prolog

# 🛰️ Sistema de Planejamento de Montagem de Satélite

Sistema especialista em Prolog para planejamento e otimização da montagem de satélites.

---


## 📋 Descrição do Projeto

Este sistema modela o planejamento de montagem de um satélite considerando:

- **10 componentes** interdependentes (estrutura, painéis, sensores, etc.)
- **9 dependências** entre componentes (precedências obrigatórias)
- **6 equipes especializadas** responsáveis pela montagem
- **Ordenamento topológico** para determinar sequência válida
- **Análise de tempo** e identificação de componentes críticos
- **Explicabilidade** completa das decisões do sistema

### 🎯 Objetivos

1. Gerar **sequência válida** de montagem respeitando dependências
2. **Detectar erros** (ciclos, dependências inválidas)
3. **Calcular tempo total** do projeto
4. **Explicar decisões** de forma transparente
5. **Otimizar** através de análise de caminho crítico

---

## 📂 Estrutura de Arquivos
```
trabalho-prolog/
├── entrada.txt              # Base de conhecimento (fatos)
├── saida.txt                # Resultados gerados (criado automaticamente)
├── principal.pl             # Arquivo principal e menu
├── componentes.pl           # Predicados sobre componentes
├── dependencias.pl          # Ordenamento topológico e dependências
├── explicabilidade.pl       # Sistema de explicações
├── caminho_critico.pl       # Extensão: análise de caminho crítico
└── README.md                 
```

---

## 🚀 Como Executar

### **Pré-requisitos**
- SWI-Prolog instalado (https://www.swi-prolog.org/download/stable)

### **Passo 1: Abrir o SWI-Prolog**
```bash
swipl
```

### **Passo 2: Carregar o Sistema**
```prolog
?- [principal].
```

#### **Passo 3: Execução Direta**
```prolog
% Executar sistema básico
?- main.

% Gerar arquivo de saída
?- gerar_saida.

% Testes específicos
?- teste_explicacao_1.
?- teste_explicacao_2.
?- teste_extensao.

```

---

## 🔧 Predicados Principais

### **1. Predicados Básicos**

| Predicado | Descrição | Exemplo |
|-----------|-----------|---------|
| `listar_componentes/1` | Lista todos os componentes | `?- listar_componentes(L).` |
| `duracao_componente/2` | Obtém duração de um componente | `?- duracao_componente(estrutura_base, D).` |
| `tempo_total/2` | Calcula tempo total de uma sequência | `?- tempo_total([...], T).` |

### **2. Predicados de Dependências**

| Predicado | Descrição | Exemplo |
|-----------|-----------|---------|
| `depende_direto/2` | Verifica dependência direta | `?- depende_direto(paineis_solares, X).` |
| `anterior/2` | Verifica precedência (transitiva) | `?- anterior(estrutura_base, sensores).` |
| `ciclo_existe/0` | Detecta ciclos no grafo | `?- ciclo_existe.` |
| `topologica/1` | Gera ordenamento topológico | `?- topologica(O).` |
| `sequencia_valida/1` | Valida uma sequência proposta | `?- sequencia_valida([...]).` |

### **3. Predicados de Explicabilidade**

| Predicado | Descrição | Exemplo |
|-----------|-----------|---------|
| `explicar_posicao/2` | Explica por que componente está em posição X | `?- explicar_posicao(estrutura_base, Seq).` |
| `explicar_invalida/1` | Explica por que sequência é inválida | `?- explicar_invalida([...]).` |
| `explicar_caminho/2` | Mostra caminho de dependências | `?- explicar_caminho(A, B).` |
| `explicar_tempo_total/1` | Detalha cálculo de tempo | `?- explicar_tempo_total(Seq).` |
| `relatorio_completo/0` | Gera relatório completo | `?- relatorio_completo.` |

---

## 📊 Exemplos de Uso

### **Exemplo 1: Gerar Sequência de Montagem**
```prolog
?- topologica(Ordem).
Ordem = [estrutura_base, paineis_solares, bateria, antena_principal,
         computador_bordo, transceptor, sensores, propulsores,
         tanque_combustivel, sistema_termico].
```

### **Exemplo 2: Validar Sequência**
```prolog
% Sequência VÁLIDA
?- sequencia_valida([estrutura_base, paineis_solares, bateria]).
true.

% Sequência INVÁLIDA (paineis antes da estrutura)
?- sequencia_valida([paineis_solares, estrutura_base]).
false.
```

### **Exemplo 3: Calcular Tempo Total**
```prolog
?- topologica(O), tempo_total(O, T).
O = [estrutura_base, paineis_solares, ...],
T = 30.  % 30 dias no total
```

### **Exemplo 4: Explicar Por Que Sequência É Inválida**
```prolog
?- explicar_invalida([paineis_solares, estrutura_base, bateria]).

=== ANÁLISE: Por que essa sequência é INVÁLIDA? ===

✓ Completude: OK (todos os componentes presentes)
Verificando dependências...
✗ VIOLAÇÕES ENCONTRADAS:

❌ VIOLAÇÃO:
   paineis_solares (posição 1) vem ANTES de
   estrutura_base (posição 2)
   MAS paineis_solares DEPENDE de estrutura_base!
   🔧 Solução: estrutura_base deve vir antes de paineis_solares
```
---

## 📝 Arquivo de Saída

O arquivo `saida.txt` contém:

1. **Sequência de Montagem**: Ordem completa com durações e equipes
2. **Cronograma**: Dias de início e fim de cada componente
3. **Tempo Total**: Duração total do projeto
4. **Caminho Crítico**: Componentes que não podem atrasar
5. **Análise de Folgas**: Componentes com margem de atraso
6. **Resumo Estatístico**: Número de componentes, dependências e equipes

---