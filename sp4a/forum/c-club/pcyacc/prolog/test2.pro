/*  Some list goals from C&M, pp. 149-151.   */

last(X,[X]).
last(X,[_|Y]) :- last(X,Y).

nextto(X,Y,[X,Y|_]).
nextto(X,Y,[_|Z]) :- nextto(X,Y,Z).

append([],L,L).
append([X|L1],L2,[X|L3]) :- append(L1,L2,L3).

member(E1,List) :- append(_,[E1|_],List).

rev([],[]).
rev([H|T],L) :- rev(T,Z), append(Z,[H],L).

efface(A,[A|L],L) :- !.
efface(A,[B|L],[B|M]) :- efface(A,L,M).

delete(_,[],[]).
delete(X,[X|L],M) :- !, delete(X,L,M).
delete(X,[Y|L1],[Y|L2]) :- delete(X,L1,L2).

subst(_,[],[]).
subst(X,[X|L],A,[A|M]) :- !, subst(X,L,A,M).
subst(X,[Y|L],A,[Y|M]) :- subst(X,L,A,M).
