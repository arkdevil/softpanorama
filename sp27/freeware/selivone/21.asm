TITLE     pro
.RADIX 2
DEEP            EQU     0d0h    ;0e0h 0f0h no 0cah yes  0aah 7aH
OLD_INT         EQU     5h	;21H
OLD_ADDR        EQU     OLD_INT*4H	;1c0a
SKIFF   EQU     32D
CODE            SEGMENT PARA
        ASSUME CS:CODE,DS:CODE,SS:CODE,ES:CODE
        ORG 100H
START:  JMP RESIDENT
FINITA:         PUSHF
                DB      10011010        ;db  11101010B
WHERE           DW 1460H
SEG_WHERE       DW 0252H
				PUSHF
				PUSH CX
				PUSH DX
				PUSH AX
				PUSH BX
				PUSH SI
				PUSH DI
				PUSH DS
		                PUSH ES
				MOV CS:[POST_AX - DEEP],AX
				MOV CS:[DX_ - DEEP],DX
				MOV CS:[BX_ - DEEP],BX
				MOV BX,320D
				MOV DX,'AX'
				CALL REG_NAME
				CALL OUTPUT
				MOV AX,CS:[BX_ - DEEP]
				MOV BX,336D
				MOV DX,'BX'
		                CALL REG_NAME
				CALL OUTPUT
				MOV AX,CX
				MOV DX,'CX'
				CALL REG_NAME
				CALL OUTPUT
				MOV AX,CS:[DX_ - DEEP]
				MOV DX,'DX'
				CALL REG_NAME
				CALL OUTPUT
NUM_check:   XOR AX,AX
                MOV DS,AX
                MOV AL,DS:[417H]
				TEST AL,00100000B
				JZ      NO_CHECK
				MOV AX,CS:[BEFORE_AX - DEEP]
				MOV AL,AH
				CMP AH,63H	;HERE MAX AH NUMBER !!!!!!!!!
				JA NO_CHECK
				MOV AH,00h
				MOV BX,OFFSET NUM_LOCK - DEEP
				ADD BX,AX
				MOV AH,CS:[BX]
				CMP AH,00H
				JZ NO_CHECK
                MOV AH,0
				INT 16H
				CMP AL,'~'
				JNE NO_CHECK
				CALL VISI_FUN
NO_CHECK:       MOV SI,0B800H
				PUSH SI
				PUSH SI
				POP DS
				POP ES
				MOV DI, 00H
				MOV SI, 6000D
				MOV CX,240D
                CLD
REP             MOVSW
				POP ES
				POP DS
				POP DI
				POP SI
				POP BX
				POP AX
				POP DX
				POP CX
                POPF
				RETF 02H
VISI_FUN:		MOV SI,01H
VISU:			PUSH CS
                POP ES
                MOV BX,0B800H
				MOV DS,BX
				MOV AX,00H
				MOV CX,0D	;20D      3800D
BEGIN_DIS:			PUSH AX
				MOV DX,00H
				ADD AX,AX
                MOV BX,OFFSET NAMING_ADDR - DEEP
                ADD BX,AX
                MOV DI,CS:[BX]
				MOV BX,CX
				POP AX
				PUSH AX
				CMP AX,SI
				JNZ	NOT_SI
				MOV AH,01110000B
				JMP BEGIN_N
NOT_SI:			MOV AH,01111B
BEGIN_N:		MOV AL,ES:[DI]
                MOV [BX],AX
				ADD BX,2H
				INC DX
                INC DI
				CMP DX,19D
				JB BEGIN_N
				MOV AL,20H
				MOV [BX],AX
				ADD BX,2H
				MOV CX,BX
					POP AX
				INC AX
				CMP AX,62H	;	TOP HERE !!!!!!!!!!
				JB BEGIN_DIS
				MOV AX,00H
				INT 16H
				CMP AL,'Q'
				JZ END_CHECK
				CMP AL,'q'
				JZ END_CHECK
				CMP AL,'+'
				JZ ADD_SI
				CMP AL,'-'
				JZ SUB_SI
				JMP VISU
ADD_SI:         CMP SI,62H	;	TOP HERE !!!!!!!!!!
				JA ZERO_SI
				INC SI
				JMP VISU
ZERO_SI:		XOR SI,SI
				JMP VISU
SUB_SI:         CMP SI,00H	;	TOP HERE !!!!!!!!!!
				JZ MAX_SI
				DEC SI
				JMP VISU
MAX_SI:			MOV SI,62H	;	TOP HERE !!!!!!!
				JMP VISU
END_CHECK:		RET

REG_NAME:			PUSH AX
				PUSH	CX
				MOV CX,0B800H
				MOV DS,CX
				MOV AL,DH
				MOV AH,07H
				MOV [BX],AX
				ADD BX,2H
				MOV AL,DL
				MOV [BX],AX
				ADD BX,2H
				MOV AL,20H
				MOV [BX],AX
				ADD BX,2H
				POP CX
				POP AX
				RET
NAMING_ADDR     DW      66H     DUP(0000H)
SCROLL_LOCK		DB		66H	DUP(01H)
NUM_LOCK		DB		66H	DUP(01H)
DX_ DW 00H
BX_ DW 00H
CX_ DW 00H
DI_ DW 00H
DS_ DW 00H
SI_ DW 00H
NAMING: DB      'завершить программу',00h       ;0
DB      'ввод с клавиатуры знака с эхом проверка на Break#AL',00h;1
DB      'DL вывод на ст.вывод',00h;2
DB      'вспомогательный ввод(асинхронный адаптер связи)#AL',00h;3
DB      'DL вспомогательный вывод(асинхронный адаптер связи)',00h;4
DB      'DL вывод на печать',00h;5
DB      'DL прямой ввод-вывод#AL',00h;6
DB      'прямой ввод с кл.без эха и проверки на Break#AL',00h;7
DB      'прямой ввод с кл.без эха,но с проверкой на Break#AL',00h;8
DB      'вывод строки',00h;9
DB      'ввод с клавиатуры через буфер',00h;0ah
DB      'проверка стандартного уст-ва ввода и на Break#AL',00h; 0bh
DB      'AL очистка буфера стандартного уст-ва ввода и вызов функции ввода-1,6,7,8',00h;        0ch
DB      'сброс диска',00h;      0dh
DB      'DL выбор диска, возвращает число дисков в системе#AL',00h      ;0eh
DB      'открыть файл#AL',00h   ;0fh
DB      'закрыть файл#AL',00h   ;10h
DB      'поиск первого элемента#AL',00h ;11h
DB      'поиск следующего элемента#AL',00h      ;12h
DB      'удалить файл#AL',00h   ;13h
DB      'последовательное чтение#AL',00h        ;14h
DB      'последовательная запись#AL',00h        ;15h
DB      'создать файл#AL',00h   ;16h
DB      'переименовать файл#AL',00h     ;17h
DB      'используется внутри DOS',00h   ;18h
DB      'текущий диск#AL',00h   ;19h
DB      'установить область обмена с диском DTA',00h    ;1аh
DB      'информация FAT для активного диска#AL кол-во секторов в кластере CX длина сектора в байтах DX общее число кластеров на диске, разрушает DS!',00h       ;1bh
DB      'DL информация FAT для диска,указанного в DL#AL кол-во секторов в кластере CX длина сектора в байтах DX общее число кластеров на диске, разрушает DS!',00h      ;1ch
DB      'используется внутри DOS',00h   ;1dh
DB      'используется внутри DOS',00h   ;1eh
DB      'используется внутри DOS',00h   ;1fh
DB      'используется внутри DOS',00h   ;20h
DB      'произвольное чтение#AL',00h    ;21h
DB      'произвольная запись#AL',00h    ;22h
DB      'размер файла#AL',00h   ;23h
DB      'установить номер записи для произвольного доступа#AL?',00h     ;24h
DB      'AL номер DS:DX адрес - установить вектор прерывания',00h       ;25h
DB      'DX длина в сегм.формате - создать новый программный сегмент',00h       ;26h
DB      'CX число блоков - произвольное чтение блоков#AL',00h   ;27h
DB      'CX число блоков - произвольнaя запись блоков#AL',00h   ;28h
DB      'DS:SI строка для анализа,ES:DI буфер для FCB -анализ имени файла#AL',00h       ;29h
DB      'получить дату#CX-год DH-месяц DL-день',00h     ;2аh
DB      'CX-год DH-месяц DL-день --- установить дату#AL',00h    ;2bh
DB      'получить время#CH-часы CL-мин DH-секунды DL-сотые доли сек',00h        ;2ch
DB      'CH-часы CL-мин DH-секунды DL-сотые доли сек---установить время#AL',00h ;2dh
DB      'Установить/сбросить переключатель верификации',00h;          2eH
DB      'Дать текущий DTA',00h;                                       2fH
DB      'Дать номер версии DOS',00h;                                  30H
DB      'Завершиться и остаться резидентным -- KEEP',00h;             31H
DB      'Дать дисковую информацию DOS (недокументировано)',00h;       32H
DB      'Установить/опросить уровень контроля прерывания DOS',00h;    33H
DB      'Адрес статуса реентерабельности DOS',00h;                    34H
DB      'Дать вектор прерывания',00h;                                 35H
DB      'Дать свободную память диска',00h;                            36H
DB      'Установить/опросить символ-переключатель (недокументировано)',00h; 37H
DB      'Дать/Установить информацию страны',00h;                      38H
DB      'Создать новое оглавление -- MKDIR',00h;                      39H
DB      'Удалить оглавление -- RMDIR',00h;                            3aH
DB      'Установить умалчиваемое оглавление DOS -- CHDIR',00h;        3bH
DB      'Создать описатель файла',00h;                                3cH
DB      'Открыть описатель файла',00h;                                3dH
DB      'Закрыть описатель файла',00h;                                3eH
DB      'Читать файл через описатель',00h;				3fH
DB      'Писать в файл через описатель',00h;			40H
DB      'Удалить файл',00h;								41H
DB      'Установить указатель файла -- LSEEK',00h;		42H
DB      'Установить/опросить атрибут файла -- CHMOD',00h;	43H
DB      'Управление вводом-выводом устройства -- IOCTL',00h;44H
DB      'Дублировать описатель файла -- DUP',00h;		45H
DB      'Переназначить описатель -- FORCDUP',00h;		46H
DB      'Дать умалчиваемое оглавление DOS',00h;			47H
DB      'Распределить память (дать размер памяти)',00h;	48H
DB      'Освободить блок распределенной памяти',00h;	49H
DB      'Сжать или расширить блок памяти',00h;			4aH
DB      'Выполнить или загрузить программу -- EXEC',00h;4bH
DB      'Завершить программу -- EXIT',00h;				4cH
DB      'Дать код выхода программы -- WAIT',00h;		4dH
DB      'Найти 1-й совпадающий файл',00h;				4eH
DB      'Найти следующий совпадающий файл',00h;			4fH
DB      'используется внутри DOS',00h;					50h
DB      'используется внутри DOS',00h;					51h
DB      'используется внутри DOS',00h;					52h
DB      'используется внутри DOS',00h;					53h
DB      'Дать переключатель верификации DOS',00h;		54H
DB      'используется внутри DOS',00h;					55h
DB      'Переименовать/переместить файл',00h;			56H
DB      'Установить/опросить время/дату файла',00h;		57H
DB      'используется внутри DOS',00h;					58h
DB      'Дать расширенную информацию об ошибке',00h;	59H
DB      'Создать уникальный временный файл',00h;		5aH
DB      'Создать новый файл',00h;						5bH
DB      'Блокировать/разблокировать доступ к файлу',00h;5cH
DB      'используется внутри DOS',00h;					5dh
DB      'Различные сетевые функции',00h;				5eH
DB      'Переназначение устройств в сети',00h;			5fH
DB      'используется внутри DOS',00h;					60h
DB      'используется внутри DOS',00h;					61h
DB      'Дать адрес префикса программного сегмента',00h;62H
DB      'используется внутри DOS',00h;					63h
DB      'используется внутри DOS',00h;					64h
BEFORE_AX	DW 00H
POST_AX		DW 00H

DRIVER:         PUSHF
		PUSH CX
				PUSH ES
				PUSH DS
				PUSH SI
				PUSH DI
				PUSH DX
                		PUSH AX
				PUSH BX
				MOV	CS:[BEFORE_AX - DEEP],AX
				MOV CS:[DX_ - DEEP],DX
				MOV CS:[CX_ - DEEP],CX
				MOV CS:[SI_ - DEEP],SI
				MOV CS:[DI_ - DEEP],DI
				MOV SI,0B800H
				PUSH SI
				PUSH SI
				POP DS
				POP ES
				MOV SI, 00H
				MOV DI, 6000D
				MOV CX,240D
                CLD
REP             MOVSW

				MOV BX,160D
				MOV DX,'AX'
				CALL REG_NAME
                CALL OUTPUT
				POP BX
				PUSH BX
				MOV AX,BX
				MOV BX,176D
				MOV DX,'BX'
                CALL REG_NAME
				CALL OUTPUT
				MOV AX,CS:[CX_ - DEEP]
				MOV DX,'CX'
				CALL REG_NAME
				CALL OUTPUT
				MOV AX,CS:[DX_ - DEEP]
				MOV DX,'DX'
				CALL REG_NAME
				CALL OUTPUT

                POP BX
				POP AX
				POP DX
				POP DI
				POP SI
				POP DS
				POP ES
				POP CX
				CMP AH,62H      ;        chaNGE HERE !!!!!!!!
                Ja      NO_NAMING
        PUSH AX
        PUSH BX
        PUSH DS
        PUSH ES
        PUSH DI
                PUSH CS
                POP ES
                MOV BX,0B800H
                MOV DS,BX
                MOV AL,AH
                MOV AH,00
                ADD AX,AX
                MOV BX,OFFSET NAMING_ADDR - DEEP
                ADD BX,AX
                MOV DI,CS:[BX]
				MOV BX,0D	;20D      3800D
                MOV AH,01111B
BEGIN_NAME:     MOV AL,ES:[DI]
                MOV [BX],AX
                ADD BX,2H
                INC DI
                CMP AL,00H
				JNZ BEGIN_NAME
				MOV AX,0720H
CLEAN:			ADD BX,2H
				MOV [BX],AX
				CMP BX,156d
				JB CLEAN
        POP DI
        POP ES
        POP DS
        POP BX
		POP AX
		JMP NO_NAMING
WELL4b: JMP INT_4B
NO_NAMING:      CMP     AH,4BH
                JZ      WELL4b
                CMP             AH,0FH
                JZ WELL0F
                CMP             AH,10H
                JZ WELL0F
                CMP             AH,11H
                JZ WELL0F
                CMP             AH,12H
                JZ WELL0F
                CMP             AH,13H
                JZ WELL0F
                CMP             AH,14H
                JZ WELL0F
                CMP             AH,15H
                JZ WELL0F
                CMP             AH,16H
                JZ WELL0F
                CMP             AH,17H
                JZ  REN
                CMP             AH,21H
                JZ WELL0F
                CMP             AH,22H
                JZ WELL0F
                CMP             AH,23H
                JZ WELL0F
                CMP             AH,24H
                JZ WELL0F
                CMP             AH,27H
                JZ WELL0F
                CMP             AH,28H
                JZ WELL0F
                CMP             AH,39H
                JZ      DIRECT_NAME
                CMP             AH,3AH
                JZ      DIRECT_NAME
                CMP             AH,3BH
                JZ      DIRECT_NAME
                CMP             AH,3CH
                JZ      DIRECT_NAME
                CMP             AH,3DH
                JZ      DIRECT_NAME
                CMP             AH,41H
                JZ      DIRECT_NAME
                CMP             AH,4EH
                JZ      DIRECT_NAME
                CMP             AH,4FH
                JZ      DIRECT_NAME
                CMP             AH,56H
				JZ      DS_DX_ES_DI

				PUSH AX	;	HERE SCROLL !!!!!!!
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI
                PUSH ES
                PUSH DS
				JMP 	SCROLL_CHECK
WELL0F: JMP W0F
REN:    JMP RENAME
DIRECT_NAME:    JMP DIRECT_NAME_F
DS_DX_ES_DI:    JMP     DS_DX_ES_DI_F
INT_4B: PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI
                PUSH ES
                PUSH DS
                MOV AX,DS
                MOV ES,AX
                MOV DI,DX
                MOV DX,0B800H
                MOV DS,DX
                MOV BX,3960D
BEG:            MOV AH,1111B
                MOV AL,ES:[DI]
                CMP AL,00H
                JZ ZERO
                MOV [BX],AX
                INC BX
                INC BX
                INC DI
                JMP BEG
ZERO:           jmp scroll_check
DIRECT_NAME_F:  PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI
                PUSH ES
                PUSH DS
                DEC DX
                MOV BX,3960D
                CALL BUF_VISU
                jmp     scroll_check
DS_DX_ES_DI_F:  PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI
                PUSH ES
                PUSH DS
                MOV BX,3938D
                CALL ES_DI
                MOV BX,3968D
                DEC DX
                                POP DS
                                PUSH DS
                CALL BUF_VISU
                jmp     scroll_check
RENAME: PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI
                PUSH ES
                PUSH DS
                                PUSH DX
                MOV BX,3938D
                CALL BUF_VISU
                                POP DX
                                POP DS
                                PUSH DS
                ADD DX,10H
                MOV BX,3968D
                CALL BUF_VISU
                JMP SCROLL_CHECK
W0F:    PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                PUSH DI
                PUSH ES
                PUSH DS
                MOV BX,3960D
                CALL BUF_VISU
scroll_check:   XOR AX,AX
                MOV DS,AX
                MOV AL,DS:[417H]
                TEST AL,00010000B
				JZ      NO_SCROLL
				MOV AX,CS:[BEFORE_AX - DEEP]
				MOV AL,AH
				MOV AH,00
				CMP AH,63H	;HERE MAX AH NUMBER !!!!!!!!!
				JA NO_SCROLL
				MOV BX,OFFSET SCROLL_LOCK - DEEP
				ADD BX,AX
				MOV AH,CS:[BX]
				CMP AH,00H
				JZ NO_SCROLL
                MOV AH,0
                INT 16H
NO_SCROLL:      POP DS
                POP ES
                POP DI
                POP DX
                POP CX
                POP BX
                POP AX
                POPF
                JMP FINITA
BUF_VISU:       MOV AX,DS
                MOV ES,AX
                MOV DI,DX
                INC DI
ES_DI:  MOV DX,0B800H
                MOV DS,DX
                MOV CX,18d
BEG_BUF:                MOV AH,1111B
                MOV AL,ES:[DI]
                MOV [BX],AX
                INC BX
                INC BX
                INC DI
                LOOP BEG_BUF
                RET


OUTPUT: PUSH DS
        PUSH CX
                PUSH AX
                        MOV AX,0B800H
                        MOV DS,AX
                        POP AX
                PUSH AX
                        MOV CL,04H
                        SHR AH,CL
                        MOV AL,AH
                        CALL HEX
                        POP AX
                PUSH AX
                        AND AH,00001111B
                        MOV AL,AH
                        CALL HEX
                        POP AX
                PUSH AX
                        MOV CL,04H
                        SHR AL,CL
                        CALL HEX
                        POP AX
                AND AL,00001111B
				CALL HEX
				MOV AL,20H
				MOV [BX],AL
				ADD BX,02H
				MOV [BX],AL
				ADD BX,02H
                POP CX
                POP DS
                RET
HEX:    ADD AL,30H
                CMP AL,3AH
                JB SIMPLE
                ADD AL,07H
SIMPLE: MOV [BX],AL
                INC BX
                MOV AL,1111B
                MOV [BX],AL
                INC BX
                RET
GREETING     DB ' How do you do ! Interruption 21h',39D,'s (DOS) functions tracer works',0dh,0ah
        DB      '      Achtung!',0DH,0AH
        DB      ' While Scroll locked - function executing freezed,until you unfreeze it by any',0dh,0ah
        DB      ' literal key or space bar.If you don',39D,'t need for it, drive for Scroll - unlock !',0dh,0ah,0dh,0ah
        DB      ' This is  smart drivers  ultra-compact  drivers generation , which reside near',0dh,0ah
        DB      ' 300 bytes system memory only  and may be pushed into the same place any times',0dh,0ah
        DB      ' Copyright  (C)  Intelligence Poltava Microsoft Corporation (IPM), V 1.0, 1990',0DH,0AH
        DB      ' Main office - 314028, Poltava-city , Fourth  Clinic  Researching Laboratories',0DH,0AH,0DH,0AH
        DB      ' Unauthorized copying  prohibited and punished severely by martial law forever',0DH,0AH
        DB      ' Flabbergast , while copyright voilations ,  despite the whole flamboyant tune',0Dh,0AH,24H
RESIDENT:       MOV DX,OFFSET GREETING
                MOV AH,09H
                INT 21H
                MOV     BX,0H
                MOV     DS,BX
                MOV     AX,DS:[OLD_ADDR]
                MOV     DX,DS:[OLD_ADDR+2H]
                MOV     CS:WHERE,AX
                MOV     CS:SEG_WHERE,DX
                MOV     SI,OLD_ADDR
                MOV     WORD PTR DS:[SI],OFFSET DRIVER - DEEP
                INC     SI
                INC SI
                MOV WORD PTR DS:[SI],CS
                PUSH CS
                POP DS
                MOV BX,OFFSET NAMING_ADDR
                PUSH DS
                POP ES
                MOV DI,OFFSET NAMING
                MOV WORD PTR [BX],OFFSET NAMING - DEEP
                XOR DX,DX
INSTALL:        ADD BX,02H
FIND_ZERO:      MOV AL,ES:[DI]
                CMP AL,00
                JZ DO_INSTALL
                INC DI
                JMP FIND_ZERO
DO_INSTALL:     INC DI
                MOV AX,DI
                SUB AX,DEEP
                MOV WORD PTR [BX],AX
                INC DX
				CMP DX,64H      ;HERE MUST BE 55H OR SOMETHING !!!!!!!!!
                JB INSTALL

                MOV CX,OFFSET EXIT_                     ;       BUG HERE
                MOV BX,CX
                SUB     CX,110H
                XOR DX,DX
                XOR AX,AX
COPY:   MOV AL,[BX]
                ADD     DX,AX
                ROL DX,1
                DEC BX
                LOOP COPY
                MOV AX,CHECK
                CMP DX,AX
                JNZ ALAS
        MOV     DX,OFFSET GREETING  - DEEP
                MOV CL,04H
                SHR     DX,CL
                INC DX
                PUSH DX
DOING:  PUSH DS
                POP ES
                MOV SI, 100H
                MOV DI, 100H    -       DEEP
                MOV CX,OFFSET GREETING + 10H - 100H
                CLD
REP             MOVSB
                MOV     AH,31H
                POP DX
EXIT_:          INT     21H
ALAS:   PUSH DS
        mov AX,9000h
        MOV DS,AX
        MOV DS:[84H],DX
        POP DS
		MOV DX,0200H    ; here must bee 0r 0 or 60000
                PUSH DX
                JMP DOING
check dw 05765h
CODE    ENDS
                END       START
