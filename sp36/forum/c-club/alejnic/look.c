/**************************************************************************
 * Если Вы подготовили текстовый буфер для печати, можете предварительно  *
 * просмотреть его на экране при помощи этой функции.                     *
 * Работа с видеопамятью напрямую.                                        *
 * Обратите внимание, функция распознает и обрабатывает только символ '\n'*
 *************************************************************************/
#include          <conio.h>
#include          <bios.h>

/* коды управляющих клавиш */
#define UP       72
#define DOWN     80
#define PgUp     73
#define PgDn     81
#define LEFT     75
#define RIGHT    77
#define Home     71
#define CtrlHome 119
#define End      79
#define CtrlEnd  117
#define Esc      1

/* цвет */
#define cyan     3
#define black    0

/* границы окна */
#define L        0
#define R        79
#define T        0
#define B        20

/* параметры экрана */
#define nrow     24
#define ncol     80
#define scrl     160  /* длина строки экрана в видеопамяти 80*2 */
#define video    0xb8000000L /* адрес видеопамяти */



/********************************
*   вывод части буфера в окно   *
* возвращает указатель на       *
* первую не выданную строку или *
* конец буфера                  *
*********************************/

char * outwind(pbuf, col, endbuf)
char *pbuf, *endbuf;
int col;
{
   char far *pwind = (char far *) (video + (long)((T+1)*scrl) );
   extern unsigned char maxl;
   unsigned char strl;
   unsigned int icol, irow;
   maxl=0;
   for ( irow=T+1; irow<B; irow++ )
   {
       strl=0;

       pwind += L+L+2;  /* до начала окна + рамка */

       icol = col;
       while ( icol-- && ( *pbuf != '\n' ) && ( pbuf < endbuf ) )
       {
          ++pbuf;  /* часть строки, остающаяся левее окна */
          ++strl;
       }

       icol = R-L-1;
       while ( icol && ( *pbuf++ != '\n' ) && ( --pbuf <= endbuf ) )
       {
          *pwind++ = *pbuf++;   /* часть строки, попадающая в окно */
          ++pwind;
          --icol;
          ++strl;
       }

       if ( ! icol )
          while ( *pbuf++ != '\n' )
             ++strl;     /* часть строки, остающаяся правее окна */

       while ( icol-- )
       {
          *pwind++ = ' ';  /* до правой границы окна*/
          ++pwind; /* аттрибут символа не изменяем */
       }

       icol = ncol-R;
       while ( icol-- )
          pwind +=2;    /* до конца экрана + рамка */

       maxl = max ( maxl , strl );

   }
   return ( pbuf );
}


unsigned char maxl=0;

look(buf,l)
char *buf;
int l;
{

   char far *pwind = (char far *) (video + (long)(T*scrl) );

   static char *mess1=
 {"Сдвиг текста:"};

   static char *mess2=
 {"Стрелки, Home, End, Ctrl+Home, Ctrl+End, PageUp, PageDown"};

   static char *mess3=
 {"Esc - конец просмотра"};

   static char sim1='┌';                                          /*┌───────────────────────────────────────┐*/
                                                                  /*│                                       │*/
   static char sim2='┐';                                          /*│                                       │*/
                                                                  /*│            Алейникова  Ольга          │*/
   static char sim3='└';                                          /*│               Михайловна              │*/
                                                                  /*│                                       │*/
   static char sim4='┘';                                          /*│           Москва 546-12-64            │*/
                                                                  /*│                                       │*/
   static char sim5='─';                                          /*│                                       │*/
                                                                  /*│                                       │*/
   static char sim6='│';                                          /*│                                       │*/
                                                                  /*│                                       │*/
                                                                  /*│                                       │*/
   union REGS r;                                                  /*└───────────────────────────────────────┘*/

   int col=0 , i;
   char *pbuf,  *pnext;

   /* быстрый курсор */
   outp(0x60,0xf3);    /* в некоторых машинах адрес порта может быть не 60, а 64 */
   for ( i=0x2000 ; i ; i-- )  /* задержка обязательна */
      ;
   outp(0x60,2); /* 2 задает 24 сигнала от клавиши в секунду */

   /* очистка экрана, цвет */
   r.h.ah=6; /*окно*/
   r.h.al=0;
   r.h.ch=T;
   r.h.cl=L;
   r.h.dh=B;
   r.h.dl=R;
   r.h.bh=cyan*16+black ; /* формула цвета: фон*16+символ */
   int86( 0x10 , &r , &r );

   r.h.ah=6; /*help*/
   r.h.al=0;
   r.h.ch=B+1;
   r.h.cl=L;
   r.h.dh=nrow;
   r.h.dl=R;
   r.h.bh=cyan;
   int86( 0x10 , &r , &r );

   /* убрать курсор */
   r.h.ah=1;
   r.h.ch=20;
   int86 ( 0x10 ,&r , &r );

   /* рамка */
   *(pwind+L+L) = sim1;
   *(pwind+R+R) = sim2;
   *(pwind+(B-T)*scrl+L+L) = sim3;
   *(pwind+(B-T)*scrl+R+R) = sim4;

   for ( i=L+L+2 ; i<R+R ; i+=2 )
       *(pwind+i) = sim5;
   for ( i=(B-T)*scrl+L+L+2 ; i<(B-T)*scrl+R+R ; i+=2 )
       *(pwind+i) = sim5;

   for ( i=(T+1)*scrl+L+L ; i<(B-T)*scrl+L+L ; i+=(R-L+1)*2 )
       *(pwind+i) = sim6;
   for ( i=(T+1)*scrl+R+R ; i<(B-T)*scrl+R+R ; i+=(R-L+1)*2 )
       *(pwind+i) = sim6;

   /* help */
   for ( i=0 ; i<strlen(mess1) ; i++ )
       *(pwind+(B-T+2)*scrl+i+i) = *(mess1+i);
   for ( i=0 ; i<strlen(mess2) ; i++ )
       *(pwind+(B-T+3)*scrl+i+i) = *(mess2+i);
   for ( i=0 ; i<strlen(mess3) ; i++ )
       *(pwind+(B-T+4)*scrl+i+i) = *(mess3+i);

  /* начальная выдача */
   pbuf = buf;
   pnext = outwind ( pbuf , col , buf+l );

   for(;;)
   {

      switch( (( _bios_keybrd(_KEYBRD_READ) & 0xFF00) >> 8) )
      {
        /********/
         case UP:
       /********/
            if ( pbuf != buf )

            {
               --pbuf;  /* конец предыдущей строки */
               while ( * (pbuf-1) != '\n' && (pbuf-1) >= buf )
                  --pbuf; /* начало предыдущей строки */

            }

            break;

        /*********/
         case DOWN:
        /*********/

           if ( pnext < buf+l )
           {

              while ( * pbuf != '\n' && pbuf < buf+l )
                 ++pbuf; /* до конца строки */

              ++pbuf; /* начало след. строки */

           }

           break;

       /*********/
        case PgUp:
       /*********/

           if ( pbuf != buf )
           {
              i=B-T;  /* на окно вверх */
              while ( i && (pbuf >= buf) )
                 if ( * --pbuf == '\n' )
                    --i;
              ++pbuf;

           }
           break;

       /*********/
        case PgDn:
       /*********/

           if ( pnext <= buf+l )
           {
              i=B-T+1;
              while ( i && pnext <= buf+l )
                 if ( * ++pbuf == '\n' )
                    --i;
              ++pbuf;

           }
           break;

       /*********/
        case Home:
       /*********/

           col = 0;
           break;

       /**************/
        case CtrlHome:
       /**************/

           pbuf = buf;
           break;

       /*********/
        case End:
       /*********/

           col = maxl >= col+(R-L-1) ? maxl-(R-L-1) : 0;  /* без рамки будет R-L+1 */
           break;

       /*************/
        case CtrlEnd:
       /*************/

           i=B-T;  /* конец буфера */
           pbuf = buf+l;
           while ( i && (pbuf >= buf) )
              if ( * --pbuf == '\n' )  /* от конца буфера вверх на окно */
                 --i;
           ++pbuf;

           break;

       /*********/
        case LEFT:
       /*********/

           if ( col )
              col -= 8; /* сдвигаемся сразу на 8 колонок; для документа может быть ширина колонки*/
           break;

        /*********/
        case RIGHT:
       /*********/

           if ( maxl-col > R-L-2 )
              col += 8;
           break;

        /*********/
        case Esc:
        /*********/

           return;

      } /* end switch */

      pnext = outwind ( pbuf , col , buf+l );

   } /* end for */

}/* end look */