#include <conio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 26

// Shows wgtprintf

*/

wgtfont medium;
int i;
float f;


void main(void)
{
vga256();		// initializes system
medium=wloadfont("c:\\tc\\newwgt\\fonts\\medium.wfn");

wtextcolor(15);
wtextbackground(0);
for (i=0; i<100; i++)
  {
  f=(float)i/100;
  wgtprintf(5,50,medium,"COUNT %i:   FLOAT  %f ",i,f);
}
getch();
textmode(C80);		// used to return to text mode
}