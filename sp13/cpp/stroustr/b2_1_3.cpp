#include <stream.hxx>

int a = 1;

void f()
{
    int b = 1;
    static int c = 1;
    cout << " a = " << a++
         << " b = " << b++
         << " c = " << c++ << "\n";
}

main ()
{
   while (a < 4) f();
}

