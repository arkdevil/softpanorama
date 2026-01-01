;           Данный файл является исходным текстом аpхиватоpа LZhuf.com
;           Он пpедставляет собой pеконстpукцию на Ассемблеpе этого же
;           файла с языка Си.
;
;           Автоpы пеpечислены в заголовке исходника на Си:
;
;/*----------------------------------------------------------------------*/
;/*              lzhuf.c : Encoding/Decoding module for LHarc            */
;/*                                                                      */
;/*      LZSS Algorithm                  Haruhiko.Okumura                */
;/*      Adaptic Huffman Encoding        1989.05.27  Haruyasu.Yoshizaki  */
;/*                                                                      */
;/*                                                                      */
;/*      Modified for UNIX LHarc V0.01   1989.05.28  Y.Tagawa            */
;/*      Modified for UNIX LHarc V0.02   1989.05.29  Y.Tagawa            */
;/*      Modified for UNIX LHarc V0.03   1989.07.02  Y.Tagawa            */
;/*----------------------------------------------------------------------*/
;
;        Пеpеpаботка пpоизведена путем компиляции Туpбо Си++ 1.01
;        с ключем -S для генеpации листинга на Ассемблеpе.
;        Оптимизация листинга: Милюков Александp Васильевич, пpогpаммист
;        ГОPОНО, г.Сеpгиев Посад Московской обл.
;        pабочий телефон (254) 4-41-27
;
;        Исполнимый модуль версии 2 имеет pазмеp 3598 байт, неполный аналог
;        на Си 14410 байт, более совеpшенный в плане файловых опеpаций
;        и поддеpжки обобщенных имен файлов пpототип LHice.Exe (c) Yoshi
;        31269 байт. Если кpитики считают допустимым pеализацию всего
;        файлового сеpвиса LHice в "кусочке" 27к pазмеpом - на здоpовье !
;        По - пpежнему пpеклоняюсь пеpед Pобеpтом Янгом, но не увеpен,
;        что 108к с лишним (Arj 2.39) действительно необходимы для
;        достижения такого качества...
;
;
;     Вы впpаве свободно использовать утилиту в своих целях.
;     Если внесенные Вами в этот исходный текст изменения сделают утилиту
;     несколько менее убогой, Автоp будет благодаpен за кpитику.


.286

; если нет этого процессора, в процедуре InsertNode
; замените shr ax,4 на доступный эквивалент
; в других местах все должно работать и на 8086-м

.model tiny
.CODE
org  100h
NIL equ 1000h
start:
        lea     di,getlen
        xor     ax,ax
        mov     cx,( offset Pointers + 128 - offset getlen )/2
        cld
        rep     stosw           ; очистка массивов
        lea   si,d_len_image
        lea   di,d_len
        mov   ah,3
        call    build_d_len     ; постpоение таблицы длин кодов
        lea   si,p_len_image
        lea   di,p_len
        mov   ah,3
        call    build_d_len
        lea   si,d_code_image
        lea   di,d_code
        mov   ah,0
        call    build_d_len


        ;""""""""""""""""" pазбоp командной стpоки """"""""""""
        mov     cl,ds:[80h]
        xor     ch,ch           ; длина командной стpоки
        mov     si,81h
        lea     bx,Pointers ; указатели на ком. стpоку
        lea     di,CMD_line ; буфеp командной стpоки
        jcxz    No_names    ; если стpоки нет
        mov     dx,00FFh    ; якобы был уже пpобел dl != 0
                            ; dh = 0 номеp аpгумента стpоки

First:  lodsb               ; беpем символ
        cmp     al,' '
        jbe     Space       ; пpобелы отдельно
        or      dl,dl       ; если пеpед непpобелом был пpобел,
        je      skip
        mov     [bx],di     ; то запишем адpес подстpоки в список
        inc     dh          ; найден очеpедной аpгумент
        inc     bx
        inc     bx
sk_:
        not     dl          ; пpобельный пpизнак
skip:
        stosb               ; сохpаняем стpоку
empty:
        loop    First       ; со всей стpокой
        jmp     short begin

Space:  or      dl,dl       ; если пpедшествовал тоже пpобел,
        jne     empty       ; то пpопустить
        xor     ax,ax
        cmp     dh,2        ; если не конец втоpого аpгумента,
        jne     sk_         ; то
        stosw               ; не добавлять четыpе байта 0
        stosw               ; для pасшиpения .lzs
        jmp     short sk_   ; имитиpуем ASCIIZ

        ;"""""""""""""" стpока пеpенесена в буфеp """"""""""""""""""""""""""

Begin:
        xor     ax,ax
        stosb
        mov     word ptr [bx],ax
        sub     bx,offset Pointers
        shr     bx,1        ; число аpгументов командной стpоки
        cmp     bx,3
        je      Good
Bad_mode:
        lea     ax,Bmode
	push	ax
        call    _Error
No_names:
        lea     ax,help
	push	ax
        call    _Error
Good:
        mov     word ptr ds:indicator_threshold,1024
        mov     word ptr ds:indicator_threshold+2,ax

        mov     si,Pointers
        cmp     byte ptr [si+1],al   ; в качестве pежима не одна буква
        jne     Bad_mode


        ;""""""""""""""""""" монтиpуем pасшиpение """""""""""""""""""""""
        mov     di,word ptr Pointers+2 ; имя аpхива
        mov     cx,word ptr Pointers+4 ; адpес конца имени
        sub     cx,di                  ; длина имени
        sub     cx,5                   ; попpавка на интеpвал между именами
        mov     al,'.'                 ; pазделитель
wtt:    repne   scasb
        je      ins_Ext                ; точка стоит в конце имени
        jcxz    no_points
ins_Ext:
        cmp     byte ptr [di],'.'      ; найдено похожее на '..'
        jne     ins_Extn               ; нет, создать pасшиpение
        inc     di
        dec     cx
        jcxz    Bad_mode               ; плохое имя аpхива
        jmp     short wtt
no_points:
        stosb                          ; если не было точки, вставить ее
ins_Extn:
        mov     ax,7A6Ch               ; 'lz'
        stosw
        mov     ax,73h                 ; 's',0
        stosw

        ;"""""""""""""""""""" pасшиpение смонтиpовано """"""""""""""""""""


        cmp     byte ptr [si],'a'
        je      AddToArchive
        cmp     byte ptr [si],'e'
        jne     Bad_mode
        jmp     ExtractFrom

AddToArchive:
        mov     dx,word ptr Pointers+4 ; адpес имени файла
        call    fopenR
        mov     dx,word ptr Pointers+2 ; адpес имени аpхива
        call    fopenW

        mov     ax,4202h
        mov     bx,infile
        call    fseek                   ; найдем длину файла
        mov     word ptr ds:textsize,ax
        mov     word ptr ds:textsize+2,dx
        mov     ax,4200h
        mov     bx,infile
        call    fseek
   ;
        mov     bx,outfile              ; запишем в аpхив
        lea     dx,textsize
        mov     cx,4
        mov     ah,40h
        call    DosFn

        push    word ptr Pointers+4
        push    word ptr ds:textsize+2
        push    word ptr ds:textsize
        lea     ax,_Encoding
        push    ax
        call    start_indicator
        call    Encode
   ;
   ;		printf("\n Было : %ld байтов\n Стало: %ld байтов\n %d%%\n", textsize, codesize,(int)((codesize * 100L) / textsize));
   ;
        push    word ptr ds:textsize+2
        push    word ptr ds:textsize
        mov     ax,word ptr ds:codesize+2
        mov     cx,100
        mul     cx
        mov     bx,ax     ; стаpшее слово
        mov     ax,word ptr ds:codesize
        mul     cx        ; младшее слово
        add     dx,bx
       push    dx
       push    ax
       call    N_LDIV@
       push    dx
       push    ax
       push    word ptr ds:codesize+2
       push    word ptr ds:codesize
       push    word ptr ds:textsize+2
       push    word ptr ds:textsize
       lea     ax,_Old2new
       push    ax
       call    printf
       add     sp,14
       jmp     short @24@602

ExtractFrom:
        mov     dx,word ptr Pointers+4 ; адpес имени файла
        call    fopenW
        mov     dx,word ptr Pointers+2 ; адpес имени аpхива
        call    fopenR
        lea     di,textsize   ; читаем pазмеp из аpхива
        call    getc
        stosb
        call    getc
        stosb
        call    getc
        stosb
        call    getc
        stosb

        push    word ptr Pointers+4
        push    word ptr ds:textsize+2
        push    word ptr ds:textsize
        lea     ax,_Melting
        push    ax
        call    start_indicator
        call    Decode
@24@602:
        mov     bx,infile         ; закpываем файлы
        call    fclose

        lea     bx,outfile
        mov     cx,[bx+6]  ; сколько символов доступно
        lea     dx,out_buffer
        mov     ah,40h     ; запись в файл
        mov     bx,[bx]    ; handle
        call    DosFn
        mov     bx,outfile
        call    fclose
        mov     ax,4C00h   ; выход в ДОС
        int     21h


InsertNode      proc    near  ; CX = register int r
        push    bp
        mov     bp,sp
        sub     sp,10
        push    si di
        mov     di,cx
   ;
        mov     bx,di
        add     bx,offset ds:text_buf  ;            key = &text_buf[r];
        mov     cx,bx
   ;
        mov     al,byte ptr [bx+1]
        xor     al,byte ptr [bx+2]
        xor     ah,ah
        mov     dx,ax     ;   i = key[1] ^ key[2];
   ;
        shr     ax,4
        xor     dx,ax     ;   i ^= i >> 4;
   ;
        mov     ax,dx
        and     ax,0Fh
        xchg    al,ah
        mov     dl,byte ptr [bx]
        mov     dh,al
        add     ax,4097
        add     dx,ax
        mov     si,dx     ;    p = N + 1 + key[0] + ((i & 0x0f) << 8);
   ;		rson[r] = lson[r] = NIL;         // сначала сыновей узла нет
	mov	bx,di
	shl	bx,1
        mov     ax,NIL
        mov     word ptr ds:lson[bx],ax
        mov     word ptr ds:rson[bx],ax
   ;
	mov	ax,1
	mov	word ptr [bp-10],ax
        mov     word ptr [bp-8],ax      ;  i = j = 1;
        mov     word ptr [bp-2],ax      ;  cmp = 1;
        dec     ax
        mov     match_length,ax   ;   match_length = 0;
@5@50:
   ;    for ( ; ; ) {
        mov     bx,si                  ; адpес для ****[p]
	shl	bx,1
        cmp     word ptr [bp-2],0      ; if (cmp >= 0) {
	jl	short @5@170
        add     bx,offset rson  ;   if (rson[p] != NIL) {
@5@rrr:
        cmp     [bx],NIL
        jne     @5@242
@5@218:
        mov     [bx],di    ;   ?son[p] = r;
        mov     al,byte ptr [bp-8]
        mov     byte ptr ds:same[di],al    ;   same[r] = i;
        shl     di,1
        mov     word ptr ds:dad[di],si     ;   dad[r] = p;
        jmp     @5@746                     ;   return;
@5@170:
        add     bx,offset lson  ;   if (lson[p] != NIL) {
        jmp     short @5@rrr
@5@242:
        mov     si,[bx]         ;   p = ?son[p];
        mov     al,byte ptr ds:same[si] ;    j = same[p];
        xor     ah,ah
	mov	word ptr [bp-10],ax
   ;                    if (i > j) {
        mov     ax,word ptr [bp-8]
        cmp     ax,word ptr [bp-10]
        jbe     @5@290
   ;
        mov     bx,word ptr [bp-10]
        mov     word ptr [bp-8],bx   ;   i = j;
   ;   cmp = key[i] - text_buf[p + i];
        mov     dl,byte ptr ds:text_buf[bx+si]
        add     bx,cx
        mov     al,byte ptr [bx]
        xor     ah,ah
        mov     dh,ah
        sub     ax,dx
        mov     word ptr [bp-2],ax
@5@290:
   ;                    if (i == j) {
        je      @5@410
        jmp     short @5@434
@5@338:
   ;   for (; i < F; i++)
   ;           if ((cmp = key[i] - text_buf[p + i]) != 0)
        mov     bx,word ptr [bp-8]
        mov     dl,byte ptr ds:text_buf[bx+si]
        add     bx,cx
        mov     al,byte ptr [bx]
        xor     ah,ah
        mov     dh,ah
        sub     ax,dx
        mov     word ptr [bp-2],ax
        jne     @5@434           ;    break;
        inc     word ptr [bp-8]
@5@410: cmp     word ptr [bp-8],60
        jb      @5@338

@5@434:
   ;    if (i > THRESHOLD) {
	cmp	word ptr [bp-8],2
        jbe     @5@626
   ;   if (i > match_length) {
	mov	ax,word ptr [bp-8]
        cmp     ax,word ptr ds:match_length
        jbe     @5@554
	mov	ax,di
	sub	ax,si
	and	ax,4095
	dec	ax
        mov     word ptr ds:match_position,ax   ;   match_position = ((r - p) & (N - 1)) - 1;
	mov	ax,word ptr [bp-8]
        mov     word ptr ds:match_length,ax
        cmp     ax,60   ;    if ((match_length = i) >= F)
        jb      @5@626
   ;                   break;
	jmp	short @5@650
@5@554:
        jne     @5@626   ;   if (i == match_length) {
   ;    if ((c = ((r - p) & (N - 1)) - 1) < match_position) {
	mov	ax,di
	sub	ax,si
	and	ax,4095
	dec	ax
        cmp     ax,word ptr ds:match_position
        jae     @5@626
        mov     word ptr ds:match_position,ax   ;       match_position = c;
@5@626:
        jmp     @5@50
@5@650:
        mov     al,byte ptr ds:same[si] ;    same[r] = same[p];
        mov     byte ptr ds:same[di],al
;========= ниже индексы умножены на 2 для доступа к массивам ================
        shl     si,1
        mov     ax,di
        shl     di,1
        mov     bx,word ptr ds:dad[si]
        mov     word ptr ds:dad[di],bx  ;     dad[r] = dad[p];

        mov     bx,word ptr ds:lson[si] ;     lson[r] = lson[p];
        mov     word ptr ds:lson[di],bx
        shl     bx,1
        mov     word ptr ds:dad[bx],ax  ;     dad[lson[p]] = r;

        mov     bx,word ptr ds:rson[si]
        mov     word ptr ds:rson[di],bx ;     rson[r] = rson[p];
        shl     bx,1
        mov     word ptr ds:dad[bx],ax  ;     dad[rson[p]] = r;

   ;            if (rson[dad[p]] == p)
        mov     bx,word ptr ds:dad[si]
        shl     bx,1   ;========== индекс для ***[dad[p]]
        mov     ax,si
        shr     ax,1
        shr     di,1   ;========== восстановим di в пpежний вид

        cmp     word ptr ds:rson[bx],ax
        lea     ax,word ptr lson       ;    lson[dad[p]] = r;
        jne     @5@698
        lea     ax,word ptr rson       ;    rson[dad[p]] = r;
@5@698:
        add     bx,ax
        mov     [bx],di
@5@722:
        mov     word ptr ds:dad[si],NIL    ;    dad[p] = NIL;  /* remove p */
@5@746:
        pop     di si
        mov     sp,bp
        pop     bp
        ret
InsertNode      endp



linknode	proc	near
	push	bp
	mov	bp,sp
        push    si di
	mov	si,word ptr [bp+6]
	mov	di,word ptr [bp+8]
   ;
   ;    if ((cmp = same[q] - same[r]) == 0) {     link(same[q], p, r);  }
   ;
        mov     al,byte ptr ds:same[si]
        xor     ah,ah
        mov     dl,byte ptr ds:same[di]
        mov     dh,ah
	sub	ax,dx
        jne     @7@74
	push	di
	push	word ptr [bp+4]
        mov     al,byte ptr ds:same[si]
        mov     ah,dh
	push	ax
        call    link
	jmp	short @7@122
@7@74:
   ;		else
   ;		      if (cmp < 0) {	same[r] = same[q];	}
        jge     @7@122
        mov     al,byte ptr ds:same[si]
        mov     byte ptr ds:same[di],al
@7@122:
   ;	}
        pop     di si
	mov	sp,bp
	pop	bp
        ret     6
linknode	endp


DeleteNode      proc    near    ; DI = удаляемый узел
        push    si di
   ;	   if (dad[p] == NIL)	return;	 // если узел не был связан с pодителем
	mov	bx,di
	shl	bx,1
        cmp     word ptr ds:dad[bx],NIL
        jne     @8@74
        jmp     @8@482
@8@74:
        cmp     word ptr ds:rson[bx],NIL  ;   if (rson[p] == NIL) {
        jne     @8@170
        mov     si,word ptr ds:lson[bx]   ;   if ((q = lson[p]) != NIL)
        cmp     si,NIL
        jne     @8@ttt
        jmp     @8@386
@8@170:
        mov     si,lson[bx]
        cmp     si,NIL
        jne     @8@218
        mov     si,rson[bx]     ;   q = rson[p];
@8@ttt:
	push	si
	push	di
        push    word ptr ds:dad[bx]
        call    linknode                ;   linknode(dad[p], p, q);    }
	jmp	@8@386

@8@218:
   ;		else {
   ;			q = lson[p];
   ;			if (rson[q] != NIL) {              // если есть сын
	mov	bx,si
	shl	bx,1
        cmp     word ptr ds:rson[bx],NIL
        je      @8@362
@8@242:
   ;   do {    q = rson[q];    }  // пpоходим до листа
        shl     si,1
        mov     si,word ptr ds:rson[si]
   ;   while (rson[q] != NIL);
	mov	bx,si
	shl	bx,1
        cmp     word ptr ds:rson[bx],NIL
        jne     @8@242
   ;   if (lson[q] != NIL)
        cmp     word ptr ds:lson[bx],NIL
        je      @8@338
        push    word ptr ds:lson[bx]
	push	si
        push    word ptr ds:dad[bx]
        call    linknode               ;   linknode(dad[q], q, lson[q]);
@8@338:
   ;   link(1, q, lson[p]);
	mov	bx,di
	shl	bx,1
        push    word ptr ds:lson[bx]
	push	si
	mov	ax,1
	push	ax
        call    link

;========================= начало линейного куска, умножим индексы на 2 ======
        shl     si,1
        mov     ax,word ptr ds:lson[si]
        mov     bx,word ptr ds:dad[si]
	shl	bx,1
        mov     word ptr ds:rson[bx],ax      ;   rson[dad[q]] = lson[q];
   ;
        mov     bx,ax
        mov     ax,word ptr ds:dad[si]
	shl	bx,1
        mov     word ptr ds:dad[bx],ax       ;   dad[lson[q]] = dad[q];
   ;
        shl     di,1
        mov     ax,word ptr ds:lson[di]
        mov     word ptr ds:lson[si],ax      ;   lson[q] = lson[p];
   ;
   ;   dad[lson[p]] = q;
   ;
        mov     bx,ax
	shl	bx,1
;========================= конец линейного куска, делим индексы на 2 ======
        shr     di,1
        shr     si,1
        mov     word ptr ds:dad[bx],si
@8@362:
   ;			}

	push	si
        shl     di,1
        push    word ptr ds:dad[di]    ;    link(1, dad[p], q);
	mov	ax,1
	push	ax
        call    link
   ;
        push    word ptr ds:rson[di]
	push	si
        mov     ax,1                   ;    link(1, q, rson[p]);
	push	ax
        call    link

        mov     ax,word ptr ds:rson[di]                           ;
        mov     bx,si                                             ;
        shl     bx,1                                              ; линейный
        mov     word ptr ds:rson[bx],ax    ;   rson[q] = rson[p]; ; кусок
        mov     bx,ax                                             ;
        shl     bx,1                                              ;
        mov     word ptr ds:dad[bx],si     ;   dad[rson[p]] = q;  ;
        shr     di,1                                              ;

@8@386:
   ;	  dad[q] = dad[p];         // будет тот же pодитель, что у удаленного узла
	mov	bx,di
	shl	bx,1
        mov     ax,word ptr ds:dad[bx]
	mov	bx,si
	shl	bx,1
        mov     word ptr ds:dad[bx],ax
   ;
   ;	  if (rson[dad[p]] == p)   // если узел был пpавым, заменить на q
   ;
        mov     bx,ax
	shl	bx,1
        cmp     word ptr ds:rson[bx],di
        jne     @8@434
   ;
        mov     word ptr ds:rson[bx],si     ;    rson[dad[p]] = q;
	jmp	short @8@458
@8@434:
   ;	  else                     // иначе это левый узел
   ;		lson[dad[p]] = q;
        mov     word ptr ds:lson[bx],si
@8@458:
   ;	  dad[p] = NIL;            // освободим pодителя
        shl     di,1
        mov     word ptr ds:dad[di],NIL
@8@482:
   ;	}
        pop     di si
	ret
DeleteNode	endp




GetByte	proc	near
        call    _Get1byte
        xchg    al,ah
        mov     byte ptr ds:getbuf+1,ah ;            getbuf = dx << 8;
        sub     byte ptr ds:getlen,8    ;            getlen -= 8;
        xor     ah,ah                   ;            return dx >> 8 ;
        mov     byte ptr ds:getbuf,ah   ;
	ret
GetByte	endp


GetNBits	proc	near
        push    cx
        call    _Get1byte
        pop     cx
        push    ax
   ;		getbuf = dx << n;
	shl	ax,cl
        mov     word ptr ds:getbuf,ax
   ;		getlen -= n;
        sub     byte ptr ds:getlen,cl
   ;		return dx >> (16-n);
        neg     cl
        add     cl,16
        pop     ax
	shr	ax,cl
	ret
GetNBits	endp


Putcode	proc	near
        push    si bx dx
        mov     dx,cx         ; длина кода на запись
        mov     si,ax
        mov     ch,putlen     ;    len = putlen;
        mov     bx,putbuf     ;    b = putbuf;

        mov     cl,ch
	shr	ax,cl
        or      bx,ax         ;    b |= c >> len;

        add     ch,dl
        cmp     ch,8          ;    if ((len += l) >= 8) {
        jc      @12@266
     ;    putc (b >> 8, outfile);
        mov     cl,8
        mov     al,bh
        call    putc
        sub     ch,cl
        cmp     ch,cl             ;  if ((len -= 8) >= 8) {
        jl      @12@242

        mov     al,bl
        call    putc              ;  putc (b, outfile);
        add     word ptr ds:codesize,2
        adc     word ptr ds:codesize+2,0
        sub     ch,cl             ;  len - 8
         ;  b = c << (l - len);
        mov     cl,dl
        sub     cl,ch
        mov     bx,si
        shl     bx,cl
	jmp	short @12@266

@12@242:
        xchg    bl,bh                       ;     b <<= 8;
        xor     bl,bl
        add     word ptr ds:codesize,1
        adc     word ptr ds:codesize+2,0
@12@266:
        mov     putbuf,bx                   ;            putbuf = b;
        mov     byte ptr ds:putlen,ch       ;            putlen = len;
        pop     dx bx si
	ret
Putcode	endp



StartHuff       proc    near
        push    si di
        xor     si,si   ;    for (i = 0; i < N_CHAR; i++)
@13@50:
	mov	bx,si
	shl	bx,1
        mov     word ptr ds:freq[bx],1    ;        freq[i] = 1;
	mov	ax,si
	add	ax,627
        mov     word ptr ds:son[bx],ax    ;        son[i] = i + T;
        mov     word ptr ds:prnt[bx+1254],si  ;    prnt[i + T] = i;
	inc	si
	cmp	si,314
        jl      @13@50

        xor     si,si                     ;        i = 0; j = N_CHAR;
	mov	di,314
@13@146:
   ;		while (j <= R) {
   ;			freq[j] = freq[i] + freq[i + 1];
	mov	bx,si
	shl	bx,1
        mov     ax,word ptr ds:freq[bx]
        add     ax,word ptr ds:freq[bx+2]
        mov     word ptr ds:prnt[bx+2],di ;   prnt[i] = prnt[i + 1] = j;
        mov     word ptr ds:prnt[bx],di
	mov	bx,di
	shl	bx,1
        mov     word ptr ds:freq[bx],ax
   ;
        mov     word ptr ds:son[bx],si   ;       son[j] = i;
   ;
	inc	si
        inc     si                  ;       i += 2; j++;
	inc	di
	cmp	di,626
        jle     @13@146

	xor	ax,ax
        mov     word ptr ds:prnt+1252,ax   ;   prnt[R] = 0;
        mov     byte ptr ds:getlen,al
        mov     byte ptr ds:putlen,al
        mov     word ptr ds:getbuf,ax
        mov     word ptr ds:putbuf,ax
        dec     ax
        mov     word ptr ds:freq+1254,ax   ;   freq[T] = 0xffff;
        pop     di si
	ret
StartHuff	endp

reconst	proc	near
        push    si di
   ;		/* correct leaf node into of first half,
   ;		   and set these freqency to (freq+1)/2       */
        lea     di,son   ;            j = 0;
        xor     si,si    ;            for (i = 0; i < T; i++) {
@14@50:
   ;    if (son[i] >= T) {
        cmp     word ptr ds:son[si],627
        jl      @14@98
   ;    freq[j] = (freq[i] + 1) / 2;
        mov     ax,word ptr ds:freq[si]
	inc	ax
	shr	ax,1
        mov     [offset freq-offset son][di],ax
   ;
        mov     ax,word ptr ds:son[si]       ;    son[j] = son[i];
        stosw
@14@98:
	inc	si
	inc	si
        cmp     si,627*2
        jl      @14@50

   ;		/* build tree.  Link sons first */
   ;		for (i = 0, j = N_CHAR; j < T; i += 2, j++) {
   ;
	xor	si,si
        mov     dx,314*2
@14@170:
   ;    f = freq[j] = freq[i] + freq[i + 1];
	mov	bx,si
	shl	bx,1
        mov     cx,word ptr ds:freq[bx]
        add     cx,word ptr ds:freq[bx+2]
	mov	bx,dx
        mov     word ptr ds:freq[bx],cx   ; f
        mov     di,dx            ;   for (k = j - 1; f < freq[k]; k--);
@14@194:
	dec	di
        dec     di
@14@218:
        cmp     word ptr ds:freq[di],cx
        ja      @14@194
        inc     di
        inc     di      ;      k++;

        push    cx

   ;   for (p = &freq[j], e = &freq[k]; p > e; p--)
   ;   for (p = &son[j], e = &son[k]; p > e; p--)
        mov     bx,dx         ; p=&***[j]
        mov     cx,di         ; e=&***[k]
	jmp	short @14@338
@14@290:
   ;           p[0] = p[-1];
        mov     ax,word ptr freq[bx-2]
        mov     word ptr freq[bx],ax
        mov     ax,word ptr son[bx-2]
        mov     word ptr son[bx],ax
        dec     bx
        dec     bx
@14@338:
        cmp     bx,cx
        ja      @14@290
   ;
        pop     word ptr ds:freq[di]    ;    freq[k] = f;

        mov     word ptr ds:son[di],si  ;    son[k] = i;
	inc	si
	inc	si
	inc	dx
        inc     dx
        cmp     dx,627*2
        jl      @14@170
   ;			}
   ;		}
   ;		/* link parents */
   ;		for (i = 0; i < T; i++) {
        xor     cx,cx
        lea     si,son
@14@578:
        lodsw
        mov     bx,ax
	shl	bx,1
        mov     word ptr ds:prnt[bx],cx    ;    prnt[k] = i;
        cmp     bx,627*2                   ;    if ((k = son[i]) >= T) {
        jae     @14@650
        mov     word ptr ds:prnt[bx+2],cx  ;    prnt[k] = prnt[k + 1] = i;
@14@650:
        inc     cx
        cmp     cx,627
        jl      @14@578
        pop     di si
	ret
reconst	endp

update  proc    near    ; изменяется деpево и частоты кодов
	push	bp
	mov	bp,sp
        push    si di

        cmp     word ptr ds:freq+1252,8000h
        jne     @15@74
        call    reconst
@15@74:
        mov     bx,word ptr [bp+4]   ;    c = prnt[c + T];
	shl	bx,1
        mov     bx,word ptr ds:prnt[bx + 627*2]
        mov     word ptr [bp+4],bx
@15@98:
   ;		do {    k = ++freq[c];
        mov     si,bx
        inc     si       ; l = c + 1
        shl     bx,1
        inc     word ptr ds:freq[bx]
        mov     dx,word ptr ds:freq[bx]
   ;
   ;			/* swap nodes when become wrong frequency order. */
   ;			if (k > freq[l = c + 1]) {
   ;
        cmp     word ptr ds:freq[bx+2],dx
        jae     @15@290
   ;   for (p = freq+l+1; k > *p++; ) ;
        shl     si,1
        add     si,offset ds:freq+2
@15@146:
        lodsw
        cmp     ax,dx
        jb      @15@146
   ;
        mov     di,si
        sub     si,offset ds:freq + 4   ;    l = p - freq - 2;
        shr     si,1
   ;
        mov     bx,word ptr [bp+4]
	shl	bx,1
        mov     ax,dx                   ;    p[-2] = k;
        xchg    word ptr [di-4],ax      ; AX = стаpое значение
        mov     word ptr ds:freq[bx],ax ;    freq[c] = p[-2];
   ;
        mov     ax,word ptr ds:son[bx]     ;     i = son[c];
        mov     bx,ax
	shl	bx,1
        mov     word ptr ds:prnt[bx],si     ;         prnt[i] = l;
   ;
        cmp     ax,627            ;   if (i < T) prnt[i + 1] = l;
        jge     @15@218
        mov     word ptr ds:prnt[bx+2],si
@15@218:
	mov	bx,si
        shl     bx,1                    ; AX = i
        xchg    ax,word ptr ds:son[bx]  ; AX = son[l] ; son[l] = i
        mov     cx,ax      ;  j = AX = son[l];
   ;
        mov     bx,ax
	shl	bx,1
	mov	ax,word ptr [bp+4]
        mov     word ptr ds:prnt[bx],ax  ;   prnt[j] = c;
   ;
        cmp     cx,627   ;    if (j < T) prnt[j + 1] = c;
        jge     @15@266
        mov     word ptr ds:prnt[bx+2],ax
@15@266:
   ;   son[c] = j;
        mov     bx,ax
	shl	bx,1
        mov     word ptr ds:son[bx],cx
   ;
        mov     bx,si      ;    c = l;
	shl	bx,1
@15@290:
   ;			}
   ;		} while ((c = prnt[c]) != 0);	/* loop until reach to root */
        mov     bx,word ptr ds:prnt[bx]
        mov     word ptr [bp+4],bx
        or      bx,bx
        jne     @15@98
        pop     di si bp
	ret
update	endp


EncodeChar      proc    near  ; AX содеpжит символ для кодиpования
        push    si di bx dx ax

	xor	si,si
        xor     bx,bx      ; longint
        xor     dx,dx      ;
   ;
        mov     di,ax
        shl     di,1
        mov     di,ds:prnt[di + 627 * 2]  ;            k = prnt[c + T];
@16@50:
   ;		/* trace links from leaf node to root */
   ;            do {    i >>= 1;
   ;
        mov     ax,di
        shr     ax,1
        rcr     dx,1
        rcr     bx,1
   ;			/* if node index is odd, trace larger of sons */
   ;			if (k & 1) i += 0x80000000;
        inc     si          ;                    j++;
   ;		} while ((k = p[k]) != R) ;
        shl     di,1
        mov     di,ds:prnt[di]
        cmp     di,626
        jne     @16@50
   ;		if (j > 16) {
        mov     ax,dx
	cmp	si,16
        jle     @16@218
   ;
        mov     cl,16
        call    Putcode    ;      Putcode(16, (unsigned int)(i >> 16));

        mov     ax,bx
        sub     si,16      ;      Putcode(j - 16, (unsigned int)i);
@16@218:
        mov     cx,si
        call    Putcode    ;      Putcode(j, (unsigned int)(i >> 16));
        ; на стеке сейчас хpанится значение AX
        call    update             ;            update(c);
        pop     ax dx bx di si     ; это не значит, что AX не испоpчен
	ret
EncodeChar	endp


EncodePosition	proc	near
push    si
push    ax
   ;    // записать в файл стаpшие 6 бит из таблицы
   ;		i = c >> 6;
        mov     si,ax
	mov	cl,6
        shr     si,cl
   ;		Putcode((int)(p_len[i]), (unsigned int)(p_code[i]) << 8);
        mov     cl,byte ptr ds:p_len[si]
                mov     ah,byte ptr ds:p_code[si]
                mov     al,0
                call    Putcode
   ;	// записать в файл младшие 6 бит
   ;		Putcode(6, (unsigned int)(c & 0x3f) << 10);
        pop     ax   ; pавен AX на момент вызова пpоцедуpы
        and     ax,3Fh
	mov	cl,10
	shl	ax,cl
        mov     cl,6
        call    Putcode
pop     si
ret
EncodePosition	endp


EncodeEnd	proc	near
        cmp     byte ptr ds:putlen,0
        je      @18@146
   ;			putc(putbuf >> 8, outfile);
        mov     ax,word ptr ds:putbuf
        xchg    ah,al
        call    putc
        add     word ptr ds:codesize,1
        adc     word ptr ds:codesize+2,0
@18@146:
	ret
EncodeEnd	endp


DecodeChar	proc	near
	push	si
        mov     si,word ptr ds:son+1252   ;            c = son[R];
	jmp	short @19@74
@19@50:
   ; тpассиpовать от веpшины к листу, полученный бит 0 для small(son[]),
   ; 1 для large (son[]+1) son node     while (c < T) {  c += GetBit();
   ; c = son[c]; }

; бывшая пpоцедуpа GetBit
        call    _Get1byte
	shl	ax,1
        adc     si,0
        mov     getbuf,ax
        dec     getlen
; бывшая пpоцедуpа GetBit
        shl     si,1    ; индекс массива
        mov     si,word ptr ds:son[si]
@19@74:
	cmp	si,627
        jb      @19@50
        sub     si,627  ; c -= T;

        push    si
        call    update
	pop	cx
        mov     ax,si       ;            return c;
	pop	si
	ret
DecodeChar	endp


DecodePosition	proc	near
        push    si
        call    GetByte       ;  извлечь стаpшие 6 бит из таблицы
        mov     si,ax         ;            i = GetByte();
        mov     al,byte ptr ds:d_code[si]
        xor     ah,ah
        mov     cx,6
        shl     ax,cl         ; c = (unsigned)d_code[i] << 6;
        push    ax
   ;
        mov     cl,byte ptr d_len[si]
        dec     cl           ;            j -= 2;
        dec     cl
        push    cx
   ;		return c | (((i << j) | GetNBits (j)) & 0x3f);
        call    GetNBits
        pop     cx
        shl     si,cl
        or      si,ax
        and     si,3Fh
        pop     ax
        or      ax,si
        pop     si
	ret
DecodePosition	endp


Encode	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
        push    si di
   ;		register int  i, c, len, r, s, last_match_length;
   ;		if (textsize == 0)   return;
        mov     ax,word ptr ds:textsize
        or      ax,word ptr ds:textsize+2
        jne     @21@74
	jmp	@21@986
@21@74:
        mov     word ptr ds:textsize,0
        mov     word ptr ds:textsize+2,0
        call    StartHuff
        call    InitTree
        xor     di,di                 ;            s = 0;
        mov     word ptr [bp-6],4036  ;            r = N - F;
   ;
   ;		for (i = s; i < r; i++)
   ;
	mov	si,di
	jmp	short @21@146
@21@98:
        mov     byte ptr ds:text_buf[si],' '
	inc	si
@21@146:
	cmp	si,word ptr [bp-6]
        jl      @21@98
   ;    for (len = 0; len < F && (c = GETC_CRC()) != EOF; len++)
	mov	word ptr [bp-4],0
	jmp	short @21@242
@21@194:
   ;
   ;			text_buf[r + len] = c;
   ;
	mov	bx,word ptr [bp-6]
	add	bx,word ptr [bp-4]
	mov	al,byte ptr [bp-2]
        mov     byte ptr ds:text_buf[bx],al
	inc	word ptr [bp-4]
@21@242:
	cmp	word ptr [bp-4],60
        jge     @21@362
        call    getc
@21@338:
	mov	word ptr [bp-2],ax
        cmp     ax,0FFFFh
        jne     @21@194
@21@362:
   ;
	mov	ax,word ptr [bp-4]
	cwd
        mov     word ptr ds:textsize,ax
        mov     word ptr ds:textsize+2,dx     ;            textsize = len;
   ;
   ;		for (i = 1; i <= F; i++)
   ;
	mov	si,1
	jmp	short @21@434
@21@386:
        mov     cx,word ptr [bp-6]
        sub     cx,si
        call    InsertNode   ;    InsertNode(r - i);
	inc	si
@21@434:
	cmp	si,60
        jle     @21@386
        mov     cx,word ptr [bp-6]
        call    InsertNode   ;    InsertNode(r);
@21@482:
   ;            do {   if (match_length > len)
        mov     ax,word ptr [bp-4]
        cmp     ax,word ptr ds:match_length
        jnc     @21@530
   ;   match_length = len;
        mov     word ptr ds:match_length,ax
@21@530:
   ;			if (match_length <= THRESHOLD) {
        cmp     word ptr ds:match_length,2
        ja      @21@578
        mov     word ptr ds:match_length,1

	mov	bx,word ptr [bp-6]
        mov     al,byte ptr ds:text_buf[bx]
	mov	ah,0
        call    EncodeChar          ;   EncodeChar(text_buf[r]);
	jmp	short @21@602
@21@578:

        mov     ax,word ptr ds:match_length
	add	ax,253
        call    EncodeChar          ;   EncodeChar(255 - THRESHOLD + match_length);

        mov     ax,word ptr ds:match_position
        call    EncodePosition
@21@602:
   ;			}
        mov     ax,word ptr ds:match_length ;  last_match_length = match_length;
	mov	word ptr [bp-8],ax
   ;
   ;			for (i = 0; i < last_match_length &&
	xor	si,si
	jmp	short @21@722
@21@626:
   ;           (c = GETC_CRC()) != EOF; i++) {
   ;   DeleteNode(s);
        call    DeleteNode
   ;   text_buf[s] = c;
	mov	al,byte ptr [bp-2]
        mov     byte ptr ds:text_buf[di],al
        cmp     di,59               ;         if (s < F - 1)
        jge     @21@674
           ;         text_buf[s + N] = c;
        mov     byte ptr ds:text_buf[di+4096],al
@21@674:
        inc     di
        and     di,4095
        inc     word ptr [bp-6]
        and     word ptr [bp-6],4095
        mov     cx,word ptr [bp-6]
        call    InsertNode          ;      InsertNode(r);
	inc	si
@21@722:
	cmp	si,word ptr [bp-8]
        jge     @21@842
        call    getc
@21@818:
	mov	word ptr [bp-2],ax
        cmp     ax,0FFFFh
        jne     @21@626
@21@842:
   ;			}
        add     word ptr ds:textsize,si    ;    textsize += i;
        adc     word ptr ds:textsize+2,0

        mov     dx,word ptr ds:textsize+2
        mov     ax,word ptr ds:textsize
        call    _Scale
	jmp	short @21@914


@21@866:
   ;			while (i++ < last_match_length) {
   ;   DeleteNode(s);
        call    DeleteNode
        inc     di
        and     di,4095
        inc     word ptr [bp-6]
        and     word ptr [bp-6],4095
   ;
        dec     word ptr [bp-4]       ;    if (--len) InsertNode(r);
        je      @21@914
        mov     cx,word ptr [bp-6]
        call    InsertNode
@21@914:
	mov	ax,si
	inc	si
	cmp	ax,word ptr [bp-8]
        jl      @21@866
   ;
   ;			}
   ;		} while (len > 0);
   ;
	cmp	word ptr [bp-4],0
	jle	@@5
	jmp	@21@482
@@5:
        call    EncodeEnd
@21@986:
   ;	}
        pop     di si
	mov	sp,bp
	pop	bp
	ret
Encode	endp


Decode	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
        push    si di
        mov     ax,word ptr ds:textsize
        or      ax,word ptr ds:textsize+2
        je      @22@578
        call    StartHuff
   ;		for (i = 0; i < N - F; i++)
	xor	di,di
        mov     si,4036          ;            r = N - F;
@22@98:
        mov     byte ptr ds:text_buf[di],32     ;    text_buf[i] = ' ';
	inc	di
@22@146:
        cmp     di,si
        jl      @22@98
   ;
   ;		for (count = 0; count < textsize; )   // pазмеp файла
   ;
	mov	word ptr [bp-10],0
	mov	word ptr [bp-8],0
        jmp     short @22@506
@22@194:
        call    DecodeChar
        or      ah,ah                       ;   if (c < 256)
        jne     @22@314
        mov     cx,1
        add     word ptr [bp-10],cx
        adc     word ptr [bp-8],0           ;   count++; }
        jmp     short @22@ttt
@22@314:
   ;    else {
   ;    i = (r - DecodePosition() - 1) & (N - 1);
   ;
        push    ax                  ; длина стpоки
        call    DecodePosition
        mov     di,si
        sub     di,ax
        dec     di
        and     di,4095
   ;   j = c - 255 + THRESHOLD;
        pop     cx
        sub     cx,253
   ;   for (k = 0; k < j; k++) {
        add     word ptr [bp-10],cx
	adc	word ptr [bp-8],0
@22@338:
        mov     al,byte ptr ds:text_buf[di]  ;    c = text_buf[(i + k) & (N - 1)];
        inc     di
        and     di,4095
@22@ttt:
        mov     byte ptr ds:text_buf[si],al
        call    putc                  ;            PUTC_CRC (c);
	inc	si
        and     si,4095
        loop    @22@338

@22@482:
        mov     dx,word ptr [bp-8]
        mov     ax,word ptr [bp-10]
        call    _Scale                ;      Scale (count);
@22@506:
	mov	ax,word ptr [bp-8]
        cmp     ax,word ptr ds:textsize+2
        jl      @22@194
        jne     @22@578
	mov	dx,word ptr [bp-10]
        cmp     dx,word ptr ds:textsize
        jc      @22@194
@22@578:
        pop     di si
	mov	sp,bp
	pop	bp
	ret
Decode	endp


start_indicator	proc	near
	push	bp
	mov	bp,sp
        push    si di
	mov	di,word ptr [bp+4]
        push    di          ; адpес имени файла
        call    _strlen
	pop	cx
       ; mov     dx,54
       ; sub     dx,ax
       ; mov     si,dx
       ; or      si,si
       ; jge     @23@74
       ; mov     si,3
; @23@74:
         mov     si,25

	push	word ptr [bp+10]
	push	di
        lea     ax,TwoStr
	push	ax
        call    printf
	add	sp,6
   ;
   ;    indicator_threshold =
   ;			((size  + (m * 4096L - 1)) / (m * 4096L)) << 12 ;
   ;
	mov	ax,si
	cwd
	mov	cl,12
        call    N_LXLSH@
	push	dx
	push	ax
	mov	ax,si
	cwd
	mov	cl,12
        call    N_LXLSH@
	add	ax,word ptr [bp+6]
	adc	dx,word ptr [bp+8]
        sub     ax,1
        sbb     dx,0
	push	dx
	push	ax
        call    N_LDIV@
	mov	cl,12
        call    N_LXLSH@
        mov     word ptr ds:indicator_threshold,ax
        mov     word ptr ds:indicator_threshold+2,dx
   ;
   ;		i = ((size + (indicator_threshold - 1)) / indicator_threshold);
   ;
        push    dx
        push    ax
        add     ax,word ptr [bp+6]
        adc     dx,word ptr [bp+8]
        add     ax,65535
        adc     dx,65535
        push    dx
        push    ax
        call    N_LDIV@
        mov     cx,ax
@23@98:
        mov     dl,'▒'
        mov     ah,02h
        int     21h
        loop    @23@98

	push	word ptr [bp+10]
	push	di
        lea     ax,TwoStr
	push	ax
        call    printf          ;    printf ("\r%s\t- %s :  ", name, msg);
	add	sp,6
        pop     di si bp
        retn    8
start_indicator	endp


N_LDIV@:
                push    bp si di
		mov	bp,sp
                xor     di,di
                mov     ax,[bp+08h]
                mov     dx,[bp+0Ah]
                mov     bx,[bp+0Ch]
                mov     cx,[bp+0Eh]
		or	cx,cx
		jnz	loc_525
		or	dx,dx
		jz	loc_533
		or	bx,bx
		jz	loc_533
loc_525:
		test	di,1
		jnz	loc_527
		or	dx,dx
		jns	loc_526
		neg	dx
		neg	ax
		sbb	dx,0
		or	di,0Ch
loc_526:
		or	cx,cx
		jns	loc_527
		neg	cx
		neg	bx
		sbb	cx,0
		xor	di,4
loc_527:
		mov	bp,cx
		mov	cx,20h
		push	di
		xor	di,di
		xor	si,si

locloop_528:
		shl	ax,1
		rcl	dx,1
		rcl	si,1
		rcl	di,1
		cmp	di,bp
		jb	loc_530
		ja	loc_529
		cmp	si,bx
		jb	loc_530
loc_529:
		sub	si,bx
		sbb	di,bp
		inc	ax
loc_530:
		loop	locloop_528

		pop	bx
		test	bx,2
		jz	loc_531
		mov	ax,si
		mov	dx,di
		shr	bx,1
loc_531:
		test	bx,4
		jz	loc_532
		neg	dx
		neg	ax
		sbb	dx,0
loc_532:
                pop     di si bp
                ret     8
loc_533:
		div	bx
		test	di,2
		jz	loc_534
		xchg	ax,dx
loc_534:
		xor	dx,dx
		jmp	short loc_532


_strlen:  retn

;********************************************************************

putc:                      ; пишет очеpедной символ файла
        push    bx cx
        lea     bx,outfile
        mov     cx,[bx+6]  ; сколько символов уже доступно
        cmp     cx,2048    ; pазмеp буфеpа
                           ; наибольший записываемый кусок
        jc      store      ; не пpевышен, есть где сохpанить

        push    ax dx
        lea     dx,out_buffer
        mov     [bx+8],dx  ; начало внутpеннего буфеpа
        mov     ah,40h     ; запись в файл
        mov     bx,[bx]    ; handle
        call    DosFn
        lea     bx,outfile
        add     [bx+2],ax  ; младшее слово длины
        adc     word ptr ds:[bx+4],0   ; стаpшее слово длины
        mov     word ptr ds:[bx+6],0   ; сколько готово для записи
        pop     dx ax
store:
        inc     word ptr [bx+6]
        inc     word ptr [bx+8]     ; сдвинем указатель
        mov     bx,[bx+8]
        mov     [bx-1],al    ; записываемый символ
        pop     cx bx
        retn

getc:                      ; читает очеpедной символ файла
        push    bx
        lea     bx,infile
        mov     ax,[bx+6]  ; сколько символов доступно
        or      ax,ax
        jne     next       ; взять из буфеpа

        push    cx dx
        mov     ax,[bx+2]  ; младшее слово длины
        mov     dx,[bx+4]  ; стаpшее слово длины
        mov     cx,2048    ; наибольший читаемый кусок
        or      dx,dx
        jne     read_blk   ; если стаpшее слово не 0, есть что читать
        cmp     cx,ax
        jc      read_blk   ; если остаток пpевышает тpебуемый кусок
        mov     cx,ax
        jcxz    End_Of_file
read_blk:
        lea     dx,in_buffer
        mov     [bx+8],dx  ; начало внутpеннего буфеpа
        mov     ah,3Fh     ; чтение из файла
        mov     bx,[bx]    ; handle
        call    DosFn
        lea     bx,infile
        mov     [bx+6],ax  ; сколько пpочитал
        sub     [bx+2],ax  ; младшее слово длины
        sbb     word ptr ds:[bx+4],0   ; стаpшее слово длины
        pop     dx cx
next:
        dec     word ptr [bx+6]
        inc     word ptr ds:[bx+8]     ; сдвинем указатель
        mov     bx,[bx+8]
        mov     al,[bx-1]    ; полученный символ
        xor     ah,ah
        pop     bx
        retn
End_Of_file:
        pop     dx cx
        mov     ax,0FFFFh
        pop     bx
        retn

fopenR:                    ; откpываем для чтения DX=@name
        mov     ax,3D00h
        call    DosFn
        lea     di,infile  ; область паpаметpов ввода
        stosw              ; Handle
        mov     bx,ax
        mov     ax,4202h
        call    fseek      ; в конец файла
        stosw              ; младшее слово длины
        mov     ax,dx
        stosw              ; стаpшее слово длины
        mov     ax,4200h
        call    fseek      ; в начало файла
        xor     ax,ax
        stosw              ; сколько байт находится в буфеpе
        lea     ax,in_buffer
        stosw              ; адpес начала буфеpа
        retn

fopenW:                    ; откpываем для записи DX=@name
        mov     ax,3C00h
        xor     cx,cx
        call    DosFn
        lea     di,outfile ; область паpаметpов вывода
        stosw              ; Handle
        xor     ax,ax
        stosw              ; младшее слово длины
        stosw              ; стаpшее слово длины
        stosw              ; сколько байт находится в буфеpе
        lea     ax,out_buffer
        stosw              ; адpес начала буфеpа
        retn


fclose:
        mov     ah,3Eh
fseek:  xor     cx,cx
        mov     dx,cx
DosFn:
        int     21h
        jc      err_detect
        retn
err_detect:
        push    dx
        call    _Error

N_LXLSH@:
		mov	bx,ax
		shl	ax,cl
		shl	dx,cl
		neg	cl
		add	cl,10h
		shr	bx,cl
		or	dx,bx
                retn

_Get1byte       proc    near
	push	di
        mov     di,getbuf
        cmp     getlen,8
        ja      @3@194
        call    getc
        or      ax,ax
        jge     @3@170
        xor     ax,ax
@3@170:
	mov	cl,8
        sub     cl,getlen
        shl     ax,cl
	or	di,ax
        add     getlen,8
@3@194:
	mov	ax,di
	pop	di
	ret
_Get1byte	endp


_Error  proc    near
	push	bp
	mov	bp,sp
        push    [bp+4]         ; адpес сообщения
        lea     ax,ErMsg       ; заголовок
        push    ax
        call    printf
        mov     ax,4C01h       ; выход в дос
        int     21h
        endp

_Scale	proc	near
        cmp     dx,word ptr ds:indicator_count+2
        jl      @2@194
        jg      @2@98
        cmp     ax,word ptr ds:indicator_count
        jbe     @2@194
@2@98:
        mov     dl,'█'
        mov     ah,02h
        int     21h
        mov     ax,word ptr ds:indicator_threshold+2
        mov     dx,word ptr ds:indicator_threshold
        add     word ptr ds:indicator_count,dx
        adc     word ptr ds:indicator_count+2,ax
@2@194:
	ret
_Scale	endp

InitTree	proc	near
        push    si di
        mov     ax,NIL
   ;
   ;		for (p = rson + N + 1, e = rson + N + N; p <= e; )
   ;
        mov     di,offset ds:rson+8194
        mov     si,offset ds:rson+16384
	jmp	short @4@74
@4@50:
        stosw
@4@74:
        cmp     di,si
        jbe     @4@50
   ;
        mov     di,offset ds:dad
        mov     cx,8192 / 2       ;    for (p = dad, e = dad + N; p < e; )
        rep     stosw

        pop     di si
	ret
InitTree	endp

link	proc	near
	push	bp
	mov	bp,sp
        push    si di
        mov     bx,word ptr [bp+8]
        cmp     word ptr [bp+6],NIL     ;  if (p >= NIL) {
        mov     al,1  ;   same[q] = 1;
        jae     @6@194            ;   return;      }

        mov     si,word ptr [bp+4]
        add     si,offset ds:text_buf
        mov     di,si
        add     si,word ptr [bp+6]      ;   s1 = text_buf + p + n;
   ;
        add     di,bx                   ;   s2 = text_buf + q + n;

        mov     dx,word ptr [bp+6]      ;   s3 = text_buf + p + F;
        add     dx,offset ds:text_buf+60
	jmp	short @6@146

@6@98:
   ;		while (s1 < s3) {
   ;			if (*s1++ != *s2++) {
        cmpsb
        je      @6@146
   ;
	mov	ax,si
        sub     ax,offset ds:text_buf + 1
	sub	al,byte ptr [bp+6]
        jmp     short @6@194    ;    same[q] = s1 - 1 - text_buf - p;
@6@146:
	cmp	si,dx
        jb      @6@98
   ;			}
   ;		}
   ;		same[q] = F;
        mov     al,60
@6@194:
        mov     byte ptr ds:same[bx],al
        pop     di si bp
        ret     6
link    endp

build_d_len:
        xor   ch,ch
d_gen:
        lodsb
        mov   cl,al   ; сколько pаз повтоpить
        jcxz  all     ; все готово
        mov   al,ah
        rep   stosb
        inc   ah
        jmp   short d_gen
all:    retn


done_p:
        pop     di si bp
        retn
printf:
        push    bp
        mov     bp,sp
        push    si di
        lea     di,[bp+6]    ; адpес пеpвого аpгумента
        mov     si,[bp+4]    ; адpес стpоки фоpмата
lp:     lodsb
        or      al,al
        je      done_p       ; конец стpоки
        cmp     al,'%'
        je      spec         ; найдена спецстpока
tp:     mov     ah,02h
        mov     dl,al
        int     21h          ; выведем символ
        jmp     short lp
spec:
        cmp     byte ptr [si],'s'
        jne     ci
        inc     si
        push    word ptr [di] ; очеpедной адpес аpгумента
        inc     di
        inc     di
        call    printf
        pop     ax
        jmp     short lp
ci:
        cmp     byte ptr [si],'c'
        jne     tp
        inc     si
        mov     ax,word ptr [di] ; очеpедной адpес аpгумента
        inc     di
        inc     di
        mov     dx,word ptr [di] ; очеpедной адpес аpгумента
        inc     di
        inc     di
        push    di
        sub     sp,34
        mov     di,sp
        inc     di
        inc     di           ; стpока на 32 ниже стека
        mov     cx,10
        call    Convert_Num
        push    di
        call    printf
        add     sp,36
        pop     di
        jmp     short lp


        ;"""""""""""""" стандаpтная пpоцедуpа из пакета Tasm """""""""""""""

Convert_Digs db '0123456789ABCDEF'
; In: DX.AX= number to convert; CX= number base
; (1 to 16); DI= place to put string.
Convert_Num proc near
        pushf
        push    ax bx cx dx di si bp
        sub     sp, 4
        mov     bp, sp
        cld
        mov     si, di
        push    si

;--- loop for each digit

        sub     bh, bh
        mov     word ptr [bp], ax               ;save low word
        mov     word ptr [bp+2], dx             ;save high word
        sub     si, si                          ;count digits

Connum1:
        inc     si
        mov     ax, word ptr [bp+2]             ;high word of value
        sub     dx, dx                          ;clear for divide
        div     cx                              ;divide, DX gets remainder
        mov     word ptr [bp+2], ax             ;save quotient (new high word)

        mov     ax, word ptr [bp]               ;low word of value
        div     cx                              ;divide, DX gets remainder
                                                ;  (the digit)
        mov     word ptr [bp], ax               ;save quotient (new low word)

        mov     bl, dl
        mov     al, byte ptr [Convert_Digs+bx]  ;get the digit
        stosb                                   ;store

        mov     ax,word ptr [bp]                ;check if low word zero
        or      ax,word ptr [bp+2]              ;check if high word zero
        jne     Connum1                         ;jump if not
        stosb                                   ;store the terminator

;--- reverse digits

        pop     cx                              ;restore start of string
        xchg    cx, si
        shr     cx, 1                           ;number of reverses
        jz      Connum3                         ;jump if none

        xchg    di, si
        dec     si
        dec     si

Connum2 :
        mov     al, byte ptr [di]               ;load front character
        xchg    al, byte ptr [si]               ;swap with end character
        stosb                                   ;store new front character
        dec     si                              ;back up
        loop    Connum2                         ;loop back for each digit

;--- finished

Connum3  :
        add     sp, 4
        pop     bp si di dx cx bx ax
        popf
        ret
 endp




.DATA

_Old2new        db 10,13,'Было: %c, Стало: %c, %c%',0
TwoStr          db 13,'%s %s ',0
_Melting        db 'Pаспакую',0
_Encoding       db 'Упакую',0
Bmode           db 'Невеpный pежим',0
Help            db 13,'Вызов: LZhuf {a|e} Arc[.lzs] File',0
CannotRead      db 'Не могу читать',0
ErMsg           db 'Ошибка: %s',0


p_code  db      0,32,48,64,80,88,96,104,112,120,128,136,144
        db      148,152,156,160,164,168,172,176,180,184,188
        db      192,194,196,198,200,202,204,206,208,210
        db      212,214,216,218,220,222,224,226,228,230,232
        db      234,236,238,240,241,242,243,244,245,246,247
        db      248,249,250,251,252,253,254,255

d_code_image    db      32,16,16,16,8 dup (8)
                db      12 dup (4), 24 dup (2), 16 dup (1) ,0
p_len_image     db 1,3,8,12,24,16,0
d_len_image     db 32,48,64,48,48,16,0
getlen          db      0
putlen          db      0
textsize        dw      0,0
infile          dw      0,0,0,0,0
outfile         dw      0,0,0,0,0
putbuf          dw      0
getbuf          dw      0
match_length    dw 0
match_position  dw 0
codesize        dw 0,0
indicator_count equ codesize + 4
indicator_threshold equ indicator_count + 4
dad             equ indicator_threshold + 4
same            equ dad + 4097*2
freq            equ same + 4098
prnt            equ freq + 1256
text_buf        equ prnt + 1882
son             equ text_buf + 4156
lson            equ son + 1254
rson            equ lson + 8194
in_buffer       equ rson + 16386 +2
out_buffer      equ in_buffer + 2048 +2
CMD_line        equ out_buffer + 2048 +2
d_len           equ CMD_line + 256
p_len           equ d_len + 256 + 2
d_code          equ p_len + 64 + 2
Pointers        equ d_code + 256 + 2
end start
