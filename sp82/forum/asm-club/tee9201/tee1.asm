Comment ~
  From: Tom  Barrett
    To: Jim Hill				Date: 08 Jan 92  20:15:00
  Subj: redirecting output
  Conf: `Dr. Debug Conference'
*******************************************************************************
 > I'm wondering if there's any way I can have both "writes"
 > occur.

Yessir... just try and locate a tiny little program probably called "tee.com"
and insert it within a piped output like "DIR | tee >save.txt" ... our you can
write a quick one using DEBUG:
[see TEE.MSG for DEBUG script]

v1.1  Toad Hall Tweak
 - Rewrote to "standard" TASM/MASM assembly language format.
 - Tweaked to use all available memory (well, this segment anyway),
   other minor tightenings for minimum size, maximum performance.

David Kirschbaum
Toad Hall
kirsch@usasoc.soc.mil

~
CSEG	SEGMENT PUBLIC PARA 'CODE'
	ASSUME	CS:CSEG,DS:CSEG,ES:CSEG
CodeStart	equ	$

	ORG	100H

Tee	PROC	NEAR
;Free space should be 0FFFFH - our program code,
;plus leave a little for the stack.

	mov	si,offset CodeStart - offset buff- 80H	;free space	v1.1
	mov	di,offset buff	;handy constant (buffer offset)		v1.1

Tee_Lup:
	xor	bx,bx		;STDIN
	mov	cx,si		;amount to read				v1.1
	mov	dx,di		;buffer starts beyond program code	v1.1
	MOV	AH,3FH		;Read from file/device
	INT	21H
	jc	Exit		;read failed, error in AL
	mov	cx,ax		;bytes read into CX			v1.1
	jcxz	Exit		;0, we're done (AL=ERRORLEVEL=0)	v1.1

	push	cx		;save for second write later		v1.1
	inc	bx	;1	;STDOUT					v1.1
	mov	dx,di		;read buffer				v1.1
	MOV	AH,40H		;write to file/device
	INT	21H
;Let's put in a little error trapping here
;in case the STDOUT write device has a problem.

	jc	Exit		;Write error:  die (error in AL)	v1.1

;A "short read" (less than what we requested) is quite all right.
;Our next loop will return 0 bytes read, and we'll exit then.

	inc	bx	;2	;STDERR (console)			v1.1
	POP	CX		;# bytes to write (what we read)
	mov	dx,di		;read buffer				v1.1
	MOV	AH,40H		;write to file/device
	INT	21H
;Assuming write as ok for now (console writes usually are :-)

	JMP	Tee_Lup		;and loop until done

Exit:
	mov	ax,4CH		;terminate, errorlevel in AL
	int	21H

Tee	ENDP

buff	equ	$

CSEG	ENDS
	END	Tee
