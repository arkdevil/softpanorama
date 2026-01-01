/*
**   -- MODEM_IO.C --
**
**  Define USE_WIN_IO to 1 if using the WIN_IO window tile
**  routines, else set USE_WIN_IO to 0.
*/

#define USE_WIN_IO 0

/**********************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "pcl4c.h"
#include "modem_io.h"

#if USE_WIN_IO
#include "win_io.h"
#endif

#define FALSE 0
#define TRUE !FALSE
#define ONE_SECOND 18
#define CR 0x0d

/*** globals ***/

static int  Debug = 0;
static int  LastPort;         /* last port referenced */
static char MatchString[80];  /* ModemWaitFor() match string */
static int  MatchLength= 0;   /* string length */
static int  MatchCount = 0;   /* # sub-strings */
static struct
  {char *Start;               /* ptr to 1st char of string */
   char *Ptr;                 /* working ptr */
  } MatchList[10];

/*** PRIVATE functions ***/

static int BreakTest(void)
{/* User BREAK ? */
 if(SioBrkKey()||SioKeyPress())
    {
#if USE_WIN_IO
     WinPutString(SCR_WIN,"User BREAK\n");
#else
     printf("User BREAK\n");
#endif
     return(TRUE);
    }
 return(FALSE);
}

void MatchInit(char *S)
{int  i;
 char C;
 char *Ptr;
 MatchCount = 0;
 strncpy(MatchString,S,80);
 MatchLength = strlen(MatchString);
 Ptr = MatchString;
 MatchList[MatchCount].Start = Ptr;
 MatchList[MatchCount++].Ptr = Ptr;
 while(*Ptr)
   {if(*Ptr=='|')
      {/* mark start of next string */
       MatchList[MatchCount].Start = Ptr + 1;
       MatchList[MatchCount++].Ptr = Ptr + 1;
      }
    Ptr++;
   }
}

void MatchUpper(void)
{int i;
 char *Ptr;
 Ptr = MatchString;
 for(i=0;i<MatchLength;i++)
   {*Ptr = toupper(*Ptr);
    Ptr++;
   }
}

int MatchChar(char C)
{int  i;
 char *Ptr;
 char *Start;
 /* consider each string in turn */
 for(i=0;i<MatchCount;i++)
   {Ptr = MatchList[i].Ptr;
    Start = MatchList[i].Start;
    if(*Ptr==C)
      {/* char C matches */
       Ptr++;
       if((*Ptr=='|')||(*Ptr=='\0'))
         {MatchList[i].Ptr = Start;
          return i;
         }
       else MatchList[i].Ptr = Ptr;
      }
    else
      {/* char C does NOT match */
       MatchList[i].Ptr = Start;
       /* look again if was not 1st char  */
       if(Ptr!=Start) i--;
      }
   }
 return -1;
}

/*** PUBLIC functions ***/

/* echos incoming to screen */

void ModemEcho(int Port,int Echo)
{int rc;
 long Time;
 Time = SioTimer();
 while(SioTimer() < Time+(long)Echo)
   {
#if USE_WIN_IO
    rc = CharGet(Port,1);
    if(rc>=0) WinPutChar(SCR_WIN,(char)rc);
#else
    rc = SioGetc(Port,1);
    if(rc>=0) printf("%c",(char)rc);
#endif
   }
}

/* send string to modem & get echo */

int ModemSendTo(
  int  Port,       /* port to talk to */
  int  Pace,       /* inter-char delay */
  char *String)    /* string to send to modem */
{int i, rc;
 char c;
 int Code;
 long Time;
 char Temp[80];
 if(Debug)
   {sprintf(Temp," [Sending '%s'] ",String);
#if USE_WIN_IO
    WinPutString(SCR_WIN,Temp);
#else
    printf("%s\n",Temp);
#endif
   }
 for(i=0;i<strlen(String);)
    {/* User BREAK ? */
     if(BreakTest()) return(FALSE);
     /* delay <Pace> tics */
     if(Pace>0) SioDelay(Pace);
     /* fetch character */
     c = String[i++];
     switch(c)
        {case '^':
            /* next char is control char */
            c = String[i++] - '@';
            break;
         case '!':
            /* replace ! with carriage return */
            c = CR;
            break;
         case '~':
            /* delay 1/2 second */
            SioDelay(ONE_SECOND/2);
            c = ' ';
            break;
         case ' ':
            /* delay 1/4 second */
            SioDelay(ONE_SECOND/4);
            c = ' ';
            break;
        } /* end switch */
     /* transmit as 7 bit ASCII character */
#if USE_WIN_IO
     CharPut(Port,(char)(0x7f & c));
#else
     SioPutc(Port,(char)(0x7f & c));
#endif
    }
 return(TRUE);
} /* end SendTo */

/* wait for 'String' */

/* NOTES:
**  (1)  Will return NULL if no match, else '0' if 1st, '2' if 2nd, etc.
**       where String = "<1st substr>|<2nd substr>| ..."
**  (2)  Example call: ModemWaitFor(COM1,180,FALSE,"more ?|Menu:");
*/

char ModemWaitFor(
  int  Port,       /* Port to talk to */
  int  Tics,       /* wait in tics for string */
  int  CaseFlag,   /* TRUE = case sensitive compares */
  char *String)    /* string to wait for */
{int i, k;
 int rc;
 char C;
 int Code;
 long Time;
 char Temp[80];
 /* wait for string */
 Time = SioTimer();
 MatchInit(String);
 if(!CaseFlag) MatchUpper();
 if(Debug)
   {sprintf(Temp," [Awaiting '%s'] ",String);
#if USE_WIN_IO
    WinPutString(SCR_WIN,Temp);
#else
    printf("%s\n",Temp);
#endif
   }
 while(SioTimer()<(Time+(long)Tics))
   {/* User BREAK ? */
    if(BreakTest()) return(FALSE);
    /* wait for next character */
#if USE_WIN_IO
    Code = CharGet(Port,1);
#else
    Code = SioGetc(Port,1);
#endif
    if(Code<-1) return(FALSE);
    if(Code>=0)
      {/* echo char */
#if USE_WIN_IO
       WinPutChar(SCR_WIN,(char)Code);
#else
       printf("%c",(char)Code);
#endif
       /* case sensitive ? */
       if(CaseFlag) C = (char)Code;
       else C = toupper( (char)Code );
       /* does char match ? */
       rc = MatchChar(C);
       if(rc>=0) return ('0' + rc);
      }
   } /* end for(i) */
 return 0;
}

/* enter command state */

/* NOTE: assumes escape char = '+' & guard time = 1 sec */

void ModemCmdState(int Port)
{int  i;
 char Temp[80];
 /* delay a bit over 1 second */
 SioDelay(ONE_SECOND+ONE_SECOND/4);
 /* send Escape Code exactly 3 times */
 for(i=0;i<3;i++)
    {
#if USE_WIN_IO
     CharPut(Port,'+');
#else
     SioPutc(Port,'+');
#endif
     SioDelay(ONE_SECOND/4);
    }
 /* delay again */
 SioDelay(ONE_SECOND+ONE_SECOND/4);
} /* end ModemCmdState */

/* hangup phone (in command state) */

void ModemHangup(int Port)
{/* enter command state */
 ModemCmdState(Port);
 /* hangup ! */
 ModemSendTo(Port,4,"!AT!");
 ModemEcho(Port,10);
 ModemSendTo(Port,4,"ATH0!");
} /* end Hangup */

/* wait for continuous quiet (no incoming serial data) */

int ModemQuiet(
  int  Port,       /* Port to talk to */
  int  Tics)       /* # tics quiet required */
{int i;
 int Code;
 long CharTime;
 /* set up */
 CharTime = SioTimer();
 while(1)
   {/* User BREAK ? */
    if(BreakTest())
      {
       return(FALSE);
      }
    /* wait for next character */
#if USE_WIN_IO
    Code = CharGet(Port,1);
#else
    Code = SioGetc(Port,1);
#endif
    if(Code<-1) return(FALSE);
    if(Code>=0)
      {CharTime = SioTimer();
#if USE_WIN_IO
       WinPutChar(SCR_WIN,(char)Code);
#else
       printf("%c",(char)Code);
#endif
      }
    else
      {/* ==-1, timed out */
       if(SioTimer() >= CharTime+(long)Tics) return TRUE;
      }
   } /* end while */
}

void ModemDebug(void)
{Debug = TRUE;
}
