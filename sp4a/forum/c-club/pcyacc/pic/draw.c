
#include <stdio.h>
#include <graph.h>
#include "defs.h"
#include "pic.h"

#define GMODE _HRESBW
static char *gmname = "HRESBW";

struct videoconfig vc;

picdraw() {
int i;

  if (! _setvideomode(GMODE)) exception (FATAL, "nonsupported graphics mode");
  _getvideoconfig(&vc);
  _rectangle(_GBORDER, 0, 15, vc.numxpixels-1, vc.numypixels-1);
  _setlogorg(vc.numxpixels/2 - 1, vc.numypixels/2 - 1);

/*
  _clearscreen(_GCLEARSCREEN);
*/
  for (i=0; i<ocount; i++) {
    _setcolor((objlst[i]->color==BLACK) ? _BLACK : _WHITE);
    _setlinestyle((objlst[i]->style==SOLID) ? 0xffff : 0xaaaa);
    switch (objlst[i]->shape) {
      case LINE: {
        draw_line(objlst[i]->npoints, objlst[i]->x_coord, objlst[i]->y_coord);
        break;
      }
      case POLYGON: {
        draw_polygon(objlst[i]->npoints, objlst[i]->x_coord, objlst[i]->y_coord);
        break;
      }
      case BOX: {
        draw_box(objlst[i]->npoints, objlst[i]->x_coord, objlst[i]->y_coord);
        break;
      }
      case CIRCLE: {
        draw_circle(objlst[i]->npoints, objlst[i]->x_coord, objlst[i]->y_coord);
        break;
      }
      case ELLIPSE: {
        draw_ellipse(objlst[i]->npoints, objlst[i]->x_coord, objlst[i]->y_coord);
        break;
      }
      default: {
      }
    }
  }
  fprintf(stdout, "press <CR> to clear screen and exit ..."); getchar();
  _setvideomode(_DEFAULTMODE);
}

draw_line(n, xs, ys)
int n;
int xs[], ys[];
{ int i;

  _moveto(xs[0], ys[0]);
  for (i=1; i<n; i++) _lineto(xs[i], ys[i]);
}

draw_polygon(n, xs, ys)
int n;
int xs[], ys[];
{ int i;

  _moveto(xs[0], ys[0]);
  for (i=1; i<n; i++) _lineto(xs[i], ys[i]);
  _lineto(xs[0], ys[0]);
}

draw_box(n, xs, ys)
int n;
int xs[], ys[];
{
  _rectangle(_GBORDER, xs[0], ys[0], xs[1], ys[1]);
}

draw_circle(n, xs, ys)
int n;
int xs[], ys[];
{
  _ellipse(_GBORDER, xs[0], ys[0], xs[1], ys[1]);
}

draw_ellipse(n, xs, ys)
int n;
int xs[], ys[];
{
  _ellipse(_GBORDER, xs[0], ys[0], xs[1], ys[1]);
}

