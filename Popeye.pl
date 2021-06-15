%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Predicados dinâmicos			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic pontuacao/1.
:- dynamic ultimapos/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Fatos e Regras					%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%insere no final de uma lista(utilizada na regra reverse)
insereFinal(X,[],[X]).
insereFinal(X,[Y|L], [Y|W]):-	insereFinal(X, L, W).

%inverte as posições de uma lista
reverse([], []).
reverse([X], [X]).
reverse([X|R], L):-	reverse(R, W), insereFinal(X, W, L).

%pega o primeiro elemento de uma lista
pegaPrimeiro([Cabeca|_], Cabeca).

%verifica se existe um elemento em uma lista
pertence(Elem, [Elem|_]).
pertence(Elem, [_|Cauda]) :- pertence(Elem, Cauda).

%concatena duas listas
concatenar([], Lista, Lista).
concatenar([Elem|Lista1], Lista2, [Elem|Lista3]) :-
    concatenar(Lista1, Lista2, Lista3).
	
%calcula os pontos dos corações adiquiridos
calcular(Andar) :-
	Andar1 is (Andar + 1),
	Pts is (Andar1 * 100),
	retract(pontuacao(Pontos)),
	PontuacaoFinal is (Pontos + Pts),
	asserta(pontuacao(PontuacaoFinal)).

%inicializa os predicados dinâmicos
inicializa :-
	asserta(pontuacao(0)),
	asserta(ultimapos([])).

%recolhe os corações e calcula e imprime a pontuação(recursiva)
coleta_coracoes([], _, _, _, _).
coleta_coracoes([Cabeca|Cauda], Inicio, Escadas, Garrafas, Brutus) :-
	Objetivo = Cabeca,
	busca_em_largura(Inicio, Escadas, Garrafas, Brutus, 0, Objetivo, CaminhoObjetivo),
	pegaPrimeiro(CaminhoObjetivo, I),
	pegaPrimeiro(Cabeca, Andar),
	calcular(Andar),
	write('Coracao na posicao '),
	write(I),
	write(' coletado pelo seguinte caminho:'),
	reverse(CaminhoObjetivo, CaminhoCorreto),
	writeln(CaminhoCorreto),
	write('Pontuacao atual: '),
	pontuacao(Pontuacao),
	writeln(Pontuacao),
	retract(ultimapos(L)),
	pegaPrimeiro(CaminhoObjetivo, U),
	asserta(ultimapos(U)),
	coleta_coracoes(Cauda, I, Escadas, Garrafas, Brutus).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Verificações para movimentar		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%verifica se existe duas garrafas ou uma garrafa e um Brutus em sequência(pelo lado direito)
verificaDoisObstaculosDireita([X, Y], Escadas, Garrafas, Brutus) :-
	Yproximo is Y+1,
	pertence([X, Y], Garrafas),
	(pertence([X, Yproximo], Garrafas);[X,Yproximo]==Brutus).

%verifica se existe duas garrafas ou uma garrafa e um Brutus em sequência(pelo lado esquerdo)
verificaDoisObstaculosEsquerda([X, Y], Escadas, Garrafas, Brutus) :-
	Yanterior is Y-1,
	pertence([X, Y], Garrafas),
	(pertence([X, Yanterior], Garrafas);[X,Yanterior]==Brutus).
	
%verifica se existe um caminho pela direita e se o Popeye pode passar
verificaDireita([X, Y], Escadas, Garrafas, Brutus, TemEspinafre) :-
	Y=<9,
	\+ verificaDoisObstaculosDireita([X, Y], Escadas, Garrafas, Brutus),
	\+ ([X,Y]==Brutus,TemEspinafre==0).
	
%verifica se existe um caminho pela esquerda e se o Popeye pode passar
verificaEsquerda([X, Y], Escadas, Garrafas, Brutus, TemEspinafre) :-
	Y>=0,
	\+verificaDoisObstaculosEsquerda([X, Y], Escadas, Garrafas, Brutus),
	\+ ([X,Y]==Brutus,TemEspinafre==0).

%verifica se existe um caminho por cima e se o Popeye pode passar
verificaAcima([X, Y], Escadas, Garrafas, Brutus) :-	
	X=<4,
	Xabaixo is X-1,
	pertence([Xabaixo, Y], Escadas),
	\+pertence([X, Y], Garrafas).

%verifica se existe um caminho por baixo e se o Popeye pode passar
verificaAbaixo([X, Y], Escadas, Garrafas, Brutus) :-
	X>=0,
	Xacima is X+1,
	pertence([X, Y], Escadas),
	\+pertence([Xacima, Y], Garrafas).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Movimentações					%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%movimenta para direita e chama a regra para verificar
prox([X, Y], Escadas, Garrafas, Brutus, TemEspinafre, [X, Yprox]) :-
	Yprox is Y+1,
	verificaDireita([X, Yprox], Escadas, Garrafas, Brutus, TemEspinafre).
	
	%movimenta para esquerda e chama a regra para verificar
prox([X, Y], Escadas, Garrafas, Brutus, TemEspinafre, [X, Yant]) :-
	Yant is Y-1,
	verificaEsquerda([X, Yant], Escadas, Garrafas, Brutus, TemEspinafre).

	%pula uma garrafa pela direita(caso possível)
prox([X, Y], Escadas, Garrafas, Brutus, TemEspinafre, [X, Ypulo]) :-
	Yprox is Y+1,
	pertence([X,Yprox], Garrafas),
	\+ verificaDoisObstaculosDireita([X, Yprox], Escadas, Garrafas, Brutus),
	Ypulo is Y+2.
	
	%pula uma garrafa pela esquerda(caso possível)
prox([X, Y], Escadas, Garrafas, Brutus, TemEspinafre, [X, Ypulo]) :-
	Yant is Y-1,
	pertence([X,Yant], Garrafas),
	\+ verificaDoisObstaculosEsquerda([X, Yant], Escadas, Garrafas, Brutus),
	Ypulo is Y-2.
	
	%movimenta para cima e chama a regra para verificar
prox([X, Y], Escadas, Garrafas, Brutus, _, [Xprox, Y]) :-	
	Xprox is X+1,
	verificaAcima([Xprox, Y], Escadas, Garrafas, Brutus).
	
	%movimenta para baixo e chama a regra para verificar
prox([X, Y], Escadas, Garrafas, Brutus, _, [Xant, Y]) :-
	Xant is X-1,
	verificaAbaixo([Xant, Y], Escadas, Garrafas, Brutus).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Busca em largura				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

busca_em_largura(Inicio, Escadas, Garrafas, Brutus, TemEspinafre, Objetivo, Solucao) :-
	b_l([[Inicio]], Escadas, Garrafas, Brutus, TemEspinafre, Objetivo, Solucao). 

b_l([[Estado|Caminho]|_], _, _, _, _, Objetivo, [Estado|Caminho]) :-
	Objetivo == Estado.

b_l([Primeiro|Restante], Escadas, Garrafas, Brutus, TemEspinafre, Objetivo, Solucao) :-
	extende(Primeiro, Sucessores, Escadas, Garrafas, Brutus, TemEspinafre),
	concatenar(Restante, Sucessores, NovaFronteira),
	b_l(NovaFronteira, Escadas, Garrafas, Brutus, TemEspinafre, Objetivo, Solucao).

extende([Estado|Caminho], ListaSucessores, Escadas, Garrafas, Brutus, TemEspinafre) :-
	bagof([Sucessor, Estado|Caminho],
	(prox(Estado, Escadas, Garrafas, Brutus, TemEspinafre, Sucessor), 
	\+ pertence(Sucessor, [Estado|Caminho])),ListaSucessores),
	!. 
extende( _ ,[], _,_,_,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Criar fases aleatorias				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%chama a main com a predefinição da fase fácil(corações, espinafre e Brutus são aleatórios)
facil(Inicio) :- 
	(Inicio >= 0,
	Inicio < 10,
	Inicio =\= 3,
	Inicio =\= 4,
	Inicio =\= 5,
	Inicio =\= 6 ->
	random(3, 9, Cora1),
	random(6, 9, Cora2),
	random(4, 7, Cora3),
	random(2, 4, Espina),
	random(7, 9, Brut),
	main([0,Inicio], [[0,3],[0,6],[1,2],[2,5],[3,3]], [[0,4],[0,5],[2,1],[3,8],[4,1],[4,5]], 
	[4,Espina], [4,Brut], [[1,Cora1], [2,Cora2], [3,Cora3]], Solucao)
	).
	
%chama a main com a predefinição da fase médio(corações, espinafre e Brutus são aleatórios)
medio(Inicio) :- 
	(Inicio >= 0,
	Inicio < 10,
	Inicio =\= 2,
	Inicio =\= 5,
	Inicio =\= 6,
	Inicio =\= 7 ->
	random(1, 4, Cora1),
	random(0, 2, Cora2),
	random(6, 8, Cora3),
	random(4, 7, Cora4),
	random(6, 7, Espina),
	random(4, 9, Brut),
	main([0,Inicio], [[0,2],[0,7],[1,0],[2,9],[3,3]], [[0,5],[0,6],[1,5],[2,3],[2,5],[3,8],
	[4,1],[4,2]], [1,Espina], [4,Brut], [[1,Cora1], [2,Cora2], [2,Cora3], [3,Cora4]], Solucao)
	).
	
%chama a main com a predefinição da fase difícil(corações, espinafre e Brutus são aleatórios)
dificil(Inicio) :- 
	(Inicio >= 0,
	Inicio < 10,
	Inicio =\= 1,
	Inicio =\= 4,
	Inicio =\= 7 ->
	random(2, 5, Cora1),
	random(6, 8, Cora2),
	random(3, 6, Cora3),
	random(0, 2, Cora4),
	random(1, 3, Cora5),
	random(0, 1, Espina),
	main([0,Inicio], [[0,4],[1,8],[2,0],[2,9],[3,1],[3,6]], [[0,1],[0,7],[1,6],[2,4],
	[2,5],[3,3],[3,4],[3,8],[4,7]], [1,Espina], [4,9], [[1,Cora1], [2,Cora2], [4,Cora3], 
	[4,Cora4], [2,Cora5]], Solucao)
	).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Main(realiza a busca)			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
main(Inicio, Escadas, Garrafas, Espinafre, Brutus, Coracoes, Solucao) :-
	inicializa,
	coleta_coracoes(Coracoes, Inicio, Escadas, Garrafas, Brutus),
	ultimapos(UltimaPos),
	busca_em_largura(UltimaPos, Escadas, Garrafas, Brutus, 0, Espinafre, CaminhoEspinafre),
	reverse(CaminhoEspinafre, CaminhoECerto),
	write('Espinafre na posicao '),
	write(Espinafre),
	write(' coletado pelo seguinte caminho:'),
	writeln(CaminhoECerto),
	busca_em_largura(Espinafre, Escadas, Garrafas, Brutus, 1, Brutus, CaminhoBrutus),
	reverse(CaminhoBrutus, CaminhoBCerto),
	write('Brutus na posicao '),
	write(Brutus),
	write(' derrotado pelo seguinte caminho:'),
	writeln(CaminhoBCerto),
	write('Pontuacao final: '),
	pontuacao(Pontuacao),
	write(Pontuacao).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%