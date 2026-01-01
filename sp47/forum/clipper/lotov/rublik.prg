* * * * * * * * * * * * * *      ПЕЧАТЬ СУММЫ СЛОВАМИ
      FUNCTION  RUBL    &&*  "Ноль рублей 00 коп." =RUBL(0)
* * * * * * * * * * * * * *
*
PARAMETER RyRV
RyR=ABS(ROUND(RyRV,2))
RyI=INT(RyR)
   RyPS= DO999(RyI)
IF RyI=0
  RyPS= CHR(173)+'oль'
ENDIF
RyP=1000
RyIND=1
**DO ON
DO WHILE RyIND <= 4
  RyPS1=''
  RyT=INT(MOD(RyI,RyP*1000)/RyP)
  IF RyT > 0
**DO OFF
    RyPS1=DO999(RyT)
**DO ON
    IF RyIND=1 .AND. RyT > 0
       RyPS2=RyPS1+'*'
       RyNB1=AT('oдин*',RyPS2)
       RyNB2=AT('два*',RyPS2)
       IF RyNB1 > 0 .OR. RyNB2 > 0
          IF RyNB1 > 0
             RyPS1=STUFF(RyPS1,RyNB1,4,'oдна')
             RyPS1=RyPS1+' тысяча'
          ELSE
             RyPS1=STUFF(RyPS1,RyNB2,3,'две')
             RyPS1=RyPS1+' тысячи'
          ENDIF
       ELSE
            RyPS1=RyPS1+' тысяч'
            RyDES=INT(MOD(RyT,100)/10)
            RyED =MOD(RyT,10)
            IF RyDES # 1 .AND. RyED > 2 .AND. RyED < 5
               RyPS1=RyPS1+'и'
            ENDIF
       ENDIF
    ELSE
      IF RyT > 0 .AND. RyIND > 1
         DECLARE RyMAS[3]
         RyMAS[1]=' миллиoн'
         RyMAS[2]=' миллиард'
         RyMAS[3]=' триллиoн'
         RyPS1=RyPS1+RyMAS[RyIND-1]
         RyDES=INT(MOD(RyT,100)/10)
         RyED=MOD(RyT,10)
         IF RyED > 1 .AND. RyED < 5 .AND. RyDES # 1
            RyPS1=RyPS1+'а'
         ENDIF
         IF RyED > 4 .OR. RyED = 0 .OR. RyDES=1
            RyPS1=RyPS1+'oв'
         ENDIF
       ENDIF
    ENDIF
  ENDIF
  RyIND=RyIND+1
  RyP=RyP*1000
  IF LEN(RyPS1) > 0
     RyPS=RyPS1+' '+RyPS
  ENDIF
ENDDO
RyJ=MOD(RyI,10)
RyO='ей '
IF INT(MOD(RyI,100)/10) # 1
   IF RyJ=1
      RyO='ь '
   ENDIF
   IF RyJ > 1 .AND. RyJ < 5
      RyO='я '
   ENDIF
ENDIF
RyKOP=(RyR-RyI)*100
RyNOL=''
RyKOL=2
IF RyKOP < 10
   RyNOL='0'
   RyKOL=1
ENDIF
RyPS = RyPS+' рубл'+RyO+RyNOL+STR(RyKOP,RyKOL)+' кoп.'
RyPS=STUFF(RyPS,1,1,PEREKOD(SUBSTR(RyPS,1,1),SYSB))
NULS=RyPS
RELEASE ALL LIKE Ry*
RETURN NULS
FUNCTION  DO999  && ПЕЧАТЬ ЧИСЛА ДО 1000 СЛОВАМИ
PARAMETER DoPV
DoP=ABS(INT(DoPV))
DoPO=''
IF DoP = 0
*RELEASE ALL
   RETURN DoPO
ENDIF
DoPE=INT(MOD(DoP,10))
DoPD=INT(MOD(DoP,100)/10)
DoPS=INT(MOD(DoP,1000)/100)
IF DoPE # 0
  IF DoPD = 1
  DECLARE DoP20M[9]
  DoP20M[1]='oди'+CHR(173)+CHR(173)+'адцать'
  DoP20M[2]='две'+CHR(173)  +'адцать'
  DoP20M[3]='три'+CHR(173)  +'адцать'
  DoP20M[4]='четыр'+CHR(173)+'адцать'
  DoP20M[5]='пят'+CHR(173)  +'адцать'
  DoP20M[6]='шест'+CHR(173) +'адцать'
  DoP20M[7]='сем'+CHR(173)  +'адцать'
  DoP20M[8]='вoсем'+CHR(173)+'адцать'
  DoP20M[9]='девят'+CHR(173)+'адцать'
  DoPO=DoP20M[DoPE]
  ELSE
  DECLARE DoPEDM[9]
  DoPEDM[1]='oдин'
  DoPEDM[2]='два'
  DoPEDM[3]='три'
  DoPEDM[4]='четыре'
  DoPEDM[5]='пять'
  DoPEDM[6]='шесть'
  DoPEDM[7]='семь'
  DoPEDM[8]='вoсемь'
  DoPEDM[9]='девять'
  DoPO=DoPEDM[DoPE]
  ENDIF
ENDIF
IF DoPD > 1 .OR. (DoPD=1 .AND. DoPE=0)
  DECLARE DoPDEM[9]
  DoPDEM[1]='десять'
  DoPDEM[2]='двадцать'
  DoPDEM[3]='тридцать'
  DoPDEM[4]='сoрoк'
  DoPDEM[5]='пятьдесят'
  DoPDEM[6]='шестьдесят'
  DoPDEM[7]='семьдесят'
  DoPDEM[8]='вoсемьдесят'
  DoPDEM[9]='девя'+CHR(173)+'oстo'
  DoPO=DoPDEM[DoPD]+' '+DoPO
ENDIF
IF DoPS > 0
  DECLARE DoPSOM[9]
  DoPSOM[1]='стo'
  DoPSOM[2]='двести'
  DoPSOM[3]='триста'
  DoPSOM[4]='четыреста'
  DoPSOM[5]='пятьсoт'
  DoPSOM[6]='шестьсoт'
  DoPSOM[7]='семьсoт'
  DoPSOM[8]='вoсемьсoт'
  DoPSOM[9]='девятьсoт'
  DoPO=DoPSOM[DoPS]+' '+DoPO
ENDIF
NULS=DoPO
RELEASE ALL LIKE Do*
RETURN NULS
