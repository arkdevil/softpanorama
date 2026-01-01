title   KillFile.com    Удаление файлов без возможности восстановления
;       MASM 5.0
codesg  segment para 'Code'
assume  cs:codesg,ds:codesg,ss:codesg,es:codesg
        org     100h
main    proc    near
;---------------------------------------
        call    SpErase ;Удаляем конечные пробелы в командной строке
        mov     al,ds:[80h];Если длина командной строки 0, выводим краткую
        cmp     al,00   ;  справку и выходим в систему
        jnz     m02
        call    Info
m02:    mov     ah,43h  ;Снимаем с файла все атрибуты
        mov     al,01
        sub     cx,cx
        mov     dx,0082h
        int     21h
        jnc     m03
        call    ErRead  ;Вывод сообщения об ошибке и выход в систему
m03:    mov     ah,3Dh  ;Открываем файл для ввода и вывода
        mov     al,02
        mov     dx,0082h
        int     21h
        jnc     m05
        call    ErRead  ;Если ошибка, сообщаем и выходим в систему
m05:    mov     Handl,ax;Запоминаем файловый номер
        mov     ah,42h  ;Определяем размер файла (в dx:ax)
        mov     al,02
        mov     bx,Handl
        sub     cx,cx
        sub     dx,dx
        int     21h
        mov     bx,8000h;Делим размер файла на 32768 (32 kB)
        div     bx
        mov     Blocks,ax;Запоминаем число блоков в файле по 32 kB
        mov     Remain,dx;Запоминаем остаток от деления
        lea     di,EndPrg;Затираем область за программой
        mov     cx,7FFFh
m06:    inc     di
        mov     word ptr [di],0FFFFh
        loop    m06
        mov     ah,3Ch  ;Создаем файл на месте старого
        sub     cx,cx   ;  (без атрибутов)
        mov     dx,0082h
        int     21h
        mov     Handl,ax;Затираем прежний файловый номер
m04:    mov     cx,8000h;Если число блоков по 32 kB в файле равно 0, то
        cmp     Blocks,0000;  устнавливаем длину записи, равной остатку от
        jnz     m01     ;  деления размера файла на 32768, иначе устанавливаем
        mov     cx,Remain;  длину записи 32768 байт
        mov     Quit,01 ;Указывает на то, что затирание окончено
m01:    mov     ah,40h  ;Пишем в файл коды этой программы и символ FFh
        mov     bx,Handl
        mov     dx,0100h
        int     21h
        jnc     m07
        call    ErWrite;В случае ошибки собщаем об этом и выходим в систему
m07:    mov     ax,Blocks;Уменьшаем число оставшихся блоков на 1
        dec     ax
        mov     Blocks,ax
        cmp     Quit,01 ;Если в файл записан и остаток, тогда - выход из цикла
        jnz     m04
        mov     ah,57h  ;Устанавливаем дату создания файла 22 июля 1993 г.,
        mov     al,01   ;  время 0 часов 0 минут, чтобы было непонятно, когда
        mov     bx,Handl;  производилось стирание
        sub     cx,cx
        mov     dx,1AF6h
        int     21h
        mov     ah,3Eh  ;Закрываем файл
        mov     bx,Handl
        int     21h
        mov     ah,41h  ;Удаляем файл
        mov     dx,0082h
        int     21h
        mov     ah,09   ;Выводим сообщение "Killed file "
        lea     dx,Msg
        int     21h
        mov     bx,Indic;Дописываем к предидущему сообщению имя файла
        mov     [bx],byte ptr 0Dh
        inc     bx
        mov     [bx],byte ptr 0Ah
        inc     bx
        mov     [bx],byte ptr '$'
        mov     ah,09   ;  (выводим имя файла на экран)
        mov     dx,0082h
        int     21h
        ret
;---------------------------------------
SpErase proc    near    ;Процедура удаления конечных пробелов командной строки.
                        ;Заменяет символ RETURN на символ с кодом 00
        mov     si,0080h;Указываем на начало командной строки
SE1:    inc     si      ;Увеличиваем указатель, пока не дойдем до RETURN
        cmp     byte ptr [si],0Dh
        jnz     SE1
SE3:    mov     byte ptr [si],00;Заменяем RETURN на символ с кодом 00
        dec     si      ;Если перед символом RETURN находится пробел (20h),
        cmp     byte ptr [si],20h       ;  записываем на его место RETURN,
        jnz     SE2                     ;  иначе - выходим из процедуры
        mov     byte ptr [si],0Dh
        mov     al,ds:[80h]     ;Уменьшаем количество символов командной
        dec     al              ;  указанное в байте по адресу 80h, на единицу
        mov     ds:[80h],al
        jmp     SE3
SE2:    inc     si
        mov     Indic,si;Запоминаем смещение конца командной строки
        ret
SpErase endp
;---------------------------------------
Info    proc    near    ;Процедура вывода краткой справки о программе и выхода
        mov     ah,09   ;  в систему
        lea     dx,Info1
        int     21h
        int     20h
Info    endp
;---------------------------------------
ErRead  proc    near    ;Процедура вывода сообщения "Error while reading file"
        mov     ah,09   ;  и выхода в систему
        lea     dx,Err1
        int     21h
        int     20h
ErRead  endp
;---------------------------------------
ErWrite proc    near    ;Процедура вывода сообщения "Error while writing file"
        mov     ah,09   ;  и выхода в систему
        lea     dx,Err2
        int     21h
        int     20h
ErWrite endp
;---------------------------------------
;       Данные
Info1   db      0Dh,0Ah,'KillFile  (c) A!V!N  1993',0Dh,0Ah
        db      'Destroy file without possibility of unerasing',0Dh,0Ah
        db      'Data would lost FOREVER !',0Dh,0Ah
        db      0Dh,0Ah,'Usage: kf filename.ext', 0Dh,0Ah,'$'
Absent1 db      0Dh,0Ah,'File not found',0Dh,0Ah,'$'
Err1    db      0Dh,0Ah,'Error while reading file',0Dh,0Ah,'$'
Err2    db      0Dh,0Ah,'Error while writing file',0Dh,0Ah,'$'
Msg     db      0Dh,0Ah,'Killed file ','$'
Handl   dw      0000    ;Файловый номер
Blocks  dw      0000    ;Число блоков по 32 kB в файле
Remain  dw      0000    ;Остаток от деления размера файла на 32768
Quit    db      00      ;Значение 1 указывает, что затирание окончено
Indic   dw      0000    ;Указывает смещение конца командной строки
EndPrg  db      00      ;Этот байт указывает на конец программы
;---------------------------------------
main    endp
codesg  ends
        end     main
