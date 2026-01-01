#include <stream.hxx>

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

// 1.13
class vec : public vector {
    int low, high;
public:
    vec(int, int);
    int& elem(int);
    int& operator[](int);
};


main()
{
   vector a(10);
   for (int i=0; i<a.size(); i++) {
       a[i] = i;
       cout << a[i] << " ";
   }
   cout << "\n";
   vec b(10,19);
   for (i=0; i<b.size(); i++) b[i+10] = a[i];
   for (i=0; i<b.size(); i++) cout << b[i+10] << " ";
   cout << "\n";
}

extern void exit(int);
// 1.13
void error(char* p)
{
  cerr << p << "\n";
  exit (1);
}

// 1.11
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

// 1.13
int& vec::elem(int i)
{
    return vector::elem(i-low);
}

vec::vec(int lb, int hb) : (hb-lb+1)
{
    if (hb-lb<0) hb = lb;
    low = lb;
    high = hb;
}

void vector::set_size(int) { /* dummy */ }

int& vec::operator[](int i)
{
   if (i<low || high<i) error("vec index out of range");
   return elem(i);
}

