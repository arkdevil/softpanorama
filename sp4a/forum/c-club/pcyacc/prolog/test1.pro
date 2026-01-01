/*  From C&M, p.104  */

read_in([W|Ws]) :- get0(C), readword(C,W,C1), restsent(W,C1,Ws).

restsent(W,_,[]) :- lastword(W), !.
restsent(W,C,[W1|Ws]) :- readword(C,W1,C1), restsent(W1,C1,Ws).

readword(C,W,C1) :- single_character(C), !, name(W,[C]), get0(C1).
readword(C,W,C2) :-
	in_word(C,NewC), !,
	get0(C1),
	restword(C1,Cs,C2),
	name(W,[NewC|Cs]).
readword(C,W,C2) :- get0(C1), readword(C1,W,C2).

restword(C,[NewC|Cs],C2) :-
	in_word(C,NewC),
	get0(C1),
	restword(C1,Cs,C2).
restword(C,[],C).

/*  this is an /* embedded */ comment  */

single_character(44).   /*  ,  */
single_character(59).   /*  ;  */
single_character(58).   /*  :  */

in_word(C,C) :- C > 96, C < 123.            /*  a b ... z  */
in_word(C,L) :- C > 64, C < 91, L is C+32.  /*  A B ... Z  */
in_word(C,C) :- C > 47, c < 58.             /*  1 2 ... 9  */
