:-consult(winCondition).



/** coutXMore(+vertice,-number)
    Return the number of elements after the vertice in the axis X
*/
coutXMore(V,N) :- nextXMore(V,VNext), coutXMore(VNext,N1), N is N1+1,!.
coutXMore(_,0).

nextXMore(V,X) :- currentFloor(V,F), Xtest is V-F+1, V =\= 2, arc(Xtest,V), X is Xtest.

/** coutXLess(+vertice,-number)
    Return the number of elements before the vertice in the axis X
*/
coutXLess(V,N) :- nextXLess(V,VNext), coutXLess(VNext,N1), N is N1+1,!.
coutXLess(_,0).

nextXLess(V,X) :- currentFloor(V,F), Xtest is V+F, arc(Xtest,V), X is Xtest.

/** coutZMore(+vertice,-number)
    Return the number of elements after the vertice in the axis Z
*/
coutZMore(V,N) :- nextXLess(V,VNext), coutZMore(VNext,N1), N is N1+1,!.
coutZMore(_,0).

nextZMore(V,X) :- currentFloor(V,F), Xtest is V+F+1, arc(Xtest,V), X is Xtest.

/** coutZLess(+vertice,-number)
    Return the number of elements before the vertice in the axis Z
*/
coutZLess(V,N) :- nextZLess(V,VNext), coutZLess(VNext,N1), N is N1+1,!.
coutZLess(_,0).

nextZLess(V,X) :- currentFloor(V,F), Xtest is V-F, V =\= 1, arc(Xtest,V), X is Xtest.

/** coutYMore(+vertice,-number)
    Return the number of elements after the vertice in the axis Y
*/
coutYMore(V,N) :- nextYMore(V,VNext), coutYMore(VNext,N1), N is N1+1,!.
coutYMore(_,0).

nextYMore(V,X) :- Xtest is V+1, V =\= 0, arc(Xtest,V), X is Xtest.

/** coutYLess(+vertice,-number)
    Return the number of elements before the vertice in the axis Z
*/
coutYLess(V,N) :- nextYLess(V,VNext), coutYLess(VNext,N1), N is N1+1,!.
coutYLess(_,0).

nextYLess(V,X) :- Xtest is V-1, V =\= 1, arc(Xtest,V), X is Xtest.


/**
grade(+Vertice,-grade)
Give a grade to a single point
*/
grade(V,G) :- coutXMore(V,XPlus), coutXLess(V,XLess), coutYMore(V,YPlus), coutYLess(V,YLess), coutZMore(V,ZPlus), coutZLess(V,Zless),
                G is XPlus + XLess + YPlus + YLess + ZPlus + Zless - abs(XPlus-XLess) - abs(YPlus - YLess) - abs(ZPlus - Zless).

/**getMaxScore(+NumberOfVertices, -score)
return the max Score a player can get
*/

getMaxScore(0,S) :- grade(0,S),!. 
getMaxScore(N,S) :- grade(N,G), N1 is N-1, getMaxScore(N1,Y), S is G+Y.

/**
getScore(+CurrentVertice,+player, +position,-score)
Return the score of the player
*/

getScore(L,w,PosFinale,S) :- not(member(w,L)),grade(PosFinale,S),!. 
getScore([H|Q],w,Pos,S) :- H == w, PosNext is Pos+1, grade(Pos,G), getScore(Q,w,PosNext,SNext), S is SNext+G,!.
getScore([_|Q],w,Pos,S) :- PosNext is Pos+1, getScore(Q,w,PosNext,SNext), S is SNext.

getScore(L,b,PosFinale,S) :- not(member(b,L)),grade(PosFinale,S),!. 
getScore([H|Q],b,Pos,S) :- H == b, PosNext is Pos+1, grade(Pos,G), getScore(Q,b,PosNext,SNext), S is SNext+G,!.
getScore([_|Q],b,Pos,S) :- PosNext is Pos+1, getScore(Q,b,PosNext,SNext), S is SNext.

getScoreNormalized(V,w,R) :- getScore(V,w,0,S), length(V,X), getMaxScore(X,Y), R is S*100/Y.
getScoreNormalized(V,b,R) :- getScore(V,b,0,S), length(V,X), getMaxScore(X,Y), R is -S*100/Y.

/** hCenter(+vertices,+player,-grade)
Give grade to the current configuration.
*/
hCenter(V,100) :- final(V,max),!. 
hCenter(V,-100) :- final(V,min),!.	

hCenter(V,R) :- getScoreNormalized(V,w,X1), getScoreNormalized(V,b,X2), R is X1+X2.

