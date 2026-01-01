/* FILL.C illustrates color, filling, and linestyle functions including:
 *    _setlinestyle      _setfillmask       _setcolor
 *    _getlinestyle      _floodfill
 *
 * The _getfillmask function is not shown, but its use is similar to
 * _getlinestyle.
 */

#include <conio.h>
#include <graph.h>
#include <time.h>
#include <stdlib.h>
#include <stddef.h>

fill()
{
    short x, y, xinc, yinc, xwid, ywid;
    unsigned char fill[8];
    struct videoconfig vc;
    unsigned seed = (unsigned)time( NULL ); /* Different seed each time   */
    short i, color, mode = _VRES16COLOR;

    while( !_setvideomode( mode ) )         /* Find a valid graphics mode */
	mode--;
    if( mode == _TEXTMONO )
	exit( 1 );                          /* No graphics available      */
    _getvideoconfig( &vc );

    xinc = vc.numxpixels / 8;               /* Size variables to mode     */
    yinc = vc.numypixels / 8;
    xwid = (xinc / 2) - 4;
    ywid = (yinc / 2) - 4;

    /* Draw circles and lines with different patterns. */
    for( x = xinc; x <= (vc.numxpixels - xinc); x += xinc )
    {
	for( y = yinc; y <= (vc.numypixels - yinc); y += yinc )
	{
	    /* Vary random seed, randomize fill and color. */
	    srand( seed = (seed + 431) * 5 );
	    for( i = 0; i < 8; i++ )
		fill[i] = rand();
	    _setfillmask( fill );
	    color = (rand() % vc.numcolors) + 1;
	    _setcolor( color );

	    /* Draw ellipse and fill with random color. */
	    _ellipse( _GBORDER, x - xwid, y - ywid, x + xwid, y + ywid );
	    _setcolor( (rand() % vc.numcolors) + 1 );
	    _floodfill( x, y, color );

	    /* Draw vertical and horizontal lines. Vertical line style
	     * is the opposite of (NOT) horizontal style. Since lines are
	     * overdrawn with several linestyles, this has the effect of
	     * combining colors and styles.
	     */
	    _setlinestyle( rand() );
	    _moveto( 0, y + ywid + 4 );
	    _lineto( vc.numxpixels - 1, y + ywid + 4 );
	    _setlinestyle( ~_getlinestyle() );
	    _moveto( x + xwid + 4, 0 );
	    _lineto( x + xwid + 4, vc.numypixels - 1 );
	}
    }

}

