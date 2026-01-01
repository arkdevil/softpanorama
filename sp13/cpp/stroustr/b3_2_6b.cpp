#include <stream.hxx>

extern void exit( int );
void out_of_store()
{
    
    cout << "operator new failed: out of store\n";
    exit(1);
}

typedef void (*PF)();

extern PF set_new_handler(PF);

main()
{
    set_new_handler(&out_of_store);
    char *p = new char[100000000];
    cout << "done, p = " << long(p) << "\n";
}

