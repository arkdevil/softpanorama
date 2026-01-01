_TEXT           segment byte public 'CODE'
                assume  cs:_TEXT

                public  _int11h
_int11h         proc    near
                int     11h
		ret
_int11h         endp

.8087
                public  _rdwr87
_rdwr87         proc    near
                push    bp
                mov     bp,sp
		sub	sp,18	; reserve stack
                push    ds
                push    es
                push    si
                push    di

                xor     bx,bx

                push    ss
                pop     es
                lea     di,ss:[bp-18]
                push    ss
                pop     ds

                lea     si,ss:[bp-18]
                mov     cx,8
locloop_233:
                fld     qword ptr cs:data_0
                loop    locloop_233

                mov     cx,8
locloop_234:
                push    cx
                fstp    qword ptr es:[di]
                fwait
                xor     dx,dx
                mov     cx,4
locloop_235:
                lodsw
                and     ax,dx
                jnz     fail_0
                loop    locloop_235

                sub     si,8
                pop     cx
                loop    locloop_234

                or      bx,1
                jmp     short loc_237
fail_0:
                pop     cx
loc_237:
                lea     si,ss:[bp-18]
                mov     cx,8
locloop_238:
                fld     qword ptr cs:data_1
                loop    locloop_238

                mov     cx,8
locloop_239:
                push    cx
                fstp    qword ptr es:[di]
                fwait
                mov     dx,5555h
                mov     cx,4
locloop_240:
                lodsw
                cmp     ax,dx
                jne     fail_1
                loop    locloop_240

                sub     si,8
                pop     cx
                loop    locloop_239

                or      bx,2
                jmp     short loc_242
fail_1:
                pop     cx
loc_242:
                lea     si,ss:[bp-18]
                mov     cx,8
locloop_243:
                fld     qword ptr cs:data_2
                loop    locloop_243

                mov     cx,8
locloop_244:
                push    cx
                fstp    qword ptr es:[di]
                fwait
                mov     dx,0AAAAh
                mov     cx,4
locloop_245:
                lodsw
                cmp     ax,dx
                jne     fail_2
                loop    locloop_245

                sub     si,8
                pop     cx
                loop    locloop_244

                or      bx,4
                jmp     short loc_247
fail_2:
                pop     cx
loc_247:
                lea     si,ss:[bp-18]
                mov     cx,8
locloop_248:
                fld     qword ptr cs:data_3
                loop    locloop_248

                mov     cx,8
locloop_249:
                push    cx
                fstp    qword ptr es:[di]
                fwait
                mov     dx,0FFFFh
                mov     cx,4
locloop_250:
                lodsw
                cmp     ax,dx
                jne     fail_3
                loop    locloop_250

                sub     si,8
                pop     cx
                loop    locloop_249

                or      bx,8
                jmp     short loc_252
fail_3:
                pop     cx
loc_252:
                mov     ax,bx
                pop     di
                pop     si
                pop     es
                pop     ds
		mov	sp,bp
                pop     bp
                retn

data_0          dq      0
data_1          dq      05555555555555555h
data_2          dq      0AAAAAAAAAAAAAAAAh
data_3          dq      0FFFFFFFFFFFFFFFFh

_rdwr87         endp

                assume  ds:_TEXT

                public  _ndpspeed
_ndpspeed       proc    near
                push    bp
                mov     bp,sp
		sub	sp,6
                push    ds

                push    cs
                pop     ds

                push    es
                mov     ax,351Ch
                int     21h
                mov     word ptr ds:old1Co,bx
                mov     word ptr ds:old1Cs,es
                pop     es

                fninit                  ; Initialize math uP
                fldz                    ; Push +0.0 to stack
                mov     word ptr ds:icounter,91
                mov     bh,ss:[bp+4]    ; 1st arg = ndp type
                mov     bl,1
                lea     dx,ds:int_1Ch_entry
                mov     ax,251Ch
                int     21h

loc_222:        or      bl,bl
                jnz     loc_222
                cmp     bh,1
                je      short loc_223
                jmp     loc_225
loc_223:
                rept    100
                db      09Bh,0D9h,0E8h  ; fld1          ; Push +1.0 to stack
                db      09Bh,0DEh,0C1h  ; faddp st(1),st
                db      09Bh,0D9h,0EDh  ; fldln2        ; Push log e(2) to st
                db      09Bh,0D9h,0F2h  ; fptan         ; Partial Tangent
                db      09Bh,0D9h,0F1h  ; fyl2x         ; st = st(1)*log2(st)
                db      09Bh,0DDh,0D8h  ; fstp st       ; Pop st to st(#)
                endm

                mov     cx,word ptr ds:icounter
                jcxz    short loc_224
                jmp     loc_223
loc_224:        jmp     loc_226
loc_225:
                rept    100
                db      0D9h,0E8h       ; fld1          ; Push +1.0 to stack
                db      0DEh,0C1h       ; faddp st(1),st
                db      0D9h,0EDh       ; fldln2        ; Push log e(2) to st
                db      0D9h,0F2h       ; fptan         ; Partial Tangent
                db      0D9h,0F1h       ; fyl2x         ; st = st(1)*log2(st)
                db      0DDh,0D8h       ; fstp    st    ; Pop st to st(#)
                endm

                mov     cx,word ptr ds:icounter
                jcxz    short loc_226
                jmp     loc_225
loc_226:
                lds     dx,dword ptr ds:old1Ch
                mov     ax,251Ch
                int     21h

                push    cs
                pop     ds

                mov     ax,ss:[bp+4]            ; 1st arg = ndp type
                add     ax,ax
                lea     bx,cs:coeffs
                add     bx,ax
                fild    word ptr ds:[bx]        ; Push onto stack
                fmulp   st(1),st                ; st(#)=st(#)*st, pop
                fild    word ptr ds:five
                fdivp   st(1),st                ; st(#)=st(#)/st, pop
                fild    word ptr ds:thousand
                fdivp   st(1),st                ; st(#)=st(#)/st, pop
                fistp   dword ptr ss:[bp-6]     ; depends on regs saving!
                fwait
                mov     ax,ss:[bp-6]            ; store long
                mov     dx,ss:[bp-4]

                pop     ds
		mov	sp,bp
                pop     bp
                retn

coeffs          label   word
thousand        dw      1000            ; dummy for addressing
                dw      1775, 1810, 707
five            dw      5

_ndpspeed       endp

int_1Ch_entry   proc    far
                xor     bl,bl
                dec     word ptr cs:icounter
                db      0EAh    ; 1st byte of the far jump
old1Ch          label   dword
old1Co          dw      ?
old1Cs          dw      ?
int_1Ch_entry   endp

icounter        dw      ?

                public  _errline
_errline        proc    near
                push    bp
                mov     bp,sp
		sub	sp,14
                push    ds
                push    es

                push    cs
                pop     ds

                mov     ax,3502h
                int     21h
                push    es
                push    bx

                mov     cx,100
                fninit          ; Initialize math uP
                fstcw   word ptr ss:[bp-14]
                mov     word ptr ds:icounter,0

                lea     dx,cs:int_02h_entry
                mov     ax,2502h
                int     21h
locloop_210:
                fninit          ; Initialize math uP
                fnclex          ; Clear execptn flags
                fldcw   word ptr ds:eline_cword
                sti
                cmp	byte ptr ss:[bp+4],0    ; cpu flag
                jz	short loc_211
                mov     al,80h  ; al = 80h, enable NMI
                out     0A0h,al ; port 0A0h, 8259-2 int command
                jmp     short loc_212
loc_211:
                mov     al,0    ; al = 0, seconds register
                out     70h,al  ; port 70h, RTC addr/enabl NMI
loc_212:
                fld     dword ptr ds:eline_sqrt
                fsqrt           ; st=square root(st)
                fnstcw  word ptr ss:[bp-12]
                fnstsw  word ptr ss:[bp-10]
                loop    locloop_210

                fninit          ; Initialize math uP

                pop     dx      ; Old handler offset
                pop     ds      ; Old handler segment
                mov     ax,2502h
                int     21h

                mov     ax,100
                sub     ax,word ptr cs:icounter

                pop     es
                pop     ds
		mov	sp,bp
                pop     bp
                retn

eline_sqrt      dd      3502B806h
eline_cword     dw      0
_errline        endp

int_02h_entry   proc    far
                inc     word ptr cs:icounter
                iret
int_02h_entry   endp

;	Indicates one step of the 87-spec test
		PUBLIC	_click
_click		PROC	near

		push    ds

		mov     ax,0EFEh	; draws a bar
		xor	bx,bx		; for a safety
		int	10h

		in	al,61h
		xor	al,2
		out	61h,al		; sounds a click

		mov	cx,200h
		loop	$		; wait a moment

		xor	al,2
		out	61h,al		; sounds a click

		xor     ax,ax
		mov     ds,ax
		mov     dx,word ptr ds:[46Ch]	; remember timer
delay:		mov     ax,word ptr ds:[46Ch]
		sub     ax,dx
		cmp     ax,2		; number of ticks
		jb      delay		; wait 2ms

		pop     ds
		ret

_click		ENDP

_TEXT           ends
                end
