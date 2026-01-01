/* File: dosintr.c - created by Marty Leisner */
/* leisner.Henr        23-Dec-87 13:18:28 */

/* Copyright (C) 1987 by Martin Leisner. All rights reserved. */

#include <regs.h>

unsigned dos_errno;

/* set dos_errno to AX if carry is set.
 * Return 0 if it works, -1 if we think it failed 
 */
int	dos_interrupt(regs)
REGS 	*regs;
{
	if(TEST_CARRY(sysint(0x21, regs, regs))) {
		dos_errno = regs->AX;
		return -1;
	} else return 0;
}
