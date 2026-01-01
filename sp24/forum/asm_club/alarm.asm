;------------------------------------------------------------------
;
;     Alarm  for PC AT compatible computer.
;     Uses CMOS memory to store alarm time.
;
;   (C) 1990 by Sia.   v. 1.6       31.03.90
;
;------------------------------------------------------------------


Del_time	equ	65535
Key		equ	'Al'

%delay	macro	time
	mov	cx,time
	call	delay
	endm
	
%sound	macro	divisor
	mov	bx,divisor
	call	sound
	endm

;------------------------------------------------------------------

code    segment	word
        assume  cs:code
        org     0100h

;---------------------------------

Start:
        jmp     Install

;------------------------------------------------------------------
;
;       Alarm Interrupt Handler
;
;------------------------------------------------------------------

Int4a:
	pushf
	push	ax
	cmp	ax,Key
	jnz	Co_1
	jmp	Maybe_chk

Co_1:
	push	bx
	push	cx
	push	dx

	in	al,061h
	push	ax

	sti
	mov   al,0b6h	;  timer mode register signal
	out   43h,al	;  output to timer control port

	%sound	784
	%delay	3
	%sound	659
	%delay	2
	%sound	523
	%delay	6
	%sound	659
	%delay	6
	%sound	784
	%delay	6
	%sound	1047
	%delay	15

	%sound	1329
	%delay	3
	%sound	1175  
	%delay	2
	%sound	1047
	%delay	6
	%sound	659
	%delay	6
	%sound	740
	%delay	6
	%sound	784
	%delay	15
	
	pop	ax	
	out	061h,al	;  send back the old val

	mov	ah,7
	int	01ah

	cli
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	jmp	dword ptr cs:int4asav
;------------

Maybe_chk:
	push	bp
	mov	bp,sp
	add	bp,10
	mov	ax,ss:[bp]
	and	ax,0200h
	pop	bp
	jz	Be_chk
	jmp	Co_1

Be_chk:
	pop	ax
	popf
	mov	ax,not Key
	iret

;---------------------------------------------

sound  proc  near
 
			; Step 2 -- send the divisor count to the timer
 
	mov	ax,34dch
	mov	dx,0012h
	div	bx

	out   42h,al	;  output low-order byte of divisor
	mov   al,ah	;  move high-order byte into ouput register
	out   42h,al	;  output hight-order byte of divisor
 
			; Step 3 -- turn on the two bits which activate the 
			; speaker, and the timer's control of the speaker
 
	in    al,61h	;  get the current bit settings for port 97
	or    al,03	;  turn on last two bits
	out   061h,al	;  send back the new value
 
	ret

 
sound	endp

;--------------------------------------

delay	proc	near

Lo_dd:
	push	cx
	mov	cx,Del_time
Lo_d:
	nop
	loop	Lo_d

	pop	cx
	loop	Lo_dd

 	ret
delay	endp

;--------------------------------------------


int4asav	label	dword
	dw      0
	dw      0

;------------------------------------------------------------------


Install:

	mov	ax,0f000h
	mov	es,ax
	cmp	byte ptr es:[0fffeh],0fch
	push	cs
	pop	es
	jz	AT_comp

	mov	dx,offset Non_AT_mess
	mov	ah,9
	int	021h
	jmp	Exit

Help:
	mov	dx,offset ok_mess
	mov	ah,9
	int	021h

	mov	dx,offset help_mess
	mov	ah,9
	int	021h
	jmp	Exit	

AT_comp:
	mov	si,080h
	mov	cl,byte ptr ds:[si]
	xor	ch,ch
	or	cx,cx
	jz	Nocomline

	inc	si
	call	Pass_bl
	call	Check_e
	jnc	Nocomline

	mov	al,byte ptr ds:[si]
	cmp	al,'?'
	jz	Help
	cmp	al,'/'
	jnz	_0
	inc	si
	mov	al,byte ptr ds:[si]
	cmp	al,'H'
	jz	Help
	cmp	al,'h'
	jz	Help

_0:
	call	Two_dig
	jnc	_1
	jmp	Err
_1:
	mov	byte ptr ds:Hour,bl

	call	Colon
	jnc	_2
	jmp	Err
_2:
	call	Two_dig
	jnc	_3
	jmp	Err
_3:
	mov	byte ptr ds:Minute,bl
	xor	al,al
	mov	byte ptr ds:Second,al

	call	Check_e
	jnc	Set

	call	Colon
	jnc	S_sec
	
	call	Pass_bl
	call	Check_e
	jnc	Set
	jmp	Err

S_sec:
	call	Two_dig
	jnc	_4
	jmp	Err
_4:
	mov	byte ptr ds:Second,bl
	call	Pass_bl
	call	Check_e
	jnc	Set
	jmp	Err	

Set:

	call	Set_alarm

	jc	_5
	jmp	Chk_inst
_5:
	mov	ah,9
	mov	dx,offset Err_c_mess
	int	021h
	
Nocomline:
;
;	Here we must get & display alarm time
;
	mov	al,1
	call	rdcmos
	mov	byte ptr ds:Second,al
	mov	al,3
	call	rdcmos
	mov	byte ptr ds:Minute,al
	mov	al,5
	call	rdcmos
	mov	byte ptr ds:Hour,al

Chk_inst:
	mov	ax,Key
	cli
	int	04ah
	sti
	cmp	ax,not Key
	jz	Was_inst

	cli
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[04ah*4]
	mov	word ptr [int4asav],ax
	mov	ax,es:[04ah*4+2]
	mov	word ptr [int4asav+2],ax
	mov	ax,offset cs:Int4a
	mov	es:[04ah*4],ax
	mov	es:[04ah*4+2],cs

	mov	ax,offset cs:Int23
	mov	es:[023h*4],ax
	mov	es:[023h*4+2],cs
	sti

	push	cs
	pop	es

	mov	dx,offset ok_mess
	mov	ah,9
	int	021h

	call	Set_alarm
	call	Display	

        mov     dx,(Install-Start)/010h+011h
        mov     ax,3100h
        int     021h


Err:
	mov	ah,9
	mov	dx,offset Err_mess
	int	021h
	jmp	Exit

Was_inst:
	call	Display
Exit:
	mov	ah,04ch
	int	021h


Int23:
	iret

;------------------------------------------------------------------

Colon	proc	near

	mov	al,byte ptr [si]
	cmp	al,':'
	jnz	Co_err
	inc	si
	clc
	ret
Co_err:
	stc
	ret

Colon	endp

;-----------------------

Pass_bl	proc	near

Pass:
	mov	al,byte ptr [si]
	inc	si
	cmp	al,' '
	jz	Pass
	
	dec	si
	ret

Pass_bl	endp

;-----------------------

Check_e	proc	near

	mov	al,byte ptr [si]
	cmp	al,0
	jz	E_str
	cmp	al,0dh
	jz	E_str
	stc
	ret
E_str:
	clc
	inc	si
	ret

Check_e	endp	

;-----------------------

Two_dig	proc	near

	mov	al,byte ptr [si]
	inc	si
	call	Is_num
	jc	T_err
	mov	bl,al

	mov	al,byte ptr [si]

	call	Is_num
	jc	T_ok

	inc	si
	xchg	bl,al
	mov	dl,10h
	mul	dl
	add	bl,al
T_ok:
	clc
	ret
T_err:
	stc
	ret

Two_dig	endp	

;-----------------------

Is_num	proc	near

	cmp	al,'9'
	jg	I_err

	cmp	al,'0'
	jl	I_err
	
	sub	al,'0'
	clc
	ret
I_err:
	stc
	ret

Is_num	endp	

;-----------------------

rdcmos	proc	near
	out	070h,al
	jmp	$+2
	in	al,071h
	ret
rdcmos	endp

;-----------------------

Display	proc	near

	mov	al,byte ptr ds:Hour
	mov	si,offset _set_
	call	BCD_set

	add	si,3
	mov	al,byte ptr ds:Minute
	call	BCD_set

	add	si,3
	mov	al,byte ptr ds:Second
	call	BCD_set

	mov	dx,offset al_mess
	mov	ah,9
	int	021h
	ret
	
Display	endp

;-----------------------

BCD_set	proc	near
	mov	ah,al
	and	ax,00ff0h
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	add	ax,'00'
	mov	word ptr ds:[si],ax
	ret
BCD_set	endp
;-----------------------

Set_alarm	proc	near

	mov	ah,7
	int	01ah

	mov	ah,6
	mov	ch,byte ptr ds:Hour
	mov	cl,byte ptr ds:Minute
	mov	dh,byte ptr ds:Second
	int	1ah
	ret
	
Set_alarm	endp

;------------------------------------------------------------------

Hour	db	0
Minute	db	0
Second	db	0

Err_mess	db	0dh,0ah,'Invalid time',0dh,0ah,'$'
Err_c_mess	db	0dh,0ah,'CMOS Error',0dh,0ah,'$'
Non_AT_mess	db	0dh,0ah,'This program is for AT-COMPATIBLE computer only.',0dh,0ah

ok_mess         db      0dh,0ah,'     ╔═══════════════════════════════════════════╗'
                db      0dh,0ah,'     ║    Alarm for PC AT compatible computer.   ║'
                db      0dh,0ah,'     ║ (C) 1990 by Sia. v.1.6. For Help Alarm /h ║'
                db      0dh,0ah,'     ╚═══════════════════════════════════════════╝'
                db      0dh,0ah,0ah,0ah,'$'

help_mess	db	0dh,0ah,'      Usage :'
		db	0dh,0ah,'               Alarm {[/Help] | HH:MM[:SS] }'
		db	0dh,0ah
		db	    0ah,'               Since alarm time is stored in CMOS memory'
		db	0dh,0ah,'               it never lost after reset, power-off, etc.'
		db	0dh,0ah,0ah,'$'

al_mess		db	0dh,0ah,'Alarm time is '
_set_		db	'00:00:00',0dh,0ah,'$'
copyr	db	0dh,0ah,'(C) 1990 by Sia.',0dh,0ah

Code    ends

        end     Start

