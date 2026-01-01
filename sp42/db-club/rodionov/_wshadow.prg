*!*********************************************************************
*! @
*! Function: WSHADOW(<y1>,<x1>,<y2>,<x2>)
*! Notes: Рисует прозрачную тень справа от заданного окна
*!        Переработанный для '87 вариант функции SHADOW из Clipper 5

FUNCTION WShadow
PARAMETERS Y1,X1,Y2,X2
PRIVATE Ny1,Nx1,Ny2,Nx2
Ny1=MIN(Y2+1,24)
Ny2=Ny1+1
Nx1=X1+1
Nx2=MIN(X2+1,79)
RESTSCREEN( Ny1, Nx1, Ny2, Nx2,;
   TRANSFORM( SAVESCREEN(Ny1, Nx1, Ny2, Nx2),;
   REPLICATE("X", Nx2 - Nx1 + 1 )+REPLICATE("XX",Nx2-Nx1+1) ) )
Ny1=Y1+1
Ny2=Y2+1
Nx1=MIN(X2+1,79)
Nx2=Nx1+1
RESTSCREEN( Ny1, Nx1, Ny2, Nx2,;
   TRANSFORM( SAVESCREEN(Ny1,  Nx1 , Ny2,  Nx2),;
   REPLICATE("XXX", Ny2 - Ny1 + 1 ) ) )
RETURN 0
*** End of WSHADOW() ***
