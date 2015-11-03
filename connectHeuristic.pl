:-consult(winCondition).

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


list_min([L|Ls], Min) :- list_min(Ls, L, Min).
list_min([], Min, Min).
list_min([L|Ls], Min0, Min) :- Min1 is min(L, Min0),list_min(Ls, Min1, Min).

%minDistSumIslets(+Islets, +VisitableVertices, -DistSum)
minDistSumIslets(I,V,D) :- setof(X,getSetOfDistSumIslets(X,I,V),L),list_min(L,D).

getSetOfDistSumIslets(X,I,V) :- member(Y,I), distSumIslet(Y,V,X).

%distSumIslet(+Islet, +VisitableVertices, -DistSum)
distSumIslet(I,V,D) :- minLengthToEdge(I,1,V,L1),minLengthToEdge(I,2,V,L2),minLengthToEdge(I,3,V,L3),D is L1+L2+L3.

%minLengthToEdge(+Islet, +Edge, +VisitableVertices, -Length)
minLengthToEdge(I,E,V,M) :- setof(X,lengthToEdge(I,E,V,X),L),list_min(L,M).

%lengthToEdge(+Islet, +Edge, +VisitableVertices, -Length)
lengthToEdge(I,E,V,L) :- member(X,I),verticeOnEdge(Y,E),minPathLength(X,Y,V,L).

%minPathLength(+StartingVertice, +EndingVertice, +VisitableVertices, -Length)
minPathLength(S,E,V,M) :- setof(X,pathLength(S,E,V,X),L),list_min(L,M).

%pathLength(+StartingVertice, +EndingVertice, +VisitableVertices, -Length)
pathLength(S,E,V,L) :- path(S,E,V,[S],C),length(C,L).


