#include <stream.hxx>
extern float pow(float, int);

main()
{
   for (int i=0; i<10; i++) cout << pow(2,i) << "\n";
}

extern void error(char *);

float pow(float x, int n)
{
    if (n < 0)  {
       error ("sorry, negative exponent to pow()");
       return 0;
       }

    switch (n) {
    case 0:   return 1;
    case 1:   return x;
    default:  return x*pow(x,n-1);
    }
}

void error(char *s)
{
   cout << s;
} 

