#include <xms.h>

int freeXMS(unsigned int handle)
{
    _DX=handle;
    _AH=0x0A;
    CallXMS();
    return(_AX);
}


