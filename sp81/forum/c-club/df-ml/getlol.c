
#include <regs.h>
#include "lstolist.h"


LIST_OF_LISTS  far *dos_list_of_lists(void)
{
	REGS regs;
	LIST_OF_LISTS  far *p;

	regs.AX = 0x5200;
	dos_interrupt(&regs);


	p = (((long) regs.ES) << 16) + regs.BX;
	return p;
}

	
