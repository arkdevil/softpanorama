/* PRPAGE           */
/* ПРОГРАММА ПЕЧАТИ С ЭКРАННЫМ ЛИСТАНИЕМ ТЕКСТА*/
/* Автор: Альперович Л.З. */
/* Упpавляющие символы в пеpвых позициях стpок текста:
   $ <R пpовеpка числа оставшихся стpок
   или $R
   ) новая стpаница
   Фоpмат: )-N   где
   N   пpоизвольное число - начало отсчета стpаниц
*/

#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <math.h>
#include <sys\stat.h>
#include <alloc.h>
#include <stdlib.h>
#include <string.h>

#define BEGIN      {
#define END        }
#define TRUE       1

#define ESC        27
#define ENTRY      13
#define INS        82
#define DEL        83
#define UP         72
#define DN         80
#define LEFT       75
#define RIGHT      77
#define PGUP       73
#define PGDN       81
#define HOME       71
#define ENDK       79
#define F2         60

#define MINUS      45
#define PLUS       43
#define SPACE      32
#define STREND     10
#define TXTEND     26
#define NEWPAGE    12
#define BUFSIZE    1024

#define LINESCRN   80
#define HECRAN     21
#define LINESIZE   161
#define MAXLINE    100
#define MALL       MAXLINE*2*LINESIZE

#define MBLOCK     1000
#define MTXT       4

#define LOOP(v,i)    for(i=0;i<v;++i)
#define ZERO(p)      {p[0]=0;list(p,m);++it;}
#define XY(x,y)      gotoxy(x,y)
#define COLOR(p)     textcolor(p)

typedef char unsigned  byte;

   int aread();
   void areadst();
   void rest();
   void prpg();
   void zag();
   void list();
   void stops();
   void lgo();
   int  recod();
   void dnlist();
   void pup();
   int  strbuf();
   int  cyf();
   int  cyf2();

   int fn,iglob=-1,iiggll=-2,flup,first,begi,lrest,flstop,lpg2;
   int hpage=72,hhpp=10,it,n=1,im,im2,im3,im4,ii=-1,lpage=80,lpage2;
   int ab,ae,ae1,ae2,at,as,an,ai,ak,ap,av,ax,ax1,ax2,ay,ar=8;
   int migalka=2,miginter,lscr,idn,hom;
   int af=4; /* PRINT */
   int jmp;
   char sym=')',sym1='$';
/*        Переменные:
     ab          малые буквы -> большие
     ae,ae1,ae2  диапазон номеров страниц
     af          выходной файл
     ai          чеpез интеpвал
     ak          Замена символа
     an          автонумерация
     as          чет-нечет
     at          в две колонки
     av          с запросом на экране
     ar          Проверяемый остаток страницы
     ax          Левое поле (до lpage)
     ay          Замена символа, формат: Yиииррр, по 3 цифры дес
     begi        анализ для случая отсутствия управляющего символа
     first       не прогонять первый лист
     flstop      пропустить лист
     flup        PGUP в конце файла
     fn          дескрипторный номер файла
     hpage       высота листа в строках
     hhpp        заполняемость листа в строках
     hom         признак попадания в начало текста
     im          индекс массива М
     ii          индекс для двусторонней печати 14-32
     iiggll      сщхраняет iglob
     iglob       индекс  в buf
     ipos        индекс в массивах параметров листов
     iread       pазмеp пpочитанной инфоpмации в buf
     it          индекс строк
     jmp         пропуск листов по +-N
     lpage       длина строки
     lpage2      координата номера в строке
     lpg2        lpage или lpage*2
     lscr        сбивка к правой границе для экрана
     lrest       текущий проверяемый остаток страницы
     migalka     мигалка страниц
     miginter    мигалка интервалов
   */
   byte s[LINESIZE];
   char str[LINESIZE*2];
   char pg[20]="";
   char sak[256];
   char aaxx[LINESCRN];
   long posm[MBLOCK],post,ipos,post1;
   int  posjm[MBLOCK];
   int  posnm[MBLOCK];
   char m[MAXLINE*2][LINESIZE];
   /*char *m;*/
   char sss2[LINESCRN] =
   " Печать - Enter, Конец - Esc, Просмотр: PgUp,PgDn,HOME,END,+ -,             ";
   char sss3[] = "01.10.90 Л.Альпеpович";
/***********************************************************/
   main(argc,argv)
   int argc;
   char *argv[];
   BEGIN
   int i,i1,j,k;
   byte l;
   if (argc<2) {
      printf("Паpаметpы: ИМЯ_ФАЙЛА [режимы]\n");
      printf("Режимы в произвольном наборе без пробел:\n");
      printf(" H72     Высота листа\n");
      printf(" D10     Межстраничный промежуток\n");
      printf(" L80     Ширина колонки\n");
      printf(" T{T2}   Две колонки {стpаницы 1,4-3,2}\n");
      printf(" V       Работа с экpаном\n");
      printf(" S1{S2}  Печать тoлько нечетных {четных} листов\n");
      printf(" N75     Авто-нумерация страниц, положение номера в строке\n");
      printf(" En1-n2  Диапазон номеров страниц для печати\n");
      printf(" R8      Проверяемый остаток страницы\n");
      printf(" Fname   Имя выходного файла\n");
      printf(" B       Малые буквы - > большие (альт. кодировка)\n");
      printf(" Х0      Расстояние от левого края листа\n");
      printf(" ))      Символ - признак начала страницы\n");
      printf(" $$      Символ - признак проверки расстояния до конца страницы\n");
      printf(" I       Печать через строку\n");
      printf(" Kabсd.. Замена символа 'a' на 'b', 'c' на 'd' и т.д.\n");
      printf(" Yaabb.. Замены символов в 16-ичном коде\n");
      printf("Об управляющих символах в тексте см. PRPAGE.DOC \n");
      printf("%s",sss3);
      return;
   };
   fn=open(argv[1],O_BINARY/*,O_TEXT*/);
   if (fn<0) {printf("Файл не найден");exit(3);};
   post = lseek(fn,0L,SEEK_SET); posm[0]=post;
   posnm[0]=n;
   if (argc>2){
      for (k=2;k<argc;k=k+1){
         LOOP(LINESIZE,i1){
            s[i1]=argv[k][i1+1]; if (s[i1]==0) break;
         };
         i=recod(argv[k][0]);
         switch(i) {
            case 'H':sscanf(s,"%d",&hpage);break;
            case 'D':sscanf(s,"%d",&hhpp);break;
            case 'L':sscanf(s,"%d",&lpage);break;
            case 'R':sscanf(s,"%d",&ar);break;
            case 'X':sscanf(s,"%d",&ax);break;
            case 'N':
                  an=0;if (s[0] == '0') break;
                  sscanf(s,"%d",&lpage2);an=1;break;
            case 'T':at=1;if (s[0]=='2') at=2;break;
            case 'V':av=1;ae=0;break;
            case 'I':ai=1;break;
            case 'F':af=0;j=k;break;
            case 'B':ab=1;break;
            case 'S':as=1;if (s[0]=='2') as=2;break;
            case 'K':
                  for(i=0;i<i1;i=i+2) sak[s[i]]=s[i+1];ak=1;
                  break;
            case 'Y':
                  if (i1<4) break;
                  for(i=0;i<i1;i=i+4){
                     l=cyf2(s+i);ak=l;
                     if (l!=0) sak[l]=cyf2(s+2);
                  }; ak=1;
                  break;
            case ')':sym=s[0];break;
            case '$':sym1=s[0];break;
            case 'E':av=0;if (i1<3) break;
                  LOOP(i1,i){if (s[i]==MINUS) s[i]=SPACE;};
                  sscanf(s,"%d%d",&ae1,&ae2);ae=1;av=0;
                  break;
            default:;
         }
     };
   };
   if (af==0) {
      af = open(argv[j]+1,O_TEXT|O_CREAT,S_IREAD|S_IWRITE);
      af = open(argv[j]+1,O_TEXT | O_RDWR |O_TRUNC);
      if (af<0) {cprintf("Выходной файл не создан"); exit(2);};
   };
   if (lpage2==0) lpage2=lpage/2-1;
   if ((hpage > MAXLINE) || (hpage<hhpp+5) || \
      (lpage >= LINESIZE-1) || (lpage2 > LINESIZE-6) || \
      (ax > LINESCRN-2) || (ax < -lpage) || (ae1>ae2))
      {printf(" Ошибка, заданы режимы:\nЛист=%d\nПромежуток=%d\n",hpage,hhpp);
       printf("Строка=%d\nОтступ номера=%d\n",lpage,lpage2);
       printf("Расстояние от левого края=%d\n",ax);
       printf("Диапазон номеров строк=%d-%d\n",ae1,ae2);
       exit(1);
   };
   hhpp=hpage-hhpp;im2=2*hpage;im3=3*hpage;im4=4*hpage;
   lpage++;lpg2=lpage;if (at>0) lpg2=lpg2+lpage;
   if (sss3[9]!='Л') exit(5);

   LOOP(LINESCRN,i) aaxx[i]=SPACE;
   if (ax > 0) ax1 = ax;
   if (ax < 0) ax2 = -ax;
   pg[0] = 0;
/*   m = malloc(MALL*2);*/

   while(TRUE){
     if (flup==1){
        flup=0;it=0;prpg();continue;
     };
     areadst();
     if (iglob==-2) {
        list(s,m); if (av==0) {close(af);clrscr();exit(0);};
        continue;
     };
     if (s[0]==sym1 && sym1 != '0') {
        lrest=ar;zag();
        if (hhpp-it<=lrest){rest();prpg();continue;};
        s[0]=0;
     };
     if (s[0]==sym && sym != '0'|| s[0]==NEWPAGE) {
	if (hom == 0) continue;
	zag();rest();prpg();continue;};
     if (begi==0) {n=1;first=1;prpg();};
     ++it;hom=1;list(s,m);
     if (it>=hhpp) {rest();prpg();};
   };
  END
/*********************************************************/
/* чтение одной стpоки из файла  */
     static void areadst()
    BEGIN
     byte k;
     int i;

     while(kbhit()!=0){if (getch()==ESC){clrscr();exit(0);};};
     if (ai == 1){
        if (miginter == 0){miginter = 1; s[0]=0; return;};
        miginter = 0;
     };

     LOOP(1000,i){
        k=aread(); if (k==0) {s[i]=0;iglob=-2;break;};
        if (k==ENTRY ) k=SPACE;
        if (k==STREND) {
           if (i==0){i--;continue;}
           else {if (i<lpage) s[i]=0;};
           break;
        };
        if (ak==1) {if (sak[k]!=0) k=sak[k];};
        if (ab==1) k=recod(k);
        if (i<lpage) s[i]=k;
     };
     s[lpage-1]=0;
     return;
    END
/************************************************************/
/* пpогон до следующей стpаницы */
       static void rest()
       BEGIN
        if (first==1){
            while(it < hpage ) ZERO(s);
            };
        first=1; it=0;
        return;
       END
/***********************************************************/
/* Занесение в буфеp титула стpоки */
        static void prpg()
        BEGIN
         char s1[LINESIZE],s2[30];
         int i;

         s2[0]=0;
         if (ae>0){
            if (n > ae2) {close(af);exit(0);};
            if (n >= ae1) ae=2; else ae=3;
         };
         if (n>1) sprintf(s2,"-%d-",n);
         if (an==1) {
            ZERO(s1);
            LOOP(lpage,i) s1[i]=SPACE;
            LOOP(30,i) {if (s2[i]==0) break;s1[i+lpage2]=s2[i];};
            s1[i+lpage2]=0;
            list(s1,m);++it;
            ZERO(s1);ZERO(s1);
         };
         ++n; begi =1; miginter =0;
         if (av==0){
            XY(1,24);clreol();printf("Стpаница %s",s2);
         };
         return;
        END
/************************************************************/
/* Выделение текста "Т" , Упpавляющие символы */
       static void zag()
       BEGIN
        int i,j=0,k=0,L=0,fl=0;
        char gg[8],gL[8];

        LOOP(20,i){
           if (s[i]== 0||s[i]==SPACE) break;
           if (s[i]== sym && sym != '0' || s[i]== NEWPAGE) {fl=1;continue;};
           if (s[i]== sym1 && sym1 != '0')   {fl=2;continue;};
           if (s[i]== '-')                   {fl=3;continue;};
           switch(fl) {
              case 1  : {pg[j]=s[i];j=j+1;}; break;
              case 2  : {gL[L]=s[i];L=L+1;}; break;
              case 3  : {gg[k]=s[i];k=k+1;}; break;
           };
        };
        if (k>0) {gg[k]=0;sscanf(gg,"%d",&n);};
        if (L>0) {gL[L]=0;sscanf(gL,"%d",&lrest);};
        /*if (j>MTXT) j = MTXT;
        if (j>0 || k>0) pg[j]=0;*/
        return;
       END
/********************************************************/
/* Запись в буфеp и извлечение  из буфеpа */
      static void list(s,m)
      char s[];
      char  m[MAXLINE*2][LINESIZE];
  BEGIN
       int i,j,k;

       if (iglob==-2) {
       for (j=im;j<im2;++j) m[j][0]=0; goto prod;};

       if (at<2 || as==0) goto pr1;
       ++ii; if (ii==im4) ii=0;
       if ((as==1) && (ii>=hpage) && (ii<im3)) return;
       if ((as==2) && ((ii<hpage) || (ii>=im3))) return;

       pr1:
       LOOP(LINESIZE,i) {m[im][i]=s[i];if (s[i]==0) break;};
       m[im][LINESIZE-1]=0;
       ++im;
       if ((im == im2) || ((at==0)&&(im==hpage))) goto prod;return;

       prod:
      if ((at<2) && (as>0)){
         switch(migalka){
            case 1: migalka = 2;break;
            case 2: migalka = 1;break;
         };
         if (as != migalka) {im=0;return;};
      };

      if ((at==2) && (as==2)){
         LOOP(hpage,j) {
            LOOP(LINESIZE,i){
               k=m[j+hpage][i];
               m[j+hpage][i] =  m[j][i];
               m[j][i]=k;
            };
         };
       };
       do  {
         if (av==1) {
           stops(m);
           if (flstop==1) return;
         };
         lgo(m); im=0;
         if ((iglob < -1) && (av > 0)) iglob=-3;
       }
       while (iglob == -3);
       return;
  END
/********************************************************/
/* Вывод из буфеpа */
      static void lgo(m)
      char m[MAXLINE*2][LINESIZE];
 BEGIN
       int k,kb;

       if (ae==3) return;
       LOOP(hpage,k){
          kb = strbuf(k,m);
          if (ax > 0) write(af,aaxx,ax);
          if (ax2>0 && kb<=ax2) {str[ax2]='\n';kb=ax2+1;};
          write(af,str+ax2,kb-ax2);
      };
      return;
  END
/********************************************************/
/* Вывод фpагмента листа на дисплей */
      static void stops(m)
      char m[MAXLINE*2][LINESIZE];
       BEGIN
        int i,i1=0,i2=0,j,j0=0,k,fln=0,isjmp=0,isym;
        char sym,sjmp[4],symm[81];

        flstop=0;
        if (jmp > 0 && iglob > -3 ){
           im=0;flstop=1; jmp--; dnlist();
           return;
        };
        jmp=0;

        while(TRUE){
           clrscr();COLOR(6);
           XY(1,1);
           for(i=0,isym=0;i<LINESCRN;i++,isym++)symm[isym]=MINUS;
	   symm[isym]=0;cprintf(symm);
           if (at > 0) {
              XY(25,1);
              if (lscr==0)     printf("Левая колонка");
              if (lscr>=lpage) printf("Правая колонка");
           };
           COLOR(7);
           LOOP(HECRAN,j){
              XY(1+ax1-i1,j+2); k = j + j0;
              if (k == hpage || idn == 1) goto minus;
              if (k < hpage) {
                 i = strbuf(k,m);
                 if (i < lscr+2) continue;
		 isym=0;
                 LOOP (LINESCRN-2-ax1+i1,i){
                    sym=str[lscr+i]; if (sym=='\n') break;
                    if (i>=ax2-i2) {symm[isym]=sym; isym++;};
                 };
		 symm[isym]=0; cprintf(symm);
                 continue;
              };
              break;
           };
           XY(1,23);
minus:     COLOR(6);
           for(i=0,isym=0;i<LINESCRN;i++,isym++)symm[isym]=MINUS;
	   symm[isym]=0;cprintf(symm);
           if (idn==1) {XY(26,j+2); printf("Конец файла");};
           COLOR(7);
           XY(1,24); cprintf(sss2);
           XY(65,24);putch(24);putch(25);putch(26);putch(27);
	   XY(2,25); cprintf("Печать до конца - F2");
           XY(1,24);
           while(kbhit()!=0) j=getch();
           j=0;
           while(TRUE) {
              while((j=getch())==0);
              if ( j== PGDN && iglob > -3) {
                 im=0;flstop=1;
                 dnlist();
                 return;
              };
              if ( j== ESC) {
                 if (fln!=0){fln=0; break;};
                 close(af); clrscr();exit(0);
              };
              if ( j== PGUP && ipos > 0){pup();return;};
              if ( j== UP && j0 > 0){
                 j0 = j0 - HECRAN + 1; if (j0 < 0) j0 = 0; break;
              };
              if ( j== DN && j0 < hpage-HECRAN+1){
                 j0 = j0 + HECRAN - 1; break;
              };
              if ( j== RIGHT && lscr<lpg2-LINESCRN){
                 if (lscr<lpage && lscr+LINESCRN > lpage)
                    lscr = lpage;
                 else lscr=lscr+LINESCRN-1;
                 i1=ax1;i2=ax2;break;
              };
              if ( j== LEFT  && lscr >0){
                 lscr=0;i1=0;i2=0;break;
              };
              if ((fln == 0) && (j== PLUS || j == MINUS)){
                 fln = 1; if (j == MINUS) fln = -1; clreol();
                 XY(2,25);cprintf("Число листов пропуска или ESC");
                 XY(1,24);isjmp=0; putch(j);
              };
              if ((fln!=0) && (j >47) && (j<58) && (isjmp<4)){
                 sjmp[isjmp] = j; isjmp++; putch(j);
              };
              if ( j== HOME) {flstop=1;ipos=1;
		 pup();return;};
              if ( j== ENDK) {
                 flstop=1;jmp=MBLOCK;
                 XY(2,25); clreol();cprintf("Подождите");im=0;dnlist();
                 return;
              };
              if ( j== F2) {av=0; clrscr();return;};
              if ( j== ENTRY) {
                 if (fln!=0){
                    if (isjmp==0) continue;
                    flstop=1;sjmp[isjmp]=0; sscanf(sjmp,"%d",&jmp);
                    if (jmp==0){isjmp=0; continue;};
                    if (fln<0) {
                       ipos=ipos-jmp +1; if (ipos<1) ipos=1;
                       jmp=0; pup(); return;
                    };
                    if (jmp>10) {XY(2,25);clreol(); cprintf("Подождите");};
                    jmp--;im=0;dnlist();
                    return;
                 };
                 if (iglob == -3) {
                    close(af); clrscr(); exit(0);
                    };
                 dnlist();return;
              };
           };
        };
       END
/******************************************/
/* Чтение одного символа из файла */
     int aread()
    BEGIN
      int nb=BUFSIZE,ret;
      static char buf[BUFSIZE];
      static int iread;

      if ((iglob==-1) || (iglob >= iread)){
         post = lseek(fn,0L,SEEK_CUR);
         iread=read(fn,buf,nb);
         if (iiggll>-2) {
            iglob=iiggll-1;
            if (iglob<0) iglob=0;
            iiggll=-2;return 0;
         };
         iglob=0;
         if (iread<=0) return 0;
      };
      ret=buf[iglob];
      ++iglob;
/*      if (ret == TXTEND) return 0;*/
      if (ret == 0) ret = SPACE;
      return ret;
    END
/************************************************************/
/* Преобразование малые буквы -> большие */
     static int recod(i)
     byte i;
    BEGIN
      if ((i> 96)&&(i<123)){i=i-32;goto ret;};
      if ((i>159)&&(i<176)){i=i-32;goto ret;};
      if ((i>223)&&(i<242)) i=i-80;
      ret:return(i);
    END
/************************************************************/
/* Модификация массива страниц при погружении */
     static void dnlist()
    BEGIN
          int i;
          if (idn==0) {
             if (ipos == MBLOCK) return;
             ++ipos; posm[ipos]=post; posjm[ipos]=iglob;
             posnm[ipos]=n;
             /*LOOP(MTXT,i) poscm[ipos][i] = pg[i];*/
          };
          if (iglob<-1) {jmp=0;idn=1;};
          return;
    END
/******************************************************/
/* Подъем */
  static void pup()
  BEGIN
     --ipos; idn=0;
     if (ipos==0) hom=0;
     post=posm[ipos]; iiggll = posjm[ipos]; n=posnm[ipos];
     /*LOOP(MTXT,i) pg[i] = poscm[ipos][i]; pg[MTXT] = 0;*/
     im=0;
     if (iglob<-1) flup=1;
     iglob=-1;
     lseek(fn,post,SEEK_SET);
     aread(fn);
     flstop=1;return;
  END
/********************************************************/
/* Заполнение одной строки из буфеpа */
      static int strbuf(k,m)
      int k;
      char m[MAXLINE*2][LINESIZE];
 BEGIN
       int i,j,flag,kb;
       flag=0;
 /*пеpвая колонка */
       LOOP(lpage,i) {
          if (flag==0 && m[k][i]==0){
             if (at==0) break;
             flag=1;
          };
          if (flag==1) str[i]=SPACE;
          else str[i]=m[k][i];
       };
       if (at==0) {
          str[i]='\n';kb=i+1;
          return(kb);
       };
 /*втоpая колонка */
       LOOP(lpage,i){
          if (m[k+hpage][i] == 0) break;
          str[i+lpage-1]=m[k+hpage][i];
       };
       str[i+lpage-1]='\n';
       kb=i+lpage;
       return(kb);
 END
/********************************************************/
/* Преобразование из 16-ичного кода в число */
      static int cyf(c)
      int c;
 BEGIN
       int i,k,j=20;
       k=recod(c);
       if (k>47 && k<58)j=k-48;
       if (k>64 && k<71)j=k-55;
       return j;
 END;
/********************************************************/
/* Преобразование из 2 разрядного 16 -ичного кода в число */
      static int cyf2(c)
      char c[4];
 BEGIN
       int i,j=20;
       i=cyf(c[0]);if (i==20) return(0);
       j=cyf(c[1]);if (j==20) return(0);
       return j+16*i;
 END;
