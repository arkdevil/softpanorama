
#include <stream.hxx>

class intset {
     int cursize, maxsize;
     int *x;
public:
     intset(int m, int n);
     ~intset();

     int member(int t);
     void insert(int t);

     void iterate(int& i)  { i = 0; }
     int ok(int& i)        { return i<cursize; }
     int next(int& i)      { return x[i++]; }
};

extern void exit (int);

void error(char *s)
{
    cout << "set: " << s << "\n";
    exit(1);
} 

extern int atoi(char *);

extern int rand();

int randint (int u)  // in the range 1..u
{
    int r = rand();
    if (r < 0) r = -r;
    return 1 + r%u ;
}

intset::intset(int m, int n)
{
    if (m<1 || n<m) error("illegal intset size");
    cursize = 0;
    maxsize = m;
    x = new int[maxsize];
}

intset::~intset()
{
   delete x;
}

void intset::insert(int t)
{
    if (++cursize > maxsize) error("too many elements");
    int i = cursize-1;
    x[i] = t;

    while (i>0 && x[i-1]>x[i]) {
        int t = x[i];
        x[i] = x[i-1];
        x[i-1] = t;
        i--;
    }
}

int intset::member(int t)
{
    int l = 0;
    int u = cursize-1;

    int m =0;
    while (l <= u) {
        m = (l+u)/2;
        if (t < x[m])
           u = m-1;
        else if (t > x[m])
            l = m+1;
        else
            return 1;    // found
    }
    return 0;    // not found
}

void print_in_order(intset* set)
{
   int var;
   set->iterate(var);
   while (set->ok(var)) cout << set->next(var) << "\n";
}

main (int argc, char *argv[])
{
   if (argc != 3) error("two arguments expected");
   int count = 0;
   int m = atoi(argv[1]);
   int n = atoi (argv[2]);
   intset s(m,n);

   int t = 0;
   while (count <m) {
       t = randint(n);
       if (s.member(t)==0) {
          s.insert(t);
          count++;
      }
   }
   print_in_order(&s);
}

