#include "coproc.h"

int     proc1(  );
int     proc2(  );

main(  )
{
	printf( "Trying to create the 1st process\n" );
	run1coproc( proc1, 10, 0 );
}

int     z = 1;

proc1(  )
{
	int     c;

	printf( "proc1, pid=%d\n", cogetpid(  ) );
	printf( "%d' Forking...\n", cogetpid(  ) );

	if ( cofork( proc2, 10, 2 ) < 0 )
	{
		printf( "%d' failed\n", cogetpid(  ) );
		return;
	}
	printf( "%d' sleeping\n", cogetpid(  ) );

	for ( c = 0; c < 3; c++ )
	{
		cosleep( &lbolt, 20 );
		printf( "%d' proc1 waken up\n", cogetpid(  ) );
	}
	printf( "%d' exiting\n", cogetpid(  ) );
	coexit(  );
	printf( "%d' had not exit\n", cogetpid(  ) );
	return;
}

proc2(  )
{
	printf( "proc2, pid=%d\n", cogetpid(  ) );

	if ( z )
	{
		printf( "%d' Trying to fork...\n", cogetpid(  ) );
		if ( cofork( proc2, 10, 2 ) < 0 )
		{
			printf( "%d' failed\n", cogetpid(  ) );
			return;
		}
		z = 0;
		printf( "%d' sleeping on z\n", cogetpid(  ) );
		cosleep( &z, 30 );
		printf( "%d' waken up, exiting\n", cogetpid(  ) );
		return;
	}
	printf( "%d' waking up on z\n", cogetpid(  ) );
	cowakeup( &z );
	printf( "%d' exiting\n", cogetpid(  ) );
}
