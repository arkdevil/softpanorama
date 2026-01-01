
              /* микробиблиотека DOS-операций */

#define open(p,acc)     (_DX=(int)(p),\
_AL=(acc),_AH=0x3d,__int__(0x0021))
#define close(h)        (_BX=(h),_AH=0x3e,__int__(0x0021))
#define read(h,b,c)     (_BX=(h),_CX=(c),_DX=(int)(b),\
_AH=0x3f,__int__(0x0021))
#define write(h,b,c)    (_BX=(h),_CX=(c),_DX=(int)(b),\
_AH=0x40,__int__(0x0021))
#define lseek(h,c,d,a)  (_BX=(h),_CX=(c),_DX=(d), \
_AL=(a),_AH=0x42,__int__(0x0021))
#define makfil(p,atr)   (_CX=(atr),_DX=(int)(p),\
_AH=0x3c,__int__(0x0021))
#define renfil(o,n)     (_DX=(int)(o),_DI=(int)(n),\
_AH=0x56,__int__(0x0021))
#define delfil(p)       (_DX=(int)(p),_AH=0x41,__int__(0x0021))
#define getfilatr(p,a)  (_CX=(a),_DX=(int)(p),\
_AX=0x4300,__int__(0x0021))
#define setfilatr(p,a)  (_CX=(a),_DX=(int)(p),\
_AX=0x4301,__int__(0x0021))
#define getblok(para)   (_BX=(para),_AH=0x48,__int__(0x0021))
#define freeblok(seg)   (_ES=(seg),_AH=0x49,__int__(0x0021))
#define modblok(s,p)    (_BX=(p),_ES=(seg),\
_AH=0x4a,__int__(0x0021))
#define exit(code)      (_AL=(code),_AH=0x4c,__int__(0x0021))
#define getret()        (_AH=0x4d,__int__(0x0021))
#define tsr(p,c)        (_DX=(p),_AL=(c),_AH=0x31,__int__(0x0021))

#define getch()         (_AH=0x07,__int__(0x0021),_AH=0)
#define getchb()        (_AH=0x08,__int__(0x0021),_AH=0)
#define getcch()        (_AX=0x0c08,__int__(0x0021),_AH=0)
#define kbhit()         (_AH=0x0b,__int__(0x0021))
#define dispstr(str)    (_DX=(int)(str),_AH=0x09,__int__(0x0021))

#define setmode(m)     (_AL=(m),\
_AH=0x00,__int__(0x0010))
#define setcolor(c)    (_BH=0,_BL=(c),\
_AH=0x0b,__int__(0x0010))
#define setpalet(p)    (_BH=1,_BL=(p),\
_AH=0x0b,__int__(0x0010))
#define getcur(p)      (_BH=(p),\
_AH=0x03,__int__(0x0010))
#define setcur(c,r,p)  (_DH=(r),_DL=(c),_BH=(p),\
_AH=0x02,__int__(0x0010),prn(56,0,curx))
#define scrollup(c1,r1,c2,r2,n,atr)  ( \
_CH=(r1),_CL=(c1),_DH=(r2),_DL=(c2), _BH=(atr),\
_AL=(n),_AH=0x06,__int__(0x0010))
#define scrolldn(c1,r1,c2,r2,n,atr)  ( \
_CH=(r1),_CL=(c1),_DH=(r2),_DL=(c2), _BH=(atr),\
_AL=(n),_AH=0x07,__int__(0x0010))
#define puttty(c,p,atr)  (_BL=(atr),_BH=(p), \
_AL=(c),_AH=0x0e,__int__(0x0010))
#define setpage(p)      (_AL=(p),\
_AH=0x05,__int__(0x0010))

/*
  ************************************************************

             Фрагмент оконного интерфейса UP_MENU
                    адаптация с Шилдта Обухов Л.И. 5.10.1990.

    Программа исчезающих меню для текстового режима
    с использованием прямого доступа к видео памяти

    Руководство к использованию:
    для обращения в своей программе к
    оконному стандартному интерфейсу достаточна
    команда вида

    up_menu(help, 6, 3,11,13,18, 0x0e1f,memp0);

    u p _ m e n u  - команда выводит окно с рамкой на экран
    с координатами углов 3,11,13,18 и ждет нажатия на любую
    клавишу
    6 - число строк внутри будущей рамки 

     Параметры:
      help  - меню вида
      char *help[] = {
                      "Яблоко",
                      "Апельсин",
                      "Груша",
                      "гРейпфрут",
                      "Малина",
                      "Клубника"
                     };

      0x0e1f - 4 шестнадцатеричные цифры для цвета фона и текста
       рамки и внутренности окна  

          0 - черный фон рамки
          e - ярко желтые линии рамки
          1 - синий фон окна
          f - белый цвет текста в окне

      memp0 - рабочий указатель на область сохранения
       подложки, желательно для каждого окна свой, обьявляется
       как   unsigned char memp0[500]; (для трех строк)
       размерность равна удвоенному обьему окна.
*/

/********************************************************/

#define HORIZ  1
#define VERT   0
#define ADR_VIDEO  ((char far *)(0xB8000000L))
char far *video_ptr;

/********************************************************/
/* запись символа с определенным аттрибутом */
void write_char(int x,int y,char ch,int attrib){
  char far *v;
  v=video_ptr;
  v += (y*160) +x*2;
  *v++ = ch;         /* запись символа */
  *v = (char)attrib; /* запись атрибута */
 }

/********************************************************/
/* вывод строки с определенным атрибутом */
void write_string(int x,int y,char *p,int attrib){
  char far *v;
  int i;
  v=video_ptr;
  v += (y*160) + x*2;
  for(i=x; *p; i++) {
   *v++ =*p++;         /* запись символа */
   *v++ =(char)attrib; /* запись атрибута */
  }
 }

/********************************************************/
/* сохранение части экрана с использованием
   прямого доступа к видео памяти */
void save_video(int startx,int starty,int endx,int endy,
      int atrclear,unsigned char *buf_ptr ){  
  int i,j;
  char far *t;
 
  for(i=startx;i<=endx;i++)
   for(j=starty;j<=endy;j++) {
    t = video_ptr + (j*160) + i*2;       /* вычисляем адрес */
    *buf_ptr++ = *t; *t++ = ' ';         /* чтение символа */
    *buf_ptr++ = *t; *t = (char)atrclear;/* чтение атрибута */
   }
 }

/********************************************************/
/* восстановление части экрана с использованием
        прямого доступа к видео памяти */
void close_menu(int startx,int starty,int endx,int endy,
       unsigned char *buf_ptr){
  int i,j;
  char far *t,far *v;
  v=video_ptr;
  t=v;
  for(i=startx;i<=endx;i++)
   for(j=starty;j<=endy;j++) {
    v = t;
    v += (j*160) + i*2;   /* вычисляем адрес */
    *v++ = *buf_ptr++;    /* запись символа */
    *v   = *buf_ptr++;      /* запись атрибута */
   }
 }

/********************************************************/
/* вывести рамку */
void draw_border(int startx,int starty,
                 int endx,int endy,int atr,
                 int blanks){
  int i;
  char far *t, far *v;
  v=video_ptr;

  t=v;
  for(i=starty+1;i<endy;i++) {
   v += (i*160) + startx*2;
   if(blanks) *v++ = ' '; else *v++ = '║';
   *v = (char)atr;
   v=t;
   v += (i*160) + endx*2;
   if(blanks) *v++ = ' '; else *v++ = '║';
   *v = (char)atr;
   v=t;
  }

  for(i=startx+1;i<endx;i++) {
   v += (starty*160) + i*2;
   if(blanks) *v++ = ' '; else *v++ = '═';
   *v = (char)atr;
   v=t;
   v += (endy*160) + i*2;
   if(blanks) *v++ = ' '; else *v++ = '═';
   *v = (char)atr;
   v=t;
  }
 
  if(blanks) write_char(startx,starty,' ',atr);
  else  write_char(startx,starty,'╔',atr);
  if(blanks) write_char(endx,starty,' ',atr);
  else  write_char(endx,starty,'╗',atr);
  if(blanks) write_char(startx,endy,' ',atr);
  else  write_char(startx,endy,'╚',atr);
  if(blanks) write_char(endx,endy,' ',atr);
  else  write_char(endx,endy,'╝',atr);
 }

/********************************************************/
/* вывести исчезающее окно */
void up_menu0(
  char *menu[],  /* текст меню */
  int count,
  int x0,int y0, /* координаты левого верхнего угла */
  int x1,int y1, /* координаты правого нижнего угла */
  int atr,
  unsigned char *pm){
  int j;

  save_video(x0-3,y0-1,x1+3,y1+1,atr,pm);
  draw_border(x0-1,y0-1,x1+1,y1+1,atr>>8,1);
  draw_border(x0-2,y0-1,x1+2,y1+1,atr>>8,1);
  draw_border(x0-3,y0-1,x1+3,y1+1,atr>>8,1);
  draw_border(x0,y0,x1,y1,atr>>8,0);
  for(j=0;j<count;j++) write_string(x0+1,y0+1+j,menu[j],atr);
 }

int up_menu(char *menu[],int count,int x0,int y0,int x1,int y1,
        int atr, unsigned char *pm){
  int j;
  up_menu0(menu,count,x0,y0,x1,y1,atr,pm);
  getch();j=_AL;if(j==0){getch();}
  close_menu(x0-3,y0-1,x1+3,y1+1,pm);
  if(j==27)return(-1); else return(0);
 }

/*
 *****************************************************
                      STRTAKE
                          copyright Obuhov L. 22.10.90

  программа из группы обработки строк;
  строка выводится на экран и заполнить ее предоставляется
  пользователю,вывод в цвете с текущими атрибутами;
  если сразу нажато Enter, то умолчание строки становится
  ответом,
  в других ситуациях пользователь заполняет строку символами
  в режиме END+SYM,
  ограничителем заполнения справа является край строки,
  при этом работает BackSpace для удаления элементов;
  Enter заканчивает заполнение строки;
  значение функции strtake = 0 было нажато Enter,
                           =-1 было нажато Esc.
 *****************************************************
*/

int strtake(char *str,int x0,int y0,int atr,int num){
  int i=0,j,k=1,x00;
  x00=x0;
  write_string(x0,y0,str,atr); setcur(x0,y0,0);
  getch();k=_AL;if(k==0){getch();k=_AL+256;}
  if(k!=13 && k!=27){
    for(j=0;j<num-1;j++){*(str+j)=' ';}  *(str+j)=0;
    write_string(x0,y0,str,atr);
  }
  while(k!=13){
   switch(k){
     case 8: if(x00<x0){
       *(str+(--i))=' ';
       write_char(--x0,y0,' ',atr); setcur(x0,y0,0);
     } break;
     case 27:return -1;
     default: if(k<256 && *(str+i)!=0){
       *(str+(i++))=k;
       write_char(x0++,y0,k,atr); setcur(x0,y0,0);
     }
   }
   getch();k=_AL;if(k==0){getch();k=_AL+256;}
   if(k==13) *(str+i)=0;
  }/*while*/
  return 0;
 }

int up_menu_get(char *str,char *menu[],int count,
        int x0,int y0,int x1,int y1,
        int atr, unsigned char *pm){
  int j;
  up_menu0(menu,count,x0,y0,x1,y1,atr,pm);
  j=strtake(str,x0+2,y0+2,0x30,x1-x0-3);
  close_menu(x0-3,y0-1,x1+3,y1+1,pm);
  return(j);
 }
 
