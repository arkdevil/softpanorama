#include  <dos.h>
#include  <time.h>
#include  <stdio.h>
#include  <conio.h>
#include  <comlib.h>

typedef  unsigned char  byte;

#define  FALSE  0
#define  TRUE   1


#define  DataEchoOn     1h      /* Эхо в режиме данных */
#define  ComEchoOn      2h      /* Эхо в режиме команд */
#define  ResultCodeOff  4h      /* Запрещение выдачи результирующих кодов */
#define  ResultCodeWord 8h      /* Результирующие коды в текстовом виде   */
#define  AutoResponsOff 10h     /* Блокирование автоответа  */
#define  PulseCall      20h     /* Импульсный вызов         */
#define  V22ModeOn      40h     /* Передача в стандарте V22 */
#define  OutChanal      80h     /* */



/**************************************************************************
	      Описание кодов возврата
***************************************************************************/

/*-----------------  цифровое значение -----------------------------------*/
#define  OK             0
#define  CONNECT        1
#define  RING           2
#define  NO_CARRIER     3
#define  ERROR          4
#define  CONNECT_1200   5
#define  NO_DIALTONE    6
#define  BUSY           7
#define  NO_ANSWER      8

/*------------------ символьное значение ------------------------------*/
   char  c0[] = {"OK"};
   char  c1[] = {"CONNECT"};
   char  c2[] = {"RING"};
   char  c3[] = {"NO CARRIER"};
   char  c4[] = {"ERROR"};
   char  c5[] = {"CONNECT 1200"};
   char  c6[] = {"NO DIALTONE"};
   char  c7[] = {"BUSY"};
   char  c8[] = {"NO ANSWER"};

   char* TXTCOM[] =  {c0,c1,c2,c3,c4,c5,c6,c7,c8};

/*************************************************************************
	     Описание регистров модема
*************************************************************************/
byte  RegModem[18] = 
      {
      /*  s0   s1   s2   s3   s4   s5   s6   s7   s8   s9   */
		       0,   0, '+',  13,  10,   8,   2,  30,   2,   6,

		  /* s10  s11  s12  s13  s14  s15  s16  s17             */
		       7,  70,  50,   0,   0,   0,   0,   0
      };


extern void  (*TabRunCom  [])();
extern void  (*TabParsCom [])();
       void  PutLine();
       void  PutEcho();
       void  PutRespons();
       void  TrnData();
       void  LfCr();
       void  TrnCommand();
       void  PutRespons();
       void  ComParsAndRun();
       void  ComParser();
       void  ComRun();


#define  TRN_DATA      0
#define  TRN_COMMAND   1
#define  TRN_DATAGO    2

  byte  TRN_STATE = TRN_COMMAND;

  long   CurrTime  = 0;           /* Время последнего байта */
  long   PrevTime;
  int    DiffTime;

  byte  StateData = Data;
  byte  StateComm = WaitA;
  byte  NumEsc    = 0;

  byte  cp;
  byte  ComStr[41];
  byte  ErrFlg;

/*///////////////////////////////////////////////////////
       Процедура  обработки запросов на передачу
///////////////////////////////////////////////////////*/
void i14_Transmit(byte ch)
{
      PrevTime = CurrTime;
      CurrTime = clock();
      DiffTime = (int)(CurrTime-PrevTime);
      switch (TRN_STATE)   
      {
      case  TRN_DATA:                       /* режим "данные" */
            TrnData(ch);
            break;
      case  TRN_COMMAND:                    /* командный режим */
            TrnCommand(ch);
             break;
      }
      if (TRN_STATE == TRN_DATAGO)          /* переход в режим данных */
        {
        PutLine(ch);
        for (; NumEsc>0; PutLine(RegModem[2]),NumEsc--); /* вывести данные */
        TRN_STATE = TRN_DATA;
        }
}


/*/////////////////////////////////////////////////////////////////////////
       ПЕРЕДАЧА  ДАННЫХ
/////////////////////////////////////////////////////////////////////////*/
#define  Data      0         /* данные */
#define  Esc       1         /* введен 1-ый символ возврата в ком реж */

void  TrnData(byte ch)
{
     switch (StateData)          
     {
     case  DATA:
           if(ch==RegModem[2] && DiffTime>(int)(RegModem[12]))
             {
             StateData = ESC;   
             NumEsc    = 1;
             }
           else
             PutLine(ch);     
           break;
     case  ESC:        
           if(ch != RegModem[2])     
             TRN_STATE = TRN_DATAGO; 
           else
             {
             NumEsc++;
             if(NumEsc == 3)
               {
               TRN_STATE = TRN_COMMAND;   
               StateComm = WaitA;  
               }
             }
             break;    
     }
}

/*/////////////////////////////////////////////////////////////////////////
             КОМАНДНЫЙ РЕЖИМ
/////////////////////////////////////////////////////////////////////////*/
#define  WaitA   0
#define  WaitT   1
#define  WaitCr  2

void  TrnCommand(byte ch)
{
     PutEcho(ch);
     if(ch >= 'a' && ch <= 'z')
       ch -= 32;
     switch(StateComm)   
     {
     case  WaitA:                          /* ожидание А */
           if(DiffTime < RegModem[12])     /* пауза не выдержана */
             TRN_STATE = TRN_DATAGO;       /* состояние - продолжение передачи */
           else
           if(ch == 'A')
             StateComm = WaitT;            /* переход: ожидание Т */
           break;
     case  WaitT:                          /* ожидание Т */
           if(ch == 'T')
             {
             ComStr[0] = 1;
             StateComm = WaitCr;           /* переход: ожидание CR */
             }
           else
           if(ch == '/')
             {
             ComParsAndRun();              /* выполнить "А/" */
             StateComm = WaitA;            /* переход: ожидание А */
             }
           else
             StateComm = WaitA;            /* переход: ожидание А */
           break;
     case  WaitCr:                         /* ожидание CR */
           if(ch == RegModem[5])           /* символ - возврат на шаг */
             {
             if(ComStr[0] == 1)
               PutEcho('T');
             else
               {
               ComStr[0]--;
               PutEcho(8);  PutEcho(' ');
               }
             }
           else
             {
             ComStr[ComStr[0]++] = ch;
             if(ch == RegModem[3])         /* CR */
               {
               ComParsAndRun();            /* проверить и выполнить команду */
               StateComm = WaitA;          /* переход: ожидание А */
               }
             }
           break;
     }
}

/*/////////////////////////////////////////////////////////////////////////
             ПРОВЕРИТЬ И ВЫПОЛНИТЬ КОМАНДУ
/////////////////////////////////////////////////////////////////////////*/
void ComParsAndRun()
{
      ErrFlg = FALSE;
      ComParser();
      if(ErrFlg)
        PutRespons (ERROR);
      else
        {
        ComRun();
        if(TRN_STATE != TRN_DATA)
          PutRespons (OK);
        }
}

/*/////////////////////////////////////////////////////////////////////////
        ПРОВЕРИТЬ КОМАНДУ
/////////////////////////////////////////////////////////////////////////*/
void  ComParser()
{
   byte  com;
   void  (*proc)();

    cp = 1;
    while (ComStr[cp] != RegModem[3] && !ErrFlg)
      {
      com = ComStr[cp++];
      if(com >= 65 && com < 91)         /* код команды правилен */
        {
        proc = TabParsCom[com-65];      /* указатель вызываемой процедуры */
        if(proc != NULL)
          (*proc)();
        else
          ErrFlg = TRUE;
        }
      else
        if(com != ' ')
          ErrFlg = TRUE;
      }
}

/*/////////////////////////////////////////////////////////////////////////
                  ВЫПОЛНИТЬ КОМАНДУ
/////////////////////////////////////////////////////////////////////////*/
void  ComRun()
{
  byte  com,StrLim;
  void  (*proc)();

    cp = 1;
    StrLim = RegModem[3];
    while (ComStr[cp] != StrLim)
      {
      com = ComStr[cp++];
      if (com != ' ')
        {
        proc = TabRunCom[com-65];
        (*proc)();
        }
      }
}


/*///////////////////////////////////////////////////////
	    Вывод ответа в порт.
///////////////////////////////////////////////////////*/
void  PutRespons(byte num)
{
   byte   *txt;

   if (~ResultCodeOff)            /* выводить код возврата? (Q0) */
     {
     LfCr();
     if (RC_TYPE == DIGIT)        /* вывод в цифровой форме */
       PutByte(num+'0');
     else                         /* вывод в симв форме */
       {
       txt = TXTCOM[num];
       while (*txt != 0) PutByte(*txt++);
       }
     LfCr();
     }
}

/*///////////////////////////////////////////////////////
            ВЫВЕСТИ БАЙТ В ПОРТ
///////////////////////////////////////////////////////*/
void PutLine(byte ch)
{
   putch(ch);
}

/*///////////////////////////////////////////////////////

///////////////////////////////////////////////////////*/
void PutEcho(byte ch)
{
   if(EchoFlg != 0)
     PutByte(ch);
}

/*///////////////////////////////////////////////////////

///////////////////////////////////////////////////////*/
void LfCr()
{
     PutByte(RegModem[3]);
     PutByte(RegModem[4]);
}


/*///////////////////////////////////////////////////////

///////////////////////////////////////////////////////*/
void PutString(byte *txt)
{
     LfCr();
     while (*txt != 0) PutByte(*txt++);
     LfCr();
}




void     A_COMR  ();     void     A_COMP  ();
void     B_COMR  ();     void     B_COMP  ();
void     C_COMR  ();     void     C_COMP  ();
void     D_COMR  ();     void     D_COMP  ();
void     E_COMR  ();     void     E_COMP  ();
void     F_COMR  ();     void     F_COMP  ();
#define  G_COMR  NULL
#define  G_COMP  NULL
void     H_COMR  ();     void     H_COMP  ();
void     I_COMR  ();     void     I_COMP  ();
#define  J_COMR  NULL
#define  J_COMP  NULL
#define  K_COMR  NULL
#define  K_COMP  NULL
void     L_COMR  ();     void     L_COMP  ();
void     M_COMR  ();     void     M_COMP  ();
#define  N_COMR  NULL
#define  N_COMP  NULL
void     O_COMR  ();     void     O_COMP  ();
void     P_COMR  ();     void     P_COMP  ();
void     Q_COMR  ();     void     Q_COMP  ();
#define  R_COMR  NULL
#define  R_COMP  NULL
void     S_COMR  ();     void     S_COMP  ();
void     T_COMR  ();     void     T_COMP  ();
#define  U_COMR  NULL
#define  U_COMP  NULL
void     V_COMR  ();     void     V_COMP  ();
#define  W_COMR  NULL
#define  W_COMP  NULL
void     X_COMR  ();     void     X_COMP  ();
void     Y_COMR  ();     void     Y_COMP  ();
void     Z_COMR  ();     void     Z_COMP  ();


 void  (*TabRunCom [])() =
    { A_COMR, B_COMR, C_COMR, D_COMR, E_COMR, F_COMR, G_COMR,
      H_COMR, I_COMR, J_COMR, K_COMR, L_COMR, M_COMR, N_COMR,
      O_COMR, P_COMR, Q_COMR, R_COMR, S_COMR, T_COMR, U_COMR,
      V_COMR, W_COMR, X_COMR, Y_COMR, Z_COMR
    };

 void  (*TabParsCom [])() =
    { A_COMP, B_COMP, C_COMP, D_COMP, E_COMP, F_COMP, G_COMP,
      H_COMP, I_COMP, J_COMP, K_COMP, L_COMP, M_COMP, N_COMP,
      O_COMP, P_COMP, Q_COMP, R_COMP, S_COMP, T_COMP, U_COMP,
      V_COMP, W_COMP, X_COMP, Y_COMP, Z_COMP
    };
/*///////////////////////////////////////////////////////
 ПРОВЕРКА МАКСИМАЛЬНОЙ ЗНАЧНОСТИ ПАРАМЕТРА
/////////////////////////////////////////////////////////*/
void TstDig(byte num)
{
  byte ch;

   ch = ComStr[cp];
   if(ch >= '0' &&  ch <= num)
     cp++;
}

/*--------------------------------------------------------------------
	  Переход в состояние ON-LINE в режиме ответа
	 ( посылка ответных тональных сигналов и запуск
	   квитирования в ответном режиме )
--------------------------------------------------------------------*/
void  A_COMR()
{
}

void  A_COMP()
{
}

/*--------------------------------------------------------------------
	     Установить тип протокола
	     B0 - CCITT  V.21/V.22
	     B1 - BELL   103/212A
--------------------------------------------------------------------*/
void  B_COMR()
{
      switch (ComStr[cp])   
      {
      case  '1':
            cp++;
            PRT_TYPE = BELL103_212A;
            break;
      case  '0':
            cp++;
      default:
            PRT_TYPE = V21_22;  
      }
}

/*////////////////////////////////////////////////////////

////////////////////////////////////////////////////////*/
void  B_COMP()
{
      TstDig('1');
}

/*--------------------------------------------------------------------
   Блокировка/разблокировка контоля передачи несущей
	 C0 - блокировка несущей
	 C1 - разблокировка несущей
--------------------------------------------------------------------*/
void  C_COMR()
{
      switch (ComStr[cp])  
      {
      case  '1':
            cp++;
            break;
      case  '0':
            cp++;
      default:

      }
}

void  C_COMP()
{
      TstDig('1');
}

/*///////////////////////////////////////////////////////////////
              АВТОНАБОР
///////////////////////////////////////////////////////////////*/
byte AutoCall()
{
  return CONNECT;
}

/*--------------------------------------------------------------------
              ФОРМИРОВАНИЕ СТРОКИ ДЛЯ АВТОВЫЗОВА
--------------------------------------------------------------------*/
byte  TlfPars()
{
  byte  ch;

   ch = ComStr[cp];
   if(ch=='P' || ch=='T')
     {
     cp++;
     ch = ComStr[cp];
     }
   while(ch=='/' || ch==',' || ch=='W' || ch=='@' || ch=='!' ||
   ch=='(' || ch==')' || ch=='-' || (ch>='0' && ch<='9'))
     {
     cp++;
     ch = ComStr[cp];
     }
   if(ch==';' || ch=='R')
     cp++;
   return ch;
}
/*////////////////////////////////////////////////////////
       АВТОМАТИЧЕСКИЙ НАБОР НОМЕРА  ( D )
//////////////////////////////////////////////////////////*/
void  D_COMR()
{
  byte rez,ch;

   rez = AutoCall();
   PutRespons(rez);
   ch  = TlfPars();              /* определить признак перехода в командный режим ";" */
   if(ch!=';' && rez==CONNECT)
     TRN_STATE = TRN_DATA;       /* переход в состояние "данные"*/
}

void  D_COMP()
{
   TlfPars();
}


/*--------------------------------------------------------------------
 РАЗРЕШЕНИЕ/ЗАПРЕТ ВЫДАЧИ ЭХО
--------------------------------------------------------------------*/
void  E_COMR()
{
   switch (ComStr[cp])
   {
   case  '1':
         cp++;
         EchoFlg = TRUE;
         break;
   case  '0':
         cp++;
   default:
         EchoFlg = FALSE; 
   }
}

void  E_COMP()
{
   TstDig('1');
}

/*--------------------------------------------------------------------
          УСТАНОВКА РЕЖИМА ( F1 -  full-duplex; F0 - half-duplex )
--------------------------------------------------------------------*/
void  F_COMR()
{
   switch (ComStr[cp])        
   {
   case  '1':
         cp++;
         RT_FLG   = FULL_DUPLEX;
         break;
   case  '0':
         cp++;
   default:
        RT_FLG   = HALF_DUPLEX; 
   }
}

void  F_COMP()
{
   TstDig('1');
}

/*--------------------------------------------------------------------
        УПРАВЛЕНИЕ СОЕДИНЕНИЕМ ЛИНИИ СВЯЗИ МОДЕМА В КОМАНДНОМ РЕЖИМЕ
        N = 0 - отключение линии связи
          = 1 - подключение к линии связи, но без запуска квитиования
--------------------------------------------------------------------*/
void  H_COMR()
{
   switch (ComStr[cp])  
   {
   case  '1':
         cp++;
         break;
   case  '2':
         cp++;
         break;
   case  '0':
         cp++;
   default:
             ;      
   }
}

void  H_COMP()
{
   TstDig('2');
}

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
void  I_COMR()
{
   switch (ComStr[cp])    
   {
   case '1':
        cp++;
        break;
   case '0':
        cp++;
   default :
        PutString ("214");   
   }
}

void  I_COMP()
{
   TstDig('2');
}

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
void  L_COMR()
{
   switch (ComStr[cp])   
   {
   case  '1':
         cp++;
         break;
   case  '2':
         cp++;
         break;
   case  '3':
         cp++;
         break;
   case  '0':
         cp++;
   default:
             ;
   }
}

void  L_COMP()
{
   TstDig('3');
}

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
void  M_COMR()
{
   switch (ComStr[cp])   
   {
   case  '1':
         cp++;
         break;
   case  '0':
         cp++;
   default:
         ;
   }
}

void  M_COMP()
{
   TstDig('1');
}

/*--------------------------------------------------------------------
             ВОЗВРАТ К СОСТОЯНИЮ ON-LINE
   при отсутствии соединения линии связи с дистанц модемом последо-
   вательность квитиования связи запускается в исходном ежиме;
   если соединение установлено, может запускаться ежим пеедачи
--------------------------------------------------------------------*/
void  O_COMR()
{
   TRN_STATE = TRN_DATA;
}

void  O_COMP()
{
}

/*--------------------------------------------------------------------
            ИМПУЛЬСНЫЙ НАБОР
--------------------------------------------------------------------*/
void  P_COMR()
{
   CALL_TYPE = PULSE_CALL;
}

void  P_COMP()
{
}

/*--------------------------------------------------------------------
          ПОСЫЛКА КОДОВ ВОЗВРА ( 0 - посылать;  1 - не посылать )
--------------------------------------------------------------------*/
void  Q_COMR()
{
   switch (ComStr[cp])  
   {
   case  '1':
         cp++;
         RC_FLG = FALSE;
         break;
   case  '0':
         cp++;
   default:
         RC_FLG = TRUE;   
   }
}

void  Q_COMP()
{
    TstDig('1');
}

/*--------------------------------------------------------------------

--------------------------------------------------------------------*/
/*///////////////////////////////////////////////////////
         ПРЕОБРАЗОВАНИЕ ASCII в десятичное
///////////////////////////////////////////////////////*/
byte  InpNum()
{
  byte  num;

  num = 0;
  while (ComStr[cp] >= '0' && ComStr[cp] <= '9')
    num = num*10+(ComStr[cp++]-'0');
  return  num;
}

/*///////////////////////////////////////////////////////
         ПРЕОБРАЗОВАНИЕ ДЕСЯТИЧНОГО В ASCII
///////////////////////////////////////////////////////*/
void OutNum(byte num)
{
  LfCr();
  PutByte(num/100+'0');
  num = num % 100;
  PutByte(num/10+'0');
  PutByte(num%10+'0');
  LfCr();
}
/*-------------------------------------------------------
        ПРОСМОТР И КОРРЕКЦИЯ СОДЕРЖИМОГО РЕГИСТРОВ
---------------------------------------------------------*/

void  S_COMR()
{
  byte num_reg,val_reg;

    num_reg = InpNum();
    switch(ComStr[cp++])          
    {
    case  '?':                         /* просмотр содержимого регистра */
       OutNum(RegModem[num_reg]);
       break;
    case  '=':                        /* просмотр ранее введенного регистра */
       val_reg = InpNum();
       RegModem[num_reg] = val_reg; }
}

void  S_COMP()
{
  byte num_reg;

    num_reg = InpNum();
    if (num_reg > 17)
      ErrFlg = TRUE;
    else
      switch(ComStr[cp++])   
      {
      case  '?':
            break;
      case  '=':
            InpNum();
            break;
      default:
            ErrFlg = TRUE;   
      }
}


/*--------------------------------------------------------------------
             ТОНАЛЬНЫЙ СИГНАЛ
--------------------------------------------------------------------*/
void  T_COMR()
{
   CALL_TYPE = TOUCHE_CALL;
}

void  T_COMP()
{
}

/*--------------------------------------------------------------------
УСТАНОВКА ВИДА КОДА ВОЗВРАТА ( 1 -символьный 0 - цифовой )
--------------------------------------------------------------------*/
void  V_COMR()
{
   switch (ComStr[cp])   
   {
   case  '1':
         cp++;
         RC_TYPE = WORD;
         break;
   case  '0':
         cp++;
   default:
         RC_TYPE = DIGIT;    
   }
}

void  V_COMP()
{
   TstDig('1');
}

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
void  X_COMR()
{
   switch (ComStr[cp])   
   {
   case  '1':
         cp++;
         break;
   case  '2':
         cp++;
         break;
   case  '3':
         cp++;
         break;
   case  '4':
         cp++;
         break;
   case  '0':
         cp++;
   default:
             ;
   }
}

void  X_COMP()
{
   TstDig('4');
}

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
void  Y_COMR()
{
   switch (ComStr[cp])   
   {
   case  '1':
         cp++;
         break;
   case  '0':
         cp++;
   default:
             ;
   }
}

void  Y_COMP()
{
   TstDig('1');
}

/*--------------------------------------------------------------------
--------------------------------------------------------------------*/
void  Z_COMR()
{
}

void  Z_COMP()
{
}