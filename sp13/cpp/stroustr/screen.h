// 7.6.1 "screen.h"
const XMAX = 40, YMAX = 24;

struct point {
      int x,y;
      point() { }
      point(int a, int b) { x=a; y=b; }
};

overload put_point;
extern void put_point(int, int);
inline void put_point(point p) { put_point(p.x,p.y); }

overload put_line;
extern void put_line(int, int, int, int); 
inline void put_line(point a, point b) { put_line(a.x,a.y,b.x,b.y); }

extern void screen_init();
extern void screen_refresh();
extern void screen_clear();

