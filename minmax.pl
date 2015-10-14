:-consult(generateBoard).
:-consult(move).
:-consult(randomHeuristic).

/**
maxN([pairlist[evaluation, configuration]],[evaluationMax,configurationMax])
Get from the pairList, the pair in witch the evaluation is maximum 
*/

maxN([X],X).
maxN([[X1|L]|Xs],[X1|L]):- maxN(Xs,[Y|_]), X1 >=Y.
maxN([[X1|_]|Xs],[N|QN]):- maxN(Xs,[N|QN]), N > X1.

/**
minN([pairlist[evaluation, configuration]],[evaluationMin,configurationMin])
Get from the pairList, the pair in witch the evaluation is minimum 
*/

minN([X],X).
minN([[X1|L]|Xs],[X1|L]):- minN(Xs,[Y|_]), X1 =< Y.
minN([[X1|_]|Xs],[N|QN]):- minN(Xs,[N|QN]), N < X1.

/** minimax(+player,+current_configuration,-evaluation,-next_configuration,+depth)
From a current configuration and a player, calculate the best next configuration and the corresponding evaluation
*/

minimax(_,V,Eval,V,_) :- final(V,_),hRandom(V,Eval),!.
minimax(_,V,Eval,V,Depth) :- hRandom(V,Eval), Depth == 0,!.

minimax(w,V,Eval,VNext,Depth) :- DepthNext is Depth-1,
	setof([TestEval,TestNext],combiMoveMinimax(V,w,b,TestNext,TestEval,DepthNext),Evals),
	maxN(Evals,[Eval,VNext]).

minimax(b,V,Eval,VNext,Depth) :- DepthNext is Depth-1,
	setof([TestEval,TestNext],combiMoveMinimax(V,b,w,TestNext,TestEval,DepthNext),Evals),
	minN(Evals,[Eval,VNext]).

combiMoveMinimax(V,X,Y,TestNext,TestEval,DepthNext) :- move(V,X,TestNext),minimax(Y,TestNext,TestEval,_,DepthNext).


%testJeu(N,LNext) :- generateGraph(N), generateVerticesEmptyList(N,L), minimax(w,L,X,LNext,2).
testJeu(_,LNext) :- minimax(w,[b,b,w,e,w,e],_,LNext,2).

/**
play(+Cnfiguration,+Player,-ConfigurationNext)
*/

play(C,P,CNext) :- minimax(P,C,_,CNext,3).
