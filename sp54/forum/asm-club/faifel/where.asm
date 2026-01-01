page 64,132
code      segment
          assume cs:code,ds:code
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░                                                           ░░░░
;░░░░         Определение абсолютного адреса начала файла       ░░░░
;░░░░                                                           ░░░░
;░░░░                                        Файфель Б.Л.       ░░░░
;░░░░                                                           ░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
          org    100h
Start:
          jmp    Real_beg                      ; Обход области констант
off_13    dw     0                             ; смещение 13-го прерывания
seg_13    dw     0                             ; сегмент  13-го прерывания
Head      db     0                             ; головка
Sector    db     0                             ; сектор
Cyl       dw     0                             ; цилиндр
Key_buf   db     80                            ; буфер для ввода имени файла
K_byte    db     00                            ; длина введенного имени (+ВК)
File_name db     81 dup (00)                   ; имя файла
Buff      db     02 dup (00)                   ; сюда читается 2 байта
Msg       db     'This program was written by' ; Приглашение
          db     ' Boris L. Faifel'            ; к
          db     ' 1992 Saratov'               ; вводу
          db     0dh,0ah                       ; имени
          db     'Input file name',0dh,0ah,'$' ; файла
NF        db     'File='                       ; Макет
Glob_msg  db     'Cyl ='                       ; вывода
C_HEX     db     '    ',0dh,0ah                ; результата
          db     'Head='                       ;
H_HEX     db     '  ',0dh,0ah                  ;
          db     'Sec ='                       ;
S_HEX     db     '  ',0dh,0ah,'$'              ;
Symtab    db     '0123456789ABCDEF'            ; таблица символов
Err1      db     'File not found',0dh,0ah,'$'  ; файл не найден
Err2      db     'Error by reading',0dh,0ah,'$'; ошибка при чтении

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░                  Префикс к 13-у прерыванию                  ░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

New_13:
          push   ax                  ; сохраняем все
          push   bx                  ; изменяемые
          push   cx                  ; далее
          push   dx                  ; регистры
          mov    cs:Head,dh          ; заносим номер головки
          mov    dl,cl               ; выделяем номер сектора
          and    dl,00111111B        ; (6 младших бит)
          mov    cs:Sector,dl        ; и заносим
          mov    ax,cx               ; ax:=cx
          and    al,11000000B        ; выделяем два старших бита номера CYL
          mov    cl,6                ; сдвигаем на 6 разрядов
          shr    al,cl               ; вправо
          xchg   al,ah               ; сейчас в AX - полный номер CYL
          mov    cs:Cyl,ax           ; занесем его на место
          pop    dx                  ; восстановим
          pop    cx                  ; регистры
          pop    bx                  ;
          pop    ax                  ;
Old_int:                             ;
          jmp    dword ptr cs:Off_13 ; и уходим в обработчик int 13h

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░         Внутренняя программа преобазования BIN -> HEX       ░░░░
;░░░░         исходный байт в AH; место для результата в SI       ░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Conv_byte:

          mov    al,ah              ; сохраним исходный байт
          and    ah,0f0h            ; выделим старшую тетраду
          mov    cl,4               ; сдвинем на 4 разряда
          shr    ah,cl              ; вправо
          xor    dx,dx              ; dx:=0
          mov    dl,ah              ; dl:=выделенная тетрада
          mov    di,Offset Symtab   ; смещение таблицы символов
          add    di,dx              ; di указывает на HEX-символ
          mov    ah,[di]            ; берем его в ah
          mov    [si],ah            ; и кладем на место
          inc    si                 ; si:=si+1
          mov    ah,al              ; вспомним исходный байт
          and    ah,00fh            ; выделим младшую тетраду
          xor    dx,dx              ; получим
          mov    dl,ah              ; соответствующий
          mov    di,Offset Symtab   ; HEX-символ
          add    di,dx              ; и занесем
          mov    ah,[di]            ; его в
          mov    [si],ah            ; целевую строку
          inc    si                 ; si:=si+1
          ret                       ; возврат

Real_beg:

          cli                       ;\
          xor    ax,ax              ; \
          mov    es,ax              ;  \
          mov    bx,es:[4ch]        ;   \
          mov    Off_13,bx          ;    \
          mov    bx,es:[4eh]        ;     I установка префикса к
          mov    Seg_13,bx          ;     I int 13h
          mov    bx,cs              ;    /
          mov    es:[4eh],bx        ;   /
          mov    bx,Offset New_13   ;  /
          mov    es:[4ch],bx        ; /
          sti                       ;/

          mov    ah,09h             ; выведем приглашение
          mov    dx,Offset Msg      ; к вводу
          int    21h                ;

          mov    ah,0ah             ; Вводим
          mov    dx,Offset Key_buf  ; имя
          int    21h                ; файла
          mov    ah,K_byte          ; и проверяем
          cmp    ah,01              ; не пуст ли ввод
          jne    OK0                ; не пуст - идем дальше
          jmp    Exit               ; пуст - конец

OK0:
          xor    ax,ax              ; найдем конец имени
          mov    al,K_byte          ; и занесем вместо
          mov    bx,Offset File_name; кода ВК
          add    bx,ax              ; двоичный
          mov    [bx],byte ptr 00   ; нуль
 
          mov    ah,0dh             ; сброс
          int    21h                ; диска (разгрузка буферов)

          mov    ah,3Dh             ; функция 3D - открыть файл
          xor    al,al              ; по чтению
          mov    dx,Offset File_name; имя файла
          int    21h                ;
          jnc    OK1                ; успешно открылся - идем дальше

          mov    ah,09h             ; иначе сообщим об ошибке
          mov    dx,Offset Err1     ;
          int    21h                ;
          jmp    Exit               ; и конец ...
OK1:
          mov    bx,ax              ; берем хэндл файла
          mov    ah,3Fh             ; функция 3F - читать
          mov    cx,word ptr 2      ; 2 байта
          mov    dx,Offset Buff     ; в буфер
          int    21h                ; читаем

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░   Именно сейчас произойдет неявное обращение к 13-у прерыванию  ░░░
;░░░   и префикс зафиксирует начало файла !!!                        ░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

          jnc    OK2                ; прочитали успешно - идем дальше

          mov    ah,09h             ; нет - сообщим
          mov    dx,Offset Err2     ; об этом
          int    21h                ;
          jmp    Exit               ; и конец ...

OK2:

          mov    ah,3Eh             ; теперь файл можно закрыть
          int    21h                ;

          mov    si,Offset NF       ; выведем заголовок
          mov    cx,5               ; используя 2-ю функцию
          mov    ah,02h             ; DOS
GetPut1:
          mov    dl,[si]            ; берем оч. байт
          int    21h                ; и выводим
          inc    si                 ; следующий
          loop   GetPut1            ; конец цикла

          mov    si,Offset File_name; аналогично выводим
          mov    cx,80              ; имя файла
          mov    ah,02h             ;
GetPut2:
          mov    dl,[si]            ; оч. символ имени
          cmp    dl,00h             ; это - нуль ???
          je     OK3                ; да - конец имени
          int    21h                ; нет - выводим
          inc    si                 ;
          loop   GetPut2            ;
OK3:
          mov    dl,0dh             ; организуем
          mov    ah,02h             ; возврат каретки
          int    21h                ; и
          mov    dl,0ah             ; перевод строки
          mov    ah,02h             ;
          int    21h                ;
 
          mov    ax,Cyl             ; Преобразуем номер цилиндра
          mov    si,Offset C_HEX    ;
          call   conv_byte          ;
          mov    ax,Cyl             ;
          mov    ah,al              ;
          call   conv_byte          ;

          mov    ah,Head            ; Преобразуем номер головки
          mov    si,Offset H_HEX    ;
          call   conv_byte          ;

          mov    ah,Sector          ; Преобразуем номер сектора
          mov    si,Offset S_HEX    ;
          call   conv_byte          ;

          mov    ah,09h             ; выводим сообщение на экран
          mov    dx,Offset Glob_msg ;
          int    21h                ;

Exit:
          cli                       ; и восстановим
          xor    ax,ax              ; исходный
          mov    es,ax              ; вектор
          mov    bx,Off_13          ; int 13h
          mov    es:[4ch],bx        ;
          mov    bx,Seg_13          ;
          mov    es:[4eh],bx        ;
          sti                       ;

          int    20h                ; конец программы

code      ends
          end    Start
