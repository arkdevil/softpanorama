From: Rony.Flatscher@wu-wien.ac.at
Newsgroups: comp.lang.rexx
Subject: Would such a change effect *any* REXX-programs ?
Date: 4 Oct 1995 17:48:47 GMT

Just a short question to those having built REXX-programs on their own:

An IF statement seems to always evaluate all expressions, regardless whether it
became already clear whether a condition was fullfilled or never may be
fullfilled, e.g.

case 1) OR

  b = "Something"

  IF DATATYPE(b, "Alphanumeric") | (b * 3) > 10 THEN SAY "somehow o.k."
                                                ELSE SAY "*not* o.k."

Yields an error, because of expression (b * 3) > 10.  Yet, after the first
(successful) expression DATATYPE(b, "Alphanumeric") it becomes clear that the IF
condition holds in any case.

So evaluating the second expression is useless in this case, it wouldn't change
the logical result anymore.



case 2) AND

   a = "This is a string, not a number!"

   IF DATATYPE(a, "Numeric") & (a * 3) > 10 THEN SAY "o.k."
                                            ELSE SAY "*not* o.k."

Yields an error, because of expression (a * 3) > 10. Yet, after the first
(failing) expression DATATYPE(a, "Numeric") it becomes clear that this IF
condition never will fullfill.

So evaluating the second expression is useless in this case, it wouldn't change
the logical result anymore.



case 3) a "real" world example (may be even from a text book of pseudocode)

The above examples may look a little weird, but consider a tree-traversal (in
Object REXX terms), e.g.:

       DO WHILE y <> .nil & x = y ~ left
          ...
       END

which bombs, if y is .nil !

This is because the second expression gets evaluated, even if the first one
evaluated to .false (because y *is* .nil) already and the .nil object wouldn't
understand the message "left" sent to it in the second expression.

Instead one would need to rewrite the above statement like

       DO WHILE y <> .nil
           IF x <> y ~ left THEN LEAVE  /* negated form necessary ! */
           ...
       END

Needless to say this is bothersome, even more so if there are many expressions
to evaluate.  (Besides, it seems to be a *waste* of time to further evaluate the
expressions, if it has become clear already that only one possible logical value
is possible in the final result.)


Does anyone rely on this "feature" of REXX evaluating booleans ?  If so, how
(please post an example) ??


Wouldn't it be *much* more intuitive, if evaluation stops, if a result was clear
already (like in other programming languages) ?

Am I overseeing something, or may this even be called a "bug" of (Object) REXX ?

---rony
P.S.:  The described behavior exists in REXX and therefore in Object REXX too.



