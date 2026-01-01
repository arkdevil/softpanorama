#include<stream.hxx>

extern void exit( int );
extern void error( char* );

// 1.11
class vector { 
    int *v;
    int sz;
public: 
         vector(int);   // constructor
         ~vector();    // destructor
    int size() { return sz; }
    void set_size(int);
    int& operator[](int);
    int& elem(int i) { return v[i]; }
};

vector::vector(int s)
{
    if (s<=0) error("bad vector size");
    sz = s;
    v = new int[s];
}

int& vector::operator[](int i)
{
     if (i<0 || sz<=i) error("vector index out of range");
     return v[i];
}

vector::~vector()
{
    delete v;
}

// 1.14
class Vec : public vector {
public:
    Vec(int s) : (s) {}
    Vec(Vec&);
    ~Vec() {}
    void operator=(Vec&);
    void operator*=(Vec&);
    void operator*=(int);  
};

Vec::Vec(Vec& a) : (a.size())
{
  int sz = a.size();
  for (int i = 0; i<sz; i++) elem(i) =a.elem(i);
}

void Vec::operator=(Vec& a)
{
   int s = size();
   if (s!=a.size()) error("bad vector size for =");
   for (int i =0; i<s; i++) elem(i)=a.elem(i);
} 

Vec operator+(Vec& a, Vec& b)
{
   int s = a.size();
   if (s != b.size()) error("bad vector size for +");
   Vec sum(s);
   for (int i=0; i<s; i++)
      sum.elem(i) = a.elem(i) + b.elem(i);
   return sum;
} 


void error(char* p)
{
  cerr << p << "\n";
  exit (1);
}

void vector::set_size(int) {  }

main()
{
   Vec a(10);
   Vec b(10);
   for (int i=0; i<a.size(); i++) a[i] = i;
   b = a;
   Vec c = a+b;
   for (i=0; i<c.size(); i++) cout << c[i] << "\n";
} 

