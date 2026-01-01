
.MODEL TINY
.CODE
.STARTUP

        jmp     begin

;***********************************************************************
;               Маленькая резидентная программка предназначенная для га-
;       шения  монитора,  если  в  течении какого-то времени не произво-
;       дилась работа с клавиатурой или мышью.  В отличие от аналогичной
;       функции популярного руссификатора KYERUS Гуртяка,  экран гасится
;       в любых режимах  видеоадаптера.  Запускается  данная программа с
;       одним параметром,  количеством минут до гашения экрана.
;           Пример:
;               CLSTIME  5      ( По умолчанию 3 минуты. )
;***********************************************************************

;       Программа ClsTime интересна способом перехвата прерываний, при
;котором вектор не изменяется, а изменяется текст обработчика. Первые 5
;байт этого обработчика заменяются на команду JMP FAR с адресом своей
;программы обработки, которая закончив все свои дела восстанавливает старый
;обработчик, передает ему управление с возвратом на себя, и после всего
;этого снова записывает JMP FAR в старый обработчик. Вся эта война затеянна
;для того, чтобы иметь возможность следить за векторами перехваченных
;прерываний и, при их изменении, врезаться в новые обработчики.}

;       Данная программа перехватывает прерывания 08h (от таймера), 09h (от
;клавиатуры), 0bh и 0ch (от COM-портов). Таймерное прерывание перехватывает-
;ся для слежения за остатком времени до выключения экрана и слежения за ос-
;тальными векторами перехваченных прерываний. В случае изменения последних
;производится врезка в новые обработчики прерываний и восстановление старых.
;Таким образом программа имеет возможность всю дорогу следить за прерывания-
;ми от клавиатуры и мышки, даже если прикладная программа пытается этому
;помешать. Если вектор установлен в ПЗУ, то производится такая-же попытка
;врезки, но с полным провалом операции, что впрочем не мешает нормальной
;работе программы.

time1   equ     word ptr cs:[00f0h]     ;время до гашения текущее.
time2   equ     word ptr cs:[00f2h]     ;время до гашения установочное.
f_alt   equ     byte ptr cs:[00f4h]     ;флаг нажатия Alt.
f_ap    equ     byte ptr cs:[00f5h]     ;флаг Alt+Pause.
f_act   equ     byte ptr cs:[00f6h]     ;флаг активности.
s_code  equ     byte ptr cs:[00f7h]     ;последний скан-код.
border  equ     byte ptr cs:[00f8h]     ;цвет бордюра экрана.
scrcls  equ     byte ptr cs:[00f9h]     ;признак погашенности.

;       По адресам 00c0h, 00d0h, 00e0h  располагаются блоки данных
;для слежения за векторами прерываний 09h (от клавиатуры), 0bh (от
;COM2) и 0ch (от COM1). Формат этих блоков следующий:  1. смещение
;+0 - вектор прерывания, смещение+4 - команда JMP FAR на наш обра-
;ботчик прерывания, смещение+10 - 5 байтов стандартного обработчи-
;ка замещаемые команндой JMP FAR на наш обработчик.

new08   proc    near
;       Обработчик прерывания 08h (таймер)
        push    ds
        push    es
        push    ax
        push    cx
        push    si
        push    di
        cmp     f_act,0 ;Проверка активности.
        je      l02
        cmp     scrcls,1;Экран погашен?
        je      l02     ;если да, то переход.
        cmp     time1,0 ;Время до гашения истекло?
        jne     l01     ;если нет, то переход.
        call    scroff  ;гашение экрана
        jmp     l02
l01:    dec     time1
l02:    push    cs      ;далее проверка векторов прерыва-
        pop     es      ;ний 09h, 0bh, 0ch.
        cld
        xor     ax,ax
        mov     ds,ax
        mov     si,0024h        ;адрес вектора 09h
        mov     di,00c0h        ;адрес блока данных слежения за 09h
        call    intver          ;на проверку
        mov     si,002ch        ;адрес вектора 0bh
        mov     di,00d0h        ;адрес блока данных слежения за 0bh
        call    intver          ;на проверку
        mov     si,0030h        ;адрес вектора 0ch
        mov     di,00e0h        ;адрес блока данных слежения за 0ch
        call    intver          ;на проверку
        pop     di
        pop     si
        pop     cx
        pop     ax
        pop     es
        pop     ds
        db      0eah            ;JMP FAR на старый обработчик.
old08   dw      2 dup(0)
new08   endp

new09   proc    near
;       Обработчик прерывания 09h (клавиатура).
        push    ax
        cmp     f_act,0         ;Проверка активности.
        jne     l00
        jmp     l18
l00:    cmp     f_ap,0          ;Не было Alt+Pause?
        je      l10             ;если не было,
        jmp     l16             ;если было.
l10:    cmp     time1,0         ;Экран погашен?
        je      l11             ;если да, то переход.
        mov     ax,time2        ;TIME1:=TIME2
        mov     time1,ax
        jmp     l13             ;На проверку <Alt+Pause>.
l11:    in      al,60h  ;ввести скан-код клавиши
        cmp     al,0e0h ;скан-код равен e0h?
        je      l12     ;если да, то переход.
        test    al,80h  ;это скан-код отпускания?
        jz      l12     ;если нет, то переход.
        call    scron   ;включаем изображение.
        mov     ax,time2        ;TIME1:=TIME2
        mov     time1,ax
l12:    in      al,61h  ;ввести байт из порта управления
        push    ax      ;клавиатурой и сохранить его.
        or      al,80h  ;установить бит "подтвержение
        out     61h,al  ;ввода" и вывести байт в порт.
        pop     ax      ;записать в порт исходное значение.
        jmp     $+2
        out     61h,al
        mov     al,20h  ;посылаем сигнал "конец прерывания"
        out     20h,al  ;контроллеру прерываний INTEL_8259.
        pop     ax
        iret
l13:    in      al,60h  
        cmp     al,38h  ;Это клавиша Alt?
        jne     l14     ;если нет, то на дальнейшие проверки.
        cmp     s_code,0e0h     ;Если это правый Alt, то
        je      l14             ;ничего не предпринимаем.
        mov     f_alt,1 ;Взводим флаг нажатия Alt.
        jmp     l18     ;К старому обработчику.
l14:    mov     s_code,al       ;Запоминаем скан-код.
        cmp     al,0b8h ;Это отпущена Alt?
        jne     l15     ;усли нет, то далее.
        mov     f_alt,0 ;Сбрасываем флаг нажатия Alt.
        jmp     l18     ;К старому обработчику.
l15:    cmp     al,0e1h ;Это Pause?
        jne     l18     ;если нет, то к старому обработчику.
        cmp     f_alt,1 ;Клавиша Alt нажата?
        jne     l18     ;если нет, то к старому обработчику.
        mov     f_ap,1  ;Устанавливаем флаг Alt+Pause.
        call    scroff  ;Гасим экран.
l16:    in      al,60h  ;Получаем скан-код.
        cmp     al,0b8h ;Alt отпущен?
        jne     l17     ;если нет.
        mov     f_ap,0  ;Сбрасываем флаг Alt+Pause.
        mov     f_alt,0 ;Сбрасываем флаг нажатия Alt.
        mov     time1,0 ;Сбрасываем счетчик тиков до гашения.
        jmp     l18     ;К старому обработчику.
l17:    in      al,61h  ;Ввести байт из порта управления
        push    ax      ;клавиатурой и сохранить его.
        or      al,80h  ;Установить бит "подтвержение
        out     61h,al  ;ввода" и вывести байт в порт.
        pop     ax      ;Записать в порт исходное значение.
        jmp     $+2
        out     61h,al
        mov     al,20h  ;посылаем сигнал "конец прерывания"
        out     20h,al  ;контроллеру прерываний INTEL_8259.
        pop     ax
        iret
l18:    push    ds      ;Передача управления старому обработчику.
        push    es      ;Для этого восстанавливаем 5 байт в старом
        push    cx      ;обработчике, передаем туда управление
        push    si      ;командой CALL и по возвращении от-тудова
        push    di      ;снова записываем JMP в старый обработчик.
        mov     ax,cs
        mov     ds,ax
        mov     si,00cah        ;DS:SI - адрес 5 байт из старого обр-ка.
        mov     es,word ptr ds:[00c2h]
        mov     di,word ptr ds:[00c0h]  ;ES:DI - адрес старого обр-ка.
        mov     cx,5
        cld
rep     movsb                           ;Восстановление 5 байт.
        pushf
        call    dword ptr ds:[00c0h]    ;Переход к старому обр-ку.
        mov     si,00c4h                ;DS:SI - адрес JMPа на сюда.
        mov     di,word ptr ds:[00c0h]  ;ES:DI - адрес старого обр-ка.
        mov     cx,5
rep     movsb                           ;Восстановление JMPа.
        pop     di
        pop     si
        pop     cx
        pop     es
        pop     ds
        pop     ax
        iret
new09   endp

new0b   proc    near
;       Обработчик прерывания 0Bh (COM2)
        push    ds
        push    es
        push    ax
        push    cx
        push    si
        push    di
        cmp     time1,0 ;Экран погашен?
        jne     l21     ;если нет, то переход.
        call    scron   ;Включаем экран.
l21:    mov     ax,time2
        mov     time1,ax
        mov     ax,cs
        mov     ds,ax
        mov     si,00dah        ;DS:SI - адрес 5 байт из старого обр-ка.
        mov     es,word ptr ds:[00d2h]
        mov     di,word ptr ds:[00d0h]  ;ES:DI - адрес старого обр-ка.
        mov     cx,5
        cld
rep     movsb                           ;Восстановление 5 байт.
        pushf
        call    dword ptr ds:[00d0h]    ;Переход к старому обр-ку.
        mov     si,00d4h                ;DS:SI - адрес JMPа на сюда.
        mov     di,word ptr ds:[00d0h]  ;ES:DI - адрес старого обр-ка.
        mov     cx,5
rep     movsb                           ;Восстановление JMPа.
        pop     di
        pop     si
        pop     cx
        pop     ax
        pop     es
        pop     ds
        iret
new0b   endp

new0c   proc    near
;       Обработчик прерывания 0Ch (COM1)
        push    ds
        push    es
        push    ax
        push    cx
        push    si
        push    di
        cmp     time1,0 ;Экран погашен?
        jne     l31     ;если нет, то переход.
        call    scron   ;Включаем экран.
l31:    mov     ax,time2
        mov     time1,ax
        mov     ax,cs
        mov     ds,ax
        mov     si,00eah        ;DS:SI - адрес 5 байт из старого обр-ка.
        mov     es,word ptr ds:[00e2h]
        mov     di,word ptr ds:[00e0h]  ;ES:DI - адрес старого обр-ка.
        mov     cx,5
        cld
rep     movsb                           ;Восстановление 5 байт.
        pushf
        call    dword ptr ds:[00e0h]    ;Переход к старому обр-ку.
        mov     si,00e4h                ;DS:SI - адрес JMPа на сюда.
        mov     di,word ptr ds:[00e0h]  ;ES:DI - адрес старого обр-ка.
        mov     cx,5
rep     movsb                           ;Восстановление JMPа.
        pop     di
        pop     si
        pop     cx
        pop     ax
        pop     es
        pop     ds
        iret
new0c   endp

new2f   proc    near
;       Обработчик прерывания 2Fh (мультеплексное).
;       Необходим во избежание повторной загрузки в память.
        pushf
        cmp     ax,0beebh       ;Если в AX BEEBh, то это
        je      l41             ;вызов из нашей программы,
        popf                    ;иначе к старому обработчику.
        db      0eah
old2f   dw      2 dup(0)
l41:    popf
        mov     ax,0abcdh       ;Возвращаем магическое слово ABCDh в
        push    cs              ;в регистре AX и адрес резидента в BX.
        pop     bx
        iret
new2f   endp

intver  proc    near
;       Процедура проверки векторов прерываний на изменение и
;       реакции на изменение заключающейся в восстановлении старого
;       обработчика и врезке в новый.
;       DS:SI - адрес вектора, ES:DI - адрес блока слежения за вектором.
        lodsw
        cmp     word ptr es:[di],ax
        jnz     l52
        lodsw
        add     di,2
        cmp     word ptr es:[di],ax
        jnz     l51
        ret
l51:    sub     si,2
        sub     di,2
l52:    sub     si,2
        push    ds      ;Восстановление 5 байт забитых командой
        push    es      ;JMP на наш обработчик в обработчике по
        pop     ds      ;старому вектору.
        push    si
        push    di
        mov     si,di
        add     si,10
        add     di,2
        mov     es,word ptr ds:[di]
        sub     di,2
        mov     di,word ptr ds:[di]
        mov     cx,5
rep     movsb
        push    ds
        pop     es
        pop     di
        pop     si
        pop     ds
        movsw           ;Сохранение нового вектора в блоке слежения.
        movsw
        sub     di,4    ;Сохранение 5 байт из нового обработчика в
        push    ds      ;блоке слежения.
        mov     si,word ptr es:[di]     ;адрес вектора в SI больше не нужен.
        add     di,2
        mov     ds,word ptr es:[di]
        add     di,8    ;ES:DI - адрес по которому сохраняются 5 байт.
        mov     cx,5    ;DS:SI - адрес нового обработчика. 
rep     movsb
        sub     si,5    ;Запись команды JMP на наш обработчик в
        sub     di,11   ;тело нового обработчика.
        mov     ax,ds
        mov     es,ax
        push    cs
        pop     ds
        xchg    si,di   ;DS:SI - адрес JMPа, ES:DI - адрес нового обр-ка.
        mov     cx,5
rep     movsb
        push    cs
        pop     es
        pop     ds
        ret
intver  endp

scroff  proc    near
;       Процедура гашения экрана.
        push    ax
        push    bx
        push    dx
        push    ds
        xor     ax,ax
        mov     ds,ax
        and     word ptr ds:[0417h],00f0h
        pop     ds
        mov     ax,1008h
        xor     bx,bx           ;Получаем цвет бордюра и
        int     10h             ;сохраняем его в BORDER.
        mov     border,bh
        mov     ax,1001h        ;Гасим бордюр.
        xor     bx,bx
        int     10h
        mov     dx,03dah        ;Переключение порта 3C0h в
        in      al,dx           ;адресный режим.
        mov     scrcls,1
        mov     al,1fh          ;Гашение экрана.
        mov     dx,03c0h
        out     dx,al
        xor     al,al
        out     dx,al
        pop     dx
        pop     bx
        pop     ax
        ret
scroff  endp

scron   proc    near
;       Процедура включения экрана.
        push    ax
        push    bx
        push    dx
        mov     dx,03dah        ;Переключение порта 3C0h в
        in      al,dx           ;адресный режим.
        mov     scrcls,0
        mov     al,20h          ;Включение экрана.
        mov     dx,03c0h
        out     dx,al
        mov     ax,1001h        ;Востановление цвета бордюра
        mov     bh,border       ;из переменной BORDER.
        int     10h
        pop     dx
        pop     bx
        pop     ax
        ret
scron   endp

begin:  call    egavga                  ;Проверка на наличие EGA или VGA.
        cmp     byte ptr ds:[0080h],2   ;Если параметров нет,
        jb      lb5                     ;то на установку резидента.
        cld
        mov     si,0081h        ;DS:SI - на параметры.
        xor     cx,cx
        mov     cl,byte ptr ds:[0080h]
        inc     cx
        push    cx
        push    si
lb1:    lodsb   
        cmp     al,2fh          ;Ищем '/'.
        jne     lb1a
        jmp     lb7
lb1a:   loop    lb1
        pop     si
        pop     cx
lb2:    lodsb
        cmp     al,21h  ;Ищем начало параметра.
        jae     lb3
        loop    lb2
        jmp     lb5
lb3:    cmp     al,30h  ;Пропускаем нули.
        jne     lb4
        lodsb
        jmp     lb3
lb4:    call    digit   ;На обработку параметра.
lb5:    mov     ax,0beebh       ;Проверка на наличие резидента.
        int     2fh
        cmp     ax,0abcdh       
        jne     lb6             ;Переход если в памяти нет резидента.
        mov     ds,bx           ;Если резидент есть, то записываем в него
        mov     ax,cs:time3     ;новое время до гашения.
        mov     word ptr ds:[00f0h],ax
        mov     word ptr ds:[00f2h],ax
        mov     byte ptr ds:[00f6h],1   ;Устанавливаем признак активности.
        push    cs
        pop     ds
        mov     dx,offset cap   ;Выводим шапку,транспорант
        mov     ah,9            ;и прекращаем все это.
        int     21h
        mov     dx,offset salut
        mov     ah,9
        int     21h
        int     20h
lb6:    mov     ax,time3        ;Запись времени до гашения экрана
        mov     time1,ax        ;в переменные TTIME1 и TIME2.
        mov     time2,ax
        mov     f_act,1         ;Устанавливаем признак активности.
        xor     ax,ax                   ;Записываем в блоки данных
        mov     word ptr ds:[00c0h],ax  ;слежения за векторами пре-
        mov     word ptr ds:[00d0h],ax  ;рываний необходимую информацию.
        mov     word ptr ds:[00e0h],ax
        mov     ax,0f000h
        mov     word ptr ds:[00c2h],ax  ;Все старые вектора якобы
        mov     word ptr ds:[00d2h],ax  ;указывали в ПЗУ.
        mov     word ptr ds:[00e2h],ax
        mov     al,0eah                 ;JMP FAR
        mov     byte ptr ds:[00c4h],al
        mov     byte ptr ds:[00d4h],al
        mov     byte ptr ds:[00e4h],al
        push    cs
        pop     ax
        mov     word ptr ds:[00c7h],ax  ;Устанавливаем адреса в
        mov     word ptr ds:[00d7h],ax  ;командах JMP FAR для
        mov     word ptr ds:[00e7h],ax  ;ссылок на свои обработчики.
        mov     ax,offset new09
        mov     word ptr ds:[00c5h],ax
        mov     ax,offset new0b
        mov     word ptr ds:[00d5h],ax
        mov     ax,offset new0c
        mov     word ptr ds:[00e5h],ax
        xor     ax,ax           ;Сохранение старых векторов
        mov     ds,ax           ;прерываний 08h и 2Fh, а также
        cld                     ;установка новых.
        cli
        mov     si,0020h
        mov     di,offset old08
        movsw
        movsw
        mov     si,00bch
        mov     di,offset old2f
        movsw
        movsw
        push    cs
        pop     ax
        mov     word ptr ds:[0022h],ax
        mov     word ptr ds:[00beh],ax
        mov     dx,offset new08
        mov     word ptr ds:[0020h],dx
        mov     dx,offset new2f
        mov     word ptr ds:[00bch],dx
        sti
        push    cs
        pop     ds
        mov     scrcls,0
        mov     dx,offset cap   ;Выводим шапку и транспорант.
        mov     ah,9
        int     21h
        mov     dx,offset salut
        mov     ah,9
        int     21h
        mov     es,word ptr ds:[002ch]  ;Высвобождаем среду DOS.
        mov     ah,49h
        int     21h
        mov     dx,offset begin ;Заканчиваем это грязное дело и
        int     27h             ;оставляем каку в памяти.
lb7:    lodsb
        cmp     al,55h  ;Это 'U'
        je      outmem  ;На освобождение памяти.
        cmp     al,75h  ;Это 'u'
        je      outmem  ;На освобождение памяти.
        cmp     al,3fh  ;Это '?'
        je      lb8
        cmp     al,48h  ;Это 'H'
        je      lb8
        cmp     al,68h  ;Это 'h'
        je      lb8
        cmp     al,4fh  ;Это 'O'
        je      lb7a
        cmp     al,6fh  ;Это 'o'
        je      lb7a
lb7e:   mov     dx,offset errpar        ;Если не '?','H','h','O','o', то
        mov     ah,9                    ;сообщаем об ошибке в параметрах.
        int     21h
        int     20h             ;Усе.
lb7a:   lodsw
        cmp     ax,4646h        ;Это 'FF'
        je      lb7b
        cmp     ax,6666h        ;Это 'ff'
        je      lb7b
        jmp     lb7e
lb7b:   mov     ax,0beebh       ;Ищем резидента в памяти.
        int     2fh
        cmp     ax,0abcdh       ;Если нет, то кончаем с этим.
        jne     lb7c
        mov     ds,bx           ;Если резидент есть, то дезактивируем.
        mov     ax,word ptr ds:[00f2h]
        mov     word ptr ds:[00f0h],ax
        mov     byte ptr ds:[00f6h],0   ;Сбрасываем признак активности.
        push    cs
        pop     ds
lb7c:   mov     dx,offset cap   ;Выводим шапку,транспорант
        mov     ah,9            ;и прекращаем все это.
        int     21h
        mov     dx,offset salut
        mov     ah,9
        int     21h
        int     20h
lb8:    mov     dx,offset cap   ;Выводим шапку и хелпик.
        mov     ah,9
        int     21h
        mov     dx,offset help
        mov     ah,9
        int     21h
        int     20h             ;Усе.
lb9:    mov     dx,offset cap   ;Выводим шапку.
        mov     ah,9
        int     21h
        mov     dx,offset uer   ;Выводим сообщение об отсутствии резидента.
        mov     ah,9
        int     21h
        int     20h             ;Усе.
outmem: mov     ax,0beebh       ;Проверка на наличие резидента.
        int     2fh
        cmp     ax,0abcdh       
        jne     lb9             ;Переход если в памяти нет резидента.
        push    bx
        mov     ax,3508h        ;Проверяем вектор прерыв. 08h.
        int     21h
        pop     bx
        mov     dx,es
        cmp     dx,bx           ;Если вектор был перехвачен, то
        jne     noout           ;переход по noout.
        push    bx
        mov     ax,352fh        ;Проверяем вектор прерыв. 2fh.
        int     21h
        pop     bx
        mov     dx,es
        cmp     dx,bx           ;Если вектор был перехвачен, то
        jne     noout           ;переход по noout.
        mov     ds,bx           ;Востанавливаем старые вектора
        xor     bx,bx           ;прерываний 08h и 2Fh, а также
        mov     es,bx           ;востанавливаем пять первых
        cld                     ;байтов в обработчиках прерываний
        cli                     ;09h, 0Bh и 0Ch.
        mov     di,0020h
        mov     si,offset old08
        movsw
        movsw
        mov     di,00bch
        mov     si,offset old2f
        movsw
        movsw
        mov     di,word ptr ds:[00c0h]
        mov     es,word ptr ds:[00c2h]
        mov     si,00cah
        movsw
        movsw
        movsb
        mov     di,word ptr ds:[00d0h]
        mov     es,word ptr ds:[00d2h]
        mov     si,00dah
        movsw
        movsw
        movsb
        mov     di,word ptr ds:[00e0h]
        mov     es,word ptr ds:[00e2h]
        mov     si,00eah
        movsw
        movsw
        movsb
        sti
        push    ds      ;Освобождаем занимаемую память.
        pop     es
        mov     ah,49h
        int     21h
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     dx,offset cap   ;Выводим шапку.
        mov     ah,9
        int     21h
        mov     dx,offset uyes  ;Выводим сообщение об освобождении.
        mov     ah,9
        int     21h
        int     20h             ;Усе.
noout:  mov     ds,bx
        mov     ax,word ptr ds:[00f2h]
        mov     word ptr ds:[00f0h],ax
        mov     byte ptr ds:[00f6h],0   ;Сбрасываем признак активности.
        push    cs
        pop     ds
        mov     dx,offset cap   ;Выводим шапку,транспорант
        mov     ah,9            ;и прекращаем все это.
        int     21h
        mov     dx,offset uno
        mov     ah,9
        int     21h
        int     20h

digit   proc    near
;       Процедура анализа цифири в параметрах программы.
;       На основании анализа заполняется переменная TIME3.
;       В AL первая цифирь, SI указывает на следующую.
        mov     cx,10   ;Десятичный множитель.
        xor     bx,bx
ld1:    cmp     al,30h  ;Проверяем действительно ли в
        jb      exitd   ;регистре AL цифирь.
        cmp     al,3ah
        jae     exitd
        and     ax,000fh        ;Выделяем цифру, умножаем накопленное
        xchg    ax,bx           ;число в BX на десять и прибавляем к
        mul     cx              ;результату выделенную цифирь.
        cmp     dx,0            ;Попутно проверяем на переполнение.
        jne     exitd
        add     ax,bx
        xchg    ax,bx
        lodsb
        cmp     al,21h          ;Проверка на конец цифирок.
        jae     ld1
        cmp     bx,61           ;Проверка, неслишком ли много.
        jae     exitd
        mov     cx,0444h        ;Количество тиков в минуте.
        mov     al,bl           ;Количество минут в AL.
        mul     cx
        mov     time3,ax
        ret
exitd:  mov     dx,offset cap           ;Выводим шапку и сообщение
        mov     ah,9                    ;об ошибках в параметрах и
        int     21h                     ;кончаем с ентим делом.
        mov     dx,offset errpar
        mov     ah,9
        int     21h
        int     20h
digit   endp

egavga  proc    near
;       Процедура проверки на наличие EGA или VGA.
        mov     ah,12h  ;Функция поддерживается ЕГой и ВЖой.
        mov     bl,10h
        int     10h
        cmp     bl,10h  ;Если есть, то BL не изменяется.
        je      exitf
        ret
exitf:  mov     dx,offset cap   ;Выводим шапку и сообщение
        mov     ah,9            ;об отсутствии ЕГи или ВЖи и
        int     21h             ;кончаем с энтим.
        mov     dx,offset novga
        mov     ah,9
        int     21h
        int     20h             ;Брык-поинт процедуры поиска ЕГи или ВЖи.
egavga  endp

time3   dw      0ccch           ;Время до гашения в тиках таймера.

; ********   Сообщения !!!   ********

cap     db      13,10
        db      '                         Программа  гашения  монитора',13,10
        db      '            при условии отсутствия работы с клавиатурой или мышью.'
        db      13,10
        db      '       Copyright (C)  Alexander Andreev,  Russia,  Magadan,  April 1994.',13,10
        db      '       ГПСИ "Россвязьинформ", тел. 2-48-11, RELCOM: root@gpsi.magadan.su',13,10
        db      '                          Раб.тел. (413-00)30-538',13,10,36
help    db      13,10
        db      '            Данная программа  предназначенна  для сохранения люминофора',13,10
        db      '       Вашего монитора.  Во время  неизбежных перерывов  в Вашей плодо-',13,10
        db      '       творной работе,  когда Вы  по каким-то причинам не хотите выклю-',13,10
        db      '       чать компьютер, эта программа позаботится о том чтобы дисплей не',13,10
        db      '       горел без толку.',13,10,13,10
        db      '       Ограничения:       Только EGA, VGA или SVGA мониторы!',13,10
        db      '                          Нельзя применять Release. (Используйте ключ /U)',13,10
        db      '                          Не работает под Windows! Там есть гасилка.',13,10,13,10
        db      '       Опции программы:   /H,/h или /? - Данная информация,',13,10
        db      '                          XX - Время в минутах до гашения экрана. (деся-',13,10
        db      '                               тичное число от 1 до 60, по умолчанию 3.)',13,10
        db      '                          /OFF-Выключение резидентной программы.',13,10
        db      '                          /U - Освобождение памяти.',13,10,13,10,36
salut   db      13,10
        db      '       Нажатие < Left_Alt + Pause > сразу гасит экран.'
        db      13,10,13,10
        db      '       Желаю доброго здоровья Вам и Вашему дисплею.'
        db      13,10,13,10,13,10,36
novga   db      13,10
        db      '                            EGA или VGA не найден !',13,10,7,13,10
        db      '                         Работа программы прекращена !',13,10,13,10,36
errpar  db      13,10
        db      '                        Ошибка в параметрах программы !',13,10,7,13,10
        db      '       Просьба применять следующие параметры:',13,10,13,10
        db      '       /H,/h или /? - Получение справочной информации,',13,10
        db      '       XX -           Время в минутах до гашения экрана в пределах',13,10
        db      '                      от 1 до 60. (по умолчанию 3 минуты).',13,10
        db      '       /OFF -         Выключение резидентной программы.',13,10
        db      '       /U  -          Освобождение памяти.',13,10,13,10
        db      '       Примеры:       CLSTIME  /H',13,10
        db      '                      CLSTIME  /OFF',13,10
        db      '                      CLSTIME  10',13,10,36
uyes    db      13,10
        db      '        Занимаемая программой память освобожденна.',13,10,13,10,36
uno     db      13,10
        db      '        Нет возможности освободить занимаемую программой память.'
        db      13,10,7,13,10
        db      '        Программа выключенна.',13,10,13,10,36
uer     db      13,10
        db      '        Программа отсутствует в оперативной памяти !',13,10,13,10,36

END
