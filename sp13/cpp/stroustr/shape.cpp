#include "shape.h"

sp_gslist shape_list;
// 7.6.2
rectangle::rectangle(point a, point b)
{
    if (a.x <= b.x) {
       if (a.y <= b.y) {
          sw = a;
          ne = b;
       }
       else {
          sw = point(a.x,b.y);
          ne = point(b.x,a.y);
       }
    }
    else {
       if (a.y <= b.y) {
          sw = point(b.x,a.y);
          ne = point(a.x,b.y);
        }
        else {
            sw = b;
            ne = a;
        }
     }
}

void rectangle::draw()
{
    point nw(sw.x,ne.y);
    point se(ne.x,sw.y);
    put_line(nw,ne);
    put_line(ne,se);
    put_line(se,sw);
    put_line(sw,nw);
}

void shape_refresh()
{
  screen_clear();
  sp_gslist_iter next(shape_list);
  shape* p;
  while ( p=next() ) p->draw();
  screen_refresh();
}

void stack (shape* q, shape* p)
{
   point n = p->north();
   point s = q->south();
   q->move(n.x-s.x,n.y-s.y+1);
}
