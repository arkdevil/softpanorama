#include "console.h"

void scrouts(short x, short y, char far *s)
{
   scrgoto(x, y); scrputs(s);
}