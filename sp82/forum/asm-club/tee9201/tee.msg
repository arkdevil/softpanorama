[From the FIDO Dr. Debug Echo]
  From: Tom  Barrett
    To: Jim Hill				Date: 08 Jan 92  20:15:00
  Subj: redirecting output
  Conf: `Dr. Debug Conference'
*******************************************************************************
 > I'm wondering if there's any way I can have both "writes"
 > occur.

Yessir... just try and locate a tiny little program probably called "tee.com"
and insert it within a piped output like "DIR | tee >save.txt" ... our you can
write a quick one using DEBUG:

a
MOV AH,3F
MOV BX,0000
MOV CX,F000
MOV DX,0200
INT 21
jc  113
AND AX,AX
JNZ 0114
RET
PUSH AX
PUSH AX
MOV AH,40
MOV BX,0001
POP CX
MOV DX,0200
INT 21
MOV AH,40
MOV BX,0002
POP CX
MOV DX,0200
INT 21
JMP 0100

ntee.com
rcx
30
w
q

---
 * Origin: TDBear's Den | Jeez! What a mess! | (1:102/1006.6)
