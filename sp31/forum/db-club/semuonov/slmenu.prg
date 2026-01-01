* program 'SLMENU'
 PARAMETERS FNAME, VID
 FLUSH
 SET STATUS OFF
 SET SCOREBOARD OFF
 CALL CURS_OFF
 SET COLOR TO GR+/B,N/BG
 CLEAR
 PRIVATE N_MAIN, MIN_REC, MAX_REC, STREL
 SET COLOR TO N/N 
 @  1, 19  TO  6, 63    CLEAR
 SET COLOR TO W+/G+
 @  0, 17,5,60 box '         '
 @  1, 35  SAY "Контpоль"
 @  2, 29  SAY "за выполнением плана"
 @  3, 31  SAY "пpоектных pабот."
 @  4, 21  SAY "Для УКС облисполкома  г. Симфеpополя."
 @  0, 17  TO  5, 60  

 SET COLOR TO N/G
 USE &FNAME
 GOTO 1
 DO WHILE N=0
            @ L,K SAY TXT
                        SKIP +1
                               ENDDO
 GOTO 1
 N_MAIN = 1
* ***************************** INICIALISATION OF LOOP
 DO WHILE .T.
   GOTO N_MAIN
   MIN_REC = Y
   MAX_REC = X
   GOTO MIN_REC
   RL=L-1
   RK=K-2
   GOTO MAX_REC
   RL1=L+1
   RK1=K+LEN(TXT)+1
   @ RL,RK TO RL1,RK1 DOUBLE
   SET COLOR TO GR+/B,N/BG
   GOTO MIN_REC
   DO WHILE N = N_MAIN
      @ L,K SAY TXT
      SKIP +1
   ENDDO
  @ RL,RK TO RL1,RK1 DOUBLE
   SET COLOR TO R/W
   GOTO MIN_REC
* ************************* INVERSION OF FIRST LINE SUBMENU N 1
   @ L,K SAY TXT
   STREL=0
   DO WHILE STREL <> 19 .AND. STREL <> 4
      SET COLOR TO N/N
      STREL = INKEY(0)
      CALL CURS_TON
      SET COLOR TO GR+/B,N/BG
      IF STREL = 24 .OR. STREL = 5
         @ L,K SAY TXT
                       ENDIF
      DO CASE
         CASE STREL = 24
              IF RECNO() <> MAX_REC
              SKIP +1
              ELSE
              GOTO MIN_REC
              ENDIF
          CASE STREL = 5
              IF RECNO() <> MIN_REC
              SKIP -1
              ELSE
              GOTO MAX_REC
              ENDIF
          CASE STREL = 13
               VID = TXT
               USE
               CALL CURS_ON
               RETURN
       ENDCASE
       if strel = 5 .or. strel = 24
       SET COLOR TO R/W
       @ L,K SAY TXT
       SET COLOR TO GR+/B,N/BG
       endif
   ENDDO
   GOTO MIN_REC
   @ (L-1),(K-2) CLEAR
   DO CASE
      CASE STREL = 4
           N_MAIN = N_MAIN + 1
           GOTO N_MAIN
           IF N <> 0
            N_MAIN = 1
           ENDIF
      CASE STREL = 19
           N_MAIN = N_MAIN - 1
           IF   N_MAIN = 0
                GOTO 1
                DO WHILE N = 0
                   SKIP +1
                ENDDO
                N_MAIN = RECNO() - 1
           ENDIF
    ENDCASE
 ENDDO
 RETURN
