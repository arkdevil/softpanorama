/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_state.c

	current state of mouse

		Version 2.04

	return : current position of marker and status of mouse key

	mask for key  : non-press  0
			left   --> 1
			right  --> 2
			middle --> 4

		*x :  current position X
		*y :  current position Y
*/

int mousestate(int *x,int *y)
{
int i;
_AX=3;
__int__(0x33);
i=_BX;
*x=_CX;
*y=_DX;
return(i);
}
