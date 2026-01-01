/*
Litovchenko V.P. Ukrain Kiev tel. (044) 430-10-80 (Home)

	support of mouse for TC 1.5

		mouselit.h

	definition for mouse functions

		Version 2.01
*/

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define MOUSE_NON_PRESS 0
#define MOUSE_LEFT	1
#define MOUSE_RIGHT	2
#define MOUSE_MIDDLE	4

int	_Cdecl	mousetest(void);
void	_Cdecl	mousesetscreen(void);
void	_Cdecl	mouseclearscreen(void);
int	_Cdecl	mousestate(int *x,int *y);
void	_Cdecl	mousesetposition(int x,int y);
void	_Cdecl	mouseviewhoriz(int minx,int maxx);
void	_Cdecl	mouseviewvert(int miny,int maxy);

#ifndef geninterrupt(i)
void	_Cdecl	__int__ (int interruptnum);
#endif
