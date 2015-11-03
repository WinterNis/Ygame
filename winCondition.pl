%A list of vertices.
%e: Empty
%w: White
%b: Black

%arc(+Start, +End)
/**
arc(0,1).
arc(1,0).
arc(0,2).
arc(2,0).
arc(1,2).
arc(2,1).
arc(1,3).
arc(3,1).
arc(1,4).
arc(4,1).
arc(2,4).
arc(4,2).
arc(2,5).
arc(5,2).
arc(3,4).
arc(4,3).
arc(4,5).
arc(5,4).
*/

%Test whether a vertice is on an edge of the board.
%verticeOnEdge(+Vertice, -EdgeNumber)
/**
verticeOnEdge(0,1).
verticeOnEdge(1,1).
verticeOnEdge(3,1).
verticeOnEdge(3,2).
verticeOnEdge(4,2).
verticeOnEdge(5,2).
verticeOnEdge(5,3).
verticeOnEdge(2,3).
verticeOnEdge(0,3).
*/

%win(+Vertices, +PlayerColor)
win(V,C) :- playerVertices(V,C,P),separateIntoIslets(P,I),hasAWinningIslet(I).

%List of vertices owned by a player.
%playerVertices(+Vertices, +PlayerColor, -PlayerVertices)
playerVertices(V, C, P) :- setof(I,nth0(I,V,C),P).

%hasAWinningIslet(+Islets)
hasAWinningIslet([I|_]) :- hasAVerticeOnEdge(I,1),hasAVerticeOnEdge(I,2),hasAVerticeOnEdge(I,3),!.
hasAWinningIslet([_|T]) :- hasAWinningIslet(T).


%hasAVerticeOnEdge(+Islet, +EdgeNumber)
hasAVerticeOnEdge([X|_],E) :- verticeOnEdge(X,E),!.
hasAVerticeOnEdge([_|T],E) :- hasAVerticeOnEdge(T,E).


%separateIntoIslets(+PlayerVertices, -Islets)
%This is a frontend to use separateIntoIslets/4.
separateIntoIslets(P,I) :- separateIntoIslets(P,P,[],I).
%separateIntoIslets(+PlayerVertices, +NotVisitedVertices, +CurrentIslets, -Islets)
%finishes when the list of nonvisited vertices is empty.
separateIntoIslets(_,[],I,I).
% separateIntoIslets find the islet of the first nonvisited vertice.
separateIntoIslets(P,[X|T],C,I) :- islet(X,P,N),subtract(T,N,R),separateIntoIslets(P,R,[N|C],I).

%islet(+StartingVertice, +PlayerVertices, -Islet)
islet(S,P,I) :- delete(P,S,N),islet(S,P,N,[S],I).
%islet(+StartingVertice, +PlayerVertices, +NotVisitedVertices, +CurrentIslet, -Islet)
islet(_,_,[],C,C).
islet(S,P,[X|T],C,I) :- S\=X,connected(S,X,P),islet(S,P,T,[X|C],I).
islet(S,P,[X|T],C,I) :- S==X,islet(S,P,T,C,I).
islet(S,P,[X|T],C,I) :- not(connected(S,X,P)),islet(S,P,T,C,I).

%connected(+StartingVertice, +EndingVertice, +VisitableVertices)
connected(X,Y,P) :- path(X,Y,P,[X],_),!.
%path(+StartingVertice, +EndingVertice, +VisitableVertices, +VisitedVertices, -ReversePath)
path(X,X,_,V,V).
path(X,Y,P,V,T) :- member(Z,P),not(member(Z,V)),arc(X,Z),path(Z,Y,P,[Z|V],T).

