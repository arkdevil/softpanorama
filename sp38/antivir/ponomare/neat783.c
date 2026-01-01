#include <fcntl.h>
#include <dos.h>
#include <io.h>
#include <conio.h>
#include "neatfag.def"
struct f_dta b_dta;
extern int cript();
const char* copyr1="\n╔═════════════════════════════════════════════════════╗";
const char* copyr2="\n║                      Фаг Neat783                    ║";
const char* copyr3="\n╟─────────────────────────────────────────────────────╢";
const char* copyr4="\n║ Для лечения от вируса  RC-783                       ║";
const char* copyr5="\n║ (C) Пономаренко В.В. & гр. NeatAvia 4.10.91 г. Киев ║";
const char* copyr6="\n╚═════════════════════════════════════════════════════╝\n";

const char* recl1="\n  Neat783  [диск] [/F] [/G]  ";
const char* recl2="\n              │     │    └─── Проверка всех файлов(иначе только COM,EXE)";
const char* recl3="\n              │     └──────── Лечить зараженные файлы";
const char* recl4="\n              └────────────── Проверяемый диск \n";

const char* vir_msg=" has virus RC-783\n";

const byte msk1[]={ 0x04,0x7E,0xE8,0x08,0x76,0xEB,0x81,0x5B,0x00,0x00,0xE8 };

const byte msk2[]={ 0xFA,0x53,0x9C,0x06,0x57,0x56,0x52,0x51,0x53,0x5D,0x00,
		    0x5D,0x87,0x89,0x2E,0x04,0x46,0x8B,0xEC,0x8B,0x55,0x50 };


const	char sucss[]="  File %s desinfected \n";

const	byte jmp_short=0xEB;

/*struct	f_dta s_dta[16];*/
byte dta_cnt=0;  /* Счетчик уровня DTA */


char	*name;
char	attr;
int	file1;		/* Описатель файла */
char	buf2[40];	/* Второй буфер для файла */
char	cur_dir[200];	/* Текущий директорий */
int	cur_disk;	/* Текущий диск       */
char	work_dir[200];	/* Рабочий директорий */
int	work_disk;	/* Рабочий диск       */
int	g;		/* Наличие ключа /G   */
int	f;		/* Наличие ключа /F   */
struct	ftime time;	/* Дата и время модификации файла */
dword	cur_pos;	/* Текущая позиция в файле */
word	total_f=0;	/* Число проверенных файлов */
word	ill_f=0;	/* Число зараженных файлов */
word	docte_f=0;	/* Число вылеченных  файлов */
word	*tt;
struct exe_header ex_h; /* Буфер для EXE-заголовка */
char	buf1[512];

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
word	*tt,c1;
dword	cur;
file1=_open(name,O_RDWR);
if (file1!=-1)
	{
	if (_read(file1,&buf1,10)!=10) goto l1;
	/********* Проверка точки старта файла ************/
	if (	(buf1[0]!='\xFF')||
		(buf1[1]!='\x26')||
		(buf1[4]!='\xFF')||
		(buf1[5]!='\xE0')	) goto l1;
	/***** Определяю базовый адрес вируса *************/
	tt=&buf1[2]; cur=*tt; cur-=0x100;

	lseek(file1,cur,SEEK_SET);
	if (_read(file1,&buf1,2)!=2) goto l1;

	tt=&buf1[0]; cur=*tt; cur-=0x100;
	lseek(file1,cur,SEEK_SET);
	if (_read(file1,&buf1,512)!=512) goto l1;

	if ((buf1[0x15])!='\x2E') goto l1;
	if ((buf1[0x16])!='\x86') goto l1;
	if ((buf1[0x17])!='\x8C') goto l1;
	if ((buf1[0x18])!='\x8E') goto l1;
	if ((buf1[0x19])!='\x81') goto l1;
	*cur_pos=cur;

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
word	*tt,c1;
dword	t1,t2;
file1=_open(name,O_RDWR);
if (file1!=-1)
	{
	lseek(file1,0,SEEK_SET);
		/* вписываю правильное начало файла */
	if (_write(file1,&buf1[0x1F0],6)!=6) ; /* error */
		/* укорачиваю длину файла */
	chsize(file1,curpos);
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