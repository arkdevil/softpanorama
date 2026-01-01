
; iskradur.asm

CSEG           SEGMENT
               ASSUME CS:CSEG,DS:NOTHING
               ORG    0100H                  ;Beginning for .COM programs
START:         JMP    INIT                   ;Initialization code is at end
OLD_INT        DD     0                      ;Place to store old interrupt

NEW_INT        PROC   FAR

               STI                           ;Allow interrupts
               PUSH   BX                     ;Save registers
               PUSH   AX

               PUSHF                         ;Simulate an interrupt
               CALL   DWORD PTR OLD_INT

               POP    BX                     ;Get old AX in BX
               PUSHF                         ;Preserve flags
               OR     BH,BH                  ;It wait for key
               JZ     CHECK                  ; see what we got
               CMP    BH,10H                 ;Same for advanced
               JE     CHECK                  ; version of keyboard
EXIT1:
               POPF                          ;Restore flags
               POP    BX                     ;And BX
               RET    2                      ;Discard old flags
CHECK:
               CMP    Al,0B0H
               JL     EXIT1
	       CMP    AL,0DFH
	       JG     EXIT1
	       SUB    AL,48
               JMP    EXIT1

NEW_INT        ENDP

;-----------------------------------------------------------------------------;
; Data area used by this program                                              ;
;-----------------------------------------------------------------------------;
OLDINT1C       DD     ?                 ;Old timer interrupt vector
;-----------------------------------------------------------------------------;
; Intercept timer vector.                                                     ;
;-----------------------------------------------------------------------------;
               ASSUME DS:NOTHING, ES:NOTHING
NEWINT1C       PROC    FAR
               pushf
               call oldint1c
               ASSUME DS:CSEG, ES:CSEG

		PUSH AX
		PUSH DX
		PUSH ES
		PUSH SI

		MOV SI,0
	        mov ax, 0b800h        ; segment adress of video memory PAGE 0
	        mov es, ax

wait_status:	mov dx, 03dah
		in  al, dx
		and al, 1001b
		cmp al, 1001b
		jne EXIT  ;     wait_status       ; if video not ready, loop

		MOV SI,0
REPLACE:	MOV AL,ES:[SI]
		CMP AL,80H            ; A RUS
		JL  INCREMENT
		CMP AL,0AFH           ; graph
		JG  INCREMENT
RUS_ALT:	ADD AL,48
		MOV ES:[SI],AL
INCREMENT:	ADD SI,2
		CMP SI,4000
		JNE REPLACE
EXIT:
		POP  SI
		POP  ES
		POP  DX
		POP  AX
		IRET
NEWINT1C       ENDP
               ASSUME CS:CSEG,DS:CSEG,ES:CSEG
INIT:
               LEA    DX,COPYRIGHT
               MOV    AH,9                   ;DOS diplay string service
               INT    21H                    ;Display title message

	       ASSUME ES:NOTHING
               MOV    AX,351CH               ;Get TIMER  vector
               INT    21H
               MOV    WORD PTR [OLDINT1C],BX      ;Save segment
               MOV    WORD PTR [OLDINT1C+2],ES    ;Save offset
               MOV    DX,OFFSET NEWINT1C
               MOV    AX,251CH
               INT    21H                    ;DOS function to change vector

               MOV    AX,3516H               ;Get interrupt vector
               INT    21H                    ;Result in ES:BX
               MOV    WORD PTR OLD_INT[0],BX ;Save offset
               MOV    WORD PTR OLD_INT[2],ES ;Save segment
               MOV    DX,OFFSET NEW_INT      ;Load our interrupt
               MOV    AX,2516H               ;Set interrupt vector
               INT    21H
;-----------------------------------------------------------------------------;
; Exit using INT 27h.  Leave code and space for buffer resident.              ;
;-----------------------------------------------------------------------------;
               MOV    AX,DS:[002CH]          ;Get segment of environment
               MOV    ES,AX                  ;Put it into ES
               MOV    AH,49H                 ;Release allocated memory
               INT    21H
               MOV    DX,OFFSET INIT        ;Leave this much resident
               INT    27H                    ;Terminate and stay resident

COPYRIGHT      DB     "Screen SuperDriver for SuperComputer ISKRA-1030",13,10
               db     "Provide alternative font without graphic characters !"
               DB     13,10,"Made by (SL)-Semuonov Leonid(1990)",13,10
PROGRAMMER     DB     "Please, send contribution(5 rubles) to adress:",13,10
               DB     "        Simferopol, Leningradskya 6/36-34",13,10
               DB     "If you have a problems with computer servis and programming:",13,10
               DB     "        Call: (065) 25-73-76(home) or 29-24-51(work) $"

CSEG           ENDS
               END    START