        .MODEL LARGE

;STKLEN  EQU 4096


S_SP    EQU 0
S_SS    EQU 2
S_NEXT  EQU 4
S_QACTIVE EQU 8
S_QDONE EQU 10

.DATA

OPER    DW ?
        DW ?
        DW OFFSET OPER
        DW SEG _DATA
        DW 0
        DW -1


ACTIVE_TASK     DW OFFSET OPER
ACTIVE_TASK_L   EQU ACTIVE_TASK
ACTIVE_TASK_H   DW SEG _DATA


.CODE

TRANSFER  PROC FAR PASCAL
        ARG T2_OFF:WORD, T2_SEG:WORD, T1_OFF:WORD, T1_SEG:WORD
        PUSH BP
        MOV BP,SP
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH DS
        PUSH ES
        PUSHF
        LES DI, DWORD PTR T1_OFF
        MOV ES:[DI+S_SP], SP
        MOV ES:[DI+S_SS], SS
        LES DI, DWORD PTR T2_OFF
        MOV SS,ES:[DI+S_SS]
        MOV SP,ES:[DI+S_SP]
        POPF
        POP ES
        POP DS
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        POP BP
        RETF 8
TRANSFER  ENDP

STOP      PROC FAR PASCAL
        pushf
        PUSH SI
        PUSH DS
        PUSH ES

        MOV AX,_DATA
        MOV DS,AX
        LES SI, DWORD PTR ACTIVE_TASK_L
        PUSH ES
        PUSH SI
LOOP1:  LES SI,ES:[SI+S_NEXT]
        CMP WORD PTR ES:[SI+S_QACTIVE],0
        JZ LOOP1
        MOV WORD PTR ES:[SI+S_QACTIVE],0
        MOV ACTIVE_TASK_L,SI
        MOV ACTIVE_TASK_H,ES
        PUSH ES
        PUSH SI
        CALL TRANSFER

        POP ES
        POP DS
        POP SI
        popf
        RETF
STOP    ENDP

PAUSE   PROC FAR
        PUSH AX
        PUSH SI
        PUSH DS
        PUSH ES
        MOV AX,_DATA
        MOV DS,AX
        LES SI, DWORD PTR ACTIVE_TASK_L
        MOV ES:[SI+S_QACTIVE],0FFFFH
        CALL STOP
        POP ES
        POP DS
        POP SI
        POP AX
        RETF
PAUSE   ENDP

BUILD   PROC FAR PASCAL
        ARG T_OFF:WORD , T_SEG:WORD
        PUSH BP
        MOV BP,SP
        PUSH AX
        PUSH SI
        PUSH DS
        PUSH ES
        MOV ES,T_SEG
        MOV SI,T_OFF
        MOV AX,_DATA
        MOV DS,AX
        PUSH [OPER+S_NEXT]
        POP ES:[SI+S_NEXT]
        PUSH [OPER+S_NEXT+2]
        POP ES:[SI+S_NEXT+2]
        MOV [OPER+S_NEXT],SI
        MOV [OPER+S_NEXT+2],ES
        MOV WORD PTR ES:[SI+S_QACTIVE],-1
        MOV WORD PTR ES:[SI+S_QDONE],0
        POP ES
        POP DS
        POP SI
        POP AX
        POP BP
        RETF 4
BUILD   ENDP

RUIN    PROC FAR PASCAL
        ARG T_OFF:WORD , T_SEG:WORD
        PUSH BP
        MOV BP,SP
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH DI
        PUSH DS
        PUSH ES
        MOV SI, OFFSET OPER
        MOV AX,_DATA
        MOV ES,AX          ; ES:SI - OPER
        MOV DS,AX
        MOV AX,T_SEG
        MOV BX,T_OFF
RUIN1:  CMP BX, ES:[SI+S_NEXT]
        JNZ RUIN2
        CMP AX, ES:[SI+S_NEXT+2]
        JZ OK
RUIN2:  MOV CX, ES:[SI+S_NEXT+2]
        MOV SI, ES:[SI+S_NEXT]
        MOV ES, CX
        JMP RUIN1
OK:     MOV DS, ES:[SI+S_NEXT+2]
        MOV DI, ES:[SI+S_NEXT]
        PUSH [DI+S_NEXT]
        POP ES:[SI+S_NEXT]
        PUSH [DI+S_NEXT+2]
        POP ES:[SI+S_NEXT+2]
        POP ES
        POP DS
        POP DI
        POP SI
        POP CX
        POP BX
        POP AX
        POP BP
        RETF 4
RUIN    ENDP


ACTIVATE PROC FAR PASCAL

;        ARG L:WORD, S_SEG:WORD, P_OFF:WORD, P_SEG:WORD, F_OFF:WORD, F_SEG:WORD, T_OFF:WORD,T_SEG:WORD
        ARG L:DWORD,  P_OFF:WORD, P_SEG:WORD, F_OFF:WORD, F_SEG:WORD, T_OFF:WORD,T_SEG:WORD


        PUSH BP
        MOV BP,SP
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH DS
        PUSH ES

;        MOV ES,S_SEG
;        MOV DI,L       ; ES:DI - STACK
        les di,l


        MOV AX,P_SEG
        SUB DI,2
        MOV ES:[DI],AX
        MOV AX,P_OFF
        SUB DI,2
        MOV ES:[DI],AX       ; PARM

        SUB DI,2
        MOV ES:[DI],CS
        SUB DI,2
        MOV ES:[DI],OFFSET BOLV

        SUB DI,8

        MOV AX,F_SEG
        SUB DI,2
        MOV ES:[DI],AX
        MOV AX,F_OFF
        SUB DI,2
        MOV ES:[DI],AX       ; F

        SUB DI,2
        MOV AX,[BP]
        MOV WORD PTR ES:[DI],AX        ;BP
        SUB DI,2
        MOV AX,[BP-2]
        MOV WORD PTR ES:[DI],AX        ;AX
        SUB DI,2
        MOV AX,[BP-4]
        MOV WORD PTR ES:[DI],AX        ;BX
        SUB DI,2
        MOV AX,[BP-6]
        MOV WORD PTR ES:[DI],AX        ;CX
        SUB DI,2
        MOV AX,[BP-8]
        MOV WORD PTR ES:[DI],AX        ;DX
        SUB DI,2
        MOV AX,[BP-10]
        MOV WORD PTR ES:[DI],AX        ;SI
        SUB DI,2
        MOV AX,[BP-12]
        MOV WORD PTR ES:[DI],AX        ;DI
        SUB DI,2
        MOV AX,[BP-14]
        MOV WORD PTR ES:[DI],AX        ;DS
        SUB DI,2
        MOV AX,[BP-16]
        MOV WORD PTR ES:[DI],AX        ;ES
        PUSHF
        SUB DI,2
        POP ES:[DI]                    ;F



        MOV DS,T_SEG
        MOV SI,T_OFF            ; DS:SI - TASK

        MOV [SI+S_SP],DI
        MOV [SI+S_SS],ES

        POP ES
        POP DS
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX

        POP BP
        RETF 16
ACTIVATE ENDP

BOLV:
        PUSH DS
        MOV AX,_DATA
        MOV DS,AX
        MOV SI,[ACTIVE_TASK_L]
        MOV DS,[ACTIVE_TASK_H]
        MOV WORD PTR [SI+S_QDONE],-1
        POP DS
        CALL STOP
        JMP BOLV

WAKE    PROC FAR PASCAL
        ARG T_OFF:WORD , T_SEG:WORD
        PUSH BP
        MOV BP,SP
        PUSH ES
        PUSH SI
        MOV ES,T_SEG
        MOV SI,T_OFF
        MOV WORD PTR ES:[SI+S_QACTIVE],-1
        POP SI
        POP ES
        POP BP
        RETF 2
WAKE    ENDP



PUBLIC STOP
PUBLIC PAUSE
PUBLIC BUILD
PUBLIC RUIN
PUBLIC ACTIVATE
PUBLIC WAKE
PUBLIC ACTIVE_TASK



        END