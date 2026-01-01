#include <xms.h>

int requestHMA(unsigned int Mem) //in bytes; $FFFF for all
{
    _DX=Mem;
    _AH=1;
    CallXMS();
    return(_AX);
}

int releaseHMA(void)
{
    _AH=2;
    CallXMS();
    return(_AX);
}
