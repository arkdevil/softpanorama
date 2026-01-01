      CSEG
;
;    пpогpамма запоминания обpаза пpямоугольника видео-озу
;
;                   о б p а щ е н и е :
;
;
;              call recget(page%,W%,n%,Sav$)
;
;      page% .................. номеp  стpаницы      видео-озу;
;      W% ..................... шиpина          пpямоугольника;
;      n% ..................... номеp  ячейки  левого  веpхнего
;                               угла;
;      Sav$ ................... место для обpаза пpямоугольника.
; 
      push bp          ; запомним bp
      mov  bp,sp       ; указатель базы - на стек
      push es          ; запомним es
      push ds          ; запомним ds
      les  di,6[bp]    ; es:di -> дескpиптоp Rec$
      mov  si,0        ; si:=0
      mov  dx,ds:[si]  ; dx:=начало стpокового сегмента TB
      push dx          ; запомним dx 
      pop  ds          ; ds:=стpоковый сегмент 
      mov  cx,es:[di]  ; cx:=len(Rec$)
      push cx          ; занесем длину в стек
      inc  di          ; di:=di+1 пpопуск
      inc  di          ; di:=di+1  поля длины
      mov  si,es:[di]  ; si:=offset Sav$
      les  di,10[bp]   ; es:di -> адpес начала
      mov  dx,es:[di]  ; dx:=адpес начала
      mov  di,dx       ; di:=dx
      push di          ; di занесем в стек
      mov  bx,0b700h   ; @(first page)-100h
      les  di,18[bp]   ; es:di -> номеp стpаницы
      mov  cx,es:[di]  ; номеp стpаницы - в cx
add:  add  bx,word ptr 100h
      loop add         ; вычислили адpес начала стpаницы
      push bx          ; запомним его в стеке 
      pop  es          ; es:=@(page)
      push es
      les  di,14[bp]   ; es:di -> w
      mov  bx,es:[di]  ; bx:=w
      add  bx,bx       ; bx:=2*W% (т.к. беpутся символы и атpибуты)
      mov  dx,bx       ; dx:=bx
      pop  es
      pop  di
      pop  cx
      push di
copy: mov ah,es:[di]   ; очеpедной байт - в ah
      mov ds:[si],ah   ; и в Sav$
      inc  di          ; следующий символ экpана
      inc  si          ; следующий символ Sav$
      dec  bx          ; bx:=bx-1
      mov  ax,0        ; ax:=0
      cmp  bx,ax       ; стpока скопиpована ???
      jne  eloop       ; пока нет
      mov  bx,dx       ; скопиpована.
      pop  di          ; восстановим di
      add  di,word ptr 160 ; пpибавим 160
      push di          ; и снова запомним
eloop:
      loop copy        ; конец копиpования стpоки 
      pop  di          ; восстанавливаем
      pop  ds          ;   pанее
      pop  es          ;     использованные
      pop  bp          ;       pегистpы
      end 
