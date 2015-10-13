:- dynamic(arc/2).
:- dynamic(verticeOnEdge/2).


%generateVerticesList(+floorsNumber,-returnList)
%generate the list of vertices depending on floorNumber
generateVerticesList(N, L) :- B is N*(1+N)/2-1, setof(A,between(0,B,A),L).

%generateVerticesEmptyList(+floorsNumber,-returnList)
%generate the list of vertices value depending on floorNumber. Use this for configuration description

generateVerticesEmptyRec(B,[]) :- B == 0,!.
generateVerticesEmptyRec(B,[e|Q]) :- BNext is B - 1, generateVerticesEmptyRec(BNext,Q).

generateVerticesEmptyList(N, L) :- B is N*(1+N)/2, generateVerticesEmptyRec(B,L).

%generateFloorMax(+floor, -lastVerticeOf)
generateFloorMax(N,X) :- X is N*(1+N)/2 - 1.

%generateMemoFloor(+numberOfFloors, -listOfLastElementForEachFloor)
%generate a list of the last element of each floor. Decreasing order.
generateMemoFloor(N,[]) :- N == 0,!.
generateMemoFloor(N,[H|Q]) :- N1 is N-1,generateFloorMax(N,H), generateMemoFloor(N1,Q).

%getFloor(+element,+memoFloor,-floor)

getFloorRec(A,[T|_],X, N) :- T<A, X is N,!.
getFloorRec(A,[_|Q],X,N) :- N1 is N - 1, getFloorRec(A,Q,X,N1).

getFloor(0,_,1).
getFloor(A,L,C) :- length(L,B), getFloorRec(A,L,X,B), C is X + 1.

%generateGraph(+floorsNumber)
%generateGraphRec(+verticesList, +memoFloorsList, floorsNumber)

generateGraphRec([],_,_).
generateGraphRec([Hl|Ql],M,N) :- getFloor(Hl,M,Floor),Next is Floor+Hl,assert(arc(Hl,Next)),assert(arc(Next,Hl)),
	Next2 is Next+1,assert(arc(Hl,Next2)),assert(arc(Next2,Hl)), assert(arc(Next,Next2)), assert(arc(Next2,Next)) ,linkVerticeToEdge(Next, Floor,N), linkVerticeToEdge(Next2, Floor,N),generateGraphRec(Ql,M,N).

generateGraph(N) :- init, NReel is N-1, generateMemoFloor(NReel,M), generateVerticesList(NReel, V), generateGraphRec(V,M,NReel).


init :- assert(verticeOnEdge(0,1)), assert(verticeOnEdge(0,3)).

%linkVerticeToEdge(+vertice,+verticeFloor,-floorsNumber)
linkVerticeToEdge(V, F, N) :- F == N, V is (F*(3+F)/2), assert(verticeOnEdge(V,3)), assert(verticeOnEdge(V,2)),!.
linkVerticeToEdge(V, F, N) :- F == N, V is (F*(1+F)/2), assert(verticeOnEdge(V,1)), assert(verticeOnEdge(V,2)),!.
linkVerticeToEdge(V, F, N) :- F == N, not(verticeOnEdge(V,2)), assert(verticeOnEdge(V,2)),!.
linkVerticeToEdge(V, F,_) :- V is (F*(3+F)/2), assert(verticeOnEdge(V,3)),!.
linkVerticeToEdge(V, F,_) :- V is (F*(1+F)/2), assert(verticeOnEdge(V,1)),!.
linkVerticeToEdge(_,_,_).
