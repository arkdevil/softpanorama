TAB EQU 09h
CR  EQU 0Dh
LF  EQU 0Ah

@DOS_PRINT_CHAR MACRO
    mov  ah, 2
    int  21h
ENDM

@DOS_PRINT_SIM MACRO Sim
    mov  ah, 2
    mov  dl, Sim
    int  21h
ENDM

@DOS_PRINT_STR MACRO   Str
  IFNB <Str>
    lea  dx, Str
  ENDIF
    mov  ah, 9
    int  21h
ENDM

@DOS_FREE_MEM MACRO   Segment
  IFNB <Segment>
    mov  es, Segment
  ENDIF
    mov  ah, 49H
    int  21h
ENDM

@DOS_GET_VECT	MACRO	Vect, Var
	mov	ax, 35H*256 + Vect
	int	21H
	IFNB	<Var>
	mov	Word Ptr Var, bx
	mov	Word Ptr Var + 2, es
	ENDIF
ENDM

@DOS_SET_VECT	MACRO	Vect, Var
	IFNB	<Var>
	lea	dx, Var
	ENDIF
	mov	ax, 25H*256 + Vect
	int	21H

ENDM
