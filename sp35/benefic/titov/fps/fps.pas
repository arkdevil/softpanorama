 { PROGRAM FPS(INPUT,OUTPUT,ARCHIVE,OBJECT);        }
 {                                                                    }
 {       FIT PROBLEM SOLVER           RESEARCH STARTED AT ......08.86 }
 {                                    LAST CHANGE AT      ......05.88 }
 {                                                                    }
 {
    THIS IS THE IN-LINE-SYNTAX OF FPS.
    __________________________________
                                                                 ...
 <PROGRAM>=<MODEL> [ ! [ <ACTIONS> [ ? ] ] ] <END-OF-FILE>
 <MODEL>  =<OPERATOR> [; ...]
 <OPERATOR> = <MODEL DESCRIPTOR> !  <RELATION> ! <DIRECTIVE>
 <MODEL DESCRIPTOR> = MODEL <SIMPLENAME> ( <MODEL> )
                      ! MODEL <SIMPLENAME> IS [ <COPY> [, ...] ]
                      ! REAL  <SIMPLENAME>    [, ...]
                      ! INTEGER <SIMPLENAME>  [, ...]
                      ! BOOLEAN <SIMPLENAME>  [, ...]
                      ! CHAR  <SIMPLENAME> <INTEGER>  [, ...]
<COPY> = <NAME> = <NAME>
<RELATION> = MODULE [ $ <INTEGER> ] <SIMPLENAME>
                    [ IN <NAME> [, ...] ]
                     OUT <NAME> [, ...]
            ! EQN   [ $ <INTEGER> ]
                    <SIMPLE EXPRESSION> = <SIMPLE EXPRESSION>
            ! LET   [ $ <INTEGER> ]
                    <NAME>              = <EXPRESSION>
<DIRECTIVE> = SAVE <NAME> [, ... ] ! USE <NAME> [ <COPY>[, ...] ]
            ! SOLVE <NAME> USING <SIMPLENAME>
            ! FD ! FDS ! HD ! HDS ! MAP
            ! FORMARCH ! OLDARCH ! ACTIONS ! ORIGIN
<ACTIONS> = <ACT OPERATOR> [; ... ]
<ACT OPERATOR> = <PASCAL OPERATOR> WHERE POSSIBLE PROCEDURE BODY
 IS FOLLOWING:   COMPUTE <NAME> [, ...]  [ FROM <NAME> [, ...] ]

 THE "ACTIONS" DIRECTIVE MAY BE USED INSTEAD OF "!" AS MODEL'S
 DELIMITER (LOOK CHAPT.1 OF THIS SYNTAX).
....................................................................
NOTE:
-----     1. EXPRESSIONS - AS IN WIRTH'S PASCAL  B U T
             "NOT" IS NOT SUPPORTED.
          2. +-TERM  ONLY AS  (+-TERM).
          3. SCALAR CONSTS (AS "TRUE","NIL") , "DIV" , "MOD" ARE
             NOT SUPPORTED.
    }
 CONST
     {  ---------------------------------------------- }
     {    THE MOST IMPORTANT CONSTANTS                 }
     {  ---------------------------------------------- }
      NAMELENGTH=8;     {  MAX LENGTH OF SIMPLE NAME }
      VERSION='88-05/2.0H   ';  {  SOURCE/OBJECT OF THIS TEXT }
      VERSLENGTH=14;    {  "VERSION" STRING LENGTH   }
      LINELENGTH=72;    {  OBJ. LINE LENGTH IS LINELENGTH + 8 }
      PAGESIZE=72;      {  FOR PRINTER DENSITY = 6   }
      ENAME='EXTERNAL'; {  EXTRN PROCS BODY- ONLY 8 CHARS NOT < NOT > }
      MYANAME='00000000'; {  INTERNAL ARCHIVE NAME- CHANGE IF ARCHIVE }
                          {  STRUCTURE IS GHANGED IN THIS VERSION     }
      {  DUPLEX TYPE & EXCHANGE  OPTION - LOOK "INITIAL" PROCEDURE }
      ORIGIN1='     ПEPECMOTPEHHЫЙ BAPИAHT ППП "ПPИЗ"(ИK AH ЭCCP)'  ;
      ORIGIN2='     ABTOP ЭTOГO BAPИAHTA:'                          ;
      ORIGIN3='                 A. A. TИTOB    KИPOBOГPAД   УCCP'   ;
      ORIGIN4='     KИPOBOГPAДCKИЙ ИHCTИTУT C/X MAШИHOCTPOEHИЯ     ';
      ORIGIN5='     TEЛ. PAБ. 93-9-28  - A.A.TИTOB   (PAЗPAБOTЧИK)' ;
      ORIGIN6='                                                    ';
      ORIGIN7='     EXPORT   >                                   <';

     {  ---------------------------------------------- }
     {   THE ARCHIVE-MANAGEMET (AMG) TYPE SEGMENT      }
     {  ---------------------------------------------- }
 TYPE
     HDRTYPE=(FIRSTINFILE,STARTOFKNOT,REFERENCE,LASTINMODEL,PARAMETER);
     FACTION=(FRESET,FREWRITE);
     FNAME=(FINPUT,FOUTPUT,FOBJECT);
     REFTYPE=(INLINK,OUTLINK);
     LINKMEMB=@LNK;
     LNK=RECORD
               LINKTYPE:REFTYPE;
               LINKVALUE:INTEGER;
               FROMVALUE:INTEGER;
               NEXT:LINKMEMB
         END;
     {  ---------------------------------------------- }
     {   THE MODEL-BUILDER (MDB) TYPE SEGMENT          }
     {  ---------------------------------------------- }
     TKNOT=(VARK,RELK,HEADERK);
     MODLINK=(EXTRN,USERPLACED);
     SUBTKNOT=(REALK,INTEGERK,BOOLEANK,CHARK,STRUCTUREK,
               MODULEK,EQNK,LETK);
     LINE=PACKED ARRAY [ 1..LINELENGTH ] OF CHAR;
     NAMEOBJ=PACKED ARRAY [ 1..NAMELENGTH ] OF CHAR;
     PTEXTRN=@EXTRND;
     EXTRND=RECORD
                 NAME:NAMEOBJ;
                 STMTNUM:INTEGER;
                 NEXT:PTEXTRN
           END;
     PTKNOT=@KNOT;
     PTLISTMEMB=@LISTMEMB;
     LISTMEMB=RECORD
                    NEXT:PTLISTMEMB;
                    TARGET:PTKNOT
              END;
     KNOT=RECORD
                NAME:NAMEOBJ;
                ORDVALUE:INTEGER;
                NEXT:PTKNOT;
                PTOWNER:PTKNOT;
                PTILIST:PTLISTMEMB;
                PTOLIST:PTLISTMEMB;
                KNOTTYPE:TKNOT;
                KNOTSUBTYPE:SUBTKNOT;
                {                 }
                {  "RELK" SEGMENT }
                {  -------------- }
                COST:INTEGER;
                RELSTRING:LINE;
                FIRSTPARM:PTLISTMEMB;
                MODULENAME:NAMEOBJ;
                MODULELOC:MODLINK;
                {                 }
                {  "VARK" SEGMENT }
                {  -------------- }
                PTMEMBLIST:PTLISTMEMB;
                LENGTH:INTEGER;
                {                    }
                {  "HEADERK" SEGMENT }
                {  ----------------- }
                HDRNAME:HDRTYPE;
                GENERATION:INTEGER;   {  IN *ALG* IS CALL NUMBER }
                NAMEOFNEXT:NAMEOBJ;
                ORDNUMOFOWNER:INTEGER;
                LINKTYPE:REFTYPE;
                LINKVALUE:INTEGER;
                APPLICATED:BOOLEAN;
                KEPT:BOOLEAN;
                TRYED:BOOLEAN
           END;
 PTEXTREF=@EXTREF;
 EXTREF=RECORD
             YOTYPE:REFTYPE;
             KNOTFROM:PTKNOT;
             OLDKNOT :PTKNOT;
             LISTMEMB:PTLISTMEMB;
             NEXT:PTEXTREF
        END;
     {  -------------------------------------------- }
     {     THE SYNTAX-ANALYZER   T Y P E   SEGMENT   }
     {  -------------------------------------------- }
     LINK=@ZUCK;
     ZUCK=RECORD
                 CURPOS:INTEGER;
                 ERRCODE:INTEGER;
                 NEXT:LINK
          END;
     LEXEMA=(BADLEX,IS,AREAL,AINTEGER,ABOOLEAN,AORIGIN,AACTIONS,
             AUSE,AOR,AAND,SAVE,SOLVE,AMODEL,AFROM,
             USING,HDT,FDT,HD,FD,MAP,
             ACHAR,MODULE,EQN,LET,AIN,OUT);
     IOTYPE=(FULL,HALF);

     {  ----------------------------------------------------------- }
     {            THE ALGORITHM-GENERATOR VAR  SEGMENT              }
     {  ----------------------------------------------------------- }
 VAR
     OBJECT:TEXT;      {  OBJECT FILE FOR GENERATED PASCAL PROGRAM }
     WORD:PACKED ARRAY [ 1..9 ] OF CHAR; {  PASCAL PROGRAM WORD  }
     OBJPOS:INTEGER;   {  POS. IN OUTPUT PASCAL CARD FORMING }
     VARSGENERATED:BOOLEAN; {  TRUE IF VARS ALRDY BE GENERATED }
     MUSTBEVARS:   BOOLEAN; {  TRUE IF VARS MUST BE GENERATED }
     RESLIST:PTLISTMEMB;    {  COMPUTE RESULT LIST POINTER    }
     DATALIST:PTLISTMEMB;   {  COMPUTE DATA   LIST POINTER    }
     SOLVED:BOOLEAN;      {  TRUE IF TASK IS SOLVED       }
     BOSS:PTKNOT;           {  OWNER OF ALL HIGHEST-LEV.MODELS}
     ALLTRYED:BOOLEAN;      {  TRUE IF ALL RELS BE TESTED BY SOLV. }
     RELCOUNT:INTEGER;      {  DEFINES ORDER OF REL-CALLS IN ALGOR.}
     OBJSHIFT:INTEGER;      {  NUM OF BLANCS BEFORE PASCAL LINE    }
     PASCLINES:INTEGER;     {  NUM OF GENERATED  PASCAL LINES      }
     PREVOBJCHAR:CHAR;      {  PREVIOUS OBJECT CHAR                }
     WASEOLNOBJECT:BOOLEAN; {  DOUBLE SPACING PROOF                }
     {  DEBUG }  DEBUG:BOOLEAN;
     {  ---------------------------------------------- }
     {      THE   M D B   VAR SEGMENT                  }
     {  ---------------------------------------------- }
     PASSING:BOOLEAN;  {  TRUE IF CURRENT CHAR BE PASSED }
                       {  TO MODEL-BUILDER BY "PASS" PROC}
     EXPRPASS:BOOLEAN; {  TRUE IF CURRENT CHAR BE PASSED }
                       {  TO MODEL-BUILDER BY "EPASS" PROC }
     NAMETEXT:NAMEOBJ; {  DEFINES CURRENT NAMETEXT WHICH }
                       {  BUILDS IN "PASS" PROCEDURE     }
     EXPRTEXT:LINE;    {  AS PREVIOUS. THIS NAMETEXT BUILDS }
                       {  IN "EXPRPASS" PROCEDURE TO PASSING }
                       {  THE TEXT OF CURRENT EXPRESSION.    }
     IPASS:INTEGER;    {  CURRENT POS. IN THIS NAMETEXT  }
     IEPASS:INTEGER;   {  CURRENT POS. IN THIS "EXPRTEXT"}
     INNAMEINEXPRESSION:BOOLEAN; {  TRUE IF THEM AND IF IN MODULE }
     FIRSTEXTRN:PTEXTRN; {  POINTER TO 1ST EXTRN-NAME LIST ELEMENT }
     OPNAME:NAMEOBJ;
     OPCOST:INTEGER; {  COST OF CURRENT "REL" OPERATOR }
     LOWLEVELKNOT: PTKNOT;
                     {  LOW KNOT IN N.N. ....           }
     PTCURKNOT:PTKNOT; {  REF. TO CUR. KNOT  }
     FIRSTKNOT:PTKNOT; {  REFER. TO HEAD OF COMMON KNOTLIST }
                       {  NAME OF CURRENT OPERATOR       }
     CURRENTOWNER:PTKNOT;
                       {  REF. TO OWNER OF CURRENT OP.   }
     DIGARRAY:ARRAY [ '0'..'9' ] OF INTEGER;
                       {  CONTAINS CORRESPONDING DIGITS  }
     FIRSTMEMBER:PTLISTMEMB;
                 {  REF TO FIRST MEMB OF EACH LIST FORMING BY }
                 {  "ATTACHNAME" PROCEDURE.                   }
     SGNPOS:INTEGER; {  POS OF CUR.CHAR IN SYSGEN NAME }
     SGNCHARNUMBER:INTEGER; {  NUMBER OF CHAR IN SGN NAME }
     UNICALNAME:NAMEOBJ; {  SGN NAME }
     REFLEFT:PTKNOT;     {  REF TO LEFT PART OF "LET" OR "GIVEN" }
     PKBECHANGED:PTKNOT; {  REF TO SUBMODEL IS TO BE CHANGED     }
     MEMPKBECHANGED:PTLISTMEMB; {  REF TO HIS MEMBER-DESCRIPTOR  }
     FIRSTBAD:PTEXTREF;     {  REF TO KNOTS LIST DUE WHICH THE   }
                            {  MODEL IS UNLOADABLE               }
     YPTR:PTKNOT;           {  REF TO Y IN "MODEL A IS B X=Y"    }
     ERR1520:(IGNORE,WORKUP);
                         {  *** ERROR 1520 *** IS "HIGHEST LEVEL }
                         {  NAME IS NOT FOUND". IF WE ARE IN EX- }
                         {  PRESSION, THIS ERR MUST BE IGNORED   }
                         {  BECAUSE IT MAY BE THE EXTERNAL FUNC- }
                         {  TION NAME. CHECKING -IN "FINDMEMB".  }
     {  ---------------------------------------------------- }
     {        THE SYNTAX-ANALYZER  V A R   SEGMENT           }
     {  ---------------------------------------------------- }
     FIRSTZUCK:LINK;
     CURCHAR:CHAR;    {  CURRENT CHAR OF SCANNER }
     CURPOS:INTEGER;  {  CURRENT POSITION - POS. OF CURCHAR }
     BUFCHAR:CHAR;    {  BUFFER SYMBOL BECAUSE ONLY GOFORWARD }
     BL:BOOLEAN;      {  WORK }
     BD:BOOLEAN;      {  WORK }
     FROMBUFCHAR:BOOLEAN;       {  WHERE IS NEXT SYMBOL     }
     CURLEX:LEXEMA;   {  CURRENT LEXEMA OF SCANNER }
     WASBADOPERATOR:BOOLEAN; {  TRUE IF LAST SCANNED OP. IS BAD }
     COMPLETE:BOOLEAN; {  TRUE IF LAST OPERATOR IS SCANNED  }
                       {  UNTIL ';'                         }
     TERMINAL:BOOLEAN; {  IS THE INPUT DEVICE CRT }
     DUPLEX:IOTYPE;      {  INPUT CRT TRANSMIT TYPE }
     DIGIT:BOOLEAN;   {  TRUE IF CURCHAR IN '0'..'9' }
     LETTER:BOOLEAN;  {  TRUE IF CURCHAR IN 'A'..'Z' }
     SIMILAR:BOOLEAN; {  TRUE IF IN BOTH PREVIOUS    }
    {  NOTE: PREV. 3 VARS NEEDED IN PASCAL-8000 AAEC DUE TO THIS }
    {  COMPILER NOT SUPPORTS 'C'..'D',['X','Y']  CONSTRUCTIONS }
    WASEOLN:BOOLEAN;
    WASEOF: BOOLEAN;
    WASLINESEPARATOR:BOOLEAN;
    OPNUMBER:INTEGER; {  NUM OF CURRENT OPERATOR }
    LINECOUNT:INTEGER; {  FOR PAGE SEPARATING  }
    PAGECOUNT:INTEGER;
    SUBTITLE:PACKED ARRAY [ 1..24 ] OF CHAR;
    ERRCOUNT:INTEGER;
    OBJCOUNT:INTEGER;  {  NUMBER OF KNOTS IN THE MODEL-NET. }
    INMODULE:BOOLEAN;  {  TRUE IF WE ARE IN MODULE          }
    INEXPRESSION:BOOLEAN; {  TRUE IF WE ARE IN EXPRESSION   }
    INSHABLON:BOOLEAN;    {  TRUE IF WE ARE IN SHABLON               }
    PROMPTSKIP:INTEGER;   {  NUM OF BLANCS BE DISPLAYED BEFORE KEYIN }
    INACTIONS: BOOLEAN;   {  TRUE IF WE ARE IN "ACTIONS" PART        }
     {  ------------------------------------------------- }
     {           THE   A M G   VAR SEGMENT                }
     {  ------------------------------------------------- }
 FIRSTSAVE:PTLISTMEMB; {  FIRST SAVE-REQUEST LIST ELEMENT }
 ARCHIVE :FILE OF KNOT;
 ENDOFARCHIVE:BOOLEAN; {  EOF IN CURRENT ARCHIVE OCCURS   }
                       {  DURING READ FILE IN "AMGPROCESS"}
 CURROOT     :PTKNOT;  {  POINTER TO THE ROOT OF CUR. PROTOTYPE    }
 FIRSTLINK   :LINKMEMB;{  FIRST IN I/O LINKS LIST OF PROTOTYPE     }
 FIRSTPLINK  :LINKMEMB;{  FIRST IN PARAMETER LINK LIST             }
 LASTPLINK   :LINKMEMB;{  LAST  IN PARAMETER LINK LIST             }
 MINORD      :INTEGER; {  MIN ORD NUM. OF INLOADED MODEL COMPONENTS}
 MAXORD      :INTEGER; {  MAX ORD NUM. OF INLOADED MODEL COMPONENTS}
 COMPOUNDNAME:BOOLEAN; {  IF CURR. NAME IS COMPOUND THEN TRUE      }
 FIRSTINLOADED:PTKNOT;{  1ST INLOADED KNOT POINTER }
 HEADER      :PTKNOT; {  KNOT FOR HEADERS - DINALLOC IN AMGINIT }
 GFIRSTPARM:PTLISTMEMB; {  REF TO FIRST PARM DESCRIPTION }
 FILENAME:  PACKED ARRAY[ 1 .. 12 ] OF CHAR; {  ARCHIVE FILE NAME }
 GLASTPARM: PTLISTMEMB; {  REF TO LAST  PARM DESCRIPTION }
     {  ------------------------------------------------- }
     {     THE   SYSTEM-DEPENDENT PROCEDURE SEGMENT       }
     {  ------------------------------------------------- }
     PROCEDURE DETACH;EXTERNAL;
     PROCEDURE BUILDFILENAME(NAMETEXT:NAMEOBJ);
     VAR
        I:INTEGER;
        J:INTEGER;
     BEGIN
          I:=1;
          WHILE (I<=NAMELENGTH) AND (NAMETEXT[ I ] <> ' ') DO
          BEGIN
               FILENAME[ I ]:=NAMETEXT[ I ];
               I:=I+1;
          END;
          FILENAME[ I ]:='.';
          FILENAME[ I+1 ]:='F';
          FILENAME[ I+2 ]:='R';
          FILENAME[ I+3 ]:='A';
          FOR J:=I+4 TO 12 DO FILENAME[ J ]:=' '
     END;
 PROCEDURE SETFILEIN(NAMETEXT:NAMEOBJ);
 BEGIN
      BUILDFILENAME(NAMETEXT);
      RESET(ARCHIVE,FILENAME)
 END;
 PROCEDURE SETFILEOUT(PK:PTKNOT);
 BEGIN
      BUILDFILENAME(PK@.NAME);
      REWRITE(ARCHIVE,FILENAME)
 END;
 PROCEDURE FINDMODEL(NAMETEXT:NAMEOBJ; VAR PRESENT:BOOLEAN);
 {  NOW IS DUMMY }
 BEGIN
       PRESENT:=TRUE
 END;
     PROCEDURE OPENCLOSE(OPERATION:FACTION;FILENAME:FNAME);
     BEGIN
          CASE OPERATION OF
          FRESET:CASE FILENAME OF
          FINPUT:BEGIN
                      DETACH;
                      RESET(INPUT,'INPUT.FPS');
                 END;
          FOUTPUT:;
          FOBJECT:    RESET(OBJECT,'OBJECT.PAS');
                 END;
        FREWRITE:CASE FILENAME OF
        FINPUT:;
        FOUTPUT:       REWRITE(OUTPUT,'OUTPUT.FPS');
        FOBJECT: REWRITE(OBJECT,'OBJECT.PAS');
                 END
          END
     END;
     {  ------------------------------------------------- }
     {     THE   M D B   PROCEDURE SEGMENT                }
     {  ------------------------------------------------- }
     PROCEDURE ENDNAME;FORWARD;
     PROCEDURE EXPROFF;FORWARD;
     PROCEDURE CONVCI(STRING:LINE;VAR IRESULT:INTEGER);FORWARD;
     PROCEDURE MDBMDL7;FORWARD;
     PROCEDURE INSERT(PT:PTKNOT);FORWARD;
     PROCEDURE ERROR(ERRCODE:INTEGER);FORWARD;
     PROCEDURE SHOOKNAME(NAME:NAMEOBJ;VAR PRESENT:BOOLEAN);FORWARD;
     PROCEDURE SHOOKINALL(NAME:NAMEOBJ;VAR PRESENT:BOOLEAN);FORWARD;
     PROCEDURE BUILDIN;FORWARD;
     PROCEDURE BUILDOUT;FORWARD;
     PROCEDURE PRINTTITLE;FORWARD;
     PROCEDURE MDBMDL3;FORWARD;
     PROCEDURE MDBMDL4;FORWARD;
     PROCEDURE MDBMDL5;FORWARD;
     PROCEDURE GETNAME;FORWARD;
     PROCEDURE GETCOST;FORWARD;
     PROCEDURE GETMODULE;FORWARD;
     PROCEDURE ATTACHNAME;FORWARD;
     PROCEDURE MDBMDL8;FORWARD;
     PROCEDURE MDBMDL9;FORWARD;
     PROCEDURE CHECKEXTREF(PT:PTKNOT;VAR UNLOADABLE:BOOLEAN);FORWARD;
     PROCEDURE BUILDCOPY(PROTOTYPE:PTKNOT;VAR HEAD:PTKNOT);FORWARD;
 PROCEDURE INITMDB;
 {  THE MODEL-BUILDER INITIALIZATION }
 BEGIN
      ERR1520:=WORKUP;
      FIRSTEXTRN:=NIL;
      INMODULE:=FALSE;
      INSHABLON:=FALSE;
      INNAMEINEXPRESSION:=FALSE;
      EXPRPASS:=FALSE;
      PASSING:=FALSE;
      IPASS:=1;
      FIRSTKNOT:=NIL;
      CURRENTOWNER:=NIL;
      UNICALNAME:='&       ';
      SGNPOS:=2;
      SGNCHARNUMBER:=ORD('A');
      {  FORM SERVICE ARRAY FOR "CONVCI" PROCEDURE }
      DIGARRAY[ '0' ]:=0;
      DIGARRAY[ '1' ]:=1;
      DIGARRAY[ '2' ]:=2;
      DIGARRAY[ '3' ]:=3;
      DIGARRAY[ '4' ]:=4;
      DIGARRAY[ '5' ]:=5;
      DIGARRAY[ '6' ]:=6;
      DIGARRAY[ '7' ]:=7;
      DIGARRAY[ '8' ]:=8;
      DIGARRAY[ '9' ]:=9;
 END;
 PROCEDURE GENUNICAL;
 {  GENERATE NEXT SGN NAME }
 BEGIN
      IF SGNCHARNUMBER = ORD('Z')+1 THEN
      BEGIN
           SGNPOS:=SGNPOS+1;
           SGNCHARNUMBER:=ORD('A')
      END;
      IF SGNPOS = 9 THEN SGNPOS:=2;
      UNICALNAME[ SGNPOS ]:=CHR(SGNCHARNUMBER);
      SGNCHARNUMBER:=SGNCHARNUMBER+1;
 END;
 PROCEDURE GENOPNAME;
 {  GENERATE NEXT SGN NAME & LOCATE IT INTO OPNAME }
 BEGIN
      GENUNICAL;
      OPNAME:=UNICALNAME
 END;
 PROCEDURE PAUSE;
 VAR C:CHAR;
 BEGIN
       WRITELN;
       WRITELN(
 '                                           TO CONTINUE PRESS "RETURN"'
              );
       READ (C);
       IF NOT EOF(INPUT) THEN READ(C);
       WRITELN
 END;
 PROCEDURE MAPPING;
 {  DEBUGGING PROC FOR MAPPING THE MODEL GRAPH-STRUCTURE }
 VAR
    CURKNOT:PTKNOT;
    CURMEMB:PTLISTMEMB;
 PROCEDURE WRITEORD(ORD:INTEGER);
 BEGIN
      WRITE(' ORD.NUM:');
      WRITELN(ORD:4)
 END;
 PROCEDURE WRITPARMS(FIRSTPARM:PTLISTMEMB);
 VAR
    CURPARM:PTLISTMEMB;
 BEGIN
      WRITELN(' PARAMETER LIST IS FOLLOWS:');
      CURPARM:=FIRSTPARM;
      WHILE CURPARM <> NIL DO
      BEGIN
           WRITE(' <-> ');
           WRITE(CURPARM@.TARGET@.NAME);
           WRITEORD(CURPARM@.TARGET@.ORDVALUE);
           CURPARM:=CURPARM@.NEXT
       END
 END;
 BEGIN
      IF FIRSTKNOT=NIL THEN ERROR(0)
                       ELSE
      BEGIN
           WRITELN;
           SUBTITLE:='MODEL MAP               ';
           PRINTTITLE;
           CURKNOT:=FIRSTKNOT;
           REPEAT
                 WITH CURKNOT@ DO
                 BEGIN
                      WRITELN;
                      WRITE(' NAME:');WRITE(NAME);
                      IF PTOWNER=NIL
                         THEN WRITE('-DEFINED AT HIGHEST LEVEL,')
                         ELSE BEGIN
                                   WRITE(' OWNER:');
                                   WRITE(PTOWNER@.NAME)
                              END;
                      IF NEXT=NIL
                         THEN WRITE(' LAST,')
                         ELSE BEGIN
                                   WRITE(' NEXT:');
                                   WRITE(NEXT@.NAME)
                              END;
                      WRITEORD(ORDVALUE);
                      IF PTILIST=NIL
                         THEN WRITELN(' NO (IN) REFERENCES')
                         ELSE
                             BEGIN
                                  WRITELN(' (IN) REFERENCES FOLLOWS:');
                                  CURMEMB:=PTILIST;
                                  REPEAT
                                        WRITE(' <-- ');
                                        WRITE(CURMEMB@.TARGET@.NAME);
                                 WRITEORD(CURMEMB@.TARGET@.ORDVALUE);
                                        CURMEMB:=CURMEMB@.NEXT
                                  UNTIL CURMEMB=NIL
                             END;
                         IF PTOLIST=NIL
                         THEN
                                  WRITELN(' NO (OUT) REFERENCES')
                         ELSE
                             BEGIN
                                  WRITELN(' (OUT) REFERENCES FOLLOWS:');
                                  CURMEMB:=PTOLIST;
                                  REPEAT
                                        WRITE(' --> ');
                                        WRITE(CURMEMB@.TARGET@.NAME);
                                   WRITEORD(CURMEMB@.TARGET@.ORDVALUE);
                                        CURMEMB:=CURMEMB@.NEXT
                                  UNTIL CURMEMB=NIL
                             END;
                          CASE KNOTTYPE OF
 RELK: BEGIN
            WRITE(' TYPE=REL');
            WRITE(' COST=');WRITE(COST:4);
            WRITELN;
 {  DEBUG    IF DEBUG THEN BEGIN
                WRITE(' *DEBUG* CALL-NUMBER=');WRITE(GENERATION:4);
                IF APPLICATED THEN WRITE('   APPLICATED');
                IF TRYED      THEN WRITE('   TRYED');
                IF KEPT       THEN WRITE('   KEPT');
                WRITELN;
                           END;   }
            CASE KNOTSUBTYPE OF
            EQNK:BEGIN
                      WRITELN(' ZEROEXPRESSION IS FOLLOWS:');
                      WRITE(' ');
                      WRITELN(RELSTRING);
                      WRITPARMS(FIRSTPARM)
                 END;
            LETK:BEGIN
                      WRITELN(' RIGHT PART OF ASSIGNMENT IS FOLLOWS:');
                      WRITE(' ');
                      WRITELN(RELSTRING)
                 END;
        MODULEK: BEGIN
                      WRITE(' MODULE NAME IS ');
                      WRITELN(MODULENAME);
                      WRITPARMS(FIRSTPARM);
                 END
            END;
      END;
 VARK:BEGIN
           WRITE(' TYPE=VAR');
           CASE KNOTSUBTYPE OF
           REALK:WRITELN(' SUBTYPE=REAL');
        INTEGERK:WRITELN(' SUBTYPE=INTEGER');
        BOOLEANK:WRITELN(' SUBTYPE=BOOLEAN');
        CHARK:   BEGIN
                      WRITE(' SUBTYPE=CHAR');
                      WRITE(' LENGTH=');
                      WRITE(LENGTH:4);
                      WRITELN
                 END;
      STRUCTUREK:BEGIN
                      WRITELN(' SUBTYPE=STRUCTURE');
                      WRITELN(' MEMBERS ARE FOLLOWS:');
                      CURMEMB:=PTMEMBLIST;
                      REPEAT
                            WRITE(' --- ');
                            WRITE(CURMEMB@.TARGET@.NAME);
                            WRITEORD(CURMEMB@.TARGET@.ORDVALUE);
                            CURMEMB:=CURMEMB@.NEXT
                      UNTIL CURMEMB=NIL
                  END
           END
      END
                            END
                 END;
           CURKNOT:=CURKNOT@.NEXT;
           IF TERMINAL AND (NOT EOF(INPUT)) AND (CURKNOT <> NIL)
           THEN PAUSE
           UNTIL CURKNOT=NIL;
           SUBTITLE:='SOURCE MODEL LISTING    ';
           PRINTTITLE
      END
 END;
 PROCEDURE ADDEXTRN;
 {  ADD THE NAME INTO THE EXTERNAL FUNCTION NAME LIST }
 VAR
    I:INTEGER;
    EXTELEM:PTEXTRN;
 BEGIN
      NEW(EXTELEM);
      WITH EXTELEM@ DO
      BEGIN
           FOR I:=1 TO NAMELENGTH DO NAME[ I ]:=NAMETEXT[ I ];
           STMTNUM:=OPNUMBER
      END;
      EXTELEM@.NEXT:=FIRSTEXTRN;
      FIRSTEXTRN:=EXTELEM
 END;
 PROCEDURE CHECKP(FIRST:PTLISTMEMB;VERIFYING:PTKNOT;
                  VAR PRESENT:BOOLEAN);
 {  IS THE "VERIFYING" KNOT PRESENT IN THE "FIRST" 'S LIST }
 VAR
    CURRENT:PTLISTMEMB;
 BEGIN
      PRESENT:=FALSE;
      CURRENT:=FIRST;
      WHILE (CURRENT <> NIL) AND (NOT PRESENT) DO
      BEGIN
           IF CURRENT@.TARGET = VERIFYING THEN PRESENT:=TRUE;
           CURRENT:=CURRENT@.NEXT
      END
 END;
 PROCEDURE CHECKPNAME(FIRST:PTLISTMEMB;VERIFYING:NAMEOBJ;
                  VAR PRESENT:BOOLEAN);
 {  IS THE "VERIFYING" KNOT PRESENT IN THE "FIRST" 'S LIST }
 VAR
    CURRENT:PTLISTMEMB;
 BEGIN
      PRESENT:=FALSE;
      CURRENT:=FIRST;
      WHILE (CURRENT <> NIL) AND (NOT PRESENT) DO
      BEGIN
           IF CURRENT@.TARGET@.NAME = VERIFYING THEN PRESENT:=TRUE;
           CURRENT:=CURRENT@.NEXT
      END
 END;
 PROCEDURE CHECKUSE;
 {  ERR IF ONE CURROOT"S MEMBER ALRDY PRESENT IN CURRENTOWNER"S MEMBS }
 VAR
    CURKNOT:PTKNOT;
    CNEW:PTLISTMEMB;
    COLD:PTKNOT;
    ERR:BOOLEAN;
 BEGIN
      IF (CURROOT@.KNOTTYPE = VARK)
                 AND
         (CURROOT@.KNOTSUBTYPE = STRUCTUREK)
      THEN
      BEGIN
      ERR:=FALSE;
      CNEW:=CURROOT@.PTMEMBLIST;
      WHILE (CNEW <> NIL) AND (NOT ERR) DO
      BEGIN
           COLD:=FIRSTKNOT;
           WHILE (COLD <> NIL) AND (NOT ERR) DO
           BEGIN
                IF (
                   (COLD@.PTOWNER = CURRENTOWNER)
                                 AND
                   (COLD@.NAME = CNEW@.TARGET@.NAME )
                   )
                THEN ERR:=TRUE;
                COLD:=COLD@.NEXT;
           END;
           CNEW:=CNEW@.NEXT;
      END;
      IF ERR THEN ERROR(101);
      END
      ELSE ERROR(140)
 END;
 PROCEDURE SHOOKHIGH(NAME:NAMEOBJ;VAR PRESENT:BOOLEAN);
 {  SHOOK OBJECT INTO HIGHEST MODEL LEVEL }
 VAR
     CURKNOT:PTKNOT;
  BEGIN
          LOWLEVELKNOT:=NIL;
          PRESENT:=FALSE;
          CURKNOT:=FIRSTKNOT;
          WHILE (CURKNOT <> NIL) AND (NOT PRESENT) DO
          BEGIN
               IF (CURKNOT@.NAME = NAME) AND (CURKNOT@.PTOWNER = NIL)
               THEN
               BEGIN
                     PRESENT:=TRUE;
                     LOWLEVELKNOT:=CURKNOT
               END;
               CURKNOT:=CURKNOT@.NEXT
          END
 END;
 PROCEDURE SHOOKNAME;
 {         (NAME:NAMEOBJ;VAR PRESENT:BOOLEAN) - "FORWARD" }
 {  SHOOK THE NAME AT THE CURRENT MODEL LEVEL }
 VAR CURMEMB:PTLISTMEMB;
     CURKNOT:PTKNOT;
 BEGIN
      PRESENT:=FALSE;
      LOWLEVELKNOT:=NIL;
      IF CURRENTOWNER = NIL
      THEN  SHOOKHIGH(NAME,PRESENT)
      ELSE
      BEGIN
           CURMEMB:=CURRENTOWNER@.PTMEMBLIST;
           WHILE (CURMEMB <> NIL) AND (NOT PRESENT) DO
           BEGIN
                IF CURMEMB@.TARGET@.NAME = NAME THEN
                BEGIN
                     PRESENT:=TRUE;
                     LOWLEVELKNOT:=CURMEMB@.TARGET
                END;
                CURMEMB:=CURMEMB@.NEXT
           END
       END
 END;
 PROCEDURE INSERT;
          {  (PT:PTKNOT) - "FORWARD" }
 {  ADD NEW KNOT TO COMMON KNOT-LIST }
 VAR
    PTLSTM:PTLISTMEMB;{  REF TO NEW MEMBER LIST ELEMENT }
 BEGIN
      {  ADD TO HEAD OF COMMON LIST }
      PT@.NEXT:=FIRSTKNOT;
      FIRSTKNOT:=PT;
      OBJCOUNT:=OBJCOUNT+1;
      PT@.ORDVALUE:=OBJCOUNT;
      {  ADD TO CURRENT OWNER'S MEMBER-LIST - TO HEAD }
      IF CURRENTOWNER <> NIL THEN
      BEGIN
           NEW(PTLSTM);
           PTLSTM@.TARGET:=PT;
           PTLSTM@.NEXT:=CURRENTOWNER@.PTMEMBLIST;
           CURRENTOWNER@.PTMEMBLIST:=PTLSTM;
      END
 END;
 PROCEDURE CATSEQ(VAR FIRSTKNOT:PTKNOT);
 {  ADD ALL FIRSTINLOADED"S SEQUENCE TO HEAD OF FIRST"S LIST }
 VAR
    SNEXT:PTKNOT;
    CURINLOADED:PTKNOT;
 BEGIN
      CURINLOADED:=FIRSTINLOADED;
      WHILE  CURINLOADED <> NIL DO
      BEGIN
           SNEXT:=CURINLOADED@.NEXT;
           CURINLOADED@.NEXT:=FIRSTKNOT;
           FIRSTKNOT:=CURINLOADED;
           CURINLOADED:=SNEXT
      END
 END;
 PROCEDURE INSERTTREE(PT:PTKNOT);
 {  ADD NEW KNOT TO COMMON KNOT-LIST }
 VAR
    PTLSTM:PTLISTMEMB;{  REF TO NEW MEMBER LIST ELEMENT }
 BEGIN
      {  ADD TO HEAD OF COMMON LIST }
      PT@.NAME:=OPNAME;
      PT@.PTOWNER:=CURRENTOWNER;
      CATSEQ(FIRSTKNOT);
      {  ADD TO CURRENT OWNER'S MEMBER-LIST - TO HEAD }
      IF CURRENTOWNER <> NIL THEN
      BEGIN
           NEW(PTLSTM);
           PTLSTM@.TARGET:=PT;
           PTLSTM@.NEXT:=CURRENTOWNER@.PTMEMBLIST;
           CURRENTOWNER@.PTMEMBLIST:=PTLSTM;
      END
 END;
 PROCEDURE DELROOT;
 {  DELETE ROOT-KNOT FR. "FIRSTINLOADED" 'S LIST }
 VAR
    CURRENT:PTKNOT;
    DELETED:BOOLEAN;
 BEGIN
      CURRENT:=FIRSTINLOADED;
      {  ROOT MAY NOT BE 1ST IN LIST }
      DELETED:=FALSE;
      WHILE (CURRENT <> NIL) AND (NOT  DELETED) DO
      BEGIN
            IF CURRENT@.NEXT@.PTOWNER = NIL THEN
            BEGIN
                 DELETED:=TRUE;
                 CURRENT@.NEXT:=CURRENT@.NEXT@.NEXT
            END;
            CURRENT:=CURRENT@.NEXT
      END
 END;
 PROCEDURE INSERTMEMBERS(PT:PTKNOT);
 {  ADD ALL MEMBERS OF KNOT TO COMMON LIST }
 VAR
    CURMEMB:PTLISTMEMB;
    PTM:PTKNOT;
    SNEXT:PTLISTMEMB;
 BEGIN
      DELROOT;
      CATSEQ(FIRSTKNOT);
      CURMEMB:=PT@.PTMEMBLIST;
      WHILE  CURMEMB <> NIL DO
      BEGIN
           PTM:=CURMEMB@.TARGET;
           PTM@.PTOWNER:=CURRENTOWNER;
           SNEXT:=CURMEMB@.NEXT;
           IF CURRENTOWNER <> NIL THEN
           BEGIN
                CURMEMB@.NEXT:=CURRENTOWNER@.PTMEMBLIST;
                CURRENTOWNER@.PTMEMBLIST:=CURMEMB
           END;
           CURMEMB:=SNEXT
     END
 END;
 PROCEDURE FINDQUAL;
 {  SHOOK OBJECT WHICH NAME IS FORMED IN "NAMETEXT" FR CURRENT }
 {  LEVEL OF MODEL & LOCATE REFERENCE TO HIM AT "LOWLEVELKNOT"}
 VAR FOUND:BOOLEAN;
     CURKNOT:PTKNOT;
 BEGIN
      ENDNAME;
      LOWLEVELKNOT:=NIL;
      IF NOT WASBADOPERATOR THEN
      BEGIN
           IF INEXPRESSION
           THEN SHOOKNAME(NAMETEXT,FOUND)
           ELSE SHOOKINALL(NAMETEXT,FOUND);
           IF NOT FOUND THEN ERROR(1520)
      END
 END;
 PROCEDURE FINDMEMB;
 {  SHOOKING OF NEXT    NNN.NNN. ... <<<NNN>>>. ... OBJECT }
 VAR
    FOUND:BOOLEAN;
    CURMEMB:PTLISTMEMB;
 BEGIN
      ENDNAME;
      IF WASBADOPERATOR THEN LOWLEVELKNOT:=NIL;
      IF LOWLEVELKNOT <> NIL THEN
      BEGIN
           IF LOWLEVELKNOT@.KNOTTYPE <> VARK
           THEN BEGIN LOWLEVELKNOT:=NIL;ERROR(103) END
           ELSE
           BEGIN
                IF LOWLEVELKNOT@.KNOTSUBTYPE <> STRUCTUREK
                THEN BEGIN LOWLEVELKNOT:=NIL;ERROR(140) END
                ELSE
                BEGIN
                     CURMEMB:=LOWLEVELKNOT@.PTMEMBLIST;
                     IF CURMEMB = NIL
                     THEN BEGIN LOWLEVELKNOT:=NIL;ERROR(152) END
                     ELSE
                     BEGIN
                          FOUND:=FALSE;
                          WHILE (NOT FOUND) AND (CURMEMB <> NIL) DO
                          BEGIN
                               IF CURMEMB@.TARGET@.NAME = NAMETEXT
                               THEN BEGIN
                                         FOUND:=TRUE;
                                         LOWLEVELKNOT:=
                                         CURMEMB@.TARGET
                                    END;
                               CURMEMB:=CURMEMB@.NEXT
                          END;
                          IF NOT FOUND THEN
                          BEGIN
                               LOWLEVELKNOT:=NIL;
                               ERROR(152)
                          END
                      END
                END
          END
     END
                                  ELSE
     BEGIN
          IF NOT WASBADOPERATOR THEN ERROR(104)
     END
 END;
 PROCEDURE GETNAME;
 VAR
    PRESENT:BOOLEAN;
 BEGIN
      OPNAME:=NAMETEXT;
      SHOOKNAME(OPNAME,PRESENT);
      IF PRESENT THEN ERROR(101)
 END;
 PROCEDURE GETCOST;
 BEGIN
      IF NOT WASBADOPERATOR THEN
         CONVCI(EXPRTEXT,OPCOST)
 END;
 PROCEDURE MDBMDL3;
 {  BUILD THE KNOT CORRESPONDING TO "REAL" VARIABLE }
 BEGIN
    IF NOT WASBADOPERATOR THEN
    BEGIN
         NEW(PTCURKNOT);
         WITH PTCURKNOT@ DO
         BEGIN
              NAME:=OPNAME;
              PTOWNER:=CURRENTOWNER;
              KNOTTYPE:=VARK;
              PTILIST:=NIL;
              PTOLIST:=NIL;
              PTMEMBLIST:=NIL;
              GENERATION:=0;
              KNOTSUBTYPE:=REALK
         END;
         INSERT(PTCURKNOT)
     END
 END;
 PROCEDURE MDBMDL4;
 {  BUILD THE KNOT CORRESPONDING TO "INTEGER" VARIABLE }
 BEGIN
    IF NOT WASBADOPERATOR THEN
    BEGIN
         NEW(PTCURKNOT);
         WITH PTCURKNOT@ DO
         BEGIN
              NAME:=OPNAME;
              PTOWNER:=CURRENTOWNER;
              KNOTTYPE:=VARK;
              PTILIST:=NIL;
              PTOLIST:=NIL;
              PTMEMBLIST:=NIL;
              GENERATION:=0;
              KNOTSUBTYPE:=INTEGERK
         END;
         INSERT(PTCURKNOT)
     END
 END;
 PROCEDURE MDBMDL5;
 {  BUILD THE KNOT CORRESPONDING TO "BOOLEAN" VARIABLE }
 BEGIN
    IF NOT WASBADOPERATOR THEN
    BEGIN
         NEW(PTCURKNOT);
         WITH PTCURKNOT@ DO
         BEGIN
              NAME:=OPNAME;
              PTOWNER:=CURRENTOWNER;
              KNOTTYPE:=VARK;
              PTILIST:=NIL;
              PTOLIST:=NIL;
              PTMEMBLIST:=NIL;
              GENERATION:=0;
              KNOTSUBTYPE:=BOOLEANK
         END;
         INSERT(PTCURKNOT)
     END
 END;
 PROCEDURE SHOOKINALL;
 {         (NAME:NAMEOBJ;VAR PRESENT:BOOLEAN) - "FORWARD" }
 {  SHOOK THE NAME AT ALL PARENT-LEVELS OF MODEL.         }
 VAR
    CURMEMB:PTLISTMEMB;
    CURKNOT:PTKNOT;
    CUROWNER:PTKNOT;
 BEGIN
      PRESENT:=FALSE;
      LOWLEVELKNOT:=NIL;
      CUROWNER:=CURRENTOWNER;
      WHILE (NOT PRESENT) AND (CUROWNER <> NIL) DO
      BEGIN
           CURMEMB:=CUROWNER@.PTMEMBLIST;
           WHILE (CURMEMB <> NIL) AND (NOT PRESENT) DO
           BEGIN
                IF CURMEMB@.TARGET@.NAME = NAME THEN
                BEGIN
                     PRESENT:=TRUE;
                     LOWLEVELKNOT:=CURMEMB@.TARGET
                END;
                CURMEMB:=CURMEMB@.NEXT
           END;
           CUROWNER:=CUROWNER@.PTOWNER
      END;
      IF NOT PRESENT THEN SHOOKHIGH(NAME,PRESENT)
 END;
 PROCEDURE GETMODULE;
 {  BUILD THE "MODULE" KNOT. I/O LISTS BUILDS THEN }
 {  IN "ATTACHNAME" PROCEDURE.                     }
 BEGIN
      ENDNAME;
      NEW(PTCURKNOT);
      WITH PTCURKNOT@ DO
      BEGIN
           NAME:=OPNAME;
           PTOWNER:=CURRENTOWNER;
           KNOTTYPE:=RELK;
           IF OPCOST = 0 THEN COST:=50 ELSE COST:=OPCOST;
           PTILIST:=NIL;
           PTOLIST:=NIL;
           FIRSTMEMBER:=NIL;
           KNOTSUBTYPE:=MODULEK;
           MODULENAME:=NAMETEXT;
           MODULELOC :=EXTRN;
      END
 END;
 PROCEDURE ATTACHNAME;
 {  ATTACH THE KNOT INTO "FIRSTMEMBER" 'S LIST }
 VAR
    PRESENT:BOOLEAN;
    PTNEW: PTLISTMEMB;
 BEGIN
      IF LOWLEVELKNOT <> NIL THEN
      BEGIN
           IF NOT (
                   ( LOWLEVELKNOT@.KNOTTYPE = VARK )
                                 AND
                   ( LOWLEVELKNOT@.KNOTSUBTYPE IN [ REALK,INTEGERK,
                                                     BOOLEANK
                                                   ]
                                                                    )
                  )
           THEN ERROR(103)
           ELSE
           IF NOT WASBADOPERATOR THEN
           BEGIN
                {  IF THIS KNOT ALRDY PRESENT, THEN NO ATTACHMENT }
                CHECKP(FIRSTMEMBER,LOWLEVELKNOT,PRESENT);
                IF NOT PRESENT THEN
                BEGIN
                     NEW(PTNEW);
                     PTNEW@.TARGET:=LOWLEVELKNOT;
                     PTNEW@.NEXT:=FIRSTMEMBER;
                     FIRSTMEMBER:=PTNEW;
                END
           END
      END
 END;
 PROCEDURE MDBMDL9;
 {  ATTACH "IN" LIST TO MODULE }
 BEGIN
      PTCURKNOT@.PTILIST:=FIRSTMEMBER;
      FIRSTMEMBER:=NIL
 END;
 PROCEDURE MDBMDL8;
 {  ATTACH "OUT" LIST TO MODULE }
 {  AND ADD MODULE TO SYSTEM    }
 VAR
    F:PTLISTMEMB;
 BEGIN
      PTCURKNOT@.RELSTRING:=EXPRTEXT;
      PTCURKNOT@.FIRSTPARM:=GFIRSTPARM;
      PTCURKNOT@.PTOLIST:=FIRSTMEMBER;
      IF NOT WASBADOPERATOR THEN
      BEGIN
           BUILDIN;
           FIRSTMEMBER:=PTCURKNOT@.PTILIST;
           BUILDOUT;
           INSERT(PTCURKNOT)
      END
 END;
 PROCEDURE BUILDOUT;
 {  BUILD IN "IN" VARS "OUT" REFERENCES TO CURRENT MODULE }
 {  POINTER TO MODULE IS GLOVAR "PTCURKNOT". POINTER TO   }
 {  FIRST IN VARS LIST ELEMENT IS "FIRSTMEMB".           }
 VAR
    CURPARM:PTLISTMEMB;
    CURACCEPTOR:PTLISTMEMB;
    NEWELEMENT:PTLISTMEMB;
    PRESENT:BOOLEAN;
    BEGIN
         CURPARM:=FIRSTMEMBER;
         WHILE CURPARM <> NIL DO
         BEGIN
              CURACCEPTOR:=CURPARM@.TARGET@.PTOLIST;
              IF CURACCEPTOR = NIL
              THEN
              BEGIN
                   NEW(NEWELEMENT);
                   NEWELEMENT@.NEXT:=NIL;
                   NEWELEMENT@.TARGET:=PTCURKNOT;
                   CURPARM@.TARGET@.PTOLIST:=NEWELEMENT
              END
              ELSE
              BEGIN
                   CHECKP(CURACCEPTOR,PTCURKNOT,PRESENT);
                   IF NOT PRESENT THEN
                   BEGIN
                        NEW(NEWELEMENT);
                        NEWELEMENT@.NEXT:=CURACCEPTOR;
                        NEWELEMENT@.TARGET:=PTCURKNOT;
                        CURPARM@.TARGET@.PTOLIST:=NEWELEMENT
                   END
              END;
              CURPARM:=CURPARM@.NEXT
          END
     END;
 PROCEDURE BUILDIN;
 {  BUILD IN "OUT" VARS "IN" REFERENCES TO CURRENT MODULE }
 {  POINTER TO MODULE IS GLOVAR "PTCURKNOT". POINTER TO   }
 {  FIRST OUT VARS LIST ELEMENT IS "FIRSTMEMB".           }
 VAR
    CURPARM:PTLISTMEMB;
    CURACCEPTOR:PTLISTMEMB;
    NEWELEMENT:PTLISTMEMB;
    PRESENT:BOOLEAN;
    BEGIN
         CURPARM:=FIRSTMEMBER;
         WHILE CURPARM <> NIL DO
         BEGIN
              CURACCEPTOR:=CURPARM@.TARGET@.PTILIST;
              IF CURACCEPTOR = NIL
              THEN
              BEGIN
                   NEW(NEWELEMENT);
                   NEWELEMENT@.NEXT:=NIL;
                   NEWELEMENT@.TARGET:=PTCURKNOT;
                   CURPARM@.TARGET@.PTILIST:=NEWELEMENT
              END
              ELSE
              BEGIN
                   CHECKP(CURACCEPTOR,PTCURKNOT,PRESENT);
                   IF NOT PRESENT THEN
                   BEGIN
                        NEW(NEWELEMENT);
                        NEWELEMENT@.NEXT:=CURACCEPTOR;
                        NEWELEMENT@.TARGET:=PTCURKNOT;
                        CURPARM@.TARGET@.PTILIST:=NEWELEMENT
                   END
              END;
              CURPARM:=CURPARM@.NEXT
          END
     END;
     PROCEDURE PASSNAME;
     {  THIS PROC LETS TO PASS NEXT CURRENT CHARACTER }
     {  FROM ANALYZER TO MDB IN "FORWARD" PROCEDURE   }
     BEGIN
          PASSING:=TRUE;
          NAMETEXT[ 1 ]:=CURCHAR;
          IPASS:=1
     END;
     PROCEDURE EXPRON;
     {  THIS PROC LETS TO PASS NEXT CURRENT CHARACTER }
     {  FROM ANALYZER TO MDB IN "FORWARD" PROCEDURE   }
     BEGIN
          EXPRPASS:=TRUE;
          IEPASS:=0;
          IF (NOT INNAMEINEXPRESSION) THEN
          BEGIN
               EXPRTEXT[ 1 ]:=CURCHAR;
               IEPASS:=1
          END
     END;
     PROCEDURE ENDNAME;
     {  CANCEL THE PASSING OF CHARACTERS FROM ANAL. TO MDB }
     VAR
        I:INTEGER;
     BEGIN
          PASSING:=FALSE;
          IF IPASS <= NAMELENGTH THEN
          FOR I:=IPASS TO NAMELENGTH DO NAMETEXT[ I ]:=' '
          {  NOTE THAT THE LAST PASSED SYMBOL IS  }
          {  THE TERMINATOR AND WILL NOT BE PASSED}
     END;
 PROCEDURE EPASS(C:CHAR);
     BEGIN
          IF (NOT WASBADOPERATOR) AND EXPRPASS AND
             (NOT INNAMEINEXPRESSION) THEN
          BEGIN
               IF IEPASS>LINELENGTH-2 THEN ERROR(400)
                           ELSE
               BEGIN
                    IF IEPASS < 0 THEN IEPASS:=0;
                    IEPASS:=IEPASS+1;
                    EXPRTEXT[ IEPASS ]:=C
               END
           END
      END;
     PROCEDURE EXPROFF;
     {  CANCEL THE PASSING OF CHARACTERS FROM ANAL. TO MDB }
     VAR
        I:INTEGER;
     BEGIN
          EXPRPASS:=FALSE;
          IF  IEPASS < 1 THEN IEPASS:=1;
          FOR I:=IEPASS TO LINELENGTH DO EXPRTEXT[ I ]:=' '
          {  NOTE THAT THE LAST PASSED SYMBOL IS  }
          {  THE TERMINATOR AND WILL NOT BE PASSED}
     END;
     PROCEDURE PASS(C:CHAR);
     BEGIN
          IF (NOT WASBADOPERATOR) AND PASSING THEN
          BEGIN
               IPASS:=IPASS+1;
               IF IPASS <= NAMELENGTH THEN NAMETEXT[ IPASS ]:=C
          END
     END;
 PROCEDURE EPASSNAME(NAME:NAMEOBJ);
 VAR
    L:INTEGER;
    I:INTEGER;
 BEGIN
      L:=NAMELENGTH;
      WHILE (L > 1) AND (NAME[ L ] = ' ') DO L:=L-1;
      FOR I:=1 TO L DO EPASS(NAME[ I ])
 END;
 PROCEDURE PASSFULLNAME(VAR M:PTKNOT);
 {  PASS FULL NAME IN CURRENT OWNER EXEPTLY CURRENT OWNER }
 VAR
    CUROWNER:PTKNOT;
    BOSS:PTKNOT;
    CURMEMBER:PTLISTMEMB;
    KINDER:BOOLEAN;
    ALRDYPRESENT:BOOLEAN;
    CURPARM:PTLISTMEMB;
    ALLNAMESGENERATED:BOOLEAN;
 BEGIN
      CHECKP(GFIRSTPARM,M,ALRDYPRESENT);
      IF NOT ALRDYPRESENT
      THEN
      BEGIN
      NEW(CURPARM);
      CURPARM@.TARGET:=M;
      CURPARM@.NEXT:=NIL;
      IF GFIRSTPARM = NIL
      THEN
      BEGIN
           GFIRSTPARM:=CURPARM;
           GLASTPARM:=CURPARM
      END
      ELSE
      BEGIN
           GLASTPARM@.NEXT:=CURPARM;
           GLASTPARM:=CURPARM
      END;
      END
      ELSE
      BEGIN
           IF INMODULE THEN ERROR(877)
      END;
      {  SHOOK CURRENT -OWNER & MARK ROOT TO IT }
      {  BY "GENERATION" FIELD = 1 IN VARS }
      M@.GENERATION:=1;
      BOSS:=M;
      CUROWNER:=M@.PTOWNER;
      WHILE CUROWNER <> CURRENTOWNER DO
      BEGIN
           BOSS:=CUROWNER;
           BOSS@.GENERATION:=1;
           CUROWNER:=CUROWNER@.PTOWNER
      END;
      {  NOW COME DOWN FR. BIG BOSS TO M }
      ALLNAMESGENERATED:=FALSE;
      WHILE (NOT ALLNAMESGENERATED) DO
      BEGIN
           EPASSNAME(BOSS@.NAME);
           BOSS@.GENERATION:=0;
           IF BOSS = M THEN ALLNAMESGENERATED:=TRUE
                       ELSE
           BEGIN
                ALLNAMESGENERATED:=FALSE;
                EPASS('.');
                CURMEMBER:=BOSS@.PTMEMBLIST;
                KINDER:=FALSE;
                WHILE (NOT KINDER) DO
                BEGIN
                     BOSS:=CURMEMBER@.TARGET;
                     IF (BOSS@.GENERATION = 1)
                              AND
                        (BOSS@.KNOTTYPE = VARK)
                     THEN KINDER:=TRUE;
                     CURMEMBER:=CURMEMBER@.NEXT;
                END;
          END;
    END;
 END;
 PROCEDURE SETNAMEINEXPRESSION;
 BEGIN
      IF LOWLEVELKNOT = NIL
      THEN
      BEGIN
           IF INMODULE
           THEN
           BEGIN
                  IF NOT INSHABLON THEN
                  BEGIN
                       IF NOT WASBADOPERATOR THEN ERROR(890)
                  END
                  ELSE INSHABLON:=FALSE
           END
           ELSE EPASSNAME(NAMETEXT)
      END
      ELSE PASSFULLNAME(LOWLEVELKNOT);
      EPASS(CURCHAR)
 END;
      PROCEDURE CONVCI;
      {         (STRING:LINE; VAR IRESULT:INTEGER ) - "FORWARD" }
      {  CONVERSION OF EXT. REPRESENTATION OF INTEGER }
      {  TO INTERNAL REPRESENT.. USES "DIGARRAY".     }
      VAR
         I:INTEGER;
         C:CHAR;
         D:INTEGER;
         ORDER:INTEGER;
      BEGIN
           ORDER:=1;
           IRESULT:=0;
           FOR I:=LINELENGTH DOWNTO 1 DO
           BEGIN
                C:=STRING[ I ];
                IF (C <> ' ') AND (NOT WASBADOPERATOR) THEN
                BEGIN
                     D:=DIGARRAY[ C ];
                     IRESULT:=IRESULT+ORDER*D;
                     IF IRESULT > 9999 THEN ERROR(203);
                     ORDER:=ORDER*10
                END
            END
 END;
 PROCEDURE MDBMDL7;
 {  CREATION OF KNOT WHICH CORRESPONDS TO "CHAR'K " OP. }
 VAR
    OPCHARLENGTH:INTEGER; {  "K" VALUE    }
 BEGIN
      EXPROFF;
      IF NOT WASBADOPERATOR THEN
         CONVCI(EXPRTEXT,OPCHARLENGTH);
      IF NOT WASBADOPERATOR THEN
      BEGIN
           NEW(PTCURKNOT);
           WITH PTCURKNOT@ DO
           BEGIN
                NAME:=OPNAME;
                PTOWNER:=CURRENTOWNER;
                KNOTTYPE:=VARK;
                PTILIST:=NIL;
                PTOLIST:=NIL;
                PTMEMBLIST:=NIL;
                GENERATION:=0;
                KNOTSUBTYPE:=CHARK;
                LENGTH:=OPCHARLENGTH
           END;
           INSERT(PTCURKNOT)
       END
 END;
 PROCEDURE GETLEFT;
 {  GET THE NAME & REF TO LEFT PART IN "LET" OPERATOR }
 BEGIN
      IF NOT WASBADOPERATOR THEN
      BEGIN
           IF LOWLEVELKNOT@.KNOTTYPE <> VARK
           THEN ERROR(103)
           ELSE
           BEGIN
                REFLEFT:=LOWLEVELKNOT;
                FIRSTMEMBER:=NIL;
                ERR1520:=IGNORE;
                EXPRON
           END
      END
 END;
 PROCEDURE ADDLET;
 {  ADD "LET" KNOT INTO SYSTEM }
 VAR
    OELEMENT:PTLISTMEMB;
 BEGIN
      EXPROFF;
      ERR1520:=WORKUP;
      IF NOT WASBADOPERATOR THEN
      BEGIN
           NEW(PTCURKNOT);
           WITH PTCURKNOT@ DO
           BEGIN
                NAME:=OPNAME;
                PTOWNER:=CURRENTOWNER;
                KNOTTYPE:=RELK;
                IF OPCOST = 0 THEN COST:=25 ELSE COST:=OPCOST;
                PTILIST:=FIRSTMEMBER;
                IF PTILIST = NIL THEN COST:=5;
                BUILDOUT;
                NEW(OELEMENT);
                OELEMENT@.NEXT:=NIL;
                OELEMENT@.TARGET:=REFLEFT;
                PTOLIST:=OELEMENT;
                FIRSTMEMBER:=PTOLIST;
                BUILDIN;
                KNOTSUBTYPE:=LETK;
                PTMEMBLIST:=NIL;
                RELSTRING:=EXPRTEXT
             END;
             INSERT(PTCURKNOT)
        END
 END;
 PROCEDURE GETEQN;
 {  START OF "EQN" PROCESSING }
 BEGIN
      IF NOT WASBADOPERATOR THEN
      BEGIN
           FIRSTMEMBER:=NIL;
           ERR1520:=IGNORE;
           EXPRON
      END
 END;
 PROCEDURE NEWEQN;
 {  BUILD THE "EQN" KNOTS }
 VAR
    LISTIN:PTLISTMEMB;
    CURRENT:PTLISTMEMB;
    NEWELEMENT:PTLISTMEMB;
    CURIN:PTLISTMEMB;
    I:INTEGER;
 BEGIN
      EXPROFF;
      ERR1520:=WORKUP;
      IF NOT WASBADOPERATOR THEN
      BEGIN
           IF FIRSTMEMBER = NIL
           THEN ERROR(403)
           ELSE
           BEGIN
                CURRENT:=FIRSTMEMBER;
                LISTIN:=FIRSTMEMBER;
                REPEAT
                      NEW(PTCURKNOT);
                      WITH PTCURKNOT@ DO
                      BEGIN
                           NAME:=OPNAME;
                           PTOWNER:=CURRENTOWNER;
                           PTMEMBLIST:=NIL;
                           KNOTTYPE:=RELK;
                           IF OPCOST=0 THEN COST:=80 ELSE COST:=OPCOST;
                           KNOTSUBTYPE:=EQNK;
                           FOR I:=1 TO NAMELENGTH
                           DO MODULENAME [ I ] :=' ';
                           RELSTRING:=EXPRTEXT;
                           FIRSTPARM:=GFIRSTPARM;
                           {  BUILD THE "OUT" LIST CONTAINS }
                           {  ONLY 1 ELEMENT                  }
                           NEW(NEWELEMENT);
                           NEWELEMENT@.NEXT:=NIL;
                           NEWELEMENT@.TARGET:=CURRENT@.TARGET;
                           PTOLIST:=NEWELEMENT;
                           FIRSTMEMBER:=PTOLIST;
                           BUILDIN;
                           {  BUILD THE "IN" LIST - CONTAINS ALL }
                           { FROM INITIAL "LISTIN"  WITHOUT        }
                           {  "CURRENT" ELEMENT                    }
                           PTILIST:=NIL;
                           CURIN:=LISTIN;
                           REPEAT
                                 IF CURIN <> CURRENT THEN
                                 BEGIN
                                        NEW(NEWELEMENT);
                                        NEWELEMENT@.NEXT:=PTILIST;
                                        NEWELEMENT@.TARGET:=
                                        CURIN@.TARGET;
                                        PTILIST:=NEWELEMENT
                                 END;
                                 CURIN:=CURIN@.NEXT;
                           UNTIL CURIN = NIL;
                           FIRSTMEMBER:=PTILIST;
                           BUILDOUT
                        END;
                        INSERT(PTCURKNOT);
                        CURRENT:=CURRENT@.NEXT
                  UNTIL CURRENT = NIL
             END
       END
 END;
 PROCEDURE FINDFROM(ORDNUM:INTEGER;VAR KNOTREF:PTKNOT);
 {  FIND KNOT IN "FIRSTINLOADED" 'S LIST FROM ORDVALUE }
 VAR
    CURKNOT:PTKNOT;
 BEGIN
      CURKNOT:=FIRSTINLOADED;
      KNOTREF:=NIL;
      WHILE (KNOTREF = NIL) DO
      BEGIN
           IF CURKNOT@.ORDVALUE = ORDNUM
           THEN KNOTREF:=CURKNOT;
           CURKNOT:=CURKNOT@.NEXT;
      END
 END;
 PROCEDURE FINDLPARM(FROMKNOT:PTKNOT; VAR LASTPARM:PTLISTMEMB);
 VAR
    CURPARM:PTLISTMEMB;
 BEGIN
      LASTPARM:=NIL;
      CURPARM:=FROMKNOT@.FIRSTPARM;
      WHILE CURPARM <> NIL DO
      BEGIN
           LASTPARM:=CURPARM;
           CURPARM:=CURPARM@.NEXT
      END
 END;
 PROCEDURE RESOLVELINKS;
 {  RESOLVE ALL I/O LINKS IN ALL "FIRSTINLOADED" 'S MODELS }
 VAR
    CURLINK:LINKMEMB;
    FROMKNOT:PTKNOT;
    TOKNOT:PTKNOT;
    NEWELEMENT:PTLISTMEMB;
    LASTPARM:PTLISTMEMB;
 BEGIN
       CURLINK:=FIRSTLINK;
       WHILE CURLINK <> NIL DO
       BEGIN
            FINDFROM(CURLINK@.FROMVALUE,FROMKNOT);
            FINDFROM(CURLINK@.LINKVALUE,TOKNOT);
            NEW(NEWELEMENT);
            NEWELEMENT@.TARGET:=TOKNOT;
            IF CURLINK@.LINKTYPE = INLINK
            THEN
            BEGIN
                 NEWELEMENT@.NEXT:=FROMKNOT@.PTILIST;
                 FROMKNOT@.PTILIST:=NEWELEMENT;
            END
            ELSE
            BEGIN
                 NEWELEMENT@.NEXT:=FROMKNOT@.PTOLIST;
                 FROMKNOT@.PTOLIST:=NEWELEMENT
            END;
            CURLINK:=CURLINK@.NEXT
        END;
        CURLINK:=FIRSTPLINK;
        WHILE CURLINK <> NIL DO
        BEGIN
             FINDFROM(CURLINK@.FROMVALUE,FROMKNOT);
             FINDFROM(CURLINK@.LINKVALUE,TOKNOT);
             NEW(NEWELEMENT);
             NEWELEMENT@.TARGET:=TOKNOT;
             NEWELEMENT@.NEXT:=NIL;
             FINDLPARM(FROMKNOT,LASTPARM);
             IF LASTPARM = NIL THEN FROMKNOT@.FIRSTPARM:=NEWELEMENT
                               ELSE LASTPARM@.NEXT:=NEWELEMENT;
             CURLINK:=CURLINK@.NEXT
        END
  END;
 PROCEDURE CORRNUMBERS;
 {  BUILD CORRECT ORDNUMBERS IN "FIRSTINLOADED" 'S LIST KNOTS }
 VAR
    CURKNOT:PTKNOT;
    NEWFIRST:INTEGER;
 BEGIN
      NEWFIRST:=OBJCOUNT+1;
      CURKNOT:=FIRSTINLOADED;
      WHILE CURKNOT <> NIL DO
      BEGIN
          CURKNOT@.ORDVALUE:=CURKNOT@.ORDVALUE+NEWFIRST-MINORD;
          CURKNOT:=CURKNOT@.NEXT;
      END;
      OBJCOUNT:=NEWFIRST+MAXORD-MINORD;
 END;
 PROCEDURE TUNELOADED;
 {  ATTACH  MODEL WHICH IS INLOADED REFRS BY "CURROOT" }
 BEGIN
      RESOLVELINKS; {  I/O LINKS BY "FIRSTLINK" 'S LIST }
      CORRNUMBERS; {  CHANGE ORDER NUMBERS }
 END;
 PROCEDURE GETSOLVE;
 BEGIN
      IF LOWLEVELKNOT@.KNOTTYPE <> RELK THEN ERROR(134)
      ELSE
         BEGIN
              IF LOWLEVELKNOT@.KNOTSUBTYPE <> EQNK THEN ERROR(135)
         END
 END;
 PROCEDURE CORRSOLVE;
 VAR
    CURKNOT:PTKNOT;
 BEGIN
      CURKNOT:=FIRSTKNOT;
      WHILE CURKNOT <> NIL DO
      BEGIN
           IF (CURKNOT@.NAME = LOWLEVELKNOT@.NAME)
                            AND
              (CURKNOT@.PTOWNER = LOWLEVELKNOT@.PTOWNER) THEN
           CURKNOT@.MODULENAME:=NAMETEXT;
           CURKNOT:=CURKNOT@.NEXT
      END
 END;
 PROCEDURE FINDCORRESPONDING(PX:PTKNOT;PY:PTKNOT;WHAT:PTKNOT;
                  VAR FOUND:BOOLEAN;VAR CORRESPONDING:PTKNOT);
 VAR
    CMX:PTLISTMEMB;
    CMY:PTLISTMEMB;
 BEGIN
      FOUND:=FALSE;
      IF WHAT@.KNOTTYPE = VARK THEN
      BEGIN
      CMX:=PX@.PTMEMBLIST;
      WHILE (CMX <> NIL) AND (NOT FOUND) DO
      BEGIN
           CMY:=PY@.PTMEMBLIST;
           WHILE (CMY <> NIL) AND (NOT FOUND) DO
           BEGIN
                IF (CMX@.TARGET@.NAME = CMY@.TARGET@.NAME) AND
                (CMX@.TARGET@.KNOTTYPE = CMY@.TARGET@.KNOTTYPE) AND
                (CMX@.TARGET@.KNOTSUBTYPE = CMY@.TARGET@.KNOTSUBTYPE)
                THEN
                BEGIN
                     IF CMX@.TARGET = WHAT
                     THEN
                     BEGIN
                          FOUND:=TRUE;
                          CORRESPONDING:=CMY@.TARGET
                     END
          ELSE FINDCORRESPONDING(CMX@.TARGET,CMY@.TARGET,WHAT,FOUND,
                                 CORRESPONDING)
                END;
                CMY:=CMY@.NEXT
           END;
           CMX:=CMX@.NEXT
      END
      END
 END;
 PROCEDURE IOSUBSTITUTE(VAR OLDREF:PTKNOT;VAR NEWREF:PTKNOT;
                        VAR INWHAT:PTKNOT);
 VAR
    CURIO:PTLISTMEMB;
    CURMEMB:PTLISTMEMB;
 BEGIN
      {  SCAN ALL MEMBER- & IN- & OUT- LISTS ELEMENTS }
      CURIO:=INWHAT@.PTILIST;
      WHILE CURIO <> NIL DO
      BEGIN
           IF CURIO@.TARGET = OLDREF THEN CURIO@.TARGET:=NEWREF;
           CURIO:=CURIO@.NEXT;
      END;
      CURIO:=INWHAT@.PTOLIST;
      WHILE CURIO <> NIL DO
      BEGIN
           IF CURIO@.TARGET = OLDREF THEN CURIO@.TARGET:=NEWREF;
           CURIO:=CURIO@.NEXT
      END;
      IF INWHAT@.KNOTSUBTYPE = EQNK THEN
      BEGIN
           CURIO:=INWHAT@.FIRSTPARM;
           WHILE CURIO <> NIL DO
           BEGIN
                IF CURIO@.TARGET = OLDREF THEN CURIO@.TARGET:=NEWREF;
                CURIO:=CURIO@.NEXT
           END
      END;
      IF INWHAT@.KNOTSUBTYPE = STRUCTUREK THEN
      BEGIN
      CURMEMB:=INWHAT@.PTMEMBLIST;
      WHILE CURMEMB <> NIL DO
      BEGIN
           IOSUBSTITUTE(OLDREF,NEWREF,CURMEMB@.TARGET);
           CURMEMB:=CURMEMB@.NEXT
      END
      END
 END;
 PROCEDURE NEWBADMEM(CURIO:PTLISTMEMB;PTMEMB:PTKNOT;YOTYPE:REFTYPE);
 VAR
    NEWMEMB:PTEXTREF;
    PRESENT:BOOLEAN;
    CORRESPONDING:PTKNOT;
 BEGIN
    FINDCORRESPONDING(PKBECHANGED,YPTR,PTMEMB,PRESENT,CORRESPONDING);
    IF NOT PRESENT THEN ERROR(419)
                   ELSE
    BEGIN
         NEW(NEWMEMB);
         NEWMEMB@.LISTMEMB:=CURIO;
         NEWMEMB@.KNOTFROM:=CORRESPONDING;
         NEWMEMB@.OLDKNOT:=PTMEMB;
         NEWMEMB@.NEXT:=FIRSTBAD;
         NEWMEMB@.YOTYPE:=YOTYPE;
         FIRSTBAD:=NEWMEMB;
    END;
 END;
 PROCEDURE XCHECKUP(K:PTKNOT;PTBOSS:PTKNOT;VAR UNLOADABLE:BOOLEAN;
                    CURIO:PTLISTMEMB;PTMEMB:PTKNOT;YOTYPE:REFTYPE);
 VAR CUROWNER:PTKNOT; LUNLOADABLE:BOOLEAN;
 BEGIN
      LUNLOADABLE:=FALSE;
      CUROWNER:=K@.PTOWNER;
      IF CUROWNER <> NIL THEN
      REPEAT
            IF CUROWNER@.ORDVALUE = PTBOSS@.ORDVALUE
            THEN LUNLOADABLE:=TRUE;
            CUROWNER:=CUROWNER@.PTOWNER
      UNTIL (CUROWNER = NIL) OR LUNLOADABLE;
      IF NOT LUNLOADABLE THEN NEWBADMEM(CURIO,PTMEMB,YOTYPE);
      UNLOADABLE:=UNLOADABLE AND LUNLOADABLE
 END;
 PROCEDURE XCHECKIO(PTMEMB:PTKNOT;PTBOSS:PTKNOT;
                   VAR UNLOADABLE:BOOLEAN);
 VAR
    CURMEMB:PTLISTMEMB;
    CURIO:PTLISTMEMB;
 BEGIN
      CURIO:=PTMEMB@.PTILIST;
      WHILE (CURIO <> NIL) DO
      BEGIN
           XCHECKUP(CURIO@.TARGET,PTBOSS,UNLOADABLE,CURIO,PTMEMB,
                    INLINK);
           CURIO:=CURIO@.NEXT
      END;
      CURIO:=PTMEMB@.PTOLIST;
      WHILE (CURIO <> NIL) DO
      BEGIN
           XCHECKUP(CURIO@.TARGET,PTBOSS,UNLOADABLE,CURIO,PTMEMB,
                    OUTLINK);
           CURIO:=CURIO@.NEXT
      END;
      IF (PTMEMB@.KNOTTYPE = VARK) AND
         (PTMEMB@.KNOTSUBTYPE = STRUCTUREK) THEN
      BEGIN
           CURMEMB:=PTMEMB@.PTMEMBLIST;
           WHILE (CURMEMB <> NIL) DO
           BEGIN
                XCHECKIO(CURMEMB@.TARGET,PTBOSS,UNLOADABLE);
                CURMEMB:=CURMEMB@.NEXT
           END
     END
 END;
 PROCEDURE GETBECHANGED;
 VAR
    CURMEMB:PTLISTMEMB;
    PRESENT:BOOLEAN;
 BEGIN
      IF (CURROOT@.KNOTTYPE = VARK) AND
         (CURROOT@.KNOTSUBTYPE = STRUCTUREK) THEN
      BEGIN
           CURMEMB:=CURROOT@.PTMEMBLIST;
           PRESENT:=FALSE;
           WHILE (CURMEMB <> NIL) AND (NOT PRESENT) DO
           BEGIN
                IF CURMEMB@.TARGET@.NAME = NAMETEXT THEN
                BEGIN
                     PRESENT:=TRUE;
                     MEMPKBECHANGED:=CURMEMB;
                     PKBECHANGED:=CURMEMB@.TARGET
                END;
                CURMEMB:=CURMEMB@.NEXT
          END;
          IF NOT PRESENT THEN ERROR(152);
      END
      ELSE ERROR(140)
 END;
 PROCEDURE ADDREF(VAR REF:PTLISTMEMB; VAR LISTTO:PTLISTMEMB);
 VAR
    ALRDYPRESENT:BOOLEAN;
    CM:PTLISTMEMB;
 BEGIN
      ALRDYPRESENT:=FALSE;
      CM:=LISTTO;
      WHILE (CM <> NIL) AND (NOT ALRDYPRESENT) DO
      BEGIN
           IF CM@.TARGET = REF@.TARGET THEN ALRDYPRESENT:=TRUE;
           CM:=CM@.NEXT
      END;
      IF NOT ALRDYPRESENT THEN
      BEGIN
           REF@.NEXT:=LISTTO;
           LISTTO:=REF
      END
 END;
 PROCEDURE ADDREFS(KOF:PTKNOT;VAR KTO:PTKNOT);
 {  ADD TO "KTO" ALL REFERENCES OF "KOF" }
 VAR
    CKOF:PTLISTMEMB;
    NEXTOF:PTLISTMEMB;
 BEGIN
      CKOF:=KOF@.PTILIST;
      WHILE CKOF <> NIL DO
      BEGIN
           NEXTOF:=CKOF@.NEXT;
           ADDREF(CKOF,KTO@.PTILIST);
           CKOF:=NEXTOF
      END;
      CKOF:=KOF@.PTOLIST;
      WHILE CKOF <> NIL DO
      BEGIN
           NEXTOF:=CKOF@.NEXT;
           ADDREF(CKOF,KTO@.PTOLIST);
           CKOF:=NEXTOF
      END
 END;
 PROCEDURE REGISTRATE(TESTING:PTKNOT; VAR UNLOADABLE:BOOLEAN);
 VAR
    CM:PTLISTMEMB;
 BEGIN
      FIRSTBAD:=NIL;
      UNLOADABLE:=TRUE;
      IF TESTING@.KNOTSUBTYPE = STRUCTUREK THEN
      BEGIN
           CM:=TESTING@.PTMEMBLIST;
           WHILE (CM <> NIL) AND (NOT WASBADOPERATOR) DO
           BEGIN
                XCHECKIO(CM@.TARGET,TESTING,UNLOADABLE);
                CM:=CM@.NEXT
           END
       END
 END;
 PROCEDURE CHANGELINKS;
 VAR
    CURBAD:PTEXTREF;
 BEGIN
      CURBAD:=FIRSTBAD;
      WHILE CURBAD <> NIL DO
      BEGIN
           IF CURBAD@.YOTYPE = INLINK
           THEN ADDREF(CURBAD@.LISTMEMB,CURBAD@.KNOTFROM@.PTILIST)
           ELSE ADDREF(CURBAD@.LISTMEMB,CURBAD@.KNOTFROM@.PTOLIST);
           IOSUBSTITUTE(CURBAD@.OLDKNOT,CURBAD@.KNOTFROM,CURROOT);
           CURBAD:=CURBAD@.NEXT
      END
 END;
 PROCEDURE REMOVEALL(VAR PK:PTKNOT;VAR LISTFROM:PTKNOT);
 {  REMOVE PK@ & HIS MEMBS FR> LIST SPECIFIED }
 VAR
    CURKNOT:PTKNOT;
    PREVKNOT:PTKNOT;
    CURMEMB:PTLISTMEMB;
    REMOVED:BOOLEAN;
 BEGIN
      CURKNOT:=LISTFROM;
      PREVKNOT:=LISTFROM;
      REMOVED:=FALSE;
      WHILE (CURKNOT <> NIL) AND (NOT REMOVED) DO
      BEGIN
           IF CURKNOT = PK THEN
           BEGIN
                REMOVED:=TRUE;
                {  RMV ROOT }
                IF PREVKNOT <> CURKNOT
                THEN PREVKNOT@.NEXT:=CURKNOT@.NEXT
                ELSE PREVKNOT:=CURKNOT@.NEXT;
                {  RMV MEMBERS }
                CURMEMB:=PK@.PTMEMBLIST;
                WHILE CURMEMB <> NIL DO
                BEGIN
                     REMOVEALL(CURMEMB@.TARGET,LISTFROM);
                     CURMEMB:=CURMEMB@.NEXT
               END
          END;
          PREVKNOT:=CURKNOT;
          CURKNOT:=CURKNOT@.NEXT
      END
 END;
 PROCEDURE CHANGE;
 {  CHNG "X" IN "MODEL A IS B X=Y"                          }
 {  PTR TO X IS IN "PKBECHANGED"                            }
 {  PTR TO "X" 'S MEMBER LIST ELEMENT IS "MEMPKBECHANGED"   }
 {  "A" IS NOT ATTACHED TO COMMON LIST BUT ALL I/O LINKS IN }
 {  "A" ARE RESOLVED & ORDER-NUMBERS ARE CHANGED            }
 {  PTR TO "Y" IS IN "LOWLEVELKNOT"                         }
 {  PTR TO "A" 'S LIST IS "FIRSTINLOADED"                   }
 {  PTR TO "A" 'S ROOT IS "CURROOT"                         }
 VAR
    XISUNLOADABLE:BOOLEAN;
    YISUNLOADABLE:BOOLEAN;
    AFIRSTINLOADED:PTKNOT;
 BEGIN
      IF (PKBECHANGED@.KNOTTYPE = LOWLEVELKNOT@.KNOTTYPE) AND
      (PKBECHANGED@.KNOTSUBTYPE = LOWLEVELKNOT@.KNOTSUBTYPE) THEN
      BEGIN
            IF LOWLEVELKNOT@.KNOTTYPE = VARK THEN
            BEGIN
            CHECKEXTREF(LOWLEVELKNOT,YISUNLOADABLE);
            IF YISUNLOADABLE THEN
            BEGIN
                 {  BUILD "Y" 'S COPY }
                 AFIRSTINLOADED:=FIRSTINLOADED;
                 FIRSTINLOADED:=NIL;
                 FIRSTLINK:=NIL;
                 FIRSTPLINK:=NIL;
                 LASTPLINK:=NIL;
                 MINORD:=10000;
                 MAXORD:=0;
                 BUILDCOPY(LOWLEVELKNOT,YPTR);
                 TUNELOADED;
                 {  FORALL CORRESP. MODELS IN "Y" :                  }
                 {  ADD TO "Y" 'S MODEL ALL OUT-OF-X REFS OF CORESP. }
                 {  MODELS IN "X".                                   }
                 REGISTRATE(PKBECHANGED,XISUNLOADABLE);
                 IF NOT WASBADOPERATOR THEN
                 BEGIN
                       IF NOT XISUNLOADABLE THEN CHANGELINKS;
                       MEMPKBECHANGED@.TARGET:=YPTR;
                       YPTR@.PTOWNER:=CURROOT;
                       YPTR@.NAME:=PKBECHANGED@.NAME;
                       ADDREFS(PKBECHANGED,YPTR);
                       IOSUBSTITUTE(PKBECHANGED,YPTR,CURROOT);
                       REMOVEALL(PKBECHANGED,AFIRSTINLOADED);
                       CATSEQ(AFIRSTINLOADED); {  Y"S TO A"S }
                 END;
                 FIRSTINLOADED:=AFIRSTINLOADED;
           END
           ELSE ERROR(502)
           END
           ELSE ERROR(103)
      END
      ELSE ERROR(418)
 END;
 PROCEDURE MULTIUNNAMED;
 {  WORKUP "NAME.*" SHABLON }
 VAR
    CURMEMB:PTLISTMEMB;
    GENERATED:BOOLEAN;
 BEGIN
      IF WASBADOPERATOR THEN LOWLEVELKNOT:=NIL;
      IF LOWLEVELKNOT <> NIL THEN
      BEGIN
           IF LOWLEVELKNOT@.KNOTSUBTYPE <> STRUCTUREK
           THEN ERROR(140)
           ELSE
           BEGIN
                CURMEMB:=LOWLEVELKNOT@.PTMEMBLIST;
                IF CURMEMB = NIL THEN ERROR(152)
                ELSE
                BEGIN
                     GENERATED:=FALSE;
                     WHILE CURMEMB <> NIL DO
                     BEGIN
                          IF CURMEMB@.TARGET@.KNOTTYPE = VARK THEN
                          BEGIN
                          GENERATED:=TRUE;
                          LOWLEVELKNOT:=CURMEMB@.TARGET;
                          ATTACHNAME;
                          SETNAMEINEXPRESSION;
                          END;
                          CURMEMB:=CURMEMB@.NEXT
                     END
                END;
                IF NOT GENERATED THEN ERROR(891)
            END
        END
        ELSE
        BEGIN
        IF NOT WASBADOPERATOR THEN ERROR(104)
        END
 END;
 PROCEDURE MULTINAMED;
 {  WKP "NAME.*.SIMPLENAME" SHHBLON }
 VAR
    CURMEMB:PTLISTMEMB;
    OURMEM: PTLISTMEMB;
    GENERATED:BOOLEAN;
 BEGIN
      ENDNAME;
      IF WASBADOPERATOR THEN LOWLEVELKNOT:=NIL;
      IF LOWLEVELKNOT <> NIL THEN
      BEGIN
           IF LOWLEVELKNOT@.KNOTSUBTYPE <> STRUCTUREK THEN ERROR(140)
           ELSE
           BEGIN
                CURMEMB:=LOWLEVELKNOT@.PTMEMBLIST;
                GENERATED:=FALSE;
                WHILE CURMEMB <> NIL DO
                BEGIN
                     IF CURMEMB@.TARGET@.KNOTSUBTYPE = STRUCTUREK THEN
                     BEGIN
                          OURMEM:=CURMEMB@.TARGET@.PTMEMBLIST;
                          WHILE OURMEM <> NIL DO
                          BEGIN
                               IF (OURMEM@.TARGET@.NAME = NAMETEXT)
                                               AND
                                  (OURMEM@.TARGET@.KNOTTYPE = VARK) THEN
                               BEGIN
                                    GENERATED:=TRUE;
                                    LOWLEVELKNOT:=OURMEM@.TARGET;
                                    ATTACHNAME;
                                    SETNAMEINEXPRESSION;
                                END;
                                OURMEM:=OURMEM@.NEXT;
                            END
                      END;
                      CURMEMB:=CURMEMB@.NEXT;
                 END;
                 IF NOT GENERATED THEN ERROR(891)
             END
       END
       ELSE
       BEGIN
            IF NOT WASBADOPERATOR THEN ERROR(104)
        END
 END;

     {  ---------------------------------------------------- }
     {     THE   A M G   PROCEDURE SEGMENT                   }
     {  ---------------------------------------------------- }
 PROCEDURE INITAMG;
 {  ARCHIVE-MANAGER INITIALIZATION }
 BEGIN
      FIRSTSAVE:=NIL;
      ENDOFARCHIVE:=FALSE;
      FIRSTLINK:=NIL;
      NEW(HEADER);
      HEADER@.KNOTTYPE:=HEADERK;
 END;
 PROCEDURE CHECKUP(K:PTKNOT;PTBOSS:PTKNOT;VAR UNLOADABLE:BOOLEAN);
 VAR CUROWNER:PTKNOT;
 BEGIN
      UNLOADABLE:=FALSE;
      CUROWNER:=K@.PTOWNER;
      IF CUROWNER <> NIL THEN
      REPEAT
            IF CUROWNER@.ORDVALUE = PTBOSS@.ORDVALUE
            THEN UNLOADABLE:=TRUE;
            CUROWNER:=CUROWNER@.PTOWNER
      UNTIL (CUROWNER = NIL) OR UNLOADABLE
 END;
 PROCEDURE CHECKIO(PTMEMB:PTKNOT;PTBOSS:PTKNOT;
                   VAR UNLOADABLE:BOOLEAN); FORWARD;
 PROCEDURE CHECKIO;
 VAR
    CURMEMB:PTLISTMEMB;
    CURIO:PTLISTMEMB;
 BEGIN
      UNLOADABLE:=TRUE;
      CURIO:=PTMEMB@.PTILIST;
      WHILE (CURIO <> NIL) AND UNLOADABLE DO
      BEGIN
           CHECKUP(CURIO@.TARGET,PTBOSS,UNLOADABLE);
           CURIO:=CURIO@.NEXT
      END;
      IF UNLOADABLE THEN
      BEGIN
           CURIO:=PTMEMB@.PTOLIST;
           WHILE (CURIO <> NIL) AND UNLOADABLE DO
           BEGIN
                CHECKUP(CURIO@.TARGET,PTBOSS,UNLOADABLE);
                CURIO:=CURIO@.NEXT
           END;
           IF UNLOADABLE THEN
           BEGIN
                IF (PTMEMB@.KNOTTYPE = VARK) AND
                   (PTMEMB@.KNOTSUBTYPE = STRUCTUREK) THEN
                BEGIN
                     CURMEMB:=PTMEMB@.PTMEMBLIST;
                     WHILE (CURMEMB <> NIL) AND UNLOADABLE DO
                     BEGIN
                          CHECKIO(CURMEMB@.TARGET,PTBOSS,UNLOADABLE);
                          CURMEMB:=CURMEMB@.NEXT
                     END
                END
          END
     END
 END;
 PROCEDURE CHECKEXTREF; {  PT:PTKNOT;VAR UNLOADABLE:BOOLEAN }
 VAR
    CURMEMB:PTLISTMEMB;
  BEGIN
       UNLOADABLE:=TRUE;
       IF PT@.PTOLIST <> NIL THEN UNLOADABLE:=FALSE;
       IF PT@.PTILIST <> NIL THEN UNLOADABLE:=FALSE;
       IF UNLOADABLE AND (PT@.KNOTSUBTYPE = STRUCTUREK) THEN
       BEGIN
            CURMEMB:=PT@.PTMEMBLIST;
            WHILE (CURMEMB <> NIL) AND UNLOADABLE DO
            BEGIN
                 CHECKIO(CURMEMB@.TARGET,PT,UNLOADABLE);
                 CURMEMB:=CURMEMB@.NEXT
            END
       END
 END;
 PROCEDURE PUTKNOT(PT:PTKNOT);
 BEGIN
      ARCHIVE@:=PT@; PUT(ARCHIVE)
 END;
 PROCEDURE NAMEFROMSTARTOFKNOT(VAR NAME:NAMEOBJ);
 BEGIN
      NAME:=ARCHIVE@.NAMEOFNEXT
 END;
 PROCEDURE MINMAXORD(I:INTEGER);
 BEGIN
      IF I < MINORD THEN MINORD:=I;
      IF I > MAXORD THEN MAXORD:=I
  END;
PROCEDURE NEWLINK(LINKTYPE:REFTYPE;LINKVALUE:INTEGER;FROMVALUE:INTEGER);
{  ADD NEW LINK INFORMATION ABOUT LOADING MODEL }
 VAR
    NEWLINK:LINKMEMB;
 BEGIN
      MINMAXORD(LINKVALUE);
      MINMAXORD(FROMVALUE);
      NEW(NEWLINK);
      NEWLINK@.LINKTYPE:=LINKTYPE;
      NEWLINK@.LINKVALUE:=LINKVALUE;
      NEWLINK@.FROMVALUE:=FROMVALUE;
      NEWLINK@.NEXT:=FIRSTLINK;
      FIRSTLINK:=NEWLINK
 END;
 PROCEDURE NEWPARMLINK(LINKVALUE:INTEGER;FROMVALUE:INTEGER);
 {  ADD NEW PARM LINK INFORMATION }
 VAR NEWLINK:LINKMEMB;
 BEGIN
      NEW(NEWLINK);
      NEWLINK@.LINKVALUE:=LINKVALUE;
      NEWLINK@.FROMVALUE:=FROMVALUE;
      NEWLINK@.NEXT:=NIL;
      IF FIRSTPLINK = NIL
      THEN
      BEGIN
           FIRSTPLINK:=NEWLINK;
           LASTPLINK:=NEWLINK;
      END
      ELSE
      BEGIN
           LASTPLINK@.NEXT:=NEWLINK;
           LASTPLINK:=NEWLINK
      END
 END;
 PROCEDURE GETKNOT;
 BEGIN
      GET(ARCHIVE)
 END;
 PROCEDURE INLOAD(VAR HEAD:PTKNOT);
 {  THIS IS THE (REVERSED) "UNLOAD" PROCEDURE;IT READS THE MODEL  }
 {  INTO MAIN STORAGE. REFR TO ITS HEAD LOCATES INTO "HEAD".      }
 {  ALL OWNER-MEMBER LINKS BE RESOLVED & CORRESPONDINGS FIELDS    }
 {  BE CHANGED BUT ALL IN-OUT LINKS NOT BE RESOLVED. IT MAY BE    }
 {  SAVED INTO "FIRSTLINK" 'S LIST WHICH IS BUILDEN IN "LOADMODEL"}
 {  PROCEDURE. I/O HEAD ALRDY LOCATED UNDER "STARTOFKNOT" HEADER.  }
 {  THE ORDER-NUMBERS NOT BE CHANGED IN THIS PROCEDURE.           }
 VAR
    TYPEOFHEAD:TKNOT;
    SUBTYPEOFHEAD:SUBTKNOT;
    REFHEADER:BOOLEAN;
    MEMBER:BOOLEAN;
    PTMEMBER:PTKNOT;
    PARMLINK:BOOLEAN;
    CURMEMB:PTLISTMEMB;
PROCEDURE ISITREFHEADER;
BEGIN
     REFHEADER:=FALSE;
     IF ARCHIVE@.HDRNAME = REFERENCE THEN REFHEADER:=TRUE
END;
PROCEDURE ISITPARMLINK;
BEGIN
     PARMLINK :=FALSE;
     IF ARCHIVE@.HDRNAME = PARAMETER THEN PARMLINK:=TRUE
END;
PROCEDURE ISITMEMBER;
BEGIN
     MEMBER:=FALSE;
     IF ARCHIVE@.HDRNAME = STARTOFKNOT THEN
        IF ARCHIVE@.ORDNUMOFOWNER = HEAD@.ORDVALUE
           THEN MEMBER:=TRUE;
END;
  {  -------- START OF "INLOAD" BODY --------- }
  BEGIN
       GETKNOT; {  SKIP HEADER }
       NEW(HEAD);
       HEAD@:=ARCHIVE@;
       {  GET KNOT BODY }
       MINMAXORD(HEAD@.ORDVALUE);
       IF (HEAD@.KNOTTYPE = RELK) AND (HEAD@.NAME[ 1 ] = '&') THEN
       BEGIN
            GENUNICAL;
            HEAD@.NAME:=UNICALNAME
       END;
       HEAD@.NEXT:=FIRSTINLOADED;
       HEAD@.PTOLIST:=NIL;
       HEAD@.PTILIST:=NIL;
       HEAD@.PTMEMBLIST:=NIL;
       HEAD@.PTOWNER:=NIL;
       HEAD@.GENERATION:=0;
       HEAD@.FIRSTPARM:=NIL;
       FIRSTINLOADED:=HEAD;
       GETKNOT; {  POINT TO NEXT HEADER }
       IF (HEAD@.KNOTTYPE = VARK)
          AND
          (HEAD@.KNOTSUBTYPE = STRUCTUREK) THEN
       BEGIN
            HEAD@.PTMEMBLIST:=NIL;
            REPEAT
                 NEW(CURMEMB);
                 CURMEMB@.NEXT:=HEAD@.PTMEMBLIST;
                 INLOAD(CURMEMB@.TARGET);
                 CURMEMB@.TARGET@.PTOWNER:=HEAD;
                 HEAD@.PTMEMBLIST:=CURMEMB;
                 ISITMEMBER
           UNTIL (NOT MEMBER)
       END;
       {  IF "REFERENCE" HEADERS FOLLOWS, THEN WORKUP IT }
       ISITREFHEADER;
       WHILE REFHEADER DO
       BEGIN
            NEWLINK(ARCHIVE@.LINKTYPE,ARCHIVE@.LINKVALUE,
                         HEAD@.ORDVALUE);
            GETKNOT;
            ISITREFHEADER
       END;
       ISITPARMLINK;
       WHILE PARMLINK DO
       BEGIN
             NEWPARMLINK(ARCHIVE@.LINKVALUE,HEAD@.ORDVALUE);
             GETKNOT;
             ISITPARMLINK
       END;
       {  ALL LINKS ARE WORKUPPED; NEXT HEADER MAY BE }
       {       STARTOFKNOT ONLY IF HEAD IS THE STUCTURE }
       {  IS THE HEAD IS NOT THE STRUCTURE, MUST BE "LASTINMODEL" }
 END;
 PROCEDURE UNLOAD(PK:PTKNOT);
 {  WRITE MODEL TO ARCHIVE FROM MAIN-STORAGE-NET }
 VAR
    CURMEMB:PTLISTMEMB;
 BEGIN
      {  SAVE HEADER WITH PK@-NAME & PK@-VARSUBTYPE }
      HEADER@.HDRNAME:=STARTOFKNOT;
      HEADER@.NAMEOFNEXT:=PK@.NAME;
      IF PK@.PTOWNER <> NIL
      THEN HEADER@.ORDNUMOFOWNER:=PK@.PTOWNER@.ORDVALUE
      ELSE HEADER@.ORDNUMOFOWNER:=0;
      PUTKNOT(HEADER);
      {  SAVE MODEL }
      PUTKNOT(PK);
      {  IF THIS IS A STRUCTURE ,THEN  SAVE  ALL COMPONENTS }
      IF (PK@.KNOTTYPE = VARK) AND
         (PK@.KNOTSUBTYPE = STRUCTUREK) THEN
      BEGIN
           CURMEMB:=PK@.PTMEMBLIST;
           WHILE CURMEMB <> NIL DO
           BEGIN
                UNLOAD(CURMEMB@.TARGET);
                CURMEMB:=CURMEMB@.NEXT
           END
       END;
       {  IF I/O REFERENCES ARE PRESENT, THEN UNLOAD THEM }
       HEADER@.HDRNAME:=REFERENCE;
       IF PK@.PTILIST <> NIL THEN
       BEGIN
            CURMEMB:=PK@.PTILIST;
            REPEAT
                  HEADER@.LINKTYPE:=INLINK;
                  HEADER@.LINKVALUE:=CURMEMB@.TARGET@.ORDVALUE;
                  PUTKNOT(HEADER);
                  CURMEMB:=CURMEMB@.NEXT
            UNTIL CURMEMB = NIL
        END;
       IF PK@.PTOLIST <> NIL THEN
       BEGIN
            CURMEMB:=PK@.PTOLIST;
            REPEAT
                  HEADER@.LINKTYPE:=OUTLINK;
                  HEADER@.LINKVALUE:=CURMEMB@.TARGET@.ORDVALUE;
                  PUTKNOT(HEADER);
                  CURMEMB:=CURMEMB@.NEXT
            UNTIL CURMEMB = NIL
        END;
        IF (PK@.KNOTSUBTYPE = EQNK) OR
           (PK@.KNOTSUBTYPE = MODULEK) THEN
        BEGIN
             HEADER@.HDRNAME:=PARAMETER;
             CURMEMB:=PK@.FIRSTPARM;
             REPEAT
                   HEADER@.LINKVALUE:=CURMEMB@.TARGET@.ORDVALUE;
                   PUTKNOT(HEADER);
                   CURMEMB:=CURMEMB@.NEXT
             UNTIL CURMEMB = NIL
       END
 END;
 PROCEDURE BUILDCOPY; {  PROTOTYPE:PTKNOT;VAR HEAD:PTKNOT }
 {  SUCH AS "INLOAD" BUT FROM THE MAIN-STORAGE - LOOK "INLOAD" }
 VAR
    CURMEMB:PTLISTMEMB;
    NEWMEMB:PTLISTMEMB;
    CURLINKM:PTLISTMEMB;
 BEGIN
      NEW(HEAD);
      HEAD@:=PROTOTYPE@;
      IF (HEAD@.KNOTTYPE = RELK) AND (HEAD@.NAME[ 1 ] = '&') THEN
      BEGIN
           GENUNICAL;
           HEAD@.NAME:=UNICALNAME;
      END;
      MINMAXORD(HEAD@.ORDVALUE);
      HEAD@.NEXT:=FIRSTINLOADED;
      HEAD@.PTILIST:=NIL;
      HEAD@.PTOLIST:=NIL;
      HEAD@.PTMEMBLIST:=NIL;
      HEAD@.GENERATION:=0;
      HEAD@.FIRSTPARM:=NIL;
      HEAD@.PTOWNER:=NIL;
      FIRSTINLOADED:=HEAD;
      IF (HEAD@.KNOTTYPE = VARK)
                   AND
         (HEAD@.KNOTSUBTYPE = STRUCTUREK) THEN
      BEGIN
           HEAD@.PTMEMBLIST:=NIL;
           CURMEMB:=PROTOTYPE@.PTMEMBLIST;
           WHILE CURMEMB <> NIL DO
           BEGIN
                NEW(NEWMEMB);
                NEWMEMB@.NEXT:=HEAD@.PTMEMBLIST;
                HEAD@.PTMEMBLIST:=NEWMEMB;
                BUILDCOPY(CURMEMB@.TARGET,NEWMEMB@.TARGET);
                NEWMEMB@.TARGET@.PTOWNER:=HEAD;
                CURMEMB:=CURMEMB@.NEXT;
           END;
      END;
      CURLINKM:=PROTOTYPE@.PTILIST;
      HEAD@.PTILIST:=NIL;
      WHILE CURLINKM <> NIL DO
      BEGIN
      NEWLINK(INLINK,CURLINKM@.TARGET@.ORDVALUE,PROTOTYPE@.ORDVALUE);
      CURLINKM:=CURLINKM@.NEXT;
      END;
      CURLINKM:=PROTOTYPE@.PTOLIST;
      HEAD@.PTOLIST:=NIL;
      WHILE CURLINKM <> NIL DO
      BEGIN
      NEWLINK(OUTLINK,CURLINKM@.TARGET@.ORDVALUE,PROTOTYPE@.ORDVALUE);
      CURLINKM:=CURLINKM@.NEXT;
      END;
      IF (PROTOTYPE@.KNOTSUBTYPE = EQNK) OR
         (PROTOTYPE@.KNOTSUBTYPE = MODULEK) THEN
      BEGIN
           CURLINKM:=PROTOTYPE@.FIRSTPARM;
           WHILE CURLINKM <> NIL DO
           BEGIN
                NEWPARMLINK(CURLINKM@.TARGET@.ORDVALUE,
                            PROTOTYPE@.ORDVALUE);
                CURLINKM:=CURLINKM@.NEXT
           END
     END;
 END;
 PROCEDURE AMGSAVE;
 {  MARK MODEL AS BE SAVED DURING "AMGPROCESS" }
 VAR
    PRESENT:BOOLEAN;
    NEWSAVE:PTLISTMEMB;
    UNLOADABLE:BOOLEAN;
 BEGIN
      {  NAME MUST BE DEFINED AT SOME PARENT LEVEL }
      IF LOWLEVELKNOT <> NIL
      THEN
      BEGIN
           IF LOWLEVELKNOT@.KNOTTYPE <> VARK
           THEN ERROR(103)
           ELSE
           BEGIN
                CHECKPNAME(FIRSTSAVE,LOWLEVELKNOT@.NAME,PRESENT);
                IF PRESENT THEN ERROR(501)
                ELSE
                BEGIN
                     {  IF I/O LINKS OUT OF THIS MODEL ARE PRESENT }
                     {  THEN UNLOADABLE                            }
                     CHECKEXTREF(LOWLEVELKNOT,UNLOADABLE);
                     IF NOT UNLOADABLE THEN ERROR(502)
                     ELSE
                     BEGIN
                          NEW(NEWSAVE);
                          NEWSAVE@.TARGET:=LOWLEVELKNOT;
                          NEWSAVE@.NEXT:=FIRSTSAVE;
                          FIRSTSAVE:=NEWSAVE
                     END
                END
            END
       END
       ELSE ERROR(104)
 END;
 PROCEDURE AMGPROCESS;
 VAR
    CURSAVE:PTLISTMEMB;
    PRESENT:BOOLEAN;
    NAME:NAMEOBJ;
 BEGIN
       {  ---------------- UNLOAD "SAVE" MARKED MODELS --------- }
       CURSAVE:=FIRSTSAVE;
       WHILE CURSAVE <> NIL DO
       BEGIN
            SETFILEOUT(CURSAVE@.TARGET);
            UNLOAD(CURSAVE@.TARGET);
            {  UNLOAD THE END-OF MODEL HEADER }
            HEADER@.HDRNAME:=LASTINMODEL;
            PUTKNOT(HEADER);
            CURSAVE:=CURSAVE@.NEXT
       END;
 END;
 PROCEDURE LOADMODEL;
 {  LOAD MODEL FROM THE ARCHIVE. REF TO HEAD WE LOCATE AT "CURROOT" }
 VAR
    PRESENT:BOOLEAN;
    UNLOADABLE:BOOLEAN;
 BEGIN
      IF NOT WASBADOPERATOR THEN
      BEGIN
           FIRSTLINK:=NIL;
           FIRSTPLINK:=NIL;
           LASTPLINK :=NIL;
           MINORD:=10000;
           MAXORD:=0;
           FIRSTINLOADED:=NIL;
           IF LOWLEVELKNOT = NIL
           THEN BEGIN
                     IF COMPOUNDNAME THEN ERROR(104)
                     ELSE
                     BEGIN
                          FINDMODEL(NAMETEXT,PRESENT);
                          IF NOT PRESENT
                          THEN ERROR(414)
                          ELSE
                          BEGIN
                               SETFILEIN(NAMETEXT);
                               INLOAD(CURROOT)
                          END
                     END
                END
           ELSE BEGIN
                     CHECKEXTREF(LOWLEVELKNOT,UNLOADABLE);
                     IF NOT UNLOADABLE THEN ERROR(502)
                     ELSE BUILDCOPY(LOWLEVELKNOT,CURROOT)
                END
      END
 END;
     {  ---------------------------------------------------- }
     {     THE SYNTAX-ANALYZER P R O C E D U R E  SEGMENT    }
     {  ----------------------------------------------------- }
     PROCEDURE WRITEERR;FORWARD;
     PROCEDURE PROMPT;FORWARD;
     PROCEDURE GETCHAR;FORWARD;
     PROCEDURE GOFORWARD; FORWARD;
     PROCEDURE GETLEXEMA;FORWARD;
     PROCEDURE TERM;FORWARD;
     PROCEDURE SIMPLEEXPRESSION;FORWARD;
     PROCEDURE HOWENDS(VAR OURSEPARATOR:BOOLEAN);FORWARD;
     PROCEDURE EXPRESSION;FORWARD;
     PROCEDURE SIMPLENAME;FORWARD;
     PROCEDURE NAME;FORWARD;
     PROCEDURE IVAR;FORWARD;
     PROCEDURE DOE;FORWARD;
     PROCEDURE IRVAR;FORWARD;
     PROCEDURE DOCONST;FORWARD;
     PROCEDURE DOOUT;FORWARD;
     PROCEDURE DOCOPY;FORWARD;
     PROCEDURE OPERATOR;FORWARD;
     PROCEDURE CHKOP;
     BEGIN
          IF WASBADOPERATOR AND (CURCHAR <> ';') AND
             (CURCHAR <> '!') AND ( NOT WASEOF )     THEN
             BEGIN
                  REPEAT
                        GOFORWARD
                  UNTIL (CURCHAR=';') OR (CURCHAR='!') OR WASEOF
             END;
             WASBADOPERATOR:=FALSE;
             COMPLETE:=TRUE;
             OPNUMBER:=OPNUMBER+1;
             IF OPNUMBER > 998 THEN OPNUMBER:=0
 END;
 PROCEDURE MODEL;
 BEGIN
      OPERATOR;
      CHKOP;
      WHILE CURCHAR = ';' DO
            BEGIN
                 GOFORWARD;
                 OPERATOR;
                 CHKOP
             END
 END;
 PROCEDURE PAIR;
 BEGIN
      {  MDB }  PASSNAME;
      SIMPLENAME;
      {  MDB }  ENDNAME;
      IF CURCHAR <> '=' THEN ERROR(19);
      {  MDB }  IF NOT WASBADOPERATOR THEN GETBECHANGED;
      GOFORWARD;
      NAME;
      IF NOT WASBADOPERATOR THEN CHANGE
 END;
 PROCEDURE DOCOPY;
 BEGIN
      { AMG}  ERR1520:=IGNORE;
      NAME;
      { AMG}  ERR1520:=WORKUP;
      { AMG}  LOADMODEL;
      { MDB}  IF NOT WASBADOPERATOR THEN TUNELOADED;
      IF CURCHAR = ' ' THEN
         BEGIN
              GOFORWARD;
              PAIR;
              WHILE CURCHAR = ',' DO
                    BEGIN
                         GOFORWARD;
                         PAIR
                    END
         END;
 END;
 PROCEDURE INITIAL; {  INITIAL }
 BEGIN
      WASEOLN:=FALSE;
      WASEOF:=FALSE;
      INACTIONS:=FALSE;
      PASCLINES:=0;
      WASLINESEPARATOR:=FALSE;
      SUBTITLE:='SOURCE MODEL LISTING    ';
      TERMINAL:=FALSE;  {  DEFAULT = BATCH  }     {  CHANGE IF NEEDED }
      DUPLEX:=FULL;{  FULL COPY OF INPUT }       {  CHANGE IF NEEDED }
      FIRSTZUCK:=NIL;
      INEXPRESSION:=FALSE;
      WASBADOPERATOR:=FALSE;
      WRITELN;
      PAGECOUNT:=0;
      ERRCOUNT:=0;
      OBJCOUNT:=0;
      IF NOT TERMINAL THEN BEGIN PRINTTITLE; LINECOUNT:=1 END;
      COMPLETE:=TRUE;
      OPNUMBER:=1;
      PROMPTSKIP:=0;
      PROMPT;
      CURPOS:=0;
      FROMBUFCHAR:=FALSE;
      DIGIT:=FALSE;
      LETTER:=FALSE;
      SIMILAR:=FALSE;
      CURCHAR:=' ';
      {  MDB }  INITMDB;
      {  AMG }  INITAMG;
      GOFORWARD
 END;
 PROCEDURE PRINTTITLE;
 VAR I:INTEGER;
 BEGIN
      WRITELN;
      WRITE(' FPS '); WRITE(VERSION); WRITE(' ');
      FOR I:=1 TO (58-VERSLENGTH) DO WRITE(' ');
      WRITE(' PAGE ');
      PAGECOUNT:=PAGECOUNT+1;
      IF PAGECOUNT > 99 THEN PAGECOUNT:=1;
      WRITELN(PAGECOUNT:2);
      WRITE(' FIT PROBLEM SOLVER - ');
      WRITELN(SUBTITLE);
      WRITELN
 END;
 PROCEDURE DOAREL;
 BEGIN
        CASE CURLEX OF
 MODULE:BEGIN
             IF CURCHAR <> ' ' THEN ERROR(24);
             GOFORWARD;
             {  MDB }  PASSNAME;
             SIMPLENAME;
             IF CURCHAR <> ' ' THEN ERROR(24);
             {  MDB }  GETMODULE;
             GOFORWARD;
             GETLEXEMA;
             {  MDB }  INMODULE:=TRUE;
             {  MDB }  INEXPRESSION:=TRUE;
             IF CURLEX IN [AIN,OUT]
                THEN
                    CASE CURLEX OF
                         AIN:BEGIN
                                  IF CURCHAR <> ' ' THEN ERROR(24);
                                  { MDB}  INNAMEINEXPRESSION:=TRUE;
                                  GOFORWARD;
                                  NAME;
                                  {  MDB }  ATTACHNAME;
                                  {  MDB }  INNAMEINEXPRESSION:=FALSE;
                                  {  MDB }  SETNAMEINEXPRESSION;
                                  WHILE CURCHAR = ','  DO
                                        BEGIN
                                             { MDB* NEXT OPERATOR }
                                             INNAMEINEXPRESSION:=TRUE;
                                             GOFORWARD;
                                             NAME;
                                             { MDB} ATTACHNAME;
                                             { MDB* NEXT 2 OPERATORS }
                                             INNAMEINEXPRESSION:=FALSE;
                                             SETNAMEINEXPRESSION;
                                         END;
                                  IF CURCHAR <> ' ' THEN ERROR(24);
                                  GOFORWARD;
                                  GETLEXEMA;
                                  IF CURLEX <> OUT THEN ERROR(63);
                                  {  MDB }  MDBMDL9;
                                  DOOUT
                             END;
                        OUT: DOOUT
                     END
                 ELSE ERROR(63);
                 {  MDB }  INEXPRESSION:=FALSE;
                 {  MDB }  INMODULE:=FALSE;
                 {  MDB }  MDBMDL8
          END;
     EQN: BEGIN
               IF CURCHAR = ' ' THEN GOFORWARD;
               {  MDB }  GETEQN;
               {  MDB }  INEXPRESSION:=TRUE;
               SIMPLEEXPRESSION;
               IF CURCHAR <> '=' THEN ERROR(16);
               { MDB}  IF IEPASS < 1 THEN IEPASS:=1;
               { MDB}  EXPRTEXT[IEPASS]:='-';
               { MDB}  IF IEPASS < LINELENGTH THEN IEPASS:=IEPASS+1
               { MDB}                 ELSE ERROR(400);
               { MDB}  EXPRTEXT[ IEPASS ]:='(';
               GOFORWARD;
               SIMPLEEXPRESSION;
               {  MDB }  INEXPRESSION:=FALSE;
               { MDB}  IF IEPASS < 1 THEN IEPASS:=1;
               { MDB}  EXPRTEXT[ IEPASS ]:=')';
               { MDB}  IF IEPASS < LINELENGTH THEN IEPASS:=IEPASS+1
               { MDB}                 ELSE ERROR(400);
               { MDB}  NEWEQN
          END;
      LET: BEGIN
                IF CURCHAR <> ' ' THEN ERROR(24);
                 GOFORWARD;
                 NAME;
                 IF CURCHAR <> '=' THEN ERROR(16);
                 GOFORWARD;
                 {  MDB }  GETLEFT;
                 {  MDB }  INEXPRESSION:=TRUE;
                 EXPRESSION;
                 {  MDB }  INEXPRESSION:=FALSE;
                 {  MDB }  ADDLET
            END
      END
 END;
 PROCEDURE DOE;
 BEGIN
      IF (CURCHAR = '+') OR (CURCHAR = '-') THEN GOFORWARD;
      IVAR
 END;
 PROCEDURE IRVAR;
 BEGIN
      IVAR;
      IF (CURCHAR = '.') OR (CURCHAR = 'E') THEN
         CASE CURCHAR OF
         '.': BEGIN
                   GOFORWARD;
                   WHILE DIGIT DO GOFORWARD;
                   IF CURCHAR = 'E' THEN
                      BEGIN
                           GOFORWARD;
                           DOE
                      END
              END;
          'E': BEGIN
                    GOFORWARD;
                    DOE
                END
            END
 END;
 PROCEDURE DOCONST;
 VAR ENDOFSTRING:BOOLEAN;
 BEGIN
      IF (CURCHAR = '+') OR (CURCHAR = '-') OR (CURCHAR = '''') THEN
      CASE CURCHAR OF
      '+','-':BEGIN
                   GOFORWARD;
                   IRVAR
               END;
        '''':  BEGIN
                    ENDOFSTRING:=FALSE;
                    REPEAT
                          GOFORWARD;
                          IF CURCHAR='''' THEN
                             BEGIN
                                  GOFORWARD;
                                  IF CURCHAR <> ''''
                                  THEN ENDOFSTRING:=TRUE;
                             END
                    UNTIL ENDOFSTRING OR WASEOF;
                    IF WASEOF THEN ERROR(202)
               END
         END
                                    ELSE
         IRVAR
 END;
 PROCEDURE DOOUT;
 BEGIN
      IF CURCHAR <> ' ' THEN ERROR(24);
      { MDB}  INNAMEINEXPRESSION:=TRUE;
      GOFORWARD;
      NAME;
      {  MDB }  ATTACHNAME;
      {  MDB }  INNAMEINEXPRESSION:=FALSE;
      {  MDB }  SETNAMEINEXPRESSION;
      WHILE CURCHAR = ',' DO
            BEGIN
                 {  MDB }  INNAMEINEXPRESSION:=TRUE;
                 GOFORWARD;
                 NAME;
                 {  MDB }  ATTACHNAME;
                 {  MDB }  INNAMEINEXPRESSION:=FALSE;
                 {  MDB }  SETNAMEINEXPRESSION;
             END
 END;
 PROCEDURE SIMPLEEXPRESSION;
 VAR OURSEPARATOR:BOOLEAN;
 BEGIN
      TERM;
      HOWENDS(OURSEPARATOR);
      WHILE OURSEPARATOR DO
            BEGIN
                 GOFORWARD;
                 TERM;
                 HOWENDS(OURSEPARATOR)
            END;
 END;
 PROCEDURE HOWENDS;
 BEGIN
      IF (CURCHAR = '+') OR (CURCHAR = '-') OR (CURCHAR = '*')
                                            OR (CURCHAR = '/')
         THEN OURSEPARATOR:=TRUE
         ELSE
         BEGIN
              IF CURCHAR = ' ' THEN
                 BEGIN
                      GOFORWARD;
                      GETLEXEMA;
                      IF NOT (CURLEX IN [AOR,AAND]) THEN ERROR(27);
                      IF CURCHAR <> ' ' THEN ERROR(24);
                      OURSEPARATOR:=TRUE
                 END
                          ELSE
                 OURSEPARATOR:=FALSE
       END
 END;
 PROCEDURE EXPRESSION;
 BEGIN
      SIMPLEEXPRESSION;
      IF (CURCHAR = '=') OR (CURCHAR = '<') OR (CURCHAR = '>') THEN
      BEGIN
         CASE CURCHAR OF
         '=': BEGIN
                   GOFORWARD
              END;
         '<': BEGIN
                   GOFORWARD;
                   IF (CURCHAR = '=') OR (CURCHAR = '>')
                      THEN GOFORWARD
               END;
          '>': BEGIN
                    GOFORWARD;
                    IF CURCHAR = '=' THEN GOFORWARD
              END
          END;
         SIMPLEEXPRESSION
      END
 END;
 PROCEDURE SIMPLENAME;
 BEGIN
      IF NOT LETTER THEN ERROR(59);
      GOFORWARD;
      WHILE  LETTER OR DIGIT DO GOFORWARD;
 END;
 PROCEDURE SHABLON(VAR SHABLOCCURS:BOOLEAN);
 BEGIN
      INSHABLON:=TRUE;
      IF SHABLOCCURS THEN ERROR(889);
      SHABLOCCURS:=TRUE;
      IF NOT INMODULE THEN ERROR(888);
      GOFORWARD;
      IF CURCHAR = '.' THEN
      BEGIN
           GOFORWARD;
           { MDB}  PASSNAME;
           SIMPLENAME;
           { MDB}  MULTINAMED
       END
       ELSE
       BEGIN
            { MDB}  MULTIUNNAMED;
            GOFORWARD
       END;
       LOWLEVELKNOT:=NIL
 END;
 PROCEDURE NAME;
 VAR
    SHABLOCCURS:BOOLEAN;
 BEGIN
      { MDB}  COMPOUNDNAME:=FALSE;
       {  MDB }  PASSNAME;
      SIMPLENAME;
      {  MDB }  FINDQUAL;
      {  MDB }  IF (CURCHAR <> '.') AND (LOWLEVELKNOT = NIL)
                                    AND (NOT WASBADOPERATOR)
                                    AND INEXPRESSION
                THEN {  THIS IS AN EXTRN NAME - MUST BE REGISTERED }
      {  MDB }  ADDEXTRN;
      SHABLOCCURS:=FALSE;
      WHILE CURCHAR = '.' DO
            BEGIN
                 IF INSHABLON THEN ERROR(892);
                 { AMG}  COMPOUNDNAME:=TRUE;
                 GOFORWARD;
                 IF CURCHAR = '*' THEN SHABLON(SHABLOCCURS)
                 ELSE
                 BEGIN
                 {  MDB }  PASSNAME;
                 SIMPLENAME;
                 {  MDB }  FINDMEMB;
                 END
            END;
            SHABLOCCURS:=FALSE
 END;
 PROCEDURE IVAR;
 BEGIN
      IF NOT DIGIT THEN ERROR(15);
      WHILE  DIGIT DO GOFORWARD;
      IF      LETTER THEN
              BEGIN
                   ERROR(50);
                   WHILE SIMILAR
                         DO GOFORWARD
              END
 END;
 PROCEDURE GETCHAR;
 LABEL 1;
 BEGIN
      IF WASEOF
      THEN BEGIN
                IF DUPLEX = FULL THEN WRITELN;
                WRITEERR;
                CURPOS:=1;
                CURCHAR:='?'
           END
      ELSE BEGIN
                READ(CURCHAR);
                CURPOS:=CURPOS+1;
                IF EOF(INPUT) THEN WASEOF:=TRUE;
                IF WASEOLN OR (TERMINAL AND EOLN(INPUT))
                THEN BEGIN
                          WASLINESEPARATOR:=TRUE;
                          WASEOLN:=FALSE
                     END
                ELSE BEGIN
                          IF EOLN(INPUT) THEN WASEOLN:=TRUE;
                          IF WASLINESEPARATOR THEN
                          BEGIN
                               IF DUPLEX = FULL THEN WRITELN;
                               WRITEERR;
                               IF NOT TERMINAL THEN PROMPTSKIP:=0;
                               CURPOS:=1+PROMPTSKIP;
                               WASLINESEPARATOR:=FALSE
                          END
                      END;
                 IF DUPLEX = FULL THEN WRITE(CURCHAR);
                 IF CURPOS = LINELENGTH+1 THEN
                 REPEAT GETCHAR UNTIL CURPOS = 1
          END;
          LETTER:=FALSE;
          DIGIT:=FALSE;
          IF CURCHAR = 'A' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'А' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'B' THEN BEGIN LETTER:=TRUE ; GOTO 1 END;
          IF CURCHAR = 'В' THEN BEGIN LETTER:=TRUE ; GOTO 1 END;
          IF CURCHAR = 'B' THEN BEGIN LETTER:=TRUE ; GOTO 1 END;
          IF CURCHAR = 'C' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'С' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'C' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'C' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'D' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Д' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'E' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Е' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'E' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'F' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Ф' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'G' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Г' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'H' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Н' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'H' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'I' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'И' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'J' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Й' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'K' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'К' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'K' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'L' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Л' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'M' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'М' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'M' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'N' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Н' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'O' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'О' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'O' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'P' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'П' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Q' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Я' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'R' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Р' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'S' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'С' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'T' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Т' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'T' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'U' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'У' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'V' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Ж' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'W' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'В' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'X' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Ь' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Х' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Y' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Ы' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'Z' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = 'З' THEN BEGIN LETTER:=TRUE; GOTO 1 END;
          IF CURCHAR = '0' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '1' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '2' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '3' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '4' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '5' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '6' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '7' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '8' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
          IF CURCHAR = '9' THEN BEGIN DIGIT:=TRUE; GOTO 1 END;
 1:;
    SIMILAR:=LETTER OR DIGIT;
    {  IGNOR BAD CHARACTERS
    IF (NOT SIMILAR)        AND
       (CURCHAR <> '$')     AND
       (CURCHAR <> ' ')     AND
       (CURCHAR <> '@')     AND
       (CURCHAR <> '"')     AND
       (CURCHAR <> '!')     AND
       (CURCHAR <> '#')     AND
       (CURCHAR <> '%')     AND
       (CURCHAR <> '&')     AND
       (CURCHAR <> '(')     AND
       (CURCHAR <> ')')     AND
       (CURCHAR <> '*')     AND
       (CURCHAR <> '+')     AND
       (CURCHAR <> ',')     AND
       (CURCHAR <> '-')     AND
       (CURCHAR <> '=')     AND
       (CURCHAR <> '.')     AND
       (CURCHAR <> '/')     AND
       (CURCHAR <> ':')     AND
       (CURCHAR <> ';')     AND
       (CURCHAR <> '<')     AND
       (CURCHAR <> '>')     AND
       (CURCHAR <> '?')     AND
       (CURCHAR <> '[')     AND
       (CURCHAR <> '\')     AND
       (CURCHAR <> ']')     AND
       (CURCHAR <> '^')     AND
       (CURCHAR <> '_')     AND
       (CURCHAR <> '''')
    THEN GETCHAR;                }
 END;
 PROCEDURE GOFORWARD;
 VAR WASSIMILAR:BOOLEAN; PREVIOUS:CHAR;
 BEGIN
      IF FROMBUFCHAR THEN
         BEGIN
              CURCHAR:=BUFCHAR;
              CURPOS:=CURPOS+1;
              LETTER:=BL;
              DIGIT:=BD;
              SIMILAR:=LETTER OR DIGIT;
              FROMBUFCHAR:=FALSE
         END
                     ELSE
         BEGIN
              WASSIMILAR:=SIMILAR;
              GETCHAR;
              IF CURCHAR = ' ' THEN
                 BEGIN
                      WHILE CURCHAR = ' ' DO GETCHAR;
                      IF WASSIMILAR AND SIMILAR THEN
                         BEGIN
                              BUFCHAR:=CURCHAR;
                              BL:=LETTER;
                              BD:=DIGIT;
                              CURCHAR:=' ';
                              CURPOS:=CURPOS-1;
                              DIGIT:=FALSE;
                              LETTER:=FALSE;
                              SIMILAR:=FALSE;
                              FROMBUFCHAR:=TRUE
                         END
                  END
          END;
          {  MDB }  EPASS(CURCHAR);
          {  MDB }  PASS(CURCHAR)
 END;
 PROCEDURE GETLEXEMA;
 LABEL 1;
 VAR
       LETTERCOUNT:INTEGER;
       LEXEMA:PACKED  ARRAY[1..8] OF CHAR;
 BEGIN
      LETTERCOUNT:=0;
      LEXEMA:='        ';
 WHILE SIMILAR DO
       BEGIN
            LETTERCOUNT :=LETTERCOUNT+1;
            IF LETTERCOUNT <= 8 THEN LEXEMA[LETTERCOUNT]:=CURCHAR;
            GOFORWARD
       END;
       IF LETTERCOUNT > 8 THEN LETTERCOUNT:=8;
 CURLEX:= BADLEX;
 IF LEXEMA = 'USE     ' THEN BEGIN CURLEX:=AUSE;      GOTO 1 END;
 IF LEXEMA = 'MODEL   ' THEN BEGIN CURLEX:=AMODEL;      GOTO 1 END;
 IF LEXEMA = 'IS      ' THEN BEGIN CURLEX:=IS;       GOTO 1 END;
 IF LEXEMA = 'OR      ' THEN BEGIN CURLEX:=AOR;       GOTO 1 END;
 IF LEXEMA = 'AND     ' THEN BEGIN CURLEX:=AAND;      GOTO 1 END;
 IF LEXEMA = 'SAVE    ' THEN BEGIN CURLEX:=SAVE;      GOTO 1 END;
 IF LEXEMA = 'HD      ' THEN BEGIN CURLEX:=HD;        GOTO 1 END;
 IF LEXEMA = 'SOLVE   ' THEN BEGIN CURLEX:=SOLVE;     GOTO 1 END;
 IF LEXEMA = 'USING   ' THEN BEGIN CURLEX:=USING;     GOTO 1 END;
 IF LEXEMA = 'HDS     ' THEN BEGIN CURLEX:=HDT;       GOTO 1 END;
 IF LEXEMA = 'FDS     ' THEN BEGIN CURLEX:=FDT;       GOTO 1 END;
 IF LEXEMA = 'FD      ' THEN BEGIN CURLEX:=FD;        GOTO 1 END;
 IF LEXEMA = 'REAL    ' THEN BEGIN CURLEX:=AREAL;     GOTO 1 END;
 IF LEXEMA = 'INTEGER ' THEN BEGIN CURLEX:=AINTEGER;  GOTO 1 END;
 IF LEXEMA = 'BOOLEAN ' THEN BEGIN CURLEX:=ABOOLEAN;   GOTO 1 END;
 IF LEXEMA = 'CHAR    ' THEN BEGIN CURLEX:=ACHAR;     GOTO 1 END;
 IF LEXEMA = 'MODULE  ' THEN BEGIN CURLEX:=MODULE;    GOTO 1 END;
 IF LEXEMA = 'EQN     ' THEN BEGIN CURLEX:=EQN;       GOTO 1 END;
 IF LEXEMA = 'LET     ' THEN BEGIN CURLEX:=LET;       GOTO 1 END;
 IF LEXEMA = 'IN      ' THEN BEGIN CURLEX:=AIN;       GOTO 1 END;
 IF LEXEMA = 'OUT     ' THEN BEGIN CURLEX:=OUT;       GOTO 1 END;
 IF LEXEMA = 'MAP     ' THEN BEGIN CURLEX:=MAP;       GOTO 1 END;
 IF LEXEMA = 'FROM    ' THEN BEGIN CURLEX:=AFROM;    GOTO 1 END;
 IF LEXEMA = 'ORIGIN  ' THEN BEGIN CURLEX:=AORIGIN;  GOTO 1 END;
 IF LEXEMA = 'ACTIONS ' THEN BEGIN CURLEX:=AACTIONS; GOTO 1 END;
 1:;
 END;
 PROCEDURE TERM;
 BEGIN
      IF (CURCHAR = '(') OR (CURCHAR = '''') OR DIGIT THEN
         CASE CURCHAR OF
              '(':BEGIN
                       GOFORWARD;
                       IF (CURCHAR = '+') OR (CURCHAR = '-')
                          THEN GOFORWARD;
                       EXPRESSION;
                       IF CURCHAR <> ')' THEN ERROR(4);
                       GOFORWARD
                   END;
 '''','1','2','3','4','5','6','7','8','9','0':
                  DOCONST
          END
                                 ELSE
          BEGIN
                {  MDB }  INNAMEINEXPRESSION:=TRUE;
                {  MDB }  IEPASS:=IEPASS-1;
                NAME;
                {  MDB }  ATTACHNAME;
                {  MDB }  INNAMEINEXPRESSION:=FALSE;
                {  MDB }  SETNAMEINEXPRESSION;
                IF CURCHAR='(' THEN
                   BEGIN
                        GOFORWARD;
                        EXPRESSION;
                        WHILE CURCHAR=',' DO
                              BEGIN
                                   GOFORWARD;
                                   EXPRESSION
                              END;
                        IF CURCHAR <> ')' THEN ERROR(4);
                        GOFORWARD
                    END
           END
 END;
 PROCEDURE ERROR;
        {  ERROR(ERRCODE:INTEGER);-WAS 'FORWARD' DESCRIPTION }
 VAR PT:LINK;PTNEXT:LINK;
 BEGIN
      IF (ERRCODE <> 1520) OR (ERR1520 = WORKUP) THEN
      BEGIN
      ERRCOUNT:=ERRCOUNT+1;
      IF ERRCODE = 1520 THEN ERRCODE:=104;
      WASBADOPERATOR:=TRUE;
      IF FIRSTZUCK = NIL THEN
         BEGIN
              NEW(FIRSTZUCK);
              FIRSTZUCK@.CURPOS:=CURPOS;
              FIRSTZUCK@.ERRCODE:=ERRCODE;
              FIRSTZUCK@.NEXT:=NIL
          END
                         ELSE
          BEGIN
               PTNEXT:= FIRSTZUCK;
               REPEAT
                     PT:=PTNEXT;
                     PTNEXT:=PT@.NEXT
               UNTIL PTNEXT = NIL;
               NEW(PTNEXT);
               PTNEXT@.CURPOS:=CURPOS;
               PTNEXT@.ERRCODE:=ERRCODE;
               PTNEXT@.NEXT:=NIL;
               PT@.NEXT:=PTNEXT
          END
      END
 END;
 PROCEDURE WRITEERR;
 VAR PT:LINK;PTPRINTED:LINK;
     I:INTEGER;
     OLDPOS:INTEGER;
 BEGIN
      PT:=FIRSTZUCK;
      IF PT <> NIL THEN
         BEGIN
              IF TERMINAL THEN WRITE('   ') ELSE WRITE('     ');
              OLDPOS:=0;
              WHILE PT <> NIL DO
                    BEGIN
                         FOR I:=1 TO PT@.CURPOS-1-OLDPOS DO WRITE(' ');
                         IF PT@.CURPOS-1-OLDPOS >= 0 THEN WRITE('$');
                         OLDPOS:=PT@.CURPOS;
                         PT:=PT@.NEXT
                    END;
              WRITELN;
              PT:=FIRSTZUCK;
              IF TERMINAL THEN  WRITELN('*** ERROR ***');
              WHILE PT <> NIL DO
                    BEGIN
                         IF NOT TERMINAL THEN
                         BEGIN
                         WRITE(' *** ERROR ',PT@.ERRCODE:3,' ***');
                         LINECOUNT:=LINECOUNT+1
                         END;
                         PTPRINTED:=PT;
                         PT:=PT@.NEXT;
                    {    DISPOSE(PTPRINTED);   }
                         IF NOT TERMINAL THEN WRITELN
                    END;
           IF NOT TERMINAL THEN WRITELN
        END;
        FIRSTZUCK:=NIL;
        IF NOT TERMINAL THEN BEGIN
           LINECOUNT:=LINECOUNT+1;
           IF LINECOUNT > (PAGESIZE-3) THEN
              BEGIN
                   PRINTTITLE;
                   LINECOUNT:=1
              END
                             END;
        IF NOT WASEOF THEN PROMPT
 END;
 PROCEDURE PROMPT;
 VAR
    I:INTEGER;
 BEGIN
      IF TERMINAL THEN BEGIN
                            IF INACTIONS THEN WRITE('P@S')
                                         ELSE WRITE('FPS');
                            IF COMPLETE THEN WRITE('>')
                                        ELSE WRITE(' ');
                            IF PROMPTSKIP > (LINELENGTH-13)
                            THEN BEGIN
                                      ERROR(503);
                                      PROMPTSKIP:=0
                                 END
                            ELSE
                                 FOR I:=1 TO PROMPTSKIP DO WRITE(' ')
                        END
                  ELSE
                        BEGIN
                              IF INACTIONS THEN
                              WRITE('     ')
                                           ELSE
                              BEGIN
                                   WRITE(' ');
                                   WRITE(OPNUMBER:3);
                                   WRITE(' ')
                              END
                         END
 END;
 PROCEDURE OPERATOR;
 VAR
    OWNCURRENTOWNER:PTKNOT;  {  OWNER OF THIS OPERATOR }
    OWNPROMPTSKIP:INTEGER;   {  PROMPT SKIP ONLY IF MODEL }
     MINUSPOS:INTEGER;
 { MDB }  PROCEDURE OPENLEVEL;
 {  OPEN NEW "MODEL" LEVEL }
 BEGIN
      NEW(PTCURKNOT);
      WITH PTCURKNOT@ DO
      BEGIN
           NAME:=OPNAME;
           PTOWNER:=CURRENTOWNER;
           KNOTTYPE:=VARK;
           PTILIST:=NIL;
           PTOLIST:=NIL;
           KNOTSUBTYPE:=STRUCTUREK;
           GENERATION:=0;
           PTMEMBLIST:=NIL
      END;
      OWNCURRENTOWNER:=CURRENTOWNER; { SAVE HIM INTO STACK }
      OWNPROMPTSKIP:=PROMPTSKIP;
      INSERT(PTCURKNOT); {  ADD THIS MODEL LEVEL INTO SYSTEM }
      CURRENTOWNER:=PTCURKNOT;
      PROMPTSKIP:=CURPOS-1
 END;
 { MDB}   PROCEDURE CLOSELEVEL;
 {  CLOSE MODEL LEVEL }
 BEGIN
      {  GET FROM THE STACK: }
      PROMPTSKIP:=OWNPROMPTSKIP;
      CURRENTOWNER:=OWNCURRENTOWNER
 END;
 BEGIN
      {  COMMENT }
      WHILE CURCHAR = '-' DO
      BEGIN
           MINUSPOS:=CURPOS;
            REPEAT
                  GETCHAR
            UNTIL CURPOS <= MINUSPOS;
            IF CURCHAR = ' ' THEN GOFORWARD
      END;
      COMPLETE:=FALSE;
    IF (CURCHAR = '!') OR ( (CURCHAR = ')') AND (CURRENTOWNER <> NIL) )
                       OR EOF(INPUT)
                       OR (CURCHAR = '!') OR (CURCHAR = '?')
    THEN
    BEGIN
      COMPLETE:=TRUE;
      OPNUMBER:=OPNUMBER-1; {  DUMMY OPERATOR DOES NOT HAVE OPNUMBER }
    END
    ELSE
    BEGIN
      {  MDB }  GFIRSTPARM:=NIL;
      {  MDB }  GLASTPARM :=NIL;
      GETLEXEMA;
      IF CURLEX IN [AMODEL,MODULE,EQN,LET,SAVE,AORIGIN,AACTIONS,
                     AINTEGER,AREAL,ABOOLEAN,ACHAR,
                     MAP,AUSE,
                     SOLVE,HDT,FDT,HD,FD] THEN
         CASE CURLEX OF
        AMODEL:BEGIN
                    IF CURCHAR <> ' ' THEN ERROR(24);
                    GOFORWARD;
                    { MDB}  PASSNAME;
                    SIMPLENAME;
                    { MDB}  ENDNAME;
                    { MDB}  GETNAME;
                    IF NOT WASBADOPERATOR THEN
                    BEGIN
                    IF CURCHAR = '('
                    THEN
                    BEGIN
                         { MDB}  OPENLEVEL;
                         GOFORWARD;
                         MODEL;
                         IF CURCHAR <> ')' THEN ERROR(4);
                         { MDB}  CLOSELEVEL;
                         GOFORWARD
                    END
                    ELSE
                    BEGIN
                         GOFORWARD;
                         GETLEXEMA;
                         IF CURLEX <> IS THEN ERROR(10);
                         IF CURCHAR <> ' ' THEN ERROR(24);
                         GOFORWARD;
                         DOCOPY;
                         IF NOT WASBADOPERATOR THEN
                         BEGIN
                              { MDB}  INSERTTREE(CURROOT)
                         END
                    END
                    END
               END;
       AREAL:  BEGIN
                    IF CURCHAR <> ' ' THEN ERROR(24);
                    REPEAT
                    GOFORWARD;
                    { MDB}  PASSNAME;
                    SIMPLENAME;
                    { MDB}  ENDNAME;
                    { MDB}  GETNAME;
                    { MDB}  MDBMDL3
                    UNTIL CURCHAR <> ','
               END;
    AINTEGER:  BEGIN
                    IF CURCHAR <> ' ' THEN ERROR(24);
                    REPEAT
                    GOFORWARD;
                    { MDB}  PASSNAME;
                    SIMPLENAME;
                    { MDB}  ENDNAME;
                    { MDB}  GETNAME;
                    { MDB}  MDBMDL4
                    UNTIL CURCHAR <> ','
                END;
    ACHAR:     BEGIN
                    IF CURCHAR <> ' ' THEN ERROR(24);
                    REPEAT
                    GOFORWARD;
                    { MDB}  PASSNAME;
                    SIMPLENAME;
                    { MDB}  ENDNAME;
                    { MDB}  GETNAME;
                    IF CURCHAR <> ' ' THEN ERROR(24);
                    GOFORWARD;
                    { MDB}  EXPRON;
                    IVAR;
                    { MDB}  MDBMDL7
                    UNTIL CURCHAR <> ','
                END;
    ABOOLEAN:  BEGIN
                    IF CURCHAR <> ' ' THEN ERROR(24);
                    REPEAT
                    GOFORWARD;
                    { MDB}  PASSNAME;
                    SIMPLENAME;
                    { MDB}  ENDNAME;
                    { MDB}  GETNAME;
                    { MDB}  MDBMDL5
                    UNTIL CURCHAR <> ','
                END;
 MODULE,EQN,LET:BEGIN
                     { MDB} GENOPNAME;
                     { MDB} OPCOST:=0;
                     IF CURCHAR = ':' THEN
                     BEGIN
                          GOFORWARD;
                          { MDB}  PASSNAME;
                          SIMPLENAME;
                          { MDB}  ENDNAME;
                          { MDB}  GETNAME
                     END;
                     IF CURCHAR = '$' THEN
                     BEGIN
                          GOFORWARD;
                          { MDB} EXPRON;
                          IVAR;
                          { MDB} EXPROFF;
                          { MDB} GETCOST
                     END;
                     DOAREL
                END;
          SAVE: BEGIN
                     IF CURCHAR <> ' ' THEN ERROR(24);
                     REPEAT
                     GOFORWARD;
                     NAME;
                     { AMG}  IF NOT WASBADOPERATOR THEN AMGSAVE
                     UNTIL CURCHAR <> ','
                END;
         AUSE:  BEGIN
                     IF CURCHAR <> ' ' THEN ERROR(24);
                     GOFORWARD;
                     DOCOPY;
                     IF NOT WASBADOPERATOR THEN
                     BEGIN
                          CHECKUSE;
                          IF NOT WASBADOPERATOR THEN
                          BEGIN
                               { MDB}  INSERTMEMBERS(CURROOT)
                          END
                     END
                 END;
        SOLVE:  BEGIN
                     IF CURCHAR <> ' ' THEN ERROR(24);
                     GOFORWARD;
                     NAME;
                     {  MDB }  IF NOT WASBADOPERATOR THEN GETSOLVE;
                     IF CURCHAR <> ' ' THEN ERROR(24);
                     GOFORWARD;
                     GETLEXEMA;
                     IF CURLEX <> USING THEN ERROR (28);
                     IF CURCHAR <> ' ' THEN ERROR(24);
                     GOFORWARD;
                     {  MDB }  PASSNAME;
                     SIMPLENAME;
                     {  MDB }  ENDNAME;
                     {  MDB }  IF NOT WASBADOPERATOR
                     THEN CORRSOLVE
                END;
         HDT:   BEGIN
                     TERMINAL:=TRUE;
                     DUPLEX:=HALF
                END;
         FDT:   BEGIN
                     TERMINAL:=TRUE;
                     DUPLEX:=FULL;
                END;
         HD:    BEGIN
                     PRINTTITLE;
                     TERMINAL:=FALSE;
                     DUPLEX:=HALF
                END;
         FD:    BEGIN
                     PRINTTITLE;
                     TERMINAL:=FALSE;
                     DUPLEX:=FULL
                END;
        AORIGIN:BEGIN
                     WRITELN;
                     SUBTITLE:='CBEДEHИЯ O PAЗPAБOTЧИKAX';
                     PRINTTITLE;
                     WRITELN(ORIGIN1);
                     WRITELN(ORIGIN2);
                     WRITELN(ORIGIN3);
                     WRITELN(ORIGIN4);
                     WRITELN(ORIGIN5);
                     WRITELN(ORIGIN6);
                     WRITELN(ORIGIN7);
                     SUBTITLE:='SOURCE MODEL LISTING    ';
                     PRINTTITLE
                END;
     AACTIONS:  CURCHAR:='!';
          MAP:  MAPPING
     END
                                             ELSE ERROR(18)
     END
 END;
 PROCEDURE SUMMARY;
 {  PROCESSING SUMMARY }
 VAR
    I:INTEGER;
    CUREXTRN:PTEXTRN;
    CURSAVE:PTLISTMEMB;
    UNLOADABLE:BOOLEAN;
 BEGIN
      SUBTITLE:='PROCESSING SUMMARY      ';
      PRINTTITLE;
      WRITELN;
      WRITE('     ');
      I:=OPNUMBER-1;
      WRITE(I:3);
      WRITELN(' SOURCE STATEMENTS.');
      CURSAVE:=FIRSTSAVE;
      WHILE CURSAVE <> NIL DO
      BEGIN
           CHECKEXTREF(CURSAVE@.TARGET,UNLOADABLE);
           IF NOT UNLOADABLE THEN
           BEGIN
                WRITE(' *** ERROR 502 ***');
                WRITE(' IN ');
                WRITELN(CURSAVE@.TARGET@.NAME);
                ERRCOUNT:=ERRCOUNT+1
           END;
           CURSAVE:=CURSAVE@.NEXT
      END;
      IF ERRCOUNT <> 0
      THEN BEGIN
                WRITE(' *** ');
                WRITE(ERRCOUNT:3)
           END
      ELSE WRITE('      NO');
      WRITELN(' ERRORS DETECTED.');
      WRITE('    ');
      WRITE(OBJCOUNT:4);
      WRITELN(' MODELS GENERATED.');
      WRITE('    ');
      WRITE(PASCLINES:4);
      WRITELN(' PASCAL LINES GENERATED.');
      IF FIRSTEXTRN <> NIL THEN
      BEGIN
           WRITELN('     WARNING- EXTERNAL REFERENCES:');
           CUREXTRN:=FIRSTEXTRN;
           REPEAT
                 WITH CUREXTRN@ DO
                 BEGIN
                      WRITE(' *** ');
                      WRITE(NAME);
                      WRITE(' IN STATEMENT ');
                      WRITELN(STMTNUM:3)
                 END;
                 CUREXTRN:=CUREXTRN@.NEXT
           UNTIL CUREXTRN = NIL
       END;
       IF (FIRSTSAVE <> NIL) THEN
       BEGIN
            IF ERRCOUNT <> 0
            THEN WRITELN(
 ' *** ARCHIVE MODIFICATION IS NOT DONE DUE TO ERRORS'
                        )
            ELSE { AMG}  AMGPROCESS
       END
 END;
     {  ---------------------------------------------------- }
     {     THE ALGOR-GENERATOR P R O C E D U R E  SEGMENT    }
     {  ----------------------------------------------------- }
 PROCEDURE GETWORD; FORWARD;
 PROCEDURE EOLNOBJECT;
 {  LINE FEED IN OBJECT FILE }
 VAR
    I:INTEGER;
 BEGIN
      IF NOT WASEOLNOBJECT THEN
      BEGIN
           OBJPOS:=OBJPOS+1;
           FOR I:=OBJPOS TO LINELENGTH+8 DO WRITE(OBJECT,' ');
           WRITELN(OBJECT);
           IF OBJSHIFT < 1  THEN OBJSHIFT:=1;
           IF OBJSHIFT > LINELENGTH-NAMELENGTH THEN OBJSHIFT:=1;
           OBJPOS:=OBJSHIFT;
           FOR I:=1 TO OBJSHIFT DO WRITE(OBJECT,' ');
           PASCLINES:=PASCLINES+1;
            WASEOLNOBJECT:=TRUE;
      END;
 END;
 PROCEDURE PASSOBJCHAR;
 VAR
    TC:PACKED ARRAY [ 1..2 ] OF CHAR;
 BEGIN
      TC [ 1 ] :=PREVOBJCHAR;
      TC [ 2 ] :=CURCHAR;
      IF (NOT(
               (TC = '} ') OR
               (TC = '{ ') OR
               (TC = ':=') OR
               (TC = '[') OR
               (TC = ']') OR
               (TC = '<>') OR
               (TC = '^=') OR
               (TC = '<=') OR
               (TC = '>=') OR
               (TC = '(#') OR
               (TC = '#)')
         )   )
         AND (OBJPOS >= LINELENGTH-1)
      THEN EOLNOBJECT;
      PREVOBJCHAR:=CURCHAR;
      IF NOT ( (CURCHAR = '?') AND EOF(INPUT) ) THEN
      BEGIN
            OBJPOS:=OBJPOS+1;
            WRITE(OBJECT,CURCHAR)
      END;
      WASEOLNOBJECT:=FALSE;
      IF CURCHAR = ';' THEN EOLNOBJECT;
 END;
 PROCEDURE PASSOBJINT(IP:INTEGER);
 VAR
    I:INTEGER;
 BEGIN
      IF OBJPOS >= LINELENGTH-8 THEN EOLNOBJECT;
      WRITE(OBJECT,IP:8);
      WASEOLNOBJECT:=FALSE;
      OBJPOS:=OBJPOS+8
 END;
 PROCEDURE PASSOBJWORD;
 VAR
    L:INTEGER;
    I:INTEGER;
 BEGIN
      L:=9;
      WHILE (L > 1) AND (WORD [ L ] = ' ') DO L:=L-1;
      IF((WORD = 'END      ')   OR
         (WORD = 'UNTIL    '))  THEN OBJSHIFT:=OBJSHIFT-4;
      IF((WORD = 'PROCEDURE')   OR
         (WORD = 'BEGIN    ')   OR
         (WORD = 'RECORD   ')   OR
         (WORD = 'REPEAT   ')   OR
         (WORD = 'UNTIL    ')   OR
         (WORD = 'VAR      ')   OR
         (WORD = 'END      ')   OR
         (WORD = 'CASE     ')   OR
         (WORD = 'CONST    ')   OR
         (WORD = 'TYPE     ')   OR
         (WORD = 'WHILE    ')   OR
         (WORD = 'FOR      ')   OR
         (WORD = 'THEN     ')   OR
         (WORD = 'ELSE     '))  AND (OBJPOS > OBJSHIFT)
       THEN EOLNOBJECT;
       FOR I:=1 TO L DO WRITE(OBJECT,WORD[ I ]);
       OBJPOS:=OBJPOS+L;
       WASEOLNOBJECT:=FALSE;
       IF (WORD = 'BEGIN    ') OR
          (WORD = 'RECORD   ') OR
          (WORD = 'REPEAT   ') OR
          (WORD = 'CASE     ')
       THEN OBJSHIFT:=OBJSHIFT+4;
       IF (WORD = 'BEGIN    ') OR
          (WORD = 'RECORD   ') OR
          (WORD = 'REPEAT   ') OR
          (WORD = 'VAR      ') OR
          (WORD = 'CONST    ') OR
          (WORD = 'TYPE     ') OR
          (WORD = 'THEN     ') OR
          (WORD = 'ELSE     ')
       THEN EOLNOBJECT;
       PREVOBJCHAR:=' ';
 END;
 PROCEDURE PASSOBJLINE(VAR LI:LINE);
 VAR
    I:INTEGER;
    L:INTEGER;
 BEGIN
      L:=LINELENGTH;
      WHILE (L > 1) AND (LI[ L ] = ' ') DO L:=L-1;
      IF L > (LINELENGTH-OBJPOS) THEN EOLNOBJECT
      ELSE
      BEGIN
           FOR I:=1 TO L DO WRITE(OBJECT,LI[ I ]);
           OBJPOS:=OBJPOS+L
      END
 END;
 PROCEDURE GENREC(PK:PTKNOT);
 {  FORM DECLARATION CORRESPONDING TO KNOT GIVEN }
 VAR
    I:INTEGER;
    CURMEMB:PTLISTMEMB;
    FOUNDVAR:BOOLEAN;
 BEGIN
      FOR I:=1 TO 8 DO WORD[ I ]:=PK@.NAME[ I ];
      WORD[ 9 ]:=' ';
      PASSOBJWORD; {  "NAMEOBJ:" }
      CURCHAR:=':'; PASSOBJCHAR;
      CASE PK@.KNOTSUBTYPE OF
      REALK:   BEGIN
                 WORD:='REAL     ';
                 PASSOBJWORD
               END;
      INTEGERK:BEGIN
                 WORD:='INTEGER  ';
                 PASSOBJWORD
               END;
      BOOLEANK:BEGIN
                 WORD:='BOOLEAN  ';
                 PASSOBJWORD
               END;
      CHARK:BEGIN
                 WORD:='PACKED   ';PASSOBJWORD;
                 CURCHAR:=' ';     PASSOBJCHAR;
                 WORD:='ARRAY [ ';PASSOBJWORD;
                 WORD:='1 ..     ';PASSOBJWORD;
                 PASSOBJINT(PK@.LENGTH);
                 WORD:=' ] OF   ';PASSOBJWORD;
                 CURCHAR:=' ';     PASSOBJCHAR;
                 WORD:='CHAR     ';PASSOBJWORD
            END;
      STRUCTUREK:BEGIN
                 WORD:='RECORD   ';PASSOBJWORD;
 FOUNDVAR:=FALSE;
 CURMEMB:=PK@.PTMEMBLIST;
 WHILE (CURMEMB <> NIL) AND (NOT FOUNDVAR) DO
 BEGIN
      IF CURMEMB@.TARGET@.KNOTTYPE = VARK THEN
      BEGIN
           FOUNDVAR:=TRUE;
           GENREC(CURMEMB@.TARGET)
      END;
      CURMEMB:=CURMEMB@.NEXT
 END;
 WHILE CURMEMB <> NIL DO
 BEGIN
      IF CURMEMB@.TARGET@.KNOTTYPE = VARK THEN
      BEGIN
           CURCHAR:=';'; PASSOBJCHAR;
           GENREC(CURMEMB@.TARGET);
      END;
 CURMEMB:=CURMEMB@.NEXT
 END;
                 WORD:='END      '; PASSOBJWORD
                 END
      END; {  CASE }
 END;
 PROCEDURE PASSUNTIL;
 BEGIN
      WHILE (NOT SIMILAR) AND (NOT WASEOF) DO
      BEGIN
           PASSOBJCHAR;
           GOFORWARD
      END
 END;
 PROCEDURE ACTWKNAME;
 VAR
    CURKNOT:PTKNOT;
    I:INTEGER;
    THISNAME:BOOLEAN;
 BEGIN
      CURKNOT:=FIRSTKNOT;
      WHILE CURKNOT <> NIL DO
      BEGIN
           THISNAME:=TRUE;
           FOR I:=1 TO 8 DO
               THISNAME:=( WORD[I] = CURKNOT@.MODULENAME[I] )
                                    AND
                         THISNAME;
           IF THISNAME THEN CURKNOT@.MODULELOC:=USERPLACED;
           CURKNOT:=CURKNOT@.NEXT
      END
 END;
 PROCEDURE PRODUCEOUTS(PK:PTKNOT);
 {  ADD PK@.PTOLIST TO DATALIST }
 VAR
    CUROUT:PTLISTMEMB;
    NEWMEMB:PTLISTMEMB;
 BEGIN
      CUROUT:=PK@.PTOLIST;
      WHILE CUROUT <> NIL DO
      BEGIN
           NEW(NEWMEMB);
           NEWMEMB@.TARGET:=CUROUT@.TARGET;
           NEWMEMB@.NEXT:=DATALIST;
           DATALIST:=NEWMEMB;
            CUROUT:=CUROUT@.NEXT
       END
 END;
 PROCEDURE ISAPPLICATABLE(PK:PTKNOT;VAR APPLICATABLE:BOOLEAN);
 VAR
    CUROVAR:PTLISTMEMB;
    CURIVAR:PTLISTMEMB;
    CURDATA:PTLISTMEMB;
    OUTSALRDYCOMPUTED:BOOLEAN;
    COMPUTEDTHIS:BOOLEAN;
 BEGIN
      {  ARE ALL INS COMPUTED ? - IF YES THEN APPLICATABLE }
      APPLICATABLE:=TRUE;
      CURIVAR:=PK@.PTILIST;
      WHILE (CURIVAR <> NIL) AND APPLICATABLE DO
      BEGIN
           COMPUTEDTHIS:=FALSE;
           CURDATA:=DATALIST;
           WHILE (CURDATA <> NIL) AND (NOT COMPUTEDTHIS) DO
           BEGIN
                IF CURIVAR@.TARGET = CURDATA@.TARGET
                THEN COMPUTEDTHIS:=TRUE;
                CURDATA:=CURDATA@.NEXT;
           END;
           APPLICATABLE:=APPLICATABLE AND COMPUTEDTHIS;
           CURIVAR:=CURIVAR@.NEXT;
      END;
      IF APPLICATABLE THEN
      BEGIN
           {  ARE ALL OUTS COMPUTED ? - IF YES THEN NOT APPL. }
           CUROVAR:=PK@.PTOLIST;
           OUTSALRDYCOMPUTED:=TRUE;
           WHILE (CUROVAR <> NIL) AND OUTSALRDYCOMPUTED DO
           BEGIN
                CURDATA:=DATALIST;
                COMPUTEDTHIS:=FALSE;
                WHILE (CURDATA <> NIL) AND (NOT COMPUTEDTHIS) DO
                BEGIN
                     IF CUROVAR@.TARGET = CURDATA@.TARGET
                     THEN COMPUTEDTHIS:=TRUE;
                     CURDATA:=CURDATA@.NEXT;
                 END;
                OUTSALRDYCOMPUTED:=OUTSALRDYCOMPUTED AND COMPUTEDTHIS;
                CUROVAR:=CUROVAR@.NEXT;
           END;
           IF OUTSALRDYCOMPUTED THEN PK@.TRYED:=TRUE;
           APPLICATABLE:=APPLICATABLE AND (NOT OUTSALRDYCOMPUTED);
       END
 END;
 PROCEDURE ISITSOLVED;
 VAR
    CURDATA:PTLISTMEMB;
    CURRES:PTLISTMEMB;
    SOLVTHIS:BOOLEAN;
 BEGIN
      SOLVED:=TRUE;
      CURRES:=RESLIST;
      WHILE (CURRES <> NIL) AND SOLVED DO
      BEGIN
           CURDATA:=DATALIST;
           SOLVTHIS:=FALSE;
           WHILE (CURDATA <> NIL) AND (NOT SOLVTHIS) DO
           BEGIN
                IF CURDATA@.TARGET = CURRES@.TARGET
                THEN SOLVTHIS:=TRUE;
                CURDATA:=CURDATA@.NEXT;
          END;
          SOLVED:=SOLVED AND SOLVTHIS;
          CURRES:=CURRES@.NEXT;
      END
 END;
 PROCEDURE UPSTEP;
 {  NEXT TRY OF RELS APPLICATION }
 VAR
    CURKNOT:PTKNOT;
    YES:BOOLEAN;
 BEGIN
      ALLTRYED:=TRUE;
      SOLVED:=FALSE;
      CURKNOT:=FIRSTKNOT;
      WHILE (CURKNOT <> NIL) AND (NOT SOLVED) DO
      BEGIN
           IF (CURKNOT@.KNOTTYPE = RELK) AND
              (NOT CURKNOT@.TRYED)  THEN
           BEGIN
                ISAPPLICATABLE(CURKNOT,YES);
                IF YES THEN
                BEGIN
                     ALLTRYED:=FALSE;
                     CURKNOT@.APPLICATED:=TRUE;
                     CURKNOT@.TRYED:=TRUE;
                     RELCOUNT:=RELCOUNT+1;
                     CURKNOT@.GENERATION:=RELCOUNT;
                     PRODUCEOUTS(CURKNOT);
               END;
               ISITSOLVED;
          END;
          CURKNOT:=CURKNOT@.NEXT;
       END
 END;
 PROCEDURE WATERUP;
 {  BUILD ALL KINDERS OF DATALIST BY ITER. APPL. OF RELS }
 BEGIN
      REPEAT
            ISITSOLVED;
            IF NOT SOLVED THEN UPSTEP;
      UNTIL SOLVED OR ALLTRYED;
 END;
 PROCEDURE KEEPPARENTS(VAR PKINDER:PTKNOT);
 {  MARK AS "KEPT" ALL I/O PARENTS OF KNOT SPECIFIED }
 VAR
    CURIREL:PTLISTMEMB;
    CURIVAR:PTLISTMEMB;
 BEGIN
           CURIREL:=PKINDER@.PTILIST;
           WHILE CURIREL <> NIL DO
           BEGIN
                IF (NOT CURIREL@.TARGET@.KEPT) THEN
                BEGIN
                CURIREL@.TARGET@.KEPT:=TRUE;
                CURIVAR:=CURIREL@.TARGET@.PTILIST;
                WHILE CURIVAR <> NIL DO
                BEGIN
                     KEEPPARENTS(CURIVAR@.TARGET);
                     CURIVAR:=CURIVAR@.NEXT
               END;
               END;
               CURIREL:=CURIREL@.NEXT
           END
 END;
 PROCEDURE KEEPBEUSED;
 {  MARK AS "KEPT" ALL RELS WHICH BE USED IN "GENPASCAL" }
 VAR
    CURRES:PTLISTMEMB;
 BEGIN
      CURRES:=RESLIST;
      WHILE CURRES <> NIL DO
      BEGIN
           KEEPPARENTS(CURRES@.TARGET);
           CURRES:=CURRES@.NEXT
      END
 END;
 PROCEDURE GENEXEPTOWR(VAR M:PTKNOT;RELOWNER:PTKNOT);
 VAR
    CUROWNER:PTKNOT;
    BOSS:PTKNOT;
    CURMEMBER:PTLISTMEMB;
    KINDER:BOOLEAN;
    I:INTEGER;
    ALLNAMESGENERATED:BOOLEAN;
 BEGIN
      {  SHOOK RELATION OWNER & MARK ROOT TO IT }
      {  BY "GENERATOIN  FIELD = 1 IN VARS }
      M@.GENERATION:=1;
      BOSS:=M;
      CUROWNER:=M@.PTOWNER;
      WHILE CUROWNER <> RELOWNER DO
      BEGIN
           BOSS:=CUROWNER;
           BOSS@.GENERATION:=1;
           CUROWNER:=CUROWNER@.PTOWNER
      END;
      {  NOW COME DOWN FR. BIG BOSS TO M EXEPT RELOWNER }
      ALLNAMESGENERATED:=FALSE;
      WHILE (NOT ALLNAMESGENERATED) DO
      BEGIN
           FOR I:=1 TO 8 DO WORD[ I ]:=BOSS@.NAME[ I ];
           WORD[ 9 ]:=' ';
           PASSOBJWORD;
           BOSS@.GENERATION:=0;
           IF BOSS = M THEN ALLNAMESGENERATED:=TRUE
                       ELSE
           BEGIN
                ALLNAMESGENERATED:=FALSE;
                CURCHAR:='.'; PASSOBJCHAR;
                CURMEMBER:=BOSS@.PTMEMBLIST;
                KINDER:=FALSE;
                WHILE (NOT KINDER) DO
                BEGIN
                     BOSS:=CURMEMBER@.TARGET;
                     IF (BOSS@.GENERATION = 1)
                              AND
                        (BOSS@.KNOTTYPE = VARK)
                     THEN KINDER:=TRUE;
                     CURMEMBER:=CURMEMBER@.NEXT;
                END;
          END;
    END;
 END;
 PROCEDURE GENFULLNAME(VAR M:PTKNOT);
 VAR
    CUROWNER:PTKNOT;
    BOSS:PTKNOT;
    CURMEMBER:PTLISTMEMB;
    KINDER:BOOLEAN;
    I:INTEGER;
    ALLNAMESGENERATED:BOOLEAN;
 BEGIN
      {  SHOOK GREATEST-OWNER & MARK ROOT TO IT }
      {  BY "GENERATOIN" FIELD = 1 IN VARS }
      M@.GENERATION:=1;
      BOSS:=M;
      CUROWNER:=M@.PTOWNER;
      WHILE CUROWNER <> NIL DO
      BEGIN
           BOSS:=CUROWNER;
           BOSS@.GENERATION:=1;
           CUROWNER:=CUROWNER@.PTOWNER
      END;
      {  NOW COME DOWN FR. BIG BOSS TO M }
      ALLNAMESGENERATED:=FALSE;
      WHILE (NOT ALLNAMESGENERATED) DO
      BEGIN
           FOR I:=1 TO 8 DO WORD[ I ]:=BOSS@.NAME[ I ];
           WORD[ 9 ]:=' ';
           PASSOBJWORD;
           BOSS@.GENERATION:=0;
           IF BOSS = M THEN ALLNAMESGENERATED:=TRUE
                       ELSE
           BEGIN
                ALLNAMESGENERATED:=FALSE;
                CURCHAR:='.'; PASSOBJCHAR;
                CURMEMBER:=BOSS@.PTMEMBLIST;
                KINDER:=FALSE;
                WHILE (NOT KINDER) DO
                BEGIN
                     BOSS:=CURMEMBER@.TARGET;
                     IF (BOSS@.GENERATION = 1)
                              AND
                        (BOSS@.KNOTTYPE = VARK)
                     THEN KINDER:=TRUE;
                     CURMEMBER:=CURMEMBER@.NEXT;
                END;
          END;
    END;
 END;
 PROCEDURE GENLET(LET:PTKNOT);
 {  RELSTRING IS THE TEXT OF RIGHT-SIDE EXPRESSION WITHOUT ";" }
 BEGIN
      GENEXEPTOWR(LET@.PTOLIST@.TARGET,LET@.PTOWNER);
      CURCHAR:=':'; PASSOBJCHAR;
      CURCHAR:='='; PASSOBJCHAR;
      PASSOBJLINE(LET@.RELSTRING);
      CURCHAR:=';'; PASSOBJCHAR
 END;
 PROCEDURE GENMODULE(MODULE:PTKNOT);
 {  RELSTRING IS THE CALL-LIST WITHOUT "(", ")" }
 VAR
    I:INTEGER;
    CURPARM:PTLISTMEMB;
 BEGIN
      FOR I:=1 TO 8 DO WORD[ I ]:=MODULE@.MODULENAME[ I ];
      WORD[ 9 ]:=' ';
      PASSOBJWORD;
      CURCHAR:='('; PASSOBJCHAR;
      CURPARM:=MODULE@.FIRSTPARM;
      WHILE CURPARM <> NIL DO
      BEGIN
           GENEXEPTOWR(CURPARM@.TARGET,MODULE@.PTOWNER);
           CURPARM:=CURPARM@.NEXT;
           IF CURPARM <> NIL THEN
           BEGIN
                CURCHAR:=','; PASSOBJCHAR
           END
      END;
      CURCHAR:=')'; PASSOBJCHAR;
      CURCHAR:=';'; PASSOBJCHAR
 END;
 PROCEDURE GENCOMPOUNDEQN(EQN:PTKNOT);
 BEGIN
      {  NEWTON'S METHOD }
      {  NEW X = X - DX / (F(X+DX) / F(X) - 1) }
      {  DX = 0.001; X0 = 0; LAST F(X) < 0.0001}
      IF EQN@.PTOWNER <> NIL THEN
      BEGIN
           WORD:='BEGIN    '; PASSOBJWORD;
      END;
      WORD:='FPS0000D:'; PASSOBJWORD;
      WORD:='=0.001;  '; PASSOBJWORD;
      WORD:='FPS0000C:'; PASSOBJWORD;
      WORD:='=0.000;  '; PASSOBJWORD;
      WORD:='REPEAT   '; PASSOBJWORD;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      CURCHAR:=':';      PASSOBJCHAR;
      CURCHAR:='=';      PASSOBJCHAR;
      WORD:='FPS0000C+'; PASSOBJWORD;
      WORD:='FPS0000D '; PASSOBJWORD;
      CURCHAR:=';';      PASSOBJCHAR;
      WORD:='FPS000FD:'; PASSOBJWORD;
      CURCHAR:='=';      PASSOBJCHAR;
      PASSOBJLINE(EQN@.RELSTRING);
      CURCHAR:=';';      PASSOBJCHAR;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      CURCHAR:=':';      PASSOBJCHAR;
      CURCHAR:='=';      PASSOBJCHAR;
      WORD:='FPS0000C '; PASSOBJWORD;
      CURCHAR:=';';      PASSOBJCHAR;
      WORD:='FPS0000F:'; PASSOBJWORD;
      CURCHAR:='=';      PASSOBJCHAR;
      PASSOBJLINE(EQN@.RELSTRING);
      CURCHAR:=';';      PASSOBJCHAR;
      WORD:='IF ABS(FP'; PASSOBJWORD;
      WORD:='S0000F)  '; PASSOBJWORD;
      WORD:=' >= 0.000'; PASSOBJWORD;
      WORD:='1 THEN   '; PASSOBJWORD;
      WORD:='BEGIN    '; PASSOBJWORD;
      WORD:='IF ABS(FP'; PASSOBJWORD;
      WORD:='S000FD-FP'; PASSOBJWORD;
      WORD:='S0000F)>0'; PASSOBJWORD;
      WORD:='.00001   '; PASSOBJWORD;
      WORD:='THEN     '; PASSOBJWORD;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      CURCHAR:=':';      PASSOBJCHAR;
      CURCHAR:='=';      PASSOBJCHAR;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      WORD:='-FPS0000D'; PASSOBJWORD;
      WORD:='/(FPS000F'; PASSOBJWORD;
      WORD:='D/FPS0000'; PASSOBJWORD;
      WORD:='F-1.0)   '; PASSOBJWORD;
      WORD:='ELSE     '; PASSOBJWORD;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      CURCHAR:=':';      PASSOBJCHAR;
      CURCHAR:='=';      PASSOBJCHAR;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      WORD:='-FPS0000D'; PASSOBJWORD;
      CURCHAR:=';'     ; PASSOBJCHAR;
      WORD:='FPS0000C:'; PASSOBJWORD;
      CURCHAR:='='     ; PASSOBJCHAR;
      GENEXEPTOWR(EQN@.PTOLIST@.TARGET,EQN@.PTOWNER);
      WORD:='END      '; PASSOBJWORD;
      WORD:='UNTIL    '; PASSOBJWORD;
      WORD:=' ABS     '; PASSOBJWORD;
      WORD:='(FPS0000F'; PASSOBJWORD;
      WORD:=')< 0.0001'; PASSOBJWORD;
      IF EQN@.PTOWNER <> NIL THEN
      BEGIN
           WORD:='END      '; PASSOBJWORD;
      END;
      CURCHAR:=';';      PASSOBJCHAR
 END;
 PROCEDURE GENIONUMBER(EQN:PTKNOT);
 VAR
      SHOOKED:BOOLEAN;
      NUM:INTEGER;
      CURPARM:PTLISTMEMB;
      OUTPARM:PTKNOT;
      ICURPARM:INTEGER;
 BEGIN
      OUTPARM:=EQN@.PTOLIST@.TARGET;
      CURPARM:=EQN@.FIRSTPARM;
      ICURPARM:=1;
      SHOOKED:=FALSE;
      WHILE (CURPARM <> NIL) AND (NOT SHOOKED) DO
      BEGIN
           IF CURPARM@.TARGET = OUTPARM THEN
           BEGIN
                SHOOKED:=TRUE;
                NUM:=ICURPARM
           END;
           ICURPARM:=ICURPARM+1;
           CURPARM:=CURPARM@.NEXT
       END;
       PASSOBJINT(NUM)
 END;
 PROCEDURE GENSIMPLEEQN(EQN:PTKNOT);
 VAR
    I:INTEGER;
    CURPARM:PTLISTMEMB;
 BEGIN
      FOR I:=1 TO 8 DO WORD[ I ] :=EQN@.MODULENAME[ I ] ;
      WORD[ 9 ] :='(';
      PASSOBJWORD;
      GENIONUMBER(EQN);
      CURPARM:=EQN@.FIRSTPARM;
      WHILE CURPARM <> NIL DO
      BEGIN
           CURCHAR:=','; PASSOBJCHAR;
           GENEXEPTOWR(CURPARM@.TARGET,EQN@.PTOWNER);
           CURPARM:=CURPARM@.NEXT
      END;
      CURCHAR:=')'; PASSOBJCHAR;
      CURCHAR:=';'; PASSOBJCHAR
 END;
 PROCEDURE GENEQN(EQN:PTKNOT);
 BEGIN
      IF EQN@.MODULENAME = '        '
      THEN GENCOMPOUNDEQN(EQN)
      ELSE GENSIMPLEEQN(EQN)
 END;
 PROCEDURE GENREL(VAR REL:PTKNOT);
 BEGIN
 IF REL@.PTOWNER <> NIL THEN
 BEGIN
      WORD:='WITH     '; PASSOBJWORD;
      CURCHAR:=' '; PASSOBJCHAR;
      GENFULLNAME(REL@.PTOWNER);
      WORD:=' DO      '; PASSOBJWORD;
      CURCHAR:=' '; PASSOBJCHAR
 END;
      CASE REL@.KNOTSUBTYPE OF
           LETK:GENLET(REL);
           EQNK:GENEQN(REL);
        MODULEK:GENMODULE(REL)
      END
 END;
 PROCEDURE GENDESCRIPTION(REL:PTKNOT);
 {  GEN "REL" 'S PROC 'S DESCRIPTION }
 VAR
    I:INTEGER;
    EXTRNBODY:PACKED ARRAY [ 1 .. 8 ] OF CHAR;
    CURPARM:PTLISTMEMB;
 BEGIN
      WORD:='PROCEDURE'; PASSOBJWORD;
      CURCHAR:=' ';      PASSOBJCHAR;
      FOR I:=1 TO 8 DO WORD[ I ]:=REL@.MODULENAME[ I ];
      WORD[ 9 ]:=' ';
      PASSOBJWORD;
      CURCHAR:='('; PASSOBJCHAR;
      CURPARM:=REL@.FIRSTPARM;
      WHILE CURPARM <> NIL DO
      BEGIN
            WORD:='VAR      ';PASSOBJWORD;
          FOR I:=1 TO 8 DO WORD[ I ]:=CURPARM@.TARGET@.NAME[ I ];
          WORD [ 9 ]:=' ';
          PASSOBJWORD;
          CURCHAR:=':'; PASSOBJCHAR;
          CASE CURPARM@.TARGET@.KNOTSUBTYPE OF
               REALK:BEGIN
                          WORD:='REAL     '; PASSOBJWORD
                     END;
            INTEGERK:BEGIN
                          WORD:='INTEGER  '; PASSOBJWORD
                    END;
           BOOLEANK:BEGIN
                          WORD:='BOOLEAN  '; PASSOBJWORD
                    END
             END;
             CURPARM:=CURPARM@.NEXT;
             IF CURPARM <> NIL THEN
             BEGIN
                  CURCHAR:=';'; PASSOBJCHAR
             END
        END;
        CURCHAR:=')'; PASSOBJCHAR;
        CURCHAR:=';'; PASSOBJCHAR;
        EXTRNBODY:=ENAME;
        FOR I:=1 TO 8 DO WORD[ I ]:=EXTRNBODY[ I ];
        WORD[ 9 ]:=';';
        PASSOBJWORD;
 END;
 PROCEDURE GENEXTERNALS;
 {  GEN EXTRNS PROCS DESCRIPTIONS }
 VAR
    CURKNOT:PTKNOT;
 BEGIN
       CURKNOT:=FIRSTKNOT;
       WHILE CURKNOT <> NIL DO
       BEGIN
            IF (CURKNOT@.KNOTSUBTYPE = MODULEK) AND
                CURKNOT@.APPLICATED AND
                CURKNOT@.KEPT THEN
            BEGIN
                 IF CURKNOT@.MODULELOC = EXTRN
                 THEN GENDESCRIPTION(CURKNOT)
            END;
            CURKNOT:=CURKNOT@.NEXT
      END
 END;
 PROCEDURE GENEQNVARS;
 VAR
    CURKNOT:PTKNOT;
    EQNPRESENT:BOOLEAN;
 BEGIN
      EQNPRESENT:=FALSE;
      CURKNOT:=FIRSTKNOT;
      WHILE (CURKNOT <> NIL) AND (NOT EQNPRESENT) DO
      BEGIN
           IF (CURKNOT@.KNOTSUBTYPE = EQNK) AND
               CURKNOT@.APPLICATED          AND
               CURKNOT@.KEPT                THEN EQNPRESENT:=TRUE;
           CURKNOT:=CURKNOT@.NEXT
      END;
      IF EQNPRESENT THEN
      BEGIN
           WORD:='VAR      '; PASSOBJWORD;
           WORD:='FPS0000D:'; PASSOBJWORD;
           WORD:='REAL     '; PASSOBJWORD;
           CURCHAR:=';';      PASSOBJCHAR;
           WORD:='FPS0000F:'; PASSOBJWORD;
           WORD:='REAL     '; PASSOBJWORD;
           CURCHAR:=';';      PASSOBJCHAR;
           WORD:='FPS000FD:'; PASSOBJWORD;
           WORD:='REAL     '; PASSOBJWORD;
           CURCHAR:=';';      PASSOBJCHAR;
           WORD:='FPS0000C:'; PASSOBJWORD;
           WORD:='REAL     '; PASSOBJWORD;
           CURCHAR:=';';      PASSOBJCHAR;
      END
 END;
 PROCEDURE GENPASCAL;
 {  GENERATE PASCAL ALGORITHM BY COMPUTE }
 VAR
    CURKNOT:PTKNOT;
    USENUMBER:INTEGER;
    GENERATED:BOOLEAN;
 BEGIN
      GENEQNVARS;   {  GEN SERVICE VARS FOR SOLV. EQN IF NEEDED }
      GENEXTERNALS; {  GEN EXTRN DESCR. IF NEEDED }
      WORD:='BEGIN    '; PASSOBJWORD;
      FOR USENUMBER:=1 TO RELCOUNT DO
      BEGIN
           GENERATED:=FALSE;
           CURKNOT:=FIRSTKNOT;
           WHILE (CURKNOT <> NIL) AND (NOT GENERATED) DO
           BEGIN
                IF (CURKNOT@.KNOTTYPE = RELK) AND
                   (CURKNOT@.GENERATION = USENUMBER) AND
                   CURKNOT@.APPLICATED AND
                   CURKNOT@.KEPT
                THEN
                BEGIN
                     GENERATED:=TRUE;
                     GENREL(CURKNOT)
                END;
                CURKNOT:=CURKNOT@.NEXT
           END
       END;
       WORD:='END      '; PASSOBJWORD;
 END;
 PROCEDURE INTERPRETE;
 {  INTERPRETE "COMPUTE" OPERATOR WHICH IS SCANED }
 VAR
    CURKNOT:PTKNOT;
 BEGIN
      {  SET INITIAL FLAGS IN KNOTS }
      CURKNOT:=FIRSTKNOT;
      WHILE CURKNOT <> NIL DO
      BEGIN
           WITH CURKNOT@ DO
           BEGIN
                GENERATION:=0;
                APPLICATED:=FALSE;
                KEPT:=FALSE;
                TRYED:=FALSE;
           END;
           CURKNOT:=CURKNOT@.NEXT;
      END;
      RELCOUNT:=0;
      ALLTRYED:=FALSE;
      {  BUILD ALL KINDERS OF DATALIST }
      WATERUP;
      IF NOT SOLVED THEN ERROR(804)
      ELSE
      BEGIN
           KEEPBEUSED;
 {  DEBUG    DEBUG:=TRUE;  }
 {  DEBUG    MAPPING;      }
           GENPASCAL
      END
 END;
 PROCEDURE ACTCOMPUTE;
 {  NOTE: "COMPUTE" SCANNED, "CURCHAR" IS HIS DELIMITER }
 BEGIN;
      WASBADOPERATOR:=FALSE;
      IF CURCHAR <> ' ' THEN ERROR(24);
      FIRSTMEMBER:=NIL;
      RESLIST:=NIL;
      REPEAT
            GOFORWARD;
            { ALG}  PASSNAME;
            NAME;
            { ALG}  ENDNAME;
            { ALG}  ATTACHNAME
      UNTIL CURCHAR <> ',';
      RESLIST:=FIRSTMEMBER;
      FIRSTMEMBER:=NIL;
      DATALIST:=NIL;
      IF CURCHAR <> ';' THEN
      BEGIN
           IF CURCHAR <> ' ' THEN ERROR(24);
           GOFORWARD;
           GETLEXEMA;
           IF CURLEX <> AFROM THEN ERROR(801);
           IF CURCHAR <> ' '  THEN ERROR(24);
           REPEAT
                 GOFORWARD;
                 { ALG} PASSNAME;
                 NAME;
                 { ALG} ENDNAME;
                 { ALG} ATTACHNAME
           UNTIL CURCHAR <> ',';
           DATALIST:=FIRSTMEMBER
      END;
      {  ALG }  IF NOT WASBADOPERATOR THEN INTERPRETE
 END;
 PROCEDURE ACTPROC;
 BEGIN
      PASSOBJCHAR;
      GOFORWARD; {  TO PROCNAME }
      GETWORD;   {  GET PRCNAME }
      IF NOT WASEOF THEN
      BEGIN
           ACTWKNAME; {  SIGN MODULE NAME AS INTERNAL }
           PASSOBJWORD; {  PASS PROCNAME }
           IF CURCHAR = ';' THEN
           BEGIN
                PASSOBJCHAR;
                GOFORWARD;
                GETWORD;
                IF NOT WASEOF THEN
                BEGIN
                     IF WORD = 'COMPUTE  ' THEN ACTCOMPUTE
                                           ELSE PASSOBJWORD
                END
           END
     END
 END;
 PROCEDURE GENVARS;
 VAR
    CURKNOT:PTKNOT;
    SAVEDWORD:PACKED ARRAY [ 1..9 ] OF CHAR;
    SAVEDCURCHAR:CHAR;
 BEGIN
      SAVEDWORD:=WORD; SAVEDCURCHAR:=CURCHAR;
      IF WORD = 'VAR      ' THEN SAVEDWORD:='         ';
      {  IGNORE USER'S "VAR" - IT WILL BE GENERATED THERE }
      IF FIRSTKNOT = NIL THEN ERROR(800)
                         ELSE
      BEGIN
           CURKNOT:=FIRSTKNOT;
           WORD:='VAR      ';
           PASSOBJWORD;
           REPEAT
                 IF (CURKNOT@.PTOWNER = NIL)      AND
                    (CURKNOT@.NAME <> '&&&&&&&&') AND
                    (CURKNOT@.KNOTTYPE = VARK) THEN
                 BEGIN
                      GENREC(CURKNOT);
                      CURCHAR:=';'; PASSOBJCHAR;
                 END;
                 CURKNOT:=CURKNOT@.NEXT;
           UNTIL CURKNOT = NIL
      END;
      WORD:=SAVEDWORD; CURCHAR:=SAVEDCURCHAR
 END;
 PROCEDURE GETWORD;
 VAR
    LETTERCOUNT:INTEGER;
 BEGIN
      LETTERCOUNT:=0;
      WORD:='         ';
      WHILE SIMILAR DO
      BEGIN
           LETTERCOUNT:=LETTERCOUNT+1;
           IF LETTERCOUNT <= 9 THEN WORD[LETTERCOUNT]:=CURCHAR;
           GOFORWARD
      END;
      IF (WORD = 'VAR      ') OR
         (WORD = 'PROCEDURE') OR
         (WORD = 'BEGIN    ') THEN  MUSTBEVARS:=TRUE;
      IF MUSTBEVARS AND (NOT VARSGENERATED) THEN
      BEGIN
           GENVARS;
           VARSGENERATED:=TRUE
      END
 END;
 PROCEDURE GREATBOSS;
 {  ATTACH ALL HIGHEST-LEV.MODELS TO BOSS }
 VAR
    NEWMEMB:PTLISTMEMB;
    CURKNOT:PTKNOT;
 BEGIN
      NEW(BOSS);
      CURRENTOWNER:=BOSS;
      BOSS@.PTOWNER:=NIL;
      BOSS@.PTMEMBLIST:=NIL;
      BOSS@.NAME:='&&&&&&&&';
      BOSS@.KNOTTYPE:=VARK;
      BOSS@.KNOTSUBTYPE:=STRUCTUREK;
      BOSS@.COST:=0;
      BOSS@.PTILIST:=NIL;
      BOSS@.PTOLIST:=NIL;
      BOSS@.ORDVALUE:=0;
      CURKNOT:=FIRSTKNOT;
      WHILE CURKNOT <> NIL DO
      BEGIN
           IF CURKNOT@.PTOWNER = NIL THEN
           BEGIN
                NEW(NEWMEMB);
                NEWMEMB@.TARGET:=CURKNOT;
                NEWMEMB@.NEXT:=BOSS@.PTMEMBLIST;
                BOSS@.PTMEMBLIST:=NEWMEMB
           END;
           CURKNOT:=CURKNOT@.NEXT
     END;
     BOSS@.NEXT:=FIRSTKNOT;
     FIRSTKNOT:=BOSS;
 END;
 PROCEDURE FINDMAX(VAR KFROM:PTKNOT;VAR PREVMAXS:PTKNOT;VAR MAXS:PTKNOT;
                   VAR SORTED:BOOLEAN);
 VAR
    CURKNOT:PTKNOT;
    SAVEDCUR:PTKNOT;
    MAXIMUM:INTEGER;
 BEGIN
      CURKNOT:=KFROM;
      MAXIMUM:=0;
      SORTED:=TRUE;
      WHILE CURKNOT <> NIL DO
      BEGIN
           IF CURKNOT@.KNOTTYPE = RELK THEN
           BEGIN
                SORTED:=FALSE;
                IF CURKNOT@.COST >= MAXIMUM THEN
                BEGIN
                     MAXIMUM:=CURKNOT@.COST;
                     PREVMAXS:=SAVEDCUR;
                     MAXS:=CURKNOT
                END
           END;
           SAVEDCUR:=CURKNOT;
           CURKNOT:=CURKNOT@.NEXT
     END
 END;
 PROCEDURE SORTRELS;
 {  SORT RELS FR. LOWER TO UPPER BY REPLACING TO START }
 VAR
    OLDFIRST:PTKNOT;
    SORTED:BOOLEAN;
    PREVMAXS:PTKNOT;
    MAXS:PTKNOT;
 BEGIN
      OLDFIRST:=FIRSTKNOT;
      {  FIRST IS ALWAYS VAR - BOSS }
      REPEAT
            FINDMAX(OLDFIRST,PREVMAXS,MAXS,SORTED);
            IF NOT SORTED THEN
            BEGIN
                 PREVMAXS@.NEXT:=MAXS@.NEXT;
                 MAXS@.NEXT:=FIRSTKNOT;
                 FIRSTKNOT:=MAXS
            END
      UNTIL SORTED
 END;
 PROCEDURE ACTIONS;
 BEGIN
      SUBTITLE:='ACTIONS DESCRIPTION     ';
      OBJPOS:=1;
      WASEOLNOBJECT:=FALSE;
      VARSGENERATED:=FALSE;
      MUSTBEVARS:=FALSE;
      WASBADOPERATOR:=FALSE;
      OBJSHIFT:=1;
      PREVOBJCHAR:=' ';
      { ALG}  GREATBOSS;
      { ALG}  SORTRELS;
      OPENCLOSE(FREWRITE,FOBJECT);
      WRITE(OBJECT,' {  PRODUCED BY FPS ');
      WRITE(OBJECT,VERSION);
      WRITE(OBJECT,' } ');
      OBJPOS:=VERSLENGTH+32;
      EOLNOBJECT;
      PASCLINES:=0;
      REPEAT
            PASSUNTIL;    {  UNTIL START OF WORD }
            IF NOT WASEOF THEN
            BEGIN
                 GETWORD;
                 IF NOT WASEOF THEN
                 BEGIN
                      PASSOBJWORD;
                      IF WORD = 'PROCEDURE' THEN ACTPROC
                 END
            END
     UNTIL (CURCHAR = '?') AND EOF(INPUT);
     IF OBJPOS > OBJSHIFT THEN EOLNOBJECT
 END;
         {  ---------------------------------------------- }
         {  THIS IS THE M A I N - PROGRAM OF  P R I Z -86  }
         {  ---------------------------------------------- }
 BEGIN
      OPENCLOSE(FRESET,FINPUT);
      OPENCLOSE(FREWRITE,FOUTPUT);
 {  DEBUG }  DEBUG:=FALSE;
      INITIAL;
      MODEL;
      IF NOT WASEOF THEN
         BEGIN
              IF CURCHAR <> '!' THEN ERROR(22);
              INACTIONS:=TRUE;
              GOFORWARD;
              IF NOT WASEOF THEN ACTIONS
          END;
    WRITEERR;
    SUMMARY
 END.
