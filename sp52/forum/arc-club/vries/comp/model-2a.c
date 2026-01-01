/*
 * Listing 17 -- model-2a.c
 *
 * This module is an order-1 highest order modeling unit that can
 * be using in conjunction with comp-2.c and expand-2.c to compress
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
 * Turbo C:     tcc -w -mc comp-2.c model-2a.c bitio.c coder.c
 * QuickC:      qcl /AC /W3 comp-2.c model-2a.c bitio.c coder.c
 * Zortech:     ztc -mc comp-2.c model-2a.c bitio.c coder.c
 * *NIX:        cc -o comp-2 comp-2.c model-1a.c bitio.c coder.c
 *
 * Building the decompressor:
 *
 * Turbo C:     tcc -w -mc expand-2.c model-2a.c bitio.c coder.c
 * QuickC:      qcl /AC /W3 expand-2.c model-2a.c bitio.c coder.c
 * Zortech:     ztc -mc expand-2.c model-2a.c bitio.c coder.c
 * *NIX:        cc -o expand-2 expand-2.c model-1a.c bitio.c coder.c
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
short int *totals[ 257 ];
/*
 * context is the last character encoded or decoded.  It is
 * used to index to the appropriate context table.  We start the
 * model with an arbitrary context of 0;
 */
int context = 0;
int current_order = 1;
int flushing_enabled=0;
int max_order=1;        /* Here for compatibility, not used */

/*
 * To initialize the model, I create all 256 context tables, and
 * set all the counts in the table to 0.  By default, the model
 * starts up in context 0, as if the last byte in was '\0'.  Since
 * each context table is supposed to be indexed from -1 to 255,
 * I increment the pointer to the table in totals[], so that the
 * array can be safely indexed with -1.  The only symbol with a
 * non-zero when the tables are initialized is the ESCAPE code,
 * which is set to a count of 1.
 */
void initialize_model()
{
    int i;
    short int j;
    int array_size;

    array_size = sizeof( short int * ) * ( 257 + 1 );
    for ( i = 0 ; i < 257 ; i++ )
    {
        totals[ i ] = (short int *) malloc( array_size ) ;
        if ( totals[ i ] == NULL )
        {
            printf( "Error allocating table space!\n" );
            exit( 1 );
        }
        totals[ i ]++;
	for ( j = -1 ; j <= ESCAPE ; j++ )
	    totals[ i ][ j ] = 0;
	totals[ i ][ ESCAPE+1 ] = 1;
    }
    for ( j = -1 ; j <= 257 ; j++ )
        totals[ ESCAPE ][ j ] = j + 1;
}

/*
 * When the table is updated, every count above "symbol" needs to
 * be incremented, which is somewhat expensive.  If the counts
 * have become to large, the table needs to be rescaled.  After the
 * rescaling is done, we have to make sure that the ESCAPE count
 * is not set to 0, otherwise we would have a problem. After the
 * update is complete, the context is changed to be the symbol that
 * was just updated, and the order is cranked back up to the maximum.
 */
void update_model( int symbol )
{
    int i;

    for ( i = symbol+1 ; i <= 257; i++ )
        totals[ context ][ i ]++;
    if ( totals[ context ][ 257 ] == MAXIMUM_SCALE )
    {
        for ( i = 0 ; i <= 257 ; i++ )
            totals[ context ][ i ] /= 2;
        if ( totals[ context ][ ESCAPE ] == totals[ context][ ESCAPE + 1 ] )
	    totals[ context ][ ESCAPE + 1 ]++;
    }
    context = symbol;
    current_order = 1;
}

/*
 * Since the context table can be directly indexed with the
 * symbol, getting the low and high counts for the particular
 * symbol is nice and easy.  If we have fallen back to a lower
 * order following an ESCAPE code being emitted, we look at the
 * ESCAPE table, else we look at the table selected by the
 * previous context.  The complication arises if we are currently
 * at the maximum order and the symbol has a count of zero.  If
 * that happens, we select the ESCAPE character instead, and
 * return that information to the calling program.
 */
int convert_int_to_symbol( int c, SYMBOL *s )
{
    int local_context;

    if ( current_order == 0 )
        local_context = ESCAPE ;
    else
        local_context = context;

    s->scale = totals[ local_context ][ 257 ];
    s->low_count = totals[ local_context ][ c ];
    s->high_count = totals[ local_context ][ c + 1 ];
    if ( s->low_count != s->high_count )
        return( 0 );
    s->low_count = totals[ local_context ][ ESCAPE ];
    s->high_count = totals[ local_context ][ 257 ];
    current_order--;
    return( 1 );
}
/*
 * The symbol's scale is always in the same place, which is nice.
 */
void get_symbol_scale( SYMBOL *s )
{
    if ( current_order == 0 )
        s->scale = totals[ ESCAPE ][ 257 ];
    else
        s->scale = totals[ context ][ 257 ];
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
    int local_context;

    if ( current_order == 0 )
        local_context = ESCAPE ;
    else
        local_context = context;


    for ( c = 257; count < totals[ local_context ][ c ] ; c-- )
        ;
    s->high_count = totals[ local_context ][ c + 1 ];
    s->low_count = totals[ local_context ][ c ];
    if ( c == ESCAPE )
        current_order--;
    return( c );
}

/*
 * These stubs are used by some of the more complicated modeling
 * modules.
 */
void add_character_to_model( int c )
{
}

void flush_model()
{
}
