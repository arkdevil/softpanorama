;        Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:55
code     segment
         assume cs:code,ds:code,es:code
         org 100h
CRLF        equ    10,13
EndStr      equ    '$'
Ver         equ    'v 2.0'
CreateDate  equ    '24.07.92'
start:
         lea       dx,TitMsg
         mov       ah,09h
         int       21h

READ_PARAM:
         cmp       byte ptr cs:[80h],0  ;Если 0 - параметров нет
         jne       GET_FIRST_SIMBOL

PRT_HELP:
         lea       dx,MSG_HELP
         mov       ah,09h
         int       21h
         jmp       QUIT

GET_FIRST_SIMBOL:
         cld
         mov       al,20h
         mov       ch,0
         mov       cl,cs:[80h]
         mov       di,81h
         repe      scasb
         jne       COMP_SAVE
         jmp       PRT_HELP

COMP_SAVE:
         dec       di
         cmp       byte ptr cs:[di],'s' ;Если 's' - сохранить путь
         je        SAVE_PATH
         cmp       byte ptr cs:[di],'S'
         jne       COMP_RESTORE

SAVE_PATH:
         push      ds
         mov       ax,0B800h
         mov       ds,ax
         mov       di,8096
         mov       ax,0
         mov       ah,19h
         int       21h
         mov       cl,al
         add       cl,65
         mov       [di],cl
         inc       di
         mov       al,':'
         mov       [di],al
         inc       di
         mov       al,'\'
         mov       [di],al
         inc       di
         mov       dl,0
         mov       si,di
         mov       ah,47h
         int       21h         
         pop       ds
         jmp       VIEW_PATH

COMP_RESTORE:
         cmp       byte ptr cs:[di],'r' ;Если 'r' - восстановить путь
         je        RESTORE_PATH
         cmp       byte ptr cs:[di],'R'
         jne       COMP_VIEW

RESTORE_PATH:
         push      ds
         mov       ax,0B800h
         mov       ds,ax
         mov       di,8096

READ_PATH_FOR_RESTORE:
         mov       al,[di]
         cmp       al,020h
         jg        BEGIN_RESTORE
         jmp       NOT_SAVED_PATH

BEGIN_RESTORE:
         mov       dh,0
         mov       dl,[di]
         sub       dl,65
         mov       ah,0Eh
         int       21h
         inc       di
         inc       di
         inc       di
         pop       ds
         lea       dx,ROOT_DIR
         mov       ah,3Bh
         int       21h
         mov       ax,0B800h
         push      ds
         mov       ds,ax
         mov       dx,di
         mov       ah,3Bh
         int       21h         
         pop       ds
         jmp       QUIT

COMP_VIEW:
         cmp       byte ptr cs:[di],'v' ;Если 'v' - показать путь
         je        VIEW_PATH
         cmp       byte ptr cs:[di],'V'
         je        VIEW_PATH
         lea       dx,MSG_HELP
         mov       ah,09h
         int       21h
         jmp       QUIT

VIEW_PATH:
         lea       si,SAVED_PATH
         push      ds
         mov       ax,0B800h
         mov       ds,ax
         mov       di,8096
         mov       cx,96

READ_PATH:
         mov       al,[di]
         cmp       al,020h
         jg        MOV_PATH
         cmp       al,0h
         je        OK_PATH
         jmp       NOT_SAVED_PATH
MOV_PATH:
         mov       es:[si],al
         inc       si
         inc       di
         loop      READ_PATH
OK_PATH:
         mov       ax,0D0Ah
         mov       es:[si],ax
         inc       si
         inc       si
         mov       al,'$'
         mov       es:[si],al
         pop       ds
         lea       dx,SAVED_PATH_MSG
         mov       ah,09h
         int       21h
         jmp       QUIT

NOT_SAVED_PATH:
         pop       ds
         lea       dx,NOT_SAVED_PATH_MSG
         mov       ah,09h
         int       21h


QUIT:
         mov       ax,04C00h
         int       21h

TitMsg:
         db        CRLF
         db        '(c)  VES   Запоминание/восстановление текущей '
         db        'директории',CRLF
         db        '           с использованием неиспользуемой '
         db        'видеопамяти     '
         db        Ver,'  ',CreateDate,CRLF,CRLF
         db        EndStr

MSG_HELP:
         db        'Формат :  AutoDir [s|r|v]',CRLF
         db        '           s - сохранить путь',CRLF
         db        '           r - восстановить путь',CRLF
         db        '           v - показать сохраненный путь',CRLF
         db        EndStr

SAVED_PATH_MSG:
         db        'Сохраненный путь :  '

SAVED_PATH:
         db        96 dup (' ')

NOT_SAVED_PATH_MSG:
         db        'Нет сохраненного пути'
         db        CRLF,EndStr

ROOT_DIR:
         db        '\',0h

code ends
         end   start
