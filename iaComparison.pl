:- consult(minmax).


recList(0,[]) :- !.
recList(B,[e|Q]) :- B1 is B-1, recList(B1,Q). 

generateEmptyPosition(N, L) :- B is N*(1+N)/2, recList(B,L).



%
% Launch a match IA1 vs IA2 (IA should be the name of the heuristic)
%
match(IA1, IA2, Size, Winner) :- 	generateGraph(Size), 
									generateEmptyPosition(Size, List),
									match(IA1, IA2, List, w, Winner).
							
match(IA1, IA2, Position, w, Winner) :- play(Position, w, NewPosition, IA1), 
										((win(NewPosition, w) -> Winner is 1,!) ;
										(match(IA1, IA2, NewPosition, b, Winner))).

match(IA1, IA2, Position, b, Winner) :- play(Position, b, NewPosition, IA2),
										(win(NewPosition, b) -> Winner is 2,! ;
										match(IA1, IA2, NewPosition, w, Winner)).



