#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <process.h>
#include <dos.h>
#include "tsvs.h"

void far *get_cvt(void) /* получим адресс векторной таблицы связи DOS */
{ union REGS inregs,outregs;
  struct SREGS segregs;
  inregs.h.ah=0x52;
  intdosx( &inregs,&outregs,&segregs );
  return( FP_MAKE( segregs.es,outregs.x.bx) );
}

void main(void)
{ unsigned char far *d;
  unsigned char a;
  unsigned int ver;
  int i,j,k;
  DINFO far *dinfo;
  DINFO far *din;
  DINFO far * far *di;
  char buf[80];

  printf("\n* Tsyganok Service * 1993 * Drive Defender *\n");

  ver=bdos(0x30,0,0); /* получим номер версии */

  if( ver< 3 ) /* Способ верен только для DOS 3.0+ */
  { printf("DOS младше 3.0 !\n");
    exit(-1);
  }

  d=(char far*)get_cvt();
  if( ver==3 )
  { /* Для DOS 3.0 */
    di=(DINFO far * far *)&d[23];
    a=d[27];
  }
  else
  { /* Для DOS 3.1 и выше */
    di=(DINFO far * far *)&d[22];
    a=d[33];
  }
  if( (ver&0xff)>5 ) /* не было проверки для версий старше 5.0 ! */
    printf("\nВнимание ! Для DOS %1d.%2d программа не тестировалась !\n",(ver&0xff),((ver>>8)&0xff));

  ver&=0xff;
  din=dinfo=*di; /* получим адресс массива */
  i=(int)a; /* и параметр Lastdrive из Config.sys */

  printf("Lastdrive=%d ( From A: to %c: )",i,(char)(i+'@') );

#ifdef PRINT_TABLE
  for(j=0;j<i;j++) /* Полазим по таблице... */
  { printf("\n\nУстройство %c:, Атрибуты %x\nПуть : %Fs ( %Fs )\n",
	   (char)(j+'A'),(k=dinfo->atrib),
	   dinfo->path,&dinfo->path[dinfo->offpath]);

    if( !(k&0xc000) ) /* Если 2 старших бита нулевые - такого DRIVE нет ! */
      printf("Устройство не используется !");
    else
    { if( k&0x8000 )
      { if( dinfo->drv.redirifs!=(void far *)0xffffffffl )
	  printf("Адрес таблицы REDIRIFS %Fp",dinfo->drv.redirifs );
	else
	  printf("Нет адреса таблицы REDIRIFS");
	printf(", Данные пользователя : %X\n",dinfo->red);
      }
      else
      { if( dinfo->drv.ph.cdir_clu==-1 )
	  printf("Не было обращений к устройству\n");
	else
	  printf("Первый кластер указанного каталога : %d\n",dinfo->drv.ph.cdir_clu);
      }
      if( k&0x8000 ) printf("Сетевой ");
      if( k&0x4000 ) printf("Физический ");
      if( k&0x2000 ) printf("JOIN - диск ");
      if( k&0x1000 ) printf("SUBST - диск ");
    }
    dinfo++; /* перейдем к следующему элементу таблицы */
    if( ver>3 ) /* Для DOS 4.0 и выше, корректируем ссылку на элемент */
      ((char far *)dinfo)+=7;
  }
  dinfo=din; /* Восстановим адресс начала таблицы */
#endif

  printf("\n\nСписок ТЕКУЩИХ ЛОГИЧЕСКИХ дисков :\n");
  for(j=0;j<i;j++)
  { if( (k=dinfo->atrib)&0xc000 )
    { printf("\n%c: -- ",(char)(j+'A') );
      if( k&0x2000 )
	printf("JOIN ->Path %Fs",dinfo->path);
      else if( k&0x1000 )
      { _fstrcpy(buf,dinfo->path);
	buf[dinfo->offpath]='\0';
	printf("SUBST ->%Fs [ %Fs ]",buf,&dinfo->path[dinfo->offpath]);
      }
      else if( k&0x8000 )
	printf("Сетевой");
      else if( k&0x4000 )
	printf("Физический [ %Fs ]",&dinfo->path[dinfo->offpath]);
    }
    dinfo++; /* перейдем к следующему элементу таблицы */
    if( ver>3 ) /* Для DOS 4.0 и выше, корректируем ссылку на элемент */
      ((char far *)dinfo)+=7;
  }
  printf("\n");
}

