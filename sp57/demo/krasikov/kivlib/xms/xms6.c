#include <xms.h>

int moveXMS(EMMSTRUCT far * M)
{
  asm {
      push ds
      lds  si,M
      mov  ah,0Bh
   }
   CallXMS();
   asm pop ds;
   return(_AX);
}



