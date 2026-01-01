#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 14

Demonstrates string input,mouse cursor shape and speed, and
wflashcursor, cursor coordinates (xc,yc)

*/

color palette[256];
int i;

char *charlist=" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_.";
	// this is a list of all the possible characters you can enter
	// with wstring. If the character is not in the list, nothing will
	// happen and the cursor will remain in the same position.

char *yesno="YNyn";
	// used for yes/no answers only

char *string;

void main(void)
{
vga256();		// initializes system

for (i=1; i<253; i++)
   wsetrgb(i,i+30,i+30,i,&palette); 		// just something other
						// than black!
wsetrgb(253,60,60,60,&palette);
wsetrgb(254,50,50,50,&palette);
wsetrgb(255,40,40,40,&palette);
wsetpalette(0,255,&palette);

wcls(255);

wtextcolor(253);
wtexttransparent(2);					// must do this
							// or characters
							// will not erase

// wstring allows strings to be inputted using special keys such as
// the arrow keys, backspace, delete, insert, home and end, etc.

string= (char *)malloc(11);			// remember to add one for
						// the null character. This
						// string is 10 chars long.

strcpy(string," ");			// now make sure it is empty


curspeed=2400;
// type in a string, try using the special keys
wouttextxy(10,1,"Type in a string: ",NULL);
wstring(150,1,string,charlist,10);


free(string);			// now free the memory



string= (char *)malloc(2);
strcpy(string," ");

// now try a yes or no answer, try letters other than {YNyn}
wouttextxy(10,30,"Do you want to quit? ",NULL);
wstring(170,30,string,yesno,1);
free(string);


wsetcursor(0,7);			// now do something interactive
curspeed=1;				// with the mouse
i=minit();
moff();
do {
   mread();
   xc=(mx/8)*8;				// divide by 8 and multiply by 8
   yc=(my/8)*8;				// to make 8*8 squares
   wflashcursor();
   if (but==1)
     {
     wsetcolor(rand() % 64);
     wline(0,0,xc,yc);			// do something in graphics as well
     }
   } while (!kbhit());



textmode(C80);				// used to return to text mode
}