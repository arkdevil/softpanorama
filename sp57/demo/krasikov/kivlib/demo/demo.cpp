#include <string.h>
#include "defines.h"
#include "mnu.h"
#include "xms.h"
#include "music.h"
#include "info.h"

const cmExit  = 1,      //команды для меню
      cmMusic = 2,
      cmInfo  = 3,
      cmXMS   = 4,
      cmFile  = 5;

const hNon    = 0,
      hMusic  = 1,
      hExit   = 2,
      hXMS    = 3,
      hInfo   = 4,
      hFile   = 5;

char *helptext[]={      //тексты помощи
       "",
       "Music on/off",
       "Quit",
       "XMS info",
       "Computer info",
       "Pick file demo"
       };

char * HelpText(int i)
{
    return helptext[i];
};

void HELP(int i)
{
     messageWindowPar(mwHelp,"Sample help for topic %d",i);
};


SubMenu * Mnu; //основное меню программы
Window * desk; //основное окно программы
int Music=0;   //флаг игры музыки


char * cpu[] = {
        "Intel 8088",
        "Intel 8086",
        "NEC V20",
        "NEC V30",
        "Intel 80188",
        "Intel 80186",
        "Intel 80286",
        "Intel 80386 or later"
        };

char * disp[]={
        "none",
        "MDPA mono",
        "CGA",
        "EGA color",
        "EGA mono",
        "PGC",
        "VGA mono",
        "VGA color",
        "MCGA mono",
        "MCGA color",
        "unknown"
        };




void main()
{
    unsigned int cursor=getcursorshape();
    setcursorshape(0x2000);                      //невидимый курсор
    desk=makeDesk(0x17," KIVLIB Demo program "); //создаем основное окно
    Mnu = newSubMenu(2,                      //начальная строка меню
                     2,                      //начальная колонка меню
                     STANDARDFRAME,
                     1,                      //с "тенью"
                     0x20, 0x28, 0x2F, 0x08, 0x0E, //аттрибуты меню
                     " Main Menu ",
                     1,                     //горизонтальное меню
                     newMenuItem("Info", 0, //команды нет - будет подменю!
                                 0,         //специальной горячей клавиши нет
                                 0,         //help отсутствует
                                 newMenuItem("Music  on ", cmMusic,
                                             0x3200, //горячая клавиша - Alt-M
                                             hMusic,
                                             newMenuItem("Exit", cmExit,
                                                         0x2D00, //Alt-X
                                                         hExit,
                                                         NULL,NULL),
                                             NULL),
                                 newSubMenu( 5,4,THINFRAME,
                                             1, 0x20,0x28,0x2F,0x08,0x0E,
                                             NULL,
                                             0,     //вертикальное меню
                                             newMenuItem("Processor",
                                                         cmInfo,0,hInfo,
                                                         newMenuItem("XMS", cmXMS,
                                                                     0,hXMS,
                                                                     newMenuItem("File",cmFile,
                                                                                 0,hFile,
                                                                                 NULL,
                                                                                 NULL),
                                                                     NULL),
                                                         NULL))));
    int choise;
    do {        //основной цикл
       choise=MenuChoiseWithHelp(Mnu, HELP,
                                 24,       //строка краткой помощи
                                 2,        //колонка краткой помощи
                                 40,       //длина строки
                                 0x74,     //аттрибуты
                                 HelpText);
       if (choise==cmExit) break;
       switch (choise) {
           case  cmMusic: if (Music) {
                              StopPlay();
                              strcpy(MenuItemName(Mnu,cmMusic),"Music on  ");
                              Music=0;
                          } else {
                              SetPlay(Odessa);
                              Music=1;
                              strcpy(MenuItemName(Mnu,cmMusic),"Music off ");
                          };
                          break;
           case  cmXMS  : if (!XMSinstalled()) messageWindow("XMS not installed",mwError); else {
                              unsigned int total, block;
                              getXMSmem(&total, &block);
                              messageWindowPar(mwInfo,"\003XMS installed\n\003Total available %d Kb\n\003Max block %d Kb",total,block);
                          };
                          break;
           case  cmFile : char name[60];
                          int error;
                          if (!GetFileName("*.*",name,5,10,20,0x70,
                                          0x71,0x7E,1,0x08,0x4F,VTHINFRAME,
                                          0,0,&error)) {
                              messageWindow("No choise",mwInfo);
                          } else {
                              messageWindowPar(mwInfo,"Your choose - %s",name);
                          };
                          break;
           case cmInfo :  messageWindowPar(mwInfo,
                              "\003CPU %s\n\003Display %s",
                              cpu[LOBYTE(PROCESSOR)],
                              disp[display_type()]);

       };
    } while(1);
    wipeWindow(desk);
    setcursorshape(cursor);
};




