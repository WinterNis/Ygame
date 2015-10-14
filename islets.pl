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