 PROGRAM TEX(INPUT,OUTPUT); 
 (* ОБОЛОЧКА ПРОСТЕЙШЕЙ ЭКСПЕРТНОЙ СИСТЕМЫ НА ЗНАНИЯХ *)
 (* ВИДА  СУЧНОСТЬ-АТРИБУТ .   --- RSX-11 ---         *)
 LABEL 1; 
 CONST
      KBLKFACTOR=48;
      WBLKFACTOR=12;
      WLENGTH=40; (* WORD LENGTH *) 
      NULLREF=0;
      SRVF='THIS_FILE_IS_PRODUCED_BY_TEX_SYSTEM,T&P.';
      FREE='ТЕМА_НЕ_ОПРЕДЕЛЕНА______________________';
      MAXQUERY=32000; 
      DATALENG = 512;   (* LEN OF DATA IN BYTES  --2TH RT-11 *) 
      DATANUMBER = 1;   (* NUMBER OF DATA RECORDS PER BUFFER *) 
 TYPE 
      INWORD=PACKED ARRAY [1..WLENGTH] OF CHAR; 
      RKBASE=RECORD 
                   D1:INTEGER;
                   D2:INTEGER;
                   ASSOCIATED:INTEGER;
                   ACTIVE:INTEGER;
                   RECTYP:(FACT,CONDITION)
             END; 
      WREC=  RECORD 
                   ASSOCIATED:INTEGER;
                   WORD:INWORD
             END; 
      KPREC=PACKED ARRAY [1..KBLKFACTOR] OF RKBASE; 
      WPREC=PACKED ARRAY [1..WBLKFACTOR] OF WREC; 
      WRANFILE = RECORD 
                   CASE INTEGER OF
                        1: (F : FILE OF WPREC); 
      (* 2: RT-11 *)    2: (POINT,MODE,BLOCK,BUFFER,WORDCOUNT,WAITFLAG,IOSTATUS: INTEGER);
                 END; 
      KRANFILE = RECORD 
                   CASE INTEGER OF
                        1: (F : FILE OF KPREC); 
      (* 2: RT-11 *)    2: (POINT,MODE,BLOCK,BUFFER,WORDCOUNT,WAITFLAG,IOSTATUS: INTEGER);
                 END; 
 VAR
    ACTIVITYSTATUS:INTEGER; 
    ACTLIMIT:INTEGER; 
    SHOW:BOOLEAN; 
    WASRESULT:BOOLEAN;
    ALLOUTSPRODUCED:BOOLEAN;
    STOPED:BOOLEAN; 
    ENDSATEOLN:BOOLEAN; 
    BASEWDS:PACKED ARRAY [1..10] OF CHAR; 
    BASEKDG:PACKED ARRAY [1..10] OF CHAR; 
    LCOUNTER:INTEGER; 
    CURWORD:INWORD; 
    CUROP:  (ENDWORD,IFWORD,NONTERMINAL,CRONLY);
    CURCHAR:CHAR; 
    NWBLOCKS:INTEGER; (* NUMBER OF WORD-DESCR. *) 
    NKBLOCKS:INTEGER; (* NUMBER OF FACT-DESCR. *) 
    MAXWBLOCKS:INTEGER; (* MAX NUMBER OF WORD-DESCR. *) 
    MAXKBLOCKS:INTEGER; (* MAX NUMBER OF FACT-DESCR. *) 
    ITERNUM:INTEGER;
    RUNTYP:INTEGER; 
    PASS:PACKED ARRAY [1..9] OF CHAR; 
    HPL:INTEGER;
    CURWBLOCK:WPREC;
    CURKBLOCK:KPREC;
    CURWBNUM:INTEGER; 
    CURKBNUM:INTEGER; 
    WCHANGED:BOOLEAN; 
    KCHANGED:BOOLEAN; 
    WRANDOMFILE:WRANFILE; 
    KRANDOMFILE:KRANFILE; 
  (* RT-11 PROCEDURE SEGMENT
  PROCEDURE WRANIO(VAR RFILE:WRANFILE;I:INTEGER); 
  VAR 
    K:INTEGER;
   BEGIN
     RFILE.IOSTATUS := RFILE.IOSTATUS AND 077777B;
     K:=I DIV DATANUMBER; 
     IF K#(RFILE.BLOCK-1) 
      THEN
       BEGIN
         IF (RFILE.MODE AND 400B)#0 
          THEN
           BEGIN
             RFILE.BLOCK:=RFILE.BLOCK-1;
             RFILE.POINT:=RFILE.BUFFER+512; 
             PUT(RFILE.F) 
           END; 
         RFILE.BLOCK:=K;
         RFILE.MODE:=RFILE.MODE AND 177377B;
         RFILE.POINT:=RFILE.BUFFER+512; 
         GET(RFILE.F);
       END; 
     RFILE.POINT:=RFILE.BUFFER+(I MOD DATANUMBER)*DATALENG
   END; 
  PROCEDURE WSEEK(VAR RFILE:WRANFILE;VAR R:WPREC;I:INTEGER);
   BEGIN
     WRANIO(RFILE,I); 
     R:=RFILE.F^
   END; 
  PROCEDURE WDEPOSIT(VAR RFILE:WRANFILE;VAR R:WPREC;I:INTEGER); 
   BEGIN
     WRANIO(RFILE,I); 
     RFILE.F^:=R; 
     RFILE.MODE:=RFILE.MODE OR 400B;
   END; 
  PROCEDURE WCLOSERANDOMFILE(VAR RFILE:WRANFILE); 
   BEGIN
     IF (RFILE.MODE AND 400B)#0 
      THEN
       BEGIN
         RFILE.POINT:=RFILE.BUFFER+512; 
         RFILE.BLOCK:=RFILE.BLOCK-1;
         GET(RFILE.F);
         RFILE.MODE:=RFILE.MODE AND 177377B;
       END; 
     CLOSE(RFILE.F) 
   END; 
  PROCEDURE KRANIO(VAR RFILE:KRANFILE;I:INTEGER); 
  VAR 
    K:INTEGER;
   BEGIN
     RFILE.IOSTATUS := RFILE.IOSTATUS AND 077777B;
     K:=I DIV DATANUMBER; 
     IF K#(RFILE.BLOCK-1) 
      THEN
       BEGIN
         IF (RFILE.MODE AND 400B)#0 
          THEN
           BEGIN
             RFILE.BLOCK:=RFILE.BLOCK-1;
             RFILE.POINT:=RFILE.BUFFER+512; 
             PUT(RFILE.F) 
           END; 
         RFILE.BLOCK:=K;
         RFILE.MODE:=RFILE.MODE AND 177377B;
         RFILE.POINT:=RFILE.BUFFER+512; 
         GET(RFILE.F);
       END; 
     RFILE.POINT:=RFILE.BUFFER+(I MOD DATANUMBER)*DATALENG
   END; 
  PROCEDURE KSEEK(VAR RFILE:KRANFILE;VAR R:KPREC;I:INTEGER);
   BEGIN
     KRANIO(RFILE,I); 
     R:=RFILE.F^
   END; 
  PROCEDURE KDEPOSIT(VAR RFILE:KRANFILE;VAR R:KPREC;I:INTEGER); 
   BEGIN
     KRANIO(RFILE,I); 
     RFILE.F^:=R; 
     RFILE.MODE:=RFILE.MODE OR 400B;
   END; 
  PROCEDURE KCLOSERANDOMFILE(VAR RFILE:KRANFILE); 
   BEGIN
     IF (RFILE.MODE AND 400B)#0 
      THEN
       BEGIN
         RFILE.POINT:=RFILE.BUFFER+512; 
         RFILE.BLOCK:=RFILE.BLOCK-1;
         GET(RFILE.F);
         RFILE.MODE:=RFILE.MODE AND 177377B;
       END; 
     CLOSE(RFILE.F) 
   END; 
 PROCEDURE WRITEWB(BNUM:INTEGER); 
 BEGIN
      WDEPOSIT(WRANDOMFILE,CURWBLOCK,BNUM); 
      WCHANGED:=FALSE 
 END; 
 PROCEDURE WRITEKB(BNUM:INTEGER); 
 BEGIN
      KDEPOSIT(KRANDOMFILE,CURKBLOCK,BNUM); 
      KCHANGED:=FALSE 
 END; 
 PROCEDURE READWB(BNUM:INTEGER);
 BEGIN
      IF CURWBNUM <> BNUM THEN
      BEGIN 
           IF WCHANGED THEN WRITEWB(BNUM);
           WSEEK(WRANDOMFILE,CURWBLOCK,BNUM); 
           CURWBNUM:=BNUM 
      END 
 END; 
 PROCEDURE READKB(BNUM:INTEGER);
 BEGIN
      IF CURKBNUM <> BNUM THEN
      BEGIN 
           IF KCHANGED THEN WRITEKB(BNUM);
           KSEEK(KRANDOMFILE,CURKBLOCK,BNUM); 
           CURKBNUM:=BNUM 
      END 
 END; 
    END OF RT-11 PROCEDURE SEGMENT *) 
 (* RSX-11 PROCEDURE SEGMENT *) 
 PROCEDURE WRITEWB(BNUM:INTEGER); 
 BEGIN
      SEEK(WRANDOMFILE.F,BNUM); 
      WRITE(WRANDOMFILE.F,CURWBLOCK); 
      WCHANGED:=FALSE 
 END; 
 PROCEDURE WRITEKB(BNUM:INTEGER); 
 BEGIN
      SEEK(KRANDOMFILE.F,BNUM); 
      WRITE(KRANDOMFILE.F,CURKBLOCK); 
      KCHANGED:=FALSE 
 END; 
 PROCEDURE READWB(BNUM:INTEGER);
 BEGIN
      IF CURWBNUM <> BNUM THEN
      BEGIN 
           IF WCHANGED THEN WRITEWB(BNUM);
           SEEK(WRANDOMFILE.F,BNUM);
           READ(WRANDOMFILE.F,CURWBLOCK); 
           CURWBNUM:=BNUM 
      END 
 END; 
 PROCEDURE READKB(BNUM:INTEGER);
 BEGIN
      IF CURKBNUM <> BNUM THEN
      BEGIN 
           IF KCHANGED THEN WRITEKB(BNUM);
           SEEK(KRANDOMFILE.F,BNUM);
           READ(KRANDOMFILE.F,CURKBLOCK); 
           CURKBNUM:=BNUM 
      END 
 END; 
 (* END OF RSX-11 PROCEDURE SEGMENT *)
 PROCEDURE OUTWORD(WORD:INWORD);
 VAR
    I:INTEGER;
 BEGIN
      FOR I:=1 TO WLENGTH DO
      BEGIN 
      (*   IF (WORD[I]='_') THEN
           BEGIN
                LCOUNTER:=LCOUNTER+1; 
                WRITELN 
           END; *)
           IF (WORD[I] <> ' ') THEN  WRITE(WORD[I]);
      END 
 END; 
 PROCEDURE LOCATEWR(RNUM:INTEGER; REC:WREC);
 BEGIN
      WCHANGED:=TRUE; 
      CURWBLOCK[RNUM]:=REC
 END; 
 PROCEDURE LOCATEKR(RNUM:INTEGER; REC:RKBASE);
 BEGIN
      KCHANGED:=TRUE; 
      CURKBLOCK[RNUM]:=REC
 END; 
 PROCEDURE SELECTWR(RNUM:INTEGER; VAR REC:WREC);
 BEGIN
      REC:=CURWBLOCK[RNUM]
 END; 
 PROCEDURE SELECTKR(RNUM:INTEGER; VAR REC:RKBASE);
 BEGIN
      REC:=CURKBLOCK[RNUM]
 END; 
 PROCEDURE CREAD(VAR C:CHAR); 
 BEGIN
      READ(C);
      IF  (NOT (C IN ['A'..'Z'] )) AND (NOT (C IN ['0'..'9']))
                                   AND (NOT (C IN ['А'..'З']))
                                   AND
      (C <> '*') AND (C <> '/') AND (C <> '?') AND (C <> ' ') 
                                   AND
      (C <> 'Ч') AND (C <> 'Ш') AND (C <> 'Щ') AND (C <> 'Э') 
                                   AND
      (C <> 'Ю') AND (C <> '&') AND (C <> '@') AND (C <> '"') 
                                   AND
      (C <> '(') AND (C <> ')') AND (C <> '%') AND (C <> '!') 
      THEN CREAD(C) 
 END; 
 PROCEDURE GETWORD; 
 VAR
    LC:INTEGER; 
 BEGIN
      ENDSATEOLN:=FALSE;
      REPEAT
            CREAD(CURCHAR); 
            IF EOLN THEN ENDSATEOLN:=TRUE;
      UNTIL (CURCHAR <> ' ') OR EOF OR EOLN;
      IF EOF
      THEN CUROP:=ENDWORD 
      ELSE BEGIN
      FOR LC:=1 TO WLENGTH DO CURWORD[LC]:=' '; 
      IF (CURCHAR = '(')
      THEN
      BEGIN 
          REPEAT CREAD(CURCHAR) UNTIL (CURCHAR <> ' ') OR EOF;
          IF NOT EOF THEN 
          BEGIN 
               LC:=0; 
               WHILE (CURCHAR <> ')') AND (NOT EOF) DO
               BEGIN
                    LC:=LC+1; 
                    IF (CURCHAR = ' ') THEN 
                    BEGIN 
                         REPEAT CREAD(CURCHAR) UNTIL (CURCHAR<>' ') OR EOF; 
                         IF (LC<=WLENGTH) AND (CURCHAR<>')') THEN CURWORD[LC]:='_'; 
                         LC:=LC+1 
                    END;
                    IF (CURCHAR<>')') AND 
                       (LC<=WLENGTH)  THEN CURWORD[LC]:=CURCHAR;
                    IF (CURCHAR<>')') THEN
                        CREAD(CURCHAR); 
                        IF EOLN THEN ENDSATEOLN:=TRUE 
               END; 
          END 
     END
     ELSE 
     BEGIN
          LC:=0;
          REPEAT
                LC:=LC+1; 
                IF LC <= WLENGTH THEN CURWORD[LC]:=CURCHAR; 
                CREAD(CURCHAR); 
                IF EOLN THEN ENDSATEOLN:=TRUE 
          UNTIL (CURCHAR = ' ') OR EOF
      END;
      CUROP:=NONTERMINAL; 
      IF (CURWORD[1] = ' ') THEN CUROP:=CRONLY; 
      IF (CURWORD[1]='H') AND (CURWORD[2]='E') AND (CURWORD[3]='L') 
                          AND (CURWORD[4]='P') AND (CURWORD[5]=' ') 
         THEN CUROP:=CRONLY;
      IF (CURWORD[1]='?') OR (CURWORD[1]='/') 
         THEN CUROP:=CRONLY;
      IF (CURWORD[1]='I') AND (CURWORD[2]='F') AND (CURWORD[3]=' ') 
         THEN CUROP:=IFWORD;
      IF (CURWORD[1]='Е') AND (CURWORD[2]='С') AND (CURWORD[3]='Л') 
                          AND (CURWORD[4]='И') AND (CURWORD[5]=' ') 
         THEN CUROP:=IFWORD;
      IF (CURWORD[1]='*') AND (CURWORD[2]=' ')
         THEN CUROP:=ENDWORD; 
      IF (CURWORD[1]='E') AND (CURWORD[2]='N') AND (CURWORD[3]='D') 
                          AND (CURWORD[4]=' ')
         THEN CUROP:=ENDWORD
           END
 END; 
 PROCEDURE FORMBASE;
 (* KNOWLEDGE-BASE FORMATIZATION *) 
 VAR
    NWORDS:INTEGER; 
    KR:RKBASE;
    WR:WREC;
    IB:INTEGER; 
    IR:INTEGER; 
    IRM:INTEGER;
    NFACTS:INTEGER; 
 BEGIN
      WRITELN;
      WRITELN('*** ФОРМАТИЗАЦИЯ БАЗЫ ЗНАНИЙ ***');
      WRITE  ('    НА КАКУЮ ТЕМУ БУДЕТ ЭТА БАЗА ЗНАНИЙ ? ');
      FOR IR:=1 TO WLENGTH DO CURWORD[IR]:=' '; 
      IR:=0;
      REPEAT
            IR:=IR+1; 
            IF (IR <= WLENGTH) THEN  READ(CURWORD[IR])
      UNTIL EOLN; 
      IF (IR = 1) THEN CURWORD:=FREE; 
      WRITE  ('    СКОЛЬКО СЛОВ БУДЕТ ИЗВЕСТНО МАШИНЕ ?');
      READLN(NWORDS); 
      CURWBNUM:=0;
      WCHANGED:=FALSE;
      CURKBNUM:=0;
      KCHANGED:=FALSE;
      NWBLOCKS:=(NWORDS DIV WBLKFACTOR)+WLENGTH+1;
      WR.WORD:=FREE;
      WR.ASSOCIATED:=NULLREF; 
      REWRITE(WRANDOMFILE.F ,BASEWDS );              (* SWITCHES RSX *) 
      WRITE('НА СЛОВА НУЖНО ',NWBLOCKS:3,'  БЛОКОВ:');
      FOR IB:=1 TO NWBLOCKS DO
      BEGIN 
           FOR IR:=1 TO WBLKFACTOR DO LOCATEWR(IR,WR);
           WRANDOMFILE.F^:=CURWBLOCK; 
           PUT (WRANDOMFILE.F); 
           IRM:=IB MOD 10;
           WRITE(IRM:1) 
      END;
      WRANDOMFILE.F^:=CURWBLOCK;
      CLOSE(WRANDOMFILE.F); 
      RESET(WRANDOMFILE.F,BASEWDS, '/SEEK/RW'); (* SWTCHS RSX *)
      READWB(1);
      SELECTWR(1,WR);WR.ASSOCIATED:=NWBLOCKS; WR.WORD:=CURWORD; LOCATEWR(1,WR); 
      SELECTWR(2,WR);WR.ASSOCIATED:=WLENGTH+1;WR.WORD:=SRVF;    LOCATEWR(2,WR); 
      WRITEWB(1); 
 (*   WCLOSERANDOMFILE(WRANDOMFILE); RT-11   *) 
      CLOSE(WRANDOMFILE.F);       (* RSX-11  *) 
      WRITELN;
      WRITE  ('    СКОЛЬКО ФАКТОВ И УСЛОВИЙ БУДЕТ ИЗВЕСТНО МАШИНЕ ?');
      READLN(NFACTS); 
      NKBLOCKS:=(NFACTS DIV KBLKFACTOR)+WLENGTH+1;
      KR.D1:=NULLREF; 
      KR.D2:=NULLREF; 
      KR.ACTIVE:=0; 
      KR.ASSOCIATED:=NULLREF; 
      REWRITE(KRANDOMFILE.F ,BASEKDG);              (* RSX SW. *) 
      WRITE('НА ЗНАНИЯ НУЖНО ',NKBLOCKS:3,'  БЛОКОВ:'); 
      FOR IB:=1 TO NKBLOCKS DO
      BEGIN 
           FOR IR:=1 TO KBLKFACTOR DO LOCATEKR(IR,KR);
           KRANDOMFILE.F^:=CURKBLOCK; 
           PUT (KRANDOMFILE.F); 
           IRM:=IB MOD 10;
           WRITE(IRM:1) 
      END;
      KRANDOMFILE.F^:=CURKBLOCK;
      CLOSE(KRANDOMFILE.F); 
      RESET(KRANDOMFILE.F,BASEKDG, '/SEEK/RW'); (* RSX SW. *) 
      READKB(1);
      SELECTKR(1,KR);KR.ASSOCIATED:=NKBLOCKS;KR.ACTIVE:=0;LOCATEKR(1,KR); 
      SELECTKR(2,KR);KR.ASSOCIATED:=WLENGTH+1;KR.D1:=-1;KR.D2:=-1;LOCATEKR(2,KR); 
      WRITEKB(1); 
 (*   KCLOSERANDOMFILE(KRANDOMFILE);   RT-11 *) 
      CLOSE(KRANDOMFILE.F);       (* RSX-11  *) 
      WRITELN;
   WRITELN('*** БАЗА ЗНАНИЙ СФОРМАТИРОВАНА. ЖЕЛАЮ ПРИЯТНЫХ УМОЗАКЛЮЧЕНИЙ.***'); 
 END; 
 PROCEDURE FACTFRKBASE(FACT:INTEGER; VAR REC:RKBASE); 
 VAR
    B:INTEGER;
    H:INTEGER;
 BEGIN
      B:=FACT DIV KBLKFACTOR; 
      IF (KBLKFACTOR*B <> FACT) THEN B:=B+1;
      H:=FACT-KBLKFACTOR*(B-1); 
      READKB(B);
      SELECTKR(H,REC) 
 END; 
 PROCEDURE KDIRECT(FACT:INTEGER; VAR REC:RKBASE; VAR B:INTEGER; VAR H:INTEGER); 
 BEGIN
      B:=FACT DIV KBLKFACTOR; 
      IF (KBLKFACTOR*B <> FACT) THEN B:=B+1;
      H:=FACT-KBLKFACTOR*(B-1); 
      READKB(B);
      SELECTKR(H,REC) 
 END; 
 PROCEDURE OCCUPYBLOCK(VAR NEWBLOCK:INTEGER); 
 VAR
    CURREC:WREC;
 BEGIN
      READWB(1);
      SELECTWR(2,CURREC); 
      NEWBLOCK:=CURREC.ASSOCIATED;
      IF NEWBLOCK = MAXWBLOCKS
      THEN BEGIN
                NEWBLOCK:=0;
                WRITELN('*** УВЫ *** БОЛЬШЕ НЕГДЕ ХРАНИТЬ СЛОВА');
           END
      ELSE
           BEGIN
                NEWBLOCK:=NEWBLOCK+1; 
                NWBLOCKS:=NWBLOCKS+1; 
                CURREC.ASSOCIATED:=NEWBLOCK;
                LOCATEWR(2,CURREC); 
                WRITEWB(1)
          END 
 END; 
 PROCEDURE OCCUPYKLOCK(VAR NEWBLOCK:INTEGER); 
 VAR
    CURREC:RKBASE;
 BEGIN
      READKB(1);
      SELECTKR(2,CURREC); 
      NEWBLOCK:=CURREC.ASSOCIATED;
      IF NEWBLOCK = MAXKBLOCKS
      THEN BEGIN
                NEWBLOCK:=0;
                WRITELN('*** УВЫ *** БОЛЬШЕ НЕГДЕ ХРАНИТЬ ЗНАНИЯ'); 
           END
      ELSE
           BEGIN
                NEWBLOCK:=NEWBLOCK+1; 
                NKBLOCKS:=NKBLOCKS+1; 
                CURREC.ASSOCIATED:=NEWBLOCK;
                LOCATEKR(2,CURREC); 
                WRITEKB(1)
          END 
 END; 
 PROCEDURE FINKB(AKNOW:RKBASE; FBLOCK:INTEGER;
                 VAR FOUND:BOOLEAN; VAR NEXT:INTEGER; 
                 VAR NKBASE:INTEGER); 
 VAR
     CURREC:RKBASE; 
 BEGIN
      READKB(FBLOCK); 
      SELECTKR(1,CURREC); 
      NEXT:=CURREC.ASSOCIATED;
      NKBASE:=2;
      REPEAT
            SELECTKR(NKBASE,CURREC);
            NKBASE:=NKBASE+1; 
            FOUND:=(AKNOW.D1 = CURREC.D1) 
                        AND 
                   (AKNOW.D2 = CURREC.D2) 
      UNTIL FOUND OR (NKBASE > KBLKFACTOR); 
      NKBASE:=NKBASE-1; 
 END; 
 PROCEDURE FINWB(WORD:INWORD;HBLOCK:INTEGER;
                 VAR FOUND:BOOLEAN; VAR NEXTOFL:INTEGER;
                 VAR HISREC:INTEGER); 
 VAR
    CURREC:WREC;
 BEGIN
      READWB(HBLOCK); 
      SELECTWR(1,CURREC); 
      NEXTOFL:=CURREC.ASSOCIATED; 
      HISREC:=2;
      REPEAT
            SELECTWR(HISREC,CURREC);
            HISREC:=HISREC+1; 
            FOUND:=(WORD = CURREC.WORD) 
      UNTIL FOUND OR (HISREC > WBLKFACTOR); 
      HISREC:=HISREC-1
 END; 
 PROCEDURE HASHWORD(WORD:INWORD;VAR HBLOCK:INTEGER);
 VAR
    I:INTEGER;
 BEGIN
      FOR I:=1 TO WLENGTH DO
      BEGIN 
           IF (WORD[I]<>' ') THEN HBLOCK:=I 
      END;
      HBLOCK:=HBLOCK+1
 END; 
 PROCEDURE FINDWORD(WORD:INWORD;VAR HISREC:INTEGER;VAR FOUND:BOOLEAN);
 VAR
    HBLOCK:INTEGER; 
    NEXTOFL:INTEGER;
    CBLOCK:INTEGER; 
 BEGIN
      HASHWORD(WORD,HBLOCK);
      REPEAT
            FINWB(WORD,HBLOCK,FOUND,NEXTOFL,HISREC);
            CBLOCK:=HBLOCK; 
            HBLOCK:=NEXTOFL 
      UNTIL FOUND OR (NEXTOFL=NULLREF); 
      HISREC:=(CBLOCK-1)*WBLKFACTOR+HISREC; 
 END; 
 PROCEDURE WORDFRWBASE(WORD:INWORD; VAR REC:WREC; 
                       VAR WWB:INTEGER;VAR WWR:INTEGER);
 VAR
     HISREC:INTEGER;
     FOUND:BOOLEAN; 
     NEXTOFL:INTEGER; 
     HBLOCK:INTEGER;
     CBLOCK:INTEGER;
 BEGIN
      HASHWORD(WORD,HBLOCK);
      REPEAT
            FINWB(WORD,HBLOCK,FOUND,NEXTOFL,HISREC);
            CBLOCK:=HBLOCK; 
            HBLOCK:=NEXTOFL;
      UNTIL FOUND OR (NEXTOFL=NULLREF); 
      WWB:=CBLOCK;
      WWR:=HISREC;
      SELECTWR(HISREC,REC)
 END; 
 PROCEDURE WDIRECT(R:INTEGER; VAR REC:WREC; VAR WWB:INTEGER; VAR WWR:INTEGER);
 BEGIN
      WWB:=R DIV WBLKFACTOR;
      IF (WWB*WBLKFACTOR <> R) THEN WWB:=WWB+1; 
      WWR:=R-(WWB-1)*WBLKFACTOR;
      READWB(WWB);
      SELECTWR(WWR,REC) 
 END; 
 PROCEDURE LOCFACT(SUBJECT:INTEGER; FACTREC:RKBASE; VAR NKBASE:INTEGER);
 VAR
    CURREC:WREC;
    FACTBLOCK:INTEGER;
    FOUND:BOOLEAN;
    NEXT:INTEGER; 
    CBLOCK:INTEGER; 
    FREEREC:RKBASE; 
    FIRSTBLOCK:INTEGER; 
    NEWBLOCK:INTEGER; 
    OLDFACT:RKBASE; 
    WWB:INTEGER;
    WWR:INTEGER;
 BEGIN
      WDIRECT(SUBJECT,CURREC,WWB,WWR);
      HASHWORD(CURREC.WORD,FACTBLOCK);
      CURREC.ASSOCIATED:=FACTBLOCK; 
      LOCATEWR(WWR,CURREC); 
      WRITEWB(WWB); 
      FIRSTBLOCK:=FACTBLOCK;
      REPEAT
            FINKB(FACTREC,FACTBLOCK,FOUND,NEXT,NKBASE); 
            CBLOCK:=FACTBLOCK;
            FACTBLOCK:=NEXT 
      UNTIL FOUND OR (NEXT = NULLREF);
      IF NOT FOUND THEN 
      BEGIN 
           WITH FREEREC DO BEGIN D1:=NULLREF; D2:=NULLREF END;
           FACTBLOCK:=FIRSTBLOCK; 
           REPEAT 
                 FINKB(FREEREC,FACTBLOCK,FOUND,NEXT,NKBASE);
                 CBLOCK:=FACTBLOCK; 
                 FACTBLOCK:=NEXT
           UNTIL FOUND OR (NEXT = NULLREF); 
           IF FOUND 
           THEN 
               BEGIN
                    LOCATEKR(NKBASE,FACTREC); 
                    WRITEKB(CBLOCK);
               END
           ELSE 
               BEGIN
                    OCCUPYKLOCK(NEWBLOCK);
                    READKB(CBLOCK); 
                    FACTREC.ASSOCIATED:=NEWBLOCK; 
                    LOCATEKR(1,FACTREC);
                    WRITEKB(CBLOCK);
                    READKB(NEWBLOCK); 
                    FACTREC.ASSOCIATED:=NULLREF;
                    LOCATEKR(2,FACTREC);
                    WRITEKB(NEWBLOCK);
                    CBLOCK:=NEWBLOCK; 
                    NKBASE:=2 
                END 
        END 
        ELSE
        BEGIN 
             SELECTKR(NKBASE,OLDFACT);
             IF ((OLDFACT.ACTIVE  >= ACTIVITYSTATUS) AND (ACTIVITYSTATUS <> 0 ))
             THEN WRITELN('    СПАСИБО, Я УЖЕ ЗНАЮ'); 
             IF (ACTIVITYSTATUS > OLDFACT.ACTIVE) THEN
             BEGIN
                  IF (RUNTYP <> 3) THEN 
                     WRITELN('    МНЕ ПРИЯТНО ЭТО УЗНАТЬ')
                                   ELSE 
                     WRITELN('    МНЕ ПРИЯТНО ТАК ДУМАТЬ'); 
                  OLDFACT.ACTIVE:=ACTIVITYSTATUS; 
                  LOCATEKR(NKBASE,OLDFACT); 
                  WRITEKB(CBLOCK) 
             END
         END; 
    NKBASE:=(CBLOCK-1)*KBLKFACTOR+NKBASE
 END; 
 PROCEDURE LOCWORD(WORD:INWORD; VAR HISREC:INTEGER);
 VAR
    CBLOCK:INTEGER; 
    HBLOCK:INTEGER; 
    FOUND:BOOLEAN;
    NEXTOFL:INTEGER;
    NEWBLOCK:INTEGER; 
    CURREC:WREC;
 BEGIN
      HASHWORD(WORD,HBLOCK);
      REPEAT
            FINWB(FREE,HBLOCK,FOUND,NEXTOFL,HISREC);
            CBLOCK:=HBLOCK; 
            HBLOCK:=NEXTOFL 
      UNTIL FOUND OR (NEXTOFL = NULLREF); 
      CURREC.WORD:=WORD;
      CURREC.ASSOCIATED:=NULLREF; 
      IF FOUND
      THEN BEGIN
                LOCATEWR(HISREC,CURREC);
                WRITEWB(CBLOCK) 
           END
      ELSE
           BEGIN
                OCCUPYBLOCK(NEWBLOCK);
                READWB(CBLOCK); 
                CURREC.ASSOCIATED:=NEWBLOCK;
                LOCATEWR(1,CURREC); 
                WRITEWB(CBLOCK);
                READWB(NEWBLOCK); 
                CURREC.ASSOCIATED:=NULLREF; 
                LOCATEWR(2,CURREC); 
                WRITEWB(NEWBLOCK);
                CBLOCK:=NEWBLOCK; 
                HISREC:=2 
           END; 
      HISREC:=(CBLOCK-1)*WBLKFACTOR+HISREC
 END; 
 PROCEDURE LOCCOND(PREMISE:INTEGER; CONDREC:RKBASE; VAR NKBASE:INTEGER);
 VAR
    FACTREC:RKBASE; 
 BEGIN
      FACTFRKBASE(PREMISE,FACTREC); 
      LOCFACT(FACTREC.D1,CONDREC,NKBASE)
 END; 
 PROCEDURE GFACT(VAR NKBASE:INTEGER); 
 VAR
    SUBJECT,PROPERTY:INTEGER; 
    FOUND:BOOLEAN;
    FACTREC:RKBASE; 
 BEGIN
      IF ENDSATEOLN THEN
      BEGIN 
           WRITE('СВОЙСТВО ПРЕДМЕТА "');
           OUTWORD(CURWORD);
           WRITE('": ') 
      END;
      IF (CUROP<>ENDWORD) THEN
      BEGIN 
      FINDWORD(CURWORD,SUBJECT,FOUND);
      IF NOT FOUND THEN LOCWORD(CURWORD,SUBJECT); 
      GETWORD;
      WHILE (CUROP = CRONLY) DO 
      BEGIN 
           WRITELN('ПРИМЕРЫ СВОЙСТВ:'); 
           WRITELN('    KРАСНЫЙ    (ГРОМКО ЛАЕТ)   МИНЕРАЛ'); 
           WRITE('СВОЙСТВО:   '); 
           GETWORD
      END;
      IF (CUROP<>ENDWORD) THEN
      BEGIN 
           FINDWORD(CURWORD,PROPERTY,FOUND);
           IF NOT FOUND THEN LOCWORD(CURWORD,PROPERTY); 
           WITH FACTREC DO
           BEGIN
               RECTYP:=FACT;
               D1:=SUBJECT; 
               D2:=PROPERTY;
               ACTIVE:=ACTIVITYSTATUS;
               ASSOCIATED:=NULLREF; 
           END; 
           LOCFACT(SUBJECT,FACTREC,NKBASE)
      END 
      END 
 END; 
 PROCEDURE OPERATOR(VAR NKBASE:INTEGER);FORWARD;
 PROCEDURE COND(VAR NKBASE:INTEGER);
 VAR
    PREMISE,CONSEQUENCE:INTEGER;
    CONDREC:RKBASE; 
    SIFA:INTEGER; 
 BEGIN
      IF ENDSATEOLN THEN WRITE('ПРЕДПОСЫЛКА:'); 
      SIFA:=ACTIVITYSTATUS; 
      ACTIVITYSTATUS:=0;
      GETWORD;
      WHILE (CUROP = CRONLY) DO 
      BEGIN 
           WRITELN('ПРИМЕРЫ ПРЕДПОСЫЛОК:'); 
           WRITELN('   СОКРАТ ЧЕЛОВЕК');
           WRITELN('   (БЕЛЫЕ СОБАКИ) (НЕ КУСАЮТ ДОЦЕНТОВ)'); 
           WRITE('ПРЕДПОСЫЛКА:'); 
           GETWORD
      END;
      GFACT(PREMISE); 
      IF (CUROP<>ENDWORD) THEN
      BEGIN 
           IF ENDSATEOLN THEN WRITELN('ЧТО ЖЕ ИЗ ЭТОГО СЛЕДУЕТ ?'); 
           OPERATOR(CONSEQUENCE); 
           ACTIVITYSTATUS:=SIFA;
           WITH CONDREC DO
           BEGIN
                RECTYP:=CONDITION;
                D1:=PREMISE;
                D2:=CONSEQUENCE;
                ACTIVE:=ACTIVITYSTATUS; 
                ASSOCIATED:=NULLREF 
           END; 
           LOCCOND(PREMISE,CONDREC,NKBASE)
      END 
 END; 
 PROCEDURE OPERATOR; (*(VAR NKBASE:INTEGER)*) 
 BEGIN
      IF ENDSATEOLN THEN WRITE('*');
      GETWORD;
      WHILE (CUROP = CRONLY) DO 
      BEGIN 
           WRITE('ФАКТ ИЛИ УСЛОВИЕ:');
           GETWORD; 
           IF (CUROP=CRONLY) THEN 
           BEGIN
 WRITELN('ПРИМЕР ФАКТА  : ПЧЕЛКИ ПОЛЕЗНЫЕ');
 WRITELN('ИЛИ 3  ФАКТА  : ПЧЕЛКИ ПОЛЕЗНЫЕ ЛУНА КРУГЛАЯ СОБАКА ЛАЕТ'); 
 WRITELN('ПРИМЕР УСЛОВИЯ: ЕСЛИ НЕБО СИНЕЕ ПОГОДА ХОРОШАЯ'); 
 WRITELN('ИЛИ           : ЕСЛИ НЕБО СИНЕЕ ЕСЛИ СОЛНЦЕ СВЕТИТ ПОГОДА ХОРОШАЯ');
 WRITELN('В ОДНОЙ СТРОКЕ МОГУТ БЫТЬ И ФАКТЫ, И УСЛОВИЯ, НАПРИМЕР:');
 WRITELN('ПЧЕЛКИ ПОЛЕЗНЫЕ ЕСЛИ ПОГОДА ПРИЯТНАЯ НАМ ХОРОШО СТУЛ УСТОЙЧИВ');
 WRITELN('<....ФАКТ.....> <........УСЛОВНЫЙ ФАКТ........> <....ФАКТ...>');
 WRITELN('ЕСЛИ СЛОВА В СКОБКАХ, ТО ЭТО ОДНО СЛОВО, НАПРИМЕР:'); 
 WRITELN('             (БЕЛЫЕ СОБАКИ) (НИКУДА НЕ ГОДЯТСЯ)');
 WRITELN('ЭТО  Н Е  ЭКВИВАЛЕНТНО СЛЕДУЮЩИМ ЗНАНИЯМ:');
 WRITELN('        ЕСЛИ СОБАКИ БЕЛЫЕ СОБАКИ (НИКУДА НЕ ГОДЯТСЯ)'); 
 WRITELN('ВНУТРЕННИЕ СКОБКИ ЗАПРЕЩЕНЫ. ПОДСКАЗКИ В СКОБКАХ НЕ ДЕЙСТВУЮТ');
 WRITELN('ЗВЕЗДОЧКА - ПРИГЛАШЕНИЕ ВВОДИТЬ НОВУЮ СТРОКУ'); 
 WRITELN('ЕСЛИ ВЫ ПЕРЕДУМАЛИ, ВВЕДИТЕ END ИЛИ СИМВОЛ "*" ');
 WRITE('ФАКТ ИЛИ УСЛОВИЕ:');
           GETWORD
           END
      END;
      IF (CUROP = IFWORD) 
      THEN COND(NKBASE) 
      ELSE IF (CUROP<>ENDWORD) THEN GFACT(NKBASE);
 END; 
 PROCEDURE REVOLUTION;
 VAR
    K:RKBASE; 
    IB,IR:INTEGER;
    IBM:INTEGER; (* SIC ! *)
 BEGIN
      WRITELN('*** МИНУТОЧКУ *** У МЕНЯ ЗАПОЙ. ЖДИТЕ ДО ',NKBLOCKS:4);
      FOR IB:=1 TO NKBLOCKS DO
      BEGIN 
           READKB(IB);
           FOR IR:=1 TO KBLKFACTOR DO 
           BEGIN
                SELECTKR(IR,K); 
                IF (K.ACTIVE < MAXQUERY) THEN K.ACTIVE:=0 
           END; 
           WRITEKB(IB); 
           IBM:=IB MOD 10;
           WRITE(IBM:1) 
      END;
      WRITELN 
 END; 
 PROCEDURE INITADD; 
 VAR
    W:WREC; 
    K:RKBASE; 
    BASENAME:INWORD;
 BEGIN
      RESET(WRANDOMFILE.F ,BASEWDS, '/RW/SEEK/SHR');
      RESET(KRANDOMFILE.F ,BASEKDG, '/RW/SEEK/SHR'); (* RSX SWTCHS *) 
      READWB(1);
      SELECTWR(1,W);
      MAXWBLOCKS:=W.ASSOCIATED; 
      BASENAME:=W.WORD; 
      WRITELN('*** БАЗА ЗНАНИЙ НА ТЕМУ: ',BASENAME);
      SELECTWR(2,W);
      NWBLOCKS:=W.ASSOCIATED; 
      READKB(1);
      SELECTKR(1,K);
      MAXKBLOCKS:=K.ASSOCIATED; 
      ACTLIMIT:=K.ACTIVE+1; 
      SELECTKR(2,K);
      NKBLOCKS:=K.ASSOCIATED; 
      IF (ACTLIMIT = MAXQUERY) THEN REVOLUTION; 
      CURWBNUM:=0;
      WCHANGED:=FALSE;
      CURKBNUM:=0;
      KCHANGED:=FALSE 
 END; 
 PROCEDURE ADDBASE; 
 VAR
    CURREC:INTEGER; 
 BEGIN
      INITADD;
      WRITELN('*** ОБУЧЕНИЕ МАШИНЫ ***'); 
      WRITELN('    ПОЖАЛУЙСТА, ВВОДИТЕ ФАКТЫ И УСЛОВИЯ; ВЫХОД - END ИЛИ *, ПОДСКАЗКИ - <ВК>');
      REPEAT
            ACTIVITYSTATUS:=MAXQUERY; 
            OPERATOR(CURREC)
      UNTIL CUROP = ENDWORD;
 (*   WCLOSERANDOMFILE(WRANDOMFILE);
      KCLOSERANDOMFILE(KRANDOMFILE)  RT-11 *) 
      CLOSE(WRANDOMFILE.F); 
      CLOSE(KRANDOMFILE.F)   (* RSX-11 *) 
 END; 
 PROCEDURE GETFACT(TSUBJC:INWORD; TSUBJR:INTEGER; K:RKBASE);
 VAR
    SUBJC:INWORD; 
    PROPC:INWORD; 
    WR:WREC;
    WWB,WWR:INTEGER;
 BEGIN
      IF (K.ACTIVE >= ACTLIMIT) THEN
      BEGIN 
           IF SHOW THEN 
           BEGIN
               WDIRECT(K.D1,WR,WWB,WWR);
               SUBJC:=WR.WORD;
               WDIRECT(K.D2,WR,WWB,WWR);
               PROPC:=WR.WORD;
               IF (K.ACTIVE = MAXQUERY) 
               THEN WRITE('БЕЗУСЛОВНО, ') 
               ELSE WRITE('ДУМАЮ, ЧТО  ');
               OUTWORD(SUBJC); WRITE(' ');OUTWORD(PROPC); 
               WRITELN; 
               LCOUNTER:=LCOUNTER+1 
          END;
          IF (K.D1=TSUBJR) THEN 
          BEGIN 
               WASRESULT:=TRUE; 
               IF NOT SHOW THEN 
               BEGIN
                    WDIRECT(K.D2,WR,WWB,WWR); 
                    PROPC:=WR.WORD; 
                    IF (K.ACTIVE = MAXQUERY)
                    THEN WRITE('БЕЗУСЛОВНО, ')
                    ELSE WRITE('ДУМАЮ, ЧТО  '); 
                    OUTWORD(TSUBJC); WRITE(' ');OUTWORD(PROPC); 
                    WRITELN;
                    LCOUNTER:=LCOUNTER+1
               END
          END 
     END
 END; 
 PROCEDURE GETCOND(TSUBJC:INWORD; TSUBJR:INTEGER; K:RKBASE);
 VAR
    KRP,KRC:RKBASE; 
    KB,KH:  INTEGER;
    W1,W2,W3,W4:WREC; 
    WWB,WWR:INTEGER;
 BEGIN
      IF (K.ACTIVE>=ACTLIMIT) THEN
      BEGIN 
           FACTFRKBASE(K.D1,KRP); 
           IF (KRP.ACTIVE >= ACTLIMIT) THEN 
           BEGIN
                KDIRECT(K.D2,KRC,KB,KH);
                     IF SHOW THEN 
                     BEGIN
                          IF (KRP.RECTYP=FACT) AND (KRC.RECTYP=FACT) THEN 
                          BEGIN 
                               WDIRECT(KRP.D1,W1,WWB,WWR);
                               WDIRECT(KRP.D2,W2,WWB,WWR);
                               WDIRECT(KRC.D1,W3,WWB,WWR);
                               WDIRECT(KRC.D2,W4,WWB,WWR);
                WRITE('РАЗ '); OUTWORD(W1.WORD);
                WRITE(' ');    OUTWORD(W2.WORD);
                WRITE(', ТО ');OUTWORD(W3.WORD);
                WRITE(' ');    OUTWORD(W4.WORD);
                               WRITELN; 
                               LCOUNTER:=LCOUNTER+1 
                          END 
                          ELSE
                          IF (KRP.RECTYP = FACT) THEN 
                          BEGIN 
                               WDIRECT(KRP.D1,W1,WWB,WWR);
                               WDIRECT(KRP.D2,W2,WWB,WWR);
                WRITE('ХОРОШО, ЧТО '); OUTWORD(W1.WORD);
                WRITE(' ');            OUTWORD(W2.WORD);
                               WRITELN; 
                               LCOUNTER:=LCOUNTER+1 
                          END 
                     END; 
                     IF (KRC.D1 <> NULLREF) AND (KRC.D2 <> NULLREF) THEN
                     BEGIN
                        IF (KRC.RECTYP = FACT) AND (KRC.ACTIVE < ACTLIMIT)
                            THEN ALLOUTSPRODUCED:=FALSE;
                        KRC.ACTIVE:=ACTLIMIT; 
                        LOCATEKR(KH,KRC); 
                        WRITEKB(KB);
                        CASE KRC.RECTYP OF
                             FACT:GETFACT(TSUBJC,TSUBJR,KRC); 
                        CONDITION:GETCOND(TSUBJC,TSUBJR,KRC)
                        END 
                     END
           END
      END 
 END; 
 PROCEDURE GETKNOWLEDGE(TSUBJC:INWORD;TSUBJR:INTEGER);
 LABEL 1; 
 VAR
    IK,IR:INTEGER;
    K:RKBASE; 
    C:CHAR; 
 BEGIN
      WRITE('*** ДЕЛАЮ ЭКСПЕРТНЫЕ ЗАКЛЮЧЕНИЯ НА ТЕМУ: '); 
      OUTWORD(TSUBJC);
      WRITELN(' ***');
      ITERNUM:=0; 
      STOPED:=FALSE;
      WASRESULT:=FALSE; 
      LCOUNTER:=0;
      REPEAT
            ALLOUTSPRODUCED:=TRUE;
            ITERNUM:=ITERNUM+1; 
            FOR IK:=2 TO NKBLOCKS DO
            BEGIN 
                 READKB(IK);
                 FOR IR:=2 TO KBLKFACTOR DO 
                 BEGIN
                      SELECTKR(IR,K); 
                      IF (K.D1 <> NULLREF) AND (K.D2 <> NULLREF) THEN 
                      CASE K.RECTYP OF
                           FACT: GETFACT(TSUBJC,TSUBJR,K);
                      CONDITION: GETCOND(TSUBJC,TSUBJR,K) 
                      END;
                      IF ((LCOUNTER > 22) OR ((IK = NKBLOCKS) AND (IR = KBLKFACTOR))) 
                                         AND
                                (NOT ALLOUTSPRODUCED) 
                      THEN
                      BEGIN 
                           LCOUNTER:=0; 
                           WRITE('*** ДАЛЬШЕ ? ');
                           GETWORD; 
                           C:=CURWORD[1]; 
                           IF (C='N') OR (C='0') OR (C='Н') THEN
                           BEGIN
                                STOPED:=TRUE; 
                                GOTO 1
                           END; 
                           WRITELN; 
                           WRITE('*** ПРОДОЛЖАЮ ЗАКЛЮЧЕНИЯ НА ТЕМУ: '); 
                           OUTWORD(TSUBJC); WRITELN(' ***') 
                      END 
                  END 
              END;
              1: ; (* BREAK-POINT IF USERSTOP *)
        UNTIL ALLOUTSPRODUCED OR STOPED;
        IF (NOT WASRESULT) THEN 
        BEGIN 
             IF STOPED
             THEN WRITELN('К СОЖАЛЕНИЮ, НЕ ДАЛИ ДОДУМАТЬ О ',TSUBJC)
             ELSE BEGIN 
                       WRITE('К СОЖАЛЕНИЮ, О ');
                       OUTWORD(TSUBJC); 
                       WRITELN(' НИЧЕГО СКАЗАТЬ НЕ МОГУ') 
                  END;
             WRITELN('МОЖЕТ БЫТЬ, ЕСТЬ СМЫСЛ УТОЧНИТЬ ОБСТАНОВКУ.') 
        END 
 END; 
 PROCEDURE QUERY; 
 LABEL
      1,2,3;
 VAR
    CURREC:INTEGER; 
    C:CHAR; 
    TSUBJC:INWORD;
    TSUBJR:INTEGER; 
    FOUND:BOOLEAN;
    WWB:INTEGER;
    WWR:INTEGER;
    WORDREC:WREC; 
    K:RKBASE; 
 BEGIN
      INITADD;
      READKB(1);
      SELECTKR(1,K);
      K.ACTIVE:=ACTLIMIT; 
      LOCATEKR(1,K);
      WRITEKB(1); 
      WRITELN('*** ЭКСПЕРТНЫЕ ЗАКЛЮЧЕНИЯ МАШИНЫ ***');
    2:; 
      WRITELN('    ПОЖАЛУЙСТА, ОПИШИТЕ ОБСТАНОВКУ. ДЛЯ ЭТОГО ВВОДИТЕ ФАКТЫ И УСЛОВИЯ'); 
      WRITELN('    КОНЕЦ ВВОДА - END ; ПОДСКАЗКИ - <ВК>');
      REPEAT
            ACTIVITYSTATUS:=ACTLIMIT; 
            OPERATOR(CURREC)
      UNTIL (CUROP = ENDWORD);
      WRITELN('*** ИТАК, ОБСТАНОВКА ОПИСАНА ***');
    3:; 
      WRITELN('    О ЧЕМ ВЫ ТЕПЕРЬ ЖЕЛАЕТЕ ПОЛУЧИТЬ ЭКСПЕРТНЫЕ ЗАКЛЮЧЕНИЯ ?');
    1:; 
      GETWORD;
      WHILE (CUROP = CRONLY) DO 
      BEGIN 
           WRITE('ПРЕДМЕТ:'); 
           GETWORD; 
           IF (CUROP = CRONLY) THEN 
           BEGIN
 WRITELN('ПРЕДМЕТ - ЭТО ИНТЕРЕСУЮЩИЙ ВАС ПРЕДМЕТ (СЛОВО)'); 
 WRITELN('НАПРИМЕР:     ГЛАДИОЛУС');
 WRITELN('ИЛИ     :     (СТАНОК 16K20)'); 
 WRITELN('ЕСЛИ ПЕРЕДУМАЛИ, ВВОДИТЕ END')
           END
      END;
      IF (CUROP=ENDWORD) THEN WRITELN('    А НАПРАСНО ВЫ НЕ ЗАХОТЕЛИ !')
                         ELSE 
      BEGIN 
           FINDWORD(CURWORD,TSUBJR,FOUND);
           TSUBJC:=CURWORD; 
           IF NOT FOUND THEN
           BEGIN
                WRITELN('К СОЖАЛЕНИЮ, СОВСЕМ НЕ ЗНАЮ ЭТОГО СЛОВА.');
                WRITE('ЗАДАЙТЕ, ПОЖАЛУЙСТА, ДРУГОЕ:');
                GOTO 1
           END; 
           WDIRECT(TSUBJR,WORDREC,WWB,WWR); 
           IF (WORDREC.ASSOCIATED = NULLREF) THEN 
           BEGIN
 WRITELN('К СОЖАЛЕНИЮ, ОБ ЭТОМ МНЕ НИЧЕГО, КРОМЕ НАЗВАНИЯ, НЕ ИЗВЕСТНО.');
 WRITE('ЗАДАЙТЕ, ПОЖАЛУЙСТА, ДРУГОЙ ПРЕДМЕТ:'); 
                GOTO 1
           END; 
           WRITE('ПОКАЗЫВАТЬ ХОД МЫСЛЕЙ ? '); 
           GETWORD; 
           WRITELN; 
           SHOW:=FALSE; 
           C:=CURWORD[1]; 
           IF (C='Д') OR (C='Y') OR (C='1') THEN SHOW:=TRUE;
           GETKNOWLEDGE(TSUBJC,TSUBJR); 
           WRITELN('*** ВСЕ ЭКСПЕРТНЫЕ ЗАКЛЮЧЕНИЯ ПОЛУЧЕНЫ ***'); 
           WRITE('*** ХОТИТЕ УТОЧНИТЬ ОБСТАНОВКУ ? ');
           GETWORD; 
           WRITELN; 
           C:=CURWORD[1]; 
           IF (C='Д') OR (C='Y') OR (C='1') THEN GOTO 2;
           WRITE('*** ХОТИТЕ ПОЛУЧИТЬ ЭКСПЕРТНЫЕ ЗАКЛЮЧЕНИЯ О ЧЕМ-ТО ДРУГОМ ? '); 
           GETWORD; 
           WRITELN; 
           C:=CURWORD[1]; 
           IF (C='Д') OR (C='Y') OR (C='1') THEN GOTO 3 
     END; 
 (*  WCLOSERANDOMFILE(WRANDOMFILE); 
     KCLOSERANDOMFILE(KRANDOMFILE)  RT-11 *)
     CLOSE(WRANDOMFILE.F);
     CLOSE(KRANDOMFILE.F) (* RSX-11 *)
 END; 
 PROCEDURE DETACH; EXTERNAL; (* RSX-11 CRT DETACHMENT *)
 (* M A I N   P R O G R A M  *) 
 BEGIN
      DETACH; 
      WRITELN('*  TEX V.M 0.3  *  ЭКСПЕРТНАЯ СИСТЕМА К ВАШИМ УСЛУГАМ  *  Т&P PRO, LTD');
      WRITELN;
      WRITE  ('***ИМЯ БАЗЫ ЗНАНИЙ:'); 
      GETWORD;
      WHILE (CUROP =CRONLY) DO
      BEGIN 
           WRITELN('ИМЯ БАЗЫ ЗНАНИЙ - ЭTО ИМЯ ФАЙЛА RSX-11 БЕЗ РАСШИРЕНИЯ.'); 
           WRITELN('НАПРИМЕР:         BASE1   SOBAKI    DP0:[5,2]SOBAKI');
           WRITELN('ЕСЛИ БАЗЫ ЕЩЕ НЕТ, ТО ВЫ СМОЖЕТЕ ЕЕ СОЗДАТЬ');
           WRITE  ('***  ИМЯ БАЗЫ ЗНАНИЙ:');
           GETWORD
      END;
      HPL:=6; 
      FOR ITERNUM:=1 TO 6 DO
      BEGIN 
           IF (CURWORD[ITERNUM]=' ') THEN HPL:=ITERNUM-1
      END;
      FOR ITERNUM:=1 TO 10 DO 
      BEGIN 
           BASEWDS[ITERNUM]:=' '; 
           BASEKDG[ITERNUM]:=' '
      END;
      FOR ITERNUM:=1 TO HPL DO
      BEGIN 
           BASEWDS[ITERNUM]:=CURWORD[ITERNUM];
           BASEKDG[ITERNUM]:=CURWORD[ITERNUM] 
      END;
      BASEWDS[HPL+1]:='.';
      BASEWDS[HPL+2]:='W';
      BASEWDS[HPL+3]:='D';
      BASEWDS[HPL+4]:='S';
      BASEKDG[HPL+1]:='.';
      BASEKDG[HPL+2]:='K';
      BASEKDG[HPL+3]:='D';
      BASEKDG[HPL+4]:='G';
      HPL:=1; 
    1:WRITELN;
      WRITELN('TEX V.M 0.3'); 
      WRITELN;
      WRITELN('    1 - ФОРМАТИЗАЦИЯ БАЗЫ ЗНАНИЙ');
      WRITELN('    2 - ОБУЧЕНИЕ МАШИНЫ         ');
      WRITELN('    3 - ПОЛУЧЕНИЕ СВЕДЕНИЙ ОТ МАШИНЫ');
      WRITELN('    4 - КОНЕЦ РАБОТЫ');
      WRITELN;
 (*   WRITE(CHR(16B));    RT-11 ONLY IN RUSSIAN DRIVER *) 
      WRITE('ЧТО ЖЕЛАЕТЕ? '); READLN(RUNTYP); 
      IF (RUNTYP < HPL) OR (RUNTYP > 4) THEN GOTO 1;
 (*   IF RUNTYP < 3 THEN
      BEGIN 
           WRITE('*** ПАРОЛЬ:');
           READLN(PASS);
           HPL:=2;
           IF PASS <> 'KISOCKASJ' THEN  GOTO 1; 
      END; *) 
      IF (RUNTYP <> 4) THEN 
      BEGIN 
          CASE RUNTYP OF
               1:FORMBASE;
               2:ADDBASE; 
               3:QUERY
          END;
          IF NOT EOF THEN GOTO  1 
      END;
      WRITELN('*** ДО СВИДАНИЯ ***'); 
 (*   WRITE (CHR(17B))  RT-11 ONLY IF RUSSIAN DRIVER *) 
 END. 
 