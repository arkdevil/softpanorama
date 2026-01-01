#include <xms.h>

int reallocXMS(unsigned int handle, unsigned int mem)
{
    _DX=handle;
    _BX=mem;
    _AH=0x0F;
    CallXMS();
    return _AX;
}



