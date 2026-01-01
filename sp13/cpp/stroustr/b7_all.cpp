#include "shape.h"
#include "b7_all.hxx"
// /*
#line 5 "b7_all.cxx" // */

main()
{
   shape* p1 = new rectangle(point(0,0),point(10,10));
   shape* p2 = new line(point(0,15),17);
   shape* p3 = new myshape(point(15,10),point(27,18));
   shape_refresh();
   p3->move(-10,-10);
   stack(p2,p3);
   stack(p1,p2);
   shape_refresh();
}

