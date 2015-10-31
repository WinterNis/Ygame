:-consult(generateBoard).
:-consult(move).
:-consult(randomHeuristic).


maxN([X],X).
maxN([[X1|L]|Xs],[X1|L]):- maxN(Xs,[Y|_]), X1 >=Y.
maxN([[X1|_]|Xs],[N|QN]):- maxN(Xs,[N|QN]), N > X1.



minN([X],X).
minN([[X1|L]|Xs],[X1|L]):- minN(Xs,[Y|_]), X1 =< Y.
minN([[X1|_]|Xs],[N|QN]):- minN(Xs,[N|QN]), N < X1.


minimax(_,V,Eval,V,_) :- final(V,_),hRandom(V,Eval),!.
minimax(_,V,Eval,V,Depth) :- hRandom(V,Eval), Depth == 0,!.

minimax(w,V,Eval,VNext,Depth) :- DepthNext is Depth-1,
	setof([TestEval,TestNext],combiMoveMinimax(V,w,b,TestNext,TestEval,DepthNext),Evals),
	maxN(Evals,[Eval,VNext]).

minimax(b,V,Eval,VNext,Depth) :- DepthNext is Depth-1,
	setof([TestEval,TestNext],combiMoveMinimax(V,b,w,TestNext,TestEval,DepthNext),Evals),
	minN(Evals,[Eval,VNext]).

combiMoveMinimax(V,X,Y,TestNext,TestEval,DepthNext) :- move(V,X,TestNext),minimax(Y,TestNext,TestEval,_,DepthNext).

%testJeu(N,LNext) :- generateGraph(N), generateVerticesEmptyList(N,L), minimax(w,L,_,LNext,2).
testJeu(_,LNext) :- minimax(w,[b,b,e,e,w,e],_,LNext,1).

play(C,P,CNext) :- minimax(P,C,_,CNext,2).
%play(C,P,CNext) :- alphabeta(P,C,_,CNext,2, -101,101).

alphabeta(_,V,Eval,_,_,_,_) :- final(V,_),hRandom(V,Eval),!.
alphabeta(_,V,Eval,V,Depth,_,_) :- hRandom(V,Eval), Depth == 0,!.

alphabeta(w,V,Eval,VNext,Depth, Alpha, Beta) :- DepthNext is Depth-1,
	find(V, Evals, w, b, DepthNext, Alpha, Beta),
	maxN(Evals,[Eval,VNext]).

alphabeta(b,V,Eval,VNext,Depth, Alpha, Beta) :- DepthNext is Depth-1,
	find(V, Evals, b, w, DepthNext, Alpha, Beta),
	minN(Evals,[Eval,VNext]).

combiMoveAlphabeta(V,ListToAvoid,X,Y,TestNext,TestEval,DepthNext,Alpha, Beta) :- move(V,X,TestNext),not(member([_,TestNext],ListToAvoid)),alphabeta(Y,TestNext,TestEval,_,DepthNext, Alpha, Beta).


find(V, Res, Player, Opponent, Depth, Alpha, Beta) :- find(V, [], Res, Player, Opponent, Depth, Alpha, Beta), !.
find(V, Acc, Res, Player, Opponent, Depth, Alpha, Beta) :-
	combiMoveAlphabeta(V, Acc, Player, Opponent,TestNext,TestEval,Depth,Alpha, Beta),!,
	(pruneAlpha(TestEval,Alpha,Player), % If min plays, he can eventually do an alpha prune.
	pruneBeta(TestEval, Beta, Player)) -> ( % If max plays, he can eventually do a beta prune.
		uList([TestEval,TestNext], Acc, AccNew),
		updateBeta(Beta,TestEval,Player,NewBeta), % If min plays, he updates beta.
		updateAlpha(Alpha,TestEval,Player,NewAlpha), % If max plays, he updates alpha.
		find(V, AccNew, Res, Player, Opponent, Depth, NewAlpha, NewBeta)).

find(_, Acc, Acc, _, _,_,_,_).

uList(X, [], [X])  :- !.
uList(H, [H|_], _) :- !, fail.
uList(X, [H|T], L) :- uList(X, T, Rtn), L = [H|Rtn].

%If min plays, he updates only beta. Max updates alpha.
%Pruning only happens on beta for max, and on alpha for min.

%update alpha as the max between alpha and the current value.
%updateAlpha(+Alpha, +Val, +Player, -NewAlpha)
updateAlpha(Alpha, _, Player, NewAlpha) :- Player == 'b', NewAlpha is Alpha.
updateAlpha(Alpha, Val, Player, NewAlpha) :- Player == 'w', NewAlpha is max(Alpha,Val).

%update beta as the min between beta and the current value.
%updateBeta(+Beta, +Val, +Player, -NewBeta)
updateBeta(Beta, _, Player, NewBeta) :-Player == 'w', NewBeta is Beta.
updateBeta(Beta, Val, Player, NewBeta) :- Player == 'b', NewBeta is min(Beta,Val).

%Pruning condition. Happens if pruneAlphaBeta is evaluate to false.
%prune(+Val,+AlphaBeta, +Player)
pruneAlpha(_,_,'w').  %Never pruneAlpha when player is white.
pruneAlpha(Val,Alpha, Player) :- Player=='b', Val > Alpha.

pruneBeta(_,_, 'b').   %Never pruneBeta when player is black.
pruneBeta(Val,Beta, Player) :- Player=='w', Val < Beta.
