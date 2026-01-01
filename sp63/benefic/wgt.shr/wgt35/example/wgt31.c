#include <wgt.h>
#include <conio.h>

// WordUp Graphics Toolkit Demo program 31
// Shows how to use WGT library files.

int i;
block sprites[1001];
color pal[256];

void main(void)
{
vga256();
setlib("demo31.wlb");
setpassword("WGT");
wloadsprites(&pal,"Demo31.spr",sprites);
// Loads a sprite file from within demo31.wlb
wcls(0);
do {
wputblock(rand()%300,rand()%180,sprites[1],0);
} while (!kbhit());
textmode(C80);
}
