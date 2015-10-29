:-consult(winCondition).

/** final(+vertices,-player)
Indicate if the game is finished.
Player value is max if max win, min if min win.
*/

final(V,max) :- win(V,w),!.
final(V,min) :- win(V,b),!.


/** coutXPlus(+vertice,-number)
    Return the number of elements after the vertice in the axis X
*/

%nextXPlus(V,X) :- 
%coutXPlus(V,N) :- .

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



/** hRandom(+vertices,-grade)
heuristic fonction, which give grade to the configuration given .
Instead of picking a random vertice, we generate a random evaluation from -100 to 100,
so that we keep the idea of evaluating positions in all our heuristics.
*/

hRandom(V,100) :- final(V,max),!. 
hRandom(V,-100) :- final(V,min),!.	

hRandom(_,R) :- X is random(200), R is X -100 .

