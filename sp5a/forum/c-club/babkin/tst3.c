#include <stdio.h>
#include "coproc.h"

#define prsum printf("%d\n", a+b+c+d+e+z+g+h+i+j )
extern  f(  );

main(  )
{
	printf( "calling run1coproc\n" );
	run1coproc( f, 10, 2 );
	printf( "returning from run1coproc\n" );

}

int     x = 0;
int     f_flag1,
        f_flag2;

f(  )
{
	int     a = 1,
	        b = 2,
	        c = 3,
	        d = 4,
	        e = 5,
	        z = 6,
	        g = 7,
	        h = 8,
	        i = 9,
	        j = 10;

	if ( x == 0 )
	{
		cofork( f, 10, 2 );
		x++;
		prsum;
		printf( "%d - sleeping\n", cogetpid(  ) );
		cosleep( &f_flag1 );
		prsum;
		printf( "%d - switching\n", cogetpid(  ) );
		cosleep( &lbolt );
		prsum;
		printf( "%d - waking up\n", cogetpid(  ) );
		cowakeup( &f_flag2 );
		prsum;
		printf( "%d - finishing\n", cogetpid(  ) );
	}
	else
	{
		prsum;
		printf( "%d - switching\n", cogetpid(  ) );
		cosleep( &lbolt );
		prsum;
		printf( "%d - waking up\n", cogetpid(  ) );
		cowakeup( &f_flag1 );
		prsum;
		printf( "%d - sleeping\n", cogetpid(  ) );
		cosleep( &f_flag2 );
		prsum;
		printf( "%d - finishing\n", cogetpid(  ) );
	}
}
