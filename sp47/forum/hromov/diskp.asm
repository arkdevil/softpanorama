;
;***************************************************************************
;*	Hard disk protector                                                *
;*	Автор - Хромов Александр, Магнитогорск, Калибровочный завод, ОАСУП.*
;*	Последняя корректировка - март 1992 г.                             *
;***************************************************************************
;
;
;******************************************************************************
;       Процедура вывода строки на EGA с атрибутами в текстовых режимах       *
;******************************************************************************
str_atr macro
        local   exit,col,st_pos,lock_loop0,no_change,col_ovf,str_ovf,change_pos
        local   normal_code0,normal_code1,control_code,lock_loop1,scroll_up
        local   lock_loop2,str_back,scr_back,ret_back,tab,next_str,linefeed
        local   color
;       INPUT:          ds:dx - string$
;                       bl    - atributes, if bl=0 - dont change atributes
;                       bh    - video page output

        pushregs        <ax,bx,cx,dx,si,di,es,ds>

        mov     cs:color,bx
        mov     si,dx

        mov     ah,0fh
        int     10h

        cmp     al,3
        jg      ex_it

        mov     cs:col,ah

        mov     al,80h
        mov     ch,byte ptr cs:color+1
        mul     ch

        cmp     cs:col,40
        jz      _40_col
        shl     ax,1
_40_col:
        add     ax,0b800h
        mov     es,ax

        mov     ah,3
        int     10h

        mov     st_pos,dx

        xor     ah,ah
        mov     al,col
        shl     al,1
        mul     dh

        xor     dh,dh
        shl     dl,1
        add     ax,dx
        mov     di,ax

        mov     bl,byte ptr cs:color
        or      bl,bl
        jz      no_change

lock_loop0:
        lodsb
        cmp     al,'$'
        jz      ex_it

        cmp     al,20h
        jge     normal_code0
        call    control_code
        jnz     normal_code0
        jmp     short lock_loop0

ex_it:  jmp     exit

normal_code0:
        mov     ah,bl
        stosw
        call    change_pos
        jmp     short lock_loop0

no_change:
        lodsb
        cmp     al,'$'
        jz      ex_it

        cmp     al,20h
        jge     normal_code1
        call    control_code
        jz      no_change

normal_code1:
        stosb
        inc     di
        call    change_pos
        jmp     short no_change
;
;***************************************
;
change_pos      proc    near

        mov     dx,st_pos
        inc     dl
        cmp     dl,col
        jge     col_ovf
        mov     st_pos,dx
        ret
col_ovf:
        xor     dl,dl
        inc     dh
        cmp     dh,25
        je      str_ovf
        mov     st_pos,dx
        ret
str_ovf:

        dec     dh
        mov     st_pos,dx
        call    scroll_up
        ret

change_pos      endp
;
;***************************************
;
control_code    proc near

        cmp     al,7
        jz      beep
        cmp     al,8
        jz      back
        cmp     al,9
        jz      tab
        cmp     al,10
        jz      linefeed
        cmp     al,13
        jz      carret

        ret
beep:
        mov     ax,0e07h
        int     10h
        cmp     al,al
        ret
back:
        dec     di
        dec     di
        mov     dx,st_pos
        sub     dl,1
        jnc     ret_back
str_back:
        sub     dh,1
        jnc     ret_back
scr_back:
        sub     di,di
        mov     dl,col
        dec     dl
        mov     dh,24
ret_back:
        mov     st_pos,dx
        cmp     al,al
        ret

tab:
        mov     cl,4
        shr     di,cl
        inc     di
        mov     cl,4
        shl     di,cl

        mov     dx,st_pos
        mov     cl,3
        shr     dl,cl
        inc     dl
        mov     cl,3
        shl     dl,cl

        cmp     dl,col
        jl      ret_back

next_str:
        sub     dl,dl
        inc     dh
        cmp     dh,25
        jl      ret_back
        call    scroll_up
        dec     dh
        jmp     short ret_back

linefeed:
        mov     cl,col
        shl     cl,1
        xor     ch,ch
        add     di,cx

        push    di
        push    cx

        mov     dx,st_pos
        inc     dh
        cmp     dh,25
        jz      line
        pop     cx
        pop     di
        jmp     short ret_back
line:
        call    scroll_up

        pop     cx
        pop     di
        sub     di,cx

        cmp     al,al
        ret

carret:
        mov     ax,di
        mov     cl,col
        shl     cl,1
        div     cl
        xor     ah,ah
        mul     cl
        mov     di,ax

        mov     dx,st_pos
        xor     dl,dl
        jmp     short ret_back

control_code    endp
;
;***************************************
;
scroll_up       proc    near

        push    si
        push    ds

        mov     cx,es
        mov     ds,cx

        mov     cl,cs:col
        mov     al,24
        mul     cl

        xor     ch,ch
        mov     si,cx
        shl     si,1
        xor     di,di
        mov     cx,ax

        cld

rep     movsw

        mov     ax,0720h

        mov     cl,cs:col
        xor     ch,ch
        mov     si,di

rep     stosw

        mov     di,si

        popregs	<ds,si>
        ret

scroll_up       endp
;
;***************************************
;
col     db      ?
st_pos  dw      ?
color   dw      ?

exit:
        mov     dx,st_pos
        mov     bh,byte ptr cs:color+1
        mov     ah,2
        int     10h

        popregs <ds,es,di,si,dx,cx,bx,ax>
        endm
;
;***************************************
;
PUSHREGS        macro   reg_list
;;
;;      Поместить регистры в стек
;;
        irp     reg,<reg_list>
        push    reg
        endm
                endm
;
;***************************************
;
POPREGS macro   reg_list
;;
;;      Извлеч из стека регистры
;;
        irp     reg,<reg_list>
        pop     reg
        endm
                endm
;
;***************************************
;	Main codes                     *
;***************************************
;
code    segment
        assume  cs:code,ds:code
        org     100h

start:  jmp     install
;
;***************************************
;
flag    db      0ffh
flag_1  db      0
device  db      80h
st_cyl_sect     dw      0
end_cyl_sect    dw      0
;
;***************************************
;
conv_CX proc    near
        push    bx
        mov     bx,cx
        shl     cl,1
        shl     cl,1
        shr     cx,1
        shr     cx,1
        and     bl,11000000b
        or      ch,bl
        pop     bx
        ret
conv_CX endp
;
;***************************************
;
int_13h proc    near
;
;       В начале исключаем возможность
;       трассирования  с  целью обхода
;       защиты.

        push    ax
        pushf
        pop     ax
        and     ax,1111110011111111b	; Сбрасываем IF и TF
        push    ax
        popf
        pop     ax
;
;       Проверяем, включена ли защита
;
        cmp     cs:flag,0ffh
        jnz     old_13h
;
;       Если включена, проверяем АН на
;       функции записи на диск :
;       03h,05h,0bh,0fh
;
        cmp     ah,3
        jz      nextchk

        cmp     ah,5
        jz      nextchk

        cmp     ah,0fh
        jz      nextchk

        cmp     ah,0bh
        jnz     old_13h
;
;       Проверяем, на какой дисковод
;       запрос записи
;
nextchk:
        cmp     dl,cs:device
        jne     old_13h
;
;       Проверяем, на какую область
;       диска запрос записи
;
        push    cx
        call    conv_CX
        cmp     cx,cs:st_cyl_sect
        jc     run
        cmp     cs:end_cyl_sect,cx
        jc      run
        pop     cx
;
;       Возвращаем код ошибки записи
;       на защищенный диск
;
        mov     cs:save_al,al
        pop     ax
        mov     cs:ret_offset,ax
        pop     ax
        mov     cs:ret_segment,ax
        pop     ax
        mov     al,cs:save_al

        mov     ah,3
        sti
        stc

                db      0eah
ret_offset      dw      0
ret_segment     dw      0
;
;       Уход на родной обработчик INT 13h
;
run:
        pop     cx
old_13h:
        sti
                db      0eah
old13offset     dw      0
old13segment    dw      0
save_al         db      0

int_13h endp
;
;***************************************
;
;       Прерывание от клавиатуры
;
int_9h  proc    near

        push    ax
        in      al,60h
        cmp     al,58h	; 58h - код клавиши 'F12', возможна замена
        jz      F12

        pop     ax
        jmp     short old_int9h
F12:
        in      al,61h
        mov     ah,al
        or      al,80h
        out     61h,al
        xchg    ah,al
        out     61h,al
        mov     al,20h
        out     20h,al
        pop     ax
;
;       Проверяем, не активизировано
;       ли окно уже
;
        cmp     cs:flag_1,0
        jz      wind
;
;       Уход на родной обработчик INT 9h
;
old_int9h:
        db      0eah
old9offset      dw      0
old9segment     dw      0

;
;═══════════ Прочедуры оконного интерфейса ═══════════
wind:
;
;       Устанавливаем признак активности
;       окна
;
        mov     cs:flag_1,0ffh

	pushregs	<ax,bx,cx,dx,di,si,ds,es,bp>

        push    cs
        pop     ds
        push    cs
        pop     es

;
;       Проверяем режим работы дисплея
;
        mov     ah,0fh
        int     10h
        cmp     al,2
        jl      popper
        cmp     al,3
        jg      popper
        or      bh,bh
        jnz     popper
;
;       Если TEXT 80х25, то продолжаем
;
        call    set_window      ;       Рисование окна
        call    ask_user        ;       Запрос пользователя
        call    remove_window   ;       Стирание окна
;
;       Уход из интерфейса
;
popper:
	popregs	<bp,es,ds,si,di,dx,cx,bx,ax>

        mov     cs:flag_1,0
        iret
;
;***************************************
;
;       Процедура рисования окна
;       путем прямой записи в экр.
;       область
;
set_window      proc    near

        push    es

        mov     ax,0b800h
        mov     ds,ax

        lea     di,shade_buffer
        mov     ah,shade_atr
        mov     si,(window_string+1)*160+(window_column+window_length)*2+1
        mov     cx,window_wind-1
lock_loop4:
        mov     al,ds:[si]
        mov     es:[di],al
        mov     ds:[si],ah
        add     si,160
        inc     di
        loop    lock_loop4

        mov     si,(window_string+window_wind)*160+(window_column+1)*2+1
        mov     cx,window_length

lock_loop5:
        mov     al,ds:[si]
        mov     es:[di],al
        mov     ds:[si],ah
        inc     si
        inc     si
        inc     di
        loop    lock_loop5

        mov     si,(window_string)*160+(window_column*2)
        lea     di,buffer
        mov     bx,window_wind

lock_loop2:
        mov     cx,window_length
lock_loop3:
rep     movsw
        add     si,160-window_length*2
        dec     bx
        jnz     lock_loop2

        push    es
        pop     ds
        mov     ax,0b800h
        mov     es,ax

        lea     si,window
        mov     di,(window_string)*160+(window_column*2)
        mov     bx,window_wind
        mov     ah,current_atr
lock_loop0:
        mov     cx,window_length

lock_loop1:

        lodsb
        stosw
        loop    lock_loop1
        add     di,160-window_length*2
        dec     bx
        jnz     lock_loop0
        pop     es
        ret

set_window      endp
;
;***************************************
;
;       Процедура восстановления экрана
;
remove_window   proc    near

        push    es

        mov     ax,0b800h
        mov     es,ax

        mov     di,window_string*160+(window_column*2)
        lea     si,buffer
        mov     bx,window_wind
lock_loop6:
        mov     cx,window_length
rep     movsw
        add     di,160-window_length*2
        dec     bx
        jnz     lock_loop6

        lea     si,shade_buffer
        mov     di,(window_string+1)*160+(window_column+window_length)*2+1
        mov     cx,window_wind-1
lock_loop7:
        lodsb
        mov     es:[di],al
        add     di,160
        loop    lock_loop7

        mov     di,(window_string+window_wind)*160+(window_column+1)*2+1
        mov     cx,window_length
lock_loop8:
        movsb
        inc     di
        loop    lock_loop8

        pop     es
        ret

remove_window   endp
;
;***************************************
;
;       Процедура запроса пользователя
;
ask_user        proc    near

        push    es
        mov     ax,0b800h
        mov     es,ax

start_ask:
        call    set_yes

        xor     ah,ah
        int     16h

        cmp     al,13
        jz      end_ask
        call    set_no

        xor     ah,ah
        int     16h

        cmp     al,13
        jnz     start_ask
end_ask:
        pop     es
        ret

ask_user        endp
;
;***************************************
;
set_yes proc    near

        mov     word ptr lock_1,(yes_string)*160+(yes_column)*2+1
        mov     word ptr lock_1+2,yes_length

        mov     word ptr lock_2,(no_string)*160+(no_column)*2+1
        mov     word ptr lock_2+2,no_length

        call    set_inverse
        mov     byte ptr cs:flag,0ffh
        ret

set_yes endp
;
;***************************************
;
set_no  proc    near

        mov     word ptr lock_2,(yes_string)*160+(yes_column)*2+1
        mov     word ptr lock_2+2,yes_length

        mov     word ptr lock_1,(no_string)*160+(no_column)*2+1
        mov     word ptr lock_1+2,no_length

        call    set_inverse
        mov     byte ptr cs:flag,0
        ret

set_no  endp
;
;***************************************
;
set_inverse     proc    near

        mov     al,inverse_atr
        mov     di,lock_1
        mov     cx,lock_1+2
lock_loop9:
        stosb
        inc     di
        loop    lock_loop9

        mov     al,current_atr
        mov     di,lock_2
        mov     cx,lock_2+2
lock_loop10:
        stosb
        inc     di
        loop    lock_loop10
        ret

set_inverse     endp
;
;***************************************
;
window:         db      '╔════════════════════════════════════╗'
                db      '║           Disk protector           ║'
                db      '║   Do you wish to protect H-disk ?  ║'
                db      '║          NO           YES          ║'
                db      '╚════════════════════════════════════╝'

window_string   equ     8
window_column   equ     18
window_length   equ     38
window_wind     equ     5

buffer          dw      (window_length)*(window_wind) dup (?)
shade_buffer    db      window_length+window_wind-1 dup (?)

lock_1          dw      4 dup (?)
lock_2          dw      4 dup (?)

yes_string      equ     window_string+3
yes_column      equ     window_column+23
yes_length      equ     5

no_string       equ     yes_string
no_column       equ     window_column+10
no_length       equ     4

current_atr     equ     4fh
shade_atr       equ     04h
inverse_atr     equ     70h

int_9h   endp
;
;***************************************
;
;       Для исключения доступа к
;       родному обработчику INT 13h
;       контролируем использование
;       функции 13h прерывания 2Fh
;
int_2fh proc    near

        cmp     ah,13h
        jnz     end_check
        iret
end_check:
                db      0eah
old2foffset     dw      0
old2fsegment    dw      0

int_2fh endp
;
;***************************************
;
;═══════ Installator ═══════
;
install proc    near

        lea     dx,copyright
        mov     bx,06fh
        call    out_s
;
;       Проверка на резидентность.
;       Если уже - то в регистрах
;       DS и DX изменений не про-
;       изойдет при вызове функции
;       13h прерывания 2Fh
;
        mov     ax,1300h
        int     2fh
        cmp     dx,offset copyright
        jz      already
;
;       Иначе - повторный вызов INT 2Fh
;       для восстановления системных
;       переходов
;
        int     2fh

        call    check_boot      ;       проверка boot sector &
                                ;       partition table

;
;       Сохраняем адрес INT 13h
;
        mov     ax,3513h
        int     21h
        mov     cs:old13offset,bx
        mov     cs:old13segment,es
;
;       Сохраняем адрес INT 2Fh
;
        mov     al,2fh
        int     21h
        mov     cs:old2foffset,bx
        mov     cs:old2fsegment,es
;
;       Сохраняем адрес INT 9h
;
        mov     al,09h
        int     21h
        mov     cs:old9offset,bx
        mov     cs:old9segment,es

        push    ds
        pop     es
;
;       Перехватываем INT 13h, INT 2Fh, INT 9h
;
        mov     dx,offset int_13h
        mov     ax,2513h
        int     21h

        mov     dx,offset int_2fh
        mov     al,2fh
        int     21h

        mov     dx,offset int_9h
        mov     al,09h
        int     21h
;
;       Освобождаем для DOS enviroment
;
        mov     ax,ds:[2ch]
        mov     es,ax
        mov     ah,49h
        int     21h
        pop     es

        lea     dx,user_msg
        mov     bx,0ah
        call    out_s
;
;       Выходим, оcтаваясь резидентом
;
        mov     dx,offset install
        int     27h
;
;***************************************
;
;       Место выхода, если уже резидентен
;
already:

        mov     bx,0ch
        lea     dx,err_msg
        call    out_s
        push    ds
        pop     es
        ret
;
;***************************************
;
;	Проверка загрузочных секторов
;
check_boot      proc    near

        push    ds
        pop     es

        mov     drive,80h
        mov     head,0h
        mov     word ptr cyl_sect,1
read_part:
        call    read_sector
        mov     cx,4
next_check_boot:
        cmp     word ptr es:[bx+1beh],0aa55h
        jz      end_check_drive
        cmp     byte ptr es:[bx+1beh],80h
        jz      cont_check_boot
        add     bx,10h
        loop    next_check_boot
end_check_drive:
        cmp     drive,80h
        jnz      err_exit_
        add     drive,1
        jmp     short read_part
err_exit_:
        jmp     err_exit
cont_check_boot:
        mov     al,drive
        mov     device,al
        lea     si,part_bufer
        call    compare
        jz      cont_check
        call    error_compare

cont_check:
        mov     al,es:[bx+1bfh]
        mov     head,al
        mov     cx,es:[bx+1c0h]
        mov     cyl_sect,cx
        call    conv_cx
        mov     st_cyl_sect,cx
        mov     cx,es:[bx+1beh+6]
        call    conv_CX
        mov     end_cyl_sect,cx
        call    read_sector

        lea     si,boot_bufer
        call    compare
        jz      check_adr
        call    error_compare
check_adr:
        mov     ax,3513h
        int     21h
        sub     di,di
        cmp     word ptr offs,bx
        jnz     error_comp
        mov     bx,es
        cmp     word ptr segm,bx
        jnz     error_comp
        push    cs
        pop     es
        ret
;
;***************************************
;
read_sector     proc    near

        mov     dl,drive
        mov     dh,head
        mov     cx,cyl_sect
        lea     bx,work_bufer
        mov     ax,0201h
        int     13h
        jc      error_read
        ret

read_sector     endp
;
;***************************************
;
write_sector    proc    near

        mov     dl,drive
        mov     dh,head
        mov     cx,cyl_sect
        mov     ax,0301h
        int     13h
        jc      error_write
        ret

write_sector    endp
;
;***************************************
;
error_write:
        lea     dx,err_wr_msg
        jmp     short err_

error_read:
        lea     dx,err_r_msg

err_:
        mov     ah,9
        int     21h
        lea     dx,corr_err_msg
        int     21h
        jmp     err_exit

error_comp:
        push    ds
        pop     es

error_compare:
        push    bx
        push    cx
        push    dx

        lea     dx,warning_msg
        mov     bx,0fh
        call    out_s

        or      di,di
        jnz     boot_opt
        lea     dx,adr_warning
        call    out_s
        jmp     short ask

boot_opt:
        cmp     si,offset boot_bufer
        jl      part_opt

        lea     dx,boot_warning
        call    out_s
        jmp     short ask

part_opt:
        lea     dx,part_warning
        call    out_s

ask:
        mov     bx,0eh
        lea     dx,warning_ask
        call    out_s

        mov     ah,1
        int     21h
        cmp     al,'C'
        jz      correct
        cmp     al,'c'
        jz      correct
        cmp     al,'W'
        jz      write
        cmp     al,'w'
        jz      write
        cmp     al,'E'
        jz      err_exit
        cmp     al,'e'
        jz      err_exit

        jmp     short ask

correct:
        call    sure
        jnz     ask
        pop     dx
        pop     cx

        or      di,di
        jnz     wr_boot
        mov     dx,segm
        mov     ds,dx
        mov     dx,cs:offs
        mov     ax,2513h
        int     21h
        push    es
        pop     ds
        pop     bx
        ret

wr_boot:
        or      dh,dh
        jz      wr_part

        lea     bx,boot_bufer
        jmp     short wr_sector

wr_part:

        lea     bx,part_bufer

wr_sector:
        call    write_sector
        pop     bx
        ret

err_exit:
        mov     ah,4ch
        int     21h

Write:
        call    sure
        jnz     ask
        pop     dx
        or      di,di
        jnz     change_boot

        mov     ax,3513h
        int     21h
        mov     segm,es
        mov     offs,bx
        push    ds
        pop     es
        jmp     short wr_file

change_boot:
        or      dh,dh
        jz      change_part

        lea     di,boot_bufer
        jmp     short change

change_part:
        lea     di,part_bufer

change:
        lea     si,work_bufer
        mov     cx,512
        cld
rep     movsb

wr_file:
        push    dx

        lea     dx,spec
        mov     ax,4301h
        xor     cx,cx
        int     21h

        lea     dx,spec
        mov     ah,3ch
        xor     cx,cx
        int     21h
        jc      err_wr_file

        mov     bx,ax
        mov     dx,100h
        lea     cx,work_bufer
        sub     cx,dx
        mov     ah,40h
        int     21h
        jc      err_wr_file

        mov     ah,3eh
        int     21h

        lea     dx,spec
        mov     ax,4301h
        mov     cx,23h
        int     21h
        jc      err_wr_file

        pop     dx
        pop     cx
        pop     bx
        ret

err_wr_file:
        lea     dx,file_msg
        mov     bx,0ch
        call    out_s
        lea     dx,corr_err_msg
        call    out_s
        jmp     err_exit

check_boot      endp
;
;***************************************
;
compare proc    near

        push    cx
        lea     di,work_bufer
        mov     cx,512
        cld
repz    cmpsb
        pop     cx
        ret

compare endp
;
;***************************************
;
sure    proc    near

        push    ax
        push    dx
        lea     dx,warning_sure
        mov     bx,0eh
        call    out_s
        mov     ah,1
        int     21h
        cmp     al,'Y'
        jz      ret_sure
        cmp     al,'y'
ret_sure:
        pop     dx
        pop     ax
        ret

sure    endp
;
;***************************************
;
out_s   proc    near

        str_atr
        ret

out_s   endp
;
;***************************************
;
drive           db      ?
head            db      ?
cyl_sect        dw      ?

err_msg         db      'Disk protector already exists.',13,10,'$'
copyright       db      13,10
                db      '┌─────────────────────────────────────────┐',13,10
                db      '│           HARD DISK PROTECTOR           │',13,10
                db      '│        Written by CHr,MKZ,03.1992       │',13,10
                db      '└─────────────────────────────────────────┘',13,10,'$'
user_msg        db      13,10,'Protection installed',13,10
                db      'Use "F12" key to activate',13,10,10,36
warning_msg     db      13,10,10,'ERROR found when checking the $'
part_warning    db      'PARTITION TABLE',13,10,'$'
boot_warning    db      'BOOT SECTOR',13,10,'$'
adr_warning     db      'INT 13h  ADRESS',13,10,'$'
warning_ask     db      13,10,'Type one of the following options :',13,10,10
                db      '"C" - to Correct changed data',13,10
                db      '"W" - to Write new data into Disk Protector',13,10
                db      '"E" - to Exit programm',13,10,36
warning_sure   db       13,10,'Are You sure (y/n) $'
err_r_msg       db      'Cannot read sector',13,10,'$'
err_wr_msg      db      13,10,'Cannot write sector',13,10,'$'
file_msg        db      13,10,'Cannot write to c:\diskp.com',13,10,'$'
corr_err_msg    db      'Correct problems and run Disk Protector again',13,10,36
spec            db      'c:\diskp.com',0
segm            dw      ?
offs            dw      ?
part_bufer      db      32 dup ('PARTITION TABLE ')
boot_bufer      db      32 dup ('BOOT RECORD     ')
work_bufer      equ     $

install endp

code    ends
        end     start
