#include <stream.hxx>

struct cl
{
    char* val;
    void print(int x) { cout << val << x << "\n"; }
    cl(char *v) { val = v; }
};


typedef void (*PROC)(void*,int);

main()
{
    cl z1("z1 ");
    cl z2("z2 ");
    PROC pf1 = PROC(&z1.print);
    PROC pf2 = PROC(&z2.print);
    z1.print(1);
    (*pf1)(&z1,2);
    z2.print(3);
    (*pf2)(&z2,4);
}

