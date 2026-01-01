#include <stream.h>
#include "screen.h"

// 7.6.1
char black='*';
char white=' ';

char screen[XMAX][YMAX];

void screen_init()
{
  for (int y=0; y<YMAX; y++)
      for (int x=0; x<XMAX; x++)
          screen[x][y] = white;
}

inline int on_screen(int a, int b)
{
    return 0<=a && a<XMAX && 0<=b && b<YMAX;
}

void put_point(int a, int b)
{
     if (on_screen(a,b)) screen[a][b] = black;
}

void put_line(int x0, int y0, int x1, int y1) 
{
    register dx = 1;
    int a = x1 - x0;
    if (a < 0) dx = -1, a = -a;
    register dy = 1;
    int b = y1 - y0;
    if (b < 0) dy = -1, b = -b;
    int two_a = 2*a;
    int two_b = 2*b;
    int xcrit = -b + two_a;
    register eps = 0;
    for(;;) {
        put_point(x0,y0);
        if(x0==x1 && y0==y1) break;
        if(eps <= xcrit) x0 +=dx, eps += two_b;
        if (eps>=a || a<=b) y0 += dy,eps -= two_a;
    }
}

void screen_clear() { screen_init(); }

void screen_refresh()
{
   for (int y=YMAX-1; 0<=y; y--) {
       for (int x=0; x<XMAX; x++) 
           cout.put(screen[x][y]);
       cout.put('\n');
   }
}
