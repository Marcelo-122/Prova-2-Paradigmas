% FATOS (verdades absolutas)
pai(joao, maria).
pai(joao, pedro).
pai(pedro, ana).

% REGRA (relação lógica)
avo(X, Y) :- pai(X, Z), pai(Z, Y).