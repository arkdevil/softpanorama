#define	UP	-1
#define	DOWN	1

extern int cdecl ScanLeft(int x, int y), cdecl ScanRight(int x, int y);

extern void cdecl Line(int,int,int,int,int);

static int FillValue;
int __BorderValue;

extern int cdecl ReadPixel(int,int);

static int near LineAdjFill(int SeedX, int y, int D, int PrevXL, int PrevXR)
//	SeedX,SeedY;		/* seed for current row of pixels */
//	D;			/* direction searched to find current row */
//	PrevXL,PrevXR;		/* endpoints of previous row of pixels */
{
	int	x;
	int	xl,xr;
	int	v;

			/* initialize to seed coordinates */
	//xl = xr = SeedX;

	xl = ScanLeft (SeedX, y)+1;/* determine endpoints of seed line segment */
	xr = ScanRight(SeedX, y)-1;

	Line( xl, y, xr, y, FillValue );	/* fill line with FillValue */


/* find and fill adjacent line segments in same direction */

	for (x=xl; x<=xr; x++)		/* inspect adjacent rows of pixels */
	{
	  v = ReadPixel( x, y+D );
	  if ( v!=__BorderValue && v!=FillValue )
	    x = LineAdjFill( x, y+D, D, xl, xr );
	}

/* find and fill adjacent line segments in opposite direction */

	for (x=xl; x<PrevXL; x++)
	{
	  v = ReadPixel( x, y-D );
	  if (v!=__BorderValue && v!=FillValue)
	    x = LineAdjFill( x, y-D, -D, xl, xr );
	}

	for (x=PrevXR; x<xr; x++)
	{
	  v = ReadPixel( x, y-D );
	  if ( v!=__BorderValue && v!=FillValue )
	    x = LineAdjFill( x, y-D, -D, xl, xr );
	}

	return xr;
}

void cdecl FillRegion(int x, int y, int color, int border_color)
{ FillValue = color;
  __BorderValue = border_color;
  LineAdjFill(x,y,UP,x,x);
}
