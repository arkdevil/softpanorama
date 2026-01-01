#include <stdio.h>
#include <string.h>

const int maxlen = 80;

class line
{
	char cont[ maxlen ];
public:
	line(char*);
	operator char*() { return cont; }
};

class file
{
	FILE* handle;
public:
	file(char* name) { handle = fopen( name, "r" ); }
	line operator[](int);
};

line::line(char* s)
{
	int j = strlen( s );
	if( j > maxlen ) j = maxlen;
	(void) strncpy( cont, s, maxlen );
	cont[ j ] = 0;
}


line file::operator[]( int j )
{
	static char *const empty = "";
	if( j <= 0 ) return empty;
	(void) rewind( handle );
	char buff[ 80 ];
	while( j-- ) if( ! fgets( buff, maxlen, handle ) ) return empty;
	return buff;
}


main( int argc, char** argv )
{
	const	int show = 2;
	file	text_file = argv[1];
	int 	line_number = atoi( argv[2] );

	for( int j = -show; j <= show; ++j )
		puts( text_file[ line_number + j ] );
}


