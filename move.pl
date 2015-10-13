/**move(+Configuration,+Player,-NextConfiguration)
	Calculate every next possible configurations from a given configuration for the player Player 
*/

move([e|Q],J,[J|Q]).
move([X|Q1],J,[X|Q2]) :- move(Q1,J,Q2), (X==w;X==b;X==e). 