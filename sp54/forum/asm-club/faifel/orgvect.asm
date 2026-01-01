page 64,132
code      segment
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░                                                              ░░░░
;░░░░          Определение оригинальных векторов прерываний        ░░░░
;░░░░                                                              ░░░░
;░░░░   Программа  спрашивает имя файла, в котором будут сохранены ░░░░
;░░░░   векторы и переписывает загрузчик дискеты "A". По соображе- ░░░░
;░░░░   ниям безопасности  лучше  задавать имя файла на диске "A". ░░░░
;░░░░                                                              ░░░░
;░░░░                                          Файфель Б.Л.        ░░░░
;░░░░                                                              ░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
          assume cs:code,ds:code
          org    100h
Start:
          jmp    Real_beg         ; Обход области констант
           
off_13    dw     0                ; Смещение старого прерывания
seg_13    dw     0                ; Сегмент  старого прерывания

Dl_       db     0                ; Область  регистров
Dh_       db     0                ; Область  регистров
Cl_       db     0                ; Область  регистров
Ch_       db     0                ; Область  регистров

Key_buf   db     80               ; Буфер для ввода имени файла
K_byte    db     00               ; с клавиатуры
File_name db     81 dup (00)      ; Имя файла
Err_count db     00               ; Счетчик ошибок
Handle    dw     00               ; Хэндл

;░░░░░░░░░░░░░░░░░░   Сообщения программы  ░░░░░░░░░░░░░░░░░░░░░

Msg       db     'This programm was written by Boris L. Faifel 1992 Saratov.'
          db     0dh,0ah
          db     'Input file name',0dh,0ah,'$'
Err1      db     'Error by open file',0dh,0ah,'$'
Err2      db     'Error by reading',0dh,0ah,'$'
Err3      db     'Error by creating',0dh,0ah,'$'
Err4      db     'Error by writing',0dh,0ah,'$'
Err5      db     'Error by reading the BOOT-RECORD',0dh,0ah,'$'
Err6      db     'Error by writing the BOOT-RECORD',0dh,0ah,'$'
Err7      db     'The first sector of the file is the last on the track !'
          db      0dh,0ah
          db     'Input new file name and delete old file when program '
          db     'completed',0dh,0ah,'$'

Buffer    db     1024 dup (66)        ; Буфер обмена

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░              Префикс к прерыванию 13h                   ░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
New_13:
          mov    cs:Cl_,cl            ; запоминаем
          mov    cs:Ch_,ch            ;  все
          mov    cs:Dl_,dl            ;   регистры
          mov    cs:Dh_,dh            ;
          jmp    dword ptr cs:Off_13  ; и уходим на обычную обраб.

;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒▒▒▒            Действительное начало программы             ▒▒▒▒▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

Real_beg:

          mov    ah,09h               ; функция 09 - вывести строку
          mov    dx,Offset Msg        ;
          int    21h                  ; Выводим приглашение
GFN:
          mov    ah,0ah               ; функция 0а - ввести строку
          mov    dx,Offset Key_buf    ; dx:=@(буфера)
          int    21h                  ; вводим
          mov    ah,K_byte            ; ah:=сколько байтов ввели
          cmp    ah,01                ; если непустой ввод
          jne    OK0                  ; идем дальше
          int    20h                  ; иначе - стоп

OK0:
          xor    ax,ax                ; ax:=0
          mov    al,K_byte            ; al:=к-во введенных байтов (с ВК)
          mov    bx,Offset File_name  ;
          add    bx,ax                ;
          mov    [bx],byte ptr 00     ; занесем нуль на место ВК

          mov    ah,3Ch               ; функция 3C - создать файл
          mov    dx,Offset File_name  ;
          xor    cx,cx                ;
          int    21h                  ; создаем
          jnc    OK3                  ; если создался - идем дальше

          mov    ah,09h               ; иначе выведем сообщение
          mov    dx,Offset Err3       ; об ошибке создания
          int    21h                  ;
          int    20h                  ; и конец ...

OK3:
          mov    bx,ax                ; файл создан - запомним хэндл
          mov    ah,40h               ; функция 40  - писать
          mov    dx,Offset Buffer     ; смещение буфера
          mov    cx,1024              ; длина буфера
          int    21h                  ; пишем
          jnc    OK4                  ; если успешно - идем дальше

          mov    ah,09h               ; иначе - выведем сообщение
          mov    dx,Offset Err4       ; об ошибке
          int    21h                  ;
          int    20h                  ; и конец ...

OK4:

          mov    ah,3Eh               ; закроем файл
          int    21h                  ;

          cli                         ; запретим прерывания
          xor    ax,ax                ; устанавливаем
          mov    es,ax                ; префикс
          mov    bx,es:[4ch]          ; к 13-у
          mov    Off_13,bx            ; прерыванию
          mov    bx,es:[4eh]          ;
          mov    Seg_13,bx            ;
          mov    bx,cs                ;
          mov    es:[4eh],bx          ;
          mov    bx,Offset New_13     ;
          mov    es:[4ch],bx          ;
          sti                         ; разрешаем прерывания

          mov    ah,0dh               ; функция 0d - сброс диска
          int    21h                  ;

          mov    ah,3Dh               ; открываем
          xor    al,al                ; только что
          mov    dx,Offset File_name  ; созданный
          int    21h                  ; файл
          jnc    OK1                  ; если успешно - идем дальше

          mov    ah,09h               ; выведем сообщение
          mov    dx,Offset Err1       ; об ошибке открытия
          int    21h                  ;
          inc    Err_count            ; и увеличим счетчик ошибок
          jmp    Exit                 ; на завершение

OK1:
          mov    Handle,ax            ; если открылся успешно - запомним
                                      ; хэндл
          mov    bx,Handle            ; и тут же в BX его ...
          mov    ah,3Fh               ; пробуем прочитать
          mov    cx,word ptr 2        ; 2 байта (именно сейчас произойдет
          mov    dx,Offset Buffer     ; неявное обращение к int 13h и пре-
          int    21h                  ; фикс запомнит абс. адрес файла !!!)
          jnc    Exit                 ; если прочитали успешно - на заверш.

          mov    ah,09h               ; иначе выведем сообщение об ошибке
          mov    dx,Offset Err2       ;
          int    21h                  ;
          inc    Err_count            ; увеличим счетчик ошибок
          jmp    Exit                 ; и на завершение

Exit:
          mov    bx,Offset l0         ; занесем в загрузчик
          inc    bx                   ; полученный
          mov    ah,Dl_               ; от префикса
          mov    [bx],ah              ; абсолютный
          mov    bx,Offset l1         ; адрес
          inc    bx                   ; файла,
          mov    ah,Dh_               ; в котором
          mov    [bx],ah              ; после
          mov    bx,Offset l2         ; загрузки
          inc    bx                   ; с "A"
          mov    ah,Cl_               ; будут
          mov    [bx],ah              ; находиться
          mov    bx,Offset l3         ; оригинальные
          inc    bx                   ; вектора
          mov    ah,Ch_               ; всех
          mov    [bx],ah              ; прерываний

          cli                         ; теперь
          xor    ax,ax                ; восстановим
          mov    es,ax                ; старое
          mov    bx,Off_13            ; int 13h
          mov    es:[4ch],bx          ; т.к. префикс
          mov    bx,Seg_13            ; нам больше
          mov    es:[4eh],bx          ; не нужен ...
          sti                         ;

          mov    ah,Err_count         ; Проверим счетчик
          cmp    ah,0                 ; ошибок
          je     OK5                  ; если ошибок не было - идем дальше
          int    20h                  ; а иначе - конец ...

OK5:
          mov    ah,3Eh               ; закроем файл
          mov    bx,Handle            ;
          int    21h                  ;

          xor    ax,ax                ; сброс дисковой
          int    13h                  ; системы

          push   ds                   ; es:=
          pop    es                   ;     ds

          mov    cx,5                 ; будем пытаться читать BOOT-сектор
          push   cx                   ; пять раз

ReadBoot:

          mov    ah,02                ; функция 02 - читать сектор
          mov    al,01                ; физический
          mov    dl,00                ; адрес
          mov    dh,00                ; BOOT
          mov    ch,00                ; сектора
          mov    cl,1                 ; дискеты
          mov    bx,Offset Buffer     ; адрес буфера
          int    13h                  ;
          jnc    OK6                  ; успешно - идем дальше
          pop    cx                   ; иначе   - повторим попытку
          dec    cx                   ; cx:=cx-1
          push   cx                   ; запомним cx
          cmp    cx,0                 ; попытки не исчерпаны ???
          jne    ReadBoot             ; пока нет

          mov    ah,09h               ; а если исчерпаны - то
          mov    dx,Offset Err5       ; сообщим об этом
          int    21h                  ;
          int    20h                  ; и конец ...

OK6:
          mov    ah,Buffer+24         ; число секторов на дорожку
          cmp    ah,CL_               ; сравним с DH_ из префикса
          jne    OK6A                 ; все нормально

          mov    ah,09h               ; а если нет -
          mov    dx,Offset Err7       ; сообщим об этом
          int    21h                  ;
          jmp    GFN
OK6A:
          mov    si,Offset My_Boot    ; смещение нашего загрузчика в прогр.
          mov    di,Offset Buffer     ; смещение прочитанного с дискеты
          mov    [di+0],byte ptr 0EBh ; команда перехода
          mov    [di+1],byte ptr 028h ; на код нашего
          mov    [di+2],byte ptr 090h ; загрузчика
          add    di,word ptr 2Ah      ; смещ. начала кода нашего загр.
          mov    cx,512               ; будем копировать 512 байтов

Copy_byte:

          mov    ah,[si]              ; взяли байт
          mov    [di],ah              ; положили байт
          inc    si                   ; NEXT
          inc    di                   ; NEXT
          loop   Copy_byte            ; конец цикла

          mov    [di-2],byte ptr 055h ; признак BOOT-сектора
          mov    [di-1],byte ptr 0AAh ; как в лучших домах Филадельфии ...

          mov    bx,Offset l0         ; настроим копию загрузчика
          inc    bx                   ; на созданный ранее файл
          mov    ah,Dl_               ;
          mov    [bx],ah              ;
          mov    bx,Offset l1         ;
          inc    bx                   ;
          mov    ah,Dh_               ;
          mov    [bx],ah              ;
          mov    bx,Offset l2         ;
          inc    bx                   ;
          mov    ah,Cl_               ;
          mov    [bx],ah              ;
          mov    bx,Offset l3         ;
          inc    bx                   ;
          mov    ah,Ch_               ;
          mov    [bx],ah              ;

          xor    ax,ax                ; сброс дисковой
          int    13h                  ; системы

          push   ds                   ; es:=
          pop    es                   ;  ds
          mov    di,Offset Buffer     ;
          add    di,word ptr 510      ; di указывает на конец BOOT-сектора
          mov    [di+0],byte ptr 055h ; признак BOOT-сектора
          mov    [di+1],byte ptr 0AAh ; как в лучших домах Филадельфии ...

          mov    cx,5                 ; будем пытаться записать
          push   cx                   ; BOOT-сектор 5 раз

WriteBoot:

          mov    ah,03                ; код 03 - писать
          mov    al,01                ; физический
          mov    dl,00                ; адрес
          mov    dh,00                ; BOOT-сектора
          mov    ch,00                ; дискеты
          mov    cl,1                 ;
          mov    bx,Offset Buffer     ; адрес буфера
          int    13h                  ; пишем ...
          jnc    OK7                  ; если успешно - идем дальше
          pop    cx                   ; иначе - повторим попытку
          dec    cx                   ; cx:=cx-1
          cmp    cx,0                 ; счетчик попыток исчерпан ???
          je     ErrWrit              ; да - сообщим об ошибке
          push   cx                   ; запомним сх
          jmp    WriteBoot            ; нет - пробуем еще раз ...

ErrWrit:

          mov    ah,09h               ; сообщение о последней ошибке
          mov    dx,Offset Err6       ;
          int    21h                  ;
OK7:
          int    20h                  ; ЭТО - КОНЕЦ !!!!

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░     Код загрузчика (без таблицы параметров дискеты)    ░░░░░░
;░░░░░              Размещается со смещения 7C2Ah             ░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

My_Boot:

          cli                      ; Обычные действия по
          xor    ax,ax             ; установке
          mov    ss,ax             ; указателя
          mov    es,ax             ; стека,
          mov    ds,ax             ; которые выполняются в
          mov    sp,7C00h          ; любом загрузчике
          sti                      ;

          mov    di,Beg_Txt4       ; выводим вопрос о сохранении
          mov    si,OutString      ; векторов прерываний
          call   si                ;
          cmp    al,79h            ; проверим ответ (Y-да, все ост-нет)
          jne    TestLock          ; сохранять не нужно

SaveVectors:

          xor    ax,ax             ; сброс дисковой
          int    13h               ; системы

          mov    ah,03             ; функция 03 - писать на диск
          mov    al,02             ; два сектора
l0:                                ; Следующие далее команды задают
          mov    dl,00             ; физический адрес начала файла
l1:                                ; Они модифицируются программой
          mov    dh,00             ; ранее
l2:                                ;
          mov    cl,00             ;
l3:                                ;
          mov    ch,00             ;

          xor    bx,bx             ; буфер располагается с начала ОЗУ
          int    13h               ; пишем
          jnc    OKWB              ; если нормально - идем дальше

          mov    di,Beg_Txt3       ; выведем сообщение о неудаче
          mov    si,OutString      ;
          call   si                ;
          jmp    SaveVectors       ; пробуем еще раз ...

OKWB:
          mov    di,Beg_Txt2       ; сообщим об успешном сохранении
          mov    si,OutString      ; таблицы векторов
          call   si                ;

TestLock:

          mov    ax,0201h          ; пробуем снова прочитать
          mov    cx,0001h          ; тот же сектор с "A", чтобы
          mov    dx,0000h          ; убедиться, что "A" - не готов
          mov    bx,7E00h          ;
          int    13h               ;
          jc     Reboot            ; "A" не готов - на загрузку с "C"

          mov    di,Beg_txt1       ; "A" готов - попросим сбросить
          mov    si,OutString      ; готовность
          call   si                ;
          jmp    TestLock          ; и опять проверим ...

Reboot:
          int    19h               ; ПЕРЕЗАГРУЗКА С "C"

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░    Внутренняя программа вывода строки и ввода ответа   ░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Signal:
OutString equ    (Signal-My_Boot+7C2Ah)
          mov    bx,word ptr 07    ; символ-атрибут
          mov    ah,0eh            ; код функции
Out_byte:
          mov    al,[di]           ; берем оч. байт
          or     al,al             ; конец строки ???
          jz     Wait_key          ; да - на ввод кода
          int    10h               ; нет - выведем символ
          inc    di                ; и берем
          jmp    short Out_byte    ; следующий
Wait_key:
          xor    ax,ax             ;
          int    16h               ; ждем нажатия клавиши
          ret                      ; возврат

Txt2      db     'Vectors have been succsessfully saved.',0dh,0ah
Beg_txt2  equ    (Txt2-My_Boot+7C2Ah)
Txt1      db     'Unlock drive "A" and press any key for '
          db     'loading the system from hard disk.',0dh,0ah,00b
Beg_txt1  equ    (Txt1-My_Boot+7C2Ah)
Txt3      db     'Error during saving vectors !',0dh,0ah,00h
Beg_txt3  equ    (Txt3-My_Boot+7C2Ah)
Txt4      db     'Do you wish to save the vectors ? (Y/N)',0dh,0ah,00
Beg_txt4  equ    (Txt4-My_Boot+7C2Ah)
          db     162 dup (00)
code      ends
          end    Start
