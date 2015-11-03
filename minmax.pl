:-consult(generateBoard).
:-consult(move).
:-consult(selectHeuristic).

% maxN(+[[Eval,Position]], -[BestEval,Position])
% Get the best couple (ordered on the Eval) from the list of couple [Eval,Position]
%
maxN([X],X).
maxN([[X1|L]|Xs],[X1|L]):- maxN(Xs,[Y|_]), X1 >=Y.
maxN([[X1|_]|Xs],[N|QN]):- maxN(Xs,[N|QN]), N > X1.



% minN(+[[Eval,Position]], -[BestEval,Position])
% Get the minimal couple (ordered on the Eval) from the list of couple [Eval,Position]
%
minN([X],X).
minN([[X1|L]|Xs],[X1|L]):- minN(Xs,[Y|_]), X1 =< Y.
minN([[X1|_]|Xs],[N|QN]):- minN(Xs,[N|QN]), N < X1.

% minimax(+Player, +Position, -Eval, -NextPosition, +Depth)
% Execute the minimax algorithm. NextPosition is the best move that Player can do if he thinks (Depth) moves further.
%
% End of recursion when Depth is 0 or when Position is a winning position.
minimax(_,V,Eval,V,_,Sel) :- final(V,_),heuristic(V,Eval,Sel),!.
minimax(_,V,Eval,V,Depth,Sel) :- heuristic(V,Eval,Sel), Depth == 0,!.

% Minimax from the point of view of max
minimax(w,V,Eval,VNext,Depth,Sel) :- DepthNext is Depth-1,
	setof([TestEval,TestNext],combiMoveMinimax(V,w,b,TestNext,TestEval,DepthNext,Sel),Evals),
	maxN(Evals,[Eval,VNext]).

% Minimax from the point of view of min
minimax(b,V,Eval,VNext,Depth,Sel) :- DepthNext is Depth-1,
	setof([TestEval,TestNext],combiMoveMinimax(V,b,w,TestNext,TestEval,DepthNext,Sel),Evals),
	minN(Evals,[Eval,VNext]).

% combiMoveMinimax(+Position, +X, +Y, -TestNext, -TestEval, +DepthNext)
% find every couple TestNext, TestEval, that directly follows the Position.
% DepthNext is necessary because combiMoveMinimax needs to call minimax.
%
combiMoveMinimax(V,X,Y,TestNext,TestEval,DepthNext,Sel) :- move(V,X,TestNext),minimax(Y,TestNext,TestEval,_,DepthNext,Sel).


%testJeu(N,LNext) :- generateGraph(N), generateVerticesEmptyList(N,L), minimax(w,L,_,LNext,2).
testJeu(_,LNext) :- minimax(w,[b,b,e,e,w,e],_,LNext,1).


play(C,P,CNext) :- play(C,P,CNext, "center").
%play(C,P,CNext,Sel) :- minimax(P,C,_,CNext,1,Sel).
play(C,P,CNext,Sel) :- alphabeta(P,C,_,CNext,3, -101,101,Sel).



% alphabeta((Same as minimax), +Alpha, +Beta, +SelectedHeuristic)
% is a minimax with alpha-beta pruning. When launched, alpha is -infinite and beta is +infinite (every lower bound of the heuristic for alpha, and upper bound for beta works)
%
alphabeta(_,V,Eval,_,_,_,_,Sel) :- final(V,_),heuristic(V,Eval,Sel),!.
alphabeta(_,V,Eval,V,Depth,_,_,Sel) :- heuristic(V,Eval,Sel), Depth == 0,!.

alphabeta(w,V,Eval,VNext,Depth, Alpha, Beta,Sel) :- DepthNext is Depth-1,
	find(V, Evals, w, b, DepthNext, Alpha, Beta, Sel),
	maxN(Evals,[Eval,VNext]).

alphabeta(b,V,Eval,VNext,Depth, Alpha, Beta, Sel) :- DepthNext is Depth-1,
	find(V, Evals, b, w, DepthNext, Alpha, Beta, Sel),
	minN(Evals,[Eval,VNext]).

% combiMoveAlphabeta(+V, +ListToAvoid, +X, +Y, -TestNext, -TestEval, +DepthNext, +Alpha, +Beta)
% is the equivalent of combiMoveMinimax. Because of the implementation of find, it needs a parameter ListToAvoid
% which is the list of the couples (TestEval,TestNext) already found.
%
combiMoveAlphabeta(V,ListToAvoid,X,Y,TestNext,TestEval,DepthNext,Alpha, Beta, Sel) :- 
		move(V,X,TestNext),not(member([_,TestNext],ListToAvoid)),alphabeta(Y,TestNext,TestEval,_,DepthNext, Alpha, Beta, Sel).



% find(+V, -Results, +Player, +Opponent, +Depth, +Alpha, +Beta)
% is an equivalent of setof, but can stop if necessary (in case of alpha or beta pruning).
%
% find(+V, +Accumulator, -Results, +Player, +Opponent, +Depth, +Alpha, +Beta)
% is the predicate that build Results, with the help of an Accumulator.
% 
find(V, Res, Player, Opponent, Depth, Alpha, Beta, Sel) :- find(V, [], Res, Player, Opponent, Depth, Alpha, Beta, Sel), !.
find(V, Acc, Res, Player, Opponent, Depth, Alpha, Beta, Sel) :-
	combiMoveAlphabeta(V, Acc, Player, Opponent,TestNext,TestEval,Depth,Alpha, Beta, Sel),!,
	(pruneAlpha(TestEval,Alpha,Player),                           % If min plays, he can eventually do an alpha prune.
	pruneBeta(TestEval, Beta, Player)) -> (                       % If max plays, he can eventually do a beta prune.
		uList([TestEval,TestNext], Acc, AccNew),
		updateBeta(Beta,TestEval,Player,NewBeta),                 % If min plays, he updates beta.
		updateAlpha(Alpha,TestEval,Player,NewAlpha),              % If max plays, he updates alpha.
		find(V, AccNew, Res, Player, Opponent, Depth, NewAlpha, NewBeta, Sel)).

% End of the recursion when Acc and Res are the same list.
find(_, Acc, Acc, _, _,_,_,_,_).



% uList(+Elem, +Acc, -AccNew)
% Add Elem to Acc if it is not already member. The Acc is returned in AccNew. 
%
uList(X, [], [X])  :- !.
uList(H, [H|_], _) :- !, fail.
uList(X, [H|T], L) :- uList(X, T, Rtn), L = [H|Rtn].

% If min plays, he updates only beta. Max updates alpha.
% Pruning only happens on beta for max, and on alpha for min.

% updateAlpha(+Alpha, +Val, +Player, -NewAlpha)
% update alpha as the max between alpha and the current value.
%
updateAlpha(Alpha, _, 'b', NewAlpha) :- NewAlpha is Alpha.
updateAlpha(Alpha, Val, 'w', NewAlpha) :- NewAlpha is max(Alpha,Val).


% updateBeta(+Beta, +Val, +Player, -NewBeta)
% update beta as the min between beta and the current value.
%
updateBeta(Beta, _, 'w', NewBeta) :- NewBeta is Beta.
updateBeta(Beta, Val, 'b', NewBeta) :- NewBeta is min(Beta,Val).

% prune(+Val,+AlphaBeta, +Player)
% Pruning condition. Pruning needs to happen if pruneAlphaBeta is evaluate to false.
%
pruneAlpha(_,_,'w').  %Never pruneAlpha when player is white.
pruneAlpha(Val,Alpha, 'b') :- Val > Alpha.

pruneBeta(_,_, 'b').   %Never pruneBeta when player is black.
pruneBeta(Val,Beta, 'w') :- Val < Beta.
