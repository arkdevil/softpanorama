
FUNCTION UPRUS
PARAMETERS ST
STT=''
N=LEN(ST)
IF N>0
   I=1
   DO WHILE  I<=N
      C=SUBSTR(ST,I,1)
      NUM=ASC(C)
      IF NUM=241
         NUM=240
      ELSE
         IF (NUM>=224) .AND. (NUM<=239)
            NUM=NUM-80
         ELSE
            IF ((NUM>=97) .AND. (NUM<=122)) .OR. ((NUM>=160) .AND. (NUM<=175))
               NUM=NUM-32
            ENDIF
         ENDIF
      ENDIF
      C=CHR(NUM)
      STT=STT+C
      I=I+1
   ENDDO
   ST=STT
ENDIF
RETURN ST
