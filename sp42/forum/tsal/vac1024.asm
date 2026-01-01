code_seg_a      segment
                assume  cs:mseg,ds:mseg,es:mseg,ss:mseg
MSEG            SEGMENT

                org     100h

stopexpl       proc    far

start:
         JMP     SHORT LOAD; jump to install
BEGRES:
         PUSH    CS
         POP     DS; set segment of message
         MOV     AH,9
         MOV     DX,OFFSET MESSAGE-0D0H; new offset
         INT     21H; display message
         XOR     AH,AH; set function for INT 16
         INT     16H; wait key
         MOV     AH,4CH
         INT     21H; terminate
MESSAGE  DB      'VIRUS DETECTED STRIKE KEY!$'
LOAD:
         XOR     AX,AX; set value of segment of CP/M jump
         MOV     CX,5; length of jump
         MOV     SI,0CDH; offset of CP/M jump
         MOV     DS,AX; set segment
         CMP     [SI+1],CX; check if already install
         JNZ     NEXTLOAD
         RETN ; terminate (return to INT 20H)
NEXTLOAD:
         MOV     DI,CX; set offset of new CP/M jump
         PUSH    CX; store new offset in stack
         REP     MOVSB; move CP/M jump
         POP     [SI-4]; store offset of new jump
         MOV     [SI-2],ES; store segment of new jump
         PUSH    ES
         POP     DS; restore owner PS
         MOV     WORD PTR [DI+1CH],0AEBH; store jump to begres
         MOV     DI,32H; set new offset of resident part
         MOV     SI,102H; offset wf begres
         MOV     CX,2DH; length of resident part
         REP     MOVSB; move resident part
         MOV     ES,DS:[2CH]; environment segment
         MOV     AH,49H
         INT     21H; release environment block
         MOV     DX,6; size of resident part
         MOV     AH,31H
         INT     21H; terminate and stay resident
STOPEXPL ENDP
END      START
MSEG     ENDSEG
