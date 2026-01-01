//  ИCXOДНЫЙ ТЕКСТ РЕДАКТОРА ФОРМ
//  Имя модуля: EDFOR (EDitor FORm)
//  Автор: Вадим Низамов
//  141305 г.Сеpгиев Посад Московской обл.
//  Скобяной пос. ул. Кирпичная 27 кв.124
//  Рабочий тел. (254)4-77-98
//  Версия: 1.01
//  Дата создания: 1.06.93
//  Язык программирования: C
//  Использованный транслятор: Borland C++ 2.00
//  Запуск: EDFOR <имя файла>

//  Предназначен для редактирования файлов, содержимое которых имеет форму
//  бланка: разбито на поля открытые(графы) и закрытые по записи(заголовки).
//  В файле с расширением edf хранится в свернутом виде информация о форме.
//  Подкачка не реализована, поэтому не помещающиеся в ОЗУ файлы не
//  редактируются. Содержимое файла хранится в ОЗУ в виде структуры,
//  состоящей из 'кирпичей', каждый из которых состоит из строк символов и
//  атрибутов, текущей длины их содержимого, указателей на соседние (сверху,
//  снизу, справа и слева) 'кирпичи'. При нехватке ОЗУ прекращает работу с
//  записью последней редакции в EDF1.ABR и EDF2.ABR.

#include <stdio.h>
#include <conio.h>
#include <alloc.h>
#include <bios.h>
#include <dos.h>

#define ADDRESSKEYS 0x417
#define BITSHIFT 0x3
#define NAMEFILEABORT  "EDF1.ABR"
#define NAMEFILEABORTA "EDF2.ABR"
#define COLFRAME (BLACK+16*LIGHTGRAY)
#define COLTEXT  (WHITE+16*BLUE)
#define COLFORM  0x31
#define COLBLOCK 0x12
#define ROWS 25
#define COLS 80
#define BUFSIZE (ROWS*COLS)
#define NHEXSYM (COLS-10)
#define NLINCOL (COLS-25)
#define NFILSIZ (COLS-40)
#define BRICKSIZE 35
#define BRICKCUTSIZE 40
#define YKURSEARCH (ROWS-3)
#define XKURSEARCH 34
#define MAXSEARCHSIZE 10
#define FREE '\0'
#define FORM '\2'
#define INFORM "FORM EDITOR,Copyright(C)1993,PROZA,Nizamov"
#define MENU "Esc-Выход             F3-Поиск  F5-Ввод нуля  F6-Режим"
#define MENUF2          "F2-Запись"
#define MENUF7 "F7-Заголовок  F8-Графа"
#define WHEREMENU   BUFSIZE-COLS+1
#define WHEREMENUF2 WHEREMENU+11
#define WHEREMENUF7 WHEREMENU+56
#define SUBMENUABORT  WRITETEXT(BUFSIZE+1,"НЕТ ПАМЯТИ ")
#define SUBMENUESC    WRITETEXT(BUFSIZE+1,"F2-С записью   F9-Без записи ")
#define SUBMENUSEARCH WRITETEXT(BUFSIZE+1,search)
#define PUTSUBMENUABORT  puttext(31,14,42,14,buf+BUFSIZE)
#define PUTSUBMENUESC 	 puttext(1,ROWS-3,15,ROWS-2,buf+BUFSIZE)
#define PUTSUBMENUSEARCH puttext(23,ROWS-3,XKURSEARCH+MAXSEARCHSIZE,ROWS-2,buf+BUFSIZE)

//#define Backspace 0x0E08
//#define Tab       0x0F09
//#define Enter     0x1C0D
//#define Esc       0x011B
#define Backspace 0x0008
#define Tab       0x0009
#define Enter     0x000D
#define Esc       0x001B
#define F2 0x3C00
#define F3 0x3D00
#define F4 0x3E00
#define F5 0x3F00
#define F6 0x4000
#define F7 0x4100
#define F8 0x4200
#define F9 0x4300
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
#define Shift_Tab    0x0F00
//#define Shift_Ins    0x5230
//#define Shift_Del    0x532E
//#define Shift_End    0x4F31
//#define Shift_KDown  0x5032
//#define Shift_PgDn   0x5133
//#define Shift_KLeft  0x4B34
//#define Shift_KRight 0x4D36
//#define Shift_Home   0x4737
//#define Shift_KUp    0x4838
//#define Shift_PgUp   0x4939
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
//#define Ctrl_KLeft  0x7300
//#define Ctrl_KRight 0x7400
#define Ctrl_End    0x7500
#define Ctrl_PgDn   0x7600
#define Ctrl_Home   0x7700
#define Ctrl_PgUp   0x8400
#define Ctrl_Ins    0x9200
#define Ctrl_Del    0x9300
#define Ctrl_Y      0x0019

#define FIGURE16(x)(((x>9)?('A'-10):('0'))+x)
#define ATT(k)buf[k].att
#define SYM(k)buf[k].sym
//#define GETKEYS(ASCIIvalue,scancode)(ASCIIvalue=(scancode=bioskey(0))&0xFF)
#define WINDOWOUT(s)((s&'\1')=='\0')
#define WINDOWIN(s) ((s&'\1')=='\1')
#define DIFFERENTFORM(s1,s2) ((s1&0x02)!=(s2&0x02))
#define BLOCKMARK y1!=y2||x1!=x2
#define REVERSE(x,y) c1=x;x=y;y=c1
#define KURSORSIZE(s) asm{MOV AH,1;MOV CH,s;MOV CL,7;INT 10H}

#define WRITENUMBER2(n1) \
 c1=col+1L;i=0;j=n1; \
 do symcol[i++]='0'+c1%10;while((c1/=10L)>0L); \
 while(i) SYM(j++)=symcol[--i]; \
 while(SYM(j)) SYM(j++)=0

#define HEXSYM \
 key=SYM(ykur*COLS+xkur-COLS-1); \
 SYM(NHEXSYM+1)=FIGURE16((key&0xF));key/=16; \
 SYM(NHEXSYM)=FIGURE16(key)

#define READFILE \
 (brickroot=brick1window=index1=index2=indexfree)->up=NULL;ALLOC(); \
 for(;;) { \
   key=fgetc(rf); \
   if(feof(rf)) break; \
   filesize++; \
 C:if(key==0x0D) { \
     key=fgetc(rf); \
     if(feof(rf)) {WRITESYMBOL(0x0D,FREE);break;} \
     filesize++; \
     if(key==0x0A) \
       {index2->attr[index2->size]=FREE; \
       (index2=index1->down=indexfree)->up=index1;ALLOC(); \
       index1=index2; \
       quanlines++; \
       continue;} \
     WRITESYMBOL(0x0D,FREE);goto C; \
   } \
   WRITESYMBOL(key,FREE); \
 } \
 index2->attr[index2->size]=FREE; \
 index1->down=NULL

#define READFILEATTR \
 if((rfa=fopen(namefile,"rb"))!=NULL) { \
   index1=index2=brickroot;i=0; \
   for(;;) { \
     key=fgetc(rfa); \
     if(feof(rfa)) break; \
     k1=key>>2;key=key&0x03; \
     if(k1==0) \
       {index2->attr[i]=key; \
       index1=index2=index1->down;i=0; \
       continue;} \
     while(k1-->0) \
       {if(i==BRICKSIZE) {index2=index2->right;i=0;} \
       index2->attr[i++]=key;} \
   } \
 } \
 fclose(rfa)

#define WRITEBUF \
 j=COLS; \
 for( \
 i=2*COLS,index1=brick1window,c3=nfirstline; \
 i<BUFSIZE; \
 i+=COLS,index1=index1->down,c3++) { \
   c1=(index2=index1)->size-xmove; \
   while(c1<=0L&&index2->right!=NULL) c1+=(index2=index2->right)->size; \
   c1=index2->size-c1; \
   c4=xmove-i+COLS+j; \
   sign_p=(y1<c3&&c3<y2); \
   while(j<i) \
     if(c1>=index2->size) \
       if(index2->right==NULL) { \
	 key=COLTEXT+(index2->attr[index2->size]>=FORM)*COLFORM; \
	 while(j<i) \
	   {SYM(j)=0; \
	   ATT(j++)=key+(sign_p \
	   ||y1==c3&&y2==c3&&x1<=c4&&c4<x2 \
	   ||y1==c3&&y2!=c3&&x1<=c4 \
	   ||y1!=c3&&y2==c3&&c4<x2)*COLBLOCK; \
	   c4++;} \
	 break; \
       } \
       else {index2=index2->right;c1=0L;} \
     else \
       {SYM(j)=index2->symb[(int)c1]; \
       ATT(j++)=COLTEXT+(index2->attr[(int)c1++]>=FORM)*COLFORM+(sign_p \
       ||y1==c3&&y2==c3&&x1<=c4&&c4<x2 \
       ||y1==c3&&y2!=c3&&x1<=c4 \
       ||y1!=c3&&y2==c3&&c4<x2)*COLBLOCK; \
       c4++;} \
   if(c3==quanlines) \
     {while(j<BUFSIZE-COLS) {ATT(j)=COLTEXT;SYM(j++)=0;} \
     break;} \
 }

FILE *rf,*rfa;
union REGS r;
char *address;
struct brick {
  unsigned char symb[BRICKSIZE];
  unsigned char attr[BRICKSIZE+1];
  int  size;
  struct brick *up;
  struct brick *down;
  struct brick *left;
  struct brick *right;
}*brickroot,*brick1window,*index1,*index2,*index3,*indexfree;
size_t bricksize=sizeof(*index1);
struct brickcut {
  unsigned char line[BRICKCUTSIZE];
  struct brickcut *left;
}*indexcut,*indexcut1;
size_t bricksizecut=sizeof(*indexcut);
struct {
  unsigned char sym;
  unsigned char att;
} buf[BUFSIZE+COLS];
short sign_p,
      sign_mod,
      sign_ins,
      sign_mark,
      sign_mark1,
      sign_form;
int   ykur=2,xkur=1,
      ys=0,xs=0,
      puttextrows=ROWS,
      searchsize[]={0,0},
      cutsize=0,
      k1;
long  filesize=0L,
      quanlines=1L,
      xmove=0L,
      nfirstline=1L,
      lin=1L,col=0L,
      lin1, col1,
      y1,x1,y2,x2,
      c1,c2,c3,c4;
//char  namefile[50],
char  *namefile,
      symcol[7],
      search[]="F3-Поиск  __________  F4-Замена __________ ";
unsigned char key,key1,key2;

int BIOSKEY() {
  r.h.ah=0x08;
  int86(0x21,&r,&r);
  if((key=r.h.al)!=0) return key+((*address&BITSHIFT)>0)*256;
  int86(0x21,&r,&r);
  return r.h.al*256;
}
void WRITEFILES(f,fa) char*f,*fa; {
  register int i;
  if(sign_mod) {
    sign_mod=0;
    rf=fopen(f,"wb");rfa=fopen(fa,"wb");
    c1=quanlines;key=k1=0;
    index1=index2=brickroot;
    for(;;) {
      for(;;) {
	for(i=0;i<index2->size;i++) {
	  fputc(index2->symb[i],rf);
	  if(index2->attr[i]!=key)
	    {if(k1) fputc(key|k1<<2,rfa);
	    key=index2->attr[i];k1=1;}
	  else if(k1==0x3F) {fputc(key|0xFC,rfa);k1=1;}
	  else k1++;
	}
	if(index2->right==NULL) break;
	index2=index2->right;
      }
      if(k1) {fputc(key|k1<<2,rfa);key=k1=0;}
      fputc(index2->attr[i],rfa);
      if(c1--==1L) break;
      fputc(0x0D,rf);fputc(0x0A,rf);
      index2=index1=index1->down;
    }
    fclose(rf);fclose(rfa);
  }
}
void WRITETEXT(n,t) int n;char*t;
  {while(*t!=0) SYM(n++)=*t++;}
void WRITEBLANK(n,q) int n,q;
  {while(q-->0) SYM(n+q)=' ';}
void WRITENUMBER1(n,x) register int n;long x;
  {do SYM(n--)='0'+x%10;while((x/=10)>0);
   while(SYM(n)) SYM(n--)=0;}
void WMOD()
  {if(sign_mod==0) {sign_mod=1;WRITETEXT(WHEREMENUF2,MENUF2);}
  puttextrows=ROWS;}
void SOUND()
  {sound(800);delay(100);nosound();}
void ABORT()
  {SUBMENUABORT;PUTSUBMENUABORT;SOUND();BIOSKEY();
  free(namefile);WRITEFILES(NAMEFILEABORT,NAMEFILEABORTA);abort();}
void ALLOC()
  {if((indexfree=malloc(bricksize))==NULL) ABORT();
  indexfree->size=0;indexfree->right=NULL;}
void ALLOCCUT()
  {if((indexcut=malloc(bricksizecut))==NULL) ABORT();}
void WRITESYMBOL(symbol,attribute) unsigned char symbol,attribute; {
  if(index2->size==BRICKSIZE)
//  {index2->right=indexfree;ALLOC();
//  index2->right->left=index2;index2=index2->right;}
    {(index2->right=indexfree)->left=index2;index2=indexfree;ALLOC();}
  index2->symb[index2->size]=symbol;
  index2->attr[index2->size++]=attribute;
}
void WRITECUT(symbol,attribute) unsigned char symbol,attribute; {
  if(cutsize==BRICKCUTSIZE)
    {indexcut1=indexcut;cutsize=0;
    ALLOCCUT();indexcut->left=indexcut1;}
  indexcut->line[cutsize++]=attribute;
  indexcut->line[cutsize++]=symbol;
}
void STRIKEINS()
  {if((sign_ins=!sign_ins)!=0) {KURSORSIZE(6)} else {KURSORSIZE(0)}}
void MOVEBLOCK1(y,x,c) long y,*x;int c;
  {if(lin==y&&col<*x) *x+=c;}
void MOVEBLOCK2(y,x,c) long y,*x;int c;
  {if(lin==y&&col<*x&&*x<c4) *x+=c;}
void MOVEBLOCK3(y,x) long *y,*x;
  {if(lin==*y&&col<*x) {*x-=col;(*y)++;} else if(lin<*y) (*y)++;}
//void MOVEBLOCK4()
//  {if(lin==y2) x2=col;else {if(lin+1==y2) x2+=col;y2--;}}
void MOVEBLOCK4(y,x) long *y,*x;
  {if(lin+1==*y) *x+=col;if(lin==*y&&col<*x) *x=col;if(lin<*y) (*y)--;}
void FINDINDEX() {
  register int i=2;
  for(index1=brick1window;i<ykur;i++) index1=index1->down;
  c1=(index2=index1)->size-col;
  while(c1<=0L&&index2->right!=NULL) c1+=(index2=index2->right)->size;
}
void CORRECT(i) int i; {
  key=(index3=index2)->attr[i];
  sign_p=WINDOWIN(key);
  for(;;)
    if(--i>=0)
      if(WINDOWIN(index3->attr[i]))
	if(sign_p==0&&index3->attr[i]-'\1'==key) index3->attr[i]--;
//      else sign_p=1;
	else break;
      else
	{if(sign_p||index3->attr[i]!=key) {index3->attr[i]++;sign_p=1;}}
    else if(index3==index1) break;
    else i=(index3=index3->left)->size;
}
void WRITEKEY(sign_ins) short sign_ins; {
  register int i;
  if(c1<=0L)
    {filesize-=c1-1L;key1=index2->attr[index2->size];
    while(++c1<=0L) WRITESYMBOL(' ',key1);
    WRITESYMBOL(key,key1);
    k1=index2->size-1;
    index2->attr[index2->size]=key1;
    if(sign_ins) {MOVEBLOCK1(y1,&x1,1);MOVEBLOCK1(y2,&x2,1);}}
  else {
    k1=index2->size-(int)c1;
    if(sign_ins==0) index2->symb[k1]=key;
    else {
      if(sign_ins>1&&sign_form||WINDOWOUT(index2->attr[k1])) {
	if(index2->size==BRICKSIZE) {
	  if((index3=index2->right)==NULL)
	    {(index3=index2->right=indexfree)->size=1;
	    index3->attr[1]=index2->attr[BRICKSIZE];
	    index3->left=index2;
	    ALLOC();}
	  else if(index3->size==BRICKSIZE)
	    {((index3=indexfree)->right=index2->right)->left=indexfree;
	    index3->size=1;index2->right=index3;index3->left=index2;
	    ALLOC();}
	  else {
	    i=index3->size++;
	    index3->attr[i+1]=index3->attr[i];
	    for(;i>0;i--)
	      {index3->symb[i]=index3->symb[i-1];
	      index3->attr[i]=index3->attr[i-1];}
	  }
	  index3->symb[0]=index2->symb[i=BRICKSIZE-1];
	  index3->attr[0]=index2->attr[i];
	}
	else {i=index2->size++;c1++;index2->attr[i+1]=index2->attr[i];}
	for(;i>k1;i--)
	  {index2->symb[i]=index2->symb[i-1];
	  index2->attr[i]=index2->attr[i-1];}
	index2->symb[k1]=key;filesize++;
	MOVEBLOCK1(y1,&x1,1);MOVEBLOCK1(y2,&x2,1);
      }
      else {
	for(index3=index2,c4=col,i=k1;;)
	  if(i<index3->size)
	    {if(index3->attr[i]!=index2->attr[k1]) break;
	    key1=index3->symb[i];index3->symb[i++]=key;key=key1;c4++;}
	  else
	    {if((index3=index3->right)==NULL) break;
	    i=0;}
	MOVEBLOCK2(y1,&x1,1);MOVEBLOCK2(y2,&x2,1);
      }
    }
  }
}
void WRITEENTER() {
  register int i=0,j;
  if(c1<=0L)
    {filesize-=c1-2L;key1=index2->attr[index2->size];
    while(++c1<=0L) WRITESYMBOL(' ',key1);
    index2->attr[k1=index2->size]=indexfree->attr[0]=key1;
    indexfree->right=NULL;}
  else {
    filesize+=2L;
    k1=j=(index2->size-=(int)c1);
    for(;i<c1;i++)
      {indexfree->symb[i]=index2->symb[j];
      indexfree->attr[i]=index2->attr[j++];}
    indexfree->attr[i]=index2->attr[j];
    if((indexfree->right=index2->right)!=NULL)
      {indexfree->right->left=indexfree;index2->right=NULL;}
    if(WINDOWIN(index2->attr[k1])) {index2->attr[k1]--;CORRECT(k1);}
  }
  indexfree->size=i;
  quanlines++;
  if((indexfree->down=index1->down)!=NULL) indexfree->down->up=indexfree;
  indexfree->up=index1;
  index1->down=indexfree;ALLOC();
  MOVEBLOCK3(&y1,&x1);MOVEBLOCK3(&y2,&x2);
}
void DELETESYMBOL() {
  register int i,j;
  if(c1>0L) {
    WMOD();
    if(WINDOWOUT((key1=index2->attr[i=index2->size-(int)c1]))) {
      MOVEBLOCK1(y1,&x1,-1);MOVEBLOCK1(y2,&x2,-1);
      filesize--;index2->size--;
      for(;i<index2->size;i++)
	{index2->symb[i]=index2->symb[i+1];
	index2->attr[i]=index2->attr[i+1];}
      index2->attr[i]=index2->attr[i+1];
      if(index2->size==0&&index2!=index1)
	{index2->left->right=index2->right;
	index2->left->attr[index2->left->size]=index2->attr[0];
	if(index2->right!=NULL) index2->right->left=index2->left;
	free(index2);}
    }
    else {
      for(++i,c4=col+2L;;)
	if(i<index2->size)
	  {if(index2->attr[i]!=key1) break;
	  if(i>0) index2->symb[i-1]=index2->symb[i];
	  else index2->left->symb[j]=index2->symb[0];
	  c4++;i++;}
	else
	  {if(index2->right==NULL) break;
	  index2=index2->right;j=i-1;i=0;}
      if(i>0) index2->symb[i-1]=' ';else index2->left->symb[j]=' ';
      MOVEBLOCK2(y1,&x1,-1);MOVEBLOCK2(y2,&x2,-1);
    }
  }
}
void DELETESYMBOLEND(p) int p; {
  register int i,j;
  if(c1<=0L)
    if(index1->down!=NULL)
      if(sign_form) {
//	MOVEBLOCK4();
	MOVEBLOCK4(&y1,&x1);MOVEBLOCK4(&y2,&x2);
	filesize-=--c1+3L;quanlines--;
	key1=index2->attr[index2->size];
	if(p) WRITECUT(0x00,key1|0x10);
	while(++c1<0L) WRITESYMBOL(' ',key1);
	index3=index2->right=index1->down;
	if((index1->down=index3->down)!=NULL) index1->down->up=index1;
	if(index3->size==0)
	  {index2->attr[index2->size]=index3->attr[0];
	  index2->right=index3->right;free(index3);}
	if(index2->right!=NULL)
	  {index2->right->left=index2;
	  c1=(index2=index2->right)->size;i=0;}
	else  i=index2->size;
	CORRECT(i);
      }
      else
	{c1=(index2=index1=index1->down)->size;
	y1++;lin++;x1=col=0;}
    else {y2=y1;x2=x1;}
  else {
    j=i=index2->size-(int)c1;
    key1=index2->attr[i];
    if(p) WRITECUT(index2->symb[i],key1);
    if(sign_form||WINDOWOUT(key1)) {
      MOVEBLOCK1(y1,&x1,-1);MOVEBLOCK1(y2,&x2,-1);
      filesize--;index2->size--;
      for(;i<index2->size;i++)
	{index2->symb[i]=index2->symb[i+1];
	index2->attr[i]=index2->attr[i+1];}
      index2->attr[i]=index2->attr[i+1];
      CORRECT(j);
      if(index2->size==0&&index2!=index1)
	{(index3=index2->left)->right=index2->right;
	if(index2->right!=NULL) index2->right->left=index3;
	index3->attr[index3->size]=index2->attr[0];
	free(index2);index2=index3;}
      if(--c1==0L&&index2->right!=NULL) c1=(index2=index2->right)->size;
    }
    else {
      index3=index2;
      for(++i,c4=col+2L;;)
	if(i<index3->size)
	  {if(index3->attr[i]!=key1) break;
	  if(i>0) index3->symb[i-1]=index3->symb[i];
	  else index3->left->symb[j]=index3->symb[0];
	  c4++;i++;}
	else
	  {if(index3->right==NULL) break;
	  index3=index3->right;j=i-1;i=0;}
      if(lin!=y2||c4<=x2) {y2=lin;x2=c4-1L;}
      if(i>0) index3->symb[i-1]=' ';else index3->left->symb[j]=' ';
      MOVEBLOCK2(y2,&x2,-1);
    }
  }
}
void MOVEXWINDOW() {
  if(xmove>col||col>xmove+COLS-1)
    {if((xmove=col+1-COLS)<0) xmove=0L;puttextrows=ROWS;}
}
void MOVEYWINDOW(p) int p; {
  if(nfirstline<=lin&&lin<=nfirstline+ROWS-3) ykur=(int)(lin-nfirstline)+2;
  else {
    for(
    ykur=2,brick1window=index1;
    ykur<(ROWS-1)*p&&brick1window!=brickroot;
    ykur++)
      brick1window=brick1window->up;
    puttextrows=ROWS;
  }
}
void KURSORLEFT() {
  register int j;
  if(sign_form||c1<0L) col-=(col>0L);
  else
    for(j=index2->size-(int)c1;;)
      if(j>0)
	{col--;
	if(index2->attr[--j]<FORM) break;
	sign_mark=0;}
      else if(index2==index1) {col=col1;SOUND();break;}
      else {index2=index2->left;j=index2->size;}
}
void KURSORRIGHT() {
  register int j;
  if(sign_form||c1<=0L) col++;
  else
    for(j=index2->size-(int)c1;;)
      {col++;
      if(j<index2->size-1||index2->right==NULL) j++;
      else {index2=index2->right;j=0;}
      if(index2->attr[j]<FORM) break;
      if(j==index2->size) {col=col1;SOUND();break;}
      sign_mark=0;}
}
int SEARCH() {
  register int i,j;
  for(
  index1=index2=brick1window,c1=nfirstline;
  index1!=NULL;
  index1=index2=index1->down,c1++)
    for(c2=1L,k1=0;index2!=NULL;index2=index2->right)
      for(i=0;i<index2->size;i++,c2++)
	if(index2->symb[i]==search[10+k1]&&(sign_form||index2->attr[i]<FORM)
	&&(c1>lin||c1==lin&&c2>col+!sign_p)) {
	  if(k1++==0) {index3=index2;j=i;c3=c2;}
	  if(k1==searchsize[0])
	    {lin=c1;col=c2-k1;ykur=2;brick1window=index1;
	    MOVEXWINDOW();return 1;}
	}
	else if(k1>0) {index2=index3;i=j;c2=c3;k1=0;}
  SOUND();return 0;
}
void SEARCHFREE(j) int j; {
  for(;;) {
    col++;
    if(j<index2->size-1) j++;
    else if(j==index2->size-1)
      if(index2->right==NULL) j++;
      else {index2=index2->right;j=0;}
    else if((index1=index2=index1->down)==NULL)
      {lin=lin1;col=col1;SOUND();break;}
    else
      {lin++;col=j=-1;sign_p=1;continue;}
    if(sign_p&&index2->attr[j]<FORM)
      {MOVEYWINDOW(0);MOVEXWINDOW();break;}
    else if(sign_p==0&&index2->attr[j]>=FORM) sign_p=1;
  }
}
void ENDOFLINE() {
  register int j;
  if(c1<=0L) col+=c1;
  else
    for(j=index2->size-(int)c1,c1=0L;;) {
      c1++;
      if(j<index2->size-1||index2->right==NULL) j++;
      else {index2=index2->right;j=0;}
      if(sign_form||index2->attr[j]<FORM)
	{col+=c1;
	if(c1>1L&&sign_mark) {col1=col;sign_mark1=0;}
	c1=0L;}
      if(j==index2->size) break;
    }
}
void MAKEFORM(s1,s2) unsigned char s1,s2; {
  register int i,j=0;
  if(sign_form) {
    WMOD();
    if(BLOCKMARK) {
      if(nfirstline<=y1&&y1<=nfirstline+ROWS-3) ykur=(int)(y1-nfirstline)+2;
      else
	for(i=1,brick1window=brickroot,ykur=2;i<y1;i++)
	  brick1window=brick1window->down;
      lin=y1;col=x1;
      FINDINDEX();MOVEXWINDOW();
    }
    else
      {FINDINDEX();
      y1=y2=lin;x2=(x1=col++)+1L;
      xmove+=(xkur==COLS);}
    if(c1<=0L) {
      if(index2->attr[index2->size]==s2)
	{filesize-=c1;
	while(++c1<=0L) WRITESYMBOL(' ',s2);
	index2->attr[index2->size]=s2;}
      c1=0L;
    }
    i=index2->size-(int)c1;
    for(;;)
      if(i<index2->size)
	{if(y1==y2&&x1==x2) break;
	x1++;index2->attr[i++]=s1;}
      else if(index2->right==NULL)
	if(y1==y2) {
	  if(x1<x2&&index2->attr[i]==s2)
	    {for(;x1<x2;x1++) {WRITESYMBOL(' ',s1);filesize++;}
	    index2->attr[index2->size]=s2;}
	  else x1=x2;
	  i=index2->size;break;
	}
	else
	  {index2->attr[i]=s1;
	  if(j==0) {CORRECT(i);j=1;}
	  index2=index1=index1->down;
	  y1++;x1=i=0;}
      else {index2=index2->right;i=0;}
    CORRECT(i);
  }
}
void DOWN(c) long c; {
  register int j;
  for(j=index2->size-((c1>0L)?(int)c1:0),c1=-1L;;) {
    col++;
    if(j<index2->size-1) j++;
    else if(j==index2->size-1)
      if(index2->right==NULL) j++;
      else {index2=index2->right;j=0;}
    else {
      if(c1>=0L) {col=((col-1L==c1&&col1>c1)?col1:c1);break;}
      if((index1=index2=index1->down)==NULL)
	{lin=lin1;col=col1;SOUND();break;}
      lin++;col=c1=j=-1;continue;
    }
    if(sign_form||index2->attr[j]<FORM) {
      if(lin>c)
	if(c1==-1L||abs(col1-col)<abs(col1-c1)) c1=col;
	else {col=c1;break;}
    }
    else sign_mark=0;
  }
}
void UP(c) long c; {
  register int j;
  for(col=c1=j=-1,index2=index1;;) {
    col++;
    if(j<index2->size-1) j++;
    else if(j==index2->size-1)
      if(index2->right==NULL) j++;
      else {index2=index2->right;j=0;}
    else {
      if(c1>=0L) {col=((col-1L==c1&&col1>c1)?col1:c1);break;}
      if((index1=index2=index1->up)==NULL)
	{lin=lin1;col=col1;SOUND();break;}
      lin--;col=c1=j=-1;continue;
    }
    if(sign_form||index2->attr[j]<FORM) {
      if(lin<c)
	if(c1==-1L||abs(col1-col)<abs(col1-c1)) c1=col;
	else {col=c1;break;}
    }
    else sign_mark=0;
  }
}
void DELETEBLOCK(p) int p; {
  register int i,j;
  if(cutsize&&p) {
    while(indexcut->left!=NULL)
      {indexcut1=indexcut;indexcut=indexcut->left;free(indexcut1);}
    cutsize=0;
  }
  if(nfirstline<=y1&&y1<=nfirstline+ROWS-3)
    ykur=(int)(y1-nfirstline+2);
  else
    for(i=1,ykur=2,brick1window=brickroot;i<y1;i++)
      brick1window=brick1window->down;
  lin1=lin=y1;col1=col=x1;
  FINDINDEX();
  while(BLOCKMARK) DELETESYMBOLEND(p);
  lin=lin1;col=col1;
  MOVEXWINDOW();
}
void INSERTBLOCK() {
  register int i;
  y1=y2=lin1;x2=(x1=col1)+1L;
  FINDINDEX();
  for(i=cutsize-1,indexcut1=indexcut;;) {
    if(i<0)
      {if((indexcut1=indexcut1->left)==NULL) break;
      i=BRICKCUTSIZE-1;}
    key=indexcut1->line[i--];
    if((key2=indexcut1->line[i--])&0x10)
      {WRITEENTER();index2->attr[k1]=key2&0xEF;c1=0L;}
    else {
      WRITEKEY(2);
      if(DIFFERENTFORM(index2->attr[k1],key2))
	index2->attr[k1]=key2|0x01;
    }
  }
  CORRECT(k1);
  x2--;
}
void main(n,nrf) int n;char*nrf[]; {
  register int i,j;
  for(i=0;i<BUFSIZE+COLS;i++) ATT(i)=COLFRAME;
  WRITETEXT(11*COLS+18,INFORM);
  if((rf=fopen(nrf[1],"rb"))==NULL) {
    WRITETEXT(12*COLS+18,"Usage: EDFOR <file_name>");
    puttext(1,1,COLS,ROWS,buf);BIOSKEY();
  }
  else {
    puttext(1,1,COLS,ROWS,buf);
    address=ADDRESSKEYS;
    STRIKEINS();
    WRITETEXT(1,nrf[1]);
    SYM(NLINCOL)=':';
    WRITETEXT(WHEREMENU,MENU);
    namefile=malloc(2000);
    for(i=0;nrf[1][i]!='\0'&&nrf[1][i]!='.';i++) namefile[i]=nrf[1][i];
    namefile[i  ]='.';namefile[i+1]='e';namefile[i+2]='d';
    namefile[i+3]='f';namefile[i+4]='\0';
    ALLOC();
    ALLOCCUT();indexcut->left=NULL;
    READFILE;
    fclose(rf);
    READFILEATTR;
    if(brickroot->attr[0]>=FORM)
      {index1=index2=brickroot;sign_p=1;SEARCHFREE(0);}
    for(;;) {
      xkur=(int)(col+1-xmove);nfirstline=lin-ykur+2L;
      if(sign_mark)
	{if(sign_mark1==0) {y1=y2=lin1;x1=x2=col1;}
	if(y1==lin1&&x1==col1) {y1=lin;x1=col;} else {y2=lin;x2=col;}
	if(y1>y2||x1>x2&&y1==y2) {REVERSE(y1,y2);REVERSE(x1,x2);}
	puttextrows=ROWS;}
      sign_mark1=sign_mark;sign_mark=0;
      if(puttextrows!=1) {WRITEBUF;}
      HEXSYM;
      WRITENUMBER1(NFILSIZ,filesize);
      WRITENUMBER1(NLINCOL-1,(lin1=lin));
      WRITENUMBER2(NLINCOL+1);col1=col;
      gotoxy(xkur,ykur);
      puttext(1,1,COLS,puttextrows,buf);puttextrows=1;
//    GETKEYS(key,i);
//    switch(i) {
      switch(i=BIOSKEY()) {
      case Esc:
	if(sign_mod)
	  {SUBMENUESC;PUTSUBMENUESC;
	  switch(BIOSKEY()) {
	  case F2:WRITEFILES(nrf[1],namefile);
	  case F9:return;
	  }
	  puttextrows=ROWS;continue;}
	return;
      case F2:
	  WRITEBLANK(WHEREMENUF2,9);
	  WRITEFILES(nrf[1],namefile);
	  puttextrows=ROWS;
	continue;
      case F3:
      B:SUBMENUSEARCH;
	if(xs>searchsize[ys]||xs==MAXSEARCHSIZE) xs--;
	k1=10+ys*(12+MAXSEARCHSIZE);
	gotoxy(XKURSEARCH+xs,YKURSEARCH+ys);
	PUTSUBMENUSEARCH;
//      GETKEYS(key,i);
//      switch(i) {
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
	  for(i=xs;i<searchsize[ys]-1;i++) search[k1+i]=search[k1+i+1];
	  search[k1+i]='_';
	  if(xs<searchsize[ys]) searchsize[ys]--;
	  goto B;
	case F3:case F4:case Enter:
	  sign_p=(i==F4||i==Enter&&ys);
	  while(SEARCH()&&sign_p) {
	    for(j=0;j<searchsize[0];j++) {FINDINDEX();DELETESYMBOL();}
	    FINDINDEX();
	    for(j=searchsize[1];j>0;)
	      {key=search[--j+22+MAXSEARCHSIZE];WRITEKEY(1);}
	    col+=searchsize[1];nfirstline=lin;
	  }
	case Esc:puttextrows=ROWS;continue;
	}
	if(key) {
	  if(xs==searchsize[ys]) searchsize[ys]++;
	  else if(sign_ins&&searchsize[ys]<MAXSEARCHSIZE)
	    for(i=searchsize[ys]++;i>xs;i--) search[k1+i]=search[k1+i-1];
	  search[k1+xs]=key;
	  xs++;
	}
	goto B;
      case F6:
	if((sign_form=!sign_form)==0) {
	  WRITEBLANK(WHEREMENUF7,22);
	  y2=y1;x2=x1;
	  FINDINDEX();
	  if(index2->attr[j=index2->size-((c1>0L)?(int)c1:0)]>=FORM)
	    {sign_p=1;SEARCHFREE(j);}
	}
	else WRITETEXT(WHEREMENUF7,MENUF7);
	puttextrows=ROWS;
	continue;
      case F7:
	MAKEFORM(FORM,FREE);
	continue;
      case F8:
	MAKEFORM(FREE,FORM);
	continue;
      case Shift_Tab:
	FINDINDEX();
	for(col=c1=c2=j=-1,index2=index1;;) {
	  col++;
	  if(j<index2->size-1) j++;
	  else if(j==index2->size-1)
	    if(index2->right==NULL) j++;
	    else {index2=index2->right;j=0;}
	  else if(c2>=0L) {col=c2;MOVEYWINDOW(1);MOVEXWINDOW();break;}
	  else if((index1=index2=index1->up)==NULL)
	    {lin=lin1;col=col1;SOUND();break;}
	  else {lin--;col=c1=c2=j=-1;continue;}
	  if(index2->attr[j]<FORM) c1=col;
	  else if((lin<lin1||col<=col1)&&c1>=0L) {c2=c1;c1=-1L;}
	}
	continue;
      case Tab:
	FINDINDEX();
	sign_p=(index2->attr[j=index2->size-((c1>0L)?(int)c1:0)]>=FORM);
	SEARCHFREE(j);
	continue;
      case Shift_End:sign_mark=1;
      case End:
	FINDINDEX();
	ENDOFLINE();
	MOVEXWINDOW();
	continue;
      case Shift_KDown:sign_mark=1;
      case KDown:
	FINDINDEX();
	DOWN(lin1);
	MOVEYWINDOW(1);MOVEXWINDOW();
	continue;
      case Shift_PgDn:sign_mark=1;
      case PgDn:
	FINDINDEX();
	DOWN(nfirstline+ROWS-3);
	MOVEYWINDOW(0);MOVEXWINDOW();
	continue;
      case Shift_KLeft:sign_mark=1;
      case KLeft:
	FINDINDEX();KURSORLEFT();MOVEXWINDOW();
	continue;
      case Shift_KRight:sign_mark=1;
      case KRight:
	FINDINDEX();KURSORRIGHT();MOVEXWINDOW();
	continue;
      case Shift_Home:sign_mark=1;
      case Home:
	FINDINDEX();
	if(sign_form) col=0L;
	else {
	  if(c1<0L) {col+=c1;c1=0L;}
	  for(j=index2->size-(int)c1,c1=0L;;)
	    if(j>0) {
	      c1++;
	      if(index2->attr[--j]<FORM)
		{col-=c1;
		if(c1>1L&&sign_mark) {col1=col+1L;sign_mark1=0;}
		c1=0L;}
	    }
	    else if(index2==index1) break;
	    else {index2=index2->left;j=index2->size;}
	}
	MOVEXWINDOW();
	continue;
      case Shift_KUp:sign_mark=1;
      case KUp:
	FINDINDEX();
	UP(lin1);
	MOVEYWINDOW(0);MOVEXWINDOW();
	continue;
      case Shift_PgUp:sign_mark=1;
      case PgUp:
	FINDINDEX();
	UP(nfirstline);
	MOVEYWINDOW(1);MOVEXWINDOW();
	continue;
      case Ctrl_PgUp:
	lin=nfirstline,col=-1L,
	index1=index2=brick1window;
	c1=index2->size+1;
	DOWN(0L);
	MOVEYWINDOW(1);MOVEXWINDOW();
	continue;
      case Ctrl_PgDn:
	lin=nfirstline;index1=brick1window;
	while(lin<nfirstline+ROWS-3&&lin<quanlines)
	  {lin++;index1=index1->down;}
	UP(quanlines+1L);
	MOVEYWINDOW(1);MOVEXWINDOW();
	continue;
      case Ctrl_Home:
	lin=1L,col=-1L,
	index1=index2=brickroot;
	c1=index2->size+1;
	DOWN(0L);
	MOVEYWINDOW(1);MOVEXWINDOW();
	continue;
      case Ctrl_End:
	index1=brick1window;
	while(index1->down!=NULL) index1=index1->down;
	lin=quanlines;
	UP(quanlines+1L);
	MOVEYWINDOW(1);MOVEXWINDOW();
	continue;
      case Ins:
	STRIKEINS();
	continue;
      case Backspace:
	FINDINDEX();KURSORLEFT();
	FINDINDEX();DELETESYMBOL();
	MOVEXWINDOW();
	continue;
      case Del:
	FINDINDEX();DELETESYMBOL();
	continue;
      case Enter:
	FINDINDEX();
	if(sign_form)
	  {WMOD();WRITEENTER();
	  xmove=col=0L;lin++;
	  index1=index1->down;
	  MOVEYWINDOW(1);}
	else
	  {ENDOFLINE();FINDINDEX();
	  sign_p=0;SEARCHFREE(index2->size-(int)c1);}
	continue;
      case Shift_Ins:
	if(cutsize) {WMOD();INSERTBLOCK();}
	continue;
      case Ctrl_Ins:
	if(BLOCKMARK) {DELETEBLOCK(1);INSERTBLOCK();puttextrows=ROWS;}
	continue;
      case Ctrl_Y:
	if(sign_form)
	  {col=0;FINDINDEX();
	  do {c3=filesize;DELETESYMBOLEND(0);} while(c3==filesize+1);
	  MOVEXWINDOW();WMOD();}
	continue;
      case Shift_Del:
      case Ctrl_Del:
	if(BLOCKMARK) {WMOD();DELETEBLOCK(i==Shift_Del);}
	continue;
      }
      if(key||i==F5)
	{FINDINDEX();WMOD();WRITEKEY(sign_ins);KURSORRIGHT();MOVEXWINDOW();}
    }
  }
}