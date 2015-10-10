/**Explication générales du fonctionnement :
On va coder un algo minimax.
Le principe est qu'on cree l'arbre des possibilités de coups suivants une configuration, avec un nombre coup définis (ou profondeur de l'arbre).
On associe à un joueur le status de max, et à l'autre de min. Lorsque l'IA va devoir jouer, elle va calculer les coups à l'avance, et donner des notes à chacunes des positions possibles. Le status min va chercher à atteindre la-les configurations dont le score est le plus bas, et max va a contrario chercher à la maximiser.

Ici,au morpion, il y a 9 cases, donc pour la 1 ere configuration il faut prévoir 8 coups à l'avance si on veut explorer toutes les possibilités et faire le meilleur choix, ce qui est possible pour nos pc.
Cependant, dans le cas général du minMax, l'arbre de recherche peut-être trop grand, et l'explorer entièrement pourrait mettre nos pc en PLS, c'est pourquoi on limite le nombre de coups prévus à l'avance, et on code une fonction dite "heuristique", qui permet de noter une position en fonction du fait qu'elle soit plus favorable au min ou plus favorable au max (c'est la partie qui peut être subtile de l'algo)

Ici on prend une fonction heuristique simple: voir TD en ligne http://www.pps.univ-paris-diderot.fr/~buccia/COURS/Prolog/prolog/td5.pdf

Si note = 100 max gagne, si note = -100 min gagne, 0 c'est que soit y a égalité, soit que la fonction heuristique ne penche ni en la faveur de l'un ni en la faveur de l'autre. Les autres valeurs possibles sont celles de l'heuristique.


Notations: x sera le max, o le min, l est une case libre.
Le plateau de jeu est de la forme [x,x,l,o,o,x,l,l,x], décrivant les 9 cases : 1ere ligne, puis 2eme puis 3eme en partant de la gauche.	
**/



/**move(+pos_courante,+joueur,-pos_suivante)
 Permet à partir d'une configuration donnée de calculer toutes les autres positions possibles pour le joueur x.
*/

move([l|Q],J,[J|Q]).
move([X|Q1],J,[X|Q2]) :- move(Q1,J,Q2), (X==x;X==o;X==l).

/** finale(+pos,-joueur)
Détermine si le jeu est fini

    testGain(+pos,+maxOuMin)
Indique si maxOuMin a gagné
*/

testGain(L,X) :- (nth0(0, L, X),nth0(1, L, X),nth0(2, L, X));
	(nth0(3, L, X),nth0(4, L, X),nth0(5, L, X));
	(nth0(6, L, X),nth0(7, L, X),nth0(8, L, X));
	(nth0(0, L, X),nth0(3, L, X),nth0(6, L, X));
	(nth0(1, L, X),nth0(4, L, X),nth0(7, L, X));
	(nth0(2, L, X),nth0(5, L, X),nth0(8, L, X));
	(nth0(0, L, X),nth0(4, L, X),nth0(8, L, X));
	(nth0(6, L, X),nth0(4, L, X),nth0(2, L, X)).

/**
testGainPotentiel(+pos,+maxOuMin)
test le potentiel de victoire d'une config donnée pour maxOuMin
*/
testGainPotentiel(L,R) :- member(X,R),member(Y,R),member(Z,R),((nth0(0, L, X),nth0(1, L, Y),nth0(2, L, Z)); %avoir des variables separer pour faire toutes les combis possibles!
	(nth0(3, L, X),nth0(4, L, Y),nth0(5, L, Z));
	(nth0(6, L, X),nth0(7, L, Y),nth0(8, L, Z));
	(nth0(0, L, X),nth0(3, L, Y),nth0(6, L, Z));
	(nth0(1, L, X),nth0(4, L, Y),nth0(7, L, Z));
	(nth0(2, L, X),nth0(5, L, Y),nth0(8, L, Z));
	(nth0(0, L, X),nth0(4, L, Y),nth0(8, L, Z));
	(nth0(6, L, X),nth0(4, L, Y),nth0(2, L, Z))).

finale(L,max) :- not(member(l,L)),testGain(L,x),!.

finale(L,min) :- not(member(l,L)),testGain(L,o),!.

finale(L,nul) :- not(member(l,L)).

/** h(+pos,-valeur)
Fonction heuristique qui donne une note à la config donnée.
*/

h(L,100) :- finale(L,max),!. 
h(L,-100) :- finale(L,min),!.
h(L,0) :- finale(L,nul),!.
h(L,R) :- aggregate_all(count, testGainPotentiel(L,[x,l]), NbMax), aggregate_all(count, testGainPotentiel(L,[o,l]), NbMin), R is NbMax-NbMin.


/**
maxN([listeCouple[note,Position]],[NoteMax,PositionMax])
cherche le max de la liste donnée.

vous vous doutez de ce que fait minN
*/
maxN([X],X).
maxN([[X1|L]|Xs],[X1|L]):- maxN(Xs,[Y|_]), X1 >=Y.
maxN([[X1|_]|Xs],[N|QN]):- maxN(Xs,[N|QN]), N > X1.

minN([X],X).
minN([[X1|L]|Xs],[X1|L]):- minN(Xs,[Y|_]), X1 =< Y.
minN([[X1|_]|Xs],[N|QN]):- minN(Xs,[N|QN]), N < X1.

/** minimax(+joueur,+pos_courante,-valeur,-pos_suivante,+profondeur)
La grosse fonction un peu "pénible".
En gros, on lui donne un joueur, la position actuelle, ainsi que la profondeur, et elle ressort le meilleur coup, ainsi que sa note.
*/

minimax(_,Pos,Note,Pos,_) :- finale(Pos,_),h(Pos,Note),!.
minimax(_,Pos,Note,Pos,Profondeur) :- h(Pos,Note), Profondeur == 0,!.

minimax(x,Pos,Note,PosNext,Profondeur) :- ProfondeurNext is Profondeur-1,
	setof([TestNote,TestProchaine],combiMoveMinimax(Pos,x,o,TestProchaine,TestNote,ProfondeurNext),Notes),
	maxN(Notes,[Note,PosNext]).

minimax(o,Pos,Note,PosNext,Profondeur) :- ProfondeurNext is Profondeur-1,
	setof([TestNote,TestProchaine],combiMoveMinimax(Pos,o,x,TestProchaine,TestNote,ProfondeurNext),Notes),
	minN(Notes,[Note,PosNext]).


combiMoveMinimax(Pos,X,Y,TestProchaine,TestNote,ProfondeurNext) :- move(Pos,X,TestProchaine),minimax(Y,TestProchaine,TestNote,_,ProfondeurNext).


/**
	Notes importantes sur Prolog:
-Ne pas oublier de faire les coupures.
et
-l'ordre est peut être important dans les predicats
et
-minuscules pour variables nommées, maj pour les autres.
ET
Ici le probleme que j'avais c'est que dans le setof de minimax, il y avait (move,minimax), et ce bâtard ne voulait pas faire toutes les combinaisons d'un coup (il trouvait un move, puis faisait les minimax pour ce move, puis le mettait dans la liste de sortie, puis recommencait pour un autre move etc). La solution, c'est de faire une fonction intermediaire (ici combiMoveMinimax et là BAAAM ca marche !
*/


%permet simplement d'illustrer le probleme (inutile en l'etat)

moveTest(Pos1,Return) :- move(Pos1,x,Next),move(Next,o,Return).


