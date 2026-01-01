#include <conio.h>
#include <stdio.h>
#include "preword.h"

char    *err[] =
	{
	 "Usage:        PreWord <source file name> [<target file name>] [options...]",
	 "Cannot open source file",
	 "Too many files specified",
	 "Cannot open intermediate file",
	 "Cannot delete source file for replacing;\n For results please look at PREWORD.TMP",
	 "Cannot delete intermediate file",
	 "Cannot write to file - may be disk full",
	 "Cannot rename intermediate file;\n For results please look at PREWORD.TMP",
	 "Not enough memory",
	 "Paragraph too big to fit in buffer, please contact (044) 514-26-88"

	};

char    *warn[] =
	{
	 "Source file will be replaced",
	};

void    error( int n )
{
 if ( n < 0 ) { printf( "\nThank's for using PreWord!\n" ); exit( 0 ); }
	 else { printf( "\n\n%s\nType PreWord ? for details\n",err[n] ); exit( 1 ); }
}

void    warning( int n )
{

 printf( "\n\tWARNING:\t%s\n",warn[n] );
}

