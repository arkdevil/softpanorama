#include <string.h>
#include "console.h"
#define COLOR_EXTERN extern
#include "define.h"

void scrline(short x, short y, char *s, int color)
{
   scrwipe(x, y, x+strlen(s)-1, y, color);
   scrgoto(x, y); scrputs(s);
}
