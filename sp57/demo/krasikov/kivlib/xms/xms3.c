#include <xms.h>

unsigned int allocXMS(unsigned int Mem)
{
   _DX=Mem;
   _AH=9;
   CallXMS();
   if (_AX==1) return _DX; else return 0;
}



