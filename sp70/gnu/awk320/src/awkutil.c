#pragma inline
/*
 * Awk stack push pop routines
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include "awk.h"

void xpop(void far *dst)
{
    _CX = sizeof(ITEM) / 2;
asm les di, dst
asm mov si, stackptr
asm rep movsw
    stackptr++;
}

void xpush(void far *src)
{
    stackptr--;
    _CX = sizeof(ITEM) / 2;
asm push ds
asm mov ax,ds
asm mov es,ax
asm mov di, stackptr
asm lds si, src
asm rep movsw
asm pop ds
}

void xmove(void far *dst, void far *src)
{
    _CX = sizeof(ITEM) / 2;
asm push ds
asm les di, dst
asm lds si, src
asm rep movsw
asm pop ds
}

