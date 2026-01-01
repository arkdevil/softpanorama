#include <stream.hxx>

main()
{
    char cv[10];
    int iv[10];

    char* pc = cv;
    int* pi = iv;

   cout << "char* " << long(pc+1)-long(pc) << "\n";
   cout << "int* "  << long(pi+1)-long(pi) << "\n";
}

