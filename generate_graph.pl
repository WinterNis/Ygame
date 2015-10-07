:- dynamic( arc/2 ).

%generateVerticesList(+floorsNumber,-returnList)
%generate the list of vertices depending on floorNumber
generateVerticesList(N, L) :- B is N*(1+N)/2-1, setof(A,between(0,B,A),L).


%generateArcs(+listOfVertices)
%generateArcs([T|Q]) :- 

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

test(A,X) :- generateMemoFloor(5,L), getFloor(A,L,X).

%generateGraph(+floorsNumber)
%generateGraphRec(+verticesList, +memoFloorsList)

generateGraphRec([],_).
generateGraphRec([Hl|Ql],M) :- getFloor(Hl,M,Floor),Next is Floor+Hl,assert(arc(Hl,Next)),assert(arc(Next,Hl)),
	Next2 is Next+1,assert(arc(Hl,Next2)),assert(arc(Next2,Hl)) ,generateGraphRec(Ql,M).

generateGraph(N) :- NReel is N-1, generateMemoFloor(NReel,M), generateVerticesList(NReel, V), generateGraphRec(V,M).

%move(+CurrentConfiguration, +Player, -NextConfiguration)
move([e|_], J , [J|_]).
move([X|Q1], J, [X|Q2]) :- move(Q1,J,Q2).
