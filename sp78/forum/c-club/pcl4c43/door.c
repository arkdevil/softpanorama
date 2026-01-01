/*
**   DOOR.C  (3/3/95)
**
**   EXAMPLE CODE: Gain control w/o resetting UART.
**
**   (1) Start your communications program such as PROCOMM
**   (2) Select "DOS gateway" to get the DOS prompt.
**   (3) Start this program. You will gain control of the
**       COM port without resetting the UART or dropping the
**       modem carrier.
**   (4) When done, exit this program, then type EXIT to
**       return to MSDOS.
**
**   For more information, see documentation.
**
**   This example program (not the PCL4C library) is donated to
**   the Public Domain by MarshallSoft Computing, Inc. It is
**   provided as an example of the use of the PCL4C.
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <dos.h>
#include <string.h>
#include "pcl4c.h"

#define FALSE 0
#define TRUE !FALSE
#define CTLZ    0x1a
#define BUFSIZE 64

/*** Global Variables ***/

int Port;

/*** locol prototypes ***/

void ErrorCheck(int);
int AllocSeg(int);

/*** Main ***/

void main(int argc,char *argv[])
{char c;
 char *ptr;
 int i, rc;
 /* get comm port */
 if(argc!=2)
   {printf("Usage: 'DOOR <port>' \n");
    exit(1);
   }
 /* get port number from command line */
 Port = atoi(argv[1]) - 1;
 if((Port<COM1) || (Port>COM20))
     {printf("Port must be COM1 to COM20n");
      exit(1);
     }
 printf("DOOR: COM%d\n",1+Port);
 /* setup receive buffer */
 ErrorCheck( SioRxBuf(Port,AllocSeg(64),Size64) );
 /* take over the port */
 ErrorCheck( SioReset(Port,NORESET) );
 /* DTR & RTS will be the same as before calling SioReset */
 printf("Enter terminal loop ( COM%d )\n",1+Port);
 printf("Type ^Z to quit !\n");
 /* enter terminal loop */
 while(TRUE)
     {/* was key pressed ? */
      if(SioKeyPress())
          {i = SioKeyRead();
           if((char)i==CTLZ)
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

void ErrorCheck(int Code)
{/* trap PCL error codes */
 if(Code<0)
     {SioError(Code);
      exit(1);
     }
} /* end ErrorCheck */

int AllocSeg(int Size)
{int Seg;
 char far *Ptr;
 /* allocate far heap */
 Ptr = (char far *) _fmalloc(Size+16);
 if(Ptr==NULL) return 0;
 /* SEG:0 points to buffer */
 Seg = FP_SEG(Ptr) + ((FP_OFF(Ptr)+15)>>4);
 return Seg;
}
