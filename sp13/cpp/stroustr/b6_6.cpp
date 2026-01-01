#include <stream.hxx>

extern int strcpy(char* , char*);

extern int strlen(char *);

struct string {
     char *p;
     int size;
     inline string(int sz) { p = new char[size=sz]; }
     string(char *);
     inline ~string() { delete p; }
     void operator=(string&);
     string(string& );
};

string::string(char* s)
{
   p = new char [size = strlen(s) + 1]; 
   strcpy (p,s);
}
  
void string::operator=(string& a)
{
   if (this == &a) return;
   delete p;
   p=new char[size=a.size];
   strcpy(p,a.p);
}


string::string(string& a)
{
   p=new char[size=a.size];
   strcpy(p,a.p);
}
string g(string arg)
{
   return arg;
}

main()
{
   string s = "asdf";
   s = g(s);
   cout << s.p << "\n";
}

