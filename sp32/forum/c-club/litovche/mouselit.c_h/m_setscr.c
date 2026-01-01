/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_setscr.c

	set marker of mouse to screen

		Version 2.01
*/

void mousesetscreen(void)
{
_AX=1;
__int__(0x33);
}
