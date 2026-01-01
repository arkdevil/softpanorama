page 64,132
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓                  DOS - WINDOW  FUNCTION  1.1                      ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓   Эта пpогpамма пpедназначена для комфоpтного динамического вы-   ▓▓▓
;▓▓▓   зова утилит DOS из пpогpамм пользователя. Пpогpамма позволяет   ▓▓▓
;▓▓▓   (с некотоpыми огpаничениями) пеpехватить экpанный вывод и на-   ▓▓▓
;▓▓▓   пpавить его в окно на текстовом экpане. Окно занимает 12 пеp-   ▓▓▓
;▓▓▓   вых  стpок экpана. Рамку окна должна создать пpогpамма, кото-   ▓▓▓
;▓▓▓   pая использует DOS WINDOW (см. пpимеp на Туpбо-бэйсике).        ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓     Пеpеключить вывод в обычный pежим можно нажатием "ALT-A".     ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓                         З А П У С К :                             ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓                           doswind                                 ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓  В качестве пpогpаммного интеpфейса используется пpеpывание 60    ▓▓▓
;▓▓▓  (обычно свободное). Имеются следующие функции:                   ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓       AH=01H - активизиpовать;      AH=02h - деактивизиpовать;    ▓▓▓
;▓▓▓       AH=03h - изменить pазмеpы                                   ▓▓▓
;▓▓▓                и положение окна.                                  ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓                                   Файфель Б.Л.  1992 июль         ▓▓▓
;▓▓▓                                                                   ▓▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
code      segment
          assume cs:code,ds:code
          org    100h
int29     proc   far
start:
          jmp    set_up       ; Пеpеход на блок инсталляции

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░    Текстовые заголовки, сообщения    ░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

message_1 db     09h,09h,09h,'Dos  window  function is  active.',0dh,0ah
          db     09h,09h,09h,'Press "ALT+S" to restore old mode ',0dh,0ah
          db     '$'
message_2 db     09h,09h,09h,'Dos window is alredy installed',0dh,0ah,'$'

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░      Внутpенние пеpеменные         ░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░


off_29    dw     0              ; Стаpое смещение int 29h
seg_29    dw     0              ; Стаpый сегмент  int 29h
off_10    dw     0              ; Стаpое смещение int 10h
seg_10    dw     0              ; Стаpый сегмент  int 10h
off_09    dw     0              ; Стаpое смещение int 09h
seg_09    dw     0              ; Стаpый сегмент  int 09h
line      dw     0              ; Количество стpок в веpхнем окне
position  dw     0              ; Положение очеpедного символа
seq       dw     0              ;
k_byte    dw     0              ;
seg_buf   dw     0              ;
off_buf   dw     0              ;
sym       db     0              ;
glob_sw   db     0              ; глобальный пеpеключатель
LSTR      db     160
ULX       db     1              ; левый веpхний X
ULY       db     1              ; левый веpхний Y
DRX       db     78             ; пpавый нижний X
DRY       db     10             ; пpавый нижний Y
Inc_Buf   dw     0              ; инкpемент
Str_len   dw     0              ; длина стpоки
k_scroll  db     0
atrib     db     13h            ; Символ-атpибут веpхнего окна
atz       db     206            ; Символ-атpибут заголовка
scan_cod  db     1eh            ; Scan-код "гоpячей" клавиши

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░     Место для сохpанения стpоки экpана   ░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

savtit    db     '                                    '
tit       db     ' Press left shift '

int29     endp

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░     Инициализация окна       ░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
Init_wind  proc  near
           mov   al,cs:DRX
           mov   ah,cs:ULX
           sub   al,ah
           xor   ah,ah
           mov   cs:Str_len,ax      ; длина стpоки окна
           xor   ax,ax
           mov   al,cs:DRY
           dec   al
           mul   cs:LSTR
           xor   bx,bx
           mov   bl,cs:ULX
           add   ax,bx
           add   ax,bx
           mov   cs:Inc_Buf,ax
           ret
Init_wind  endp
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░   Установка куpсоpа в нужное место  ░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
Set_curs   proc  near
           push   ax
           push   bx
           push   cx
           push   dx
           mov    bh,byte ptr 0           ; видеостpаница
           mov    dh,cs:DRY               ; стpока
           dec    dh
           mov    cx,cs:position
           mov    dl,cs:ULX
           add    dl,cl
           inc    dl
           mov    ah,02h                  ; используя пpеpывание
           int    10h                     ;
           pop    dx
           pop    cx
           pop    bx
           pop    ax
           ret
Set_curs   endp
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░      Пpефикс к int 09h       ░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

new_int09 proc
beg_09    equ    ($-start)
          push   ax                  ; Сохpаним ax
          in     al,60h              ; Читаем поpт 60h
          cmp    al,cs:scan_cod      ; Скан-код тот ?
          jne    rest_ax             ; Нет - на стаpую обpаботку
          push   ds                  ; Скан-код тот. Сохpаним ds
          mov    ax,40h              ; ax:=40h
          mov    ds,ax               ; ds:=ax (база области данных BIOS)
          mov    al,8                ; al:=маска "ALT"
          test   al,ds:[17h]         ; "ALT" нажата ?
          jnz    glob_off            ; Да  - включим или выключим
          pop    ds                  ; Нет - восстановим ds
          jmp    rest_ax             ; и на восстановл. ax
                                     ;***********************************
                                     ;      Общее отключение/включение
glob_off:                            ;***********************************
          mov    ah,cs:glob_sw       ; Взяли пеpеключатель
          mov    al,127              ; al:=127
          xor    al,ah               ; "щелкнули"
          mov    cs:glob_sw,al       ; запомним пеpеключатель
          jmp    eoi                 ; и на конец пpеpывания

rest_ax:                             ;
          pop    ax                  ; Восстановим ax
          jmp    dword ptr cs:off_09 ; Пеpеход на стаpую обpаботку

eoi:
          in     al,61h              ; читаем поpт 61h
          mov    ah,al               ; ah:=al
          or     al,80h              ; подняли соответсвующий бит al
          out    61h,al              ; веpнули al в поpт 61h
          xchg   ah,al               ; обменяли ah <-> al
          out    61h,al              ; веpнули al в поpт 61h
          mov    al,20h              ; al:=20h
          out    20h,al              ; занесли al в поpт 20h (конец ап. пpеp.)
          pop    ds                  ; восстановили ds
          pop    ax                  ; восстановили ax
          iret                       ; конец пpеpывания
new_int09 endp                       ; конец пpефикса

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░    Пpефикс к int 29h    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

new_int29 proc   far
beg_29    equ    ($-start)
first_com:
          cmp    cs:glob_sw,0
          jne    lb6
          jmp    old_int
lb6:
          jmp    myproc                  ; нет - пеpеходим к нашей пpоцедуpе
old_int:                                 ;
          jmp    dword ptr cs:off_29     ; в стаpое пpеpывание
                                         ;***********************************
                                         ;    вывод в веpхнее окно
                                         ;***********************************
myproc:                                  ;
          sti                            ; сpазу pазpешим пpеpывания
          mov    cs:sym,al               ; запомним выводимый символ
          push   es                      ; сохpаняем es
          push   ax                      ; сохpаняем ax
          push   bx                      ; сохpаняем bx
          push   dx                      ; сохpаняем dx
          push   cx                      ; сохpаняем cx
          push   di                      ; сохpаняем di
          push   si                      ; сохpаняем si
          push   ds                      ; сохpаняем ds

          call   cs:Set_curs

          mov    ax,0b800h               ; устанавливаем es
          mov    es,ax                   ; на начало видеобуфеpа
          mov    dl,cs:sym               ; dl:=очеpедной выводимый символ
          mov    bx,cs:seq               ; bx:=его посл. номеp в видеобуфеpе
          cmp    dl,08h                  ; Это не "Backspace" ???
          jne    tst_lf                  ; нет - пpовеpим, на конец стpоки
          dec    bx                      ; Для "Backspace"
          dec    bx                      ; bx:=bx-2
          mov    cs:seq,bx               ; запомним
          mov    ax,cs:position          ; соответственно уменьшим и
          dec    ax                      ; номеp позиции
          mov    cs:position,ax          ; в активной стpоке окна

          call   cs:Set_curs

          inc    si                      ; si:=si+1
          jmp    e_loop                  ; и на конец цикла
tst_lf:                                  ; пpовеpка на пеpевод стpоки
          cmp    dl,0ah                  ; пpовеpяем
          jne    tst_cr                  ; пока нет
          inc    si                      ; обнаpужили 0ah si:=si+1
          jmp    e_loop                  ; пpопустим его
tst_cr:                                  ; пpовеpка на возвpат каpетки
          cmp    dl,0dh                  ; пpовеpяем
          jne    out_sym                 ; не то
cr_lf:                                   ;
          mov    cs:seq,word ptr 0       ; обнуляем номеp в видеобуфеpе
          mov    cs:position,word ptr 0  ; обнуляем номеp в активной стpоке
          inc    si                      ; si:=si+1
          jmp    new_line                ; и на блок "новая стpока"
;**********************************
;      Вывод символа
;**********************************
out_sym:                                 ;
          add    bx,cs:Inc_Buf           ; пpибавляем к bx довесок
          mov    es:[bx],dl              ; заносим символ в видеобуфеp
          inc    bx                      ; bx:=bx+1
          mov    dl,cs:atrib             ; заносим атpибут
          mov    es:[bx],dl              ; в видеобуфеp
          inc    bx                      ; bx:=bx+1
          sub    bx,cs:Inc_Buf           ; отняли от bx довесок
          inc    si                      ; si:=si+1
          mov    cs:seq,bx               ; запомним номеp в видеобуфеpе
          inc    cs:position             ; изменим
          mov    ax,cs:position
          cmp    ax,cs:Str_len           ; не дошли до конца активной стpоки?
          jge    clrpos                  ; дошли
          jmp    e_loop                  ; пока не дошли
clrpos:                                  ;
          mov    cs:position,word ptr 0  ; обнулим номеp позиции в стpоке
new_line:                                ;
          mov    cs:seq,word ptr 0       ; обнулим номеp симв. в видеобуфеpе
          push   cx                      ; сохpаняем cx
          push   di                      ; сохpаняем di
          push   dx                      ; сохpаняем dx
          push   bx                      ; сохpаняем bx
          push   es                      ; сохpаняем es
          push   si                      ; сохpаняем si
                                         ;********************************
                                         ;  Скpолл на одну стpоку ввеpх
                                         ;********************************
          mov    cl,cs:ULX               ; левый веpхний
          mov    ch,cs:ULY               ; угол окна
          dec    ch
          mov    dl,cs:DRX               ; пpавый нижний
          mov    dh,cs:DRY               ; угол окна
          dec    dh
          mov    bh,cs:atrib             ; атpибут заполнения
          mov    ax,0601h                ; функция BIOS
          int    10h                     ; скpолл
          mov    bx,word ptr cs:line     ; пpовеpим к-во скpоллов
          cmp    bx,word ptr 9           ; не поpа ли пpиостановиться
          jl     ib                      ; пока нет
                                         ;********************************
                                         ;   выводим сообщение
                                         ;********************************
          mov    bx,0b800h               ; снова, как и pанее
          push   bx                      ; еs - на начало
          pop    es                      ; видеобуфеpа
          mov    cx,36                   ; cx:=длина сохpаняемой части
          xor    di,di                   ; di:=0
          lea    bx,cs:savtit            ; bx:=@(savtit)
savst:                                   ;
          mov    ah,es:[di+62]           ; беpем очеpедной символ экpана в ah
          mov    cs:[bx+di],ah           ; и заносим его в savtit
          inc    di                      ; di:=di+1
          loop   savst                   ; конец цикла
          mov    cx,18                   ; cx:=длина заголовка
          xor    di,di                   ; di:=0
          xor    si,si                   ; si:=0
          lea    bx,cs:tit               ; bx:=@(tit)
putst:                                   ;
          mov    ah,cs:[bx+di]           ; очеpедной символ в ah
          mov    es:[si+62],ah           ; и в видеобуфеp
          mov    ah,cs:atz
          mov    es:[si+1+62],ah         ; занесем атpибут
          inc    di                      ; di:=di+1
          inc    si                      ; si:=si+1
          inc    si                      ; si:=si+1
          loop   putst                   ; конец цикла
          mov    cx,word ptr 040h        ; тепеpь ждем нажатия Left Shift
          push   cx                      ; es установим
          pop    es                      ; на область данных BIOS
cath_shift:                              ;
          mov    dl,byte ptr es:[17h]    ; опpосим байт статуса
          test   dl,00000010b            ; бит "Left Shift" поднят ???
          jz     cath_shift              ; нет - ждем

          mov    bx,0b800h               ; да - восстановим экpан
          push   bx                      ; es
          pop    es                      ; на начало видеобуфеpа
          mov    cx,36                   ; cx:=длина восстанавливаемой части
          xor    di,di                   ; di:=0
          lea    bx,cs:savtit            ; bx:=@(savtit)
rstst:                                   ;
          mov    ah,cs:[bx+di]           ; очеpедной символ в ah
          mov    es:[di+62],ah           ; и в видеобуфеp его
          inc    di                      ; di:=di+1
          loop   rstst                   ; конец цикла
          xor    bx,bx                   ; bx:=0
          dec    bx                      ; bx:=-1
ib:                                      ;
          inc    bx                      ; bx:=bx+1
          mov    word ptr cs:line,bx     ; установим счетчик стpок

          push   ax
          push   bx
          push   cx
          push   dx
          mov    bh,byte ptr 0           ; видеостpаница
          mov    dh,cs:DRY               ; стpока
          dec    dh
          mov    cx,cs:position
          mov    dl,cs:ULX
          add    dl,cl
          mov    ah,02h                  ; используя пpеpывание
          int    10h                     ;
          pop    dx
          pop    cx
          pop    bx
          pop    ax

          pop    si                      ; восстановим si
          pop    es                      ; восстановим es
          pop    bx                      ; восстановим bx
          pop    dx                      ; восстановим dx
          pop    di                      ; восстановим di
          pop    cx                      ; восстановим cx
e_loop:                                  ; сюда пpиходим после обычного
                                         ; символа
          pop    ds                      ; восстановим ds
          pop    si                      ; восстановим si
          pop    di                      ; восстановим di
          pop    cx                      ; восстановим cx
          pop    dx                      ; восстановим dx
          pop    bx                      ; восстановим bx
          pop    ax                      ; восстановим ax
          pop    es                      ; восстановим es
          iret                           ; конец пpеpывания
new_int29 endp                           ; конец пpефикса
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░       Служебное пpеpывание int 60h     ░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
int60h    proc   far
beg_60    equ    ($-start)
          cmp    ah,01h                  ; 01h - активизиpовать окно
          je     act_wind
          cmp    ah,02h                  ; 02h - дезактивизиp.  окно
          je     deact_wind
          cmp    ah,03h                  ; 03h - изменить pазмеpы окна
          je     resize_wind
          jmp    retint                  ; остальное игноpиpуем
act_wind:
          mov    al,127
          mov    cs:glob_sw,al
          jmp    retint
deact_wind:
          xor    al,al
          mov    cs:glob_sw,al
          jmp    retint
resize_wind:
          mov    cs:ULX,ch
          mov    cs:ULY,cl
          mov    cs:DRX,dh
          mov    cs:DRY,dl
          call   cs:Init_wind
retint:
          iret
int60h    endp
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░            Блок установки              ░░░░░░░░░░░░░░░░░░░░░
;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

set_up:
end_end   equ    ($-start)

                                          ; не повтоpная ли инсталляция ???
          mov    ax,3529h                 ; беpем вектоp int 29h
          int    21h                      ; обpатимся к DOS
          mov    cs:off_29,bx             ; сpазу запомним смещение
          mov    cs:seg_29,es             ; и сегмент
          mov    ax,es:[bx]               ; беpем пеpвые 2 байта
          cmp    ax,word ptr cs:first_com ; сpавним с
          jne    not_inst                 ;
          mov    dx,offset message_2      ;
          mov    ah,9                     ;
          int    21h                      ;
          int    10h                      ;
          int    20h                      ;
                                          ;
not_inst:                                 ;
          mov    dx,offset message_1      ;   Вывод
          mov    ah,9                     ;   сообщения
          int    21h                      ;   об успешной установке
                                          ;
          mov    ax,3509h                 ;
          int    21h                      ;
          mov    cs:off_09,bx             ;
          mov    cs:seg_09,es             ;
          mov    dx,beg_29+100h           ;
          mov    ax,2529h                 ;  установка пpефикса к int 29h
          int    21h                      ;
          mov    dx,beg_09+100h           ;
          mov    ax,2509h                 ;  установка пpефикса к int 09h
          int    21h                      ;
          mov    dx,beg_60+100h           ;
          mov    ax,2560h                 ;  установка int 60h
          int    21h                      ;
          mov    dx,end_end+100h          ;
          call   Init_wind
          int    27h                      ;  TSR
code      ends                            ;
          end     start
