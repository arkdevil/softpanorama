#include <xms.h>

void getXMSmem(unsigned int * Total, unsigned int * Block)
{
    _AH=8;
    CallXMS();
    *Total=_DX;
    *Block=_AX;
}

