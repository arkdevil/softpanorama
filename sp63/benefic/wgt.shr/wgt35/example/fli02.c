#include <conio.h>
#include <wgt.h>
#include <wgtfli.h>

// WordUp Graphics Toolkit FLI demo program
// Simply loads in an FLI file and plays the animation.
// Shows FLI on a virtual screen.
void main(void)
{
     vga256();
     fliscreen=wnewblock(0,0,319,199);

     openfli("wordup.fli");
     do {
     nextframe();
     wnormscreen();
     copyfli();
     }while (!kbhit());
     getch();
     closefli();
     wfreeblock(fliscreen);
textmode(C80);
}

