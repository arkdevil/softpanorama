/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		m_test.c

	test of activity of mouse driver

		Version 2.03

	return :

	active mouse  : 2 or 3 ( number of mouse keys )
	non-active    : 0
*/

int mousetest(void)
{
_BX=0;
_AX=0;
__int__(0x33);
return(_BX);
}
