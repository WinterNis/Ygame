:-consult(winCondition).

%hConnect(+vertices,-grade)
%heuristic fonction, which give grade to the configuration given.
%In this heuristic, the best player is the one who has the islet which is the nearest to win.
%A theoric maximum distance of an islet to the edges is (N(N-1)/4)+2.
%The minimum distance of an islet to the edge is 3.
%We map the grade of a player between 0 and 99. 0 corresponds to (N(N-1)/4)+2 and 99 corresponds to 0.
%The heuristic is the grade of max minus the grade of min.

%a1 = 0
%b1 = (length(V)/2)+2
%a2 = 99
%b2 = 0

hConnect(V,100) :- final(V,max),!. 
hConnect(V,-100) :- final(V,min),!.
hConnect(V,G) :- playerVertices(V,e,VE),playerVertices(V,w,PW),separateIntoIslets(PW,IW),union(VE,PW,VW),minDistSumIslets(IW,VW,DW),
                                         playerVertices(V,b,PB),separateIntoIslets(PB,IB),union(VE,PB,VB),minDistSumIslets(IB,VB,DB),
										    length(V, M),
											GW is (99*((M/2)+2-DW))/((M/2)+2),
											GB is (99*((M/2)+2-DB))/((M/2)+2),
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
lengthToEdge(I,E,V,L) :- member(S,I),findall(X,verticeOnEdge(X,E),G),minPathLength(S,G,V,L).

%minPathLength(+StartingVertice, +Goals, +PlayerVertices, -Length)
minPathLength(S,G,P,L) :- empty_assoc(D),put_assoc(S,D,0,D2),minPathLength1([S],G,[S],P,D2,L).
% minPathLength(+FIFO, +Goals, +VisitedVertex, +PlayerVertices, +AssocDistances, -Length)
minPathLength1([S|_],G,_,P,A,L) :- member(S,G),member(S,P),get_assoc(S,A,L),!.
minPathLength1([S|T],G,V,P,A,L) :- findall(X,(arc(S,X),not(member(X,V)),member(X,P)),E),
                                   append(T,E,F),
                                   append(V,E,V2),
                                   get_assoc(S,A,D1),
                                   D2 is D1 + 1,
                                   put_assoc_list(E,A,D2,A2),
                                   minPathLength1(F,G,V2,P,A2,L).

%put_assoc_list(+KeyList, +Assoc, +Value, -NewAssoc).
put_assoc_list([],A,_,A).
put_assoc_list([H|T],A,V,N) :- put_assoc(H,A,V,A2),put_assoc_list(T,A2,V,N).


