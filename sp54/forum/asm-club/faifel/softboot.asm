page 64,132
code      segment
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒▒▒                                                               ▒▒▒▒
;▒▒▒▒           Мягкая перезагрузка с выбранного накопителя         ▒▒▒▒
;▒▒▒▒                                                               ▒▒▒▒
;▒▒▒▒   Программа позволяет загрузиться  с  выбранного  накопителя  ▒▒▒▒
;▒▒▒▒   без обращения к загрузчику из BIOS.  Для успешного функци-  ▒▒▒▒
;▒▒▒▒   онирования необходимо наличие файла VECTORS.ORG  в доступ-  ▒▒▒▒
;▒▒▒▒   ной директории. Этот файл, содержащий оригинальные векторы  ▒▒▒▒
;▒▒▒▒   прерываний из BIOS'а, может быть получен с помощью утилит-  ▒▒▒▒
;▒▒▒▒   ки ORGVECT.                                                 ▒▒▒▒
;▒▒▒▒                                          Файфель Б.Л.         ▒▒▒▒
;▒▒▒▒                                                               ▒▒▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
          assume cs:code,ds:code
          org    100h
start:
          jmp    Real_beg             ; Обход области констант

          db  'This programm was written by Boris L. Faifel in 1992'
File_name db  'vectors.org',00
Frame1    db  '╔════╡ Choose drive for loading ╞════╗'
          db  '║                                    ║'
          db  '║           A      B      C          ║'
          db  '║                                    ║'
          db  '╚════════════════════════════════════╝'
Frame2    db  '╔════════════════════════════════════╗'
          db  '║                                    ║'
          db  '║     File VECTORS.ORG not found     ║'
          db  '║                                    ║'
          db  '╚════════════════════════════════════╝'
Frame3    db  '╔════════════════════════════════════╗'
          db  '║                                    ║'
          db  '║  Error during reading VECTORS.ORG  ║'
          db  '║                                    ║'
          db  '╚════════════════════════════════════╝'
Frame4    db  '╔════════════════════════════════════╗'
          db  '║                                    ║'
          db  '║   Error during reading MBR/BOOT    ║'
          db  '║                                    ║'
          db  '╚════════════════════════════════════╝'

SaveArea  db  380 dup (00)                  ; Область сохранения экрана
Vectors   dd  512 dup (66H)                 ; Буфер для векторов
Attr      db  00                            ; Атрибут при выводе боксов
Pos       db  00                            ;
PhysDrv   db  00                            ; Физический адрес драйв.
SigVect   db  00                            ; Признак установки векторов

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░      Внутренняя процедура сохранения куска экрана       ░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

SaveScreen:

          push    ax                       ; сохраняем
          push    bx                       ; все
          push    cx                       ; изменяемые
          push    di                       ; далее
          push    si                       ; регистры
          push    ds                       ;
          push    es                       ;

          mov     ax,0B800h                ; AX:=начало видео-озу
          mov     es,ax                    ; ES:=AX
          mov     di,Offset SaveArea       ; берем смещение начала обл.сохр.
          mov     bx,1640                  ; и смещение начала бокса
          mov     cx,word ptr 5            ; 5 строк
          push    cx                       ; запомним
SV00:
          xor     si,si                    ; si - указатель байта строки
          mov     cx,word ptr 76           ; ширина строки (с атрибутами)
SV01:
          mov     ah,es:[bx+si]            ; оч. символ (атрибут) -> AH
          mov     ds:[di],ah               ; AH -> обл. сохранения
          inc     si                       ;
          inc     di                       ;
          loop    SV01                     ; конец цикла строки
          pop     cx                       ; вспомним номер строки
          dec     cx                       ; уменьшим
          cmp     cx,word ptr 0            ; не конец ???
          jle     SV02                     ; конец
          push    cx                       ; пока нет - запомним CX
          add     bx,word ptr 160          ; переход к след. строке
          jmp     SV00                     ; продолжаем
SV02:
          pop     es                       ; восстанавливаем
          pop     ds                       ; все
          pop     si                       ; сохраненные
          pop     di                       ; регистры
          pop     cx                       ;
          pop     bx                       ;
          pop     ax                       ;
          ret                              ; и возврат ...

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░    Внутренняя процедура восстановления куска экрана     ░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

RestScreen:

          push    ax                       ; запомним
          push    bx                       ; все
          push    cx                       ; изменяемые
          push    di                       ; далее
          push    si                       ; регистры
          push    ds                       ;
          push    es                       ;

          mov     ax,0B800h                ; базируемся на начало
          mov     es,ax                    ; видеобуфера по ES
          mov     di,Offset SaveArea       ; DI указывает на нач. сохр. обл.
          mov     bx,1640                  ; BX указывает на нач. места экр.
          mov     cx,word ptr 5            ; пять строк
          push    cx                       ; запомним CX
RS00:
          xor     si,si                    ; SI - указатель строки
          mov     cx,word ptr 76           ; длина строки (с атрибутами)
RS01:
          mov     ah,ds:[di]               ; взяли байт
          mov     es:[bx+si],ah            ; занесли в видео-озу
          inc     si                       ; прирастим
          inc     di                       ; индексы-указатели
          loop    RS01                     ; конец цикла строки
          pop     cx                       ; вспомним счетчик строк
          dec     cx                       ; уменьшим
          cmp     cx,word ptr 0            ; еще не конец ???
          jle     RS02                     ; конец
          push    cx                       ; не конец - запомним счетчик
          add     bx,word ptr 160          ; к следующей строке
          jmp     RS00                     ; повторим
RS02:
          pop     es                       ; восстановим
          pop     ds                       ; все
          pop     si                       ; регистры
          pop     di                       ;
          pop     cx                       ;
          pop     bx                       ;
          pop     ax                       ;
          ret                              ; выход

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░       Внутренняя процедура вывода бокса на экран        ░░░░░
;░░░░░        Attr - атрибут; BX - адрес образа бокса          ░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

PutBox:

          push    ax                  ; запоминаем все
          push    cx                  ; регистры,
          push    di                  ; которые
          push    si                  ; будут
          push    ds                  ; меняться
          push    es                  ; программой

          mov     ax,0B800h           ; базируемся на видеобуфер
          mov     es,ax               ; по ES
          mov     di,1640             ; DI - смещение начала бокса
          mov     cx,word ptr 5       ; CX - его высота
          push    cx                  ; запомним ее как счетчик строк
          mov     al,ds:Attr          ; AL - атрибут
PUT00:
          mov     si,di               ; SI - указатель строки бокса
          mov     cx,word ptr 38      ; размер строки (без атрибутов)
PUT01:
          mov     ah,ds:[bx]          ; берем очередной байт из образа
          mov     es:[si],ah          ; заносим его в видео-озу
          mov     es:[si+1],al        ; заносим атрибут
          inc     si                  ; следующий
          inc     si                  ; сивол видео-озу
          inc     bx                  ; следующий символ образа
          loop    PUT01               ; конец цикла строки
          pop     cx                  ; вспомним счетчик строк
          dec     cx                  ; уменьшим
          cmp     cx,word ptr 0       ; конец ???
          jle     PUT02               ; да - выход
          push    cx                  ; нет - запомним счетчик
          add     di,word ptr 160     ; переходим к след. строке
          jmp     PUT00               ;
PUT02:
          pop     es                  ; восстановим
          pop     ds                  ; регистры
          pop     si                  ;
          pop     di                  ;
          pop     cx                  ;
          pop     ax                  ;
          ret                         ; выход

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░       Префикс к INT 13H       ░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Int13:

Off_13     dw      0                     ; смещение исходного int 13h
Seg_13     dw      0                     ; сегмент  исходного int 13h

           cmp     dl,00h                ; обращение к устройству "A" ???
           je      Swap_ab               ; да - переключим на "B"
           cmp     dl,01h                ; обращение к устройству "B" ???
           je      Swap_ba               ; да - переключим на "A"

           jmp     dword ptr cs:[0000H]  ; Обращение к другим не трогаем
Swap_ab:                                 ; <<<<<  A <-> B  >>>>>
           mov     dl,01h                ; подставим "B"
           pushf                         ; вызовем исх. прерывание
           call    dword ptr cs:[0000h]  ; дальним вызовом
           mov     dl,00h                ; восстановим "A"
           retf    02h                   ; и выход
Swap_ba:                                 ; <<<<<  B <-> A  >>>>>
           mov     dl,00h                ; подставим "A"
           pushf                         ; вызовем исх. прерывание
           call    dword ptr cs:[0000h]  ; дальним вызовом
           mov     dl,01h                ; восстановим "B"
           retf    02h                   ; и выход

;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓▓▓▓             Действительное начало программы               ▓▓▓▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

Real_beg:

           mov     ah,01h                ; спрячем курсор,
           mov     ch,20h                ; чтобы не мельтешил
           int     10h                   ;

           xor     ax,ax                 ; пробуем
           mov     ah,3Dh                ; открыть файл
           mov     dx,Offset File_name   ; с векторами
           int     21h                   ;
           jnc     OK0                   ; успешно - идем дальше

           call   SaveScreen             ; ошибка при открытии
           mov    bx,Offset Frame2       ; сохраним экран и выведем
           mov    ah,78                  ; сообщение об ошибке
           mov    ds:Attr,ah             ;
           call   PutBox                 ;
ERR00:
           xor    ax,ax                  ; ждем нажатия клавиши
           int    16h                    ;
           call   RestScreen             ; восстановим экран
           int    20h                    ; и конец ...

OK0:
           mov     bx,ax                 ; запомним хэндл
           mov     ah,3Fh                ; читаем
           mov     cx,1024               ; 1024 байта
           mov     dx,Offset Vectors     ; в буфер
           int     21h                   ;
           jnc     ChooseDrv             ; успешно - на выбор драйвера

           call   SaveScreen             ; ошибка - сохраним кусок экрана
           mov    bx,Offset Frame3       ; выведем
           mov    ah,78                  ; сообщение
           mov    ds:Attr,ah             ;
           call   PutBox                 ;
           jmp    ERR00                  ; и конец

ChooseDrv:

           call   SaveScreen             ; выводим
           mov    bx,Offset Frame1       ; меню выбора
           mov    ah,31                  ; драйвера
           mov    ds:Attr,ah             ; для загрузки
           call   PutBox                 ;

           mov    bx,(1649+334)          ; BX указ. область буквы на экр.
           mov    ds:PhysDrv,00          ; начинаем с "A"
           mov    ax,0b800h              ; базируемся на видео-буфер
           mov    es,ax                  ; по ES

PutSel:
           mov    es:[bx],byte ptr 78    ; устанавливаем
           mov    es:[bx+2],byte ptr 78  ; засветку
           mov    es:[bx+4],byte ptr 78  ; выбранного поля
GETKEY:
           xor    ax,ax                  ; ждем нажатия
           int    16h                    ; клавиши

           cmp    al,13                  ; ENTER ???
           jne    EscTest                ; нет - проверим, не ESAPE ли ???
           jmp    Loading                ; да  - идем на загрузку
EscTest:
           cmp    al,27                  ; ESCAPE ???
           jne    Arrows                 ; нет - проверим стрелки
           mov    ah,SigVect             ; да  - отказ от загрузки
           cmp    ah,0                   ; вектора устанавливались ???
           jne    GETKEY                 ; если ДА - то придется грузиться !

           Call   RestScreen             ; иначе - восстановим экран
           int    20h                    ; и выход в DOS
Arrows:
           cmp    ah,77                  ; Стрелка вправо ???
           je     ArrRight               ; да
           cmp    ah,75                  ; Стрелка влево  ???
           je     ArrLeft                ; да
           jmp    GETKEY                 ; все остальное игнорируем
ArrRight:
           mov    es:[bx],byte ptr 31    ; восстановим засветку выбранной
           mov    es:[bx+2],byte ptr 31  ; ранее буквы
           mov    es:[bx+4],byte ptr 31  ;

           add    bx,word ptr 14         ; перейдем к следующей букве
           inc    Pos                    ; увеличим позицию
           inc    PhysDrv                ; и номер драйвера
           mov    ah,Pos                 ; проверим, не заехали ли вправо ???
           cmp    ah,02                  ; если нет - все пока ОК
           jle    PutSel                 ;
           mov    bx,(1649+334)          ; иначе встанем на букву "A"
           xor    ah,ah                  ; обнулим
           mov    Pos,ah                 ; позицию
           mov    PhysDrv,ah             ; и драйвер
           jmp    PutSel                 ;
ArrLeft:
           mov    es:[bx],byte ptr 31    ; восстановим засветку выбранной
           mov    es:[bx+2],byte ptr 31  ; ранее буквы
           mov    es:[bx+4],byte ptr 31  ;

           sub    bx,word ptr 14         ; вернемся к предыдущей букве
           dec    Pos                    ; уменьшим позицию
           dec    PhysDrv                ; и номер драйвера
           mov    ah,Pos                 ; проверим, не заехали ли
           cmp    ah,0ffh                ; левее "A"
           je     CONT0                  ;
           jmp    PutSel                 ; нет - все ОК
CONT0:
           mov    bx,(1649+334+28)       ; встанем на букву "C"
           mov    ah,02                  ; установим код "C"
           mov    Pos,ah                 ; позицию
           mov    PhysDrv,ah             ; и драйвер
           jmp    PutSel                 ;

;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒▒▒▒                      Блок загрузки                      ▒▒▒▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

Loading:

          cli                            ; установим оригинальные
          xor       ax,ax                ; вектора
          mov       es,ax                ; прерываний (всех !)
          mov       cx,1024              ; которые
          xor       di,di                ; ранее
          mov       si,Offset vectors    ; считаны
CopyVect:                                ; из
          mov       ah,ds:[si]           ; файла
          mov       es:[di],ah           ;
          inc       si                   ;
          inc       di                   ;
          Loop      CopyVect             ;
          sti                            ;

          mov       ah,0ffh              ; установим признак
          mov       SigVect,ah           ; изменения векторов

          mov       ah,PhysDrv           ; берем физ. драйвер
          cmp       ah,00                ; это "A" ???
          je        ReadBoot             ; да - на чтение загрузчика
          cmp       ah,02                ; это "C" ???
          je        Hard                 ; да - на загрузку с жесткого диска
          xor       ah,ah                ; для "B" установим код "A"
          mov       PhysDrv,ah           ;
          jmp       SWAB                 ; и включим префикс к int 13h
Hard:
          mov       ah,80h               ; для жесткого диска достаточно
          mov       PhysDrv,ah           ; лишь установить истиный код устр.
          jmp       ReadBoot             ; и можно загружаться
SWAB:
          xor       ax,ax                ; запоминаем
          mov       es,ax                ; точку
          mov       bx,es:[004ch]        ; входа
          mov       Off_13,bx            ; в INT 13h
          mov       bx,es:[004eh]        ;
          mov       Seg_13,bx            ;

          push      ds                   ; запомним DS

          mov       ds,ax                ; ds:=0
          mov       ax,es:[413h]         ; объем памяти в К
          dec       ax                   ; отщепим 1К
          mov       es:[413h],ax         ; и установим
          mov       cl,6                 ; получим
          shl       ax,cl                ; сегмент этого
          mov       es,ax                ; участка в ES
          mov       ax,04h               ;
          mov       ds:[004ch],ax        ; установим новый вектор
          mov       ds:[004eh],es        ; INT 13h на этот участок

          pop       ds                   ; вспомним DS

          mov       si,offset Int13      ; копируем
          mov       cx,100               ; в украденную у DOS
          xor       di,di                ; память
CPB:
          mov       ah,ds:[si]           ; наш префикс
          mov       es:[di],ah           ; к 13-у прерыванию
          inc       si                   ;
          inc       di                   ;
          loop      CPB                  ;

ReadBoot:
          xor       ax,ax                ; сброс дисковой системы
          int       13h                  ;
          xor       ax,ax                ; ES - сегмент
          mov       es,ax                ; куда будет читаться BOOT-сектор
          mov       bx,7C00h             ; а это - смещение
          mov       dl,PhysDrv           ; физ. драйвер
          mov       dh,0                 ; координаты
          mov       ch,00                ; BOOT/MBR
          mov       cl,01                ; записи
          mov       ah,02                ; читать
          mov       al,01                ; 1 сектор
          int       13h                  ; читаем ...
          jnc       GOTOBOOT             ; если успешно - переходим в BOOT

          mov       bx,Offset Frame4     ; иначе выведем
          mov       ah,78                ; боксик с сообщением
          mov       ds:Attr,ah           ; об ошибке
          call      PutBox               ;
          xor       ax,ax                ; дождемся нажатия клавиши
          int       16h                  ;
          jmp       ChooseDrv            ; и снова на выбор драйвера

GOTOBOOT:
          xor       ax,ax                ; заносим в стек сегмент
          push      ax                   ;
          mov       ax,7C00h             ; и смещение BOOT/MBR - записи
          push      ax                   ;
          retf                           ; и в нее ...

code      ends
          end    start
