#include <stdio.h>
#include <string.h>

const int maxfile = 5000;
const int maxline = 80;

class line	// behaves exactly like a char* except that a line is
	 	// guaranteed to be null-terminated and <= maxline
{
	char *cont;
	line() { cont = 0; }	// null constructor is only used by friends
	void error() { printf( "line error\n" ); } // only used by members
	friend class file;
public:
	line(char*);
	operator char*() { return cont; }
};

class file	// a collection of lines, with a handle to the file-system
{
	FILE* handle;
	int mode;	// used only by the destructor, true means 'write'
	line* text;
public:
	file(char*,int);
	~file();
	line& operator[]( int j ) { return text[ j ]; }
};

class infile : public file
{
public: infile( char* name ) : ( name, 0 ) { }
};

class outfile : public file
{
public: outfile( char* name ) : ( name, 1 ) { }
};


line::line( char* s )
{
	if( ! s ) error();
	int j = strlen( s );
	if( j > maxline ) error();
	cont = new char[ j + 1 ];
	(void) strncpy( cont, s, j );
	cont[ j ] = 0;
}

file::file( char* name, int w )
{
	handle = fopen( name, ( w ? "w" : "r" ) );
	mode = w;
	text = new line[ maxfile + 1 ];
	if( mode ) return;	// 'output' files return here
	char buff[ maxline + 1 ];
	for( int j = 0; j < maxfile; j++ )
	{
		if( ! fgets( buff, maxline, handle ) ) break;
		text[ j ] = buff;
	}
	(void) fclose( handle );
	printf( "%d lines read\n", j );
}


file::~file()
{
	if( ! mode ) return;	// 'input' files return here
	for( int j = 0; j < maxfile; j++ )
		if( text[ j ] ) (void) fputs( text[ j ], handle );
		else break;
	(void) fclose( handle );
	printf( "%d lines written\n", j );
}



main( int argc, char** argv )
{
	infile input = argv[1];
	outfile output = argv[2];

	//	copy files

	for( int j = 0; j < maxfile; j++ )
		output[ j ] = input[ j ];
}


