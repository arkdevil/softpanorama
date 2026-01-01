/*
 * Listing 16 -- model-1a.c
 *
 * This module is an order-1 fixed-context modeling unit that can
 * be using in conjunction with comp-1.c and expand-1.c to compress
 * and expand files.  It is a very simple implementation of an order-1
 * model, using the same techniques for storing counts as were used
 * in model-1.c.  This means that it uses a lot of memory, around
 * 140 Kbytes, and that it spends a lot of time updating the table.
 * Since it can loop up context tables with a simple index on the
 * context character, it is still pretty fast.
 *
 * Building the compression and expansion programs with this model
 * requires moving up to compact model.
 *
 * Building the compressor:
 *
 * Turbo C:     tcc -w -mc comp-1.c model-1a.c bitio.c coder.c
 * QuickC:      qcl /AC /W3 comp-1.c model-1a.c bitio.c coder.c
 * Zortech:     ztc -mc comp-1.c model-1a.c bitio.c coder.c
 * *NIX:        cc -o comp-1 comp-1.c model-1a.c bitio.c coder.c
 *
 * Building the decompressor:
 *
 * Turbo C:     tcc -w -mc expand-1.c model-1a.c bitio.c coder.c
 * QuickC:      qcl /AC /W3 expand-1.c model-1a.c bitio.c coder.c
 * Zortech:     ztc -mc expand-1.c model-1a.c bitio.c coder.c
 * *NIX:        cc -o expand-1 expand-1.c model-1a.c bitio.c coder.c
 */
#include <stdio.h>
#include <stdlib.h>
#include "coder.h"
#include "model.h"

/*
 * *totals[] is an array of pointers to context tables.  The EOF
 * character doesn't get a context table, since we stop encoding
 * as soon as that character appears.  Each context table is
 * an array of ints with indices ranging from -1 to 255.
 */
short int *totals[ 256 ];
/*
 * context is the last character encoded or decoded.  It is
 * used to index to the appropriate context table.  We start the
 * model with an arbitray context of 0;
 */
int context = 0;

/*
 * To initialize the model, I create all 256 context tables, and
 * set all the counts in the table to 1.  By default, the model
 * starts up in context 0, as if the last byte in was '\0'.  Since
 * each context table is supposed to be indexed from -1 to 255,
 * I increment the pointer to the table in totals[], so that the
 * array can be safely indexed with -1.
 */
void initialize_model()
{
    int i;
    short int j;
    int array_size;

    array_size = sizeof( short int * ) * ( 257 + 1 );
    for ( i = 0 ; i < 256 ; i++ )
    {
        totals[ i ] = (short int *) malloc( array_size ) ;
        if ( totals[ i ] == NULL )
        {
            printf( "Error allocating table space!\n" );
            exit( 1 );
        }
        totals[ i ]++;
        for ( j = -1 ; j <= 256 ; j++ )
            totals[ i ][ j ] = j + 1;
    }
}

/*
 * When the table is updated, every count above "symbol" needs to
 * be incremented, which is somewhat expensive.  If the counts
 * have become to large, the table needs to be rescaled.  While
 * rescaling, we have to make sure that none of the counts drop
 * below 1.  After the update is complete, the context is changed
 * to be the symbol that was just updated.
 */
void update_model( int symbol )
{
    int i;

    for ( i = symbol+1 ; i <= 256; i++ )
        totals[ context ][ i ]++;
    if ( totals[ context ][ 256 ] == MAXIMUM_SCALE )
    {
        for ( i = 0 ; i <= 256 ; i++ )
	{
            totals[ context ][ i ] /= 2;
            if ( totals[ context ][ i ] <= totals[ context ][ i-1 ])
                totals[ context ][ i ] = totals[ context ][ i-1 ] + 1;
	}
    }
    context = symbol;
}

/*
 * Since the context table can be directly indexed with the
 * symbol, getting the low and high counts for the particular
 * symbol is nice and easy.
 */
int convert_int_to_symbol( int c, SYMBOL *s )
{
    s->scale = totals[ context ][ 256 ];
    s->low_count = totals[ context ][ c ];
    s->high_count = totals[ context ][ c + 1 ];
    return( 0 );
}
/*
 * The symbols scale is always in the same place, which is nice.
 */
void get_symbol_scale( SYMBOL *s )
{
    s->scale = totals[ context ][ 256 ];
}
/*
 * To find the symbol whose low and high values straddle count
 * requires walking through the table until a match is found.
 * This is a lengthy operation, and helps to keep decoding
 * slower than encoding.
 */
int convert_symbol_to_int( int count, SYMBOL *s )
{
    int c;

    for ( c = 256; count < totals[ context ][ c ] ; c-- )
        ;
    s->high_count = totals[ context ][ c + 1 ];
    s->low_count = totals[ context ][ c ];
    return( c );
}

