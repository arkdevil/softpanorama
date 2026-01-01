$NOPAGING MACROFILE NOSYMBOLS

	ASEG

	ORG	0	;	начало работы
	EI
	HLT		;	ждем прерываний
	JMP	0
	ORG	8	;	здесь вектор прерываний
	JMP	BEGIN

	CSEG
BEGIN:
	IN	0	;	освещенность снаружи дома
	ORA	A
	JZ	CHAIN	;	темно: работаем
	EI
	RET		;	светло: возвращаемся вхолостую
CHAIN:
	IRP	P,<1,2,3,4> ;	4 комнаты - повторяем 4 раза
	LOCAL	M1,M2,MR
	LDA	COUNT&P	;;	счетчик тиков для этой комнаты
	ORA	A
	JNZ	M1	;;	время еще не пришло
	LDA	STATE&P	;;	новое состояние света в комнате
	OUT	P	;;	включить/выключить
	CMA
	STA	STATE&P	;;	следующее состояние обратно текущему
	LDA	RND	;;	случайное число
	MVI	C,4+p
MR:	ADD	A
	ADD	C
	RAL
	JPO	$+4
	INR	A
	DCR	C
	JNZ	MR
	STA	RND	;;	новое случайное число
	STA	COUNT&P	;;	новое состояние счетчика тиков комнаты
	JMP	M2
M1:	DCR	A	;;	убавляем счетчик тиков комнаты
	STA	COUNT&P	;;	сохраняем его
M2:
	ENDM
	EI
	RET		;	возвращаемся на ожидание следующего прерывания

	DSEG
RND:	DS	1	;	случайное число
	IRP	P,<1,2,3,4>
COUNT&P: DS	1	;;	счетчики тиков комнат
STATE&P: DB	0	;;	состояния света в комнатах
	ENDM
	END	0
