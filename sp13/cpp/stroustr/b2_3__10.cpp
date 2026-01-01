#include <stream.hxx>

struct pair {
      char* name;
      int val;
};
extern int strlen(char*);
extern int strcpy(char*, char*);
extern int strcmp(char*, char*); 

const large = 1024;
static pair vec[large];

pair* find(char* p)
{
   for (int i=0; vec[i].name; i++)
       if (strcmp(p,vec[i].name)==0) return &vec[i];

   if (i== large) return &vec[large-1];

   return &vec[i];
}

int& value(char* p)
{
    pair* res = find(p);
    if (res->name == 0) {
       res->name = new char[strlen(p)+1];
       strcpy(res->name,p);
       res->val = 0;
    }
    return res->val;
}

const MAX = 256;


main ()
{
   char buf [MAX];

   while ( cin>>buf) value(buf)++;
  
   for (int i=0; vec[i].name; i++)
     cout << vec[i].name << ":" << vec[i].val << "\n";
}

