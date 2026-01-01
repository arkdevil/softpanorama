#include <stream.hxx>

main()
{
   const float fac = 2.54;
   float x, in, cm;
   char ch = 0;

for ( int i= 0; i< 8; i++) {
   cerr << "enter length: ";
   cin >> x >> ch;

   if (ch == 'i' ) {   // inch
      in = x;
      cm = x*fac;
   }
   else if (ch == 'c') { // cm
       in = x/fac;
       cm = x;
   }
   else
      in = cm = 0;
   
   cerr << in << "in = " << cm << " cm\n";
}
}

