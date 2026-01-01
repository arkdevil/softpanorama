COMMENT %
		Name	MASM6test
	;****************************************************************
	;
	; Hello, world!
	; Please send this information (may be obsolete?) to
	;
	;				  Microsoft Corporation
	;				  Dept.125
	;				  16011 NE 36th Way
	;				  Box 97017
	;				  Redmond, WA 98073-9902
	;				  U.S.A.
	;				  E-mail: ?????
	;
	;             Microsoft MASM V6.0 bugs.
	;             =========================
	;
	; In some case MASM V6.0 produce wrong code (see examples
	; below). This module was tested with MASM V5.1, TASM V2.0,
	; QuickAssembler (QuickC V2.01), and they are OK.
	;
	; Question: are this a real bugs or my MASM is corrupted?
	;
	; If this is a real bugs, it is very dangerously to use
	; this MASM version.
	;			Yours truly
	;			Victor P. Kuznetsov
	;
	;		249020  Engels st.,7-12
	;			Obninsk Kaluga region, Russia
	;			Tel. (084-39)2-80-20
	;
	;****************************************************************
 0000			code	SEGMENT 'CODE'
				ASSUME	CS:code,DS:code
		;========================================================
		; 1st bug				10.07.1992
		;========================================================
 0000 54 65 73 74 20 73		String	DB	'Test string length equ 1Ah'
       74 72 69 6E 67 20
       6C 65 6E 67 74 68
       20 65 71 75 20 31
       41 68
 001A = 001A			S_Len	EQU $-String
		;--------------------------------------------------------
 001A  C6 06 001A 13		mov	BYTE PTR DS:[S_Len],13h		;OK

		; In 2 statements below MASM V6.0 produced wrong code,
		; if second operand is a constant

 001F  C6 44 1A 00		mov	BYTE PTR [SI+S_Len],13h		;where 13h?
 0023  80 60 1A 00		and	BYTE PTR [SI+BX+S_Len],13h	;where 13h???

		;========================================================
		; 2nd bug				02.08.1992
		;========================================================
 0027 0000		Lab1	DW	0

		; Code1_Size equ 8, but 2nd statement below use 0Eh ???

 0029  B9 0008			mov	CX,Code1_Size			; OK
 002C  C7 06 0027 R 000E	mov	WORD PTR Lab1,Code1_Size	; wrong code???
 0032  C7 06 0027 R 0008	mov	WORD PTR Lab1,8			; must be so

		; in next statement bug #1 is main:

 0038  C7 47 1A 0000		mov	WORD PTR [BX+S_Len],Code1_Size	; wrong ???
		;
 003D			Code1:
 003D  B8 0000			mov	AX,0
 0040  7F 03			jg	Code1_end	;!!! OK without this string
 0042  B8 0001				mov	AX,1
 0045			Code1_end:
			;
 = 0008			Code1_Size	EQU Code1_end-Code1

		;========================================================
		; 3d bug				28.08.1992
		;========================================================
 0045			NewSAVE_PTR	label word
 0045  0014 [			DW	20 DUP (0)
        0000
       ]

 006D			TEXT_Info	LABEL BYTE

 006D = 0028		C_SHIFT	equ	$-NewSAVE_PTR
		;+
		; Const2 in listing equ Const1, but in symbol table
		; Const2 < 0 ???
		;-
 = 0045			Const1	=	TEXT_Info-C_SHIFT
 = 0045			Const2	=	(OFFSET TEXT_Info)-C_SHIFT

 006D  0045 R		DW	Const1				;it's OK
 006F  0000		DW	Const2				;why 0 ???
 0071  0045 R		DW	TEXT_Info-C_SHIFT		;it's OK
 0073  0000		DW	(offset TEXT_Info)-C_SHIFT	;why 0 ???
		;========================================================
 0075			code	ENDS
				END
Microsoft (R) Macro Assembler Version 6.00     	 08/30/92 00:05:39
a.asm							     Symbols 2 - 1

Segments and Groups:

                N a m e                 Size     Length   Align   Combine Class

code . . . . . . . . . . . . . .	16 Bit	 0075	  Para	  Private 'CODE'	


Symbols:

                N a m e                 Type     Value    Attr

C_SHIFT  . . . . . . . . . . . .	Number	 0028h	 
Code1_Size . . . . . . . . . . .	Number	 0008h	 
Code1_end  . . . . . . . . . . .	L Near	 0045	  code	
Code1  . . . . . . . . . . . . .	L Near	 003D	  code	
Const1 . . . . . . . . . . . . .	Number	 0045h	 
Const2 . . . . . . . . . . . . .	Number	 FFFFFF6Bh   		???????
Lab1 . . . . . . . . . . . . . .	Word	 0027	  code	
NewSAVE_PTR  . . . . . . . . . .	Word	 0045	  code	
S_Len  . . . . . . . . . . . . .	Number	 001Ah	 
String . . . . . . . . . . . . .	Byte	 0000	  code	
TEXT_Info  . . . . . . . . . . .	Byte	 006D	  code	

	   0 Warnings
	   0 Errors

	Appendix: Source code to assemble
		  =======================
%
	Name	MASM6test
;********************************************************
code	SEGMENT 'CODE'
	ASSUME	CS:code,DS:code
;========================================================
; 1st bug				10.07.1992
;========================================================
String	DB	'Test string length equ 1Ah'
	S_Len	EQU $-String
;--------------------------------------------------------
	mov	BYTE PTR DS:[S_Len],13h		;OK

; In 2 statements below MASM V6.0 produced wrong code,
; if second operand is a constant

	mov	BYTE PTR [SI+S_Len],13h		;where 13h?
	and	BYTE PTR [SI+BX+S_Len],13h	;where 13h???

;========================================================
; 2nd bug				02.08.1992
;========================================================
Lab1	DW	0

; Code1_Size equ 8, but 2nd statement below use 0Eh ???

	mov	CX,Code1_Size			; OK
	mov	WORD PTR Lab1,Code1_Size	; wrong code???
	mov	WORD PTR Lab1,8			; must be so

; in next statement bug #1 is main:

	mov	WORD PTR [BX+S_Len],Code1_Size	; wrong ???
;
Code1:
	mov	AX,0
	jg	Code1_end	;!!! OK without this string
		mov	AX,1
Code1_end:
;
Code1_Size	EQU Code1_end-Code1

;========================================================
; 3d bug				28.08.1992
;========================================================
NewSAVE_PTR	label word
	DW	20 DUP (0)

TEXT_Info	LABEL BYTE

C_SHIFT	equ	$-NewSAVE_PTR
;+
; Const2 in listing equ Const1, but in symbol table
; Const2 < 0 ???
;-
Const1	=	TEXT_Info-C_SHIFT
Const2	=	(OFFSET TEXT_Info)-C_SHIFT

	DW	Const1				;it's OK
	DW	Const2				;why 0 ???
	DW	TEXT_Info-C_SHIFT		;it's OK
	DW	(offset TEXT_Info)-C_SHIFT	;why 0 ???
;========================================================
code	ENDS
	END


COMMENT	%
$storage:2
	Integer function	F510test (IER)
C********************************************************
C	Microsoft FORTRAN V5.10 bug		1.1992
C	===========================
C	When compiling this module
C		>fl /c f.for
C	you have the warning message F4063:
C		"FUNCTION TOO LARGE FOR POST-OPTIMIZER",
C	and created object file size is > 160000 bytes.
C	If command line is
C		>fl /c /Od f.for
C	there are no messages, but object file is too
C	large.
C	All right if:
C		- you comment 1st string (i.e.
C		 $storage=4 and don't use option /4I2);
C		- comment 1 or more of CASE;
C		- remove ":" from case (:0) or insert
C		  constant (-1:0);
C
C	May be code generator (get & see ASM listing >500 Kb)
C	generate too long table for JMP (32K entries)
C	in some case ?
C
C			Victor P. Kuznetsov
C		249020  Engels st.,7-12
C			Obninsk Kaluga region, Russia
C			Tel. (084-39)2-80-20 
C
C	P.S.	Sorry, but I'm not a registered MS-user.
C********************************************************
	select case	(IER)
		case	(:0)		!OK if remove ":"
			goto	999
		case	(1)
			goto	999
		case	(2)
			goto	999
		case	(3)
			goto	999
	end select
C
999	F510test	= 0
	return
C>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	END
%
