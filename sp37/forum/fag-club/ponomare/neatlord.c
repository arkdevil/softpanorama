#include <fcntl.h>
#include <dos.h>
#include <io.h>
#include <conio.h>
#include "neatfag.def"
struct f_dta b_dta;

const char* copyr1="\n╔═════════════════════════════════════════════════════╗";
const char* copyr2="\n║                      Фаг NeatLord                   ║";
const char* copyr3="\n╟─────────────────────────────────────────────────────╢";
const char* copyr4="\n║ Для лечения от вируса  RCE-921(DarkLord)            ║";
const char* copyr5="\n║ (C) Пономаренко В.В. & гр. NeatAvia 19.08.91 г. Киев║";
const char* copyr6="\n╚═════════════════════════════════════════════════════╝\n";

const char* recl1="\n  NeatLord [диск] [/F] [/G]  ";
const char* recl2="\n              │     │    └─── Проверка всех файлов(иначе только COM,EXE)";
const char* recl3="\n              │     └──────── Лечить зараженные файлы";
const char* recl4="\n              └────────────── Проверяемый диск \n";

const char* vir_msg=" has virus RCE-921(Dark Lord)\n";

const byte msk1[]={ 0x01,0x00,0xEA,0x58,0x01,0x0B,0x06,0x01,0xC8,0x8C,0x50 };

const byte msk2[]={ 0x9D,0x06,0x8E,0x2E,0x58,0x1F,0x0E,0x3E,0x75,0xE8,0x3B,
		    0x21,0xCD,0xEC,0x59,0xB8,0x50,0x04,0x9D,0x1E,0x8C,0x2E };


const	char sucss[]="  File %s desinfected \n";

const	byte jmp_short=0xEB;

/*struct	f_dta s_dta[16];*/
byte dta_cnt=0;  /* Счетчик уровня DTA */


char	*name;
char	attr;
int	file1;		/* Описатель файла */
char	buf1[0x40];	/* Первый буфер для файла */
char	buf2[40];	/* Второй буфер для файла */
char	cur_dir[200];	/* Текущий директорий */
int	cur_disk;	/* Текущий диск       */
char	work_dir[200];	/* Рабочий директорий */
int	work_disk;	/* Рабочий диск       */
int	g;		/* Наличие ключа /G   */
int	f;		/* Наличие ключа /F   */
struct	ftime time;	/* Дата и время модификации файла */
unsigned cur_pos;	/* Текущая позиция в файле */
word	total_f=0;	/* Число проверенных файлов */
word	ill_f=0;	/* Число зараженных файлов */
word	docte_f=0;	/* Число вылеченных  файлов */
word	*tt;
struct exe_header ex_h; /* Буфер для EXE-заголовка */

main (int paramcount, char **paramstr,char **envstr)
     {
     int i,c1;
     print_head();
/**********************************/
/**** Анализ строки параметров ****/
g=0; f=0; work_disk=-1;
if (paramcount>1)
	{
	for(i=1; i<paramcount; i++)
	  {
	  switch (paramstr[i][0])
	    {
	   case '-':
	   case '/':
	       switch(toupper(paramstr[i][1]))
		   {
		case 'G': g=1; break;
		case 'F': f=1; break;
		   }
	       break;
	   default:  work_disk=toupper(paramstr[i][0])-0x41;
	    }
	  }
	}
     else
	{
	reclama();
	}
if (work_disk==-1) reclama();



	/**********************/
	/* Основная обработка */
	/**********************/
init_dir(work_disk,&cur_disk,cur_dir);  /* Настройка на диск */
while(get_file(&b_dta)==0)
	{
	if((g==1)||(detect_ext(b_dta)==1))
		{
		out_f_name(2,b_dta);
		del_atr(b_dta);
		total_f++;
		switch(f_exe(b_dta.name,&time))
		   {
		case 0:
			if((find_com(b_dta.name,&cur_pos)==1)&&(f==1))
				{
				clr_com(b_dta.name,cur_pos,&time);
				}
			break;
		case 1:
			if((find_exe(b_dta.name,&cur_pos)==1)&&(f==1))
				{
				clr_exe(b_dta.name,cur_pos,&time);
				}
			break;
		   }
		ret_atr(b_dta);
		}
	}
old_dir(cur_disk,cur_dir);	/* Возврат к старому каталогу */
report(total_f,ill_f,docte_f);
}

/*****************************/
/* Поиск вируса в файле .COM */
/*****************************/
find_com(char *name,dword *cur_pos)
{
int	i,j;
int	file1;
char	buf1[512];
word	*tt,c1;
dword	cur;
file1=_open(name,O_RDWR);
if (file1!=-1)
	{
	if (_read(file1,&buf1,512)!=512)  ; /* error */
	for(i=0,j=10; i!=10; i++, j--)
		{
		if (buf1[i]!=msk1[j])  goto l1;
		}
	tt=&buf1[11]; c1=*tt; c1*=16; cur=c1; *cur_pos=cur;
	lseek(file1,cur,SEEK_SET);
	if (_read(file1,&buf1,512)!=512) ; /* error */

	if (buf1[0]!=jmp_short) goto l1;
	if (buf1[1]!=0x35) goto l1;

	lseek(file1,cur+0x37,SEEK_SET);
	if (_read(file1,&buf1,512)!=512) ; /* error */
	for(i=0,j=21; i!=22; i++, j--)
		if(buf1[i]!=msk2[j]) goto l1;
	_close(file1);
	printf(vir_msg);
	ill_f++;
	return(1);

l1:	_close(file1);
	return(0);
	}
}
/**********************/
/* Лечение файла .COM */
/**********************/
clr_com(char *name, dword curpos, struct ftime *time)
{
int	i,j;
int	file1;
char	buf1[512];
word	*tt,c1;
file1=_open(name,O_RDWR);
if (file1!=-1)
	{
	lseek(file1,cur_pos+2,SEEK_SET);
	if (_read(file1,&buf1,512)!=512) ; /* error */
	lseek(file1,0,SEEK_SET);
		/* вписываю правильное начало файла */
	if (_write(file1,&buf1,13)!=13) ; /* error */
		/* укорачиваю длину файла */
	chsize(file1,cur_pos);
	setftime(file1,time);
	_close(file1);
	printf(sucss,name);
	docte_f++;
	return(1);
	}
}
/*****************************/
/* Поиск вируса в файле .EXE */
/*****************************/
find_exe(char *name,dword *cur_pos)
{
int	i,j;
int	file1;
char	buf1[512];
word	*tt,c1;
dword	cur;
struct	exe_header hdr;
cur=*cur_pos;
file1=_open(name,O_RDWR);
if (file1!=-1)
	{
	if (_read(file1,&hdr,0x1C)!=0x1C)  ; /* error */
	strt_ptr(hdr,&cur);
		/* устанавливаю указатель на точку старта */
	lseek(file1,cur,SEEK_SET);
	if (_read(file1,&buf1,512)!=512) ; /* error */
		/* делаю проверки на зараженность */
	if ((buf1[0]!=jmp_short)&&(buf1[1]!=0x35)) goto l1;
	lseek(file1,cur+0x37,SEEK_SET);
	if (_read(file1,&buf1,512)!=512) ; /* error */
	for(i=0,j=21; i!=22; i++, j--)
		if(buf1[i]!=msk2[j]) goto l1;

	_close(file1);
	printf(vir_msg);
	*cur_pos=cur;
	ill_f++;
	return(1);

l1:     _close(file1);
	return(0);
      }
}
/**********************/
/* Лечение файла .EXE */
/**********************/
clr_exe(char *name,dword curpos, struct ftime *time)
{
int	file1;
char	buf1[0x18];
file1=_open(name,O_RDWR);
if (file1!=-1)
	{
	lseek(file1,cur_pos+2,SEEK_SET);
		/* считываю истинный EXE-заголовок */
	if (_read(file1,&buf1,0x18)!=0x18); /* error */
	lseek(file1,0,SEEK_SET);
		/* вписываю истинный EXE-заголовок */
	if (_write(file1,&buf1,0x18)!=0x18); /* error */
		/* укорачиваю длину файла */
	chsize(file1,cur_pos);
	setftime(file1,time);
	_close(file1);
	printf(sucss,name);
	docte_f++;
	return(1);
      }
}
/***************************************/
/* Определение типа файла по заголовку */
/***************************************/
int f_exe(char *name,struct ftime *dat_tim)
{
int k;
int file1;
file1=_open(name,O_RDWR);
 if (file1!=-1)
	{
	getftime(file1,dat_tim);
	if(_read(file1,&buf1,2)==2)
	     {
	     if((buf1[0]=='M') && (buf1[1]=='Z'))
		{
		k=1;
		}
	     else
		{
		k=0;
		}
	     }
	_close(file1);
	return(k);
	}
return(-1);
}
/*******************************************/
/* Выделение смещения в файле точки старта */
/*******************************************/
int strt_ptr(struct exe_header hdr,unsigned long *cur_pos)
{
unsigned long cur;
	cur=*cur_pos;
	cur = hdr.ReloCS;
	cur = cur*16;
	cur = hdr.HdrSize*16 + cur + hdr.ExeIP;
	*cur_pos = cur;
}
/******************************/
/* Печать заголовка программы */
/******************************/
print_head()
	{
	printf(copyr1);
	printf(copyr2);
	printf(copyr3);
	printf(copyr4);
	printf(copyr5);
	printf(copyr6);
	}
/**********************************/
/* Печать используемых параметров */
/**********************************/
int reclama()
	{
printf(recl1);
printf(recl2);
printf(recl3);
printf(recl4);
exit(0);
	 }
int report(int total,int ill,int docte)
	{
printf("\n╔═════════════════════════════════════════════════════╗");
printf("\n║                 И Т О Г О :                         ║");
printf("\n╟─────────────────────────────────────────────────────╢");
printf("\n║ Всего проверено файлов    :%4d                     ║",total);
printf("\n║ Из них было заражено      :%4d                     ║",ill);
printf("\n║ Из них вылечено           :%4d                     ║",docte);
printf("\n╚═════════════════════════════════════════════════════╝\n");
	}
