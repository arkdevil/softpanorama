/*
 ИCXOДНЫЙ ТЕКСТ РЕДАКТОРА ФАЙЛОВ
 Имя модуля: ED (EDitor)
 Автор: Вадим Низамов
 141305 г.Сеpгиев Посад Московской обл.
 Скобяной пос. ул.Кирпичная 27 кв.124
 Рабочий тел.(254) 4-77-98
 Версия: 1.1
 Дата создания: 17.08.93
 Язык программирования: C
 Использованный транслятор: Borland C++ 3.0
 Запуск: ED [<имя файла>]

 Цель создания: компактный редактор с большим набором операций
 чем в Norton Editor. Идеология: уменьшение размера кода за счет
 быстродействия. Подкачка не реализована, поэтому не помещающиеся
 в ОЗУ файлы не редактируются. Содержимое файла хранится в ОЗУ в
 виде структуры, состоящей из 'кирпичей', каждый из которых состоит
 из символьной строки, текущей длины ее содержимого, указателей на
 соседние (сверху, снизу и справа) 'кирпичи'.
*/
#include <stdio.h>
#include <conio.h>
#include <alloc.h>
#include <bios.h>
#include <dos.h>

#define ADDRESSKEYS 0x417
#define BITSHIFT 0x3
#define NAMEFILEABORT "ED.ABR"
#define NAMEFILENEW   "EdFile"
#define ROWS 25
#define COLS 80
#define BUFSIZE (ROWS*COLS)
#define NHEXSYM (COLS-10)
#define NLINCOL (COLS-25)
#define NFILSIZ (COLS-40)
#define BRICKLINESIZE 35
#define YKURSEARCH (ROWS-3)
#define XKURSEARCH 34
#define MAXSEARCHSIZE 10
#define MENU "Esc-Выход             F3-Поиск  F5-Режимы  F7-Ввод нуля"
#define MENUF2          "F2-Запись"
#define MENUF2CLOSE     "         "
#define WHEREMENU   BUFSIZE-COLS+1
#define WHEREMENUF2 WHEREMENU+11
#define SUBMENU WRITETEXT(BUFSIZE+1,"НЕТ ПАМЯТИ" \
	" F2-С записью   F9-Без записи" \
	" F5-Концы строк:     F6-Копия в .bak:   ")
#define SUBMENUSEARCH WRITETEXT(BUFSIZE+80,search)
#define PUTSUBMENU1 puttext(31,14,42,14,buf+BUFSIZE)
#define PUTSUBMENU2 puttext(1,ROWS-3,15,ROWS-2,buf+BUFSIZE+11)
#define PUTSUBMENU3 puttext(33,ROWS-3,52,ROWS-2,buf+BUFSIZE+40)
#define PUTSUBMENUS puttext(23,ROWS-3,XKURSEARCH+MAXSEARCHSIZE,ROWS-2,buf+BUFSIZE+79)
#define	WHEREEND BUFSIZE+58
#define	WHEREBAK BUFSIZE+78
#define	STRINGLENGTH 1000

#define Backspace 0x0008
#define Tab       0x0009
#define Enter     0x000D
#define Esc       0x001B
//#define Backspace 0x0E08
//#define Tab       0x0F09
//#define Enter     0x1C0D
//#define Esc       0x011B
#define F2  0x3C00
#define F3  0x3D00
#define F4  0x3E00
#define F5  0x3F00
#define F6  0x4000
#define F7  0x4100
#define F9  0x4300
#define Ins    0x5200
#define Del    0x5300
#define End    0x4F00
#define KDown  0x5000
#define PgDn   0x5100
#define KLeft  0x4B00
#define KRight 0x4D00
#define Home   0x4700
#define KUp    0x4800
#define PgUp   0x4900
#define Shift_Ins    0x0130
#define Shift_Del    0x012E
#define Shift_End    0x0131
#define Shift_KDown  0x0132
#define Shift_PgDn   0x0133
#define Shift_KLeft  0x0134
#define Shift_KRight 0x0136
#define Shift_Home   0x0137
#define Shift_KUp    0x0138
#define Shift_PgUp   0x0139
#define Ctrl_KLeft  0x7300
#define Ctrl_KRight 0x7400
#define Ctrl_End    0x7500
#define Ctrl_PgDn   0x7600
#define Ctrl_Home   0x7700
#define Ctrl_PgUp   0x8400
#define Ctrl_Ins    0x9200
#define Ctrl_Del    0x9300
#define Ctrl_Y      0x0019

#define FIGURE16(x)(((x>9)?('A'-10):('0'))+x)
#define ATR(k)buf[k].atr
#define SYM(k)buf[k].sym
//#define GETKEYS(ASCIIvalue,scancode)(ASCIIvalue=(scancode=BIOSKEY())&0xFF)
#define BLOCKMARK y1!=y2||x1!=x2
#define REVERSE(x,y) c1=x;x=y;y=c1
#define KURSORSIZE(s) asm{MOV AH,1;MOV CH,s;MOV CL,7;INT 10H}
#define KURSORRIGHT if(xkur==COLS) xmove++;else xkur++

#define WRITENUMBER2(n1) \
 c1=col+1;i=0;j=n1; \
 do inform[i++]='0'+c1%10;while((c1/=10)>0); \
 while(i) SYM(j++)=inform[--i]; \
 while(SYM(j)) SYM(j++)=0

#define HEXSYM \
 key=SYM(ykur*COLS+xkur-COLS-1); \
 SYM(NHEXSYM+1)=FIGURE16((key&0xF));key/=16; \
 SYM(NHEXSYM  )=FIGURE16(key)

#define BRICK1DOWN \
 if(ykur==ROWS-1) brick1=brick1->down;else ykur++; \
 lin++

#define READFILE \
 for(;;) { \
   if((k1=fgetc(rf))==EOF) break; \
   filesize++; \
 C:if(k1==0x0D) { \
     if((k1=fgetc(rf))==EOF) {WRITESYMBOL(0x0D);break;} \
     filesize++; \
     if(k1==0x0A) \
       {(index2=index1->down=indexfree)->up=index1;ALLOC(); \
       index1=index2; \
       quanlines++; \
       continue;} \
     WRITESYMBOL(0x0D);goto C; \
   } \
   WRITESYMBOL((unsigned char)k1); \
 }

#define WRITEBUF \
 j=COLS; \
 for( \
 i=2*COLS,index1=brick1,c3=nfirstline; \
 i<BUFSIZE; \
 i+=COLS,index1=index1->down,c3++) { \
   c1=(index2=index1)->size-xmove; \
   while(c1<=0&&index2->right!=NULL) c1+=(index2=index2->right)->size; \
   c1=index2->size-c1; \
   c4=xmove-i+COLS+j; \
   sign_p=1; \
   while(j<i) { \
     if(sign_p&&(c2=c1-index2->size)>=0)  \
       {sign_p=((index2=index2->right)!=NULL); \
       c1=0;continue;} \
     ATR(j)=(sign_end&&c2++==0&&c3!=quanlines)?COLEND: \
     ((y1<c3&&c3<y2 \
     ||y1==c3&&y2==c3&&x1<=c4&&c4<x2 \
     ||y1==c3&&y2!=c3&&x1<=c4 \
     ||y1!=c3&&y2==c3&&c4<x2)?COLBLOCK:COLTEXT); \
     c4++; \
     SYM(j++)=(sign_p)?index2->line[(int)c1++]:0; \
   } \
   if(c3==quanlines) \
     {while(j<BUFSIZE-COLS) {ATR(j)=COLTEXT;SYM(j++)=0;} \
     break;} \
 }

FILE
  *rf;
union
  REGS r;
char
  *address,
  *symbols,
  *fileforedit,
  fname[]="┌┘",
  search[]="F3-Поиск  __________  F4-Замена __________ ",
  inform[]="EDITOR 1.1,Copyright(C)1993,PROZA,Nizamov";
unsigned char
  COLFRAME=16*LIGHTGRAY+BLACK,
  COLTEXT =16*BLUE     +WHITE,
  COLBLOCK=16*CYAN     +BLUE,
  COLEND  =16*GREEN    +GREEN,
  key;
struct
  {
    unsigned char sym;
    unsigned char atr;
  } buf[BUFSIZE+2*COLS];
struct
  brick {
    unsigned char line[BRICKLINESIZE];
    int  size;
    struct brick *up;
    struct brick *down;
    struct brick *right;
  }*brickroot,*brick1,*index1,*index2,*index3,*indexfree,
   *indexcut,*indexcut1;
size_t
  bricksize=sizeof(*index1);
short
  sign_p,
  sign_mod=1,
  sign_ins,
  sign_end,
  sign_bak,
  sign_mark,
  sign_mark1;
int
  cutsize=0,
  ykur=2,xkur=1,
  ys=0,xs=0,
  searchsize[]={0,0},
  k1;
long
  filesize=0,
  quanlines=1,
  xmove=0,
  nfirstline,
  lin=1,col,
  lin1, col1,
  y1,x1,y2,x2,
  c1,c2,c3,c4;

int BIOSKEY() {
  r.h.ah=0x08;
  int86(0x21,&r,&r);
  if((key=r.h.al)!=0) return key+((*address&BITSHIFT)>0)*256;
  int86(0x21,&r,&r);
  return r.h.al*256;
}
void WRITEFILE() {
  register int i;
  if(sign_mod) {
    sign_mod=0;
    if(sign_bak) {
      for(i=0;fileforedit[i]!='\0'&&fileforedit[i]!='.';i++)
	symbols[i]=fileforedit[i];
      symbols[i  ]='.';
      symbols[i+1]='b';
      symbols[i+2]='a';
      symbols[i+3]='k';
      symbols[i+4]='\0';
      rf=fopen(symbols,"wb");
    }
    else rf=fopen(fileforedit,"wb");
    c1=quanlines;
    index1=index2=brickroot;
    for(;;) {
      do
	for(i=0;i<index2->size;i++) fputc(index2->line[i],rf);
      while((index2=index2->right)!=NULL);
      if(c1--==1) break;
      fputc(0x0D,rf);fputc(0x0A,rf);
      index2=index1=index1->down;
    }
    fclose(rf);
    if(sign_bak)
      {rename(symbols,fname);
      rename(fileforedit,symbols);
      rename(fname,fileforedit);}
  }
}
void WRITETEXT(n,t) int n;char*t;
  {while(*t!=0) SYM(n++)=*t++;}
void ALLOC() {
  if((indexfree=malloc(bricksize))==NULL)
    {PUTSUBMENU1;BIOSKEY();
    free(symbols);sign_bak=0;fileforedit=NAMEFILEABORT;WRITEFILE();
    abort();}
  indexfree->size=0;indexfree->right=NULL;
}
void WRITESYMBOL(symbol) unsigned char symbol; {
  if(index2->size==BRICKLINESIZE)
    {index2=index2->right=indexfree;ALLOC();}
  index2->line[index2->size++]=symbol;
}
void WRITECUT(symbol) unsigned char symbol; {
  if(cutsize>=BRICKLINESIZE-1)
    {(indexcut1=indexcut)->size=cutsize;cutsize=0;
    (indexcut=indexfree)->right=indexcut1;ALLOC();}
  indexcut->line[cutsize++]=symbol;
}
void WRITENUMBER1(n,x) register int n;long x;
  {do SYM(n--)='0'+x%10;while((x/=10)>0);
   while(SYM(n)) SYM(n--)=0;}
void STRIKEINS()
  {if((sign_ins=!sign_ins)!=0) {KURSORSIZE(6)} else {KURSORSIZE(0)}}
void MOVEBLOCK1(y,x,c) long y,*x;int c;
  {if(lin==y&&col<*x) *x+=c;}
void MOVEBLOCK3(y,x) long *y,*x;
  {if(lin==*y&&col<*x) {*x-=col;(*y)++;} else if(lin<*y) (*y)++;}
void MOVEBLOCK4(y,x) long *y,*x;
  {if(lin+1==*y) *x+=col;if(lin==*y&&col<*x) *x=col;if(lin<*y) (*y)--;}
void INDEX1DOWN()
  {register int i=2;
  for(index1=brick1;i<ykur;i++) index1=index1->down;}
void FINDINDEX() {
  if(sign_mod==0) {sign_mod=1;WRITETEXT(WHEREMENUF2,MENUF2);}
  INDEX1DOWN();
  c1=(index2=index1)->size-col;
  while(c1<=0&&index2->right!=NULL) c1+=(index2=(index3=index2)->right)->size;
}
void JUMP()
  {if(c1==0&&index2->right!=NULL) c1=(index2=(index3=index2)->right)->size;}
void WRITESYMBOLBLANK()
  {while(++c1<=0) WRITESYMBOL(' ');}
void WRITEKEY(sign_ins) short sign_ins; {
  register int i,j;
  if(c1<=0)
    {filesize-=c1-1;
    WRITESYMBOLBLANK();
    WRITESYMBOL(key);}
  else {
    j=index2->size-(int)c1;
    if(sign_ins) {
      if(index2->size==BRICKLINESIZE) {
	if((index3=index2->right)==NULL)
	  {(index3=index2->right=indexfree)->size=1;
	  ALLOC();}
	else if(index3->size==BRICKLINESIZE)
	  {(index3=indexfree)->right=index2->right;
	  index3->size=1;
	  index2->right=index3;
	  ALLOC();}
	else for(i=index3->size++;i>0;i--) index3->line[i]=index3->line[i-1];
	index3->line[0]=index2->line[i=BRICKLINESIZE-1];
      }
      else {i=index2->size++;c1++;}
      for(;i>j;i--) index2->line[i]=index2->line[i-1];
      filesize++;
    }
    index2->line[j]=key;
  }
  if(sign_ins) {MOVEBLOCK1(y1,&x1,1);MOVEBLOCK1(y2,&x2,1);}
}
void WRITEENTER() {
  register int i=0,j;
  if(c1<=0)
    {filesize-=c1-2;
    WRITESYMBOLBLANK();}
  else
    {filesize+=2;j=(index2->size-=(int)c1);
    for(;i<c1;i++) indexfree->line[i]=index2->line[j++];
    indexfree->right=index2->right;
    index2->right=NULL;
    indexfree->size=i;}
  quanlines++;
  if((indexfree->down=index1->down)!=NULL) indexfree->down->up=indexfree;
  indexfree->up=index1;
  index1->down=indexfree;ALLOC();
  MOVEBLOCK3(&y1,&x1);MOVEBLOCK3(&y2,&x2);
}
int DELETE() {
  register int i;
  if(c1--<=0) {
    MOVEBLOCK4(&y1,&x1);MOVEBLOCK4(&y2,&x2);
    if(index1->down!=NULL)
      {filesize-=c1+3;
      while(++c1<0) WRITESYMBOL(' ');
      quanlines--;
      index3=index2->right=index1->down;
      if((index1->down=index1->down->down)!=NULL) index1->down->up=index1;
      if(index3->size==0) {index2->right=index3->right;free(index3);}
      return 2;}
    return 0;
  }
  else {
    MOVEBLOCK1(y1,&x1,-1);MOVEBLOCK1(y2,&x2,-1);
    key=index2->line[(i=index2->size-(int)c1)-1];
    for(;i<index2->size;i++) index2->line[i-1]=index2->line[i];
    filesize--;
    if(--index2->size==0&&index2!=index1)
      {index3->right=index2->right;free(index2);index2=index3;}
    return 1;
  }
}
void MOVEWINDOWx() {
  if((xmove=col+MAXSEARCHSIZE+1-COLS)<0) xmove=0;
  xkur=(int)(col+1-xmove);
}
int SEARCH() {
  register int i,j;
  for(
  index1=index2=brick1,c1=nfirstline;
  index1!=NULL;
  index1=index2=index1->down,c1++)
    for(c2=1,k1=0;index2!=NULL;index2=index2->right)
      for(i=0;i<index2->size;i++,c2++)
	if(index2->line[i]==search[10+k1]&&(c1>lin||c1==lin&&c2>col+!sign_p)) {
	  if(k1++==0) {index3=index2;j=i;c3=c2;}
	  if(k1==searchsize[0])
	    {lin=c1;col=c2-k1;ykur=2;brick1=index1;
	    MOVEWINDOWx();return 1;}
	}
	else if(k1>0) {index2=index3;i=j;c2=c3;k1=0;}
  return 0;
}
void ENDOFLINE() {
  INDEX1DOWN();
  col=index1->size;
  while(index1->right!=NULL) col+=(index1=index1->right)->size;
  if(col>=COLS) {xmove=col+1-COLS;xkur=COLS;}
  else {xmove=0;xkur=(int)col+1;}
}
void DELETEBLOCK(p) int p; {
  register int i;
  if(cutsize&&p) {
    while(indexcut->right!=NULL)
      {indexcut1=indexcut;indexcut=indexcut->right;free(indexcut1);}
    cutsize=0;
  }
  if(nfirstline<=y1&&y1<=nfirstline+ROWS-3) ykur=(int)(y1-nfirstline+2);
  else {ykur=2;for(i=1,brick1=brickroot;i<y1;i++) brick1=brick1->down;}
  lin=y1;col=x1;
  FINDINDEX();
  while(BLOCKMARK) {
    switch(DELETE()*p) {
    case 2:WRITECUT(0x0D);indexcut->line[cutsize++]=0x0A;break;
    case 1:WRITECUT(key);
    }
    JUMP();
  }
  MOVEWINDOWx();
}
void INSERTBLOCK() {
  register int i;
  y1=y2=lin;x2=(x1=col)+1;
  FINDINDEX();
  for(i=cutsize-1,indexcut1=indexcut;;) {
    if(i<0)
      {if((indexcut1=indexcut1->right)==NULL) break;
      i=indexcut1->size-1;}
    if((key=indexcut1->line[i--])==0x0A&&i>=0&&indexcut1->line[i]==0x0D)
      {WRITEENTER();i--;c1=0;}
    else WRITEKEY(1);
  }
  x2--;
}
void main(n,nrf) int n;char*nrf[]; {
  register int i,j;
  for(i=0;i<BUFSIZE+2*COLS;i++) ATR(i)=COLFRAME;
  SUBMENU;
  WRITETEXT(11*COLS+18,inform);
  puttext(1,1,COLS,ROWS,buf);
  symbols=malloc(STRINGLENGTH);
  ALLOC();
  indexcut=indexfree;ALLOC();
  brickroot=brick1=index1=index2=indexfree;ALLOC();
  if(n<=1) fileforedit=NAMEFILENEW;
  else {
    fileforedit=nrf[1];
    if(nrf[1][0]=='/'&&nrf[1][1]=='?')
      {WRITETEXT(13*COLS+25,"Usage:ED [<file_name>]");
      puttext(1,1,COLS,ROWS,buf);BIOSKEY();return;}
    if((rf=fopen(nrf[1],"rb"))!=NULL)
      {sign_mod=0;READFILE;fclose(rf);}
  }
  index1->down=NULL;
  address=ADDRESSKEYS;
  STRIKEINS();
//WRITETEXT(1,nrf[1]);
  WRITETEXT(1,fileforedit);
  SYM(NLINCOL)=':';
  WRITETEXT(WHEREMENU,MENU);
  WRITEFILE();
  for(;;) {
    col=xmove+xkur-1;nfirstline=lin-ykur+2;
    if(sign_mark)
      {if(sign_mark1==0) {y1=y2=lin1;x1=x2=col1;}
      if(y1==lin1&&x1==col1) {y1=lin;x1=col;} else {y2=lin;x2=col;}
      if(y1>y2||x1>x2&&y1==y2) {REVERSE(y1,y2);REVERSE(x1,x2);}}
    sign_mark1=sign_mark;sign_mark=0;
    WRITEBUF;
    WRITENUMBER1(NFILSIZ,filesize);
    WRITENUMBER1(NLINCOL-1,(lin1=lin));
    WRITENUMBER2(NLINCOL+1);col1=col;
    HEXSYM;
    gotoxy(xkur,ykur);
    puttext(1,1,COLS,ROWS,buf);
//  GETKEYS(key,i);
    switch(i=BIOSKEY()) {
    case Esc:
      if(sign_mod)
	{PUTSUBMENU2;
	switch(BIOSKEY()) {
	case F2:WRITEFILE();
	case F9:return;
	}
	continue;}
      return;
    case F2:
      WRITETEXT(WHEREMENUF2,MENUF2CLOSE);
      WRITEFILE();
      continue;
    case F3:
    B:SUBMENUSEARCH;
      if(xs>searchsize[ys]||xs==MAXSEARCHSIZE) xs--;
      k1=10+ys*(12+MAXSEARCHSIZE);
      gotoxy(XKURSEARCH+xs,YKURSEARCH+ys);
      PUTSUBMENUS;
//    GETKEYS(key,i);
      switch(i=BIOSKEY()) {
      case KRight:xs++;goto B;
      case KLeft: if(xs) xs--;goto B;
      case KUp:   ys=xs=0;goto B;
      case KDown: ys=1;
      case Home:  xs=0;goto B;
      case End:   xs=searchsize[ys];goto B;
      case Ins:   STRIKEINS();goto B;
      case Backspace:
	if(xs==0) goto B;xs--;
      case Del:
	for(i=k1+xs;i<k1+searchsize[ys]-1;i++) search[i]=search[i+1];
	search[i]='_';
	if(xs<searchsize[ys]) searchsize[ys]--;
	goto B;
      case F3:case F4:case Enter:
	sign_p=(i==F4||i==Enter&&ys);
	while(SEARCH()&&sign_p) {
	  for(j=0;j<searchsize[0];j++) {FINDINDEX();DELETE();}
	  FINDINDEX();
	  for(j=searchsize[1];j>0;)
	    {key=search[--j+22+MAXSEARCHSIZE];WRITEKEY(1);}
	  xkur+=searchsize[1];col+=searchsize[1];nfirstline=lin;
	}
      case Esc:continue;
      }
      if(key) {
	if(xs==searchsize[ys]) searchsize[ys]++;
	else if(sign_ins&&searchsize[ys]<MAXSEARCHSIZE)
	  for(i=searchsize[ys]++;i>xs;i--) search[k1+i]=search[k1+i-1];
	search[k1+xs]=key;
	xs++;
      }
      goto B;
    case F5:
    A:SYM(WHEREEND)=(sign_end)?'+':'-';
      SYM(WHEREBAK)=(sign_bak)?'+':'-';
      PUTSUBMENU3;
      switch(BIOSKEY()) {
      case F5:sign_end=!sign_end;goto A;
      case F6:sign_bak=!sign_bak;goto A;
      }
      continue;
    case Shift_End:sign_mark=1;
    case End:
      ENDOFLINE();
      continue;
    case Shift_KDown:sign_mark=1;
    case KDown:
      if(lin<quanlines) {BRICK1DOWN;}
      continue;
    case Shift_PgDn:sign_mark=1;
    case PgDn:
      if(nfirstline+ROWS-3<quanlines) {
	brick1=index1->up;
	if((lin+=ROWS-3)>quanlines)
	  {ykur-=(int)(lin-quanlines);lin=quanlines;}
      }
      continue;
    case Shift_KLeft:sign_mark=1;
    case KLeft:
      if(xkur>1) xkur--;else if(xmove>0) xmove--;
      continue;
    case Ctrl_KLeft:
      if((xmove-=(COLS-1))<0) xmove=0;
      continue;
    case Shift_KRight:sign_mark=1;
    case KRight:
      KURSORRIGHT;
      continue;
    case Ctrl_KRight:
      xmove+=(COLS-1);
      continue;
    case Shift_Home:sign_mark=1;
    case Home:
      xkur=1;xmove=0;
      continue;
    case Shift_KUp:sign_mark=1;
    case KUp:
      if(lin>1)
	{if(ykur==2) brick1=brick1->up;else ykur--;
	lin--;}
      continue;
    case Shift_PgUp:sign_mark=1;
    case PgUp:
      for(i=ROWS;i>3&&brick1!=brickroot;i--) {brick1=brick1->up;lin--;}
      continue;
    case Ctrl_PgUp:
      lin=nfirstline;ykur=2;
      continue;
    case Ctrl_PgDn:
      if((lin=nfirstline+ROWS-3)>quanlines) lin=quanlines;
      ykur+=(int)(lin-lin1);
      continue;
    case Ctrl_Home:
      brick1=brickroot;xmove=0;lin=xkur=1;ykur=2;
      continue;
    case Ctrl_End:
      while(index1->down!=NULL) index1=index1->down;
      brick1=index1;ykur=1;
      while(ykur++<ROWS-2&&brick1!=brickroot) brick1=brick1->up;
      xmove=0;xkur=1;lin=quanlines;
      continue;
    case Ins:
//    sign_ins=!sign_ins;
//   _setcursortype((int)sign_ins+1);
      STRIKEINS();
      continue;
    case Backspace:
      if(xkur>1) {xkur--;col--;}
      else if(xmove>0) {xmove--;col--;}
      else if(ykur>2) {ykur--;lin--;ENDOFLINE();}
      else if(lin>1) {lin--;brick1=brick1->up;ENDOFLINE();}
      else continue;
    case Del:
      FINDINDEX();DELETE();
      continue;
    case Enter:
      FINDINDEX();WRITEENTER();
      BRICK1DOWN;
      xmove=0;xkur=1;
      continue;
    case Shift_Ins:
      if(cutsize) INSERTBLOCK();
      continue;
    case Ctrl_Y:
      col=0;
      FINDINDEX();
      while(DELETE()==1) JUMP();
      MOVEWINDOWx();
      continue;
    case Ctrl_Ins:
      if(BLOCKMARK) {sign_mod++;DELETEBLOCK(1);INSERTBLOCK();sign_mod--;}
      continue;
    case Shift_Del:
    case Ctrl_Del:
      if(BLOCKMARK) DELETEBLOCK(i==Shift_Del);
      continue;
    }
    if(key||i==F7) {FINDINDEX();WRITEKEY(sign_ins);KURSORRIGHT;}
  }
}