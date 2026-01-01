#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <wgt.h>
#include <wgtmenu.h>
#include <filesel.h>


color pal[256];	// our palette
char *menubar[10]={" QUIT  "," FILE "," MODE ",NULL,NULL,NULL,NULL,NULL,NULL,NULL};
int menuchoice; // result from menus
wgtfont little; // smaller font with special characters 
int picmode=3;	// mode for picture (PCX,PAK,BLK)
char *picturename; // filename of picture for loading and saving
		   // used with file selector
char *palname;	   // filename of palette
block screen2;	   // a virtual screen to load pictures onto


void changemode(int);
void loadapicture(void);
void saveapicture(void);
void dopalette(void);

void main(void)
{
vga256();

screen2=wnewblock(0,0,319,199);
little=wloadfont("c:\\tc\\newwgt\\fonts\\medium.wfn");
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

dropdown[1].choice[0]="LOAD A PICTURE";
dropdown[1].choice[1]="--------------";
dropdown[1].choice[2]="SAVE A PICTURE";
dropdown[1].choice[3]="--------------";
dropdown[1].choice[4]="LOAD A PALETTE";
dropdown[1].choice[5]="--------------";
dropdown[1].choice[6]="SAVE A PALETTE";

dropdown[2].choice[0]=" PCX \x09";
dropdown[2].choice[1]=" PAK \x09";
dropdown[2].choice[2]=" BLK \x0A";

initdropdowns();

showmenubar();

  mon();

do { menuchoice=checkmenu();

 switch (menuchoice)
   {
   case 20:
   case 21:
   case 22: changemode(menuchoice-19); break;
   case 10: loadapicture(); break;
   case 12: saveapicture(); break;
   case 14: dopalette(); break;

  }
 } while (menuchoice !=0);	// quit


removemenubar();
free(little);			// free the font
wfreeblock(screen2);
textmode(C80);
}


void changemode(int cmode)
{
// make all boxes empty
dropdown[2].choice[0]=" PCX \x09";
dropdown[2].choice[1]=" PAK \x09";
dropdown[2].choice[2]=" BLK \x09";


// and put a check mark in the right one
if (cmode==1)
dropdown[2].choice[0]=" PCX \x0A";
else if (cmode==2)
dropdown[2].choice[1]=" PAK \x0A";
else if (cmode==3)
dropdown[2].choice[2]=" BLK \x0A";

picmode=cmode;
}


void loadapicture()
{
block tempblock=NULL;

   moff();
removemenubar();

if (picmode==1)
    picturename=wfileselector("Load a PCX","*.pcx");
else if (picmode==2)
    picturename=wfileselector("Load a PAK","*.pak");
else if (picmode==3)
    picturename=wfileselector("Load a BLK","*.blk");

  moff();
if (picturename !=NULL)	// if you selected something
    {
    wsetscreen(screen2);
    wcls(0);			// clear the virtual screen
    if (picmode==1)
       {
       tempblock=wloadpcx256(picturename,&pal);
       wputblock(0,0,tempblock,0);
	wsetrgb(1,63,63,63,&pal);
	wsetrgb(253,50,50,50,&pal);
	wsetrgb(254,40,40,40,&pal);
	wsetrgb(255,30,30,30,&pal);
	wsetpalette(0,255,&pal);
      }
    else if (picmode==2)
       {
       tempblock=wloadpak(picturename);
       wputblock(0,0,tempblock,0);
       }
    else if (picmode==3)
       {
       tempblock=wloadblock(picturename);
       wputblock(0,0,tempblock,0);
       }

    if (tempblock !=NULL)
       wfreeblock(tempblock);
	}
wnormscreen();
wputblock(0,0,screen2,0);
showmenubar();
   mon();
}

void saveapicture()
{
removemenubar();

   moff();
if (picmode==1)
    picturename=wfileselector("Save a PCX","*.pcx");
else if (picmode==2)
    picturename=wfileselector("Save a PAK","*.pak");
else if (picmode==3)
    picturename=wfileselector("Save a BLK","*.blk");


if (picturename !=NULL)	// if you selected something
    {
    moff();
    wnormscreen();
    wputblock(0,0,screen2,0);
    if (picmode==1)
       wsavepcx256(picturename,screen2,&pal);
    if (picmode==2)
       wsavepak(picturename,screen2);
    else if (picmode==3)
       wsaveblock(picturename,screen2);
    }
showmenubar();
   mon();
}


void dopalette(void)
{

moff();
removemenubar();

palname=wfileselector("Load a palette","*.pal");
moff();
if (palname !=NULL)
{ 
wloadpalette(palname,&pal);
wsetpalette(0,255,&pal);
}
wnormscreen();
wputblock(0,0,screen2,0);
showmenubar();
mon();
}
