/*

                         М Е Т А 
                                           версия 1.3  1.12.90

           meta -  простой текстовый редактор
                                           длина 12210 байт

*/
#define c80 80        /* ширина окна */
#define c25 24        /* нижний край окна */
#define c0   1        /* верхний край окна */
#define MAXFILE 33000 /* максимальный размер файла */
#define MAXBUF 50000U /* допустимый размер буфера */
#define NL      0     /* образ '\n' на экране */
#define MAXJ    64    /* длина строки для justify */
#define disable() __cli__() /* запретить прерывания */
#define enable()  __sti__() /* разрешить прерывания */

         /* глобальные переменные */

int yylval;           /* значение принятого символа в yyparse */
int curx=0;           /* указатели курсора на экране */
int cury=c0;
int oldx0=0;          /* положение курсора для up и down,
  использование oldx0: при большинстве операций курсор
  по возможности устанавливается по глобальному значению oldx0
  (по горизонтали), единственные операции, которые изменяют
  это значение - пользовательские команды - 
  Left1,Right1,Home1,End1,Sym,BackSp и Del
                      */
char *oldcurp;
char *buf;            /* буфер текста */
char *endbuf;         /* указатель конца буфера buf */
char *curpage;        /* указатель страницы в буфере buf */
char *curptr;         /* указатель курсора в буфере buf */
unsigned mfl=MAXFILE; /* длина файла */
int fileh;            /* внутренний номер файла*/
int insflag=0;        /* переключение режимов вставка/перекрытие */
char file_path[32];   /* вместилище для имени файла */
char atr0=0x1b;       /* цвет фона и основного текста*/
char atr1=0x30;       /* цвет для верхнего бара */
char atr2=0x30;       /* цвет для нижнего бара */
                /* сами бары */
char *bar1="Edit:                                  *  Line 28\
    Col 10                 *** ";
char *bar2=" 1 Help  2 Save  3 Back  4 Room  5 C\
opy  6 Move  7 Find  8 Delet 9 Mark 10 Qsave";

char *msg1[]={ " ","           Fail in open file !"," "};
char *msg2[]={ " ","            Read error file !"," "};
char *msg3[]={ " ","      Too long string ! Fatal end !"," "};
char *msg5[]={ " ","           Not enough memory !"," "};
char *msg6[]={ " ","           File is too large !"," "};
char *msg7[]={
   "                                                        ",
   "      ^y -  delete line       ^t -  clear line to end     ",
   "      ^f -  for(;;){}         ^w -  while(){}             ",
   "      ^s -  switch()...       ^r -  justify line          ",
   "      ^d -  auto-wordwrap  with  auto-justify             ",
   "      ^PgDn - swap line down  ^PgUp - swap line up        ",
   "      |<-Left = Mark_block    |<-Home = Copy_block        ",
   "                                                        ",
 };
char *msg8[]={ " Search for the string "," " };
char *msg9[]={ "        Could not find the string" };
char *msge[]={ "         text-editor M E T A           ",
               "   Copyright Obuhov & Mironov 8.12.90  ",
               "    meta <edit_file> [pos_for_error]   ",
               "                     "};
char *msgs[]={ " You've made changes since the last save. ",
               "   Enter-Save  Esc-Change will be lost    "};
char *tmp;

char *begin_block_ptr=0;/* ук.начала блока */
char *end_block_ptr=0;  /* ук.конца блока  */
char atr_block=0x2b;    /* цвет для блоков */
                        /* буфер для образца поиска */
char *reply="                                       ";
         /* для indenting*/
char *blanks="                               \
                                                  ";
int indent=1; /* автоотступ при разрыве строки */
int wrap=0;   /* авто перенос слов за 64 позицией */
int wrapflag=0;
int change_flag=0;    /* были ли изменения от пользователя? */
char *room_curpage=0; /* указатель позиции для возвратов back/room */
char ballast[50];

         /* образцы для авто генерации конструкций */
         /* для templating */

char *pat_f="for(;;){}";
#define pat_fe pat_f+9

char *pat_w="while(){}";
#define pat_we pat_w+9

char *pat_s="  switch(){\r\n    \
case ():{}\r\n    \
default: {}\r\n  }\r\n";
#define pat_se pat_s+51

                     /* прототипы */
void __int__(int intr);
void __cli__(void);
void __sti__(void);
void home();
int end0();
int up();
int down();
void pgdn();
void pgup();
int up1();
int down1();
void mark_block();
int copy_block();
void prn(int x,int y,int num);
int justify();
int sym();

#include "meta1.c"   /* обеспечение вывода сообщений в рамке */


/* смещение содержимого окна вниз*/
/*
void scrolldn(){
  _AH=0x07; _CL=0;_CH=c0;_DL=c80-1;_DH=c25-1;
  _AL=1;_BH=0x1b; __int__(0x10);
 }
*/
/* смещение содержимого окна вверх*/
/* 
void scrollup(){
  _AH=0x06; _CL=0;_CH=c0;_DL=c80-1;_DH=c25-1;
  _AL=1;_BH=0x1b; __int__(0x10);
 }
*/

/* выдача трехзначных чисел на экран по позиции */
void prn(int x,int y,int num){
             *(video_ptr+160*y+2*(x+2))=num%10+'0'; num/=10;
  if(num!=0){*(video_ptr+160*y+2*(x+1))=num%10+'0'; num/=10;}
  else       *(video_ptr+160*y+2*(x+1))=' ';
  if(num!=0){*(video_ptr+160*y+2*(x+0))=num%10+'0';         }
  else       *(video_ptr+160*y+2*(x+0))=' ';
 }

/* выдача на экран текущего номера номера строки */
void set_nline(){
  int i;char *p;
  for(p=buf,i=0;p<curptr;p++){
    if(*p=='\n')i++;
  }
  prn(47,0,i+1);
 }

/* вывод верхней полоски бара и нижней */ 
void set_bars(){
  int i;
  for(i=0;i<c80;i++){
    *(video_ptr+i*2)=*(bar1+i);
    *(video_ptr+i*2+1)=atr1;
    *(video_ptr+24*c80*2+i*2)=*(bar2+i);
    *(video_ptr+24*c80*2+i*2+1)=atr2;
  }
  for(i=0;i<10;i++){
    *(video_ptr+24*c80*2+i*2*8+1)=0x07;
    *(video_ptr+24*c80*2+i*2*8+3)=0x07;
  }
  for(i=0;i<32;i++){
    if(file_path[i]==0) break;
    *(video_ptr+6*2+i*2)=file_path[i];
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^^F1 */
void help(){
  up_menu(msg7, 8, 10,5,69,5+8+1, 0x3030,tmp);
 }
 
/* 
  позаботиться об изменении begin/end_block_ptr
  при вставке/удалении символов и блоков надо также
  корректировать указатели меток блока и собственной 
  страницы room-curpage
*/
void correct_mark(int sh){
  if(curptr<begin_block_ptr){
    begin_block_ptr+=sh;
    end_block_ptr+=sh;
  }
  if(curptr<room_curpage){
    room_curpage+=sh;
  }
 }

/* продвинуть на одну строку вперед ptr в буфере текста */
/* значение 0/1 - удача/неудача */
/*
   ориентиром для начала следующей строки берется символ
   конца текущей строки, возможны случаи:
   1. у текущей строки нет символов конца, то есть она
      упирается в нижний конец текста - endbuf
   2. следующая строка минимальна, тогда указатель станет
      на '\r', но этот символ у нас считается неотображаемым
      на экран, поэтому указатель надо пододвинуть правее
*/
int next(char **ptr){
 int i;
  for(i=0;i<c80;i++){
    if((*ptr)+i == endbuf+1 ){ *ptr+=i;return(1); }
    if( *((*ptr)+i) == '\n' ) {
      *ptr+=(i+1);
      if(**ptr=='\r') (*ptr)++;
      return(0);
    }
  }
  atr0=0x0c;
  up_menu(msg3,3,17,8,59,12,0x4f4f,tmp);exit(0);
 }

/* продвинуть на одну строку назад ptr в буфере текста */
/* значение 0/1 - удача/неудача */
/*
   в качестве ориентира для начала предыдущей строки берется
   символ конца передпредыдущей строки, однако
   здесь необходимо отследить случаи:

   1. предыдущая строка минимальная
   2. текущая строка минимальная
   3. обе строки минимальные
   4. предыдущая строка не ограничивается слева '\n',
       то есть упирается в начало буфера, первая
   5. текущая строка минимальная, предыдущая - первая
   6. текущая строка минимальная,предыдущая первая и также
       минимальная
*/
int prev(char **ptr){
 int i;
  if(**ptr=='\n') *ptr-=1;
  if(*ptr==buf){ return(1);}
  for(i=2;i<c80+2;i++){
    if((*ptr)-i == buf){
      if(*buf == '\r' ) { *ptr=buf+1;return(0); }
      else {*ptr=buf;return(0);}
    }
    if(*((*ptr)-i) == '\n' ) {
      *ptr-=(i-1);
      if(**ptr=='\r') (*ptr)++;
      return(0);
    }
  }
  atr0=0x0c;
  up_menu(msg3,3,17,8,59,12,0x4f4f,tmp);exit(0);
 }

/* очистка экрана скроллингом */
void clear_screen(int atr){
  _AH=0x07; _CL=0;_CH=c0;_DL=c80-1;_DH=c25-1;
  _AL=0;_BH=atr; __int__(0x10);
 }

/* вывести по curpage на экран информацию */
int toscr(){
  int i,j,k;char *old;
  clear_screen(atr0);
  setcur(curx,cury,0);
  k=0; /* ук. на экране относительно строки  */
  i=0; /* ук. в буфере текста buf относительно curpage */
  j=c0; /* номер строки */
  disable();
  for(;;){
    if( curpage+i >= endbuf ) return(1);
    /* подсветить блок на экране */
    if(begin_block_ptr!=0 && end_block_ptr!=0){
      if(curpage+i>=begin_block_ptr &&
           curpage+i<end_block_ptr ){
        *(video_ptr+j*c80*2+k*2+1)=atr_block;
      }
    }
    switch(*(curpage+i)){
      case '\n': {
        *(video_ptr+j*c80*2+k*2)=NL; /* вместо '\n'*/
        i++;
        k=0;
        j++;
        if(j>c25-1){enable(); return(0);}
        break;
      }
      case '\r':
        i++; break;
      default:   {
        if(k<c80) *(video_ptr+j*c80*2+k*2)=*(curpage+i);
        else{ 
          atr0=0x0c;
          up_menu(msg3,3,17,8,59,12,0x4f4f,tmp);exit(0);
        }
        i++;
        k++; 
      }
    }/*switch*/
  }/*for*/
 }

/*
   проверка длины текущей строки после сцепления - 0/1 -
   означает нормальная/длинная, >c80-1 символов
*/
int test_leng(char *dp){
  char *p,*p0;
  p=dp;
  if(*p=='\n') p++;
  p0=p; prev(&p0);
  next(&p);
  if(*p=='\n') p++;
  if(p-p0>c80+2) return(1);
  else return(0);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^^^ */
/* завершение */
void trailer(){
   clear_screen(0x07);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^^^F2 */
/* закрытие файлов по запросу и флагу изменений 
   если не было изменений, то можно даже не запрашивать 
   пользователя о сохранении */
void save(){

  if(change_flag==1)
  if(up_menu(msgs,2,17,8,60,8+2+1,0x4f4f,tmp)!=-1){
  
    delfil(file_path);      /* наш файл удаляется */
    makfil(file_path,0);    /* создается новый файл с тем же именем*/
    open(file_path,1);fileh=_AX; /* и он открывается на запись */
    if( fileh == -1 ){      /* проверить успешно ли открыт файл */
     up_menu(msg1,3,17,8,59,12,0x4f4f,tmp);
     exit(0);
    }

    write(fileh,buf,(unsigned)(endbuf-buf));
    close(fileh);
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^PgDn^^ */
/* на страницу вниз*/
void pgdn1(){
  int i;
  /* если cury не 23, то лишь опустить курсор */
  if(cury<c25-1 && cury!=c0+(c25-c0)/2 ){
    for(i=0;i<c25-1;i++)down();
    set_nline();
    return ;
  }
  else pgdn();
  set_nline();
 }
void pgdn(){
  int i;
  oldcurp=curpage;
  for(i=0;i<c25;i++){
    if(next(&curpage)){ 
      curpage=oldcurp; break; 
    }
  }
  /* 
     при листании для удобства располагаем курсор 
     посредине страницы 
  */
  if(curpage!=oldcurp){ 
    curx=0;cury=c0;curptr=curpage;
    for(i=0;i<(c25-c0)/2;i++)down();
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^PgUp^^ */
/* на страницу вверх*/
void pgup1(){
  int i;
  /* если cury не c0, то лишь поднять курсор */
  if(cury>c0 && cury!=c0+(c25-c0)/2){
    for(i=0;i<c25-1;i++)up();
    set_nline();
    return ;
  }
  else pgup();
  set_nline();
 }
void pgup(){
  int i;
  for(i=0;i<c25;i++){
    if(prev(&curpage)) break;
  }
  curx=0;cury=c0;curptr=curpage;
  for(i=0;i<(c25-c0)/2;i++)down();
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^End */
/* в конец файла 
   чтобы достичь последней страницы мы просто листаем весь
   файл до последней страницы вхолостую. Может быть,
   казалось бы, лучше зная end_buf отсчитать последнюю
   страницы от концы, однако при это нарушится вид последней
   неполной страницы
*/
void to_end_file(){
  pgdn();
  while(curpage!=oldcurp) pgdn();
  set_nline();
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^Home */
/* в начало файла */
void to_begin_file(){
  while(curpage!=buf && curpage!=buf+1) pgup();
  set_nline();
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^^ ^y */
/* удаление строки  */
int del_line(){
  char *ptr,*p,*q;
  change_flag=1;
  if(curptr>=begin_block_ptr && curptr<=end_block_ptr)return(0);
  if(curptr<endbuf+1){
   home();
   ptr=curptr;
   if(next(&ptr)) return(0);
   if(*curptr=='\n') curptr--;
   if(*ptr=='\n') ptr--;
   for(p=curptr,q=ptr;q!=endbuf;p++,q++) *p=*q;
   endbuf-=(ptr-curptr);
  }
  correct_mark(-(ptr-curptr));
  if(*curptr=='\r') curptr++;
  if(cury==c0 && curx==0) curpage=curptr;
  set_nline();
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^PgDn */
/* протягивание строки вниз по курсору на экране */
int swap_down(){
  int i,ox;
  char *ptr,*ptr1,*p,*q; char buftmp[160];
  change_flag=1;
   /* поменять местами строки в тексте */
  if(cury!=c25-1 && curptr<endbuf+1){
        /* блок предусловий защит */
   ox=curx;home();
   ptr=curptr;
   if(next(&ptr)) 
     return(1);
   ptr1=ptr;
   if(next(&ptr1))
     return(1);
   if(begin_block_ptr>=curptr && begin_block_ptr<=ptr1)
     return(1);
   if(end_block_ptr>=curptr && end_block_ptr<=ptr1)
     return(1);

   if(*curptr=='\n') curptr--;
   if(*ptr=='\n') ptr--;
   if(*ptr1=='\n') ptr1--;
   for(p=curptr,q=buftmp;p<ptr;p++,q++) *q=*p;
   for(p=curptr,q=ptr;q<ptr1;p++,q++) *p=*q;
   for(p=curptr+(ptr1-ptr),q=buftmp;p<ptr1;p++,q++) *p=*q;
   if(*curptr=='\r') curptr++;
   down();
   for(i=0;i<ox;i++) right();
   set_nline();
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^PgUp */
/* протягивание строки вверх по курсору на экране */
int swap_up(){
  int i,ox;
  char *ptr,*ptr1,*p,*q; char buftmp[160];
   /* поменять местами строки в тексте */
  change_flag=1;
  if(cury!=c0 && curptr<endbuf+1){
        /* блок предусловий защит */
   ox=curx;up();
   home();
   ptr=curptr;
   if(next(&ptr)){
     down();return(1);}
   ptr1=ptr;
   if(next(&ptr1)){
     down();return(1);}
   if(*curptr=='\n') curptr--;
   if(*ptr=='\n') ptr--;
   if(*ptr1=='\n') ptr1--;
   if(begin_block_ptr>=curptr && begin_block_ptr<=ptr1){
     down();return(1);}
   if(end_block_ptr>=curptr && end_block_ptr<=ptr1){
     down();return(1);}

   for(p=curptr,q=buftmp;p<ptr;p++,q++) *q=*p;
   for(p=curptr,q=ptr;q<ptr1;p++,q++) *p=*q;
   for(p=curptr+(ptr1-ptr),q=buftmp;p<ptr1;p++,q++) *p=*q;
   if(*curptr=='\r') curptr++;
   for(i=0;i<ox;i++) right();
   set_nline();
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^t */
/* очистка строки справа от курсора */
void clear_right(){
  yylval='\r';sym(); /* имитация вставки символа разрыва строки */
  del_line();up();end0();
 }

/* 
   в процедурах работы с курсором и символами мы придерживаемся
   следующего правила: вывод на экран toscr и вывод курсора setcur
   откладываются до самой последней минуты (милисекунды) 
   для того, чтобы оптимизировать эти же процедуры при исполь-
   зовании их в качестве подпрограмм в других процедурах
*/
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Left */
/* курсор влево  0/1 - удачно/неудачно */
int left1(){
  if(curx==0){ mark_block(); toscr();}
  else left();
  oldx0=curx;
 }
int left(){
  if(curx!=0 && curptr!=buf) {
    curx--;
    curptr--;if(*curptr=='\r')curptr--;
    return(0);
  }
  else return(1);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Right */
/* курсор вправо 0/1 - удачно/неудачно */
int right1(){
  right();
  oldx0=curx;
 }
int right(){
  if(curx+1!=c80 && curptr<endbuf && *curptr!='\n') {
    curptr++;
    if(*curptr=='\r' && curptr<endbuf)curptr++;
    curx++;
    return(0);
  }
  else return(1);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Up */
/* курсор вертикально вверх*/
int up1(){
  int i;
  /* 
     если cury==c0, то работает как 
     прокрутка на одну строку
  */
  if(cury==c0){
   prev(&curpage);
   curx=0;cury=c0;curptr=curpage;
          /* отступить на столько же сколько было */
   for(i=0;i<oldx0;i++){ if(right()) break; }
   toscr();
   set_nline();
   return(0); 
  }
  else up();
  set_nline();
 }

int up(){
  int i;
  if( cury>c0 ){
    home();              /* подогнать к началу строки */
    prev(&curptr);
    cury--;              /* к началу предыдущей строки */
          /* отступить на столько же сколько было */
    for(i=0;i<oldx0;i++){ if(right()) break; }
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Down */
/* курсор вертикально вниз */
int down1(){
  int i;
  /* 
     если cury==c25-1, то работает как scr_down 
     прокрутка на одну строку
  */
  if(cury==c25-1){
    next(&curpage);
    curx=0;cury=c0;curptr=curpage;
    for(i=c0;i<c25-1;i++)down();
    toscr(); 
    set_nline();
    return(0);
  }
  else down();
  set_nline();
 }

int down(){
  int i,j,curold,oldx,oldy; char *old;

  oldx=curx;oldy=cury;old=curptr;
  if( cury<c25-1 ){ /* подогнать к концу строки */
    end0();
    curx=0;         /* перейти на следующую строку */
    cury++;
    if(curptr>endbuf){curx=oldx;cury=oldy;curptr=old;return(1);}
    curptr++;
    if(curptr>endbuf){curx=oldx;cury=oldy;curptr=old;return(1);}
    if(*curptr=='\r' && curptr<endbuf) curptr++;
          /* отступить на столько же сколько было */
    for(i=0;i<oldx0;i++){ if(right()) break; }
    return(0);
  }
  else return(1);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Home */
/* курсор в начало строки */
void home1(){
  if(curx==0) { copy_block();toscr();}
  else home();
  oldx0=0;
 }
void home(){
  while(curx!=0 && curptr!=buf ) left();
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ End */
/* курсор в конец строки */
int end1(){
  end0();
  oldx0=curx;
 }
int end0(){
  int i;i=0;
  while(curx!=c80-1 && curptr<endbuf+1 && *curptr!='\n' && 
         i==0) i=right();
  return(i);
 }

/*
   backsp и del сходны между собой и сходны их структуры,
   разбираются два основных случая:
   1. не левый край строки
   2. левый край строки - curx==0
   в первом случае нужно произвести два основных действия
     подтянуть текст на один или два символа и
     подтянуть строку на экране, если при этом строки должны
     слипнуться, то вместо подтягивания их на экране просто
     весь экран обновляется имея в виду известное положение
     curptr
*/
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ BackSpace */
/* удалить символ слева */
int backsp(){
  char *p;
  int i;
  change_flag=1;
  if(curptr>=begin_block_ptr && curptr<=end_block_ptr+1)return(0);
  if(insflag==1 && curx!=0 ){
    if(*curptr=='\n')curptr--;  /* учесть правый край строки*/

    for(p=curptr;p!=endbuf;p++) {*(p-1)=*p;}
    if(endbuf>=buf+1) endbuf-=1;

    correct_mark(-1);
    curptr--;
    if(*curptr=='\r')curptr++;  /* учесть правый край строки*/
    
    *(video_ptr+(c80-1)*2)=' '; /* середина строки */
    for(i=curx;i!=c80-1;i++){
      *(video_ptr+cury*c80*2+i*2-2)=*(video_ptr+cury*c80*2+i*2);
    }
    curx--;
    oldx0=curx;
  }
  else if(insflag==1 && cury!=c0 ){ /*curx==0 левый край строки */
    if(test_leng(curptr))return(1);
    up();end1(); curptr--;
    for(p=curptr;p!=endbuf-2;p++){*p=*(p+2);}
    if(endbuf>=buf+2) endbuf-=2;

    correct_mark(-2);
    set_nline();
    toscr();
  }
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Del */
/* удалить символ справа */
int del(){
  char *p;
  int i;
  change_flag=1;
  if(curptr>=begin_block_ptr-1 && curptr<=end_block_ptr)return(0);

  /* середина строки */
  if(insflag==1 && *curptr!='\n' && *curptr!='\r'
        && curptr<endbuf){

    for(p=curptr;p<endbuf-1;p++){*p=*(p+1);}
    if(endbuf>=buf+1) endbuf-=1;

    correct_mark(-1);
    if(*curptr=='\r') curptr++;
    
    *(video_ptr+(c80-1)*2)=' ';
    for(i=curx;i<c80-1;i++){
      *(video_ptr+cury*c80*2+i*2)=*(video_ptr+cury*c80*2+i*2+2);
    }
  }
  /*curptr=='\n' правый край строки*/
  else if(insflag==1 && (*curptr=='\n' || *curptr=='\r')
           && curptr<endbuf){ 
  
    if(test_leng(curptr)) return(1);
    if(*curptr!='\r')curptr--;
    for(p=curptr;p<endbuf-2;p++){*p=*(p+2);} 
    if(endbuf>=buf+2) endbuf-=2;

    correct_mark(-2);
    if(*curptr=='\r')curptr++;  /* учесть минимальность сл.строки */
    if(cury==c0 && curx==0) curpage=curptr;
    set_nline();
    toscr();
  }
  oldx0=curx;
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ Ins */
/* переключить режим вставки/перекрытия */
void ins(){
  insflag=1-insflag;
  if(insflag) write_string(65,0,"ins",0x30);
  else write_string(65,0,"   ",0x30);
 }

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ ^d */
/* переключить режим автопереноса */
void switch_wrap(){
  wrap=1-wrap;
  if(wrap) write_string(60,0,"wrap",0x30);
  else write_string(60,0,"    ",0x30);
 }

/* 
   сначала символ вставляется в тексте, возможно с его 
   сдвигом вправо, затем он вставляется в строку на экране,
   тоже возможно со сдвигом вправо 
*/
/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^назначена на клавишу^^ <sym> */
/* вставка символов */
int sym(){
  int i,j,oldx,oldy;
  char tmp,zzz,*p,*oldcr;
  change_flag=1;
  if(curptr>=begin_block_ptr && curptr<=end_block_ptr)return(0);

  /* режим вставки с перекрытием */
  if(insflag==0 && yylval!='\r'){
    if(curx!=c80-1 && curptr!=endbuf && *curptr!='\n') {

      /* перекрыть символ в тексте по curptr */
      *curptr = yylval;

      /* то же самое сделать в строке на экране */
      *(video_ptr+cury*c80*2+curx*2) = yylval;
      right1();

    }
  }
  /* режим вставки со вставкой */
  else{
    wrapflag=0;
    if(curx<c80-2) {
    
      /* если нажато ENTER,CR */
      if(cury!=c25-1 && yylval=='\r'){
        if(*curptr=='\n')curptr--;/* иначе вставка разорвет */
        for(p=endbuf+2;p!=curptr+1;p--) *p=*(p-2); endbuf+=2;

        correct_mark(2);
        *curptr++ = '\r'; *curptr = '\n';
        home(); p=curptr;
        down();home();
        /* ======= indenting =======*/
        if(indent){
          for(i=0;*(p+i)==' ';i++);
          copy_b(blanks,blanks+i,&curptr);
          for(j=0;j<i;j++)right1();
        }
        /* =========================*/
        set_nline();
        return(0);
      }
      else if(yylval=='\r'){ return(1) ;}

      for(p=curptr;*p!='\n' && p<endbuf+1;p++);
      if(p-(curptr-curx)>78) return(0);
      
      /* то же самое сделать с остатком строки на экране */
      if(wrap && yylval==' ' && curx==MAXJ){
        yylval='\r';sym();
        up(); justify(); down();
        if(cury==c25-1){
          next(&curpage);
          curx=0;cury=c0;curptr=curpage;
          for(i=c0;i<c25-2;i++)down();
        }
        end0();
        toscr();return(0);
      }
      tmp=*(video_ptr+cury*c80*2+curx*2);
      wrapflag=0;
      for(i=1;i<c80;i++){
        zzz=*(video_ptr+cury*c80*2+curx*2+i*2); /* swap */
        if(curx+i>=MAXJ) wrapflag=1;
        if(zzz==NL && curx+i>=(c80-2)) {toscr();return(0);}
        if(curx+i>=(c80-1)) break;
        *(video_ptr+cury*c80*2+curx*2+i*2)=tmp;
        tmp=zzz;
        if(zzz==NL) break;
      }
      *(video_ptr+cury*c80*2+curx*2) = yylval;

      /* сдвинуть текст от curptr на символ вправо */
      if(*curptr=='\n')curptr--;/* иначе вставка разорвет */
      for(p=endbuf+1;p!=curptr;p--){*p=*(p-1);} endbuf++;

      correct_mark(1);
      *curptr = yylval;
      right1();

        /* ======= wraping =========*/
      if(wrap && wrapflag ){
        oldx=curx;oldy=cury;oldcr=curptr;
        for( ; curx<MAXJ; ){ if(right()) break; }
        for( ; curx>MAXJ; ){ if(left()) break; }
        if(*curptr!=' '&&*curptr!='\n'){
          for( ; *curptr!=' ' && curx>MAXJ-15; ){ if(left()) break; }
          if(*curptr==' '){
            right();
            yylval='\r'; sym();
            up(); justify(); down();
            if(oldx<MAXJ){curx=oldx;cury=oldy;curptr=oldcr; }
            else end0();
            if(cury==c25-1){
              next(&curpage);
              curx=0;cury=c0;curptr=curpage;
              for(i=c0;i<c25-2;i++)down();
              end0();
            }
            toscr();
          }
        }
        else {curx=oldx;cury=oldy;curptr=oldcr;}
      }/*if(wrap*/
        /* =========================*/
    }/*if*/
  }/*else*/
 }

#include "meta2.c"
