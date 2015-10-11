:-consult(winCondition).

/** final(+vertices,-player)
Indicate if the game is finished.
Player value is max if max win, min if min win.
*/

final(V,max) :- win(V,w),!.
final(V,min) :- win(V,b),!.


/** hRandom(+vertices,-grade)
heuristic fonction, which give grade to the configuration given .
Instead of picking a random vertice, we generate a random evaluation from -100 to 100,
so that we keep the idea of evaluating positions in all our heuristics.
*/

hRandom(V,100) :- final(V,max),!. 
hRandom(V,-100) :- final(V,min),!.	

hRandom(_,R) :- X is random(200), R is X -100 .

