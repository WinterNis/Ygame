%hConnect(+vertices,-grade)
%heuristic fonction, which give grade to the configuration given.
%In this heuristic, the best player is the one who has the islet which is the nearest to win.
%A theoric maximum distance of an islet to the edges is (N(N-1)/4)+2.
%The minimum distance of an islet to the edge is 3.
%We map the grade of a player between 0 and 100. 0 corresponds to (N(N-1)/4)+2 and 100 corresponds to 3.
%The heuristic is the grade of max minus the grade of min.

%a1 = 3
%b1 = (length(V)/2)+2
%a2 = 100
%b2 = 0

hConnect(V,100) :- final(V,max),!. 
hConnect(V,-100) :- final(V,min),!.
hConnect(V,G) :- playerVertices(V,e,VE),playerVertices(V,w,PW),separateIntoIslets(PW,IW),minDistSumIslets(IW,VE,DW),
                                         playerVertices(V,b,PB),separateIntoIslets(PB,IB),minDistSumIslets(IB,VE,DB),
										    length(V, M),
											GW is (-100*DW + 3*((M/2)+2))/((M/2)-1),
											GB is (-100*DB + 3*((M/2)+2))/((M/2)-1),
											G is GW - GB.

%pathLength(+StartingVertice, +EndingVertice, +VisitableVertices, -Length)
pathLength(S,E,V,L) :- path(S,E,V,[V],C),length(C,L).
%path(+StartingVertice, +EndingVertice, +VisitableVertices, +VisitedVertices, -ReversePath)
path(X,X,_,V,V).
path(X,Y,P,V,T) :- member(Z,P),not(member(Z,V)),arc(X,Z),path(Z,Y,P,[Z|V],T).