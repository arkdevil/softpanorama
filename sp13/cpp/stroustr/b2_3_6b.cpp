#include <stream.hxx>

char v[2][5] = {
     'a', 'b', 'c', 'd', 'e',
     '0', '1', '2', '3', '4'
};

main() {
   for ( int i = 0; i<2; i++) {
       for (int j = 0; j <5; j++)
           cout << "v[" << i << "][" << j
                << "]=" << chr(v[i][j]) << "  ";
      cout << "\n";
  }
}

