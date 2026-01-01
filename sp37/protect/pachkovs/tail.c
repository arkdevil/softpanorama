#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define GRANULARITY     (512)
#define ID_LENGTH       30

int
main( int argc, char *argv[] )
{
        int     handle ;
        long    length ;
        char    buf[ ID_LENGTH + 1 ] ;
        int     size ;

if( ( handle = open( argv[ 0 ], O_RDWR | O_BINARY ) ) == -1 ){
        perror( argv[ 0 ] ) ;
        return -1 ;
        }
length = filelength( handle ) ;
if( GRANULARITY - length % GRANULARITY < ID_LENGTH ){
        printf( "File %s has no sufficient tail !\n", argv[ 0 ] ) ;
        close( handle ) ;
        return -1 ;
        }
if( argc == 2 ){        /* Write to tail */
        lseek( handle, 0, SEEK_END ) ;
        size = min( strlen( argv[ 1 ] ) + 1, ID_LENGTH ) ;
        if( write( handle, argv[ 1 ], size ) != size ){
                perror( argv[ 0 ] ) ;
                close( handle ) ;
                return -1 ;
                }
        }
else {
        lseek( handle, ID_LENGTH, SEEK_END ) ;
        write( handle, " ", 1 ) ;
        lseek( handle, length, SEEK_SET ) ;
        read( handle, buf, ID_LENGTH ) ;
        printf( "File tail is \"%s\"\n", buf ) ;
        }
chsize( handle, length ) ;
close( handle ) ;
return 0 ;
}
