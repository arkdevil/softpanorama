#include <stdio.h>
#include <memory.h>
#include <process.h>
#include <dos.h>
#include "tsvs.h"

void main(void)
{ unsigned int ver;
  union REGS inregs,outregs;
  struct SREGS segregs;
  char far *asstab;
  int i,k;

  printf("\n* Tsyganok Service * 1993 * ASSIGN TEST *\n");
  ver=bdos(0x30,0,0)&0xff; /* получим номер версии */
  if( ver<3 )
  { printf("Нужна DOS 3.0 или выше !\n");
    exit(-1);
  }

  inregs.x.ax=0x0600;
  int86x( 0x2f,&inregs,&outregs,&segregs );
  if( outregs.h.al!=0xff )
  { printf("ASSIGN not installed !\n");
    exit(0);
  }
  inregs.x.ax=0x0601;
  int86x( 0x2f,&inregs,&outregs,&segregs );
  asstab=FP_MAKE(segregs.es,0x103);
  k=0;
  for(i=0;i<26;i++)
    if( asstab[i]!=(char)(i+1) )
    { printf("%c: назначено на %c:\n",(char)(i+'A'),(char)('A'+asstab[i]) );
      k=1;
    }
  if( !k )
    printf("Нет переназначенных устройств !\n");
}
