;
; ┌─────────────────────────────────────────────────────┐      
; │  Данный .asm-файл представляет собой результат      │ 
; │  декомпиляции Norton Commander, его одной части,    │ 
; │  где были собраны только ассемблерные модули. Это   │ 
; │  позволяет предположить, что это ассемблерная часть │ 
; │  библиотеки, с помощью которой был собран Norton    │ 
; │  Commander. Полагаю, что как начинающим, так и про- │ 
; │  должающим программистам полезно ознакомиться со    │ 
; │  стилем программирования автора NC.                 │ 
; │   Некоторые названия функций возможно не вполне     │ 
; │  точно отражают их суть, так что читателю предостав-│ 
; │  ляется самому изменить эти названия с помощью      │ 
; │  контекстной замены.                                │ 
; │   Полный набор всех модулей системы NC находится в  │ 
; │  файле NCWORK.ZIP                                   │ 
; │                                                     │ 
; │                           Обухов Л.И. тел.266-22-75 │ 
; └─────────────────────────────────────────────────────┘ 
;
;          Библиотека DOS-функций JOHN SOCHA
;
;
_TEXT   segment byte public 'CODE'
DGROUP  group   _DATA,_BSS
        assume  cs:_TEXT,ds:DGROUP,ss:DGROUP
        ;org 0D326h 
_TEXT   ends
_BSS    segment word public 'BSS'
_BSS    ends
_TEXT   segment byte public 'CODE'

public _yround
_yround:
lab_D326:
  PUSH BP   
  MOV BP,SP
  PUSH SI   
  MOV SI,[BP+04h] 
  MOV AX,[SI]
  MOV DX,[SI+02h] 
  MOV BX,[BP+06h] 
  DEC BX   
  ADD AX,BX
  ADC DX,00 
  INC BX   
  CMP DX,BX
  JA lab_D34C 
  DIV BX   
  MUL BX   
lab_D344:
  MOV [SI],AX
  MOV [SI+02h],DX 
  POP SI   
  POP BP   
  RET
lab_D34C:
  XOR AX,AX
  NOT AX   
  MOV DX,AX
  JMP lab_D344 

public _yreset_mode
_yreset_mode:
lab_D354:
  PUSH SI   
  PUSH DI   
  PUSH BP   
  PUSH DS   
  MOV AX,0040h
  MOV DS,AX
  MOV AH,0Fh
  INT 10h
  XOR AH,AH
  OR AL,80h
  INT 10h  
  AND BYTE PTR DS:[87h],07Fh 
  AND BYTE PTR DS:[87h],0FEh ;запрет эмуляции курсора               
  MOV AX,0100h
  MOV CX,0607h
  INT 10h
  POP DS   
  POP BP   
  POP DI   
  POP SI   
  RET

public _yega_line
_yega_line:
lab_D37E:
  PUSH SI   
  PUSH DI   
  PUSH BP   
  PUSH DS   
  MOV AX,0040h
  MOV DS,AX
  MOV AH,0Fh
  INT 10h
  XOR AH,AH
  OR AL,80h
  INT 10h
  AND BYTE PTR DS:[87h],7Fh
  MOV AX,1112h
  MOV BL,00
  INT 10h
  OR BYTE PTR DS:[87h],01h ; установить эмуляцию курсора
  MOV AX,0100h
  MOV CX,0607h
  INT 10h
  MOV AX,1200h
  MOV BL,20h
  INT 10h
  MOV DX,WORD PTR DS:[63h]
  MOV AL,0Eh
  OUT DX,AL
  INC DX   
  MOV AL,07h
  OUT DX,AL
  POP DS   
  POP BP   
  POP DI   
  POP SI   
  RET
  db 0

public _yset_cur    ; (DH,DL)
_yset_cur:
lab_D3C2:
  PUSH AX
  PUSH BX
  PUSH SI   
  PUSH DI   
  PUSH BP   
  CALL _yget_page 
  MOV BH,AL
  MOV AH,02h
  INT 10h
  POP BP   
  POP DI   
  POP SI   
  POP BX   
  POP AX   
  RET

public _yget_cur_pos
_yget_cur_pos:
lab_D3D6:
  PUSH BX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  CALL _yget_page 
  MOV BH,AL
  MOV AH,03h
  INT 10h  
  MOV AX,DX
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP BX   
  RET

public _yset_cur1
_yset_cur1:
lab_D3EC:
  PUSH DX   
  XOR DX,DX
  CALL _yset_cur
  POP DX   
  RET

public _yget_page
_yget_page:
lab_D3F4:
  PUSH BX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV AH,0Fh
  INT 10h
  MOV AL,BH
  POP BP   
  POP DI   
  POP SI   
  POP BX   
  RET

public _yset_cur_size0    ; (DH,DL)
_yset_cur_size0:
lab_D403:
  PUSH AX   
  PUSH CX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  CALL _yget_cur_size 
  MOV WORD PTR glob_3940,AX
  MOV CH,DH
  MOV CL,DL
  MOV AH,01
  INT 10h  
  POP BP   
  POP DI   
  POP SI   
  POP CX   
  POP AX   
  RET

public _yset_cur_size
_yset_cur_size:
lab_D41C:
  CALL _yget_cur_size 
  CMP AH,0Fh
  JB lab_D42A 
  MOV AX,0607h
  CALL lab_D443 
lab_D42A:
  RET

public _yget_cur_size
_yget_cur_size:
lab_D42B:
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  XOR BH,BH
  MOV AH,03h
  INT 10h
  MOV AX,CX
  CALL lab_D443 
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  RET

public _yget_cur_sz
_yget_cur_sz:
lab_D443:
  CMP AX,0067h
  JNZ lab_D44B 
  MOV AX,0607h
lab_D44B:
  PUSH AX   
  INT 11h  
  AND AL,30h
  CMP AL,30h
  POP AX   
  JNZ lab_D45D 
  CMP AX,0607h
  JNZ lab_D45D 
  MOV AX,0B0Ch
lab_D45D:
  RET

public _yhide_cur
_yhide_cur:
lab_D45E:
  PUSH AX   
  PUSH DX   
  MOV DH,0Fh
  MOV DL,00h
  CALL _yset_cur_size0 
  POP DX   
  POP AX   
  RET

public _yrestore_cur_size
_yrestore_cur_size:
lab_D46A:
  PUSH DX   
  MOV DX,WORD PTR glob_3940
  CALL lab_D403 
  POP DX   
  RET

public _yset_cur_ibm
_yset_cur_ibm:
lab_D474:
  PUSH AX   
  PUSH DX   
  XOR DH,DH
  MOV DL,07h
  CALL lab_DD07 
  CMP AL,03h
  JNZ lab_D483 
  MOV DL,0Dh
lab_D483:
  CALL lab_D403 
  POP DX   
  POP AX   
  RET
  
public _yset_cur2
_yset_cur2:
lab_D489:
  PUSH AX   
  PUSH DX   
  MOV DH,06h
  MOV DL,07h
  CALL lab_DD07 
  CMP AL,03h
  JNZ lab_D483 
  MOV DH,0Bh
  MOV DL,0Ch
  CALL lab_D403 
  POP DX   
  POP AX   
  RET

public _yclear_screen
_yclear_screen:
lab_D4A0:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  XOR BH,BH
  CALL _yis_old_mode 
  JZ lab_D4B2 
  MOV BH,atr_window
lab_D4B2:
  SUB AL,AL
  SUB CX,CX
  MOV DX,184Fh
  MOV AH,06h
  INT 10h
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET

public _yscrollup0   ; (BL,BH,AL,AH)
_yscrollup0:
lab_D4C5:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV CX,BX
  MOV DX,AX
  XOR BH,BH
  CALL _yis_old_mode 
  JZ lab_D4DB 
  MOV BH,atr_window
lab_D4DB:
  SUB AL,AL
  MOV AH,06h
  INT 10h
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET

public _yscrollup1  ; (BL,BH,AL,AH)
_yscrollup1:
lab_D4E9:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  CMP BH,AH
  JNZ lab_D4F6 
  XOR CX,CX
lab_D4F6:  MOV DX,AX
  MOV AL,CL
  MOV CX,BX
  XOR BH,BH
  CALL _yis_old_mode 
  JZ lab_D507 
  MOV BH,atr_window
lab_D507:
  MOV AH,06h
  INT 10h
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET

public _yscrolldn0  ; (BL,BH,AL,AH,CX)
_yscrolldn0:
lab_D513:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  CMP BH,AH
  JNZ lab_D520 
  XOR CX,CX
lab_D520:
  MOV DX,AX
  MOV AL,CL
  MOV CX,BX
  XOR BH,BH
  CALL _yis_old_mode 
  JZ lab_D531 
  MOV BH,atr_window
lab_D531:
  MOV AH,07h
  INT 10h  
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET

public _get_ega_mode
_yget_ega_mode:
lab_D53D:
  PUSH BX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV AH,0Fh
  INT 10h
  XOR AH,AH
  POP BP   
  POP DI   
  POP SI   
  POP BX   
  RET

public _yset_mode0
_yset_mode0:
lab_D54C:
  PUSH BX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV AH,00h
  INT 10h
  POP BP   
  POP DI   
  POP SI   
  POP BX   
  RET

public _yis_old_mode
_yis_old_mode:
lab_D559:
  PUSH AX   
  PUSH BX   
  CALL _yget_ega_mode 
  CMP AL,old_ega_mode
  JA lab_D56A 
  MOV BX,offset glob_358B
  XLAT      
  CMP AL,01h
lab_D56A:
  POP BX   
  POP AX   
  RET

public _yround24
_yround24:
lab_D56D:
  PUSH AX   
  PUSH BX   
  CALL _yget_ega_mode 
  CMP AL,old_ega_mode
  JA lab_D57E 
  MOV BX,offset glob_359C
  XLAT      
  CMP AL,01h
lab_D57E:
  POP BX   
  POP AX   
  RET
  db 0

public _yround25
_yround25:
lab_D582:
  PUSH AX
  PUSH BX
  PUSH CX   
  LEA AX,glob_E940
  ADD AX,000Fh
  MOV CL,04h
  SHR AX,CL
  CALL lab_D5B3 
  POP CX   
  POP BX   
  POP AX   
  RET

public _yround26
_yround26:
lab_D597:
  PUSH BX   
  PUSH CX   
  MOV AX,0FFFh
  MOV CX,AX
  CALL lab_D5B3 
  JNB lab_D5AE 
  MOV AX,BX
  MOV CX,BX
  CALL lab_D5B3 
  JNB lab_D5AE 
  XOR CX,CX
lab_D5AE:
  MOV AX,CX
  POP CX   
  POP BX   
  RET

public _yround27
_yround27:
lab_D5B3:
  PUSH DX   
  PUSH ES   
  MOV BX,CS:[0024h]
  MOV ES,BX
  MOV DX,DS
  SUB DX,BX
  MOV BX,DX
  ADD BX,AX
  MOV AH,4Ah
  INT 21h
  JB lab_D5CE 
  XOR AX,AX
  JMP short lab_D5D1 
lab_D5CE:
  SUB BX,DX
  STC      
lab_D5D1:
  POP ES   
  POP DX   
  RET

public _yround28
_yround28:
lab_D5D4:
  MOV AX,DS
  RET

public _yround29
_yround29:
lab_D5D7:
  PUSH CX   
  PUSH SI   
  PUSH DI   
  CLD      
  REPZ      
  MOVSB      
  POP DI   
  POP SI   
  POP CX   
  RET
  db 0

public _yround30
_yround30:
lab_D5E2:
  PUSH BX
  PUSH ES
  MOV AX,3533h
  INT 21h  
  MOV AX,ES
  OR AX,AX
  JZ lab_D5F8 
  OR BX,BX
  JZ lab_D5F8 
  MOV AX,0001h
  JMP short lab_D5FA 
lab_D5F8:  XOR AX,AX
lab_D5FA:
  POP ES   
  POP BX   
  RET

public _yround31
_yround31:
lab_D5FD:
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH BP   
  PUSH ES   
  CALL lab_D5E2 
  OR AX,AX
  JZ lab_D663 
  MOV AX,0021h
  INT 33h
  CMP AX,0021h
  JZ lab_D61D 
  CMP AX,0FFFFh
  JNZ lab_D61D 
  CMP BX,+02h
  JZ lab_D626 
lab_D61D:
  MOV AX,0000h
  INT 33h
  OR AX,AX
  JZ lab_D663 
lab_D626:
  MOV AX,000Ah
  XOR BX,BX
  MOV CX,0FFFFh
  MOV DX,7700h
  INT 33h
  MOV BYTE PTR glob_183B,00h                
  CALL _yis_ega 
  JNZ lab_D65A 
  MOV AX,1130h
  XOR BH,BH
  INT 10h
  INC DL   
  CMP DL,19h
  JZ lab_D65A 
  MOV AL,DL
  MUL CL   
  DEC AX   
  MOV DX,AX
  MOV AX,0008h
  MOV CX,0000
  INT 33h
lab_D65A:
  MOV glob_1838,AL
  POP ES   
  POP BP   
  POP DX   
  POP CX   
  POP BX   
lab_D662:  RET
lab_D663:  XOR AX,AX
  JMP short lab_D65A 
  TEST BYTE PTR glob_1838,0FFh               
  JZ lab_D680 
  INC BYTE PTR glob_183B
  CMP BYTE PTR glob_183B,01h                
  JNZ lab_D680 
  PUSH AX   
  MOV AX,0001h
  INT 33h  
  POP AX   
lab_D680:
  RET

public _yround32
_yround32:
lab_D681:
  TEST BYTE PTR glob_1838,0FFh
  JZ lab_D69A 
  DEC BYTE PTR glob_183B
  CMP BYTE PTR glob_183B,00                
  JNZ lab_D69A 
  PUSH AX   
  MOV AX,0002h
  INT 33h
  POP AX   
lab_D69A:
  RET
  db 0

public _yround33
_yround33:
lab_D69C:
  PUSH AX
  MOV  AH,02h
  INT  21h
  POP  AX
  RET
  
public _yround34
_yround34:
lab_D6A3:
  PUSH DX   
  db 81h,0E2h,0fh,00    ;AND DX,000Fh
  CMP DL,0Ah
  JNB lab_D6B2 
  ADD DL,30h
  JMP short lab_D6B5 
lab_D6B2:  ADD DL,37h
lab_D6B5:  CALL lab_D69C 
  POP DX   
  RET

public _yround35
_yround35:
lab_D6BA:
  PUSH CX   
  PUSH DX   
  MOV DH,DL
  MOV CL,04h
  SHR DL,CL
  CALL lab_D6A3 
  MOV DL,DH
  CALL lab_D6A3 
  POP DX   
  POP CX   
  RET

public _yround36
_yround36:
lab_D6CD:
  XCHG DL,DH
  CALL lab_D6BA 
  XCHG DL,DH
  CALL lab_D6BA 
  RET

public _yround37
_yround37:
lab_D6D8:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  MOV AX,DX
  MOV BX,000Ah
  XOR CX,CX
lab_D6E3:
  XOR DX,DX
  DIV BX   
  PUSH DX   
  INC CX   
  OR AX,AX
  JNZ lab_D6E3 
lab_D6ED:
  POP DX   
  CALL lab_D6A3 
  LOOP lab_D6ED 
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET

public _yround38
_yround38:
lab_D6F8:
  PUSH AX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  CMP DX,270Fh
  JA lab_D737 
  MOV SI,2710h
  DIV SI   
  OR AX,AX
  JZ lab_D72F 
  XCHG DX,AX
  CALL lab_D6D8 
  PUSH AX   
  MOV SI,000Ah
  MOV CX,0004h
lab_D716:
  OR AX,AX
  JZ lab_D721 
  DEC CX   
  XOR DX,DX
  DIV SI   
  JMP short lab_D716 
lab_D721:
  OR CX,CX
  JZ lab_D72C 
  MOV DL,30h
lab_D727:  CALL lab_D69C 
  LOOP lab_D727 
lab_D72C:  POP AX   
  MOV DX,AX
lab_D72F:  CALL lab_D6D8 
lab_D732:
  POP SI   
  POP DX   
  POP CX   
  POP AX   
  RET

public _yround39
_yround39:
lab_D737:
  STC      
  JMP short lab_D732 
  PUSH DX   
  OR DX,DX
  JNS lab_D748 
  NEG DX   
  PUSH DX   
  MOV DL,2Dh
  CALL lab_D69C 
  POP DX   
  CALL lab_D6D8 
lab_D748:
  POP DX   
  RET

public _yround40
_yround40:
lab_D74D:
  PUSH AX   
  PUSH DX   
  PUSH SI   
  PUSHF      
  MOV SI,DX
  CLD      
lab_D754:  LODSB      
  OR AL,AL
  JZ lab_D760 
  MOV DL,AL
  CALL lab_D69C 
  JMP short lab_D754 
lab_D760:
  POPF      
  POP SI   
  POP DX   
  POP AX   
  RET

public _yround41
_yround41:
lab_D765:
  PUSH DX   
  MOV DL,0Dh
  CALL lab_D69C 
  MOV DL,0Ah
  CALL lab_D69C 
  POP DX   
  RET

public _yround42
_yround42:
lab_D772:
  PUSH AX   
  PUSH BP   
  MOV AL,07h
  MOV AH,0Eh
  INT 10h
  POP BP   
  POP AX   
  RET
  db 0

public _yround43
_yround43:
lab_D77E:
  MOV  AH,01h
  INT  21h
  XOR  AH,AH
  CLD
  RET

public _yround44
_yround44:
lab_D786:
  XOR AH,AH
  INT 16h  
  CALL lab_D78F 
  CLD      
  RET

public _yround45
_yround45:
lab_D78F:
  OR AL,AL
  JZ lab_D79A 
  CMP AL,0E0h
  JZ lab_D79A 
  XOR AH,AH
  RET

public _yround46
_yround46:
lab_D79A:
  XCHG AL,AH
  MOV AH,01h
  RET

public _yround47
_yround47:
lab_D79F:
  MOV AH,00
  INT 16h
  CLD      
  RET

public _yround48
_yround48:
lab_D7A5:
  MOV AH,08h
  INT 21h
  XOR AH,AH
  CLD      
  RET

public _yround49
_yround49:
lab_D7AD:
  PUSH DX   
  MOV AX,0C06h
  MOV DL,0FFh
  INT 21h  
  POP DX   
  CLD      
  RET

public _yround50
_yround50:
lab_D7B8:
  INT 28h
  MOV AH,01
  INT 16h
  JNZ lab_D7C4 
  XOR AX,AX
  NOT AX   
lab_D7C4:  CLD      
  RET

public _yround51
_yround51:
lab_D7C6:
  MOV AH,02h
  INT 16h
  XOR AH,AH
  CLD      
  RET

public _yround52
_yround52:
lab_D7CE:
  MOV AH,30h
  INT 21h
  XCHG AL,AH
  RET

public _yround53
_yround53:
lab_D7D5:
  PUSH CX   
  PUSH DX   
  MOV AH,2Ah
  INT 21h  
  MOV BX,CX
  MOV AX,DX
  POP DX   
  POP CX   
  RET

public _yround54
_yround54:
lab_D7E2:
  PUSH CX   
  PUSH DX   
  MOV AH,2Ch
  INT 21h
  MOV BX,CX
  MOV AX,DX
  POP DX   
  POP CX   
  RET

public _yround55
_yround55:
lab_D7EF:
  MOV AH,19h
  INT 21h
  XOR AH,AH
  RET

public _yround56
_yround56:
lab_D7F6:
  PUSH BX   
  PUSH DS   
  XOR AX,AX
  MOV DS,AX
  MOV BX,0504h
  MOV AL,[BX]
  CMP AL,01h
  JZ lab_D807 
  XOR AL,AL
lab_D807:
  POP DS   
  POP BX   
  RET
  
public _yround57
_yround57:
lab_D80A:
  PUSH AX   
  PUSH DX   
  MOV WORD PTR glob_1842,0B000h
  MOV WORD PTR glob_1847,0019h
  MOV BYTE PTR glob_183E,00                
  CALL lab_DD07 
  CMP AL,03h
  JZ lab_D84C 
  MOV WORD PTR glob_1842,0B800h
  CALL _yis_ega 
  JZ lab_D840 
  CALL lab_DD24 
  JZ lab_D84C 
  CALL lab_DD13 
  JZ lab_D84C 
  MOV BYTE PTR glob_183E,01h
  JMP short lab_D84C 
lab_D840:  CALL lab_DD85 
  CMP AL,32h
  JBE lab_D849 
  MOV AL,32h
lab_D849:  MOV glob_1847,AL
lab_D84C:  PUSH CX   
  CALL _yget_page 
  MOV BYTE PTR glob_1846,AL
  MOV AH,AL
  XOR AL,AL
  MOV CL,04h
  SHL AX,CL
  MOV glob_1844,AX
  POP CX   
  PUSH BX   
  PUSH DI   
  PUSH ES   
  MOV BX,glob_1842
  MOV ES,BX
  XOR DI,DI
  MOV AH,0FEh
  INT 10h
  MOV AX,ES
  CMP AX,BX
  JZ lab_D88A 
  MOV BYTE PTR glob_1840,01h
  MOV glob_1842,AX
  MOV glob_1844,DI
  MOV BYTE PTR glob_1846,00                
  MOV BYTE PTR glob_183E,00                
lab_D88A:
  POP ES   
  POP DI   
  POP BX   
  CALL _yget_cur_pos 
  MOV DX,AX
  CALL lab_DABE 
  CALL lab_D994 
  MOV glob_183C,AL
  MOV atr_window,AL
  POP DX   
  POP AX   
  RET
  
public _yround58
_yround58:
lab_D8A1:
  PUSH AX   
  PUSH BX   
  PUSH ES   
  CMP WORD PTR glob_1849,04Fh
  JA lab_D8E5 
  MOV AX,glob_1842
  MOV ES,AX
  MOV BX,glob_184D
  MOV AH,glob_183C
  MOV AL,DL
  TEST BYTE PTR glob_183E,01               
  JZ lab_D8E2 
  PUSH AX   
  PUSH BX   
  PUSH DX   
  PUSH DI   
  MOV DI,BX
  CLD      
  MOV DX,03DAh
  MOV BX,AX
lab_D8CD:  IN AL,DX
  TEST AL,01h
  JNZ lab_D8CD 
  CLI      
lab_D8D3:  IN AL,DX
  TEST AL,01h
  JZ lab_D8D3 
  MOV AX,BX
  STOSW      
  STI      
  POP DI   
  POP DX   
  POP BX   
  POP AX   
  JMP short lab_D8E5 
lab_D8E2:
  MOV ES:[BX],AX
lab_D8E5:
  MOV BX,glob_1849
  INC BX   
  CMP BX,04Fh
  JA lab_D8F8 
  MOV glob_1849,BX
  ADD WORD PTR glob_184D,02h
lab_D8F8:  TEST BYTE PTR glob_1840,01h
  JZ lab_D90C 
  PUSH CX   
  PUSH DI   
  MOV DI,BX
  MOV CX,0001
  MOV AH,0FFh
  INT 10h 
  POP DI   
  POP CX   
lab_D90C:
  POP ES   
  POP BX   
  POP AX   
  RET
  
public _yround59
_yround59:
lab_D910:
  TEST DL,0F0h
  JZ lab_D919 
lab_D915:
  CALL lab_D8A1 
  RET
  
public _yround60
_yround60:
lab_D919:
  CMP DL,0Dh
  JZ lab_D92F 
  CMP DL,0Ah
  JZ lab_D93B 
  CMP DL,09h
  JZ lab_D97B 
  CMP DL,07h
  JZ lab_D97A 
  JMP short lab_D915 
lab_D92F:  PUSH DX   
  MOV DH,glob_184B
  XOR DL,DL
  CALL lab_DABE 
  POP DX   
  RET
  
public _yround61
_yround61:
lab_D93B:
  PUSH AX   
  MOV AX,WORD PTR glob_1847
  DEC AX   
  CMP WORD PTR glob_184B,AX
  POP AX   
  JNB lab_D957 
  PUSH DX   
  MOV DH,glob_184B
  INC DH   
  MOV DL,BYTE PTR glob_1849
  CALL lab_DABE 
  POP DX   
  RET
  
public _yround62
_yround62:
lab_D957:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV AX,0601h
  MOV BH,glob_183C
  MOV CX,0000h
  MOV DH,glob_1847
  DEC DH   
  MOV DL,04Fh
  INT 10h 
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET
  
public _yround63
_yround63:
lab_D97A:  RET

public _yround64
_yround64:
lab_D97B:
  PUSH CX   
  PUSH DX   
  MOV DL,20h
  MOV CX,glob_1849
  db 81h,0E1h,07h,00   ; AND CX,0007h
lab_D98C:  NEG CX   
  ADD CX,08h 
  CALL lab_D8A1 
  LOOP lab_D98C 
  POP DX   
  POP CX   
  RET
  
public _yround65
_yround65:
lab_D994:
  PUSH DX   
  PUSH DI   
  PUSH ES   
  MOV AX,glob_1842
  MOV ES,AX
  MOV DI,glob_184D
  INC DI   
  TEST BYTE PTR glob_183E,01               
  JZ lab_D9B6 
  MOV DX,03DAh
lab_D9AB:
  IN AL,DX
  TEST AL,01h
  JNZ lab_D9AB 
  CLI      
lab_D9B1:
  IN AL,DX
  TEST AL,01h
  JZ lab_D9B1 
lab_D9B6:
  MOV AL,ES:[DI]
  STI      
  XOR AH,AH
  POP ES   
  POP DI   
  POP DX   
  RET
  
public _yround66
_yround66:
lab_D9C0:
  PUSH AX   
  PUSH DX   
  PUSH SI   
  PUSHF      
  MOV SI,DX
  CLD      
lab_D9C7:
  LODSB      
  OR AL,AL
  JZ lab_D9D3 
  MOV DL,AL
  CALL lab_D910 
  JMP short lab_D9C7 
lab_D9D3:
  POPF      
  POP SI   
  POP DX   
  POP AX   
  RET 
   
public _yround67
_yround67:
lab_D9D8:
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV BP,glob_1849
  ADD BP,CX
  DEC BP   
  PUSHF      
  MOV SI,DX
  XOR DI,DI
  CLD      
lab_D9EB:  OR BX,BX
  JZ lab_DA16 
  LODSB      
  OR AL,AL
  JZ lab_DA4E 
  CMP AL,09h
  JNZ lab_DA12 
  MOV AX,DI
  DIV BYTE PTR glob_18C7
  SUB AH,BYTE PTR glob_18C7
  NEG AH   
lab_DA04:  CMP AH,01h
  JZ lab_DA12 
  INC DI   
  DEC AH   
  DEC BX   
  JNZ lab_DA04 
  DEC SI   
  JMP short lab_DA16 
lab_DA12:  INC DI   
  DEC BX   
  JNZ lab_D9EB 
lab_DA16:  LODSB      
  OR AL,AL
  JZ lab_DA4E 
  CMP AL,09h
  JNZ lab_DA45 
  CMP BYTE PTR glob_18C7,01h
  JZ lab_DA45 
  MOV AX,DI
  DIV BYTE PTR glob_18C7
  SUB AH,BYTE PTR glob_18C7
  NEG AH   
  CMP AH,CL
  JNB lab_DA4E 
  MOV DL,20h
lab_DA38:  CALL lab_D8A1 
  INC DI   
  DEC CX   
  JZ lab_DA4E 
  DEC AH   
  JNZ lab_DA38 
  JMP short lab_DA16 
lab_DA45:  MOV DL,AL
  CALL lab_D8A1 
  INC DI   
  DEC CX   
  JNZ lab_DA16 
lab_DA4E:  JCXZ lab_DA57 
  MOV DL,20h
lab_DA52:  CALL lab_D8A1 
  LOOP lab_DA52 
lab_DA57:  DEC SI   
  LODSB      
  OR AL,AL
  JNZ lab_DA5E 
  DEC SI   
lab_DA5E:  MOV AX,SI
  POPF      
  POP BP   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  POP BX   
  RET
  
public _yround68
_yround68:
lab_DA68:
  PUSH DX   
  db 81h,0E2h,0Fh,0   ; AND DX,000Fh
  CMP DL,0Ah
  JNB lab_DA77 
  ADD DL,30h
  JMP short lab_DA7A 
lab_DA77:  ADD DL,37h
lab_DA7A:  CALL lab_D910 
  POP DX   
  RET
  
public _yround69
_yround69:
lab_DA7F:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  MOV AX,DX
  MOV BX,000Ah
  XOR CX,CX
lab_DA8A:  XOR DX,DX
  DIV BX   
  PUSH DX   
  INC CX   
  OR AX,AX
  JNZ lab_DA8A 
lab_DA94:  POP DX   
  CALL lab_DA68 
  LOOP lab_DA94 
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET
  
public _yround70
_yround70:
lab_DA9F:
  PUSH CX   
  JCXZ lab_DAA7 
lab_DAA2:  CALL lab_D8A1 
  LOOP lab_DAA2 
lab_DAA7:
  POP CX   
  RET
  
public _yround71
_yround71:
lab_DAA9:
  PUSH DX   
  MOV DL,20h
  CALL lab_DA9F 
  POP DX   
  RET
  
public _yround72
_yround72:
lab_DAB1:
  PUSH DX   
  MOV DL,0Dh
  CALL lab_D910 
  MOV DL,0Ah
  CALL lab_D910 
  POP DX   
  RET
  
public _yround73
_yround73:
lab_DABE:
  PUSH BX   
  PUSH DX   
  MOV BL,glob_1847
  DEC BL   
  CMP DH,BL
  JBE lab_DAD2 
  CMP DH,BL
  MOV DH,BL
  JG lab_DAD2 
  MOV DH,00
lab_DAD2:  CALL _yset_cur 
  MOV BYTE PTR glob_1849,DL
  MOV glob_184B,DH
  MOV BL,DH
  XOR BH,BH
  SHL BX,1h
  MOV BX,[BX+glob_184F]   
  ADD BX,glob_1849
  SHL BX,1h
  ADD BX,glob_1844
  MOV glob_184D,BX
  POP DX   
  POP BX   
  RET
  
public _yround74
_yround74:
lab_DAF8:
  PUSH DX   
  MOV DL,BYTE PTR glob_1849
  MOV DH,glob_184B
  CALL _yset_cur 
  POP DX   
  RET
  
public _yround75
_yround75:
lab_DB06:
  MOV AH,glob_184B
  MOV AL,BYTE PTR glob_1849
  RET
  
public _yround76
_yround76:
lab_DB0E:
  PUSH AX   
  PUSH BX   
  MOV BL,BYTE PTR glob_1849
  MOV BH,glob_184B
  MOV AL,4Fh
  CMP BL,AL
  JA lab_DB23 
  MOV AH,BH
  CALL _yscrollup0 
lab_DB23:  POP BX   
  POP AX   
  RET
  
public _yround77
_yround77:
lab_DB26:
  CMP DL,41h
  JB lab_DB4F 
  CMP DL,5Ah
  JA lab_DB35 
  ADD DL,20h
  JMP short lab_DB4F 
lab_DB35:  CMP DL,80h
  JB lab_DB4F 
  CMP DL,0A5h
  JA lab_DB4F 
  PUSH AX   
  PUSH BX   
  LEA BX,glob_35AE
  SUB DL,80h
  MOV AL,DL
  XLAT      
  MOV DL,AL
  POP BX   
  POP AX   
lab_DB4F:
  RET

public _yround78
_yround78:
lab_DB50:
  CMP DL,61h
  JB lab_DB5F 
  CMP DL,7Ah
  JA lab_DB5F 
  ADD DL,0E0h
  JMP short lab_DB79 
lab_DB5F:  CMP DL,80h
  JB lab_DB79 
  CMP DL,0A5h
  JA lab_DB79 
  PUSH AX   
  PUSH BX   
  LEA BX,glob_35D4
  SUB DL,80h
  MOV AL,DL
  XLAT      
  MOV DL,AL
  POP BX   
  POP AX   
lab_DB79:
  RET

public _yround79
_yround79:
lab_DB7A:
  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  PUSH DS   
  PUSH ES   
  MOV AX,DS
  PUSH ES   
  POP DS   
  MOV ES,AX
  CLD      
  MOV SI,DX
  MOV DI,BX
  JCXZ lab_DBA8 
  MOV DL,ES:[DI]
  INC DI   
  OR DL,DL
  JZ lab_DBA8 
  CALL lab_DB50 
  MOV DH,DL
  CALL lab_DB26 
lab_DB9D:  LODSB      
  CMP AL,DH
  JZ lab_DBAE 
  CMP AL,DL
  JZ lab_DBAE 
  LOOP lab_DB9D 
lab_DBA8:  XOR AX,AX
  DEC AX   
  JMP short lab_DBD9 
  NOP      
lab_DBAE:  PUSH CX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
lab_DBB2:
  MOV DL,ES:[DI]
  INC DI   
  OR DL,DL
  JZ lab_DBCF 
  DEC CX   
  JCXZ lab_DBCA 
  CALL lab_DB26 
  LODSB      
  XCHG AL,DL
  CALL lab_DB26 
  CMP AL,DL
  JZ lab_DBB2 
lab_DBCA:  XOR AX,AX
  DEC AX   
  JMP short lab_DBD1 
lab_DBCF:  XOR AX,AX
lab_DBD1:  POP DI   
  POP SI   
  POP DX   
  POP CX   
  JZ lab_DBD9 
  LOOP lab_DB9D 
lab_DBD9:  PUSHF      
  MOV AX,SI
  DEC AX   
  POPF      
  POP ES   
  POP DS   
  POP DI   
  POP SI   
  POP DX   
  POP CX   
  RET
  
public _yround80
_yround80:
lab_DBE5:
  PUSH SI   
  PUSH DI   
  MOV SI,BX
  MOV DI,DX
  CLD      
lab_DBEC:  LODSB      
  OR AL,AL
  JZ lab_DC15 
  MOV AH,ES:[DI]
  INC DI   
  OR AH,AH
  JZ lab_DC0F 
  OR CX,CX
  JNZ lab_DC0B 
  MOV DL,AL
  CALL lab_DB26 
  MOV AL,DL
  MOV DL,AH
  CALL lab_DB26 
  MOV AH,DL
lab_DC0B:  CMP AH,AL
  JZ lab_DBEC 
lab_DC0F:  XOR SI,SI
  INC SI   
lab_DC12:  POP DI   
  POP SI   
  RET
  
public _yround81
_yround81:
lab_DC15:
  CMP BYTE PTR ES:[DI],00                   
  JMP short lab_DC12 
lab_DC1B:  PUSH AX   
  PUSH DX   
  PUSH SI   
  PUSH DI   
  MOV SI,BX
  MOV DI,DX
  CLD      
lab_DC24:  LODSB      
  OR AL,AL
  JZ lab_DC47 
  MOV AH,ES:[DI]
  INC DI   
  OR AH,AH
  JZ lab_DC47 
  OR CX,CX
  JNZ lab_DC43 
  MOV DL,AL
  CALL lab_DB26 
  MOV AL,DL
  MOV DL,AH
  CALL lab_DB26 
  MOV AH,DL
lab_DC43:  CMP AH,AL
  JZ lab_DC24 
lab_DC47:  POP DI   
  POP SI   
  POP DX   
  POP AX   
  RET
  
public _yround82
_yround82:
lab_DC4C:
  PUSH AX   
  PUSH CX   
  PUSH SI   
  PUSH DI   
  PUSH ES   
  CLD      
  PUSH CX   
  PUSH DX   
  MOV AX,CS:[0024h]
  MOV ES,AX
  MOV AX,ES:[002Ch]
  MOV ES,AX
  XOR DI,DI
lab_DC62:  
  CMP BYTE PTR ES:[DI],00                   
  JZ lab_DCA0 
  MOV DX,DI
  XOR CX,CX
  CALL lab_DC1B 
  JZ lab_DC7E 
  MOV CX,8000h
  SUB CX,DI
  JB lab_DCA0 
  XOR AL,AL
  REPNZ      
  SCASB      
  JMP short lab_DC62 
lab_DC7E:  MOV CX,00A0h
  MOV AL,3Dh
  REPNZ      
  SCASB      
  POP DX   
  POP CX   
  DEC CX   
  MOV SI,DX
lab_DC8A:
  MOV AL,ES:[DI]
  MOV [SI],AL
  OR AL,AL
  JZ lab_DC97 
  INC SI   
  INC DI   
  LOOP lab_DC8A 
lab_DC97:  MOV BYTE PTR [SI],00            
  POP ES   
  POP DI   
  POP SI   
  POP CX   
  POP AX   
  RET
lab_DCA0:  POP DX   
  POP CX   
  MOV SI,DX
  JMP short lab_DC97 
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH DI   
  PUSH ES   
  MOV BX,DX
  CMP BYTE PTR glob_3AA6,03h
  JB lab_DCE7 
  CLD      
  MOV AX,CS:[0024h]
  MOV ES,AX
  MOV AX,ES:[002Ch]
  MOV ES,AX
  MOV CX,8000h
  XOR DI,DI
lab_DCC7:  XOR AL,AL
  REPNZ      
  SCASB      
  JCXZ lab_DCE7 
  CMP BYTE PTR ES:[DI],00                   
  JNZ lab_DCC7 
  INC DI   
  ADD DI,02h 
  MOV CX,003Fh
lab_DCDA:
  MOV AL,ES:[DI]
  OR AL,AL
  JZ lab_DCE7 
  MOV [BX],AL
  INC DI   
  INC BX   
  LOOP lab_DCDA 
lab_DCE7:  MOV BYTE PTR [BX],00            
  POP ES   
  POP DI   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET
  db 0
  
public _yround83
_yround83:
lab_DCF2:
  INT  11h
  TEST AX,0001h
  JZ lab_DD04 
  PUSH CX   
  MOV CL,06h
  SHR AX,CL
  POP CX   
  AND AX,0003h
  INC AX   
  RET
  
public _yround84
_yround84:
lab_DD04:
  XOR AX,AX
  RET
  
public _yround85
_yround85:
lab_DD07:
  PUSH CX   
  INT 11h
  MOV CL,04h
  SHR AX,CL
  AND AX,0003h
  POP CX   
  RET
  
public _yround86
_yround86:
lab_DD13:
  PUSH BX   
  PUSH ES   
  MOV BX,0F000h
  MOV ES,BX
  MOV BX,0FFFEh
  CMP BYTE PTR ES:[BX],0FDh
  POP ES   
  POP BX   
  RET
  
public _yround87
_yround87:
lab_DD24:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH DX   
  PUSH ES   
  MOV BX,0F000h
  MOV ES,BX
  MOV BX,offset glob_35FA
  MOV DX,0E000h
  MOV CX,0100h
  CALL lab_DB7A 
  POP ES   
  POP DX   
  POP CX   
  POP BX   
  POP AX   
  RET
  
public _yround88
_yround88:
lab_DD40:
  PUSH AX   
  PUSH BX   
  PUSH CX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  MOV AX,1200h
  MOV BL,10h
  MOV BH,0FFh
  MOV CL,0Fh
  INT 10h 
  CMP CL,0Ch
  JNB lab_DD69 
  CMP BH,01h
  JA lab_DD69 
  CMP BL,03h
  JA lab_DD69 
  XOR AX,AX
lab_DD62:
  POP BP   
  POP DI   
  POP SI   
  POP CX   
  POP BX   
  POP AX   
  RET
lab_DD69:  XOR AX,AX
  INC AX   
  JMP short lab_DD62 
  
public _yis_ega?
_yis_ega?:
lab_DD6E:
  CALL lab_DD40 
  JNZ lab_DD84 
  PUSH AX   
  PUSH ES   
  MOV AX,0040h
  MOV ES,AX
  TEST BYTE PTR ES:[0087h],08h ; EGA ?
  POP ES   
  POP AX   
  JZ lab_DD84 
lab_DD84:
  RET

public _yround90
_yround90:
lab_DD85:
  MOV AX,0019h
  CALL _yis_ega 
  JNZ lab_DDA4 
  PUSH BX   
  PUSH SI   
  PUSH DI   
  PUSH BP   
  PUSH ES   
  MOV AX,1130h
  XOR BH,BH
  INT 10h
  INC DL   
  MOV AL,DL
  XOR AH,AH
  POP ES   
  POP BP   
  POP DI   
  POP SI   
  POP BX   
lab_DDA4:
  RET

public _yround91
_yround91:
lab_DDA5:
  PUSH AX   
  PUSH DS   
  MOV AX,0040h
  MOV DS,AX
  CALL _yis_ega 
  JNZ lab_DDC4 
  CALL lab_DD85 
  CMP AL,19h
  JA lab_DDBF 
  AND BYTE PTR DS:[0087h],0FEh ; запретить эмуляцию курсора
  JMP short lab_DDC4 
lab_DDBF:
  OR BYTE PTR DS:[0087h],01h ; установить эмуляцию курсора
lab_DDC4:  POP DS   
  POP AX   
  RET
  
public _ydisable_cur
_ydisable_cur:
lab_DDC7:
  PUSH AX   
  PUSH DS   
  MOV AX,0040h
  MOV DS,AX
  AND BYTE PTR DS:[0087h],0FEh ; запретить эмуляцию курсора
  POP DS   
  POP AX   
  RET
  
public _yround93
_yround93:
lab_DDD6:
  PUSH DX   
  PUSH ES   
  MOV AX,0040h
  MOV ES,AX
  MOV DX,ES:[0063h]
  MOV AL,0Eh
  OUT DX,AL
  INC DX   
  IN AL,DX
  MOV AH,AL
  DEC DX   
  MOV AL,0Fh
  OUT DX,AL
  INC DX   
  IN AL,DX
  POP ES   
  POP DX   
  RET
  
public _yround94
_yround94:
lab_DDF2:
  PUSH AX   
  PUSH BX   
  PUSH DX   
  PUSH ES   
  MOV BX,AX
  MOV AX,0040h
  MOV ES,AX
  MOV DX,ES:[0063h]
  MOV AL,0Eh
  OUT DX,AL
  INC DX   
  MOV AL,BH
  OUT DX,AL
  DEC DX   
  MOV AL,0Fh
  OUT DX,AL
  INC DX   
  MOV AL,BL
  OUT DX,AL
  POP ES   
  POP DX   
  POP BX   
  POP AX   
  RET
  
public _yround95  ; ( _DX )
_yround95:
lab_DE16:
  PUSH DX   
  PUSH ES   
  MOV AX,0040h
  MOV ES,AX
  MOV AX,DX
  MOV DX,ES:[004Eh] ; смещение активной страницы
  SHR DX,1 
  SUB AX,DX
  MOV DX,ES:[004Ah] ; ширина экрана
  DIV DL   
  XCHG AL,AH
  POP ES   
  POP DX   
  RET
  
public _yclear_window  ; (x0,y0,x1,y1)
_yclear_window:
lab_DE34:
  PUSH BP   
  MOV BP,SP
  MOV BH,[BP+06h] 
  MOV BL,[BP+04h] 
  MOV AH,[BP+0Ah] 
  MOV AL,[BP+08h] 
  CALL _yscrollup0 
  POP BP   
  CLD      
  RET      
       
public _yscrollupc  ; (x0,y0,x1,y1,num)
_yscrollupc:
lab_DE49:
  PUSH BP   
  MOV BP,SP
  MOV BH,[BP+06h] 
  MOV BL,[BP+04h] 
  MOV AH,[BP+0Ah] 
  MOV AL,[BP+08h] 
  MOV CX,[BP+0Ch] 
  CALL _yscrollup1 
  POP BP   
  CLD      
  RET      
       
public _yscrolldnc   ; (x0,y0,x1,y1,num)
_yscrolldnc:
lab_DE61:
  PUSH BP   
  MOV BP,SP
  MOV BH,[BP+06h] 
  MOV BL,[BP+04h] 
  MOV AH,[BP+0Ah] 
  MOV AL,[BP+08h] 
  MOV CX,[BP+0Ch] 
  CALL _yscrolldn0 
  POP BP   
  CLD      
  RET      
       
public _yset_mode  ; (int mode)
_yset_mode:
lab_DE79:
  PUSH BP   
  MOV BP,SP
  MOV AL,[BP+04h] 
  CALL _yset_mode0
  POP BP   
  RET      
       
public _yround100
_yround100:
lab_DE84:
  XOR AX,AX
  CALL lab_D56D 
  JNZ lab_DE8D 
  NOT AX   
lab_DE8D:  RET      

public _yround101
_yround101:
lab_DE8E:
  PUSH BP   
  MOV BP,SP
  MOV DX,[BP+04h] 
  MOV AX,[BP+06h] 
  MOV DH,AL
  CALL _yset_cur 
  POP BP   
  RET      
       
public _yround102
_yround102:
lab_DE9E:
  PUSH BP   
  MOV BP,SP
  CALL _yget_cur_pos
  MOV CX,AX
  XOR CH,CH
  MOV BX,[BP+04h] 
  MOV [BX],CX
  MOV CL,AH
  MOV BX,[BP+06h] 
  MOV [BX],CX
  POP BP   
  RET      
       
public _yround103
_yround103:
lab_DEB6:
  CALL _yget_page 
  XOR AH,AH
  RET      
       
public _yround104
_yround104:
lab_DEBC:
  PUSH BP   
  MOV BP,SP
  MOV DX,[BP+04h] 
  CALL lab_D403 
  POP BP   
  RET           

_TEXT   ends
        
_DATA   segment word public 'DATA'
           ;db 1836h dup (0)
atr_window db 1bh,0     ; glob_1836
glob_1838  db 30h,0,0
glob_183B  db 0
glob_183C  db 1bh,0
glob_183E  dw 00
glob_1840  db 0,0
glob_1842  dw 0b800h
glob_1844  dw 00
glob_1846  db 0
glob_1847  db 19h,0
glob_1849  dw 4bh
glob_184B  db 0e0h,1h
glob_184D  dw 136h
glob_184F  dw 0h
           db (18c7h-184fh-2h) dup (0)
glob_18C7  db 8h
           ;db (358ah-18c7h-1) dup(0)
old_ega_mode  db 10h ; glob_358A
glob_358B  db 11h  dup (1)
glob_359C  db 12h  dup (0)
glob_35AE  db 87h,81h
           db 82h,83h,84h,85h,86h,87h,88h,89h
           db 8ah,8bh,8ch,8dh,84h,86h,82h,91h
           db 91h,93h,94h,95h,96h,97h,98h,94h
           db 81h,9bh,9ch,9dh,9eh,9fh,0a0h,0a1h
           db 0a2h,0a3h,0a4h,0a4h
glob_35D4  db 80h,9ah,90h,83h,8eh,85h,8fh,80h
           db 88h,89h,8ah,8bh,8ch,8dh,8eh,8fh         
           db 16h  dup (0)
glob_35FA  db 0 ;346h dup (0)
glob_3940  db 0 ;166h  dup (0)
glob_3AA6  db 0
glob_E940  dw 0
_DATA   ends

        end
;
 
