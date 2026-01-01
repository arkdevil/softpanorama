/*╒══════════════════════════════════════════════════════════════════════════╕*/
/*│                                                                          │*/
/*│ Пристыковщик из комплекса MatchBox (Спичечный коробок)  Ver.0.0 29.04.92 │*/
/*│                                                                          │*/
/*│ Автор: Чоп Александр	тел:(095)315-10-31(раб.)     105043,Москва,  │*/
/*│ Язык : TurboC-2.0(Model:S)  Измайловский пр.,73/2,общ.5 MГТУ им.Баумана  │*/
/*│                                                                          │*/
/*│ Служит для добавления в BOX-файл EXE и COM файлов. После добавления они  │*/
/*│ могут быть катапультированы "изнутри" запущенного BOX-файла. Обращения к │*/
/*│ диску прекращаются после загрузки MatchBox-а.  Внешне выглядит наподобие │*/
/*│ запуска программы, предварительно упакованной LZEXE : хотя в  файле  все │*/
/*│ перелопачено, но в памяти после запуска - абсолютно то же, что и раньше. │*/
/*│                                                                          │*/
/*│                                                                          │*/
/*│ Цель создания MatchBox такая же как у LZEXE - экономия места на диске.   │*/
/*│ Как известно, при размере кластера 2Kb, 20 программ размером по 500 байт │*/
/*│ занимают не 10Kb, но 40Kb. С помощью MatchBox они будут занимать меньше, │*/
/*│ чем 10Kb, потому что "связку" уже можно упаковать LZEXом.                │*/
/*│                                                                          │*/
/*│ Виртуозы ассемблера! Теперь Ваши старания ужать килобайтную утилиту еще  │*/
/*│ наполовину, приведут к реальному выиграшу в "дисковом габарите".         │*/
/*│                                                                          │*/
/*│ Примечание: Ассемблерный текст собственно MatchBox-а  находится в файле  │*/
/*│   		BOX.BSP .                                                    │*/
/*│     К сожалению, из-за нехватки времени утилита для извлечения программ  │*/
/*│   из MatchBox-а пока не доделана. Не желающие ждать версию 0.1 могут     │*/
/*│   попробовать написать самостоятельно. Формат в файле MATCHBOX.DOC.      │*/
/*╘══════════════════════════════════════════════════════════════════════════╛*/

#include<string.h>
#include<io.h>
#include<dos.h>
#include<alloc.h>
#include<stdio.h>
#include<fcntl.h>
#define SIZBUF 32
#define LENNAME 8	/* длина идентификатора */
#define ELEMTABLE (LENNAME+4+2)
int tmp;

/*	*	*	*	*	копирование во временный файл */
void cop_tmp(int hnd,long seek,long length)
/*           откуда?   начало?       сколько?	*/
{
char *buf;
unsigned sizebuf;
int isread,writecount;
buf=malloc(sizebuf=coreleft());
writecount=(int)(length/sizebuf);
for(;writecount>=0;writecount--)
	{lseek(hnd,seek,SEEK_SET);
	length-=(isread=_read(hnd,buf,(unsigned)((length>sizebuf)?sizebuf:length)));
	seek+=isread;
	_write(tmp,buf,isread);
	}
free(buf);
}

/*******************************************  M A I N   *******/
main(int argc,char **argv)
{
struct exepref{unsigned ident,
			lenoff,
			lensec,
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
			overnum;}boxprf;
static struct exepref srsprf={0,0,0,0};
struct boxdata{unsigned off,
			seg;
	       int  total;
	       }bxdt;		/* заголовок BOX-файла */

unsigned intbuf,sizbuf,longcode;
int srs,box,i;
char *pnt,*pnt2,sym,newstr[10]="         ";
long startcode,longbuf,tmpstcode,startnew,newsecond;
static int com=0; /* флаг СОМ-файла */
static char label[]="CHOP",tmpname[14]="";
char buf[SIZBUF];
if (argc<3)
	{
	puts("\n* Utility for adding executed files to MatchBox * (C)opyleft 1992 Chop XBOCTWARE"
	     "Usage: BOXADDER <BoxName.EXE> <ExeName.EXE || ComName.COM>\n");
	return;
	}
if((srs=_open(argv[2],O_RDONLY))==-1)
	{puts("Impossible open :");
	puts(argv[2]);
	return;
	}
/* проверка действительно ли этот EXE-файл натуральный MatchBox */
if((box=_open(argv[1],O_RDONLY))!=-1
    && _read(box,&boxprf,sizeof(struct exepref))==sizeof(struct exepref)
    && boxprf.ident==0x5a4d)
	{
	startcode=lseek(box,(boxprf.sizpre<<4),SEEK_SET);
/* в самом начале кода должна быть ПОДПИСЬ */
	pnt=label;
	do{
		_read(box,&intbuf,1);
		}while(*pnt && (char)intbuf==*pnt++);
	if(!*pnt)
		{
		_read(box,&bxdt,sizeof(struct boxdata));
/* создание 8-символьного идентификатора для добавляемой программы   	    */
/* в качестве сырья используется имя файла, дополняется пробелами до 8 симв.*/
		pnt2=pnt=argv[2];
		while(*pnt2)
			if((sym=*(pnt2++))=='\\'|| sym==':')
				pnt=pnt2;
		for(pnt2=newstr;(sym=*pnt)!='.' && sym;*pnt2++=*pnt++);
/* проверка - не используется ли уже такое имя?	*/
		if(bxdt.total)
			{lseek(box,-ELEMTABLE*bxdt.total,SEEK_END);
			for(i=0;i<bxdt.total;i++)
				{_read(box,buf,ELEMTABLE);
				if(!strncmp(buf,newstr,LENNAME))
					{puts("TaskName already used!");
					return;
					}
				}
			}
/* выяснение типа файла подсунутого для добавления: ЕХЕ, или какой-то другой */
/* c изрядным успехом можно включить вместо COM-файла - текстовый	     */
/* но запускать его - не советую					     */
if(_read(srs,&srsprf,sizeof(struct exepref))!=sizeof(struct exepref)
						|| srsprf.ident!=0x5a4d)
	{puts("ProcessingCOM-file");
	com++;
	}
   else
	puts("Processing EXE-file");

/* создание выходного файла ( предполагаем наличие свободного места на диске)*/
/* в крайнем случае раззява-пользователь всегда может UNDELETить старый ВОХ  */

if((tmp=creattemp(tmpname,FA_ARCH))==-1)
	{puts("Impossible creat tempfile!");
	return;
	}
/* перенос старого префикса */
		cop_tmp(box,0,0x1c);
		cop_tmp(box,boxprf.startrelo,boxprf.allrelo<<2);
		boxprf.startrelo=0x1c;
/* добавление новых элементов из добавляемого файла в таблицу перемещ.симв.*/
		if(!com) /* только в случае ЕХЕ */
			{
			lseek(srs,srsprf.startrelo,SEEK_SET);
			for(i=0;i<srsprf.allrelo;i++)
				{_read(srs,&longbuf,4);
				longbuf+=*(long *)&bxdt.off;
				_write(tmp,&longbuf,4);
				}
			}
		tmpstcode=tell(tmp);
/* установка начала кода tmp-файла на границу сегмента */
		boxprf.sizpre=(unsigned)(tmpstcode>>4);
		if(tmpstcode&0xf)
			boxprf.sizpre++;
		tmpstcode=boxprf.sizpre<<4;
		lseek(tmp,tmpstcode,SEEK_SET);
/* перенос старой начинки BOX-файла */
		cop_tmp(box,startcode,bxdt.off+(bxdt.seg<<4));
/* добавление нового кода */
		if(!com)
			{
			startnew=srsprf.sizpre<<4;
			sizbuf=srsprf.lenoff
				+((srsprf.lensec-1)<<9)-(srsprf.sizpre<<4);
			}
		  else
			{
			sizbuf=(unsigned)filelength(srs);
			startnew=0;
			}
		cop_tmp(srs,startnew,sizbuf);
		longcode=sizbuf;
/* запись данных из EXE-префикса добавляемого файла */
		if(com)
			srsprf.minmem=-1;
		_write(tmp,&srsprf.minmem,2);
		if(!com) /* если СОМ: значения регистров - по умолчанию */
			{_write(tmp,&srsprf.SPoff,2);
			 _write(tmp,&srsprf.SSseg,2);
			 _write(tmp,&srsprf.CSseg,2);
			 _write(tmp,&srsprf.IPoff,2);
			 }
		newsecond=tell(tmp);
/* перенос старого хвоста */
		startnew=tell(box);
		sizbuf=(unsigned)(filelength(box)-startnew);
		if(!bxdt.total) /* после линковки пустой MatchBox иногда
				бывает дополнен нулями до границы параграфа,
				их надо при первой записи в него выбросить */
			{lseek(box,-SIZBUF,SEEK_END);
			 _read(box,buf,SIZBUF);
			 for(i=0;!buf[SIZBUF-1-i];i++);
			 sizbuf-=i;
			 }
		cop_tmp(box,startnew,sizbuf);
/* добавление новой строки в таблицу-содержание	*/
		_write(tmp,newstr,LENNAME);		/* идентификатор */
		_write(tmp,&bxdt.off,4);/* относительный Seg:Offs кода */
		intbuf=bxdt.off+longcode;
		_write(tmp,&intbuf,2);  /* Offs конца кода (Seg, что и раньше*/
/* настройка MatchBox-a на новое состояние */
		sizbuf=(unsigned)(newsecond-tmpstcode);
		bxdt.off=sizbuf & 0xf;
		bxdt.seg=sizbuf>>4;
		bxdt.total++;
		lseek(tmp,tmpstcode+sizeof(label),SEEK_SET);
		_write(tmp,&bxdt,sizeof(struct boxdata));
/* настройка префикса MatchBox-a на новое состояние */
		sizbuf=filelength(tmp);
		boxprf.lenoff=sizbuf & 0x1ff;
		boxprf.lensec=(sizbuf>>9)+1;
		if(!com)
			boxprf.allrelo+=srsprf.allrelo;
		lseek(tmp,0,SEEK_SET);
		_write(tmp,&boxprf,sizeof(struct exepref));
		close(tmp);
                close(box);
		unlink(argv[1]);
		rename(tmpname,argv[1]);
		}
	  else
		puts("Don't add to non BoxFile!");
	  }
  else
	puts("Your BoxFile non correct!");
close(box);
close(srs);
}
