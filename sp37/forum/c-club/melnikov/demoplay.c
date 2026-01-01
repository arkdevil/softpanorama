/***************************************************************

		     Функция    play()

		Аналог оператора  play  BASIC

   Язык программирования: Quick C, V 2.51
   Модель памяти: LAGRE
   Версия: 1.1
   Дата последнего изменения: 27.08.91г.
 -----------------------------------------------------------------

 Программист: Мельников А.В. ВЦ Укр.УГА, г.Киев, р.т.(044) 216-27-96
						 д.т.(044) 488-88-16

 --------------------------------------------------------------------

*********************************************************************/


#include "play.h"     /* описание функции play()  */

#include <stdio.h>
#include <conio.h>
#include <graph.h>

main()        /* YESTERDAY */
{

  int ret;
  /*             The Beatles 'Yesterday'
	 Писалось на слух (если таковой имеется).
  */

 char *a$="mbl8o3g.f.f2.p4abo4c#defe.d8d2.p4o4ddc.o3a#aga#4aa2g4f4a g4.d4f4.a.a2 ";
 char *r$="l4 a2a2 o4 defe8d8e.d8c d8 o3a1 l4 a2a2 o4 defe8d8e.d8c efco3a#a";
 /* play("r"); */
 ret=play (a$);
 ret=play (a$);
 ret=play (r$);
 ret=play (a$);
 ret=play (r$);
 ret=play (a$);
 ret=play ("l4f.a.g.d.f.a8.a2.");

  do
    fill();
  while (!kbhit()); getch();
   play("q");
   _setvideomode( _DEFAULTMODE );
   exit(0);
}



