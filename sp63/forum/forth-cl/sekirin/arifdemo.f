hex
: pause cr ." Any key to cont." 0 ax ! 16 intr ;
: zsuv
 bye bye bye bye bye
 bye bye bye bye bye
 bye bye bye bye bye
 bye bye bye bye bye
;
variable smyeshch 0 smyeshch !
: vnes ( slowo -> ) ['] zsuv smyeshch @ + !  smyeshch @ 2+ smyeshch ! ;
: vnesc ( bajt -> ) ['] zsuv smyeshch @ + c! smyeshch @ 1+ smyeshch ! ;
' zsuv 40 dump
( 0FB vnesc 0FEEB vnes )
0C68B vnes               ( mov ax,si )
0F58B vnes               ( mov si,bp )
0FE8B vnes               ( mov di,si )
0EF81 vnes 0100 vnes     ( sub di,100h )
0B9 vnesc 0FFA0 vnes     ( mov cx,0FFA0h )
0CD2B vnes               ( sub cx,bp )
0FC vnesc                ( cld )
( 0FEEB vnes )
0A4F3 vnes               ( repe movsb )
( 0FEEB vnes )
0ED81 vnes 0100 vnes     ( sub bp,100h )
0F08B vnes               ( mov si,ax )
0AD vnesc 0E0FF vnes     ( lodsw/jmp ax )
' zsuv 40 dump
1 2 3 4 >r >r zsuv r> r> . . . . pause
' zsuv 40 dump
( ------------------------ )
: s1 " 0.5" ;
: s2 " 0.2" ;
create s3 11 allot
create r1 6 allot create r2 6 allot create r3 6 allot
( : pause cr ." Any key to cont." 0 ax ! 16 intr ; )
52 intr pause
: actio ( cod -> ) dx ! 51 intr ;
: s>r ( s r -> )
 cx ! ax !
 1 actio
;
r1 6 dump s1 r1 s>r r1 6 dump pause
r2 6 dump s2 r2 s>r r2 6 dump pause
: plus ( a b c -> )
 cx ! bx ! ax !
 21 actio
;
r3 6 dump r1 r2 r3 plus r3 6 dump pause
: r>s_10_4 ( r s -> ) ( po formatu r:10:4 )
 cx ! ax !
 0 bx ! 10 si ! 4 di !
 2 actio
;
r3 s3 r>s_10_4
: print count type ;
s3 print
bye
