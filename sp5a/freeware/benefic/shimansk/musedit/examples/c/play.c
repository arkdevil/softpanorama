/*
        Функции были написаны на Ассемблере => могут быть использованы как в
  Microsoft C, так и в Borland C++.
*/

#include <stdio.h>                    /* для printf */ 
#include <conio.h>                    /* для kbhit */
#include "..\..\include\music.h"      /* музыка */

extern unsigned far music[];          /* внешний массив, созданный */
                                      /* Music Editor */

static char title[]=
"\n╔════════════════════╗\n║      ╔═════╤═╦═══╗ ║\n║  ╔═══╩═════╧═╝   ║ ║"
"\n║  ╚════╦════╤═╗   ║ ║\n║ KUKISH╠════╪═╣   ║ ║\n║  SOFT ╠════╪═╣   ║ ║"
"\n║       ╚═╦══╧═╝   ║ ║\n║    93   ╚════════╝ ║\n╚════════════════════╝"
"\nИграет фоновая музыка. Для прекращения нажмите любую клавишу...";

void main( void )
{     printf(title);
      install_music();                /* установка музыки */
      set_new_melody( music );        /* запуск музыки */

      while( !kbhit() &&              /* пока не нажата клавиша */
      get_music_pos() != 0xffff )     /* или не кончилась мелодия */
            ;                         /* делаем холостой цикл */

      uninstall_music();              /* выключаем музыку */
}
