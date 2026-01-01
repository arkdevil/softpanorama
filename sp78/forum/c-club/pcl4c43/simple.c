/*
**  simple.c (4/2/95)
*/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <dos.h>
#include <string.h>
#include "pcl4c.h"

#define FALSE 0
#define TRUE !FALSE

/*** Global Variables ***/

int Port = COM1;          /* Port COM1 */
int BaudCode;             /* baud rate code ( index into BaudRate[] ) */
char *BaudRate[10] =  {"300","600","1200","2400","4800","9600",
                       "19200","38400","57600","115200"};

/*** local prototypes */

int BaudMatch(char *);
int ErrorCheck(int);

/*** main ***/

void main(int argc, char *argv[])
{char c;
 int  i, rc;
 char far *Ptr;
 int  Seg;
 if(argc!=3)
   {printf("Usage: SIMPLE <port> <baud>\n");
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
 /* setup 128 byte receive buffer */
 Ptr = (char far *) _fmalloc(128+16);
 Seg = FP_SEG(Ptr) + ((FP_OFF(Ptr)+15)>>4);
 SioRxBuf(Port,Seg,Size128);
 /* set port parmameters */
 ErrorCheck( SioParms(Port,NoParity,OneStopBit,WordLength8) );
 /* reset the port */
 ErrorCheck( SioReset(Port,BaudCode) );
 /* set DTR and RTS */
 ErrorCheck( SioDTR(Port,'S') );
 ErrorCheck( SioRTS(Port,'S') );
 printf("Enter terminal loop ( Type ^Z to exit )\n");
 /* enter terminal loop */
 while(TRUE)
     {/* was key pressed ? */
      if(SioKeyPress())
          {i = SioKeyRead();
           if((char)i==0x1a)
              {/* restore COM port status & exit */
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

int ErrorCheck(int Code)
{/* trap PCL error codes */
 if(Code<0)
     {SioError(Code);
      SioDone(Port);
      exit(1);
     }
 return(0);
} /* end ErrorCheck */


int BaudMatch(char *P)
{int i;
 /* find baud rate in table */
 for(i=0;i<10;i++) if(strcmp(BaudRate[i],P)==0) return(i);
 return(-1);
}
