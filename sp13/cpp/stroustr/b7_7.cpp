
#include <stream.hxx>

struct base { base(); };

struct derived : base { derived(); };

base:: base()
{
   cout << "\tbase 1: this=" << long(this) << "\n";
   if (this == 0) this = (base*)27;
   cout << "\tbase 2: this=" << long(this) << "\n";
}

derived::derived()
{
   cout << "\tderived 1: this=" << long(this) << "\n";
   if (this == 0) this = (derived*)43;
   cout << "\tderived 2: this=" << long(this) << "\n";
}

main()
{
   cout << "base b;\n";
   base b;
   cout << "new base;\n";
   new base;
   cout  << "derived  d;\n";
   derived d;
   cout << "new derived;\n";
   new derived;
   cout << "new derived;\n";
   new derived;
   cout << "at the end\n";
}

