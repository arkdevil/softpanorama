#include <conio.h>
#include <stdlib.h>
#include <time.h>
#include <wgt.h>
#include <wgtfli.h>
#include <spr.h>

// WordUp Graphics Toolkit FLI demo program
// Show how to display sprites overtop an animating FLI.

block sprites[1001];
color palette[256];
int i;


void main(void)
{
     randomize();
     vga256();
     wloadsprites(&palette,"bird.spr",sprites);
     initspr();
     fliscreen=spritescreen;
     spon=5;
     spclip=1;

    for (i=1; i<5; i++)
     {
     spriteon(i,320+rand() % 50,rand() % 170,1);
     animate(i,"(1,1)(2,1)(3,1)(2,1)R");		     
     animon(i);
     }

     movex(1,"(-1,400,0)R"); 
     movex(2,"(-2,400,0)R"); 
     movex(3,"(-3,400,0)R"); 
     movex(4,"(-4,400,0)R"); 
     movexon(1);
     movexon(2);
     movexon(3);
     movexon(4);

     movey(1,"(-1,200,3)R"); 
     movey(2,"(1,200,2)R"); 
     movey(3,"(1,400,1)R"); 
     moveyon(1);
     moveyon(2);
     moveyon(3);


     openfli("wordup.fli");


     nextframe();
     copyfli();

     do {
     erasespr();
     nextframe();
     drawspr();
     copyfli();
     for (i=1; i<5; i++)
       if (s[i].x<-40)
	 {
	 s[i].x=320+rand() % 50;
	 s[i].y=rand() % 170;
	 }
     }while (!kbhit());
     getch();
     closefli();
     wfreesprites(sprites);
     textmode(C80);
}

