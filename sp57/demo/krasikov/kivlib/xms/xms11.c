#include <xms.h>

int getXMShandleInfo(unsigned int handle,
		     unsigned char * LockCount,
		     unsigned char * FreeHandles,
		     unsigned int  * Size)
{
    int r;
    _DX=handle;
    _AH=0x0E;
    CallXMS();
    r=_AX;
    if (!r) return r;
    *LockCount=_BH;
    *FreeHandles=_BL;
    *Size=_DX;
    return(r);
}
