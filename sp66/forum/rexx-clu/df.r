/*===================================================================*/
/*          Finds the DERIVATIVE of the given function               */
/*     Bill N. Vlachoudis                                     o o    */
/*     Computer adDREss.......CACZ0200 AT Grtheun1.EARN     ____oo_  */
/*     HomE AdDreSs...........Parodos Filippoy 51          /||    |\ */
/*   !                        TK 555-35 Pylaia              ||    |  */
/* !  tHe bESt Is             ThesSALONIKI, GREECE          '.___.'  */
/*  Y e t  to   Co mE !                                     MARMITA  */
/*===================================================================*/
call load 'files.r'
arg fun ',' dx
if dx = '' then dx = 'X'
/*FUN = '2*X+X*X*X +(X/Y)' ; DX = 'X'*/
OPERATORS = '( + - * / ^ _ ) '  ; op = words(operators)
STACKP    = '0 1 3 5 7 101120'
INPUTP    = '202 4 6 8 9 120 '
call learn
fun = space(fun,1)
if fun = '' then exit 10
say 'FUNCTION = 'fun
fun = putblanks(fun)
fun = postfix(fun)
fun = sort(fun)
fun = df(fun)
fun = sort(fun)
fun = infix(fun)
c = '_`-`' ; call change c
say 'DF = 'fun
exit 0
putblanks : procedure expose operators op
arg fun
fun = space(fun,0)
c = "(`( `" ; call change c
c = ")` )`" ; call change c
Do i = 2 to op - 1
   c = word(operators,i) || "` " || word(operators,i) || " `"
   call change c
End
Return fun
postfix: procedure expose operators inputp stackp
arg fun
stack = '(';
queue = '';
wo = words(fun);
Do i = 1 to wo
   co = word(fun,i) ; la = word(stack,1)
   if co = '-' then if la = '(' then co = '_'
   inp = input(co) ; st = stack(la)
   Do while inp < st
      parse var stack la stack
      queue = queue la
      la    = word(stack,1)
      st    = stack(la)
   End
   if co ^= ')' ;then stack = co stack
                ;else do
                   parse var stack la stack
                   queue = queue la
                 End
End
Queue = queue stack
c = " (` `"
fun = queue
call change c
fun = space(fun)
Return fun
 
input : procedure expose operators inputp
arg op .
p = pos(op' ',operators)
if right(op,1) = "(" then Return 20
in = 12
if p ^= 0 then in = substr(inputp,p,2)
Return in
stack : procedure expose operators stackp
arg op .
p = pos(op' ',operators)
if right(op,1) = "(" then Return 0
st = 11
if p ^= 0 then st = substr(stackp,p,2)
Return st
 
change : procedure expose fun
arg old "`" new "`" .
p = pos(OLD,FUN) ; l = length(old) ; l2 = length(new)
Do while p > 0
   if p = 1 ;then le = ""
            ;else le = left(fun,(p-1))
   if p+l = length(fun)+1 ;then ri = ""
                          ;else ri = substr(fun,(p+l))
   fun = le || new || ri
   p   = p + l2
   p = pos(old,fun,p);
End
Return
oper : procedure expose operators
arg x
p = 0
if pos(x,operators) ^= 0 then if x = "_" ;then p = 1
                                          ;else p = 2
if right(x,1) = '(' then p = 1
Return p
 
find_a_b : procedure expose a b op operators fun le ri
arg prt
op = word(fun,prt) ; p = prt ; p2 = 0
po = oper(op)
if po = 1 then p2 = p
Do while po > 0 & p > 0
    p = p - 1
    po = po + oper(word(fun,p)) - 1
    if po = 1 & p2 = 0 then p2 = p
End
/* le = '' ; ri = '' ; wo = words(fun)                  */
/* if p > 1 then le = subword(fun,1,(p-1))              */
/* if p < wo then ri = subword(fun,(prt+1),(wo-prt))    */
a = subword(fun,p,(p2-p))  ;
b = subword(fun,p2,(prt-p2))
Return 0
/*****************************************************************/
DF : procedure expose operators dx d.
arg fun
if words(fun) < 2 then do
         R = (fun = dx)
         Return R
         End
wl = words(fun)
call find_a_b wl
dfa = df(a)
dfb = df(b)
Select
   When op = '+' then fun = dfa dfb '+'
   When op = '-' then fun = dfa dfb '-'
   When op = '*' then fun = dfa b '*' a dfb '* +'
   When op = '/' then fun = dfa b '*' a dfb '* -' b '2 ^ / '
   When op = '_' then fun = dfa '_'
   When op = '^' then do
                 if dfb = 0 ;then fun = b a b 1 '- ^ 'dfa' * *'
                 ;else do
                 fun = a dfb '^' b '1' a '/' dfa '* * +'
                   end
                 end
   Otherwise Do
      Parse var op op '('
      f = 1
      Do i = 1 to d.0
      if op = d.i.1 then do;interpret 'fun = 'd.i.2
                         f = 0 ; leave ; end
      end
      if f then do ; Say 'Illegal function --> 'op ; fun = '' ; end
      End
End
Return fun
infix: procedure expose operators inputp stackp nl
arg fun
wo = words(fun)
if wo = 1 then do
          nl = 20 ; return fun; end
call find_a_b wo
a = infix(a); lastl = nl
if b ^= '' then do ; b = infix(b) ; lastr = nl ; end
new = input(op)
if right(op,1) = '(' | op = '_' ; then do
                  parse var op op "("
                  fix = op || "(" || a || ")"
if op = '_' then if lastl<6 | lastl = 9 ;then new = 4
                                        ;else fix = "(_"a")" ;
                          End ; else do
          if new > lastl & lastl ^= 20 then a = "("a")"
          if new > lastr & lastr ^= 20 then b = "("b")"
          fix = a || op || b
          end
nl = new
Return fix
 
sort: procedure expose operators
arg fun
wo = words(fun)
if wo = 1 then return fun
call find_a_b wo
a = sort(a)
if b ^= '' then b = sort(b)
if op = '*' | op = '+' then  do
       nb = datatype(b,'NUM')
       if a > b | nb then fun = b a op
       z = 1
       if op = '*' ;then
           Select
           when a = 0 | b = 0 then fun = 0
           When a = 1 then fun = b
           When b = 1 then fun = a
           when a = b then fun = a '2 ^'
           When a =-1 then fun = b '_'
           When b =-1 then fun = a '_'
           Otherwise nop
        End
        ;else Select
           When a = 0 then fun = b
           When b = 0 then fun = a
           when a = b then fun = a '2 *'
           Otherwise NOP; end
     End
if op = '_' & a = 0 then fun = a
if op = '^' & b = 1 then fun = a
if op = '^' & b = 0 then fun = 1
if datatype(a,'NUM') & datatype(b,'NUM') then
     interpret 'fun = a 'op' b'
Return fun
 
learn : procedure expose l. d. operators inputp stackp op
if ^state('algebra.fun') then do
  p.0 = 0; return 1;
end
/*'STATE algebra function *'
if rc ^= 0 then do ; p.0 = 0 ; return 1 ; end
'Execio * diskr algebra function * 1 (stem F.'*/
d = 0 ; l = 0
Do i = 1 until eof('algebra.fun')
   f.i = read('algebra.fun')
   if left(f.i,1) = '*' then iterate;
   parse var f.i fir '=' sec
   upper fir sec
   df = 0
   if left(fir,2) = 'DF' then do
           df = 1
           parse var fir . '(' fir '(' .
           end
   fir = postfix(space(putblanks(fir),1));
   sec = postfix(space(putblanks(sec),1));
   if df ;then do
         d = d + 1
         d.d.1 = fir
         d.d.2 = mama(sec)
         end
         ;else do
         l = l + 1
         l.l.1 = mama(fir)
         l.l.2 = mama(sec)
         end
End
f.0 = i
d.0 = d ; l.0 = l
Return 0
mama : procedure
arg fun
wo = words(fun) ; r = ''
do i = 1 to wo
   a = word(fun,i)
   if a = 'A' | a = 'DFA' ;then r = r a
                          ;else r = r "'"a"'"
end
return r
