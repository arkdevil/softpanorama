#include "window.h"

void far snowtest(int flag)
{
char far *egabits=(char far *)0x00000487L;
	*egabits&=0xfb;
	*egabits|=(flag) ? 4 : 0;
}
