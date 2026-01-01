/*
**   minimal.c (3/3/95)
*/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <dos.h>
#include "pcl4c.h"

#define CTLZ 0x1a

void main(void)
{int i, Seg;
 char far *Ptr;
 /* setup 128 byte receive buffer */
 Ptr = (char far *) _fmalloc(128+16);
 Seg = FP_SEG(Ptr) + ((FP_OFF(Ptr)+15)>>4);
 SioRxBuf(COM1,Seg,Size128);
 /* set port parmameters & reset port */
 SioParms(COM1,NoParity,OneStopBit,WordLength8);
 SioReset(COM1,Baud9600);
 printf("\nMINIMAL: COM%d @ 9600 Baud: Type ^Z to quit\n",1+COM1);
 /* enter terminal loop */
 while(1)
   {/* was key pressed ? */
    if(SioKeyPress())
      {i = SioKeyRead();
       if((char)i==CTLZ)
         {/* restore COM port status & exit */
          SioDone(COM1);
          exit(0);
         }
       else SioPutc(COM1,(char)i);
      } /* end if */
    /* any incoming over serial port ? */
    i = SioGetc(COM1,0);
    if(i>-1) SioCrtWrite((char)i);
   } /* end while */
} /* end main */
