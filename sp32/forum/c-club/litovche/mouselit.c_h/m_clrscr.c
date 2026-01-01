/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_clrscr.c

	remove marker of mouse from screen

		Version 2.01
*/

void mouseclearscreen(void)
{
_AX=2;
__int__(0x33);
}
