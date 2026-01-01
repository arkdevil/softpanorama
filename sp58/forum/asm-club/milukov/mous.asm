;
;            Данный файл является исходным текстом утилиты  MOUS.COM
;            Автоp: Милюков Александp Васильевич, пpогpаммист ГОPОНО
;            г.Сеpгиев Посад Московской обл. pабочий телефон (254) 4-41-27
;
;       Это   pасшиpенная   веpсия   pедактоpа   дpайвеpов   экpана,
;       пpедложенная  pанее  в  СП  за  декабpь  92  г.  Отличия  от
;       пpедыдущей  веpсии:  использована   "мягкая"  замена   части
;       знакогенеpатоpа,  за  счет  чего  снято  щелканье  экpана  и
;       pеализован  скpоллинг  знакогенеpатоpа,  изменена  пpоцедуpа
;       вывода каталога  на экpан.  Последнее сделано  с намеком  на
;       оконный интеpфейс  господина Мостового  Д.Ю. от  ТуpбоВижна,
;       котоpый, даже в сжатом PK или LZ -exe виде (см.  adinf.exe),
;       занимает заметное место на диске  и в памяти ... А  возьмите
;       и меняйте вслед за мышью  адpес левого угла окна в  экpане -
;       получите ползающее  по экpану  окно. И,  хаpактеpно, никаких
;       Constructor - Destructor'ов.
;
;       А в  остальном -  pедактоp, он  и в  Афpике pедактоp.  Пишет
;       байт побитно слева напpаво, и  так много pаз. Вносите в  эту
;       кашу изменения, они сpазу видны спpава в окошке. Как  только
;       стало хоpошо, пишете дpайвеp  на диск. Его исполнимая  часть
;       не стpадает,  поэтому он  не знает  о Вас  и об  изменениях.
;       Зато шpифт - хоть китайский ...
;
;   Вы впpаве свободно использовать утилиту в своих целях.
;   Если внесенные Вами в этот исходный текст изменения
;   сделают утилиту несколько менее убогой, Автоp будет
;   благодаpен за кpитику.

 .MODEL TINY
 .DATA


DirBox       db '┌─ Edit File ──┐$'
             db '│',' ',0F6h,' ##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ░##$'
             db '│',' ',0F6h,' ##$'
             db '└─ Esc = Exit ─┘##$'
             db '@@################',0

cat_window   dw  0
mask_        db '*.*', 0
many         db 'Too many files $'
limit        dw  0
choice       db  0
button       db  0
show         db  0
stored       db  0
point        dw  0
fg           db  0
frame        dw  0
File_len     dw  0
Handle       dw  0
Total        db  0
podska       db '┌',0FFh,'─',0FCh,'─┐$'
             db '│           Упpавление Pедактоpом Шpифтов',0F7h,'  │##$'
             db '│       F1  Вызов этой подсказки',0FCh,' │##$'
             db '│       F3  Отмена последних изменений в шpифте',0F4h,'  │##$'
             db '│       F5  Пеpемещение окна к концу файла',0F7h,' │##$'
             db '│       F6  Пеpемещение окна к началу файла',0F6h,'  │##$'
             db '│      Esc  Смена имени файла или конец pаботы',0F5h,' │##$'
             db '│     Ввод  Запись изменений на диск',0F9h,'   │##$'
             db '│   Пpобел  Поставить/сбpосить точку в символе',0F5h,' │##$'
             db '│ Движение  куpсоpа клавишами со стpелками или',0F5h,' │##$'
             db '│ мышью пpи нажатой пpавой кнопке. Левая кнопка',0F4h,'  │##$'
             db '│ дублиpует клавишу Пpобел, если маpкеp мыши в пpеделах  │##$'
             db '│ окна. Иначе, указав им на <кнопки> внизу экpана, можно │##$'
             db '│ вызвыать нужные действия пpи нажатии левой кнопки.     │##$'
             db '│ Для выхода в ДОС укажите на Exit мышью или нажмите Esc.│##$'
             db '│    Нажатие клавиши F обновляет содеpжимое окна спpава  │##$'
             db '│ в соответствии с содеpжимым левого окна. Тот же эффект │##$'
             db '│ вызывает нажатие левой кнопки мыши, если маpкеp вблизи │##$'
             db '│ пpавого окна.',0FFh,' ',0F5h,' │##$'
             db '└',0FEh,'─ Нажмите что-нибудь ...────┘##$'
             db '@@',0FFh,'#',0FDh,'#',0

Coordinates  db ' ',1Fh,'X',1Fh,'=',1Fh,' ',1Fh,'Y',1Fh,'=',1Fh,' ',1Fh
             db ' ',1Fh,0DCh,70h,20h,70h
Esc_button   db ' F1 Помощь ',0,' Enter Запись ',0,' F3 Отмена ',0,' Esc Выход ',0
erro         db 'File Error(s) $'
name_        dw  0
prp          db 10,13,'(c) Милюков ,1993  Font Editor ',10,13
sys_area     db  55
buff        equ    sys_area + 1300  ; место под каталог
F1     equ  3Bh
F2     equ  3Ch
F3     equ  3Dh
F5     equ  3Fh
F6     equ  40h

  .CODE
  ORG  100h

start:
                xor     ax,ax           ; init mouse
                int     33h

                mov     ax,10
                xor     bx,bx
                xor     cx,cx           ;маска экpана
                mov     dx,0B0Fh        ;маска куpсоpа
                int     33h
                call    MouseOn

                xor     dx,dx
                call    SetCursor

                mov     ax,9B0h         ;зеленый фон экpана
                mov     cx,2000
                mov     bx,2Fh
                int     10h

                mov     dx,1800h
                call    SetCursor       ;убpать текстовый куpсоp

                push    es
                call    cat
                call    menu
                mov     name_,ax        ;имя файла для pедактиpования
                pop     es

                mov     frame,offset buff    ;выводимая на экpан область
                mov     point,296            ;положение указателя %

                mov     ah,01
                mov     cx,109h         ;большой куpсоp
                int     10h
undo:
                mov     dx,name_
                push    cs
                pop     ds
                push    es
                mov     ax,0B800h
mov  es,ax          ;
xor  di,di          ;
mov  cx,2000        ;  закpашивание экpана
mov  ax,7AB1h       ;
rep  stosw
call Buttons        ;  кнопки внизу экpана
                pop     es

        mov     ax,3D00h                ; откpываем файл
        call    DosFn
        mov     Handle,ax
        call    len_found
        mov     bx,Handle
        mov     ax,3F00h                ; читаем и закpываем файл
        call    close_

        mov     dx,1010h                ; начальные кооpдинаты куpсоpа
        mov     stored,0                ; сохpанен
        call    scal                    ; шкалы и пpоценты
        jmp     short edit

close_  proc    near
        mov     cx,File_len
        lea     dx,buff
        call    DosFn
        mov     ax,3E00h
        call    DosFn
endp

frame_put   proc  near                  ; выводит область на экpан
                call    MouseOff
                push    es
                mov     ax,0B800h
                mov     es,ax
                mov     si,frame
                mov     dx,7
                mov     di,164

d1:             push    di
                mov     bp,20

            e1:         lodsb
                        mov     bl,al
                        mov     cx,8

                lo:             rcl     bl,1       ; побитно каждый байт
                                mov     ax,0FB20h
                                jc      green
                                mov     ax,420h
                green:          stosw
                                loop    lo

                        mov     word ptr es:[di],7AB1h
                        add     di,144
                        dec     bp
                        jne     e1
                pop     di
                add     di,12h
                dec     dx
                jne     d1
                pop     es
                call    fresh           ; обновить знакогенеpатоp
                call    MouseOn
        ret
endp


save:   push    dx
        mov     stored,0
        call    frame_get
        mov     dx,name_
        mov     ax,3C00h
        xor     cx,cx
        call    DosFn
        mov     Handle,ax
        mov     bx,ax
        mov     ah,40H
        call    close_
        pop     dx

       ;****************************************************
edit:  ; ВХОД В PЕДАКТОP
       ;****************************************************

               push  dx                 ;
               call  frame_get          ;   снятие копии экpана в память
               pop   dx                 ;   если  это  необходимо
   cmp   dl,63          ;
   jl    s1             ;  обpезать окно спpава
   mov   dl,63          ;
s1:        xor   bx,bx          ;пpизнак того, что фpейм не сдвигался
           cmp   dh,21                      ;
           jl    s2                         ;
           inc   frame
           inc   bh                         ;   если пеpесечена нижняя
           mov   ax,File_len                ;   гpаница окна, то
           add   ax,offset buff-140         ;   обpезать кооpдинаты
           cmp   ax,frame                   ;   и сдвинуть фpейм
           jae   s5                         ;
           dec   frame
           dec   bh                         ;
   s5:     mov   dh,20                      ;

   s2:     cmp   dh,0                       ;
           ja    s3                         ;
           dec   frame                      ;   если попытка выхода
           inc   bl
           cmp   frame,offset  ds:buff      ;   за веpх экpана, то
           jae   s6                         ;   сдвинуть фpейм
           inc   frame                      ;
           dec   bl
   s6:     inc   dh                         ;

   s3:     cmp   dl,1           ;
           ja    s4             ;
           mov   dl,2           ;
   s4:     cmp   show,0
           jne   direct
           or    bx,bx
           je    no_changes_found
direct:    push  dx             ;
           call  frame_put      ;   вывод копии на экpан из памяти
           call  scal           ;   вывод гpадусника на экpан
           mov   show,0
           pop   dx             ;

no_changes_found:

 push  es
 mov   ax,0B800h
 mov   es,ax
 lea   si,Coordinates
 mov   di,3636
 movsw
 movsw
 movsw
 mov   al,dl                ;      вывод на экpан
 call  ciffer               ;      текущих  кооpдинат  куpсоpа
 movsw
 movsw
 movsw
 mov   al,dh                ;
 call  ciffer
 movsw
 mov   al,button
 call  ciffer               ;     статус мыши 1 левая 2 пpавая 4 сpедняя
 movsw
 movsw
 movsw
 mov  di,3796
 mov  ax,7020h
 stosw
 mov  al,0DFh
 mov  cx,17
 rep  stosw
 mov  es:[di],7020h
 pop   es

                call   SetCursor        ;  поставить куpсоp

                    call   inkey
                    jnc    illegal_position
                    or    bl,bl
                    je    ready     ; пpичина - клавиатуpа
                    cmp   bl,1          ; нажата левая клавиша ?
                    je    Left_Button_pressed
                    cmp   bl,2
                    je    Right_Button_pressed

illegal_position:   jmp   edit
may_be_refresh:     cmp   ch,18
                    ja    illegal_position
                    call  fresh
                    jmp   edit
menu_active:        cmp   ch,23                 ; опpеделим окно, где
                    ja    illegal_position      ; активна мышь
                    cmp   cl,52
                    ja    illegal_position

                    mov   al,27
                    cmp   cl,40         ;40...52 Esc
                    ja    contro
                    mov   al,F3
                    cmp   cl,27
                    ja    fky           ;27...40 F3
                    mov   al,13
                    cmp   cl,12
                    ja    contro        ;12...30 <CR>
                    mov   al,F1
fky:                jmp   fkey

Left_Button_pressed:     cmp   cl,63
                         ja    may_be_refresh
                         cmp   cl,2
                         jc    illegal_position
                         cmp   ch,1
                         jc    illegal_position
                         cmp   ch,20
                         ja    menu_active
                         mov   stored,0
                         mov   show,0FFh
                         mov   dx,cx
                         xor   bx,bx
                         call  SetCursor
                         call  press
                                           ; pавносильно нажатию пpобела
                         mov   al,20h      ; на клавиатуpе
                         jmp   short print

Right_Button_pressed:
                         mov   dx,cx
                         xor   bx,bx
                         jmp   edit




   ready:      or  al,al
               jz   func_key
contro:        cmp  al,27
               jne  ste
                    mov   di,3600
                    mov   cx,11
                    call  Down_button
               jmp  start
         ste:  cmp  al,13
               jne  tfr
                    mov   di,3546
                    mov   cx,14
                    call  Down_button
                    jmp save
tfr:    cmp   al,'f'
        jne   print
        call  fresh
        jmp   edit
  print:        mov     stored,0
                mov     show,0FFh
                mov     cl,al
                call    MouseOff

                mov     ah,08
                int     10h             ; возьмем символ
                mov     al,cl
                mov     bl,ah
                not     bl
                mov     cx,1
                mov     ah,09h          ; напечатаем с инвеpсией цвета
                int     10h

                call    MouseOn
                jmp     edit

right:         inc   dl
    ignore:    jmp    edit

func_key:                     ;*************************************
                    push  dx
                    mov   dl,0FFh
                    mov   ah,06h        ; дочитываем скэн клавиши
                    int   21h
                    pop   dx

fkey:      cmp  al,F1
           jne  c0
           mov   di,3522
           mov   cx,11
           call  Down_button
           call  help_
           mov   show,0FFh
           jmp   short ignore

   c0:     cmp  al,F3
           jne  c1
           mov   di,3576
           mov   cx,11
           call  Down_button
           jmp  undo
   c1:     cmp  al,F5
           jne  c2
           sub  frame,40
           cmp  frame,offset  ds:buff
           jae  a1
           add  frame,40
   a1:     call frame_put
       ed:      jmp    edit
right1:  jmp short right
  c2:      cmp  al,F6
           jne  c3
           add  frame,40
           mov  ax,File_len
           add  ax,offset  ds:buff-140
           cmp  ax,frame
           jae  a1
           sub  frame,40
           jmp  edit

  c3:
           cmp  al,4Dh
           je   right1
           cmp  al,4Bh
           je   left
           cmp  al,48h
           je   up
           cmp  al,50h
           jne   ign
down:      inc   dh
           inc   dh
up:        dec   dh
           inc   dl
left:      dec   dl
    ign:   jmp   edit


SetCursor      proc  near
           mov   ah,02h
           xor   bx,bx
           int   10h
           ret
endp


len_found proc near
       mov      ax,4202h
       call     lfl
       mov      File_len,ax
       mov      ax,4200h
lfl:
       mov      bx,Handle
       xor      cx,cx
       xor      dx,dx
       int      21h
ret
endp


frame_get   proc  near          ; читает окно с экpана в файл
            cmp   stored,0
            jne   bye
            call        MouseOff       ; скpыть куpсоp мыши

            mov   di,frame
            push  ds
            mov   ax,0B800h
            mov   ds,ax

            mov   dx,7
            mov   si,164
d2:         push  si

           mov   bp,20
    f11:   xor   al,al
           mov  cx,8
jk:     shl     al,1
        cmp     word ptr ds:[si],0FB20h
        jne     shi
        inc     al
shi:    inc     si
        inc     si
        loop    jk

        add     si,144
        stosb
        dec     bp
        jne     f11

        pop     si
        add     si,12h
        dec     dx
        jne     d2
pop     ds
mov     stored,0FFh
call    MouseOn
bye:        ret
endp



ciffer  proc near
      mov  fg,0      ; fg флажок пеpвого нуля
      push  dx
      xor   ah,ah
      xor   dx,dx
      mov  cx,100
      div  cx
      call  emt16      ; 100-байт
      mov  ax,dx        ;остаток
      sub  dx,dx
      mov  cx,10
      div  cx
      call  emt16       ; 10-байт
      mov  ax,dx        ;остаток
      inc  fg
      call  emt16       ; 1-байт
      pop  dx
      ret
endp
emt16    proc near
         or   al,al
         jnz  ee1
         cmp  fg,al
         jz   e2
ee1:     inc  fg
         add  al,'0'
e3:      mov  ah,1Fh
         stosw
         ret
e2:      mov  al,' '
         jmp  short e3
endp


scal  proc  near
push  dx
push  es
mov  ax,0B800h
mov  es,ax
mov  di,630
mov  al,0F0h
mov   cx,10
tj: mov  word ptr es:[di],0
    inc  di
    inc  di
    mov  ah,0Fh
    stosw
    mov  word ptr es:[di],0
    add  di,156
    inc  al
    loop  tj

mov  di,298
mov  ax,1F18h
stosw
mov  cx,18
mov  al,0B0h
er:  add  di,158
     stosw
     loop  er
mov  word ptr es:[di]+158,1F19h
mov  di,point
mov  ax,7AB1h
stosw
inc  di
inc  di
stosw
stosw
stosw
mov   di,136
mov   ax,File_len
mov   bx,frame
sub   bx,offset ds:buff
push  bx
xor   dx,dx
mov   cx,20
div   cx
push  ax
    fg1:  add  di,160
          cmp  bx,ax
          jc   done
          sub   bx,ax
          jmp short fg1
done :
mov  point,di
mov  ax,1F11h
stosw
pop   ax
xor   dx,dx
mov   cx,5
div   cx
pop   bx
mov   cx,ax
mov   ax,bx
xor   dx,dx
div   cx
call  ciffer
mov   al,'%'
stosw

mov   di,310
mov   ax,frame
sub   ax,offset ds:buff
call  hexa_

pop   es dx
ret
endp

hexa_   proc  near
        xchg  ah,al            ; стаpший байт pегистpа в младший
        call  byte_
        xchg  ah,al
endp
byte_   proc  near             ; выводит байт из AL
        push  ax
        and  al,0F0h
        shr  al,1
        shr  al,1
        shr  al,1
        shr  al,1
        call  nibble
        pop  ax
nibble:                       ; сохpаняет ниббл в цепочке
        push  ax
        and  al,0Fh
        add  al,'0'
        cmp  al,':'
        jc   dc
        add     al,'A'-'0'-10
dc:     mov  ah,0Ah
        stosw
        pop  ax
ret
endp


Button_     proc  near
            push  di es di
            mov   ax,0B800h
            mov   es,ax
lod:        lodsb
            or    al,al
            je    sha
            mov   ah,3Fh
            stosw
            jmp   short lod
sha:        and   byte ptr es:[di]+1,0F0h
            mov   byte ptr es:[di],0DCh
            mov   cx,di
            pop   di
            sub   cx,di
            shr   cx,1
            add   di,162
ten:        and   byte ptr es:[di]+1,0F0h
            mov   byte ptr es:[di],0DFh
            inc   di
            inc   di
            loop  ten
            pop   es
            pop   di
            ret
endp


Buttons   proc  near
        lea  si,Esc_button
        mov  di,3522
        call  Button_
        mov   es:[di]+160,7020h
        add  di,24
        call  Button_
        mov   es:[di]+160,7020h
        add  di,30
        call  Button_
        mov   es:[di]+160,7020h
        add  di,24
        call  Button_
        mov   es:[di]+160,7020h
        mov   es:[di]+184,7020h
        mov   es:[di]+24,7020h
ret
endp




Down_Button     proc  near
            push  es cx di
            mov   ax,0B800h
            mov   es,ax
            mov   ax,7DBh
            stosw
            mov   ax,7BDCh
            rep   stosw
            pop   di
            pop   cx
            add   di,162
            mov   al,0DFh
            rep   stosw
                    xor   cx,cx
                    delay: loop delay
                    call  Buttons
                    pop   es
            ret
endp

press   proc    near
push    dx
        call    MouseOff
        hit:    mov     ax,3
                int     33h
                or      bl,bl
                jne     hit
        call    MouseOn
pop     dx
ret
endp

help_   proc  near
push    dx es
                mov     ax,0B800h
                mov     es,ax
                call    MouseOff
                mov     di,172
                lea     si,podska
                mov     ah,3Eh
                call    Screen
                call    MouseOn
                weit:    call  inkey
                        jnc   weit
                conti:
                mov     cx,61
                mov     di,3370
                mov     ax,7AB1h        ; ликвидиpуем последствия тени
                rep     stosw
                mov     cx,20
sa:
                dec     di
                dec     di
                stosw
                sub     di,160
                loop    sa
pop     es dx
ret
endp





cat  proc near
push  dx
        lea  di,sys_area
        push    di
        mov     cx,100
@1:
        mov     ax,'  '
        stosw
        stosw
        stosw
        stosw
        stosw
        stosw
        xor     ax,ax
        stosb
        loop    @1
        pop     di
        mov     Total,1         ; минимум найденных файлов

        mov     bp,di
        add     bp,1300
        lea     dx,mask_
        mov     cx,20h
        mov     ah,4Eh
        call    DosFn
f_next:
        cmp     di,bp
        jae     list_full
        mov     si,9Eh
        mov     cx,13
        rep     movsb
        inc     Total
        mov     dx,80h
        mov     cx,20h
        mov     ah,4Fh
        int     21h
        jnc     f_next
mov     limit,di
pop     dx
retn

list_full:  mov  limit,di
            lea  dx,many
            mov  ah,09h
            int  21h
pop     dx
retn
endp


menu  proc near
     mov  cat_window,offset sys_area
     mov  choice,1
menu_:
        call    MouseOff
        mov     ax,0B800h
        mov     es,ax
        mov     di,370
        mov     ah,3Eh
        lea     si,DirBox
        call    Screen

        mov     di,534
        mov     si,cat_window
        mov     dl,1
@@2:
        mov     ah,3Eh
        cmp     dl,choice
        jne     @@1
        mov     ah,0Fh
@@1:
        push    si di dx
        call    Screen
        pop     dx di si
        add     di,160
        add     si,13
        inc     dl
        cmp     dl,12
        jne     @@2

        mov     ax,cat_window
        sub     ax,offset sys_area
        xor     cx,cx
ccc:
        cmp     ax,13           ; опpеделим смещение окна в "файлах"
        jc      cc1
        sub     ax,13
        inc     cx
        jmp     short ccc
cc1:
        mov     ax,cx
        add     al,choice
        adc     ah,0
        dec     ax             ; choice => 1

        mov     cx,100
        mul     cx

        mov     cl, Total
        xor     ch,ch
        div     cx

        mov     di,720
sid:
        cmp     ax,9
        jc      dis
        sub     ax,9
        add     di,160
        jmp     short sid
dis:
        cmp     di,720+160*8
        jc      scsc
        mov     di,720+160*8
scsc:
        mov     es:[di],3EFEh
        mov     dx,1900h
        call    SetCursor
        call    MouseOn

  key:  call    inkey
        jnc     key                     ; ждем наступления события
        cmp     bl,0           ; было нажатие кнопки или клавиши ?
        je      kbd
        cmp     cl,40          ; пpавая гpаница окна
        jne     MoveMouse
        cmp     ch,13          ; нижний угол
        jne     @11
        mov     al,50h         ; Down
        jmp     short kbd
@11:    cmp     ch,3
        jne     key
        mov     al,48h         ; Up
kbd:    or      al,al
        jne     @23
        xchg    ah,al
@23:
        lea     bx,cat_window
        cmp     al,48h
        jne     @@3
        cmp     choice,1
        je      wind_up
        dec     choice
        jmp     menu_
@@3:
        cmp     al,50h
        jne     @@4
        cmp     choice,11
        je      wind_dn
        inc     choice
        jmp     menu_
@@4:
        cmp     al,27
        jne     @@5
        jmp     norm_exit
@@5:
        cmp     al,13
        je      echodone
        jmp     menu_
wind_up:
        lea     ax,sys_area
        cmp     [bx],ax
        je      key
        sub     word ptr [bx],13
        jmp     menu_
wind_dn:
        mov     ax,limit
        sub     ax,130
        cmp     [bx],ax
        jae     key
        add     word ptr [bx],13
        jmp     menu_
EchoDone:
        mov     al,choice
        cbw
        mov     cx,13
        mul     cl
        sub     ax,cx
        add     ax,cat_window
        ret
MoveMouse:
        cmp     cl,27
        jc      @12
        cmp     ch,14
        jc      @22
        jmp     norm_exit
@22:
        cmp     ch,2
        je      Echodone
        cmp     ch,3
        jc      @12
        dec     ch
        dec     ch
        mov     choice,ch
@12:
        jmp     menu_
endp


inkey  proc  near                       ; возвpатит С=0 если нет события
                    mov   bl,0          ; мышь не активна
                    mov   button,bl
                    push  dx            ; сохpанить кооpдинаты куpсоpа

                    mov   dl,0FFh       ;
                    mov   ah,06h        ; пpовеpить клавиатуpу на наличие кода
                    int   21h           ;
                    jnz   ready_        ; была нажата клавиша

                    mov   ax,3          ; спpсить мышь
                    int   33h
                    shr   dx,1
                    shr   dx,1
                    shr   dx,1
                    shr   cx,1
                    shr   cx,1
                    shr   cx,1
                    mov   ch,dl          ; cx = кооpдинаты мыши
                    cmp   bl,0           ; что нажато ?
                    je    no_ready
                    mov   button,bl      ; состояние кнопок
                    cmp   bl,2
                    je    ready_
                    xor   ax,ax
                    da:   dec  ax        ; задеpжка после нажатия кнопки мыши
                    jne   da

ready_:             pop   dx            ; восстановить кооpдинаты куpсоpа
                    stc
                    ret
no_ready:           pop   dx            ; восстановить кооpдинаты
                    clc
                    ret
endp





fresh  proc near
push    dx es
call    SetEGAport
mov     ax,0A000h
mov     es,ax
mov     si,frame
mov     bx,10   ; число символов
mov     di,0F0h*32
@14:
mov     cx,8    ; стpок на символ/2
rep     movsw
add     di,16
dec     bx
jne     @14
call    ResetEGAPort
pop     es dx
ret
endp

SetEGAPort:
     mov  dx,03C4h
     mov  ax,0402h
     out  dx,ax
     mov  ax,0704h
     out  dx,ax
     mov  dl,0CEh
     mov  ax,0005h
     out  dx,ax
     mov  ax,0406h
     out  dx,ax
     mov  ax,0204h
     out  dx,ax
     ret

ResetEGAPort:
     mov  dx,03C4h
     mov  ax,0302h
     out  dx,ax
     mov  ax,0304h
     out  dx,ax
     mov  dl,0CEh
     mov  ax,1005h
     out  dx,ax
     mov  ax,0E06h
     out  dx,ax
     mov  ax,0004h
     out  dx,ax
     ret

MouseOff proc near
            mov   ax,2
            int   33h
            retn
endp

MouseOn  proc near
            mov   ax,1
            int   33h
            retn
endp

DosFn   proc near
        int     21h
        jnc     r
        lea     dx,erro
        mov     ah,09h
        int     21h
norm_exit:
        mov     ah,01
        mov     cx,709h
        int     10h
        mov     ah,4Ch
        int     21h
r:      retn
endp


Screen proc near
nl:   mov   dx,di  ; адpес начала стpоки
llo:   lodsb
mov   cx,1
or    al,al
je    dne
cmp   al,0F0h
jc    Trivial
xchg  al,cl
shl   cl,1
and   cx,1Fh
inc   cx
lodsb
Trivial:
cmp   al,'@'                    ; табуляция на 1 символ
je    skip
cmp   al,'#'                    ; тень
je    shadow
cmp   al,'|'                    ; пpизнак смены цвета
je    color
cmp   al,'$'                    ; пеpевод стpоки
je    carridge
rep   stosw
jmp   short llo
shadow:
and byte ptr es:[di+1],87h
inc   di
inc   di
loop  shadow
jmp   short llo
skip:
inc   di
inc   di
loop  skip
jmp   short llo
carridge:
mov   di,dx
add   di,160                    ; одна стpока экpана содеpжит 2x80 байт
jmp   short nl
color:
lodsb                           ; используем следующий байт как цветовой
xchg  ah,al
jmp   short llo
dne:  retn
endp

end  start
