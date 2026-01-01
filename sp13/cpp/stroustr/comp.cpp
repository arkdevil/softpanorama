#include	<complex.hxx>

const	complex	i ( 0.0, 1.0 );

main	()

{
	complex	z1, z2;

	z1	= complex(1.0) + i;
	z2	= complex(1.0) / z1;

	cout << z2;

	if	( i * i != -1.0 )
		cout << "\nerror";

}

