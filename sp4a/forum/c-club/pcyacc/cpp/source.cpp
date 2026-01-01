
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


/*
 * a class definition for integer sets
 */

extern void exit(int);

class inset {
  int cursize;
  int maxsize;
  int *x;
public:
  int test;
  int iterate(int& i) { i = 0; }
  int ok(int& i) { int k; k=i<cursize; return k; }
  int next(int& index) { return x[index++]; }

  inset(int m, int n); // at most m ints in 1 .. n
  ~inset();

  int member(int t);   // is t a member?
  void insert(int t);  // add t to set

};

/* class constructor */

inset::inset(int m, int n) {

  if (m<1 || n<m) exit(1);
  cursize = 0;
  maxsize = m;
  x = new int[maxsize];
}

/* class destructor */

inset::~inset() {

  delete x;
}

/* class interface: add an element to set */

void inset::insert(int t) {  // ints are kept in ascending order

  if (++cursize > maxsize) exit(1);

  int i = cursize - 1;
  x[i] = t;

  while (i>0 && x[i-1]>x[i]) { // swapping
    int s = x[i];
    x[i] = x[i-1];
    x[i-1] = s;
    i--;
  }
}

/* class interface: membership testing */

int inset::member(int t) { // binary search

  int l = 0;
  int u = cursize - 1;
  int m;

  while (l <= u) {
    m = (l+u) / 2;
    if (t < x[m]) {
      u = m - 1;
    } else if (t > x[m]) {
      u = l + 1;
    } else {
      return 1;
    }
  }
  return 0;
}
