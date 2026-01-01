/*
 ИCXOДНЫЙ ТЕКСТ "УСТАНОВКА ЦВЕТОВ РЕДАКТОРА ФОPМ"
 Имя модуля: COLEDFOR (COLours for EDitor of FORms)
 Автор: Вадим Низамов
 141305 г.Сеpгиев Посад Московской обл.
 Скобяной пос. ул.Кирпичная 27 кв.124
 Рабочий тел. (254) 4-77-98
 Версия: 1.0
 Дата создания: 18.08.93
 Язык программирования: C
 Использованный транслятор: Borland C++ 3.00
 Запуск: COLEDFOR [<имя файла>]

 Предназначен для установки цветов pедактоpа EDFOR.EXE. Поиск таблицы
 цветов осуществляется по ключу "Nizamov". Далее следуют: нулевой байт,
 байт цвета pамки, байт цвета гpафы, байт цвета заголовка, байт цвета
 блока.
*/
#include <stdio.h>
#include <conio.h>
#include <alloc.h>
#include <bios.h>
#include <dos.h>

#define NAMEFILE  "edfor.exe"
#define ROWS 25
#define COLS 80
#define BUFSIZE (ROWS*COLS)
#define yf1 15
#define xf1 15

#define Esc 0x011B
#define F2  0x3C00
#define F9  0x4300
#define End    0x4F00
#define KDown  0x5000
#define PgDn   0x5100
#define KLeft  0x4B00
#define KRight 0x4D00
#define Home   0x4700
#define KUp    0x4800
#define PgUp   0x4900
#define Ctrl_KLeft  0x7300
#define Ctrl_KRight 0x7400
#define Ctrl_End    0x7500
#define Ctrl_Home   0x7700

#define ATR(k) buf[k].atr
#define SYM(k) buf[k].sym
#define COLFRAME filebytes[nbyte  ]
#define COLFREE  filebytes[nbyte+1]
#define COLFORM  filebytes[nbyte+2]
#define COLBLOCK filebytes[nbyte+3]
#define MOD COLFRAME1!=COLFRAME|| \
	    COLFREE1 !=COLFREE || \
	    COLFORM1 !=COLFORM || \
	    COLBLOCK1!=COLBLOCK
#define WRITEMESSAGE(t) WRITETEXT(2*COLS+10,t); \
			puttext(1,1,COLS,ROWS,buf);bioskey(0); \
			return

FILE *rf;
char
  *colourfile;
unsigned char
  *filebytes,
  search[]="Nizamov",
  COLFRAME1,
  COLFREE1,
  COLFORM1,
  COLBLOCK1;
short
  sign_mod;
int
  k=0,
  filesize,
  nbyte=0,
  nfield=0;
struct {
  unsigned char sym;
  unsigned char atr;
} buf[BUFSIZE];

void REMEMBERCOL() {
  COLFRAME1=COLFRAME;
  COLFREE1 =COLFREE;
  COLFORM1 =COLFORM;
  COLBLOCK1=COLBLOCK;
}
void WRITETEXT(n,t) int n;unsigned char*t;
  {while(*t!=0) SYM(n++)=*t++;}
void WRITEATTR(y1,x1,y2,x2,attr) int y1,x1,y2,x2;unsigned char attr;
  {register int i,j;
  for(i=y1;i<=y2;i++) for(j=x1;j<=x2;j++) ATR(i*COLS+j)=attr;}
int OPENFILE() {
  if((rf=fopen(colourfile,"wb"))==NULL)
    {WRITETEXT(2*COLS+10,"файл не открыт для записи");return 0;}
  return 1;
}
void WRITEFILE()
  {register int i;
  for(i=0;i<filesize;i++) fputc(filebytes[i],rf);
  fclose(rf);}
void main(n,nrf) int n;char*nrf[]; {
  register int i;
  for(i=0;i<BUFSIZE;i++) ATR(i)=16*BLACK+WHITE;
  WRITETEXT(24,"УСТАНОВКА ЦВЕТОВ PЕДАКТОPА ФОPМ");
  WRITETEXT(COLS+10,"Colours for editor of forms,Copyright(C)1993,PROZA,Nizamov");
  WRITEATTR(2,1,2,COLS,16*DARKGRAY+YELLOW);
  if(n<=1) colourfile=NAMEFILE;
  else {
    if(nrf[1][0]=='/'&&nrf[1][1]=='?')
      {WRITEMESSAGE("Usage:COLEDFOR [<file_name>]");}
    colourfile=nrf[1];
  }
  if((rf=fopen(colourfile,"rb"))==NULL) {WRITEMESSAGE("файл не открылся");}
//____Чтение_файла,_поиск_ключа,_запись_в_ОЗУ____________________________
  filesize=(int)filelength(fileno(rf));
  if(filesize==0) {WRITEMESSAGE("файл пуст");}
  if((filebytes=malloc(filesize))==NULL)
    {WRITEMESSAGE("файл не поместился в оперативной памяти");}
  i=0;
  while(i<filesize) {
    filebytes[i]=fgetc(rf);
    if(filebytes[i++]==search[k])
      if(search[k]=='\0') nbyte=i; else k++;
    else k=0;
  }
  fclose(rf);
  if(nbyte==0) {WRITEMESSAGE("таблица цветов не найдена");}
  REMEMBERCOL();
//____Замена_цветов______________________________________________________
  for(i=0;i<=15*3;i+=3) WRITEATTR(yf1,xf1+i,yf1+1,xf1+i+2,16*(i/3));
  WRITEATTR(ROWS-3,1,ROWS-2,13,16*DARKGRAY+YELLOW);
  for(;;) {
    sign_mod=MOD;
    for(i=3*COLS;i<BUFSIZE;i++) SYM(i)=' ';
    WRITETEXT((ROWS-1)*COLS+1,"Esc-Выход");
    if(sign_mod) WRITETEXT((ROWS-1)*COLS+12,"F2-Запись");
    WRITETEXT( 7*COLS+42,      "\x18,\x19,PgUp,PgDn-Выбоp поля");
    WRITETEXT( 8*COLS+42,      "\x1B,\x1A,Home,End -Выбоp цвета фона");
    WRITETEXT( 9*COLS+36,"Ctrl+{\x1B,\x1A,Home,End}-Выбоp цвета символа");
    WRITEATTR( 7,35, 9,54,16*BLACK+YELLOW);
    WRITETEXT( 3*COLS+11,"Цветовые поля");
    WRITETEXT( 4*COLS+15,"pамка");
    WRITETEXT( 6*COLS+15,"гpафа");
    WRITETEXT( 8*COLS+13,"заголовок");
    WRITETEXT(10*COLS+12,"помеченный текст");
    WRITETEXT((yf1-1)*COLS+xf1+20,"Цвет фона");
    WRITETEXT((yf1+4)*COLS+xf1+18,"Цвет символов");
    for(i=1;i<=48;i+=3) SYM((yf1+5)*COLS+xf1+i)='x';
    WRITEATTR( 4, 5, 4,30,COLFRAME);
    WRITEATTR( 5, 5,11,30,COLFORM);
    WRITEATTR( 6, 9, 6,30,COLFREE);
    WRITEATTR(10, 9,10,30,COLBLOCK);
    WRITEATTR(12, 5,12,30,COLFRAME);
    SYM((4+2*nfield)*COLS+31)=0x1B;
    SYM((yf1+2)*COLS+xf1+filebytes[nbyte+nfield]/16*3+1)=0x18;
    SYM((yf1+6)*COLS+xf1+filebytes[nbyte+nfield]%16*3+1)=0x18;
    for(i=0;i<=15*3;i+=3)
      WRITEATTR(yf1+5,xf1+i,yf1+5,xf1+i+2,filebytes[nbyte+nfield]/16*16+i/3);
    puttext(1,1,COLS,ROWS,buf);
    switch(bioskey(0)) {
      case Esc:
	if(sign_mod) {
	  WRITETEXT((ROWS-3)*COLS+1,"F2-С записью");
	  WRITETEXT((ROWS-2)*COLS+1,"F9-Без записи");
	  puttext(1,1,COLS,ROWS,buf);
	  switch(bioskey(0)) {
	    case F2:if(OPENFILE()) WRITEFILE();else continue;
	    case F9:return;
	  }
	  continue;
	}
	return;
      case F2:
	if(sign_mod&&OPENFILE()) {WRITEFILE();REMEMBERCOL();}
	continue;
      case KUp:
	if(nfield) nfield--;
	continue;
      case KDown:
	if(nfield<3) nfield++;
	continue;
      case PgUp:
	nfield=0;
	continue;
      case PgDn:
	nfield=3;
	continue;
      case KRight:
	if(filebytes[nbyte+nfield]/16<15) filebytes[nbyte+nfield]+=16;
	continue;
      case KLeft:
	if(filebytes[nbyte+nfield]/16) filebytes[nbyte+nfield]-=16;
	continue;
      case End:
	filebytes[nbyte+nfield]|=0xF0;
	continue;
      case Home:
	filebytes[nbyte+nfield]&=0x0F;
	continue;
      case Ctrl_KRight:
	if(filebytes[nbyte+nfield]%16<15) filebytes[nbyte+nfield]++;
	continue;
      case Ctrl_KLeft:
	if(filebytes[nbyte+nfield]%16) filebytes[nbyte+nfield]--;
	continue;
      case Ctrl_End:
	filebytes[nbyte+nfield]|=0x0F;
	continue;
      case Ctrl_Home:
	filebytes[nbyte+nfield]&=0xF0;
    }
  }
}