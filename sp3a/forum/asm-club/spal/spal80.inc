	.XLIST

;******************************************************************
;     Определение количества аргументов
;******************************************************************
.narg     macro code,x1,x2,x3,x4,x5,x6,x7,x8
	  ifnb <x8>
	     code = 8
	     exitm
	  endif
	  ifnb <x7>
	     code = 7
	     exitm
	  endif
	  ifnb <x6>
	     code = 6
	     exitm
	  endif
	  ifnb <x5>
	     code = 5
	     exitm
	  endif
	  ifnb <x4>
	     code = 4
	     exitm
	  endif
	  ifnb <x3>
	     code = 3
	     exitm
	  endif
	  ifnb <x2>
	     code = 2
	     exitm
	  endif
	  ifnb <x1>
	     code = 1
	     exitm
	  endif
	  code = 0
	  endm

;******************************************
;        Определение кода операции
;******************************************
.defopr   macro   code,opr
	  ifidn <opr>,<ON>
	    code = 101h
	    exitm
	  endif
          ifidn <opr>,<NE>
            code = 1
            exitm
          endif
          ifidn <opr>,<NZ>
            code = 1
            exitm
          endif

	  ifidn <opr>,<OFF>
	    code = 102h
	    exitm
	  endif
          ifidn <opr>,<EQ>
            code = 2
            exitm
          endif
	  ifidn <opr>,<E>
            code = 2
            exitm
          endif
          ifidn <opr>,<Z>
            code = 2
            exitm
          endif

	  ifidn <opr>,<A>
	    code = 3
	    exitm
	  endif
	  ifidn <opr>,<NBE>
	    code = 3
	    exitm
	  endif

	  ifidn <opr>,<NC>
	    code = 4
	    exitm
	  endif
	  ifidn <opr>,<AE>
	    code = 4
	    exitm
	  endif
	  ifidn <opr>,<NB>
	    code = 4
	    exitm
	  endif

	  ifidn <opr>,<C>
	    code = 5
	    exitm
	  endif
	  ifidn <opr>,<B>
	    code = 5
	    exitm
	  endif
	  ifidn <opr>,<NAE>
	    code = 5
	    exitm
	  endif

          ifidn <opr>,<NA>
	    code = 6
	    exitm
	  endif
	  ifidn <opr>,<BE>
	    code = 6
	    exitm
	  endif

	  ifidn <opr>,<G>
	    code = 7
	    exitm
	  endif
	  ifidn <opr>,<GT>
	    code = 7
	    exitm
	  endif
          ifidn <opr>,<NLE>
	    code = 7
	    exitm
	  endif

          ifidn <opr>,<P>
	    code = 8
	    exitm
	  endif
	  ifidn <opr>,<NS>
	    code = 8
	    exitm
	  endif
	  ifidn <opr>,<GE>
	    code = 8
	    exitm
	  endif
	  ifidn <opr>,<NL>
	    code = 8
	    exitm
	  endif

          ifidn <opr>,<M>
	    code = 9
	    exitm
	  endif
	  ifidn <opr>,<S>
	    code = 9
	    exitm
	  endif
	  ifidn <opr>,<LT>
	    code = 9
	    exitm
	  endif
	  ifidn <opr>,<L>
	    code = 9
	    exitm
	  endif
	  ifidn <opr>,<NGE>
	    code = 9
	    exitm
	  endif

          ifidn <opr>,<LE>
	    code = 10
	    exitm
	  endif
	  ifidn <opr>,<NG>
	    code = 10
	    exitm
	  endif

	  ifidn <opr>,<PO>
	    code = 11
	    exitm
	  endif

	  ifidn <opr>,<PE>
	    code = 12
	    exitm
	  endif

	  code = -1
	  .err SPAL  ERROR   bad operation
	  endm

;******************************************************************
;          Генерация переходов
;******************************************************************

;**********************************************
;          Безусловный переход
;**********************************************
.genjmp   macro    lbl
          jmp  .&lbl
	  endm

;**********************************************
;         Прямой переход
;**********************************************
.genbrd   macro    opr,lbl
	  local  .loc1,.loc2
          if opr eq 1
	    jnz  .&lbl
            exitm
          endif
          if opr eq 2
	    jz   .&lbl
            exitm
	  endif
	  if opr eq 3
	    jc   .loc1
	    je   .loc1
	    jmp  .&lbl
       .loc1:
	    exitm
	  endif
	  if opr eq 4
	    jnc  .&lbl
            exitm
          endif
	  if opr eq 5
	    jc   .&lbl
            exitm
	  endif
	  if opr eq 6
	    jc   .&lbl
	    je   .&lbl
            exitm
	  endif
	  if opr eq 7
	    jm   .loc2
	    je   .loc2
	    jmp  .&lbl
       .loc2:
	    exitm
	  endif
	  if opr eq 8
	    jp   .&lbl
            exitm
          endif
	  if opr eq 9
	    jm   .&lbl
            exitm
	  endif
	  if opr eq 10
	    jm   .&lbl
	    je   .&lbl
            exitm
	  endif
	  if opr eq 11
	    jpo  .&lbl
            exitm
          endif
	  if opr eq 12
	    jpe  .&lbl
            exitm
          endif
	  endm

;************************************
;        Обратный переход
;************************************
.genbrr   macro    opr,lbl
	  local   .loc1,.loc2
	  if opr eq 1
	    jz   .&lbl
            exitm
          endif
          if opr eq 2
	    jnz  .&lbl
            exitm
          endif
	  if opr eq 3
	    jc   .&lbl
	    je   .&lbl
            exitm
	  endif
	  if opr eq 4
	    jc   .&lbl
            exitm
          endif
	  if opr eq 5
	    jnc  .&lbl
            exitm
	  endif
	  if opr eq 6
	    jc   .loc1
	    je   .loc1
	    jmp  .&lbl
       .loc1:
            exitm
	  endif
	  if opr eq 7
	    jm   .&lbl
	    je   .&lbl
            exitm
	  endif
	  if opr eq 8
	    jm   .&lbl
            exitm
          endif
	  if opr eq 9
	    jp   .&lbl
            exitm
	  endif
	  if opr eq 10
	    jm   .loc2
	    je   .loc2
	    jmp  .&lbl
       .loc2:
	    exitm
	  endif
	  if opr eq 11
	    jpe  .&lbl
            exitm
          endif
	  if opr eq 12
	    jpo  .&lbl
            exitm
          endif
          endm


;************************************************
;         Генерация операции
;************************************************
.genopr   macro  code,ta1,x1,opr,ta2,x2
	  .narg ?narg,ta1,<x1>,opr,ta2,<x2>
          if ?narg eq 1
	    .defopr code,ta1
          else
	    .defopr code,opr
	  endif
	  if code ge 100h
	    if ?narg eq 5
	      .TEST  ta1,<x1>,ta2,<x2>
	    else
	      .err  SPAL ERROR   bad arguments
	    endif
          else
	    if ?narg eq 5
	      .CMP  ta1,<x1>,ta2,<x2>
	    else
	    if ?narg eq 3
	      .CMP  ta1,<x1>,C,0
	    endif
	    endif
	  endif
	  endm

;******************************************************************
;            макро-определения для организации стека
;******************************************************************

.initsp   macro    typ                    ;;инициализация стека
          ?ps&typ =  0
	  endm

.putsp    macro    typ,num                ;;запись в стек
          ?ps&typ = (?ps&typ)+1
	  .saves    typ,%(?ps&typ),num
          endm

.saves    macro    typ,lev,num
          ?&typ&lev = num
          endm

.getsp    macro    typ,num                ;;чтение из стека
	  .unsavs   typ,%(?ps&typ),num
          ?ps&typ = (?ps&typ)-1
          endm

.unsavs   macro    typ,lev,num
          num = ?&typ&lev
          endm

;******************************************************************
;       Гeнерация меток
;******************************************************************

.genlbl   macro    lbl
.&lbl:
          endm

;**************************************************
;         Инициализация библиотеки SPAL
;**************************************************
.spal     macro

?IF = 1
?LP = 2
?SW = 3
?OR = 4
?PR = 5

?numor = 0
?numbl = 0
?numll = 0

?orfl  =  0
?andfl =  0

	  .initsp  %?IF
	  .initsp  %?LP
	  .initsp  %?SW
	  .initsp  %?PR
	  endm


;**************************************************
;         Операции с логическими связками
;**************************************************

.OR       macro   ta1,x1,opr,ta2,x2
	  .genbrd  ?code,%(?OR*1000+?numor)
          ?orfl = 1
	  .genopr  ?code,ta1,<x1>,opr,ta2,<x2>
	  endm

.AND      macro   ta1,x1,opr,ta2,x2
	  .genbrr  ?code,%?andlb
          ?andfl = 1
	  if ?orfl
	     .genlbl  %(?OR*1000+?numor)
	     ?numor = ?numor+1
	     ?orfl  = 0
	  endif
	  .genopr  ?code,ta1,<x1>,opr,ta2,<x2>
	  endm

.BEGIN    macro
	  if ?so_type eq 0
	     exitm
	  endif
	  .genbrr  ?code,%(?so_type*1000+?numbl)
	  .putsp   %?so_type,?numbl
          ?numbl = ?numbl+1
          if ?orfl
            .genlbl %(?OR*1000+?numor)
            ?numor = ?numor+1
            ?orfl  = 0
          endif
	  endm

.WHILE    macro   ta1,x1,opr,ta2,x2
	  .genlbl  %(?LP*1000+?numbl)
	  .putsp   %?LP,?numbl
          ?numbl = ?numbl+1
	  .genopr  ?code,ta1,<x1>,opr,ta2,<x2>
          ?so_type  = ?LP
          ?andlb = ?LP*1000+?numbl
          endm

.BREAK    macro
	  .getsp  %?LP,?num
	  .genjmp %(?LP*1000+?num)
	  .putsp  %?LP,?num
          endm

.BREAK_IF macro   ta1,x1,opr,ta2,x2
	  .getsp  %?LP,?num
	  .genopr ?code,ta1,<x1>,opr,ta2,<x2>
	  .genbrd ?code,%(?LP*1000+?num)
	  .putsp  %?LP,?num
          endm

;*********************************************************
;         Условный оператор .IF  ta x1 opr ta x2
;                           .OR  ta x1 opr ta x2
;                           .AND ta x1 opr ta x2
;                           .BEGIN
;                              ..........
;                           .ELSE
;                              ..........
;                           .ENDI
;*********************************************************

.IF       macro   ta1,x1,opr,ta2,x2
	  .genopr  ?code,ta1,<x1>,opr,ta2,<x2>
          ?so_type  = ?IF
          ?andlb = ?IF*1000+?numbl
	  endm


.ELSE     macro
	  .genjmp  %(?IF*1000+?numbl)
	  .getsp   %?IF,?num
	  .genlbl  %(?IF*1000+?num)
	  .putsp   %?IF,?numbl
          ?numbl = ?numbl+1
	  endm

.ENDI     macro
	  .getsp  %?IF,?num
	  .genlbl %(?IF*1000+?num)
          endm

;********************************************************
;      Оператор цикла  .WHILE ta,x1 opr ta,x2
;                      .OR    ta,x1 opr ta,x2
;                      .AND   ta,x1 opr ta,x2
;                      .BEGIN
;                      .......
;                        .BREAK (.BREAK_IF ta1,x1,opr,ta2,x2)
;                      .......
;                      .ENDW
;********************************************************

.ENDW     macro
	  .getsp  %?LP,?num
	  .getsp  %?LP,?num1
	  .genjmp %(?LP*1000+?num1)
	  .genlbl %(?LP*1000+?num)
          endm

;******************************************************
;       Оператор цикла  .DO
;                       .......
;                         .BREAK (.BREAK_IF ta1,x1,opr,ta2,x2)
;                       .......
;                       .WHILE ta,x1 opr ta,x2
;                       .OR    ta,x1 opr ta,x2
;                       .AND   ta,x1 opr ta,x2
;                       .ENDD
;******************************************************

.DO       macro
	  .genlbl  %(?LP*1000+?numbl)
	  .putsp   %?LP,?numbl
          ?numbl = ?numbl+1
	  .putsp   %?LP,?numbl
          ?numbl = ?numbl+1
	  endm


.ENDD     macro
          .getsp   %?LP,?num
	  .getsp   %?LP,?num
	  .getsp   %?LP,?num1
	  .genbrd  ?code,%(?LP*1000+?num1)
          if ?orfl
             .genjmp %(?LP*1000+?num)
             .genlbl %(?OR*1000+?numor)
             ?numor = ?numor+1
             .genjmp %(?LP*1000+?num1)
             ?orfl = 0
          endif
	  .genlbl  %(?LP*1000+?num)
	  endm

;*******************************************************
;      Оператор цикла   .FOR ta cnt,ta limit
;                       .BEGIN
;                       ..........
;                          .BREAK (.BREAK_IF ta1,x1,opr,ta2,x2)
;                       ..........
;                       .ENDF
;*******************************************************
.FOR      macro   ta1,x1,ta2,x2
	  ifnb <ta2>
	    .MOV   ta1,<x1>,ta2,<x2>
	  endif
	  .genlbl  %(?LP*1000+?numbl)
	  .putsp   %?LP,%?numbl
          ?numbl = ?numbl+1
	  .DEC     ta1,<x1>
	  .genopr  ?code,ta1,<x1>,GE,C,0
          ?so_type  = ?LP
	  endm

.ENDF     macro
	  .getsp   %?LP,?num
	  .getsp   %?LP,?num1
	  .genjmp  %(?LP*1000+?num1)
	  .genlbl  %(?LP*1000+?num)
	  endm

;**************************************************
;        Оператор цикла    .LOOP
;                          ............
;                              .BREAK (.BREAK_IF ta1,x1,opr,ta2,x2)
;                          ............
;                          .ENDL
;**************************************************
.LOOP     macro
          .DO
          endm
.ENDL     macro
          .ENDF
          endm


;**************************************************
;        Оператор выбора     .SWITCH ta,x1
;                              .CASE  x1 ... x5
;                              ........
;                              .CASE  x1 ... x5
;                              .DEFAULT
;                            .ENDS
;**************************************************

.tsteq    macro   size,x1,x2,x3,x4,x5
	  ifb <x1>
	    exitm
	  endif
          if size eq 1
	    .IF R  a EQ C  <x1>
          else
	    .IF RW b EQ CW <x1>
          endif
	  ifb <x2>
	     exitm
	  endif
          if size eq 1
	    .OR R  a EQ C  <x2>
          else
	    .OR RW b EQ CW <x2>
          endif
	  ifb <x3>
	     exitm
	  endif
          if size eq 1
	    .OR R  a EQ C  <x3>
          else
	    .OR RW b EQ CW <x3>
          endif
	  ifb <x4>
	     exitm
	  endif
          if size eq 1
	    .OR R  a EQ C  <x4>
          else
	    .OR RW b EQ CW <x4>
          endif
	  ifb <x5>
	     exitm
	  endif
          if size eq 1
	    .OR R  a EQ C  <x5>
          else
	    .OR RW b EQ CW <x5>
          endif
	  endm

.SWITCH   macro   ta,x1
          .defsize ?size_sw,ta
          if ?size_sw eq 1
	    .MOV   R  a, ta,<x1>
          else
	    .MOV   RW b, ta,<x1>
          endif
          .putsp   %?SW,?size_sw
	  .putsp   %?SW,0
	  endm

.CASE     macro   x1,x2,x3,x4,x5
          .getsp   %?SW,?numcs
          .getsp   %?SW,?size_sw
	  if ?numcs ne 0
	     .ELSE
	  endif
	  .tsteq   ?size_sw,<x1>,<x2>,<x3>,<x4>,<x5>
	  .BEGIN
          ?numcs = ?numcs+1
          .putsp   %?SW,?size_sw
	  .putsp   %?SW,?numcs
	  endm

.DEFAULT  macro
	  .getsp   %?SW,?numcs
	  if ?numcs ne 0
	     .ELSE
	  endif
	  .putsp   %?SW,?numcs
	  endm

.ENDS     macro
          .getsp   %?SW,?numcs
	  .getsp   %?SW,?size_sw
	  rept    ?numcs
	     .ENDI
	  endm
	  endm


;*****************************************************************
;          Оператор сохранения в стеке
;             .PUSH    ta1,x1,ta2,x2,ta3,x3,ta4,x4,ta5,x5,ta6,x6
;          Оператор восстановления из стека
;             .POP  ta1,x1,ta2,x2,ta3,x3,ta4,x4,ta5,x5,ta6,x6
;*****************************************************************

.PUSH   macro   ta1,x1,ta2,x2,ta3,x3,ta4,x4,ta5,x5,ta6,x6
        ifb <ta1>
          push psw
          push b
          push d
          push h
          exitm
        endif
	.push_1 ta1,<x1>
	.push_1 ta2,<x2>
	.push_1 ta3,<x3>
	.push_1 ta4,<x4>
	.push_1 ta5,<x5>
	.push_1 ta6,<x6>
	endm

.POP    macro  ta1,x1,ta2,x2,ta3,x3,ta4,x4,ta5,x5,ta6,x6
        ifb <ta1>
          pop h
	  pop d
	  pop b
	  pop psw
	  exitm
	endif
	.pop_1 ta6,<x6>
	.pop_1 ta5,<x5>
	.pop_1 ta4,<x4>
	.pop_1 ta3,<x3>
	.pop_1 ta2,<x2>
	.pop_1 ta1,<x1>
	endm

;***********************************************************************
;          Оператор вызова функции
;              .CALL  name, ta1,x1,ta2,x2,ta3,x3,ta4,x4,ta5,x5,ta6,x6
;***********************************************************************
.CALL    macro  name, ta1,x1,ta2,x2,ta3,x3,ta4,x4,ta5,x5,ta6,x6
	 push  h
	 .push_1 ta6,<x6>
	 .push_1 ta5,<x5>
	 .push_1 ta4,<x4>
	 .push_1 ta3,<x3>
	 .push_1 ta2,<x2>
	 .push_1 ta1,<x1>
	 call name
	 .narg  ?NumPar, ta1,ta2,ta3,ta4,ta5,ta6
	 lxi  h, ?NumPar*2
	 dad  sp
         sphl
         pop  h
         endm

;***********************************************************************
;          Оператор входа в функцию и выхода из нее
;             .ENTER/.LEAVE
;***********************************************************************
.ENTER   macro  loc_size
	 ifb <loc_size>
           lxi  h,  0
	   dad  sp
	   .putsp   %?PR, 0
	 else
	   lxi  h, -loc_size
	   dad  sp
	   sphl
	   push d
	   lxi  d, lock_size
	   dad  d
	   pop  d
	   .putsp   %?PR, 1
	 endif
	 endm

.LEAVE   macro
	 .getsp   %?PR, ?ls
	 if ?ls eq 1
	   sphl
	 endif
	 endm

FALSE   equ  0
TRUE    equ  1
NULL    equ  0

	 .SPAL

         .LIST
