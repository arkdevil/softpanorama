#include <conio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 2

Draw pixels with random colour in random places until you hit a key.
Second loop fills screen with wfastputpixel.
***** wgetpixel will return the colour at a specific coordinate. It
is not included in this example file.

*/

int x,y,col;

void main(void)
{
vga256();		// initializes system
wcls(0); // clears screen with colour 0
do {
   wsetcolor(rand() % 255);
   x=rand() % 320;
   y=rand() % 200;
   wputpixel(x,y);
   } while (kbhit()==0);
getch();		// get the key

wcls(0); // clears screen with colour 0
wsetcolor(10);
for (x=0; x<320; x++)
for (y=0; y<200; y++)
   wfastputpixel(x,y);
getch();		// get the key
textmode(C80);		// used to return to text mode
}