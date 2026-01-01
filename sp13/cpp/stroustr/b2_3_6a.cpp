#include <stream.hxx>

extern int strlen(char*);

char alpha[] = "abcdefghijklmnopqrstuvwxyz";

main ()
{
   int sz = strlen(alpha);

   for (int i=0; i<sz; i++) {
       char ch = alpha[i];
       cout << "'" << chr(ch) << "'"
            << " = " << ch
            << " = 0" << oct(ch)
            << " = 0x" << hex(ch) << "\n";
   }
}

