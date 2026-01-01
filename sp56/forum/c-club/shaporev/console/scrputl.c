#include <stdring.h>
#include "console.h"

void scrputl(char far *s, int a)
{
   short x,y; scraddr(&x,&y); scrwipe(x, y, x+strlen(s)-1, y, a); scrputs(s);
}
