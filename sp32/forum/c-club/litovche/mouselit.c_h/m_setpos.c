/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_setpos.c

	set marker of mouse to position (x,y)

		Version 2.03
*/

void mousesetposition(int x,int y)
{
_CX=x;
_DX=y;
_AX=4;
__int__(0x33);
}
