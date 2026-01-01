#include <dos.h>
#include <stdio.h>
#include <sys/types.h>
#include "lib.h"

boolean ssleep(time_t interval)
{
	sleep(interval);
	return 0;
}
