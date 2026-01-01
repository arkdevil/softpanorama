/*                OLV present (c) Menu Maker 1991 v1.4D  

filename :        menudemo.c

*/

#include <conio.h>
#include <stdio.h>
#include "dmenu.h"

char *screensumbl="";
int   screenattr =LIGHTGRAY on BLACK;

MENU *menu0;
int  attr0[] ={LIGHTGREEN on BLUE,LIGHTCYAN on BLUE,BLACK on CYAN,LIGHTCYAN on BLUE,YELLOW on CYAN,CYAN on BLUE,YELLOW on BLUE,YELLOW on RED,YELLOW on BLUE};
int  attr1[] ={LIGHTGREEN on BLUE,LIGHTGRAY on BLACK,BLACK on CYAN,LIGHTGRAY on BLUE,YELLOW on LIGHTGRAY,CYAN on BLUE,WHITE on BLUE,LIGHTBLUE on BLUE,LIGHTGREEN on BLUE};
int  attr2[] ={LIGHTGREEN on BLUE,LIGHTGRAY on BLACK,BLACK on CYAN,LIGHTCYAN on BLUE,YELLOW on LIGHTGRAY,CYAN on BLUE,YELLOW on BLUE,LIGHTBLUE on BLUE,LIGHTGREEN on BLACK};
int  attr3[] ={LIGHTGREEN on BLUE,GREEN on RED,BLACK on CYAN,WHITE on BLACK,YELLOW on BLUE,CYAN on BLUE,LIGHTBLUE on BLUE,DARKGRAY on BROWN,LIGHTGREEN on BLUE};
int  attr4[] ={LIGHTGREEN on BLUE,CYAN on BROWN,BLACK on CYAN,LIGHTGREEN on BLUE,YELLOW on RED,CYAN on BLUE,WHITE on BLUE,LIGHTBLUE on BLUE,WHITE on BLUE};
int  attr5[] ={LIGHTGRAY on BLACK,LIGHTGRAY on BLACK,BLACK on GREEN,LIGHTGREEN on BLUE,YELLOW on RED,CYAN on BLUE,LIGHTBLUE on BLACK,LIGHTBLUE on BLUE,WHITE on BLUE};
char frame0[] ="╔═╗║╝═╚║";
char frame1[] ="╦═╦║╝═╚║";
char frame2[] ="┌─┐│┘─└│╔═╗║╝═╚║";
char frame3[] ="";
char wind0[] =" ";
char wind1[] ="░▒▓█ ";
char wind2[] ="┴─┬───";
char wind3[] ="";
int  flag0   = AREASAVE | BORDURE | WINDOW | SMALLSHADOW;
int  flag1   = AREASAVE | BORDURE | WINDOW | SMALLSHADOW | RECOME;
int  flag2   = AREASAVE | BORDURE | WINDOW;
int  flag3   = AREASAVE | BORDURE | WINDOW | BARMENU;
int  flag4   = AREASAVE | WINDOW | SMALLSHADOW | BARMENU;
/* ----------------------------------------------------------------------- */

main()
{
int f=1;
int choice;

/* --------------- Инициализация МЕНЮ ------------------------------------ */
menu0 =submenu(" Это Демонстрационное Меню ",frame0,wind0,attr0,25,flag0);
         menuxy(12,1);
         lenmenu(62,3);
         menuitem(" Опция 1 ", 15, 2, 7, 1, "Это подсказка к Опции 1");
       submenu("",frame1,wind0,attr1,25,flag1);
         helpxy(CENTRCENTR,25);
           menuitem(" Опция 11 ", 15, 4, 9, 6, "Строка-подсказка к Опции 1");
           menuitem(" Опция 12 ", 15, 5, 9, 7, "А это уже строка-подсказка к Опции 12");
           menuitem(" Опция 13 ", 15, 6, 9, 8, "У Опции 14 строки-подсказки НЕТ !");
           menuitem(" Опция 14 ", 15, 7, 9, 9, "");
           menuitem(" Опция 15 ", 15, 8, 9, 10, "В даном подменю работает АВТОСДВИГ !!!");
           menuitem(" Опция 16 ", 15, 9, 9, 11, "Строка-подсказка центрована в ЦЕНТР");
       popsubmenu();
         menuitem(" Опция 2 ", 26, 2, 7, 2, "А это уже подсказка к Опции 2");
       submenu("",frame0,wind0,attr2,5,flag1);
         helpxy(41,5);
           menuitem(" Опция 21 ", 26, 4, 9, 12, " Это строка-подсказка к опции 21 ");
           menuitem(" Опция 22 ", 26, 5, 9, 13, " А это уже строка подсказки к Опции 22");
           menuitem(" Опция 23 ", 26, 6, 9, 14, " Подсказка к Опции 24 отсутствует !!!");
           menuitem(" Опция 24 ", 26, 7, 9, 15, "");
       popsubmenu();
         menuitem(" Опция 3 ", 38, 2, 7, 3, "У Опции 4 строки-подсказки НЕТ !");
       submenu("",frame1,wind1,attr3,2,flag2);
         menuxy(20,3);
         lenmenu(47,18);
         helpxy(16,2);
           menuitem(" Опция 31 ", 26, 8, 0, 16, "           демонстрируются                             ");
           menuitem(" Опция 32 ", 26, 11, 0, 17, "           возможности                                 ");
           menuitem(" Опция 33 ", 26, 14, 0, 18, "           рисователя                                  ");
           menuitem(" Опция 34 ", 51, 8, 0, 19, "                                Демонстрируются        ");
           menuitem(" Опция 35 ", 51, 11, 0, 20, "                                Возможности            ");
           menuitem(" Опция 36 ", 51, 14, 0, 21, "                                Make Menu              ");
       popsubmenu();
         menuitem(" Опция 4 ", 50, 2, 7, 4, "");
       submenu("",frame2,wind2,attr4,25,flag3);
           menuitem(" Опция 41 ", 3, 6, 2, 22, "");
           menuitem(" Опция 42 ", 18, 10, 3, 23, "");
           menuitem(" Опция 43 ", 34, 14, 4, 24, "");
           menuitem(" Опция 44 ", 51, 18, 5, 25, "");
           menuitem(" Опция 45 ", 67, 22, 6, 26, "");
       popsubmenu();
         menuitem(" Опция 5 ", 62, 2, 7, 5, "Выход производится по нажатию клавиши ESC");
       submenu("",frame3,wind3,attr5,25,flag4);
         lenmenu(72,13);
           menuitem("   Выбор 501   ", 5, 8, 0, 27, "");
           menuitem("   Выбор 502   ", 5, 11, 0, 28, "");
           menuitem("   Выбор 502   ", 5, 14, 0, 29, "");
           menuitem("   Выбор 504   ", 24, 8, 0, 30, "");
           menuitem("   Выбор 505   ", 24, 11, 0, 31, "");
           menuitem("   Выбор 506   ", 24, 14, 0, 32, "");
           menuitem("   Выбор 507   ", 43, 8, 0, 33, "");
           menuitem("   Выбор 508   ", 43, 11, 0, 34, "");
           menuitem("   Выбор 509   ", 43, 14, 0, 35, "");
           menuitem("   Выбор 510   ", 62, 8, 0, 36, "");
           menuitem("   Выбор 511   ", 62, 11, 0, 37, "");
           menuitem("   Выбор 512   ", 62, 14, 0, 38, "");
       popsubmenu();
       popsubmenu();
/* --------------- Инициализация МЕНЮ  закончена ------------------------- */

paint(ALLSCREEN,screensumbl,screenattr);

while(f){
      choice=choicemenu(menu0);
      switch(choice){

/*             */  case 0: if(stackmenu()==0) f=0; break;
/*  Опция 11       */  case     6 : break;
/*  Опция 12       */  case     7 : break;
/*  Опция 13       */  case     8 : break;
/*  Опция 14       */  case     9 : break;
/*  Опция 15       */  case    10 : break;
/*  Опция 16       */  case    11 : break;
/*  Опция 21       */  case    12 : break;
/*  Опция 22       */  case    13 : break;
/*  Опция 23       */  case    14 : break;
/*  Опция 24       */  case    15 : break;
/*  Опция 31       */  case    16 : break;
/*  Опция 32       */  case    17 : break;
/*  Опция 33       */  case    18 : break;
/*  Опция 34       */  case    19 : break;
/*  Опция 35       */  case    20 : break;
/*  Опция 36       */  case    21 : break;
/*  Опция 41       */  case    22 : break;
/*  Опция 42       */  case    23 : break;
/*  Опция 43       */  case    24 : break;
/*  Опция 44       */  case    25 : break;
/*  Опция 45       */  case    26 : break;
/*    Выбор 501    */  case    27 : break;
/*    Выбор 502    */  case    28 : break;
/*    Выбор 502    */  case    29 : break;
/*    Выбор 504    */  case    30 : break;
/*    Выбор 505    */  case    31 : break;
/*    Выбор 506    */  case    32 : break;
/*    Выбор 507    */  case    33 : break;
/*    Выбор 508    */  case    34 : break;
/*    Выбор 509    */  case    35 : break;
/*    Выбор 510    */  case    36 : break;
/*    Выбор 511    */  case    37 : break;
/*    Выбор 512    */  case    38 : break;
       default :;
      }/* end switch */

}/* end while */

freemenu(menu0);

}/* end main  */

/* ----------------------------------------------------------------------- */
