* *  * * * * * * * * * * * * * * * * * * * * * *  ПЕРЕHОС СТРОКИ
*            PROCEDURE  PERENOS                *  ПО ПРОБЕЛУ,
* *  * * * * * * * * * * * * * * * * * * * * * *  ПО ОДHОМУ ИЛИ ПО ДВУМ
*
* ┌────────────────────┬────────────────────┬──────────────┬─────────┐
* │       R_POLE       │       R_POLE       │    R_POLE1   │ R_POLE2 │
* ├────────────────────┼────────────────────┼──────────────┼─────────┤
* │ Маша играла кашей ═┼═> Маша играла кашей│  Маша играла │  кашей  │
* │ R_LEN=───────┘     │    (не изменяется) │(нужной длины)│(остаток)│
* └────────────────────┴────────────────────┴──────────────┴─────────┘
* R_POLE разбивается на два поля R_POLE1 и R_POLE2 по границе R_LEN.
* R_POLE1 - строка длины не более R_LEN символов,
* R_POLE2 - остаток.
* ВСЕ ТРИ ПЕРЕМЕННЫЕ ДОЛЖНЫ БЫТЬ ФИЗИЧЕСКИ РАЗНЫЕ.
* R_T - .T. - перенос по пробелу
*       .F. - обязательный перенос по двум пробелам

PARAMETER R_POLE, R_LEN, R_T, R_POLE1, R_POLE2
R_PROBEL=" "
R_STR=TRIM(R_POLE)
R_POLE1=R_STR
R_POLE2=R_PROBEL
R_N=AT(R_PROBEL,R_STR)
R_LONG=LEN(R_STR)
IF R_LONG <= R_LEN
   RELEASE ALL
   RETURN
ENDIF
IF R_N > R_LEN .OR. R_N = 0
   R_POLE1=SUBSTR(R_STR,1,R_LEN)
   R_POLE2=LTRIM(SUBSTR(R_STR,R_LEN+1))
   RELEASE ALL
   RETURN
ENDIF
IF .NOT. R_T && ПОПЫТКА ПЕРЕНЕСТИ ПО ДВУМ ПРОБЕЛАМ:
  R_STR1=LTRIM(R_STR)
  R_DEL=R_LONG-LEN(R_STR1)
  R_N=AT('  ',R_STR1)
  R_N1=R_N+R_DEL
  IF R_N > 0 .AND. R_N1 <= R_LEN+1
     R_POLE1=SUBSTR(R_STR,1,R_N1-1)
     R_POLE2=LTRIM(SUBSTR(R_STR,R_N1))
       RELEASE ALL
       RETURN
  ENDIF
ENDIF
R_IND=R_LEN+1
DO WHILE SUBSTR(R_STR,R_IND,1) # R_PROBEL
                      R_IND=R_IND-1
ENDDO
R_POLE1=TRIM(SUBSTR(R_STR,1,R_IND))
R_POLE2=SUBSTR(R_STR,R_IND+1)
RELEASE ALL
RETURN
