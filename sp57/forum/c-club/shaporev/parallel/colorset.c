#include "console.h"
#define COLOR_EXTERN extern
#include "define.h"

void colorset(int argc, char *argv[])
{
   if (argc>=2 && (argv[1][0]=='/' || argv[1][0]=='-') &&
                  (argv[1][1]=='c' || argv[1][1]=='C') && argv[1][2]==0) {
      BRIGHT=BRIGHT_COLOR;
      NORMAL=NORMAL_COLOR;
      INVERT=INVERT_COLOR;
      ITALIC=ITALIC_COLOR;
      BORDER=BORDER_COLOR;
      EMPTY =EMPTY_COLOR;
      HLIGHT=INVERT_COLOR | BRIGHT_COLOR;
   } else {
      BRIGHT=BRIGHT_BW;
      NORMAL=NORMAL_BW;
      INVERT=INVERT_BW;
      ITALIC=ITALIC_BW;
      BORDER=BORDER_BW;
      EMPTY =EMPTY_BW;
      HLIGHT=HLIGHT_BW;
   }
}