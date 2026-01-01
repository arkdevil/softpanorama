#include <wgt.h>
#include <conio.h>

// WordUp Graphics Toolkit demo program 30
// Mouse routines work in normal text modes too!

int i;

void main(void)
{
textmode(C80);
clrscr();
textbackground(BLUE);
textcolor(WHITE);
for (i=1; i<26; i++)
 {
 gotoxy(1,i);
 cputs("                                                                                ");
 }

 i=minit();
 mon();
do {
  mread();
    gotoxy(1,1);
    cprintf("Mouse coordinates: %i,%i     Button: %i     ",mx/4,my/8,but);
  } while (!kbhit());
moff();
getch();

textmode(C4350);
clrscr();
textbackground(BLUE);
textcolor(WHITE);
for (i=1; i<51; i++)
 {
 gotoxy(1,i);
 cputs("                                                                                ");
 }

 i=minit();
 mon();
do {
  mread();
    gotoxy(1,1);
    cprintf("Mouse coordinates: %i,%i     Button: %i     ",mx/4,my/8,but);
  } while (!kbhit());
moff();
getch();
}
