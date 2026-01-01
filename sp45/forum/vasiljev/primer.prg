// Демо-пример многостраничного редактирования
// с применением модернизированной GET системы
//
// Васильев Игорь Викторович МП "КАСТ"
//
#include "My_get.ch"
#include "Inkey.ch"
PROC Potreb
LOCAL scr1,scr2
SET COLOR TO "W/B,N/BG,,,N/G"
CLEAR SCREEN
USE POTREB
@  2, 0 SAY "Kod_potr▒▒"
@  3, 0 SAY "Respublika"
@  4, 0 SAY "Oblast▒▒▒▒"
@  5, 0 SAY "Raion▒▒▒▒▒"
@  2,34 SAY "Gorod▒▒▒▒▒"
@  3,34 SAY "Ylisa▒▒▒▒▒"
@  4,34 SAY "Dom▒▒▒▒▒▒▒"
@  5,34 SAY "Post_index"
@  6,34 SAY "Tel_m_kod▒"
@  7,34 SAY "Telegraf▒▒"
@  8, 9 SAY "Name_potr▒"
@  9, 9 SAY "Bank▒▒▒▒▒▒"
@ 10, 9 SAY "R_schet▒▒▒"
@ 11, 9 SAY "Mfo▒▒▒▒▒▒▒"
@ 12, 9 SAY "Telefon1▒▒"
@  7,60 SAY "Telefon2▒▒"
@  8,60 SAY "Telefon3▒▒"
@  9,60 SAY "Telefon4▒▒"

@ 24 , 1 SAY "PgUP,PgDn - следующая страница "

@  2,10 GET Kod_potr
@  3,10 GET Respublika
@  4,10 GET_SHOW Oblast      GET_PROC R_choice()
@  5,10 GET Raion
@  2,44 GET Gorod
@  3,44 GET Ylisa
@  4,44 GET Dom
@  5,44 GET Post_index
@  6,44 GET Tel_m_kod
@  7,44 GET Telegraf
@  8,19 GET Name_potr
@  9,19 GET Bank
@ 10,19 GET R_schet
@ 11,19 GET Mfo         WHEN .F.
@ 12,19 GET Telefon1
@  7,70 GET Telefon2
@  8,70 GET Telefon3
@  9,70 GET Telefon4
PUT GETS TO fst_get_arr
READ FROM fst_get_arr
IF Lastkey() <> K_ESC
        SAVE SCREEN TO scr1
        CLEAR SCREEN

        @  2, 3 SAY "Famili1▒▒▒"
        @  3, 3 SAY "Famili2▒▒▒"
        @  4, 3 SAY "Famili3▒▒▒"
        @  5, 3 SAY "Famili4▒▒▒"
        @  6, 3 SAY "Doljn1▒▒▒▒"
        @  2,42 SAY "Doljn2▒▒▒▒"
        @  3,42 SAY "Doljn3▒▒▒▒"
        @  4,42 SAY "Doljn4▒▒▒▒"
        @  5,42 SAY "Teleks▒▒▒▒"
        @  6,42 SAY "Faks▒▒▒▒▒▒"
        @  8,25 SAY "Jeldor_st▒"
        @  9,25 SAY "Kod_st▒▒▒▒"

	@ 24 , 1 SAY "PgUP,PgDn - следующая страница "

        @  2,13 GET Famili1
        @  3,13 GET Famili2
        @  4,13 GET Famili3
        @  5,13 GET Famili4
        @  6,13 GET Doljn1
        @  2,52 GET Doljn2
        @  3,52 GET Doljn3
        @  4,52 GET Doljn4
        @  5,52 GET Teleks
        @  6,52 GET Faks
        @  8,35 GET Jeldor_st
        @  9,35 GET Kod_st
        PUT GETS TO sec_get_arr
        READ FROM sec_get_arr
ELSE
        RETURN
ENDIF
// Организуем многостраничное редактирование

SAVE SCRE TO scr2
order := 2

WHILE .T.
        lst_k := Lastkey()
        DO CASE
                CASE lst_k = K_PGDN
                        If( order < 2 , order++, NIL )
                CASE lst_k = K_ENTER
                        If( order < 2 , order++, NIL )
                CASE lst_k = K_PGUP
                        If( order > 1 , order--, NIL )
                OTHERWISE
                        EXIT
        ENDCASE
        IF order = 1
                REST SCREE FROM scr1
                READ FROM  fst_get_arr
                SAVE SCREE TO scr1
        ELSE
                REST SCREE FROM scr2
                READ FROM  sec_get_arr
                SAVE SCREE TO scr2
        ENDIF
ENDDO

PROC R_choice
LOCAL array := {"Самарская   ","Саратовская ","Позвоночника"}
LOCAL tmpscr,ret,l_key
   l_key := Inkey(0)
   IF !Is_exit_key(l_key)

      tmpscr := Savescreen(0,0,24,79)
      @ 3,10 TO 7,23 DOUBLE COLOR "B+/B"
      @ 4 ,11 PROMPT array[1]
      @ 5 ,11 PROMPT array[2]
      @ 6 ,11 PROMPT array[3]
      MENU TO ret

      Restscreen(0,0,24,79,tmpscr)
      IF ret<>0
         REPLACE OBLAST WITH array[ret]
      ENDIF
      KEYBOARD Chr(K_DOWN)
      Inkey()
   ENDIF
RETURN