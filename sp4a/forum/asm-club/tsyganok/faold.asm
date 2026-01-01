title FastAbort
;;
;; * Tsyganok Service * 1992 * Fast Abort *
;;      Ver 1.01
;;
;; It's a COM - file !!!
;;
;; Рабочая версия специально для Soft - Panorama
;;
;; Прошу прощения за качество коментариев.
;;

cod     segment para 'code'
        assume  cs:cod
        org     100h
start:  jmp     load
shiftstat db    4       ;; по умолчанию вызов 'Ctrl'+'='
tmpbuf  dw      512 dup(0) ;; копия векторов
norma   db      26,78   ;; размеры рамки в разных режимах
nors    dw      104,0   ;; смещение до начала следующей строки
reg     dw      0
numres  dw      0       ;; число отслеживаемых задач
tpoint  dw      taskl   ;; указатель на конец таблицы 
taskl   dw      ?
poin1   db      'FastOld toSP'
        db      ?
        dw      518 dup(0)
                 ;; format :
                 ;;      dw      ?               ;; PSP adress
                 ;;      db      12 dup(0)       ;; Task name
                 ;;      db      ?               ;; number of hooked vector's
                 ;;            db      ?         ;; numer         \
                 ;;            dd      ?         ;; hooked vector / ^
endtask dw      $-4     ;; ограничитель таблицы
begmcb  dw      0       ;; адрес первого MCB
asx     dw      0       ;; рабочая переменная

tal     db      '┌─╖'
gtal    db      '│║'
        db      '╘═╝'
ou      db      80 dup ( 32 )   ;; буфер для формирования строки
myes    dw      0               
mydi    dw      0
prgn    db      'Memory to load :'
        lprgn = $ - prgn
pnjk    db      ' Total free : '
        lpnjk = $ - pnjk
pnmk    db      ' Max free block : '
        lpnmk = $ - pnmk
;        ltal = $ - tal

decload:        ;; вывести десятичное число
        push    bx
        mov     cx,4
        xor     dx,dx
bgf:    shl     ax,1
        rcl     dx,1
        loop    bgf
        mov     bx,10
        mov     cx,6
        call    near ptr decasc
        pop     bx
        retn


sdt     dw ?    ;; сохранить все регистры
spush:  push    bp
        mov     bp,sp
        push    ds
        push    es
        push    di
        push    si
        push    dx
        push    cx
        push    bx
        push    ax
        push word ptr [bp+2]
        retn

spop:   pop     word ptr sdt    ;; востановить все регистры
        pop     ax
        pop     bx
        pop     cx
        pop     dx
        pop     si
        pop     di
        pop     es
        pop     ds
        pop     bp
        add     sp,2
        push    word ptr sdt
        retn

;; получить адреса для сохранения / востановления Video экрана
video:  mov     ah,0fh  
        int     10h
        mov     ax,0b800h
        mov     es,ax
        mov     ds,ax
        mov     ax,4000
        mov     bl,bh
        xor     bh,bh
        mul     bx
        mov     si,ax
        mov     word ptr cs:asx,ax
        mov     ax,4000
        xor     bl,7
        mul     bx
        mov     di,ax
        cld
        mov     cx,2000
        retn


mul5:   push    cx      ;; умножить AX на 5
        push    ax
        shl     ax,1
        shl     ax,1
        pop     cx
        add     ax,cx
        pop     cx
        retn

otklic: mov     ax,cs           ;; отметится
        add     ax,6
        iret
in21:   cmp     ax,0efefh       ;; это запрос на отметку ?
        jz      otklic
        cmp     ah,4bh  ;; запуск новой задачи ?
        jne     no4b
        cmp     al,byte ptr 3   ;; или перекрытия ?
        je      no4b
        call    near ptr spush
        cld
        push    ds      ;; "своруем" имя программы в таблицу
        pop     es
        mov     di,dx
        mov     cx,65
        xor     al,al
        repne   scasb
        mov     cx,di

        push    cx
        std
        mov     al,92   ;; '\'
        mov     cx,13
        repne   scasb
        jz      ekd
        or      cx,cx
        jz      srds
ekd:    add     di,2
srds:   cld
        cmp     byte ptr es:[di],92 ;; \
        jne     zx
        inc     di
zx:     pop     cx

        cmp     di,dx
        jae     kmn
        mov     di,dx
kmn:    mov     si,di
        sub     cx,di
        mov     ax,cs
        mov     es,ax
        mov     di,word ptr cs:tpoint
        add     di,2
        push    di
        push    cx
        mov     cx,12
        mov     al,20h
        rep     stosb
        pop     cx
        pop     di
        rep     movsb   ;; сохранили имя

        mov     ax,0bfh ;; запомним текущие вектора
        call    ax      ;; и вектора

ngh:    call    near ptr spop
        jmp     short o21
no4b:   cmp     ah,31h  ;; это постановка в резидент ?
        jne     o21
        call    near ptr rsys
o21:
old21   db      0eah ;; jmp far ptr Old 21 interrupt
i21of   dw      ?
i21sg   dw      ?

rsys:   call    near ptr spush  ;; обслужим постановку в резидент
        push    cs
        pop     es
        mov     di,cs:tpoint    ;; ES:[DI] -> конец таблицы
        mov     ah,62h  ;; получим адресс PSP нового резидента
        int     21h
        mov     word ptr es:[di],bx
        add     di,15 ;; опустим имя резидента и число векторов
        xor     si,si
        mov     ds,si
        mov     bx,di
        xor     dx,dx
        lea     di,es:tmpbuf
        mov     cx,512
nxt:    repe    cmpsw   ;; поиск изменившихся векторов
        or      cx,cx
        jz      qt
        sub     di,2
        add     si,2
        mov     ax,si
        shr     ax,1
        shr     ax,1
        dec     ax
        cmp     ax,22h  ;; вектора с 22h по 24h используются DOS и не 
        jb      culs    ;; подлежат запоминанию
        cmp     ax,24h
        jbe     nomem
culs:   cmp     bx,word ptr cs:endtask
        jae     error
        mov     byte ptr es:[bx],al
        inc     bx
        mov     ax,word ptr es:[di]
        mov     word ptr es:[bx],ax
        mov     ax,word ptr es:[di+2]
        mov     word ptr es:[bx+2],ax
        inc     dx
        add     bx,4
nomem:  add     di,4
        dec     cx
        jmp     short nxt
qt:     mov     di,bx
        mov     bx,word ptr cs:tpoint
        add     bx,14 ;; ???    ;; запомнили число векторов
        mov     byte ptr es:[bx],dl
        mov     word ptr cs:tpoint,di   ;; новый конец таблицы
        inc     word ptr cs:numres      ;; увеличим число резидентов
        mov     ax,0bfh
        call    ax      ;; запомним новые вектора
error:  call    near ptr spop
        retn            ;; и пусть DOS делает все остальное...

in27:   call    near ptr rsys   ;; резидент от COM !
old27   db      0eah    ; jmp far ptr
i27of   dw      ?
i27sg   dw      ?

in09:   push    ax      ;; работаем с клавиатурой
        in      al,60h
        cmp     al,0dh  ;; нажата '=' ?
        jz      go      ;; yes !
olk:    pop     ax
old09   db      0eah    ; jmp far ptr Old 09h
i09of   dw      ?
i09sg   dw      ?

go:     cmp     byte ptr cs:start,0     ;; FA уже активен ?
        jnz     olk     ;; да
        mov     ah,2    ;; получим статус нажатия клавиш Ctrl и Alt
        int     16h
        and     al,0Ch
        cmp     al,byte ptr cs:shiftstat        ;; совпадает с заданным ?
        jnz     olk     ;; нет

        inc     byte ptr cs:start       ;; FA уже активен
        in      al,61h  ; обработаем прерывание
        mov     ah,al
        or      al,80h
        out     61h,al
        xchg    ah,al
        out     61h,al
        mov     al,20h
        out     20h,al
        pop     ax

        call    near ptr spush  ;; сохраним все регистры
        call    near ptr check  ;; проверим наличие в памяти резидентов
        mov     bp,sp
fhn:    sub     sp,6    ;; для моих переменных
        mov     ah,0fh  ;; получим номер текущего Video - режима
        int     10h
        cmp     al,7    ;; монохромный ?
        jz      dfdx    ;; да
        cmp     al,3    ;; текстовый ?
        jbe     dfdx    ;; да
        jmp     rbkd    ;;; я не могу активироваться в графическом режиме
dfdx:   call    near ptr video
        rep     movsw   ;; сохраним экран
        push    cs      ;; долго строим окно диалога
        pop     ds
        mov     di,word ptr asx
        push    di
        mov     ah,0eh
        lea     si,tal
        lodsb
        stosw
        lodsb
        mov     bx,word ptr reg
        mov     cl,byte ptr norma[bx]
        rep     stosw
        lodsb
        stosw     ;; нарисовали верхнею рамку
        shl     bx,1
        add     di,word ptr nors[bx]

        mov     bx,word ptr numres
        lea     ax,taskl
        mov     word ptr [bp-2],ax
        push    si
a2:     mov     si,word ptr [bp-2]      ;; адресс PSP
        mov     ax,9fh
        call    ax
        lodsw
        push    bx
        mov     bx,16
        mov     cx,-4
        xor     dx,dx
        mov     word ptr [bp-4],ax
        call    near ptr decasc
        pop     bx
        mov     cx,12
        inc     di
        rep     movsb ;; имя резидента
cony:   inc     di      ;; его длина
        mov     cx,word ptr [bp-4]
        mov     ax,0ceh
        call    ax
        mov     word ptr [bp-6],ax
        call    near ptr decload
        xor     ch,ch
        xor     ah,ah
        xor     dx,dx
        lodsb
        cmp     word ptr reg,0  ;; надо печатать перехваченные вектора ?
        jz      fnb     ;; нет
        mov     cl,al   ;; пройдемся по таблице...
        or      al,al
        jz      afr2
        push    bx
        mov     bx,16
afr:    lodsb
        add     si,4
        inc     di
        push    cx
        mov     cx,-2
        call    near ptr decasc
        pop     cx
        loop    afr
        pop     bx
afr2:   mov     word ptr [bp-2],si
        jmp     short bvd
fnb:    call    near ptr mul5
        add     ax,15
        add     word ptr [bp-2],ax
bvd:    push    bx
        mov     cx,67h  ; writel
        call    cx
        pop     bx
        dec     bx      ;; циклимся по выдаче резидентов
        jle     axc
        jmp     a2      ; кончили печатать имена резедентов
axc:    mov     ax,9fh
        call    ax      ; строим текущую программу...

        mov     ah,62h  ;; адресс PSP текущей задачи
        int     21h
        push    bx
        mov     ax,bx
        xor     dx,dx
        mov     cx,-4
        mov     bx,16
        call    near ptr decasc
        push    si
        mov     si,tpoint
        add     si,2
        inc     di
        mov     cx,12
        rep     movsb   ;; имя из таблицы
        pop     si
        inc     di
        pop     bx
        push    bx

        mov     cx,bx
        mov     ax,0ceh
        call    ax      ;; длину в параграфах текущей задачи
        push    ax
        call    near ptr decload
        pop     dx
        pop     bx
        add     dx,bx
        cmp     word ptr reg,0
        jz      kmnde
        push    ds      ; список перехваченных векторов
        mov     ax,16
        mov     word ptr [bp-2],ax
        xor     ax,ax
        mov     ds,ax
        mov     si,2
        mov     cx,256
bilg:   lodsw
        add     si,2
        cmp     ax,bx
        jb      enbilg
        cmp     ax,dx
        ja      enbilg
        mov     ax,si
        sub     ax,6
        shr     ax,1
        shr     ax,1
        push    cx
        push    bx
        push    dx
        xor     dx,dx
        mov     cx,-2
        inc     di
        mov     bx,16
        call    near ptr decasc
        pop     dx
        pop     bx
        pop     cx
        dec     word ptr [bp-2]
        jnz     enbilg
        mov     al,46    ;;; '.'
        mov     cx,3
        inc     di
        rep     stosb
        jmp     short dchk
enbilg: loop    bilg
dchk:   pop     ds
kmnde:  sub     dx,bx
        mov     cx,67h
        call    cx      ;; выведем на экран

        mov     ax,9fh
        call    ax      ;; сколько памяти свободно
        lea     si,prgn
        mov     cx,lprgn
        rep     movsb
        inc     di
        inc     di
        xor     cx,cx

        mov     ax,0ceh
        call    ax

        push    ax      ; total
        add     ax,dx   ; to load
        call    near ptr decload
        pop     ax
        cmp     word ptr reg,0
        jz      mklcv
        inc     di
        lea     si,pnjk
        mov     cx,lpnjk
        rep     movsb
        call    near ptr decload

        inc     di
        lea     si,pnmk
        mov     cx,lpnmk
        rep     movsb
        push    ds
        xor     bx,bx
        xor     cx,cx    ; ищем max free space...
        mov     ax,word ptr begmcb
        push    si
        xor     si,si
sf5:    mov     ds,ax
        mov     ax,word ptr [si+3]
        inc     ax
        cmp     word ptr [si+1],cx
        jne     cl32
        cmp     bx,ax
        jae     cl32
        mov     bx,ax
cl32:   push    cx
        mov     cx,ds
        add     ax,cx
        pop     cx
        cmp     byte ptr [si],4dh
        jz      sf5
        mov     ax,bx
        pop     si
        pop     ds
        call    near ptr decload
mklcv:  mov     cx,67h
        call    cx

        pop     si      ; рисуем нижнию рамку
        add     si,2
        lodsb
        stosw
        mov     cl,byte ptr norma[bx]
        lodsb
        rep     stosw
        lodsb
        stosw

        pop     di      ;; теперь готовимся к диалогу
        mov     ax,word ptr numres
        mov     word ptr [bp-2],ax      ;; с какой строки инвертировать
        inc     ax
        mov     dx,160
        mul     dx
        add     ax,3
        add     di,ax
        mov     word ptr asx,0
        xor     ch,ch
        mov     bx,word ptr reg
srsk:   mov     cl,byte ptr norma[bx]
        mov     al,70h
        push    di
hdj:    stosb           ;; инвертировали...
        inc     di
        loop    hdj
        pop     di
        xor     ah,ah   ; wait press...
        int     16h
        or      al,al   ;; это стрелки ?
        jnz     nostr
        cmp     AH,72   ; Up
        jne     no72
        mov     ax,word ptr asx ;; инвертируем строку над текущей
        cmp     word ptr [bp-2],ax
        jbe     srsk
        inc     word ptr asx
        sub     di,160
        jmp     short srsk
no72:   cmp     ah,80   ; Down
        jne     no80
        mov     ax,word ptr asx
        or      ax,ax
        jz      srsk
        mov     cl,byte ptr norma[bx]
        mov     al,0eh
        push    di
hdj1:   stosb   ;; снимем инвертирование
        inc     di
        loop    hdj1
        pop     di
        add     di,160
        dec     word ptr asx
        jmp     short srsk
no80:   cmp     ah,75   ; Left
        jne     no75
        xor     ax,ax
        jmp     short wex
no75:   cmp     ah,77   ; Right
        jne     srsk
        mov     ax,word ptr 1
wex:    mov     word ptr reg,ax ;; переключим режим представления
        call    near ptr video  ;; и перерисуем окно
        xchg    si,di
        rep     movsw
        mov     sp,bp
        jmp     fhn

nostr:  cmp     al,27
        jz      quit    ;; нажата ESC !!!
        cmp     al,13   
        jz      kosr    ;; нажата  Enter !!!
        jmp     srsk
kosr:   call    near ptr releas ;; выгрузим резидентов
quit:   call    near ptr video  ;; востановим экран...
        xchg    si,di
        rep     movsw

rbkd:   mov     sp,bp   ;;  и вернемся из прерывания
        call    near ptr spop
        dec     byte ptr cs:start       ;; FA не активен
        iret

releas: cmp     word ptr asx,0  ;; asx -- число снимаемых задач
        jnz     wor
nowork: retn
wor:    cld
        lea     si,taskl
        mov     cx,numres
        or      cx,cx
        jle     nowork  ;; СБОЙ В ДАННЫХ !!!
polm:   dec     cx      ;; ищем последнею запись в таблице
        jz      polb
        add     si,14
        xor     ah,ah
        lodsb
        call    near ptr mul5
        add     si,ax
        jmp     short polm
polb:   mov     word ptr tpoint,si      ;; запоминаем ссылку на нее
        lodsw   ;; получили ее PSP
        mov     dx,ax
        add     si,12
        xor     ax,ax
        mov     es,ax
        lodsb
        or      al,al   ;; число перехваченных векторов 
        jz      djv
        mov     cl,al
vecres: xor     ah,ah
        lodsb   ;; номер перехваченного вектора
        shl     ax,1
        shl     ax,1
        mov     di,ax
        cli
        movsw   ;; востановили вектор
        movsw
        sti
        loop    vecres  ;; востановим ВСЕ вектора
        push    ds
        pop     es
        mov     di,word ptr tpoint
        mov     cx,14
        rep     movsb   ;; перепишем таблицу для ТЕКУЩЕЙ программы
djv:    mov     ax,begmcb       ;; и освободим все распределенные
        xor     di,di           ;; резиденту блоки PSP
pomh:   mov     es,ax
        cmp     word ptr es:[di+1],dx
        jnz     dfbr
        xor     cx,cx
        mov     word ptr es:[di+1],cx

dfb3d:  mov     es,ax
dfbr:   add     ax,word ptr es:[di+3]
        inc     ax
        cmp     byte ptr es:[di],4dh
        jz      pomh       ; There is anower blok...
dvj:    dec     word ptr numres ;; уменшим число резидентов
        dec     word ptr asx
        push    ds
        push    ds
        pop     es
        mov     ax,0bfh
        call    ax      ;; прочитаем исправленную таблицу векторов
        pop     ds
        jmp     releas

check:  push    cs
        pop     ds
        mov     cx,numres
        lea     si,taskl
        xor     di,di
        cld
ch0:    lodsw   ;; получим адрес PSP
        push    si
        push    ax
        add     si,12
        xor     ah,ah
        lodsb           ;; число векторов
        call    near ptr mul5
        add     si,ax

        pop     ax      ; PSP
        dec     ax      ;; в ax адресс MCB
        mov     es,ax
        inc     ax
        cmp     byte ptr es:[di],4dh    ;; это правильный MCB ?
        jz      ch1
        cmp     byte ptr es:[di],5ah
        jnz     ch2     ; no MCB
ch1:    cmp     word ptr es:[di+1],ax   ;; это распределенный резеденту PSP ?
        jnz     ch2     ; no PSP
        add     sp,2
        loop    ch0
        jmp     short chexit

ch2:    pop     di      ;; Задача выгруженна... 
        push    cx      ;; Исправим мою таблицу резедентов
        sub     di,2
        lea     cx,endtask
        sub     cx,si
        push    di
        mov     ax,si
        sub     ax,di
        sub     word ptr tpoint,ax
        push    ds
        pop     es
        rep     movsb
        dec     word ptr numres
        jg      eg
        pop     si
        pop     cx
        mov     word ptr numres,1
        jmp     short chexit
eg:     pop     si
        pop     cx
        xor     di,di
        loop    ch0

chexit: retn
        ;; Универсальная подпрограмма перевода числа в набор символов
decasc:  ; dx:ax - ##; es:[di] - output adress
         ; cx - length ; bx - basa
        cld
        push    si
        push    ax
        or      cx,cx
        jg      edt
        mov     al,48   ; '0'
        neg     cx
        jmp     short gvb
edt:    mov     al,20h  ; ' '
gvb:    rep     stosb
        pop     ax
        push    di
        dec     di
        std
dcr:    div     bx
        mov     si,dx
        push    ax
        mov     al,byte ptr cs:asc[si]
        stosb
        pop     ax
        xor     dx,dx
        or      ax,ax
        jnz     dcr
        pop     di
        pop     si
        cld
        retn

asc     db      '0123456789ABCDEF'

load:
        lea     dx,soobs        ;; Крикнем о себе...
        mov     ah,9
        int     21h

        xor     ax,ax
        mov     si,80h
        cld
        lodsb
        or      al,al   ;; а командная строка есть ?
        jz      se
        mov     cx,ax   ;; Ах, все-таки есть...
        xor     bl,bl

se2:    lodsb   ;; посмотрим, что там записано...
        cmp     al,'?'
        jnz     jhk     
        lea     dx,help ;; как со мной работать...
        mov     ah,9
        int     21h
        jmp     short se3
jhk:    cmp     al,'a'
        jnz     se4
se5:    or      bl,8    ;; установим признак Alt
        jmp     short se3
se4:    cmp     al,'A'
        jz      se5
        cmp     al,'C'
        jnz     se6
se7:    or      bl,4    ;; установим признак Ctrl
        jmp     short se3
se6:    cmp     al,'c'
        jz      se7
se3:    loop    se2
        or      bl,bl   ;; изменение вызова ?
        jz      se      ;; нет
        mov     byte ptr cs:shiftstat,bl        ;; запомним
se:     mov     ax,0efefh       ;; а я уже резидентен ?
        int     21h
        cmp     ah,0efh 
        jz      taskload        ;; нет
        mov     es,ax
        xor     di,di
        lea     si,polmd
        cld
        mov     cx,6
        repz    cmpsb
        lea     ax,polmd+6
        cmp     si,ax
        jne     taskload        ;; нет, в памяти не я, или другая версия...
        mov     di,0a3h 
        or      bl,bl
        jnz     dcr3
        mov     al,byte ptr es:[di]     ;; как там вызвать резидента ?
        mov     cs:shiftstat,al
        jmp     short mlop      
dcr3:   mov     byte ptr es:[di],bl     ;; заменим вызов резидента
mlop:   mov     di,0a0h  ;; сбросим флаг занятости
        mov     byte ptr es:[di],0
        lea     dx,alr  ;; скажу, что я уже в памяти
        mov     ah,9
        int     21h
        call    near ptr mmo    ;; сообщу как вызвать
exit:   mov     ax,4c00h        ;; и все...
        int     21h
taskload:

        cld
        mov     ax,cs   ;; готовимся к постановке в резидент...
        mov     es,ax
        xor     ax,ax
        push    ds
        mov     ds,ax
        xor     si,si
        mov     word ptr cs:start,si
        lea     di,es:tmpbuf    
        mov     cx,512
        rep     movsw   ;; запомнили старые вектора
        pop     ds

        push    es
        mov     ah,52h  ;; получим адресс первого MCB
        int     21h
        mov     ax,word ptr es:[bx-2]
        mov     word ptr cs:begmcb,ax
        pop     es
        ;; более полное использование PSP
        lea     si,polmd        ;; скопировали свой признак
        mov     di,60h
        mov     cx,6
        push    cs
        pop     es
        rep     movsb

        lea     si,writeline    ;; и кое - что еще...
        mov     cx,lwriteline
        rep     movsb

        lea     si,clear        ;; и кое - что еще...
        mov     cx,lclear
        rep     movsb

        lea     si,oldvec       ;; и кое - что еще...
        mov     cx,loldvec
        rep     movsb

        lea     si,cntmcb1      ;; и кое - что еще...
        mov     cx,lcntmcb1
        rep     movsb


        mov     ax,3521h        ;; заменил вектор 21h
        int     21h
        mov     word ptr i21of,bx
        mov     bx,es
        mov     word ptr i21sg,bx
        lea     dx,in21
        mov     ah,25h
        int     21h

        mov     ax,3527h        ;; заменил вектор 27h
        int     21h
        mov     word ptr i27of,bx
        mov     bx,es
        mov     word ptr i27sg,bx
        lea     dx,in27
        mov     ah,25h
        int     21h

        mov     ax,3509h        ;; заменил вектор 09h
        int     21h
        mov     word ptr i09of,bx
        mov     bx,es
        mov     word ptr i09sg,bx
        lea     dx,in09
        mov     ah,25h
        int     21h

        mov     ax,word ptr cs:[2ch]    ; остался без окружения
        mov     es,ax
        mov     ah,49h
        int     21h
        mov     word ptr cs:[2ch],0


        lea     dx,res  ;; скажем что остаемся в памяти...
        mov     ah,9
        int     21h
        call    near ptr mmo    ;; и как меня вызывать...

        lea     dx,load
        mov     cl,byte ptr 4
        shr     dx,cl
        inc     dx
        mov     ax,3100h  ;; остался в резиденте
        int     21h

mmo:    lea     dx,cls
        mov     ah,9    ;; Вызов :
        int     21h
        mov     al,byte ptr shiftstat
        mov     ah,9
        test    al,4
        jz      noctrl
        lea     dx,clsc ;; Ctrl+
        push    ax
        int     21h
        pop     ax
noctrl: test    al,8
        jz      noalt
        lea     dx,clsa ;; Alt+
        int     21h
noalt:  lea     dx,cls1 ;; '='
        int     21h
        retn
;; Copy to PSP...
writeline:      ;; вывести строку из буфера ou в Video - буфер с атрибутами
        mov     cx,word ptr cs:myes
        mov     es,cx
        mov     di,word ptr cs:mydi
        xor     ch,ch
        lea     si,ou
        mov     bx,word ptr reg
        mov     cl,byte ptr norma[bx]
        push    si
        add     si,cx
        inc     si
        mov     al,byte ptr gtal+1
        mov     byte ptr ds:[si],al
        pop     si
        add     cl,byte ptr 2

        mov     ah,0eh
a4:     lodsb
        stosw
        loop    a4
        shl     bx,1
        add     di,word ptr nors[bx]
        shr     bx,1
        retn

lwriteline = $ - writeline

clear:  mov     ax,es   ;; очистка буфера строки ou
        mov     word ptr cs:myes,ax
        mov     word ptr cs:mydi,di
        push    cs
        pop     es
        lea     di,ou
        push    di
        mov     cx,80
        mov     al,20h
        rep     stosb
        pop     di
        mov     al,byte ptr gtal
        stosb
        inc     di
        retn
        lclear = $ - clear

oldvec: xor     ax,ax   ;; запомнили старые вектора
        mov     ds,ax
        xor     si,si
        lea     di,es:tmpbuf
        mov     cx,512
        rep     movsw
        retn
        loldvec = $ - oldvec
;; Определение суммарной длины в параграфах блоков MCB распр. резеденту
cntmcb1: push    ds      ;; CX - PSP ; Ret : ax - summa len
        push    bx
        XOR     bx,bx
        mov     ax,word ptr begmcb
        push    si
        xor     si,si
sf4:    mov     ds,ax
        mov     ax,word ptr [si+3]
        inc     ax
        cmp     word ptr [si+1],cx
        jne     cl31
        add     bx,ax
cl31:   push    cx
        mov     cx,ds
        add     ax,cx
        pop     cx
        cmp     byte ptr [si],4dh
        jz      sf4
        mov     ax,bx
        pop     si
        pop     bx
        pop     ds
        retn
        lcntmcb1 = $ - cntmcb1

mytext  db      0

soobs   db      0dh,0ah,' * Обнинский институт атомной энергетики *'
        db      0dh,0ah,' * Лаборатория "Тренажер" * (08439)20806 *'
        db      0dh,0ah,' * Tsyganok Service * 1992 * Fast Abort  *'
        db      0dh,0ah,' * Свободное распространение * Ver 1.01  *'
        db      0dh,0ah,'     Для помощи дайте команду : "FA ?"'
        db      0dh,0ah,0ah,'$'
alr     db      ' Я уже загружен.$'
res     db      ' Я остаюсь в памяти.$'
cls     db      0dh,0ah,0ah,' Вызов : $'
cls1    db      "'='",0dh,0ah,'$'
clsa    db      'Alt+$'
clsc    db      'Ctrl+$'
help    db      ' После запуска задача становится резидентной и'
        db      0dh,0ah,' после активации при помощи стрелок '
        db      34,24,'" и "',25,34,' выбирете'
        db      0dh,0ah,' задачи подлежащие удалению из памяти,'
        db      ' и нажмите "Enter".'
        db      0dh,0ah,' Используя стрелки "<-" и "->"'
        db      ' выбираете: отображать или нет'
        db      0dh,0ah,' перехваченные вектора.'
        db      0dh,0ah,' Для выхода без удаления нажмите "Esc"'
        db      0dh,0ah,0ah,' FA ? этот текст'
        db      0dh,0ah," FA A вызов по Alt+'='"
        db      0dh,0ah," FA C вызов по Ctrl+'='"
        db      0dh,0ah," FA CA вызов по Ctrl+Alt+'='"
        db      0dh,0ah,0ah,'$'
polmd   db      'FATSV',0
cod     ends
        end     start