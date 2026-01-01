/*
**                ---  selftest.c ---
**
**  SELFTEST requires two serial ports on the same computer. The
**  program transmits a test string on one port (FirstCOM) and
**  receives on a second port (SecondCOM), where the two ports are
**  connected via a null modem adapter. The received string is tested
**  against the transmit string (they should be idenical).
**
**  Connect the two serial ports (on a single computer) together
**  using a null modem cable. Be sure to modify the configuration
**  section for non-standard PC ports or to setup your multiport
**  board. Note that many multiport boards are either Digiboard or
**  BOCA board compatible.
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
#define ESC 0x1b

/*** Global Variables ***/

int BaudCode = Baud9600;  /* Code for 9600 baud  */
char *TestString = "This is a test string";
int TestLength;
int FirstCOM;
int SecondCOM;

int ErrorCheck(int);
int AllocSeg(int);

char *Ptr[4] = {"SMALL","COMPACT","MEDIUM","LARGE"};
/*** Main ***/

#define PC 1
#define DB 2
#define BB 3

void main(int argc, char *argv[])
{int Port;
 char *P;
 int ComLimit = 0;
 char c;
 int TheSwitch = 0;
 int Version;
 int Model;
 int i, rc;
 if(argc!=4)
  {printf("Usage: selftest {pc|db|bb} 1stCom 2ndCom\n");
   exit(1);
  }
 puts("*** SELFTEST 3.0");
 Version = SioInfo('V');
 Model = SioInfo('M');
 printf("*** Lib Ver : %d.%d\n",Version/16,Version%16);
 printf("***   Model : %s \n", Ptr[Model&3] );
 printf("*** TX Intr : ");
 if(SioInfo('I')) puts("enabled.");
 else puts("not enabled.");
 P = argv[1];
 if((strcmp(P,"pc")==0)||(strcmp(P,"PC")==0)) TheSwitch = PC;
 if((strcmp(P,"db")==0)||(strcmp(P,"DB")==0)) TheSwitch = DB;
 if((strcmp(P,"bb")==0)||(strcmp(P,"BB")==0)) TheSwitch = BB;
 if(TheSwitch==0)
   {puts("Must specify 'PC', 'DB' or 'BB' as 1st argument");
    puts("EG:  SELFTEST PC 1 4");
    exit(1);
   }
 if(TheSwitch==PC) ComLimit = COM4;
 if(TheSwitch==DB) ComLimit = COM8;
 if(TheSwitch==BB) ComLimit = COM16;
 FirstCOM = atoi(argv[2]) -1;
 SecondCOM = atoi(argv[3]) -1;
 printf("FirstCOM  = COM%d\n",1+FirstCOM);
 printf("SecondCOM = COM%d\n",1+SecondCOM);
 if(FirstCOM<COM1)
   {puts("1stCom must be >= COM1");
    exit(1);
   }
 if(SecondCOM>ComLimit)
   {printf("2ndCom must be <= COM%d\n",1+ComLimit);
    exit(1);
   }
 if(FirstCOM>=SecondCOM)
   {puts("1stCom must be < 2ndCom");
    exit(1);
   }
 if(TheSwitch==DB)
   {/*** Custom Configuration: DigiBoard PC/8 ***/
    puts("[ Configuring for DigiBoard PC/8 (IRQ5) ]");
    SioPorts(8,COM1,0x140,DIGIBOARD);
    for(Port=COM1;Port<=COM8;Port++)
      {/* set DigiBoard UART addresses */
       ErrorCheck( SioUART(Port,0x100+8*Port) );
       /* set DigiBoard IRQ */
       ErrorCheck( SioIRQ(Port,IRQ5) );
      }
   }
 if(TheSwitch==BB)
   {/*** Custom Configuration: BOCA BB2016 ***/
    puts("[ Configuring for BOCA Board BB2016 (IRQ15) ]");
    SioPorts(16,COM1,0x107,BOCABOARD);
    for(Port=COM1;Port<=COM16;Port++)
      {/* set BOCA Board UART addresses */
       ErrorCheck( SioUART(Port,0x100+8*Port) );
       /* set BOCA Board IRQ */
       ErrorCheck( SioIRQ(Port,IRQ15) );
      }
   }
 if(TheSwitch==PC)
   {/*** Custom Configuration: 4 port card ***/
    puts("[ Configuring for PC ]");
    SioIRQ(COM1,IRQ4);
    SioIRQ(COM2,IRQ3);
    SioIRQ(COM3,IRQ4);
    SioIRQ(COM4,IRQ3);
   }
 /* setup transmit & receive buffer */
 ErrorCheck( SioRxBuf(FirstCOM,AllocSeg(128),Size128) );
 ErrorCheck( SioRxBuf(SecondCOM,AllocSeg(128),Size128) );
 if(SioInfo('I'))
   {ErrorCheck( SioTxBuf(FirstCOM,AllocSeg(128),Size128) );
    ErrorCheck( SioTxBuf(SecondCOM,AllocSeg(128),Size128) );
    printf("Transmit buffers created\n");
   }
 /* set port parmameters */
 ErrorCheck( SioParms(FirstCOM,NoParity,OneStopBit,WordLength8) );
 ErrorCheck( SioParms(SecondCOM,NoParity,OneStopBit,WordLength8) );
 /* use 16650 FIFO if present */
 printf("***   COM%d : ",1+FirstCOM);
 if( SioFIFO(FirstCOM,LEVEL_8) ) printf("16550\n");
 else printf("8250/16450\n");
 printf("***   COM%d : ",1+SecondCOM);
 if( SioFIFO(SecondCOM,LEVEL_8) ) printf("16550\n");
 else printf("8250/16450\n");
 /* reset the ports */
 ErrorCheck( SioReset(FirstCOM,BaudCode) );
 ErrorCheck( SioReset(SecondCOM,BaudCode) );

 printf("Start selftest @ 9600 baud\n");

 TestLength = strlen(TestString);
 /* send string */
 printf("  Sending: ");
 for(i=0;i<TestLength;i++)
   {c = TestString[i];
    SioPutc(FirstCOM,c);
    SioCrtWrite(c);
   }
 /* receive string */
 printf("\nReceiving: ");
 for(i=0;i<TestLength;i++)
   {rc = SioGetc(SecondCOM,18);
    if(rc<0)
      {printf("\nERROR: ");
       SioError(rc);
       SioDone(FirstCOM);
       SioDone(SecondCOM);
       exit(1);
      }
    /* echo just received char */
    SioCrtWrite((char)rc);
    /* compare character */
    if((char)rc!=TestString[i])
      {printf("\nERROR: Expecting '%c', received '%c'\n");
       SioDone(FirstCOM);
       SioDone(SecondCOM);
       exit(2);
      }
   } /* end for */
 puts("\nSUCCESS: Test AOK !");
 SioDone(FirstCOM);
 SioDone(SecondCOM);
} /* end main */

int ErrorCheck(int Code)
{/* trap PCL error codes */
 if(Code<0)
     {SioError(Code);
      SioDone(FirstCOM);
      SioDone(SecondCOM);
      exit(1);
     }
 return(0);
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
}