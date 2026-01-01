#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <wgt.h>
#include <wgtmenu.h>

wgtfont little;
color pal[256];
char *menubar[10]={" QUIT  "," MENU1  "," MENU2 "," MENU3  ",NULL,NULL,NULL,NULL,NULL,NULL};
int menuchoice;

void main(void)
{
vga256();
// change the directory if needed
little=wloadfont("c:\\tc\\newwgt\\fonts\\little.wfn");

wreadpalette(0,255,&pal);
wsetrgb(1,63,63,63,&pal);
wsetrgb(253,50,50,50,&pal);
wsetrgb(254,40,40,40,&pal);
wsetrgb(255,30,30,30,&pal);
wsetpalette(0,255,&pal);

menubarcolor=254;
menubartextcolor=1;
bordercolor=255;
highlightcolor=144;

menufont=little;

dropdown[0].choice[0]=" QUIT ";

dropdown[1].choice[0]="This is a drop";
dropdown[1].choice[1]="down menu. You can";
dropdown[1].choice[2]="put any text in here";
dropdown[1].choice[3]="and WGT Menus will";
dropdown[1].choice[4]="handle the rest";
dropdown[1].choice[5]="--------------------";
dropdown[1].choice[6]="You can have up to";
dropdown[1].choice[7]="ten choices per menu";
dropdown[1].choice[8]="and up to ten menus.";

dropdown[2].choice[0]=" Choice #1 ";
dropdown[2].choice[1]=" Choice #2 ";
dropdown[2].choice[2]=" Choice #3 ";
dropdown[2].choice[3]="You can even change";
dropdown[2].choice[4]="the colors of each";
dropdown[2].choice[5]="dropdown menu.";
dropdown[2].color=12;
dropdown[2].bordercolor=14;
dropdown[2].textcolor=1;

dropdown[3].choice[0]="You can also use";
dropdown[3].choice[1]="any font, as long";
dropdown[3].choice[2]="as all the menus";
dropdown[3].choice[3]="fit on the screen.";
dropdown[3].choice[4]="******************";
dropdown[3].choice[5]="Try changing";
dropdown[3].choice[6]="menufont to NULL";
dropdown[3].choice[7]="and the default";
dropdown[3].choice[8]="font will be used.";
dropdown[3].choice[9]="******************";

menufont=little;
initdropdowns();
showmenubar();

mon();

do { menuchoice=checkmenu();


 } while (menuchoice !=0);


removemenubar();
free(little);
textmode(C80);
}


