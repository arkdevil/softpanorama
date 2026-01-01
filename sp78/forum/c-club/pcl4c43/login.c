/*
**  login.c (3/3/95)
**
**  Logs onto MarshallSoft BBS as 'GUEST GUEST'
*/


#define RTS_CTS_CONTROL 1

/************************/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <dos.h>
#include <string.h>
#include "modem_io.h"
#include "pcl4c.h"

#define FALSE 0
#define TRUE !FALSE
#define CTLZ 0x1a

/*** Global Variables ***/

int Port;                 /* COM Port */
int CharPace = 3;         /* inter-char delay in tics */
int BaudCode;             /* baud rate code ( index into BaudRate[] ) */
char *BaudRate[10] =  {"300","600","1200","2400","4800","9600",
                       "19200","38400","57600","115200"};
char *ModelText[4] =  {"Small","Compact","Medium","Large"};

/*** local prototypes ***/

int BaudMatch(char *);
int PutGet(char *,char *,int);
void ErrorCheck(int);
void MyExit(char *);

/*** main ***/

#define ONE_SEC 18

void main(int argc, char *argv[])
{char c;
 int  i, rc;
 char far *Ptr;
 int  Seg;
 int  Code;
 int  Version;
 char Temp[80];
 if(argc!=3)
   {printf("Usage: LOGIN <port> <baud>\n");
    exit(1);
   }
 /* get port number from command line */
 Port = atoi(argv[1]) - 1;
 if((Port<COM1) || (Port>COM20))
   {printf("Port must be COM1 to COM20n");
    exit(1);
   }
 /* get baud rate from command line */
 BaudCode = BaudMatch(argv[2]);
 if(BaudCode<0)
   {printf("Cannot recognize baud rate = %s\n",argv[2]);
    exit(1);
   }
 /* setup 512 byte receive buffer */
 Ptr = (char far *) _fmalloc(512+16);
 Seg = FP_SEG(Ptr) + ((FP_OFF(Ptr)+15)>>4);
 SioRxBuf(Port,Seg,Size512);
 /* set port parmameters */
 ErrorCheck( SioParms(Port,NoParity,OneStopBit,WordLength8) );
 /* reset the port */
 ErrorCheck( SioReset(Port,BaudCode) );
 /* set DTR and RTS */
 ErrorCheck( SioDTR(Port,'S') );
 ErrorCheck( SioRTS(Port,'S') );
 /* display some info */
 printf(" -- LOGIN (3/5/95) --\n");
 Version = SioInfo('V');
 sprintf(Temp,"      Library: %d.%d\n",Version>>4,0x0f&Version);
 printf(Temp);
 sprintf(Temp," Memory Model: %s\n",ModelText[3&SioInfo('M')] );
 printf(Temp);
 strcpy(Temp,"TX Interrupts: ");
 if(SioInfo('I')) strcat(Temp,"YES\n");
 else strcat(Temp,"NO\n");
 printf(Temp);
#if RTS_CTS_CONTROL
 SioFlow(Port,10*ONE_SEC);
 printf(" Flow Control: YES\n");
#else
 printf(" Flow Control: NO\n");
#endif
 /* Set FIFO level */
 printf("   16550 UART: ");
 if( SioFIFO(Port,LEVEL_14) ) printf("YES\n");
 else printf("NO\n");
 /* clear PCL4C receive buffer */
 ErrorCheck( SioRxFlush(Port) );
 printf("\n");
 /* wait for Modem to say its ready */
 printf("  <<Waiting for Modem DSR>>\n");
 while( !SioDSR(Port) )
   {if(SioKeyPress()||SioBrkKey()) MyExit("Aborted by user");
    printf(".");
    SioDelay(ONE_SEC);
   }
 printf("  <<DSR on>>\n");

#if RTS_CTS_CONTROL
 printf("  <<Waiting for Modem CTS>>\n");
 while( !SioCTS(Port) )
   {if(SioKeyPress()||SioBrkKey()) MyExit("Aborted by user");
    printf(".");
    SioDelay(ONE_SEC);
   }
 printf("  <<CTS on>>\n");
#endif
 /* initialize (Hayes compatible) modem */
 Code = PutGet("!AT!","OK",ONE_SEC);
 if(Code) Code = PutGet("AT E1 S7=60 S11=60 V1 X1 Q0!","OK",5*ONE_SEC);
 if(Code)
   {printf("  <<Modem ready. Logging on...>>\n");
    /* log onto MarshallSoft BBS as GUEST */
    Code = PutGet("!ATDT880,9748!","CONNECT",45*ONE_SEC);
    if(Code) Code = PutGet("!","graphics (y/N)?|LAST name:",30*ONE_SEC);
    if(Code=='0') Code = PutGet("!","LAST name:",10*ONE_SEC);
    if(Code) Code = PutGet("GUEST GUEST!","password:",10*ONE_SEC);
    if(Code) Code = PutGet("GUEST!",NULL,10*ONE_SEC);
   }
 else printf("\n  <<WARNING: Expected OK not received>>\n");
 /* user now has control */
 printf("Enter terminal loop ( Type ^Z to exit )\n");
 /* enter terminal loop */
 while(TRUE)
     {/* was key pressed ? */
      if(SioKeyPress())
          {i = SioKeyRead();
           if((char)i==CTLZ)
              {printf("\n*** Hanging up modem\n");
               ModemHangup(Port);
               /* restore COM port status & exit */
               SioDone(Port);
               exit(1);
              }
           else SioPutc(Port,(char)i);
          } /* end if */
      /* any incoming over serial port ? */
      i = SioGetc(Port,0);
      if(i>-1) SioCrtWrite((char)i);
     } /* end while */
} /* end main */

/*** check return code ***/

void ErrorCheck(int Code)
{/* trap PCL error codes */
 if(Code<0)
     {SioError(Code);
      SioDone(Port);
      exit(1);
     }
} /* end ErrorCheck */

/*** find baud rate index ***/

int BaudMatch(char *P)
{int i;
 /* find baud rate in table */
 for(i=0;i<10;i++) if(strcmp(BaudRate[i],P)==0) return(i);
 return(-1);
}

/*** send string & expect reply ***/

int PutGet(char *Send,char *Expect,int Tics)
{int rc;
 printf("\n*** Sending '%s' ",Send);
 if(Expect) printf(" & awaiting '%s'",Expect);
 printf("\n");
 rc = ModemSendTo(Port, CharPace, Send);
 if(Expect)
   {rc = ModemWaitFor(Port,Tics,FALSE,Expect);
    if(rc<=0) printf("\nERROR: '%s' sent but '%s' not received\n",Send,Expect);
   }
 return rc;
}

/*** common exit ***/

void MyExit(char *S)
{printf("%s\n",S);
 SioDone(Port);
 exit(0);
}
