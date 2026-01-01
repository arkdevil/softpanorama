#include <stream.hxx>

struct employee {
friend class manager;
     employee* next;
     char*     name;
     short     department;
     virtual void print();
};

struct manager : employee {
     employee* group;
     short     level;
     void print();
};

void employee::print()
{
   cout << name << "\t" << department << "\n";
}

void manager::print()
{
    employee::print();
    cout << "\tlevel " << level << "\n";
}

void f(employee* ll)
{
   for ( ; ll; ll=ll->next) ll->print();
}

main ()
{
    employee e;
        e.name = "J. Brown";
        e.department = 1234;
        e.next = 0;
     manager m;
        m.name = "J. Smith";
        m.department = 1234;
        m.level = 2;
        m.next = &e;
f(&m);
}

