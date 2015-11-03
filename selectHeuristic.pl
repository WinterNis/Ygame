:-consult(randomHeuristic).
:-consult(connectHeuristic).
:-consult(centerHeuristic).

% heuristic (+Position, -Evaluation, +SelectedHeuristic)
%
%
heuristic(V, Eval, Select) :-
				Select == random -> hRandom(V,Eval);
				Select == connect -> hConnect(V,Eval);
				Select == center -> hCenter(V,Eval). 
