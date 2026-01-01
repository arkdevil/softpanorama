/*
** Simple and foolproof keyboard I/O.
*/
#include "window.h"

int far waitkey(void)
{
	while (!testkey())
		DVpause();
	_AH=0;
	__int__(0x16);
	return _AX;
}

int far testkey(void)
{
	__emit__(0xb4,0x01);		/* mov ah,1 */
	__emit__(0xcd,0x16);		/* int 16h */
	__emit__(0xb8,0xff,0xff);	/* mov ax,0ffffh */
	__emit__(0x75,0x02);		/* jnz skip */
	__emit__(0x33,0xc0);		/* xor ax,ax */
	return _AX;
}

