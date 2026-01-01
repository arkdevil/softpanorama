
#include <stream.hxx>
#include <string.h>

struct pair {
     char* name;
     int val;
};

class assoc {
friend class assoc_iterator;
     pair* vec;
     int max;
     int free;
public:
     assoc(int);
     int& operator[](char*);
};
class assoc_iterator {
    assoc* cs;
    int i;
public:
    assoc_iterator(assoc& s) { cs = &s; i = 0; }
    pair* operator()()
          { return (i<cs->free)? &cs->vec[i++] : 0; }
};

assoc::assoc(int s)
{
   max = (s<16) ? s : 16;
   free = 0;
   vec = new pair[max];
}
      
int& assoc::operator[](char* p)
{
   register pair* pp;

   for (pp=&vec[free-1]; vec<=pp; pp-- )
       if (strcmp(p,pp->name)==0) return pp->val;

   if (free ==max) {
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

main()
{
   const MAX = 256;
   char buf[MAX];
   assoc vec(512);
   while ( cin>>buf) vec[buf]++;
   assoc_iterator next(vec);
   pair* p;
   while (p = next() )
       cout << p->name << ": " << p->val << "\n";
}

