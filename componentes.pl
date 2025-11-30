% ============================================
% COMPONENTES.PL
% Predicados relacionados a componentes
% ============================================

% Lista todos os componentes
listar_componentes(Lista) :-
    findall(Nome, componente(Nome, _, _), Lista).

% Obtém duração de um componente
duracao_componente(Nome, Duracao) :-
    componente(Nome, Duracao, _).

% Obtém equipe responsável
equipe_responsavel(Nome, Equipe) :-
    componente(Nome, _, Equipe).

% Tempo total de uma lista de componentes
tempo_total([], 0).
tempo_total([Comp|Resto], Total) :-
    duracao_componente(Comp, Duracao),
    tempo_total(Resto, TotalResto),
    Total is Duracao + TotalResto.