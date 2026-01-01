             .XLIST
; 22-may-91
;
;**************************************************
;        Определить количество аргументов
;**************************************************
.narg     macro   code,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10
	  ifnb <x10>
	     code = 10
	     exitm
	  endif
	  ifnb <x9>
	     code = 9
	     exitm
	  endif
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
	  ifidn <opr>,<E>
	     code = 1
	     exitm
	  endif
	  ifidn <opr>,<EQ>
	     code = 1
	     exitm
	  endif
	  ifidn <opr>,<Z>
	     code = 1
	     exitm
	  endif
          ifidn <opr>,<OFF>
	     code = 1
	     exitm
	  endif

	  ifidn <opr>,<NE>
	     code = 2
	     exitm
	  endif
	  ifidn <opr>,<NZ>
	     code = 2
	     exitm
	  endif
	  ifidn <opr>,<ON>
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

          ifidn <opr>,<AE>
	     code = 4
	     exitm
	  endif
          ifidn <opr>,<NB>
	     code = 4
	     exitm
	  endif
          ifidn <opr>,<NC>
	     code = 4
	     exitm
	  endif

	  ifidn <opr>,<NA>
	     code = 5
	     exitm
	  endif
          ifidn <opr>,<BE>
	     code = 5
	     exitm
	  endif

	  ifidn <opr>,<NAE>
	     code = 6
	     exitm
	  endif
	  ifidn <opr>,<B>
	     code = 6
	     exitm
	  endif
	  ifidn <opr>,<C>
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

	  ifidn <opr>,<NG>
	     code = 8
	     exitm
	  endif
          ifidn <opr>,<LE>
	     code = 8
	     exitm
	  endif

	  ifidn <opr>,<GE>
	     code = 9
	     exitm
	  endif
          ifidn <opr>,<NL>
	     code = 9
	     exitm
	  endif

          ifidn <opr>,<L>
	     code = 10
	     exitm
	  endif
	  ifidn <opr>,<LT>
	     code = 10
	     exitm
	  endif
	  ifidn <opr>,<NGE>
	     code = 10
	     exitm
	  endif

          ifidn <opr>,<P>
	     code = 11
	     exitm
	  endif
	  ifidn <opr>,<PE>
	     code = 11
	     exitm
	  endif

	  ifidn <opr>,<NP>
	     code = 12
	     exitm
	  endif

	  ifidn <opr>,<O>
	     code = 13
	     exitm
	  endif

	  ifidn <opr>,<NO>
	     code = 14
	     exitm
	  endif

	  ifidn <opr>,<S>
	     code = 15
	     exitm
	  endif

	  ifidn <opr>,<NS>
	     code = 16
	     exitm
	  endif

          ifidn <opr>,<CXZ>
	     code = 17
	     exitm
	  endif

          ifidn <opr>,<CXNZ>
	     code = 18
	     exitm
	  endif

          .err  SPAL ERROR   bad operation
          code = -1
	  endm

;******************************************************************
;          Генерация переходов
;******************************************************************

;**********************************************
;          Безусловный переход
;**********************************************
.genjmp   macro    lbl
          jmp near ptr .&lbl
	  endm

;**********************************************
;          Короткий безусловный переход
;**********************************************
.genbr    macro    lbl
	  jmp short .&lbl
	  endm

;**********************************************
;         Прямой переход
;**********************************************
.genbrd   macro    opr,lbl
	  if opr eq 1
	    jz  .&lbl
            exitm
	  endif
	  if opr eq 2
	    jnz  .&lbl
            exitm
	  endif
	  if opr eq 3
	    ja  .&lbl
            exitm
	  endif
	  if opr eq 4
	    jae  .&lbl
            exitm
	  endif
	  if opr eq 5
	    jna  .&lbl
            exitm
	  endif
	  if opr eq 6
	    jnae  .&lbl
            exitm
	  endif
	  if opr eq 7
	    jg  .&lbl
            exitm
	  endif
	  if opr eq 8
	    jng  .&lbl
            exitm
	  endif
	  if opr eq 9
	    jge  .&lbl
            exitm
	  endif
	  if opr eq 10
	    jnge  .&lbl
            exitm
	  endif
	  if opr eq 11
	    jp  .&lbl
            exitm
	  endif
	  if opr eq 12
	    jnp  .&lbl
            exitm
	  endif
	  if opr eq 13
	    jo  .&lbl
            exitm
	  endif
	  if opr eq 14
	    jno  .&lbl
            exitm
	  endif
	  if opr eq 15
	    js  .&lbl
            exitm
	  endif
	  if opr eq 16
	    jns  .&lbl
            exitm
	  endif
          if opr eq 17
            jcxz  .&lbl
            exitm
          endif
          if opr eq 18
            or   cx,cx
            jne  .&lbl
            exitm
          endif
	  endm

;************************************
;        Обратный переход
;************************************
.genbrr   macro    opr,lbl
	  if opr eq 1
	    jnz  .&lbl
            exitm
	  endif
	  if opr eq 2
	    jz  .&lbl
            exitm
	  endif
	  if opr eq 3
	    jna  .&lbl
            exitm
	  endif
	  if opr eq 4
	    jnae  .&lbl
            exitm
	  endif
	  if opr eq 5
	    ja  .&lbl
            exitm
	  endif
	  if opr eq 6
	    jae  .&lbl
            exitm
	  endif
	  if opr eq 7
	    jng  .&lbl
            exitm
	  endif
	  if opr eq 8
	    jg  .&lbl
            exitm
	  endif
	  if opr eq 9
	    jnge  .&lbl
            exitm
	  endif
	  if opr eq 10
	    jge  .&lbl
            exitm
	  endif
	  if opr eq 11
	    jnp  .&lbl
            exitm
	  endif
	  if opr eq 12
	    jp  .&lbl
            exitm
	  endif
	  if opr eq 13
	    jno  .&lbl
            exitm
	  endif
	  if opr eq 14
	    jo  .&lbl
            exitm
	  endif
	  if opr eq 15
	    jns  .&lbl
            exitm
	  endif
	  if opr eq 16
	    js  .&lbl
            exitm
	  endif
          if opr eq 17
            or   cx,cx
	    jne  .&lbl
            exitm
	  endif
          if opr eq 18
	    jcxz .&lbl
            exitm
	  endif
	  endm

;*****************************************************************
;             Генерация операций
;*****************************************************************
.genopr   macro  code,x1,opr,x2
          .narg  ?num,<x1>,opr,<x2>
	  if ?num eq 1
	     .defopr code,x1
	     exitm
	  endif
	  if ?num eq 2
	     or   x1, x1
          else
          ifidn <opr>,<ON>
	     test x2, x1
          else
          ifidn <opr>,<OFF>
	     test x2, x1
          else
             cmp  x1, x2
          endif
          endif
          endif
          .defopr code,opr
	  endm

;******************************************************************
;            МАКРООПРЕДЕЛЕНИЯ ДЛЯ ОРГАНИЗАЦИИ СТЕКА
;******************************************************************
.initsp   macro    typ                    ;;инициализация стека
	  ?ps&typ = 0
	  endm

.putsp    macro    typ,num                ;;запись в стек
	  ?ps&typ = (?ps&typ)+1
	  .saves   typ,%(?ps&typ),num
          endm

.saves    macro    typ,lev,num
	  ?&typ&lev = num
          endm

.getsp    macro    typ,num                ;;чтение из стека
	  .unsavs  typ,%(?ps&typ),num
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
;         Определение длины перехода
;**************************************************
.deflen   macro  len,lbl
	  len = $-.&lbl
	  endm

;**************************************************
;         Инициализация библиотеки SPAL
;**************************************************
.SPAL     macro

?IF  =  1
?LP  =  2
?SW  =  3
?PR  =  4
?LL  =  5
?OR  =  6

?numor = 0
?numll = 0
?numbl = 0

?orfl   = 0
?andfl  = 0

	  .initsp  %?IF
	  .initsp  %?LP
	  .initsp  %?PR
	  .initsp  %?SW
	  endm


;**************************************************
;         Операции с логическими связками
;**************************************************

.OR       macro   x1,opr,x2
	  .genbrd ?code,%(?OR*1000+?numor)
	  ?orfl = 1
	  .genopr ?code,<x1>,opr,<x2>
	  endm

.AND      macro   x1,opr,x2
	  .genbrr ?code,%?andlb
	  ?andfl = 1
	  if ?orfl
	     .genlbl  %(?OR*1000+?numor)
	     ?numor = ?numor+1
	     ?orfl  = 0
	  endif
          .genopr ?code,<x1>,opr,<x2>
	  endm

.BEGIN    macro  long
	  if ?type eq 0
	     exitm
	  endif
	  ifidn <long>,<L>
	    .genbrd ?code,%(?LL*1000+?numll)
	    if ?andfl eq 1
	      .genlbl %(?type*1000+?numbl)
	      ?numbl = ?numbl+1
	      ?andfl = 0
	    endif
	    .genjmp %(?type*1000+?numbl)
	    .genlbl %(?LL*1000+?numll)
	    ?numll = ?numll+1
	  else
	    .genbrr  ?code,%(?type*1000+?numbl)
	  endif
	  .putsp   %?type,?numbl
	  ?numbl = ?numbl+1
	  if ?orfl eq 1
	     .genlbl  %(?OR*1000+?numor)
	     ?numor = ?numor+1
	     ?orfl  = 0
	  endif
	  endm

.WHILE    macro   x1,opr,x2
	  .genlbl  %(?LP*1000+?numbl)
	  .putsp   %?LP,?numbl
	  ?numbl = ?numbl+1
	  .genopr ?code,<x1>,opr,<x2>
	  ?type  = ?LP
          ?andlb = ?LP*1000+?numbl
          endm

.BREAK    macro  long
	  .getsp  %?LP,?endl
	  ifnb <long>
	     .genjmp %(?LP*1000+?endl)
	  else
	     .genbr  %(?LP*1000+?endl)
	  endif
	  .putsp  %?LP,?endl
          endm

.BREAK_IF macro  x1,opr,x2
	  .getsp  %?LP,?endl
          .genopr ?code,<x1>,opr,<x2>
          .genbrd ?code,%(?LP*1000+?endl)
	  .putsp  %?LP,?endl
          endm

;*********************************************************
;         Условный оператор .IF  X1 OPR X2
;                           .OR  X1 OPR X2
;                           .AND X1 OPR X2
;                           .BEGIN  (L)
;                              ..........
;                           .ELSE   (L)
;                              ..........
;                           .ENDI
;*********************************************************

.IF       macro   x1,opr,x2
	  .genopr ?code,<x1>,opr,<x2>
	  ?type = ?IF
	  ?andlb = ?IF*1000+?numbl
	  endm


.ELSE     macro  long
	  ifidn <long>,<L>
	     .genjmp %(?IF*1000+?numbl)
	  else
	     .genbr  %(?IF*1000+?numbl)
	  endif
	  .getsp   %?IF,?num
	  .genlbl  %(?IF*1000+?num)
	  .putsp   %?IF,?numbl
	  ?numbl = ?numbl+1
	  endm

.ENDI     macro
	  .getsp  %?IF,?num
	  .genlbl %(?IF*1000+?num)
          endm

;***************************************************************************
;  Условный оператор .$IF <логическое выражение>,<инструкция1>,<инструкция2>
;***************************************************************************
.$IF      macro   log,instr1,instr2
	  .IF  log
	  .BEGIN
	  instr1
	  ifnb <instr2>
	    .ELSE
	    instr2
	  endif
	  .ENDI
	  endm

;********************************************************
;      Оператор цикла  .WHILE X1 OPR X2
;                      .OR    X1 OPR X2
;                      .AND   X1 OPR X2
;                      .BEGIN  (L)
;                      .......
;                        .BREAK  (L) (.BREAK_IF X1 OPR X2)
;                      .......
;                      .ENDW
;********************************************************


.ENDW     macro
	  .getsp  %?LP,?num
	  .getsp  %?LP,?num1
	  .deflen ?len,%(?LP*1000+?num1)
          if  ?len ge 127
	     .genjmp %(?LP*1000+?num1)
	  else
	     .genbr  %(?LP*1000+?num1)
	  endif
	  .genlbl %(?LP*1000+?num)
          endm

;******************************************************
;       Оператор цикла  .DO
;                       .......
;                         .BREAK (L) (.BREAK_IF X1 OPR X2)
;                       .......
;                       .WHILE X1 OPR X2
;                       .OR    X1 OPR X2
;                       .AND   X1 OPR X2
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
	  .deflen  ?len,%(?LP*1000+?num1)
          if ?len ge 127
	     .genbrr ?code,%(?LP*1000+?num)
	     .genjmp %(?LP*1000+?num1)
	  else
	     .genbrd  ?code,%(?LP*1000+?num1)
	     if ?orfl eq 1
	       genbr  %(?LP*1000+?num)
	     endif
	  endif
	  if ?orfl eq 1
	    .genlbl  %(?OR*1000+?numor)
	    ?numor = ?numor+1
            if ?len ge 127
	      .genjmp %(?LP*1000+?num1)
	    else
	      .genbr  ?code,%(?LP*1000+?num1)
	    endif
            ?orfl  = 0
	  endif
	  .genlbl  %(?LP*1000+?num)
	  if ?andfl eq 1
	    .genlbl %(?LP*1000+?numbl)
	    ?numbl = ?numbl+1
	    ?andfl = 0
	  endif
	  endm

;*******************************************************
;      Оператор цикла   .FOR CNT,LIMIT
;                       .BEGIN (L)
;                       ..........
;                          .BREAK (L) (.BREAK_IF X1 OPR X2)
;                       ..........
;                       .ENDF
;*******************************************************
.FOR      macro   x1,x2
	  ifnb <x2>
	    mov   x1,x2
	  endif
          .genlbl  %(?LP*1000+?numbl)
	  .putsp   %?LP,?numbl
	  ?numbl = ?numbl+1
	  dec   x1
	  .defopr ?code,GE
	  ?type  = ?LP
	  endm

.ENDF      macro
	  .getsp   %?LP,?num
	  .getsp   %?LP,?num1
	  .deflen  ?len,%(?LP*1000+?num1)
          if ?len ge 127
	     .genjmp  %(?LP*1000+?num1)
	  else
	     .genbr   %(?LP*1000+?num1)
	  endif
	  .genlbl  %(?LP*1000+?num)
	  endm

;*******************************************************
;      Оператор цикла   .LOOP
;                          ..........
;                          .BREAK (L) (.BREAK_IF X1 OPR X2)
;                          ..........
;                       .ENDL
;*******************************************************

.LOOP   macro
        .DO
        endm

.ENDL   macro
        .ENDF
        endm

;**************************************************
;        Оператор выбора     .SWITCH  X (,B)
;                              .CASE  X1,X2 ... X5
;                              ........
;                              .CASE  X1,X2 ... X5
;                              .DEFAULT
;                            .ENDS
;**************************************************

.tsteqw   macro   x1,x2,x3,x4,x5
          .narg   ?num_const,<x1>,<x2>,<x3>,<x4>,<x5>
	  if ?num_const eq 0
	    exitm
	  endif
	  .IF ax E <x1>
	  if ?num_const eq 1
	     exitm
	  endif
	  .OR ax E  <x2>
	  if ?num_const eq 2
	     exitm
	  endif
	  .OR ax E  <x3>
	  if ?num_const eq 3
	     exitm
	  endif
	  .OR ax E  <x4>
	  if ?num_const eq 5
	     exitm
	  endif
	  .OR ax E  <x5>
	  endm

.tsteqb   macro   x1,x2,x3,x4,x5
          .narg   ?num_const,<x1>,<x2>,<x3>,<x4>,<x5>
	  if ?num_const eq 0
	    exitm
	  endif
	  .IF al E <x1>
	  if ?num_const eq 1
	     exitm
	  endif
	  .OR al E  <x2>
	  if ?num_const eq 2
	     exitm
	  endif
	  .OR al E  <x3>
	  if ?num_const eq 3
	     exitm
	  endif
	  .OR al E  <x4>
	  if ?num_const eq 5
	     exitm
	  endif
	  .OR al E  <x5>
	  endm


.SWITCH    macro   x1,x2
	   ifidn <x1>,<SB>
	     ?TypeArg = 0
	     ?CaseLen = 0
	   else
	   ifidn <x1>,<SW>
	     ?TypeArg = 1
             ?CaseLen = 0
	   else
	   ifidn <x1>,<LB>
	     ?TypeArg = 0
	     ?CaseLen = 1
	   else
	   ifidn <x1>,<LW>
	     ?TypeArg = 1
	     ?CaseLen = 1
	   else
	     .err  SPAL ERROR   bad .SWITCH type
	   endif
	   endif
	   endif
           endif
	   ifnb  <x2>
             if ?TypeArg eq 0
               ifdif  <x2>,<al>
               ifdif  <x2>,<AL>
                 mov  al,  x2
               endif
               endif
             else
	       ifdif <x2>,<ax>
	       ifdif <x2>,<AX>
	         mov  ax,  x2
	       endif
	       endif
             endif
           endif          
	   ?numcs = 0
	   .putsp  %?SW,?numcs
	   .putsp  %?SW,?TypeArg
	   .putsp  %?SW,?CaseLen
	   endm

.CASE     macro   x1,x2,x3,x4,x5
	  .getsp   %?SW,?CaseLen
	  .getsp   %?SW,?TypeArg
	  .getsp   %?SW,?numcs
	  if ?numcs ne 0
	    if ?CaseLen eq 0
	      .ELSE
	    else
	      .ELSE  L
	    endif
	  endif
	  if ?TypeArg  eq  0
	    .tsteqb  <x1>,<x2>,<x3>,<x4>,<x5>
	  else
	    .tsteqw  <x1>,<x2>,<x3>,<x4>,<x5>
	  endif
          if ?CaseLen eq 0
	    .BEGIN
	  else
	    .BEGIN  L
	  endif
	  ?numcs = ?numcs+1
	  .putsp   %?SW,?numcs
          .putsp  %?SW,?TypeArg
	  .putsp  %?SW,?CaseLen
	  endm


.DEFAULT  macro
	  .getsp   %?SW,?CaseLen
	  .getsp   %?SW,?TypeArg
	  .getsp   %?SW,?numcs
	  if ?numcs ne 0
	    if ?CaseLen eq 0
	      .ELSE
	    else
	      .ELSE   L
	    endif
	  endif
	  .putsp   %?SW,?numcs
          .putsp  %?SW,?TypeArg
	  .putsp  %?SW,?CaseLen
	  endm

.ENDS     macro
          .getsp   %?SW,?CaseLen
	  .getsp   %?SW,?TypeArg
	  .getsp   %?SW,?numcs
	  rept    ?numcs
	     .ENDI
	  endm
	  endm


;**********************************************************************
;          Оператор сохранения/восстановления в стеке
;               .PUSH   x1,x2,...,x10
;               ................................
;
;               .POP    x1,x2,...,x10
;**********************************************************************
.push_1 macro  par
	ifnb  <par>
	  push  par
	endif
	endm

.pop_1  macro  par
	ifnb  <par>
	  pop  par
	endif
	endm

.PUSH   macro   x1,x2,x3,x4,x5,x6,x7,x8,x9,x10
	.narg  ?num,<x1>,<x2>,<x3>,<x4>,<x5>,<x6>,<x7>,<x8>,<x9>,<x10>
	.push_1  <x1>
	.push_1  <x2>
	.push_1  <x3>
	.push_1  <x4>
	.push_1  <x5>
	.push_1  <x6>
	.push_1  <x7>
	.push_1  <x8>
	.push_1  <x9>
	.push_1  <x10>
	endm

.POP    macro  x1,x2,x3,x4,x5,x6,x7,x8,x9,x10
	.narg  ?num,<x1>,<x2>,<x3>,<x4>,<x5>,<x6>,<x7>,<x8>,<x9>,<x10>
	.pop_1   <x10>
	.pop_1   <x9>
	.pop_1   <x8>
	.pop_1   <x7>
	.pop_1   <x6>
	.pop_1   <x5>
	.pop_1   <x4>
	.pop_1   <x3>
	.pop_1   <x2>
	.pop_1   <x1>
	endm

;***********************************************************************
;            Оператор вызова процедур
;             .CALL  "имя", x1,x2,...,x10
;***********************************************************************
.CALL   macro  name, x1,x2,x3,x4,x5,x6,x7,x8,x9,x10
	.narg  ?NumPar, <x1>,<x2>,<x3>,<x4>,<x5>,<x6>,<x7>,<x8>,<x9>,<x10>
        ?SizeAreaSp = 0
	.push_1  <x10>
	.push_1  <x9>
	.push_1  <x8>
	.push_1  <x7>
	.push_1  <x6>
	.push_1  <x5>
	.push_1  <x4>
	.push_1  <x3>
	.push_1  <x2>
	.push_1  <x1>
	call  name
	add   sp,  ?NumPar*2
	endm


;**********************************************************************
;               Оператор входа в процедуру
;        .ENTER  "размер области локальных переменных"
;**********************************************************************
.ENTER      macro  loc_size
	    push   bp
	    mov    bp,  sp
	    ifnb  <loc_size>
	      sub   sp,  loc_size
	      .putsp   %?PR,1
	    else
              .putsp   %?PR,0
	    endif
	    endm


;**********************************************************************
;             Оператор выхода из процедуры
;                .LEAVE
;**********************************************************************
.LEAVE      macro  name
	    .getsp  %?PR, ?ls
	    if  ?ls eq  1
	      mov   sp,  bp
	    endif
	    pop   bp
	    endm


NULL   equ  0
FALSE  equ  0
TRUE   equ  1

          .SPAL

          .LIST
