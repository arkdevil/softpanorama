#include <stdring.h>
#include "console.h"

void scroutl(short x, short y, char far *s, int a)
{
   scrgoto(x, y);   scrwipe(x, y, x+strlen(s)-1, y, a);   scrputs(s);
}
