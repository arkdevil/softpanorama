#include <conio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 28

  Shows wpan.
  Since 320x200x256 doesn't support multiple pages, the vertical
  lines you might see when the screen scrolls down is just what is
  in memory after the VGA screen buffer. Do not be alarmed.

*/

int i;

void main(void)
{
vga256();		// initializes system

for (i=1; i<200; i++)
  {
  wsetcolor(i);
  wline(0,0,319,i);
  wsetcolor(200-i);
  wline(319,199,0,i);
  }

do {
for (i=0; i<100; i++) { wpan(i*320); delay(20);}
for (i=0; i<50; i++) { wpan(rand() % 10); delay(40);}
} while (!kbhit());


getch();
textmode(C80);		// used to return to text mode
}