; ПЕРЕКОДИРОВКА СТРОКИ ЧЕРЕЗ ТАБЛИЦУ, КОТОРАЯ НАЧИНАЕТСЯ С КОДА 00
; (КОТОРЫЙ НЕ УЧАСТВУЕТ В ПЕРЕКОДИРОВКЕ) ДО БАЙТА 00.
;
; ОБРАЩЕНИЕ: PEREKOD ( СТРОКА_ИСХ, ТАБЛИЦА ) ИЛИ
;     OTVETS=PEREKOD ( СТРОКА_ИСХ, ТАБЛИЦА ), ГДЕ OTVETS==СТРОКА_ИСХ
;                                  ПОСЛЕ ВЫЗОВА ФУНКЦИИ.
; НЕ ЗАБУДЬТЕ - ВСЕГДА ДВА ПАРАМЕТРА ! Таблицы SYSB,SYSM смотри в RUNINGER.PRG
          INCLUDE   EXTENDA.INC
          CODESEG
          DATASEG
          CLpublic  <PEREKOD>
          CLfunc CHAR PEREKOD <char stroka, char tabl>
          CLcode
          PUSH BX
          PUSH SI
          PUSH DS
          PUSH ES
;O:        JMP O           ; ПРЕКРАСНО СРАБАТЫВАЕТ AFD ПО Ctrl+Esc
          LDS BX,TABL      ; ТАБЛИЦА - DS:BX
          LES SI,STROKA
; ПЕРЕКОДИРУЕМ, ПОКА НЕ 00
CYCL:      MOV AL,BYTE PTR ES:[SI]
           CMP AL,0
           JZ  KONEC
           XLAT
           MOV BYTE PTR ES:[SI],AL
           INC SI
           JMP CYCL
KONEC:     POP ES
           POP DS
           POP SI
           POP BX
           CLret STROKA
           END