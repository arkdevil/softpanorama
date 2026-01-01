/* Файл play.h                                           */

/* прототип функции play() */

int far play (char far *);

/* Перед завершинием программы необходимо предусмотреть,
   чтобы буфер функции play() был чист.
   Например:
   int playexit();
   onexit playexit();
   playexit()
   {
     if (play() > 0 ) play ("q");    завершение мелодии
   }
*/
