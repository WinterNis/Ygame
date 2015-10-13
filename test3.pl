%arc(+Start, +End)
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

%Test whether a vertice is on an edge of the board.
%verticeOnEdge(+Vertice, -EdgeNumber)
verticeOnEdge(0,1).
verticeOnEdge(1,1).
verticeOnEdge(3,1).
verticeOnEdge(3,2).
verticeOnEdge(4,2).
verticeOnEdge(5,2).
verticeOnEdge(5,3).
verticeOnEdge(2,3).
verticeOnEdge(0,3).