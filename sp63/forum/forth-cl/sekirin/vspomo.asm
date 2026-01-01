; Larionovsk.Forth - opr.f-tsij na yaz.assemb.
; Ispolhz.: tasm imya / tlink/t imya / ren imya.com imya.frl .
; V prog.: use <imya>.frl, zatyem obr.po imyenam k f-tsiyam.
; zdyesh k imyenam f-tsij nado dopis. '_': imya -> imya_ i _imya.
; ispravl.osh.v f-tsiyakh >,<,EXPECT; dobavl.f-tsiya DELAY.
; --------------
	include	forthasm.inc
; -----------------
; ispravl. > i < : v orig. (20000>-20000)=false;
; logika: analiz.znak raznosti; 20000-(-20000)=40000 - vospr.kak <0.
; u Cherezova vychit.osushch.v kodakh i analiz.flagi. Dyel.zdyesh to zhe.
gt_: db 1,'>',0
  dw 0
  _gt:
	pop	cx
	pop	ax
	sub	ax,cx
	jle	false
	jmp	short true
false:	xor	ax,ax
	jmp	short ende
true:	mov	ax,0FFFFh
ende:
 push ax
 next ;	jmp	word ptr ds:[105h]
; -------
lt_: db 1,'<',0
  dj gt_
  _lt:
	pop	cx
	pop	ax
	sub	ax,cx
	jge	false
	jmp	short true
; next nye tryeb.
; ------------------
; Ispravl.slovo EXPECT iz larionovsk.forta.
; v orig.: 0Ah naravnye s 0Dh vospr.kak prizn.kontsa stroki.
; vv.s klav. -> tk.0Dh, no v fajlye - 0Dh,0Ah; eto -> fiktivn.pust.stroki.
; U Cherezova 0Ah ignor. Dyel.zdyesh to zhe.
; -------------------------
expect_: db 6,'EXPECT',0
 dj lt_
 _expect:
	pop    cx	; maks.dlina
        pop    bx	; adr.nachala bufyera
	push   bp
	push   si
        xor    di,di
snova: ; nado chitath ocheredn.simvol.
        push   bx
        push   cx
        push   di
        mov    dx,01D3h
        call   dx	; vv.simv.byez otobrazh.(int 21h,f-n 8)
        pop    di
	pop    cx
        pop    bx
        cmp    al,0Ah
        je     snova
        cmp    al,0Dh
        je     endfound
        cmp    al,08h ; BACKSPACE
        jne    lAF9
        cmp    di,00h
        je     lB06
        dec    bx
        dec    di
        push   bx
        push   di
        push   cx
        mov    dx,01C8h
        push   dx
        call   dx ; vyv.simv. (int 21h, f-n 2).
        pop    dx
        mov    al,20h
        call   dx
        mov    al,08h
lAEF: ; cref: B04 B0B
        mov    dx,01C8h
        call   dx ; vyv.simv. (int 21h, f-n 2).
        pop    cx
        pop    di
        pop    bx
        jmp    snova
lAF9: ; cref: AD6
        cmp    cx,di
        je     lB06
        mov    byte ptr ds:[bx],al
        inc    bx
        inc    di
        push   bx
        push   di
        push   cx
        jmp    lAEF
lB06: ; cref: ADB AFB - pyeryepoln.buf.ili pust.buf.+BACKSPACE.
        push   bx
        push   di
        push   cx
        mov    al,07h
        jmp    lAEF
endfound: ; vvyedyeno 0Dh.
        pop    si
        pop    bp
        mov    word ptr ds:[011Bh],di	; zanyes.dliny v SPAN
;        jmp    word ptr ds:[0105h]	; konyets rab.
        next
; -----------------------------------
; Dizass.proc-ra DELAY v borlandovsk.paskalye (vyers.5.5).
delay_: db	5,'DELAY',0
 dj expect_
_delay:
; v stekye - paramyetr - dlit-sth v msec.
	pop	dx		; dlit-sth v msec.
	or	dx,dx
	jz	loc_3_2BB
;	push	ax			; sokhr.ryeg.
;	push	bx
;	push	cx
;	push	dx
	push	di
	push	es
	push	bp
	db	0E8h,00h,00h
point:	pop	bp
	add	bp,offset(zago)-offset(point)
; tyepyerh dolzhno byth cs:[bp]=zago.
	xor	di,di
	mov	es,di	; -> es:[di]=0:[0] - nach.tabl.vyekt.pryer.
	mov	al,es:[di]
	mov	bx,word ptr cs:[bp]	; zagotovka,obyesp.1 msec.
loc_3_2B3:
	mov	cx,bx
	call	sub_3_2BE
	dec	dx
	jnz	loc_3_2B3
	pop	bp
	pop	es			; vosst.ryeg.
	pop	di
;	pop	dx
;	pop	cx
;	pop	bx
;	pop	ax
loc_3_2BB:
          next
; ---------------------------------------
; Subroutine msec	
; yesli v cx - nuzhn.chislo, vydyerzh.1 msec.
; dlya nakh.etogo chisla ust.es:[di] na mladsh.bajt timer tick counter'a,
; v cx zanos.FFFFh i vyz.etu prog.; ochev.,nuzhn.chislo=(FFFFh-nov.cx)/55;
; faktich.byeryotsa -nov.cx/55.
sub_3_2BE	proc  near
	cmp	al,es:[di] ; v normye (0:[0] nye izm.) -> ravny.
	jnz	loc_3_2C5
	loop	sub_3_2BE ; cx umyenhsh.na 1.
loc_3_2C5: ; CREF: 3003:02C1
	ret
	endp	sub_3_2BE
;--------------------------------------------------
initdelay_:     db              9,'INITDELAY',0
                dj              delay_
_initdelay:			; dolzhna vypolnitsa pri zagruzkye.
	push	di
	push	es
	push	bp
	db	0E8h,02h,00h
zago	dw	01111h
	pop	bp		; cs:[bp]=zago
;	db	0FBh,0EBh,0FEh
; v podpr.initsializatsii - sozd.zagotovki dlya 1 msec.
        mov     ax,040h
	mov	es,ax
        mov     di,06Ch
; t.o.,es:[di]=40:[6C] - mladsh.iz 4 bajt timer tick counter'a.
	mov	al,es:[di]
loc_3_71:
	cmp	al,es:[di]
	jz	loc_3_71
; dozhdalish izmyenyeniya timer tick counter'a.
	mov	al,es:[di]
	mov	cx,0FFFFh
	call	sub_3_2BE
; eta podpr.umyenhsh.cx do cx=0 ili al<>es:[di];
; v dann.sluch.ozhid.,chto es:[di] izmyenitsa ranhshe;
; togda obr.k etoj podpr.s cx=(FFFF-nov.cx)/55 pri al==es:[di] obyesp.1 msec.
        mov     ax,037h	; =55 (1 timer tick=55 msec)
	xchg	ax,cx
	neg	ax
; vmyesto FFFF-cx byerut -cx; nyeyasno, chem luchshe.
	xor	dx,dx
	div	cx
	mov	word ptr cs:[bp],ax
;	db	0DBh,0FEh
; zapomnili zagotovku dlya podpr.,obyesp.1 msec.
	pop	bp
	pop	es
	pop	di
        next
; ---------------------------------------
; dalxshe - "zagolovok".
; Po nyemu translqtor dyel.vyv., chto podkl.fajl - dyejstvit-no fort-modulh.
                dw              100h
                dw              (offset initdelay_)-100h
                db              92,9
                dw              1231h
                end             module
