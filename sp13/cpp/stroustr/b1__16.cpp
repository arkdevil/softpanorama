#include <vector.hxx>

declare(vector,int);
implement(vector,int);

main()
{
    vector(int) vv(10);
    vv[2] = 3;
    vv[10] = 4;		// range error
}

