/*╒══════════════════════════════════════════════════════════════════════════╕*/
/*│                                                                          │*/
/*│  EXEPREF     Обозреватель ЕХЕ-префиксов                         29.04.92 │*/
/*│                                                                          │*/
/*│ Автор: Чоп Александр	 тел:(095)315-10-31(раб.)     105043,Москва, │*/
/*│ Язык : TurboC-2.0(model:S)   Измайловский пр.,73/2,общ.5 MГТУ им.Баумана │*/
/*│                                                                          │*/
/*│ Аналог: INFOEXE из пакета LZEXE                                          │*/
/*│ Преимущества: Показывает и расшифровывает все поля префикса, а также     │*/
/*│               значения из TABLE RELOCATION.				     │*/                                       │*/
/*│               Язык сообщений - русский.                                  │*/                                       │*/
/*│               Удаляет пустые промежутки из префикса.                     │*/
/*│                                                                          │*/
/*╘══════════════════════════════════════════════════════════════════════════╛*/

#include<io.h>
#include<dos.h>
#include <bios.h>
#include<stdio.h>
#include<fcntl.h>
#define BUFDLSZ 0x8000
void pressfile(int srs,long sizetail,long begwrit,long begread)
{
int isread,wrtccl;
char buf[BUFDLSZ];
 wrtccl=sizetail/BUFDLSZ;
 for(;wrtccl>=0;wrtccl--)
	{lseek(srs,begread,SEEK_SET);
	isread=_read(srs,buf,(unsigned)((sizetail>BUFDLSZ)?BUFDLSZ:sizetail));
	begread+=isread;
	lseek(srs,begwrit,SEEK_SET);
	begwrit+=_write(srs,buf,isread);
	}
}

/*******************************************  M A I N   *******/
int main(int argc,char **argv)
{
struct exepref{int      ident,
			lenoff;
	       unsigned lensec,
			allrelo,
			sizpre,
			minmem,
			maxmem,
			SSseg,
			SPoff,
			CRSchk,
			IPoff,
			CSseg,
			startrelo,
			overnum;}prf;
unsigned long flen,prefilsiz;
struct{unsigned offs,seg;}relobuf;
int srs,minpar,minlen,spac,i;
if (argc<2)
	{
	printf("\n** EXEprefix ** EXEpress **\t\t\t(C)opyleft 1991 CHOP Software\n"
	     "Usage: EXEP <filename.EXE>\n");
	return;
	}
if((srs=_open(argv[1],O_RDWR))==-1)
  printf("Не могу открыть %s\n",argv[1]);
else{if(_read(srs,&prf,sizeof(struct exepref))!=sizeof(struct exepref))
	printf("Невозможно чтение EXE-префикса из файла: %s\n",argv[1]);
  else
  if(prf.ident!=0x5a4d)
	printf("Нет EXE-префикса!");
    else
	{flen=filelength(srs);
	prefilsiz=512*((long)prf.lensec-1)+prf.lenoff;
	printf("\n\t\tДанные из EXE-префикса файла %s\n\n"
		"Длина кода = %u [%xh-1] * 512 + %u [%xh] = %lu байт\n"
		"Кол. перемещ. симв. = %u [%xh]\t\tСмещение таблицы = %u [%xh]\n"
		"Размер префикса = %u [%xh] * 16 = %u байт\n"
		"Миним. необх. память  = %u [%xh] * 16 = %lu байт\n"
		"Максим. необх. память = %u [%xh] * 16 = %lu байт\n"
		"SS = %04xh\tSP = %04xh\t\tIP = %04xh\tCS =  %04xh\n"
		"Контрольная сумма = %04xh\n"
		"Номер оверлея = %u[%xh]",
		argv[1],
		prf.lensec-1,prf.lensec,prf.lenoff,prf.lenoff,prefilsiz,
		prf.allrelo,prf.allrelo,prf.startrelo,prf.startrelo,
		prf.sizpre,prf.sizpre,prf.sizpre<<4,
		prf.minmem,prf.minmem,((long)prf.minmem<<4),
		prf.maxmem,prf.maxmem,((long)prf.maxmem<<4),
		prf.SSseg,
		prf.SPoff,
		prf.CSseg,
		prf.IPoff,
		prf.CRSchk,
		prf.overnum,prf.overnum);
	if(prefilsiz<flen)
		printf("\tимеется неучтенный хвост из %lu байт\n",
					flen-prefilsiz);
        while(bioskey(1)) bioskey(0);
	if(prf.allrelo
	   && (printf("\nПоказать таблицу перемещаемых символов (Y/N)? <N>"),
	   (bioskey(0) & 0xff00)==0x1500))
		{printf("\tYes !\n");
                lseek(srs,prf.startrelo,SEEK_SET);
		for(i=7;i--;)
			printf("═════════╤");
		printf("═════════");
		for(i=0;i<prf.allrelo;i++)
			{printf(i&7?"│":"\n");
			_read(srs,&relobuf,4);
			printf("%04x:%04x",relobuf.seg,relobuf.offs);
			}
		while(i++&7)
			printf("│         ");
		printf("\n═════════");
		for(i=7;i--;)
			printf("╧═════════");
		}
	minlen=0x1c+(prf.allrelo<<2);
	minpar=minlen>>4;
	if(minlen&0xf)
		minpar++;
        while(bioskey(1)) bioskey(0);
	if(!prf.overnum &&(spac=prf.sizpre-minpar)>0
	   &&(printf("\nЖелаете сжать префикс на %u байт (Y/N)? <N>",spac<<4),
	   (bioskey(0) & 0xff00)==0x1500))
		{
		 printf("\tYes !\n");
		 if(prf.allrelo)
			 pressfile(srs,prf.allrelo<<2,0x1c,prf.startrelo);
		 pressfile(srs,flen-(prf.sizpre<<4),minpar<<4,prf.sizpre<<4);
		 chsize(srs,flen-=(spac<<4));
		 lseek(srs,2,SEEK_SET);
		 prf.sizpre=minpar;
		 prf.lensec-=spac>>5;
		 if((prf.lenoff -= (spac & 0x1f)<<4 )<0)
			{prf.lenoff+=0x200;
			prf.lensec--;
			}
		 lseek(srs,2,SEEK_SET);
		 _write(srs,&prf.lenoff,8);
		 lseek(srs,0x18,SEEK_SET);
		 prf.startrelo=0x1c;
		 _write(srs,&prf.startrelo,2);
		 }
	}
close(srs);
  }
}

