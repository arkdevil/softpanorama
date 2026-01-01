#include <conio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 3

Clears the screen with random colours until you hit a key.
*/

int x,y,col;

void main(void)
{
vga256();		// initializes system
do {
   wcls(rand() % 255);
   } while (kbhit()==0);
getch();		// get the key
textmode(C80);		// used to return to text mode
}