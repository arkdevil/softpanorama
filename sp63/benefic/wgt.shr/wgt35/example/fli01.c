#include <conio.h>
#include <wgt.h>
#include <wgtfli.h>

// WordUp Graphics Toolkit FLI demo program
// Simply loads in an FLI file and plays the animation.

void main(void)
{
     vga256();
     fliscreen=abuf;
     // Abuf means the visual screen. 

     openfli("wordup.fli");
     do {
     nextframe();
     wnormscreen();
     }while (!kbhit());
     getch();
     closefli();
     wfreeblock(fliscreen);
textmode(C80);
}

