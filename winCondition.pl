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
%implemented with connexity checks
%win(V,C) :- playerVertices(V,C,P),separateIntoIslets(P,I),hasAWinningIslet(I).

%win(+Vertices, +PlayerColor)
%implemented with the method of equivalency of a smaller board
win(V,C) :- sizeOfBoard(V,Size), recShrinkBoard(V, C, Size).

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


recShrinkBoard(Board, Dominant, 2) :- getDominance(Board,Dominant), !.
recShrinkBoard(Board, Dominant, Size) :- Size1 is Size-1, createBoardMinusOne(Board, BoardNext, Size1), recShrinkBoard(BoardNext,Dominant,Size1).

createBoardMinusOne( BoardBefore, BoardAfter, SizeNewBoard) :- Cursor is ((SizeNewBoard * (SizeNewBoard+1)/2) -1) ,addElemInNewBoard(BoardBefore,Cursor, [], BoardAfter).


addElemInNewBoard(Board, 0, NewBoard, NewBoardFinal) :- 		getTriangle(Board,0,ListOfThree), 
															getDominance(ListOfThree, Color), 
															NewBoardFinal = [Color|NewBoard].
															
addElemInNewBoard(Board, Cursor, NewBoard, NewBoardFinal) :- 	getTriangle(Board,Cursor,ListOfThree), 
																getDominance(ListOfThree, Color), 
																NewBoard1 = [Color|NewBoard],
																Cursor1 is Cursor-1,
																addElemInNewBoard(Board, Cursor1, NewBoard1, NewBoardFinal). 

getTriangle(Board, Vertice, ListOfElementsInTheTriangle) :- L1 = [] ,nth0(Vertice, Board, Elem1), L2 = [Elem1|L1],
															currentFloor(Vertice, F), V is Vertice+F, nth0(V, Board, Elem2), L3 = [Elem2|L2],
															V2 is V+1, nth0(V2, Board, Elem3), ListOfElementsInTheTriangle = [Elem3|L3].

%
% Find the color of the dominant Player in the elements of a triangle.
%
getDominance(ListOfThree, Color) :- getDominance(ListOfThree, 0,0, Color).
getDominance([], _, NbB, b) :- NbB > 1 ,!. 
getDominance([], NbW, _, w) :- NbW > 1 ,!. 
getDominance([], _, _, e). 
getDominance([w|Q], NbW, NbB, Color) :- NbW1 is NbW+1, getDominance(Q, NbW1, NbB, Color).    
getDominance([b|Q], NbW, NbB, Color) :- NbB1 is NbB+1, getDominance(Q, NbW, NbB1, Color).
getDominance([e|Q], NbW, NbB, Color) :- getDominance(Q, NbW, NbB, Color).
																

sizeOfBoard(Board, Size) :- length(Board,Length) ,Length1 is Length-1, currentFloor(Length1,Size).


/**addFloor(Vertice,Sum,CurrentFloor,FloorFinale)
The idea is to begin from 0, to add the number of vertices of each level, until we reach the right vertice at the right floor.
*/
addFloor(V,0,0,F) :- V>0, addFloor(V,0,1,F),!. % we do that to make sure that is working with 0
addFloor(_,0,0,F) :- F is 1,!.
addFloor(V,N,C,F) :- V > N, F1 is C+1, N1 is N+F1,addFloor(V,N1,F1,F),!.
addFloor(_,_,C,F) :- F is C. %we come here only at the end 

/**
Get the current floor in a better way than into generateBoard
*/
currentFloor(V,F) :- addFloor(V,0,0,F).
