#include "slist.h"
#include "screen.h"

// 7.6.2
struct shape;
typedef shape* sp;

// 7.3.5
// This section has been hand-coded because of the Lattice pre-processor

struct sp_gslist : slist {
    int insert(sp a) { return slist::insert( ent(a) ); }
    int append(sp a) { return slist::append( ent(a) ); }
    sp get() { return sp ( slist::get() ); }
    sp_gslist() { }
    sp_gslist(sp a) : (ent(a)) { }
};

struct sp_gslist_iter : slist_iterator {
    sp_gslist_iter( sp_gslist& s ) : ( (slist&)s ) { }
    sp operator()() { return sp( slist_iterator::operator()() ); }
};   

// 7.6.2
extern sp_gslist shape_list;

struct shape {
     shape() { shape_list.append(this); }

     virtual point north() { return point(0,0); }
     virtual point south() { return point(0,0); }
     virtual point east () { return point(0,0); }
     virtual point neast() { return point(0,0); }
     virtual point seast() { return point(0,0); }

     virtual void draw() {};
     virtual void move(int, int) {};
};

class line : public shape {
     point w,e;
public:
     point north()
         { return point ((w.x+e.x)/2,e.y<w.y?w.y:e.y); }
     point south()
         { return point ((w.x+e.x)/2,e.y<w.y?e.y:w.y); }

     void move (int a, int b)
          { w.x += a; w.y += b; e.x += a; e.y += b; }
     void draw() { put_line(w,e); }

     line (point a, point b) { w = a; e = b; }
     line(point a, int l)
         { w = point(a.x+l-1,a.y); e = a; }
};



class rectangle : public shape {
    point sw,ne;
public:
    point north() { return point((sw.x+ne.x)/2,ne.y); }
    point south() { return point((sw.x+ne.x)/2,sw.y); }
    point neast() { return ne; }
    point swest() { return sw; }
    void move(int a, int b)
       { sw.x+=a; sw.y+=b; ne.x+=a; ne.y+=b; }
    void draw();
    rectangle( point, point );
};

void shape_refresh();
void stack(shape*,shape*);
