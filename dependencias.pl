% ============================================
% DEPENDENCIAS.PL
% Predicados de dependências
% ============================================

% Predicado 1: DEPENDE_DIRETO (o mais simples!)
% Significa: A depende diretamente de B
depende_direto(A, B) :-
    dependencia(A, B).

% Predicado 2: ANTERIOR (um pouco mais complexo)
% Significa: B deve vir ANTES de A
% Caso 1: B é dependência direta de A
anterior(B, A) :-
    depende_direto(A, B).

% Caso 2: B é dependência indireta (transitiva)
% B -> C -> A  então  B -> A
anterior(B, A) :-
    depende_direto(A, C),
    anterior(B, C).

% Predicado 3: CICLO_EXISTE (detecta erros)
% Se X é anterior a Y E Y é anterior a X = CICLO!
ciclo_existe :-
    anterior(X, Y),
    anterior(Y, X),
    !.  % Corta após encontrar o primeiro ciclo

% ============================================
% ORDENAMENTO TOPOLÓGICO (Algoritmo de Kahn)
% ============================================

% Coleta todos os componentes
todos_componentes(Lista) :-
    findall(C, componente(C, _, _), Lista).

% Coleta todas as dependências no formato d(A, B)
todas_arestas(Arestas) :-
    findall(d(A, B), depende_direto(A, B), Arestas).

% Verifica se componente não tem dependências pendentes
sem_dependencias(Comp, Arestas) :-
    \+ member(d(Comp, _), Arestas).

% Remove arestas relacionadas a um componente
remover_arestas(_, [], []).
remover_arestas(Comp, [d(A, Comp)|Resto], SemComp) :-
    !,
    remover_arestas(Comp, Resto, SemComp).
remover_arestas(Comp, [Aresta|Resto], [Aresta|SemComp]) :-
    remover_arestas(Comp, Resto, SemComp).

% Algoritmo principal
topologica(Ordem) :-
    \+ ciclo_existe,  % Verifica se não há ciclo
    todos_componentes(Comps),
    todas_arestas(Arestas),
    ordenar(Comps, Arestas, [], OrdemReversa),
    reverse(OrdemReversa, Ordem).

% Caso base: não há mais componentes
ordenar([], _, Acc, Acc).

% Caso recursivo: encontra componentes sem dependências
ordenar(Comps, Arestas, Acc, Ordem) :-
    % Encontra todos sem dependências
    findall(C, (member(C, Comps), sem_dependencias(C, Arestas)), SemDep),
    SemDep \= [],  % Garante que há pelo menos um
    
    % Pega o primeiro (ordem alfabética para determinismo)
    sort(SemDep, [Proximo|_]),
    
    % Remove da lista de componentes
    select(Proximo, Comps, CompsRestantes),
    
    % Remove arestas relacionadas
    remover_arestas(Proximo, Arestas, ArestasRestantes),
    
    % Continua recursivamente
    ordenar(CompsRestantes, ArestasRestantes, [Proximo|Acc], Ordem).
    
% Verifica se sequência é válida
sequencia_valida(Seq) :-
    % Verifica se tem todos os componentes
    todos_componentes(TodosComps),
    msort(Seq, SeqOrdenada),
    msort(TodosComps, CompsOrdenados),
    SeqOrdenada = CompsOrdenados,
    
    % Verifica se respeita dependências
    \+ (
        depende_direto(A, B),
        nth1(PosA, Seq, A),
        nth1(PosB, Seq, B),
        PosA < PosB  % A vem antes de B (errado!)
    ).