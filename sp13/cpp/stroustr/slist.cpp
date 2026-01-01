#include <stream.h>
#include "slist.h"

extern void exit(int);
typedef void (*PFC)(char*);
extern PFC slist_handler;
extern PFC set_slist_handler(PFC);

void default_error(char* s)
{
   cerr << s << "\n";
   exit(1);
}

PFC slist_handler = default_error;

PFC set_slist_handler(PFC handler)
{
   PFC rr = slist_handler;
   slist_handler = handler;
   return rr;
}

// 7.3.1
int slist::insert(ent a)
{
   if (last)
      last->next = new slink(a,last->next);
   else {
       last = new slink(a,0);
       last->next = last;
  }
  return 0;
}

int slist::append(ent a)
{
   if (last)
      last = last->next = new slink(a,last->next);
   else {
      last = new slink(a,0);
      last->next = last;
   }
   return 0;
} 

ent slist::get()
{
   if (last == 0) (*slist_handler)("get from empty slist");
   slink* f = last->next;
   ent r = f->e;
   last = (f==last) ? 0 : f->next;
   delete f;
   return r;
}

void slist::clear()
{
   slink* l = last;
   if (l == 0) return;
   do {
       slink* ll = l;
       l = l->next;
       delete ll;
    } while ( l !=last );
}  
