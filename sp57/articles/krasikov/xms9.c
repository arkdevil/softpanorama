#include <xms.h>

int lockBlock(unsigned int handle, unsigned long * Address)
{   int r;
    _DX=handle;
    _AH=0x0C;
    CallXMS();
    r=_AX;
    *Address=_DX*0x10000L+_BX;
    return r;
}

