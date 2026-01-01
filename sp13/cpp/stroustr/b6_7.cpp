#include <stream.hxx>
#include <string.h>
struct pair {
   char * name;
   int val;
};

class assoc {
  pair * vec;
  int max;
  int free;
public:
  assoc(int);
  int& operator[](char* );
  void print_all();
};

assoc::assoc(int s)
{
  max = (s<16) ? s: 16;
  free = 0;
  vec = new pair[max];
}
 
int& assoc::operator[](char * p)
/*
   maintain a set of "pair"s
   search for p,
   return a reference to the integer part of its "pair"
   make a new "pair" if "p" has not been seen
*/
{
   register pair* pp;
   for (pp=&vec[free-1]; vec<=pp; pp-- )
      if (strcmp(p, pp->name)==0) return pp->val;

   if (free==max) { // overflow: grow the vector
      pair* nvec = new pair[max*2];
      for (int i=0; i<max; i++) nvec[i] = vec[i];
      delete vec;
      vec = nvec;
      max = 2*max;
   }

    pp = &vec[free++];
    pp->name = new char[strlen(p)+1];
    strcpy(pp->name,p);
    pp->val = 0;
    return pp->val;
}

void assoc::print_all()
{
   for (int i=0; i<free; i++)
       cout << vec[i].name << ": " << vec[i].val << "\n";
}

main()
{
   const MAX = 256;
   char buf[MAX];
   assoc vec(512);
   while ( cin>>buf) vec[buf]++;
   vec.print_all();
}

