//	This program implements a huge array of any type
//	It uses the file 'bigvec.c', which contains 'big::operator[]()'.
//	To compile the program:		ccxx huge.cxx bigvec.c

#include <stream.hxx>

typedef long typ;	// typedef float typ; would give a float array

class big {		// 'big' behaves like 'typ', except for operator[]
	typ p;
public:
	big(typ t) { p = t; }			// 'cast to' operator
	typ operator typ() { return p; }	// 'cast from' operator
	typ& operator[](long);			// subscript operator
};


extern typ bigarray[];		// defined as huge in 'bigvec.c'

main ()
{
	cout << "Printing every 1000th element of a huge array...\n";
	big *a = (big*) bigarray;
	for ( long j=0; j<40000; j+=1000 )
		a[j] = j;
	for ( j-=1000; j>0; j-=1000 )
		cout << a[j] << "\n";
}
