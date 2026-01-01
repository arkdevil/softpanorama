/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_view_h.c

	set horizontal limits for movement of mouse marker

		Version 2.03
*/

void mouseviewhoriz(int minx,int maxx)
{
_CX=minx;
_DX=maxx;
_AX=7;
__int__(0x33);
}
