#include <stdio.h>
#include <memory.h>
#include <process.h>
#include <dos.h>
#include "tsvs.h"

/* Обратимся к DOS - овскому менеджеру HMA для получения информации о HMA */
void get_hma(HMA far *hma)
{ union REGS inregs,outregs;
  struct SREGS segregs;

  inregs.x.ax=0x4A01;
  int86x( 0x2f,&inregs,&outregs,&segregs );
  hma->size=outregs.x.bx;
  hma->a.w.high=outregs.x.di;
  hma->a.w.low=segregs.es;
}

/* Обратимся к DOS - овскому менеджеру HMA для резервирования памяти
 !!! После этого уже нельзя использовать эту область памяти
 !!! другими программами !
 !!! Только для резедентных режимов !!!
*/
void alloc_hma(HMA far *hma)
{ union REGS inregs,outregs;
  struct SREGS segregs;

  inregs.x.ax=0x4A02;
  inregs.x.bx=hma->size;
  int86x( 0x2f,&inregs,&outregs,&segregs );
  hma->a.w.high=outregs.x.di;
  hma->a.w.low=segregs.es;

}

void main(void)
{ HMA hma;
  unsigned int ver;

  printf("\n* Tsyganok Service * 1993 * HMA TEST *\n");
  ver=bdos(0x30,0,0)&0xff; /* получим номер версии */
  if( ver<5 )
  { printf("Нужна DOS 5.0 или выше !\n");
    exit(-1);
  }

  get_hma(&hma);
  if( hma.size==0 )
    printf("DOS не использует HMA !");
  else
    printf("Свободно %u байт HMA, начиная с адреса %Fp",hma.size,hma.a.first);

}
