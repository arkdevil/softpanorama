#include <xms.h>

int unlockBlock(unsigned int handle)
{
  _DX=handle;
  _AH=0x0D;
  CallXMS();
  return _AX;
}

