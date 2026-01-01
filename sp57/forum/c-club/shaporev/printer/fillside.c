#include "console.h"
#define COLOR_EXTERN extern
#include "define.h"

#define SIDECHAR 176

void fillside(int width, int height)
{
   register x, y;
   register l, r;

   r = (l = (width - 40) / 2) + 40;

   for (y=0; y<height; y++) {
      for (x=0; x<l; x++) {
         scrgoto(x, y); scrpoke((EMPTY<<8)|SIDECHAR);
      }
      for (x=r; x<width; x++) {
         scrgoto(x, y); scrpoke((EMPTY<<8)|SIDECHAR);
      }
   }
}
