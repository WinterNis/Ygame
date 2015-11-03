:- consult(minmax).


recList(0,[]) :- !.
recList(B,[e|Q]) :- B1 is B-1, recList(B1,Q). 

generateEmptyPosition(N, L) :- B is N*(1+N)/2, recList(B,L).



%
% Launch a match IA1 vs IA2 (IA should be the name of the heuristic)
%
match(IA1, IA2, Size, Depth, Winner) :- 	generateGraph(Size), 
										generateEmptyPosition(Size, List),
										match(IA1, IA2, Depth, List, w, Winner).
							
match(IA1, IA2, Depth, Position, w, Winner) :- 	play(Position, w, NewPosition, IA1, Depth), 
												((win(NewPosition, w) -> Winner is 1,!) ;
												(match(IA1, IA2, Depth, NewPosition, b, Winner))).

match(IA1, IA2, Depth, Position, b, Winner) :-	play(Position, b, NewPosition, IA2, Depth),
												(win(NewPosition, b) -> Winner is 2,! ;
												match(IA1, IA2, Depth, NewPosition, w, Winner)).


recStats(0,Wwins, Bwins,_,_,_,_,Wwins,Bwins) :- !.
recStats(N, Wwins, Bwins, IA1, IA2, Size, Depth, Wfinal, Bfinal) :- 
		N1 is N-1, 
		match(IA1, IA2, Size, Depth, Winner),
		
		((Winner is 1 -> ((NewWwins is Wwins+1),(NewBwins is Bwins)));
						(NewBwins is Bwins+1),(NewWwins is Wwins)),
		
		recStats(N1, NewWwins, NewBwins, IA1, IA2, Size, Depth, Wfinal, Bfinal).

