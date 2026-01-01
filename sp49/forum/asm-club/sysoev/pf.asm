;;
;;	PF.ASM	- Протокол файлов
;;	  V 1.01	09-15-92 02:08pm
;;
;;  Автор - Сысоев В.
;;
;;  Транслятор - TASM 2.5
;;
;;
		%TITLE   "V 1.01  (c) "

SIZE_STACK      EQU     21
SIZE_NAME       EQU     40

		.MODEL	TINY
         	.CODE
		IDEAL
                org     100H
Start:          jmp     Instal
top_stack       dw      SIZE_STACK dup ('ts')
old_ss          dw      ?
old_sp          dw      ?
mdx		dw	?
mds		dw	?
mcx		dw	?

device_out      dw      2
fl_activ        db      0
CR_LF           db      13,10,0
name_fpr        db      'd:\`pf.txt', 0
                db      SIZE_NAME dup(?)

mode_work       dw      ?
modes		db      3dh, 3ch, 41h, 4bh
LEN_MODES	=	$-modes
mess_open	db	' -- OPEN FILE', 0
mess_create	db	' -- CREATE FILE', 0
mess_delete	db	' -- DELETE FILE', 0
mess_run	db	' -- RUN',0
mess_overlay	db 	' -- LOAD OVERLAY',0
buf_dat		db	'    -  -    ',0
buf_time	db	' AT   :  :  ',0


PROC	Show_Error
                mov     ah, 0fH
                int     10H
                cmp     al, 7
                jne     @@mod1
                mov     [cs:color], 112
                jmp     short save_scr
@@mod1:
                cmp     al, 4
                jb      save_scr
                jmp     quit_show_err
save_scr:
                mov     ah, 03H
                int     10H
                mov     [cs:mem_curs], dx
                cld
                push    cs cs
                pop     es ds

                xor     di, di
                mov     cx, HEIGHT_BOX
loop_save_win:
                push    cx

                mov     dx, HEIGHT_BOX
                sub     dx, cx
                mov     ax, 100H
                mul     dx
                mov     dx, [cs:where_xy]
                add     dx, ax

                mov     ah, 02H
                int     10H
                mov     cx, LEN_ITEM
loop_save_str:
                mov     ah, 08H
                int     10H
                stosw
                inc     dx
                mov     ah, 02H
                int     10H
                loop    loop_save_str

                pop     cx
                loop    loop_save_win

; ---   out_window:
                mov     si, OFFSET error
                mov     cx, HEIGHT_BOX
                mov     bl, [cs:color]
loop_out_win:
                push    cx

                mov     dx, HEIGHT_BOX
                sub     dx, cx
                mov     ax, 100H
                mul     dx
                mov     dx, [cs:where_xy]
                add     dx, ax

                mov     ah, 02H
                int     10H
                mov     cx, LEN_ITEM
loop_out_str:
                lodsb
                push    cx
                mov     cx, 1
                mov     ah, 09H
                int     10H

                inc     dx
                mov     ah, 02H
                int     10H
                pop     cx
                loop    loop_out_str

                pop     cx
                loop    loop_out_win

; -------       Ожидание клавиши
                mov     ah, 08H
		int     21H

; ---   restore_window:
                xor     si, si
                mov     dx, 1019H
                mov     cx, HEIGHT_BOX
loop_restore_win:
		push    cx

                mov     dx, HEIGHT_BOX
                sub     dx, cx
                mov     ax, 100H
                mul     dx
                mov     dx, [cs:where_xy]
                add     dx, ax

                mov     ah, 02H
                int     10H
                mov     cx, LEN_ITEM
loop_restore_str:
                lodsw
                mov     bl, ah
                push    cx
                mov     cx, 1
                mov     ah, 09H
                int     10H

                inc     dx
                mov     ah, 02H
                int     10H
                pop     cx
                loop    loop_restore_str

                pop     cx
                loop    loop_restore_win

                mov     dx, [cs:mem_curs]
                mov     ah, 02H
                int     10H
quit_show_err:
                ret

color           db      79
where_xy        dw      0612H
mem_curs        dw      ?
error           db      '╔═ File`s protocol: ════════════╗'
LEN_ITEM        =	$-error
                db      '║ ERROR of output the protocol !║'
                db      '╚═ press any key to continue.═══╝'
HEIGHT_BOX	=	3
ENDP    Show_Error


PROC    Put_Str

                cld
                mov     al, 0
                mov     di, dx
                push    ds
                pop     es
                mov     cx, 180
                repne   scasb
                mov     cx, di
                sub     cx, dx
		dec	cx

                mov     ah, 40H
                mov     bx, [cs:device_out]
		int     21H
                ret
ENDP	Put_Str

PROC	DecToStr

	push	bx dx
 	 mov	 bx, 10

@@ConvertLoop:

	 sub	 dx, dx
	 div	 bx

	 add	 dl, '0'
	 mov	 [si], dl
	 dec	 si

	 loop	 @@ConvertLoop

	 inc	 si

	pop	dx bx
	ret
ENDP	DecToStr
;
;-------------------------------------------------

PROC    New_int21       FAR
                cmp     [cs:fl_activ], 0
                jne     Old_int21

                mov     [cs:mode_work], ax
		mov	al, ah
		push	es di cx cs
		pop	es
		mov	cx, LEN_MODES
		mov	di, OFFSET modes
		cld
		repne	scasb
		pop	cx di es
		jz	ac_work

		mov     ax, [cs:mode_work]

                cmp     ax, 5449H
                je      ac_check
                cmp     ax, 0556H
                je      ac_uninstal
Rest_Old21:
		mov	ax, [cs:mode_work]
Old_int21:      db      0eaH
oiv21           dw      0,0

ac_work:
                sti
		pushf
		push	bx es di si bp
		mov	[cs:mds], ds
		mov	[cs:mdx], dx
		mov	[cs:mcx], cx
                call    Pr_Work
		pop	bp si di es bx
		popf
		mov	ds, [cs:mds]
		mov	dx, [cs:mdx]
		mov	cx, [cs:mcx]
                jmp     Rest_Old21

ac_check:
                sti
                mov     ax, 5443H
                iret

ac_uninstal:
                sti
                inc     [cs:fl_activ]
                call    Pr_Uninstal
                pushf
                pop     ax
                and     ax, 1
                iret

ENDP    New_int21


PROC    Pr_Work

                inc     [cs:fl_activ]

                mov     [cs:old_ss], ss
                mov     [cs:old_sp], sp
                mov     ax,cs
                cli
                mov     ss, ax
                mov	sp, OFFSET top_stack
                sti


                mov     ax, 3524H
                pushf
                call    [DWORD cs:oiv21]
                mov     [cs:oiv24], bx
                mov     [cs:oiv24+2], es

                mov	dx, OFFSET New_int24
                mov     bx, cs
                mov     ds, bx
                mov     ax, 2524H
                pushf
                call    [DWORD cs:oiv21]



                cmp     [cs:device_out], 4
                je      at_prn
                mov     ax, cs
                mov     ds, ax
                mov	dx, OFFSET name_fpr
                mov     ah, 3dH
                mov     al, 1H
                pushf
                call    [DWORD cs:oiv21]
                jnc     @@cont

                mov     ah, 3cH
                mov     dx, OFFSET name_fpr
                mov     cl, 0
                xor     ch, ch
                pushf
                call    [DWORD cs:oiv21]
                jnc     @@cont
                jmp     Error
@@cont:
                mov     [cs:device_out], ax

                mov     bx, ax
                mov     ah, 42H
                mov     al, 2
                xor     cx, cx
                xor     dx, dx
		int     21H

                jnc	at_prn
		jmp	Error
at_prn:

		lds	dx, [DWORD cs:mdx]
               	call    Put_Str

		push	cs
		pop	ds
@@case_open:
		cmp	[BYTE cs:mode_work+1], 3dh
		jne	@@case_create
		mov	dx, OFFSET mess_open
		jmp	short @@end_case
@@case_create:
		cmp	[BYTE cs:mode_work+1], 3ch
		jne	@@case_delete
		mov	dx, OFFSET mess_create
		jmp	short @@end_case
@@case_delete:
		cmp	[BYTE cs:mode_work+1], 41h
		jne	@@case_run
		mov	dx, OFFSET mess_delete
		jmp	short @@end_case
@@case_run:
		cmp	[cs:mode_work], 4b00h
		jne	@@case_overl
		mov	dx, OFFSET mess_run
		jmp	short @@end_case
@@case_overl:
		cmp	[cs:mode_work], 4b03h
		jne	@@end_case
		mov	dx, OFFSET mess_overlay
@@end_case:
               	call    Put_Str

		mov	ah, 2ch
		int	21h
		mov	[WORD cs:buf_dat+2], cx
		mov	al, dh
		xor	ah, ah
		mov	si, OFFSET buf_time+11
		mov	cx,2
		call	DecToStr

		dec	si
		dec	si

		mov	al, [cs:buf_dat+2]
		xor	ah, ah
		mov	cx, 2
		call	DecToStr

		dec	si
		dec	si

		mov	al, [cs:buf_dat+3]
		xor	ah, ah
		mov	cx, 2
		call	DecToStr

		dec	si
		dec	si

		mov	dx, OFFSET buf_time
		call    Put_Str

		mov	ah, 2ah
		int	21h
		mov	ax, cx
		mov	si, OFFSET buf_dat+11
		mov	cx, 4
		call	DecToStr

		dec	si
		dec	si

		mov	al, dl
		xor	ah, ah
		mov	cx, 2
		call	DecToStr

		dec	si
		dec	si

		mov	al, dh
		xor	ah, ah
		mov	cx, 2
		call	DecToStr

		mov	dx, OFFSET buf_dat
		call    Put_Str


                mov     dx, OFFSET CR_LF
                call    Put_Str


                cmp     [cs:device_out], 4
                je      quit_pr
                mov     bx, [cs:device_out]
                mov     ah, 3eH
                int     21H
                jnc     quit_pr
Error:
          	call    Show_Error

quit_pr:

                mov     dx, [cs:oiv24]
                mov     ds, [cs:oiv24+2]
                mov     al, 24H
                mov     ah, 25H
                int     21H


                mov     ax, [cs:old_ss]
                cli
                mov     ss, ax
                mov     sp, [cs:old_sp]
                sti

                dec     [cs:fl_activ]

                ret

ENDP    Pr_Work

PROC    New_int24       FAR
                add     sp, 24

                mov     bx, sp
                or      [WORD ss:bx+4], 1
                iret

                db      0eah
oiv24           dw      0,0
ENDP    New_int24

PROC    Pr_Uninstal
                mov     AL,21H
                mov     AH,35H
                Int     21H
                cmp     bx, OFFSET cs:New_int21
                jne     not_unins
                mov     bx, cs
                mov     dx, es
                cmp     dx, bx
                jne     not_unins

                push    ds
                mov     dx, [cs:oiv21]
                mov     ds, [cs:oiv21 + 2]
                mov     al, 21H
                mov     ah, 25H
                pushf
                call    [DWORD cs:oiv21]
                pop     ds

                push    bx es
                mov     ah, 49H
                mov     bx, cs
                mov     es, bx
                pushf
                call    [DWORD cs:oiv21]
                pop     es bx
                jnc     @@quit
not_unins:
                stc
@@quit:
                ret
ENDP    Pr_Uninstal


;----------------------------------------------------------

Instal:
                mov     ah, 9
                mov     dx, OFFSET CopyRight
                int     21H

                mov     bx, 80H
                test    [BYTE bx], -1
                jnz     com_line
                jmp     ex_loop
com_line:
                cld
                mov     di, 81H
                mov     cl, [bx]

beg_loop:
                mov	al, [BYTE di]
		push	di
		mov	cx, LEN_SEPAR
		mov	di, OFFSET separ
		repne	scasb
		pop	di
		jnz	@@n0
                inc     di
                jmp     short beg_loop

@@n0:
                cmp     [BYTE di], 13
                je      ex_loop

                cmp     [BYTE di], '>'
                jne     @@cont1
                mov     al, ' '
                mov     cx, 10H
                repne   scasb
                jmp     short beg_loop

@@cont1:
                and     [BYTE di], 0dfH

                cmp     [BYTE di], 'N'
                jne     @@n1
                inc     di
                inc     [fl_new]
                jmp     short beg_loop
@@n1:
                cmp     [BYTE di], '?'
                jne     @@n2
                jmp     Help
@@n2:
                cmp     [BYTE di], 'U'
                jne     @@n4
                jmp     Run_Uninst
@@n4:
                cmp     [BYTE di], 'F'
                je      @@n5
                jmp     Help
@@n5:
                inc     [no_outdef]
                inc     di
                call    Make_namef
                or      al, al
                jz      beg_loop
                jmp     Help


ex_loop:
                cmp     [fl_new], 0
                jne     create
                mov     dx, OFFSET name_fpr
                mov     ah, 3dH
                mov     al, 1H
                int     21H
                jnc     close
create:
                mov     ah, 3cH
                mov     dx, OFFSET name_fpr
                mov     cl, 0
                xor     ch, ch
                int     21H
                jc      Err_file
close:
                mov     bx,ax
                mov     ah, 3eH
                int     21H
                jc      Err_file


rezid:
                mov     ax, 5449H
                int     21H
                cmp     ax, 5443H
                je      already

                cmp     [no_outdef], 0
                jne     @@c
                mov     ah, 9
                mov     dx, OFFSET default
                int     21H
@@c:
                mov     AX,3521H
                Int     21H
                mov     [oiv21], bx
                mov     bx, es
                mov     [oiv21 + 2], bx

                push    ds
                mov     dx, OFFSET New_int21
                mov     bx, cs
                mov     ds, bx
                mov     ax, 2521H
                Int     21H
                pop     ds

		mov	es, [cs:2Ch]
		mov	ah, 49h
		int	21h

                mov     dx, OFFSET Instal
                Int     27H
Err_file:
                mov     ah, 09H
                mov     dx, OFFSET d_err
                int     21H
                jmp     short quit_ins
Run_Uninst:
                mov     ax, 0556H
                int     21H
                or      ax, ax
                jnz     deact
                mov     ah, 09H
                mov     dx, OFFSET ok_uninst
                int     21H
                jmp     short quit_ins
deact:          mov     ah, 09H
                mov     dx, OFFSET ok_deactive
                int     21H
                jmp     short quit_ins
already:
                mov     ah, 09H
                mov     dx, OFFSET alr_ins
                int     21H
                jmp     short quit_ins
Help:
                mov     ah, 9
                mov     dx, OFFSET help_str
                int     21H
quit_ins:
                mov     ax, 4c00H
                int     21H

fl_new          db      0
separ		db	' /-'
LEN_SEPAR	=	$-separ

no_outdef       db      0
CopyRight       db      'File`s protocol V1.01 (c) 1992 '
                db      'Writed by Sysoev Victor.',13,10,'$'
default         db      13,10,'    Protocol in file  d:\`pf.txt',13,10,'$'
help_str        db      13,10,'For run :',13,10
                db      '    pf [switch]',13,10
                db      'where  switch:',13,10
                db      '       n          - create new protocol',13,10
                db      '       fpathname  - full pathname for protocol',13,10
                db      '                     ( fdisk:\path\name_file ',13,10
                db      '                          or',13,10
                db      '                       fprn  - to printer )',13,10
                db      '       u          - uninstall resident protocol',13,10
                db      '       ?          - output this help.',13,10,'$'
ok_uninst       db      13,10,'   Protocol uninstalled.',13,10,13,10,'$'
ok_deactive     db      13,10,'   Protocol deactived.',13,10,13,10,'$'
alr_ins         db      13,10,'   Protocol already installed.',13,10,13,10,'$'
d_err           db      'Error open of protocol !!!',13,10,7,13,10,'$'


PROC    Make_namef
                mov     bx, OFFSET name_fpr
                xor     cx, cx
@@beg_loop:
                cmp     [BYTE di], 13
                je      @@ex_loop
                cmp     [BYTE di], ' '
                je      @@ex_loop
                mov     al, [BYTE di]
                call    To_Upper
                mov     [BYTE bx], al
                inc     bx
                inc     di
                inc     cx
                jmp     @@beg_loop
@@ex_loop:
                mov     [BYTE bx], 0
                push    di
                xor     al, al
                cld
                mov     si, OFFSET s_prn
                mov     di, OFFSET name_fpr
                repe    cmpsb
                jcxz    @@isprn
                cmp     [name_fpr+1], ':'
                je      short @@cont
                inc     al
                jmp     short @@cont
@@isprn:
                mov     [device_out], 4
@@cont:
                pop     di
                ret
s_prn           db      'PRN',0
ENDP    Make_namef

PROC    To_Upper
                cmp     al, 61H
                jb      @@quit_u
                cmp     al, 7aH
                ja      @@quit_u
                and     al, 0dfH
@@quit_u:
                ret
ENDP    To_Upper

                END Start