\ arifm.s plav.tochkoj; dlya ispolhz.nado zapust.arifmyet.exe -
\ ryezid.prog.,napis.na paskalye.
\ ispolhz.: zapusk.fs.com; include arifmyet.frt (byez kavychek i t.p.);
\ zatyem mozhno vyz.opis.zdyesh f-tsii.
\ ZHELAT.PROSM.PAMYATH IZ DANN.PROG. - YESTH LI NUZHN.RYEZIDYENT !
hex
registers regs
: ax regs ax ; : bx regs bx ; : cx regs cx ; : dx regs dx ;
: si regs si ; : di regs di ;
: intr regs intr ;
\ ----------------------
create srab 17 allot
variable irab
: real ( create byeryot imya iz vkh.potoka ) create 6 allot ;
real r1 real r2 real r3 real r4 real r5 real r6 real r7 real r8
\ ------------------------------
: pause cr ." Any key to cont." 0 ax ! 16 intr ;
\ ------------------------------------------
: actio ( cod -> ) dx ! 51 intr ;
: 1arg ( arg1 resu -> ) cx ! ax ! ;
: 2arg ( arg1 arg2 resu -> ) cx ! bx ! ax ! ;
\ ------------------------------------------
: s>r ( s r -> ) 1arg 1 actio ;
: r>s_10_4 ( r s -> ) ( po f-tu r:10:4 ) 1arg 0 bx ! 10 si ! 4 di ! 2 actio ;
: i>r ( i r -> ) 1arg 3 actio ;
: round ( r i -> ) 1arg 4 actio ;
: trunc 1arg 5 actio ;
\ -------------------------------------
: p= ( a b -> flag ) irab 2arg 11 actio irab @ ;
: p> ( a b -> flag ) irab 2arg 12 actio irab @ ;
\ ---------------------------------
: p+ ( a b c -> ) 2arg 21 actio ;
: p- ( a b c -> ) 2arg 22 actio ;
: p* ( a b c -> ) 2arg 23 actio ;
: p/ ( a b c -> ) 2arg 24 actio ;
\ -----------------------------------
: ppi ( c -> ) cx ! 31 actio ;
: frac ( a c -> ) 1arg 32 actio ;
: int 1arg 33 actio ;
: abs 1arg 34 actio ;
: sqr 1arg 35 actio ;
: sqrt 1arg 36 actio ;
: exp 1arg 37 actio ;
: ln  1arg 38 actio ;
: sin 1arg 39 actio ;
: cos 1arg 03A actio ;
: arctan 1arg 03B actio ;
: -x 1arg 41 actio ;
: 1/x 1arg 42 actio ;
\ ----------------------------------
: immed>r ( immed r -> ) >r irab ! irab r> i>r ;
: vyv ( r -> ) srab r>s_10_4 srab print ;
\ nado sdyel. := .
\ ----------------------------------
: s1 " 0.5" ;
: s2 " 0.2" ;
s1 r1 s>r
s2 r2 s>r
r1 r2 r3 p+
r1 vyv r2 vyv r3 vyv cr
pause
\ bye nye stavim,t.k.planir vkl.po include.
\ pyeryed zapuskom nado: include arifmye.frt ;
\ zapusk - po include.
decimal
1 r1 immed>r 2 r2 immed>r 12 r4 immed>r
r2 r3 ln ( r3=ln2 ) r3 r4 r3 p/ ( r3=ln2/12 )
: main
 13 0 do
  i r5 immed>r
  r3 r5 r5 p* ( r5=ln2*[i/12] ) r5 r5 exp ( r5=2^[i/12] )
  r5 r7 frac
  i 0 > i 12 < and if r1 r7 r8 p/ else 0 r8 immed>r then
  i . r5 vyv r8 vyv cr
 loop
;
main
pause
\ --------------------------------------
hex
real rrab real delta real pi real eps
: seps " 0.01" ; seps eps s>r
pi ppi delta ppi rrab ppi
eps vyv pi vyv delta vyv rrab vyv pause cr
: razb0
 ( podgot.k nakh.tsepn.drobi )
 ( napr.,rrab=3.1416 -> 3 0 v stekye i delta=0.1416 )
 rrab irab trunc irab @ 0 rrab delta frac
;
: stadia ( k0...kn n; dn -> k0...kn+1; dn+1 )
 ." stadia:bylo:" s. delta vyv cr
 delta delta 1/x   delta irab trunc 1+ irab @ swap   delta delta frac
 ." stadia ->:" s. delta vyv pause cr
;
: kettebruch
 ( v rrab - chislo; -> v stekye - k0...kn n i chislo v delta; )
 ( iskh.chislo=k0+[1/[k1+[1/[.../kn+delta]]]] )
 razb0
 begin
  dup 3 < delta eps p> and
 while
  stadia s.
 repeat
;
kettebruch
s. cr
bye
