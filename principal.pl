% ============================================
% PRINCIPAL.PL
% Arquivo principal do sistema
% ============================================

% Carrega a base de dados
:- consult('entrada.txt').

% Carrega os módulos
:- consult('componentes.pl').
:- consult('dependencias.pl').
:- consult('explicabilidade.pl').
:- consult('tecnicos.pl').

% ============================================
% PREDICADO PRINCIPAL
% ============================================
main :-
    write('SISTEMA DE PLANEJAMENTO DE SATÉLITE'), nl, 
    % Teste 1: Listar componentes
    write('COMPONENTES DISPONÍVEIS:'), nl,
    write('─────────────────────────────'), nl,
    listar_componentes(Comps),
    length(Comps, NumComps),
    format('Total: ~w componentes~n', [NumComps]),
    forall(member(C, Comps), (write('  • '), write(C), nl)),
    nl,
    
    % Teste 2: Verificar ciclos
    write('VERIFICAÇÃO DE CICLOS:'), nl,
    write('─────────────────────────────'), nl,
    (ciclo_existe ->
        write('ERRO: Ciclo detectado! Dependências circulares.'), nl
    ;
        write('OK: Não há ciclos no grafo de dependências.'), nl
    ),
    nl,
    
    % Teste 3: Ordenamento topológico
    write('SEQUÊNCIA DE MONTAGEM:'), nl,
    write('─────────────────────────────'), nl,
    topologica(Ordem),
    numerar_lista_simples(Ordem, 1),
    nl,
    
    % Teste 4: Tempo total
    write('TEMPO TOTAL:'), nl,
    write('─────────────────────────────'), nl,
    tempo_total(Ordem, Tempo),
    format('Tempo total sequencial: ~w dias~n', [Tempo]),
    nl,
    
    % Teste 5: Dependências
    write('EXEMPLOS DE DEPENDÊNCIAS:'), nl,
    write('─────────────────────────────'), nl,
    write('paineis_solares depende de: '),
    (depende_direto(paineis_solares, Dep1) -> write(Dep1) ; write('nada')),
    nl,
    write('sensores depende de: '),
    (depende_direto(sensores, Dep2) -> write(Dep2) ; write('nada')),
    nl,
    nl,
    
    write('Sistema carregado com sucesso!'), nl,
    write('Execute: gerar_saida. para criar o arquivo de saída'), nl.

% Helper para numerar lista simples
numerar_lista_simples([], _).
numerar_lista_simples([Item|Resto], N) :-
    format('  ~d. ~w~n', [N, Item]),
    N1 is N + 1,
    numerar_lista_simples(Resto, N1).

% ============================================
% GERAÇÃO DO ARQUIVO DE SAÍDA
% ============================================
gerar_saida :-
    write('Gerando arquivo saida.txt...'), nl,
    open('saida.txt', write, Stream),
    
    % CABEÇALHO
    write(Stream, 'PLANEJAMENTO DE MONTAGEM DE SATÉLITE'), nl(Stream),
    nl(Stream),
    
    % SEQUÊNCIA DE MONTAGEM
    write(Stream, 'SEQUÊNCIA DE MONTAGEM'), nl(Stream),
    topologica(Ordem),
    numerar_componentes(Ordem, 1, Stream),
    nl(Stream),

    % CRONOGRAMA
    write(Stream, 'CRONOGRAMA'), nl(Stream),
    gerar_cronograma(Ordem, 1, Stream),
    nl(Stream),
    
    % Calcula tempo total
    tempo_total(Ordem, Tempo),
    write(Stream, 'Tempo total: '), write(Stream, Tempo), 
    write(Stream, ' dias'), nl(Stream),
    
    % Identifica caminho crítico (componentes que levam ao maior tempo)
    identificar_caminho_critico_basico(Ordem, Stream),
    nl(Stream),
    
    % RESUMO
    write(Stream, 'RESUMO'), nl(Stream),
    length(Ordem, NumComps),
    write(Stream, 'Componentes: '), write(Stream, NumComps), nl(Stream),
    
    % Contagem de dependências
    findall(_, depende_direto(_, _), Deps),
    length(Deps, NumDeps),
    write(Stream, 'Dependências: '), write(Stream, NumDeps), nl(Stream),
    
    % Contagem de equipes
    findall(E, equipe(E, _), Equipes),
    length(Equipes, NumEquipes),
    write(Stream, 'Equipes: '), write(Stream, NumEquipes), nl(Stream),
    
    write(Stream, 'Tempo total: '), write(Stream, Tempo), 
    write(Stream, ' dias'), nl(Stream),
    nl(Stream),
    exportar_analise_tecnicos(Stream),    %Técnicos
    close(Stream),
    write('✓ Arquivo saida.txt gerado com sucesso!'), nl.

% HELPERS PARA GERAÇÃO DE SAÍDA
% Numera componentes com detalhes
numerar_componentes([], _, _).
numerar_componentes([Comp|Resto], N, Stream) :-
    duracao_componente(Comp, Duracao),
    equipe_responsavel(Comp, Equipe),
    
    % Formata: "1. estrutura_base (5 dias, equipe_mecanica)"
    write(Stream, N), write(Stream, '. '),
    write(Stream, Comp), write(Stream, ' ('),
    write(Stream, Duracao), write(Stream, ' dias, '),
    write(Stream, Equipe), write(Stream, ')'),
    
    % Adiciona dependências se houver
    (depende_direto(Comp, Dep) ->
        write(Stream, ' [após '), write(Stream, Dep), write(Stream, ']')
    ; true),
    
    nl(Stream),
    N1 is N + 1,
    numerar_componentes(Resto, N1, Stream).

% Gera cronograma com dias de início e fim
gerar_cronograma([], _, _).
gerar_cronograma([Comp|Resto], DiaInicio, Stream) :-
    duracao_componente(Comp, Duracao),
    DiaFim is DiaInicio + Duracao - 1,
    
    % Formata: "Dias 1-5: estrutura_base"
    format(Stream, 'Dias ~d-~d: ~w~n', [DiaInicio, DiaFim, Comp]),
    
    ProximoDia is DiaFim + 1,
    gerar_cronograma(Resto, ProximoDia, Stream).

% Identifica componentes do caminho crítico (versão básica)
identificar_caminho_critico_basico(Ordem, Stream) :-
    write(Stream, 'Caminho crítico: '),
    
    % Encontra componentes que têm dependentes (estão no caminho crítico)
    findall(Comp,
        (member(Comp, Ordem),
         depende_direto(_, Comp)),
        Criticos),
    
    % Remove duplicatas e imprime
    list_to_set(Criticos, CriticosUnicos),
    imprimir_lista(CriticosUnicos, Stream),
    nl(Stream).

% Helper para imprimir lista separada por vírgulas
imprimir_lista([], _).
imprimir_lista([Ultimo], Stream) :-
    write(Stream, Ultimo), !.
imprimir_lista([Primeiro|Resto], Stream) :-
    write(Stream, Primeiro),
    write(Stream, ', '),
    imprimir_lista(Resto, Stream).

% TESTES INTERATIVOS
% Teste 1: Explicar por que estrutura_base é primeiro
teste_explicacao_1 :-
    nl,
    write('TESTE 1: Explicação de Posição'), nl,
    nl,
    topologica(Seq),
    explicar_posicao(estrutura_base, Seq).

% Teste 2: Explicar sequência inválida
teste_explicacao_2 :-
    nl,
    write('TESTE 2: Análise de Sequência Inválida'), nl,
    nl,
    explicar_invalida([paineis_solares, estrutura_base, bateria]).

% Teste 3: Explicar caminho de dependências
teste_explicacao_3 :-
    nl,
    write('TESTE 3: Caminho de Dependências'), nl,
    nl,
    explicar_caminho(estrutura_base, sensores).

% Teste 4: Relatório completo
teste_relatorio :-
    nl,
    relatorio_completo.

% Teste 5: Análise da extensão escolhida
% Descomente APENAS a extensão que você implementou
teste_extensao :-
    nl,
    write('TESTE 5: Análise da Extensão'), nl,
    nl,
    analisar_tecnicos.

% Teste 6: Validação de sequência
teste_validacao :-
    nl,
    write('TESTE 6: Validação de Sequências'), nl,
    nl,
    
    topologica(SeqValida),
    write('Sequência válida:'), nl,
    write(SeqValida), nl,
    (sequencia_valida(SeqValida) ->
        write('✓ Validação: APROVADA'), nl
    ;
        write('✗ Validação: REPROVADA'), nl
    ),
    nl,
    
    write('Sequência inválida (teste):'), nl,
    SeqInvalida = [paineis_solares, estrutura_base, bateria],
    write(SeqInvalida), nl,
    (sequencia_valida(SeqInvalida) ->
        write('✓ Validação: APROVADA'), nl
    ;
        write('✗ Validação: REPROVADA (esperado)'), nl
    ).
