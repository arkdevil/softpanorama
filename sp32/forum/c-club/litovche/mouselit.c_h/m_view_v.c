/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_view_v.c

	set vertical limits for movement of mouse marker

		Version 2.03
*/

void mouseviewvert(int miny,int maxy)
{
_CX=miny;
_DX=maxy;
_AX=8;
__int__(0x33);
}
