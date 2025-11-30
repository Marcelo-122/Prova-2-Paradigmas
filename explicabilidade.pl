% ============================================
% EXPLICABILIDADE.PL
% Predicados para explicar decisões do sistema
% ============================================

% ----------------------------------------
% 1. EXPLICA POR QUE UM COMPONENTE ESTÁ NA POSIÇÃO
% ----------------------------------------
explicar_posicao(Componente, Sequencia) :-
    write('EXPLICAÇÃO: Posição de '), write(Componente), 
    write(' na sequência'), nl, nl,
    
    % Encontra posição
    nth1(Posicao, Sequencia, Componente),
    write(Componente), 
    write(' está na posição '), write(Posicao), nl, nl,
    
    % Explica dependências que forçam essa posição
    write('Dependências que exigem essa ordem:'), nl,
    explicar_dependencias_anteriores(Componente, Sequencia),
    nl,
    
    % Explica o que depende deste componente
    write('Componentes que dependem de '), write(Componente), write(':'), nl,
    explicar_dependencias_posteriores(Componente, Sequencia),
    nl.

explicar_dependencias_anteriores(Componente, Sequencia) :-
    findall(Dep,
        (depende_direto(Componente, Dep),
         member(Dep, Sequencia)),
        Dependencias),
    (Dependencias = [] ->
        write('Nenhuma (pode ser feito primeiro)'), nl
    ;
        forall(member(Dep, Dependencias),
            (
                nth1(PosDep, Sequencia, Dep),
                nth1(PosComp, Sequencia, Componente),
                write('->'), write(Dep),
                write(' (posição '), write(PosDep),
                write(') deve vir antes da posição '), write(PosComp),
                nl
            ))
    ).

explicar_dependencias_posteriores(Componente, Sequencia) :-
    findall(Dep,
        (depende_direto(Dep, Componente),
         member(Dep, Sequencia)),
        Dependentes),
    (Dependentes = [] ->
        write('Nenhum (não bloqueia outros componentes)'), nl
    ;
        forall(member(Dep, Dependentes),
            (
                nth1(PosDep, Sequencia, Dep),
                write('->'), write(Dep),
                write(' (posição '), write(PosDep),
                write(') só pode começar após este'), nl
            ))
    ).

% ----------------------------------------
% 2. EXPLICA POR QUE UMA SEQUÊNCIA É INVÁLIDA
% ----------------------------------------
explicar_invalida(Sequencia) :-
    write('ANÁLISE: Por que essa sequência é INVÁLIDA?'), nl, nl,
    
    % Verifica completude
    (verifica_completude(Sequencia) ->
        write('Completude: OK (todos os componentes presentes)'), nl
    ;
        write('ERRO: Faltam componentes ou há duplicatas!'), nl,
        mostrar_componentes_faltantes(Sequencia),
        nl
    ),
    
    % Verifica violações de dependências
    write('Verificando dependências...'), nl,
    (encontrar_violacoes(Sequencia, Violacoes) ->
        write('VIOLAÇÕES ENCONTRADAS:'), nl, nl,
        explicar_violacoes(Violacoes, Sequencia)
    ;
        write('Todas as dependências respeitadas'), nl
    ),
    nl.

verifica_completude(Sequencia) :-
    todos_componentes(TodosComps),
    msort(Sequencia, SeqOrd),
    msort(TodosComps, CompsOrd),
    SeqOrd = CompsOrd.

mostrar_componentes_faltantes(Sequencia) :-
    todos_componentes(Todos),
    subtract(Todos, Sequencia, Faltantes),
    (Faltantes \= [] ->
        write('  Faltantes: '), write(Faltantes), nl
    ; true),
    subtract(Sequencia, Todos, Extras),
    (Extras \= [] ->
        write('  Componentes inválidos: '), write(Extras), nl
    ; true).

encontrar_violacoes(Sequencia, Violacoes) :-
    findall(v(A, B, PosA, PosB),
        (depende_direto(A, B),
         nth1(PosA, Sequencia, A),
         nth1(PosB, Sequencia, B),
         PosA < PosB),  % A vem antes de B (ERRADO!)
        Violacoes),
    Violacoes \= [].

explicar_violacoes([], _).
explicar_violacoes([v(A, B, PosA, PosB)|Resto], Sequencia) :-
    write(' VIOLAÇÃO:'), nl,
    write('   '), write(A), write(' (posição '), write(PosA), write(')'),
    write(' vem ANTES de '), nl,
    write('   '), write(B), write(' (posição '), write(PosB), write(')'), nl,
    write('   MAS '), write(A), write(' DEPENDE de '), write(B), write('!'), nl,
    write('    Solução: '), write(B), 
    write(' deve vir antes de '), write(A), nl, nl,
    explicar_violacoes(Resto, Sequencia).

% ----------------------------------------
% 3. EXPLICA O CAMINHO DE DEPENDÊNCIAS
% ----------------------------------------
explicar_caminho(De, Para) :-
    write('CAMINHO DE DEPENDÊNCIAS'), nl,
    write('De: '), write(De), nl,
    write('Para: '), write(Para), nl, nl,
    
    (encontrar_caminho(De, Para, Caminho) ->
        write(' Existe caminho de dependências:'), nl,
        mostrar_caminho(Caminho)
    ;
        write(' Não há dependência entre esses componentes'), nl
    ),
    nl.

encontrar_caminho(De, Para, [De, Para]) :-
    depende_direto(Para, De).

encontrar_caminho(De, Para, [De|Resto]) :-
    depende_direto(Intermediario, De),
    encontrar_caminho(Intermediario, Para, Resto).

mostrar_caminho([_]).
mostrar_caminho([A, B|Resto]) :-
    write('  '), write(A), write(' → '), write(B),
    duracao_componente(A, D),
    write(' ('), write(A), write(' leva '), write(D), write(' dias)'),
    nl,
    mostrar_caminho([B|Resto]).

% ----------------------------------------
% 4. EXPLICA O TEMPO TOTAL
% ----------------------------------------
explicar_tempo_total(Sequencia) :-
    write('=== EXPLICAÇÃO: Tempo Total ==='), nl, nl,
    
    tempo_total(Sequencia, Total),
    write('⏱️  Tempo total: '), write(Total), write(' dias'), nl, nl,
    
    write('📊 Detalhamento por componente:'), nl,
    explicar_tempos_individuais(Sequencia, 0, Total).

explicar_tempos_individuais([], Acumulado, Total) :-
    write(nl),
    write('✓ Total acumulado: '), write(Acumulado), write(' dias'), nl.

explicar_tempos_individuais([Comp|Resto], Acumulado, Total) :-
    duracao_componente(Comp, Duracao),
    NovoAcum is Acumulado + Duracao,
    Percentual is (Duracao / Total) * 100,
    format('  ~w: ~w dias (~1f% do total)~n', [Comp, Duracao, Percentual]),
    explicar_tempos_individuais(Resto, NovoAcum, Total).

% ----------------------------------------
% 5. RELATÓRIO COMPLETO
% ----------------------------------------
relatorio_completo :-
    write('RELATÓRIO COMPLETO DE PLANEJAMENTO'), nl,
    topologica(Seq),
    
    write('SEQUÊNCIA DE MONTAGEM'), nl,
    write('─────────────────────────'), nl,
    numerar_sequencia(Seq, 1), nl,
    
    write('ANÁLISE DE TEMPO'), nl,
    write('─────────────────────────'), nl,
    explicar_tempo_total(Seq), nl,
    
    write('COMPONENTES CRÍTICOS'), nl,
    write('─────────────────────────'), nl,
    identificar_componentes_criticos(Seq), nl,
    
    write('DEPENDÊNCIAS COMPLEXAS'), nl,
    write('─────────────────────────'), nl,
    listar_dependencias_complexas, nl.

numerar_sequencia([], _).
numerar_sequencia([Comp|Resto], N) :-
    duracao_componente(Comp, D),
    equipe_responsavel(Comp, E),
    format('  ~d. ~w (~w dias, ~w)~n', [N, Comp, D, E]),
    N1 is N + 1,
    numerar_sequencia(Resto, N1).

identificar_componentes_criticos(Sequencia) :-
    forall(member(Comp, Sequencia),
        (
            findall(Dep, depende_direto(Dep, Comp), Dependentes),
            length(Dependentes, NumDep),
            (NumDep > 2 ->
                format('  ~w: ~w componentes dependem dele~n', [Comp, NumDep])
            ; true)
        )).

listar_dependencias_complexas :-
    forall(
        (depende_direto(A, B),
         findall(C, (depende_direto(A, C), C \= B), OutrasDeps),
         OutrasDeps \= []),
        (
            format('  -> ~w depende de: ~w e ~w~n', [A, B, OutrasDeps])
        )
    ).