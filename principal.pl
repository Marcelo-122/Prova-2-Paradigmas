% ============================================
% PRINCIPAL.PL
% Arquivo principal do sistema
% ============================================

% Carrega a base de dados
:- consult('entrada.txt').

% Carrega os módulos
:- consult('componentes.pl').

% Carrega as dependências
:- consult('dependencias.pl').

% Carrega o módulo de técnicos
:- consult('tecnicos.pl').

% Predicado principal
main :-
    write('=== SISTEMA DE PLANEJAMENTO DE SATÉLITE ==='), nl, nl,
    
    % Teste 1: Listar componentes
    write('Componentes disponíveis:'), nl,
    listar_componentes(Comps),
    write(Comps), nl, nl,
    
    % Teste 2: Duração de um componente
    write('Duração da estrutura_base:'), nl,
    duracao_componente(estrutura_base, D),
    write(D), write(' dias'), nl, nl,
    
    % Teste 3: Tempo total (exemplo)
    write('Tempo total de [estrutura_base, bateria]:'), nl,
    tempo_total([estrutura_base, bateria], T),
    write(T), write(' dias'), nl.

gerar_saida :-
    open('saida.txt', write, Stream),
    
    % Cabeçalho
    write(Stream, '=== PLANEJAMENTO DE MONTAGEM DE SATÉLITE ==='), nl(Stream),
    nl(Stream),
    
    % Sequência
    write(Stream, '=== SEQUÊNCIA DE MONTAGEM ==='), nl(Stream),
    topologica(Ordem),
    numerar_componentes(Ordem, 1, Stream),
    nl(Stream),
    
    % Tempo total
    write(Stream, '=== RESUMO ==='), nl(Stream),
    length(Ordem, NumComps),
    write(Stream, 'Componentes: '), write(Stream, NumComps), nl(Stream),
    tempo_total(Ordem, Tempo),
    write(Stream, 'Tempo total: '), write(Stream, Tempo), write(Stream, ' dias'), nl(Stream),
    
    close(Stream).

numerar_componentes([], _, _).
numerar_componentes([Comp|Resto], N, Stream) :-
    duracao_componente(Comp, D),
    equipe_responsavel(Comp, E),
    write(Stream, N), write(Stream, '. '),
    write(Stream, Comp), write(Stream, ' ('),
    write(Stream, D), write(Stream, ' dias, '),
    write(Stream, E), write(Stream, ')'), nl(Stream),
    N1 is N + 1,
    numerar_componentes(Resto, N1, Stream).