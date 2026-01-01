
#include <stream.hxx>

extern void exit(int);

void error(char* s, char* s2)
{
   cerr << s << " " << s2 << "\n";
   exit(1);
}

main(int argc, char* argv[])
{
   if (argc != 3) error ("wrong number of arguments","");

   filebuf f1;
   if (f1.open(argv[1],input) == 0)
      error("cannot open input file",argv[1]);
   istream from(&f1);

   filebuf f2;
   if (f2.open(argv[2],output) == 0)
      error("cannot open input file",argv[2]);
   ostream to(&f2);

   char ch;
   while (from.get(ch)) to.put(ch);

   if (!from.eof() || to.bad())
      error("something strange happened","");
}

