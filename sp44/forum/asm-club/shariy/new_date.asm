;          NEW_DATE  ver. 1.1.  3 января  1992 
;          автор      Шарий Максим Борисович
;                     340005, г.Донецк, Речная, 4-34
;                     тел. (0622) 91-92-77 (рабочий)
;          транслятор - Turbo Assembler ver. 2.0
;
;          Программа предназнечена для определения первого запуска машины за
;          день, неделю или месяц. Контролируются первые три байта на предмет
;          заражения.


TITLE      Program for checking day & week & month
           .model tiny

CODE       SEGMENT
           ASSUME DS:CODE, CS:CODE, ES:CODE

                                       ;******************************
                                       ;*   Error Levels Returned:   *
                                       ;*   0 - New Day              *
           ORG 100H                    ;*   1 - Same Day             *
                                       ;*   2 - Virus Found          *
Origin     Label      Byte             ;*   3 - Some Error           *
           jmp Start                   ;*   4 - New Month            *
drive      db (?)                      ;*   5 - New Week (on Mondays)*
Sector_No  dw (?)                      ;******************************
Vir_msg    db 07,'Virus found!',10,13,'$'
Hello      db 'Day/Week/Month check! (c) Шарий М.Б. ДонГУ. ver 1.1 ',10,13,'$'
LastDate   db (?)
LastMonth  db (?)
Jump_ok    db 0ebh,5ch,90h
MyName     db 0,'NEW_DATECOM'

START:
           mov ah,09h
           lea dx,Hello
           int 21h
           cld                ; move forward in string operations
           lea si,MyName
           lea di,Buffer      ; FCB will be in buffer
           mov cx,12
   rep     movsb
           mov al,0
           mov cx,30
   rep     stosb              ; FCB is ready
; Set DTA
           mov ah,1ah
           lea dx,dta_drive
           int 21h            ; DTA is set
           mov ah,11h
           lea dx,Buffer
           int 21h            ; finding first matching file
           cmp al,0
           je File_Found
           jmp Dsk_Err
File_Found:
           mov ax,Clustr_No
           mov Sector_No,ax   ; Cluster Number in Sector_No now
           mov al,dta_drive
           dec al
           mov drive,al       ; adjusted drive number for Int 25h/26h
; Let's calculate Sector Number
           mov cx,1
           mov dx,0           ; boot sector
           lea bx,buffer
           int 25h
           pop dx             ; boot sector in buffer
           cmp al,0
           je cont1
           jmp Dsk_Err
Cont1:
           mov al,0ebh
           cmp al,buffer
           jne bad_boot
           mov ax,512
           cmp ax,SectSize
           je ok_boot       ; now we sure that boot sector is read
bad_boot:  jmp Dsk_Err
ok_boot:
           mov ax,RootSize
           mov bx,32
           mov cx,SectSize
           mov dx,0
           mul bx
           div cx
           mov cx,ax
           mov ax,FatSize
           mov bh,0
           mov bl,FatCnt
           mul bx
           add ax,ResSecs
           add ax,cx
           mov cx,ax
           mov ax,Sector_no       ; It is Cluster Number
           sub ax,2
           mov bh,0
           mov bl,ClustSize
           mul bx
           add ax,cx
           mov Sector_no,ax       ; Sector Number in Sector_no!
           mov al,drive           ; Let's make sure that Sector
           mov cx,1               ; Number is Correct
           mov dx,Sector_No
           lea bx,buffer
           int 25h                ; Reading program into buffer
           pop dx
           cmp al,0
           je cont2
           jmp Dsk_Err
Cont2:       ; Let's compare Origin Program with Buffer contents
           lea si,Origin
           add si,70h
           lea di,Buffer
           add di,70h
           mov cx,50h
repe       cmpsb
           jne Dsk_Err
; Is our first bytes correct?
           lea si,Buffer         ; our first 3 bytes
           lea di,Jump_ok        ; what ought to be
           mov cx,3
repe       cmpsb
           je virus_ok
           mov ah,09h            ; VIRUS FOUND!
           lea dx,Vir_Msg
           int 21h
           mov al,2               ; Error Level 2 - means VIRUS
           jmp exit
Virus_OK:                         ; compare dates
           mov ah,2ah
           int 21h
           cmp dh,LastMonth
           je Check_Day
           mov LastMonth,dh
           mov LastDate,dl
           call Write_Sector      ; Overwriting Month and Day of week and Date
           jc  Dsk_Err
           mov al,4               ; Error Level 4 means new month
           jmp exit
Check_Day: cmp dl,LastDate
           jne New_Day
           mov al,1               ; Error Level 1 means same day
           jmp exit
New_day:   cmp al,1               ; New day & Monday?
           jne Same_Week
           mov LastDate,dl
           call Write_Sector      ; Overwriting day
           jc  Dsk_Err
           mov al,5               ; Error Level 5 means new week (Monday)
           jmp exit
Same_Week: mov LastDate,dl
           call Write_Sector      ; Overwriting day
           jc  Dsk_Err
           mov al,0               ; Error Level 0 means new day
           jmp exit
Dsk_Err:   mov al,3               ; Level 3 - Disk Error!

; Exiting now
exit:      mov ah,4ch
           int 21h

; ==============================================================

Write_Sector  proc near
           mov al,drive
           mov cx,1               ; 1 sector
           mov dx,Sector_No       ; Number of Sector
           lea bx,origin          ; start of code in memory
           int 26h                ; writing now
           pop dx
           ret
           endp

; ==============================================================

;  Space for reading boot sector
buffer     label byte
OEM        db 0bh dup (?)
SectSize   dw (?)
ClustSize  db (?)
ResSecs    dw (?)
FatCnt     db (?)
RootSize   dw (?)
TotSecs    dw (?)
Media      db (?)
FatSize    dw (?)
TrkSecs    dw (?)
HeadCnt    dw (?)
HidnSec    dw (?)

DTA_DRIVE      DB (?)
ENTRY      DB 1AH DUP (?)
CLUSTR_NO  DW (?)
ENTRY2     DB (?)

CODE       ENDS
           END origin