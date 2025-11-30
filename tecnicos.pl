% ============================================
% TECNICOS.PL
% Gerenciamento de técnicos e especialidades
% ============================================

% Especialidades necessárias para cada tipo de componente
especialidade_necessaria(equipe_mecanica, mecanica).
especialidade_necessaria(equipe_energia, eletrica).
especialidade_necessaria(equipe_comunicacao, comunicacao).
especialidade_necessaria(equipe_eletronica, eletronica).
especialidade_necessaria(equipe_propulsao, propulsao).
especialidade_necessaria(equipe_termica, termica).

% Técnicos e suas especialidades (extraído de entrada.txt)
tecnico_especialidade(joao, mecanica).
tecnico_especialidade(maria, mecanica).
tecnico_especialidade(carlos, eletrica).
tecnico_especialidade(ana, eletrica).
tecnico_especialidade(pedro, comunicacao).
tecnico_especialidade(lucia, eletronica).
tecnico_especialidade(roberto, eletronica).
tecnico_especialidade(fernando, propulsao).
tecnico_especialidade(beatriz, termica).

% Verifica se técnico pode trabalhar em componente
tecnico_pode_trabalhar(Tecnico, Componente) :-
    equipe_responsavel(Componente, Equipe),
    especialidade_necessaria(Equipe, Especialidade),
    tecnico_especialidade(Tecnico, Especialidade).

% Lista técnicos disponíveis para um componente
tecnicos_disponiveis(Componente, Tecnicos) :-
    findall(Tecnico,
        tecnico_pode_trabalhar(Tecnico, Componente),
        Tecnicos).

% Verifica se há técnicos suficientes
tem_tecnicos_suficientes(Componente) :-
    tecnicos_disponiveis(Componente, Tecnicos),
    length(Tecnicos, N),
    N > 0.

% Aloca técnicos para uma sequência de componentes
alocar_tecnicos([], []).
alocar_tecnicos([Comp|Resto], [(Comp, Tecnicos)|AlocRestante]) :-
    tecnicos_disponiveis(Comp, Tecnicos),
    alocar_tecnicos(Resto, AlocRestante).

% Análise de disponibilidade de técnicos
analisar_tecnicos :-
    write('=== ANÁLISE DE TÉCNICOS ==='), nl, nl,
    
    write('Técnicos por especialidade:'), nl,
    forall(
        (especialidade_necessaria(_, Espec),
         findall(T, tecnico_especialidade(T, Espec), Tecs),
         length(Tecs, N)),
        (
            write('  '), write(Espec), write(': '),
            write(N), write(' técnico(s) - '), write(Tecs), nl
        )
    ),
    nl,
    
    write('Alocação de técnicos por componente:'), nl,
    topologica(Ordem),
    alocar_tecnicos(Ordem, Alocacao),
    mostrar_alocacao(Alocacao).

mostrar_alocacao([]).
mostrar_alocacao([(Comp, Tecnicos)|Resto]) :-
    write('  '), write(Comp), write(': '), write(Tecnicos), nl,
    mostrar_alocacao(Resto).

% Exporta para arquivo
exportar_analise_tecnicos(Stream) :-
    write(Stream, '=== ALOCAÇÃO DE TÉCNICOS ==='), nl(Stream),
    nl(Stream),
    
    topologica(Ordem),
    alocar_tecnicos(Ordem, Alocacao),
    exportar_alocacao(Alocacao, Stream).

exportar_alocacao([], _).
exportar_alocacao([(Comp, Tecnicos)|Resto], Stream) :-
    write(Stream, '  '), write(Stream, Comp),
    write(Stream, ': '), write(Stream, Tecnicos),
    nl(Stream),
    exportar_alocacao(Resto, Stream).