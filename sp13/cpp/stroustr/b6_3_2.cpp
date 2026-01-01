
#include "stream.hxx"

int error (char * p)
{
   cout << p << "\n";
   return 1;
}

class tiny {
    char v;
    tiny assign(int i)
    {  v = (i&~63) ? (error("range error"),0) : i; return *this; }
public:
    tiny (int i)       { assign(i); }
    tiny (tiny& t)      { v = t.v; }
    tiny operator=(tiny& t1) { v = t1.v; return *this; }
    tiny operator=(int i ) { return assign(i); }  
    int operator int()         { return v; }
};

void main()
{
   tiny c1 = 2;
   tiny c2 = 62;
   tiny c3 = (c2 - c1);
   tiny c4 = c3;
   int i = (c1 + c2);
   c1 = (c2 + (2 * c1));
   c2 = c1 - i;
   c3 = c2;
}

