From ankh.iia.org!uunet!MathWorks.Com!europa.eng.gtefsd.com!howland.reston.ans.net!paladin.american.edu!auvm!HSI.COM!siperas Tue Aug 23 20:39:24 1994
Path: ankh.iia.org!uunet!MathWorks.Com!europa.eng.gtefsd.com!howland.reston.ans.net!paladin.american.edu!auvm!HSI.COM!siperas
Comments: Gated by NETNEWS@AUVM.AMERICAN.EDU
Newsgroups: comp.lang.rexx
X-Mailer: Mail User's Shell (7.1.2 7/11/90)
Message-ID: <199408231832.AA18647@hsi86.hsi.com>
Date: Tue, 23 Aug 1994 14:32:40 EDT
Sender: REXX Programming discussion list <REXXLIST@UGA.BITNET>
From: Steve Siperas <siperas@HSI.COM>
Subject: A call from rexx to ASM370 pgm
Comments: To: REXXLIST@uga.cc.uga.edu
Lines: 193

Hi

My mind is fading - I've done this before but it's greek to me now.
I have a rexx exec passing a string to an assemble pgm. This
use to work in another pgm but now complains about about no info returned
to the calling rexx exec. Here is rexx exec and the asm pgm.
We recently went from VM/SP to VM/XA if that makes a difference?
Also is there an easier way to pass data to a ASM pgm this parmlist
stuff seems more complicated then it should be?

I would step thru the asm pgm but I
Also forgot how I tested this before - I wanted to step thru
the asm program using per but I forgot how to run the rexx exec and
then be able to stop the asm pgm it is calling. Boy I forgot alot
in 2 years :-)

thanks - I do this once every 2 years so I tend to forget

steve
siperas@hsi.com

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
exec to run load module
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

FILEDEF APD100DX DISK DXTAB100 BIN B
FILEDEF APD100SG DISK SGTAB100 BIN B
FILEDEF APD100DG DISK DGTAB100 BIN B
FILEDEF APD100CC DISK CCTAB100 BIN B
FILEDEF APD100MC DISK MCTAB100 BIN B
FILEDEF APD100NC DISK NCTAB100 BIN B
FILEDEF APD100NT DISK NTTAB100 BIN B
LOADMOD RXAPD100

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
rexx exec that calls RXAPD100
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

/* Sample Server for APD with client being a interface on VAX */
data = '1233/33/3344/44/4455/55/55      V3000'
response = RXAPD100(data)
exit

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
asm pgm called from rexx
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

* THIS IS THE STUB PROGRAM TO REFORMAT DATA FROM REXX INTERFACE PGM     RXA00010
*                                                                       RXA00020
RXAPD100 CSECT                                                          RXA00030
         USING *,R12                                                    RXA00040
         STM   R14,R12,12(R13)                                          RXA00050
         LR    R12,R15                                                  RXA00060
         LA    R2,SAVEAREA                                              RXA00070
         ST    R2,8(R13)                                                RXA00080
         ST    R13,4(R2)                                                RXA00090
         LR    R13,R2                                                   RXA00100
*                                                                       RXA00110
         XC    RCODE,RCODE            MAKE A ZERO RETURNCODE            RXA00120
*                                     PROPER PLIST AVAILABLE?           RXA00130
         CLM   R1,B'1000',=X'05'      WAS THIS A REXX FUNCTION CALL?    RXA00140
         BNE   EOF                    NO! ABORT ABORT ABORT             RXA00150
*                                     FETCH THE ARGS                    RXA00160
         LR    R8,R0                  MAKE A COPY OF THE EPLIST PRT     RXA00170
         L     R2,16(R8)              FETCH PTR TO FUNCTION ARG LIST    RXA00180
         L     R4,0(R2)               FETCH PTR TO ARG1 (PATTERN)       RXA00190
         L     R5,4(R2)               FETCH LEN OF ARG1 (PATTERN)       RXA00200
         C     R4,=4X'FF'             WAS THERE AN ARG?                 RXA00210
         BE    TOOFEW                 NO, COMPLAIN                      RXA00220
         MVC   BUFFER(123),0(R4)      COPY INPUT INFO TO BUFFER         RXA00230
         MVI   RESULTS,C' '                                             RXA00240
         MVC   RESULTS+1(47),RESULTS  CLEAR RETURN AREA                 RXA00250
         LA    R1,PTR                 R1 -> GROUPER REQUIRED INFO       RXA00260
         OI    ATRI,X'80'                                               RXA00270
         CALL  APD100CN               CALL GROUPER                      RXA00280
         NI    ATRI,X'7F'                                               RXA00290
         B     SUCCESS                                                  RXA00300
TOOMANY  EQU   *                      TOO MANY ARGS, COMPLAIN           RXA00310
TOOFEW   EQU   *                      NOT ENOUGH ARGS                   RXA00320
         MVC   RCODE,=F'2'            SET A RETURNCODE                  RXA00330
         B     EOF                    GO HOME                           RXA00340
TOOSHORT EQU   *                                                        RXA00350
         MVC   RCODE,=F'4'                                              RXA00360
         B     EOF                                                      RXA00370
ARGTHERE EQU   *                      LOOK CLOSER AT THE ARGS           RXA00380
         LTR   R5,R5                  FIRST ARG ZERO LENGTH?            RXA00390
         BZ    TOOSHORT               YES, GO COMPLAIN                  RXA00400
SUCCESS  EQU   *                                                        RXA00410
         SR    R15,R15                IT WORKED- ZERO CC.               RXA00420
MAKEEVAL EQU   *                                                        RXA00430
         LA    R0,12                  SIZE OF EVALBLOK (DWORDS)         RXA00440
*        DMSFREE DWORDS=(0),TYPE=USER,ERR=EOF                           RXA00450
         XC    0(64,R1),0(R1)         ZAP THE EVALBLOK                  RXA00460
         MVC   4(4,R1),=F'8'          LENGTH OF EVALBLOK (DWORDS)       RXA00470
         MVC   8(4,R1),=F'48'         LENGTH OF RESULT                  RXA00480
         MVC   16(48,R1),RESULTS                                        RXA00490
         L     R9,20(R8)              WHERE TO PUT A(EVALBLOK)          RXA00500
         ST    R1,0(R9)               POINT TO EVALBLOK FOR CALLER      RXA00510
*DEPART   EQU   *                                                       RXA00520
*         L     R13,SAVEAREA+4        PTR TO CALLERS SAVE AREA          RXA00530
*         MVC   16(4,R13),RCODE       MOVE RETURNCODE INTO R15 SAVE ARE RXA00540
*         RETURN (14,12)              RESTORE REGS, GO HOME             RXA00550
EOF      L     R13,SAVEAREA+4                                           RXA00560
         LM    R14,R12,12(R13)                                          RXA00570
         L     R15,RCODE                                                RXA00580
         BR    R14                                                      RXA00590
*********************************************************************** RXA00600
*                 DEFINE STORAGE AREAS                                  RXA00610
*********************************************************************** RXA00620
SAVEAREA DS    18F                                                      RXA00630
NDX      DC    F'10'                                                    RXA00640
NSG      DC    F'10'                                                    RXA00650
RCODE    DS    F                                                        RXA00660
PTR      DC    A(DX)                                                    RXA00670
         DC    A(NDX)                                                   RXA00680
         DC    A(SG)                                                    RXA00690
         DC    A(NSG)                                                   RXA00700
         DC    A(SEX)                                                   RXA00710
         DC    A(DSTAT)                                                 RXA00720
         DC    A(BDATE)                                                 RXA00730
         DC    A(ADATE)                                                 RXA00740
         DC    A(DDATE)                                                 RXA00750
         DC    A(CIND)                                                  RXA00760
         DC    A(BWT)                                                   RXA00770
         DC    A(BWO)                                                   RXA00780
         DC    A(DRG)                                                   RXA00790
         DC    A(MDC)                                                   RXA00800
         DC    A(RTC)                                                   RXA00810
         DC    A(OR1)                                                   RXA00820
         DC    A(OR2)                                                   RXA00830
         DC    A(OR3)                                                   RXA00840
         DC    A(NOR1)                                                  RXA00850
         DC    A(NOR2)                                                  RXA00860
         DC    A(DX1)                                                   RXA00870
         DC    A(DX2)                                                   RXA00880
         DC    A(DX3)                                                   RXA00890
         DC    A(DXCC)                                                  RXA00900
         DC    A(MCCI)                                                  RXA00910
ATRI     DC    A(TRI)                                                   RXA00920
*                                                                       RXA00930
BUFFER   DS   0CL171                                                    RXA00940
SEX      DS    CL1                                                      RXA00950
DSTAT    DS    CL2                                                      RXA00960
BDATE    DS    CL8                                                      RXA00970
ADATE    DS    CL8                                                      RXA00980
DDATE    DS    CL8                                                      RXA00990
CIND     DS    CL1                                                      RXA01000
BWT      DS    CL4                                                      RXA01010
BWO      DS    CL1                                                      RXA01020
DX       DS    CL50                                                     RXA01030
SG       DS    CL40                                                     RXA01040
RESULTS  DS   0CL48                                                     RXA01050
DRG      DS    CL3                                                      RXA01060
MDC      DS    CL2                                                      RXA01070
RTC      DS    CL1                                                      RXA01080
OR1      DS    CL4                                                      RXA01090
OR2      DS    CL4                                                      RXA01100
OR3      DS    CL4                                                      RXA01110
NOR1     DS    CL4                                                      RXA01120
NOR2     DS    CL4                                                      RXA01130
DX1      DS    CL5                                                      RXA01140
DX2      DS    CL5                                                      RXA01150
DX3      DS    CL5                                                      RXA01160
DXCC     DS    CL5                                                      RXA01170
MCCI     DS    CL1                                                      RXA01180
TRI      DS    CL1                                                      RXA01190
*                                                                       RXA01200
* DEFINITION OF EVALBLOK                                                RXA01210
*                                                                       RXA01220
EVALBLOK DSECT                                                          RXA01230
EVBPAD1  DS    F                      RESEVERED                         RXA01240
EVSIZE   DS    F                      TOTAL SIZE IN DW'S                RXA01250
EVLEN    DS    F                      LENGTH OF DATA IN BYTES           RXA01260
EVBPAD2  DS    F                      RESERVED SHOULD BE SET TO 0       RXA01270
EVDATA   DS    CL48                   THE RETURNED CHARACTER STRING     RXA01280
*                                     FROM GROUPER                      RXA01290
*                                                                       RXA01300
R0       EQU   0                                                        RXA01310
R1       EQU   1                                                        RXA01320
R2       EQU   2                                                        RXA01330
R3       EQU   3                                                        RXA01340
R4       EQU   4                                                        RXA01350
R5       EQU   5                                                        RXA01360
R6       EQU   6                                                        RXA01370
R7       EQU   7                                                        RXA01380
R8       EQU   8                                                        RXA01390
R9       EQU   9                                                        RXA01400
R10      EQU   10                                                       RXA01410
R11      EQU   11                                                       RXA01420
R12      EQU   12                                                       RXA01430
R13      EQU   13                                                       RXA01440
R14      EQU   14                                                       RXA01450
R15      EQU   15                                                       RXA01460
         END                                                            RXA01470

From ankh.iia.org!uunet!MathWorks.Com!news.duke.edu!eff!wariat.org!malgudi.oar.net!news.ysu.edu!psuvm!auvm!VM.SAS.COM!SNOKLF Tue Aug 23 20:39:35 1994
Path: ankh.iia.org!uunet!MathWorks.Com!news.duke.edu!eff!wariat.org!malgudi.oar.net!news.ysu.edu!psuvm!auvm!VM.SAS.COM!SNOKLF
Comments: Gated by NETNEWS@AUVM.AMERICAN.EDU
Newsgroups: comp.lang.rexx
Message-ID: <940823.165905.EDT.SNOKLF@vm.sas.com>
Date: Tue, 23 Aug 1994 16:57:05 EDT
Sender: REXX Programming discussion list <REXXLIST@UGA.BITNET>
From: Kent Fiala <SNOKLF@VM.SAS.COM>
Organization: SAS Institute Inc.
Subject: Re: A call from rexx to ASM370 pgm
In-Reply-To: <199408231832.AA18647@hsi86.hsi.com>
Lines: 28

On Tue, 23 Aug 1994 14:32:40 EDT Steve Siperas said:
>My mind is fading - I've done this before but it's greek to me now.
>I have a rexx exec passing a string to an assemble pgm. This
>use to work in another pgm but now complains about about no info return
>to the calling rexx exec. Here is rexx exec and the asm pgm.
>We recently went from VM/SP to VM/XA if that makes a difference?

Yes, the high order byte of R1 is no longer the place to look for the
calltype byte (since R1 might contain a 31-bit address).

>         CLM   R1,B'1000',=X'05'      WAS THIS A REXX FUNCTION CALL?

You want to look for the X'05' in field USECTYP of the USERSAVE block,
which is pointed to initially by R13.



>*        DMSFREE DWORDS=(0),TYPE=USER,ERR=EOF

I'm also dubious about commenting this out and using program storage
for the EVALBLOK.  I think you're going to get an error when REXX tries
to free the EVALBLOK.  But now that you're on XA, don't just go back
to using the DMSFREE, replace it with

          CMSSTOR OBTAIN,DWORDS=(R0),ERR=EOF

------------------------------------------------------------------------
Kent Fiala <snoklf@vm.sas.com>
SAS Institute Inc., Cary NC 27513 USA                 919-677-8000 x6646

