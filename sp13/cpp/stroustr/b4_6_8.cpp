// This version of the program does not assume sizeof(int)==sizeof(char*) !

#include <stream.hxx>
#include <stdarg.hxx>

extern void exit(int);
void error (int ...);

main(int argc, char* argv[])
{
    switch (argc) {
    case 1:
        error(0,argv[0],(char*)0);
        break;
    case 2:
        error(0,argv[0],argv[1],(char*)0);
        break;
    default :
       error(1,"with",dec(argc-1),"arguments",(char*)0);
    }
}


void error(int n ...)
{
   va_list ap;
   va_start(ap,n);

   for (;;) {
       char *p = va_arg(ap,char*);
       if (p == 0) break;
       cerr << p << " ";
   }

   va_end(ap);

   cerr << "\n";
   if (n) exit(n);
}

