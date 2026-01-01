/*********************************************************
*                                                        *
*   DPERIOD - пример функции пользователя для MacroBat   *
*   В ы з о в   в среде MacroBat:                        *
*                                                        *
*      имя = DPERIOD(дата1,дата2)                        *
*                                                        *
*   Н а з н а ч е н и е: вычислить число дней,           *
*      прошедшее (в обычном смысле) между дата1 и дата2  *
*   Ф о р м а т  каждой даты: ГГГГММДД (год,месяц,день)  *
*   Пример обращения:  i=Dperiod(19920501,19920601)      *
*      Результат:  i=31  (в мае 31 день)                 *
*                                                        *
*********************************************************/
#include <string.h>

void main() {
  struct {                      /* блок MBCB */
        char flags,rc;
        int plen;
        char txt[];
  } far *parg;

  long days(int,int,int);
  int k,y1,m1,d1,y2,m2,d2;
  char buf[250];

  asm {
        mov  ax,"F0"
        mov  di,"MB"
        int  11h
        cmp  ax,0
        jne  NotMB
        mov  word ptr parg,di
        mov  word ptr parg+2,es
  };

  /* для удобства перешлем текст аргумента в локальную переменную buf */
  k = 0;
  do buf[k] = parg->txt[k]; while (k++ < parg->plen);

  sscanf(buf,"%4u%2u%2u",&y1,&m1,&d1);
  sscanf(buf+9,"%4u%2u%2u",&y2,&m2,&d2);

  /* вычислим и занесем в buf разность числа дней */
  sprintf(buf,"%lu",days(y2,m2,d2) - days(y1,m1,d1));

  /* перешлем результат обратно */
  parg->plen = strlen(buf); k = 0;
  do parg->txt[k] = buf[k]; while (++k < parg->plen);
  goto Finish;

NotMB:
  printf(" ** Run this program under MacroBat environment **");
Finish: ;
}

/* Функция подсчета числа дней, прошедших с 31 декабря 1900 года */
long days(int y, int m, int d) {
  long R;
  int mt[12]={0,31,59,90,120,151,181,212,243,273,304,334};

  R = 365*(y-1901) + (y-1901)/4 + mt[m-1] + d;
  if (y%4 == 0 && m > 2) R++;
  return(R);
}
