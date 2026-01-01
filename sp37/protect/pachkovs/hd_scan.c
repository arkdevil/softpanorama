#if 0
                        COPYRIGHT NOTICE

        This program is an important part of "Introduction into Copy
        Protection" electronic book and should not be distributed
        alone. Introduction into Copy Protection is a copyrighted
        property of Serge S. Pachkovsky. This program is free for any
        non-commercial use provided that:
           A. This copyright notice is not removed from program source
              code.
           B. The copyright statement following this notice is not
              removed neither from object nor executable files.
           C. Origin of source code is explicitly specified in program
              manual.
           D. This program is not used as part of copy protection
              system.
        Any commercial use require prior written permission from the
        author of this software.

#endif
static  char    __rights__[] = "HardDisk exerciser module. (C) 1991 Serge S. Pachkovsky" ;

#ifndef __TINY__
#error Should be compiled in TINY model !
#endif
#pragma inline
#include <stdio.h>
#include <stdlib.h>
#include <bios.h>
#include <dos.h>

#define VERSION                 "0.0"
#define MAX_ROMS                100
#define MAX_SECTORS             64
#define SECTOR_SIZE             512
#define TIMER_CLOCK_RATE        (2*1193180ul)

#define INT_13()        geninterrupt(0x13)
#define BIOS_13()       (*BIOS_entry)()

        unsigned        HDD ;
        unsigned        cyls, heads, sectors ;
        FILE            *report ;
        void interrupt  (*BIOS_entry)( void ) ;
        unsigned        ROM_count = 0 ;
        unsigned long   revolution_time ;
        unsigned char   error_code ;
        double          ForcedRPS = 0.0 ;

        struct  _Z_ {
        unsigned char   sector ;
        unsigned long   position ;
        } ;

static  struct  _Y_ {
        unsigned        ROM_start ;     /* para                 */
        unsigned        ROM_end ;       /* para                 */
        } ROM_list[ MAX_ROMS ] ;

static  struct  _X_ {
        unsigned char   code ;
        char            *message ;
        } disk_errors[] = {
                0x00, "Function ok",
                0x01, "Invalid value passed or unsupported function",
                0x02, "Cannot locate address mark",
                0x03, "Write protected",
                0x04, "Sector not found",
                0x05, "Reset failure",
                0x07, "Parameter activity failed",
                0x08, "DMA overrun occured",
                0x09, "DMA attempted across 64K byte boundry",
                0x0A, "Sector flag bad",
                0x0D, "Wrong # of sectors (format)",
                0x0E, "Detected control data address mark",
                0x0F, "DMA arbitration level has invalid range",
                0x10, "ECC has an unresolvable error",
                0x11, "Data corrected by ECC",
                0x20, "Disk controller failure",
                0x40, "Seek operation failed",
                0x80, "Hard disk not ready",
                0xBB, "Error not defined",
                0xCC, "Write error",
                0xE0, "Error register is zero",
                } ;

char    *
get_error_name( unsigned char code )
{
        int     i ;
static  char    buf[ 80 ] ;

for( i = 0 ; i < sizeof disk_errors / sizeof( struct _X_ ) ; i++ )
        if( code == disk_errors[ i ].code ) return disk_errors[ i ].message ;
sprintf( buf, "Unknown error code 0x%02X", code ) ;
return buf ;
}

unsigned long
get_exact_time( void )
{
asm     xor     ax, ax
asm     mov     es, ax
asm     pushf
asm     sti
repeat_request:
asm     mov     al, 0c2h
asm     cli
asm     out     43h, al
asm     jmp     $+2
asm     jmp     $+2
asm     in      al, 40h
asm     jmp     $+2
asm     mov     bl, al          /* Counter state byte   */
asm     in      al, 40h
asm     jmp     $+2
asm     mov     ah, al
asm     in      al, 40h
asm     mov     dx, es:[46Ch]
asm     sti
asm     xchg    ah, al
asm     cmp     dx, es:[46Ch]
asm     jne     repeat_request
asm     popf
asm     neg     ax
asm     shl     bl, 1
asm     cmc
asm     rcl     dx, 1
return ( (unsigned long)_DX << 16 ) + _AX ;
}

void
init_timer_channel( unsigned char channel )
{
asm     pushf
asm     cli
asm     mov     al, channel
asm     mov     cl, 6
asm     shl     al, cl
asm     or      al, 36h
asm     out     43h, al
asm     mov     dx, 40h
asm     add     dl, channel
asm     jmp     $+2
asm     jmp     $+2
asm     xor     al, al
asm     out     dx, al
asm     jmp     $+2
asm     jmp     $+2
asm     out     dx, al
asm     popf
}

int
parce_parameters( int argc, char **argv )
{
printf( "HD_scan v. " VERSION " (C) 1991 Serge S. Pachkovsky\n" ) ;
printf( "Values reported can be incorrect for a caching disk controllers\n" ) ;
if( argc < 2 ){
        printf( "HD_scan BIOS_disk_ID [Drive RPS]\n" ) ;
        return -1 ;
        }
if( sscanf( argv[ 1 ], "%x", &HDD ) != 1 ){
        printf( "Invalid disk ID %s\n", argv[ 1 ] ) ;
        return -1 ;
        }
if( argc > 2 )
if( sscanf( argv[ 2 ], "%lg", &ForcedRPS ) != 1 ){
        printf( "Invalid drive revolutions_per_secons %s\n", argv[ 2 ] ) ;
        return -1 ;
        }
return 0 ;
}

int
init_files( void )
{
if( ( report = fopen( "HD_scan.rep", "wt" ) ) == NULL ){
        perror( "HD_scan.rep" ) ;
        return -1 ;
        }
fprintf( report, "Hard disk scan v " VERSION " report on disk %X\n", HDD ) ;
return 0 ;
}

int
read_HDD_params( unsigned char disk )
{
        unsigned dx, cx ;

_DL = disk ;
_AH = 0x08 ;
INT_13() ;
dx = _DX ; cx = _CX ;
heads   = dx >> 8 ;
sectors = cx & 0x3F ;
cyls    = ( cx >> 8 ) | ( ( ( cx >> 6 ) & 3 ) << 8 ) ;
return 0 ;
}

int
scan_ROMs( void )
{
        unsigned                seg ;
        unsigned char far       *ptr ;
        struct _Y_              *x = ROM_list ;

for( seg = 0xC800 ; seg < 0xE000 ; seg += 0x80 ){
        ptr = MK_FP( seg, 0 ) ;
        if( ptr[ 0 ] == 0x55 && ptr[ 1 ] == 0xAA ){
                /* ROM-extension signature found        */
                x->ROM_start = seg ;
                x->ROM_end   = seg + (unsigned)ptr[ 2 ] * (512/16) - 1 ;
                x++ ; ROM_count++ ;
                }
        }
x->ROM_start = 0xF000 ; x->ROM_end = 0xFFFF ;
ROM_count++ ;
return 0 ;
}

void interrupt
(*trace_to_BIOS( void interrupt (*start)(), unsigned char disk ))()
{
static  void interrupt  (*old_01)( void ) ;
static  void interrupt  (*entry_point)( void ) ;
static  unsigned char   trace_on ;
static  void interrupt  (*trace_dst)( void ) ;

entry_point = start ;
old_01      = getvect( 0x01 ) ;
trace_on    = 1 ;
asm     push    cs
asm     lea     ax, trace
asm     push    ax
asm     mov     ax, 1
asm     push    ax
asm     call    setvect
asm     add     sp, 6
asm     pushf
asm     push    cs
asm     lea     ax, normal_return
asm     push    ax
asm     pushf
asm     pop     ax
asm     or      ah, 1
asm     push    ax
asm     popf
asm     pushf
asm     push    word ptr start + 2
asm     push    word ptr start + 0
asm     mov     ah, 8
asm     mov     dl, disk
asm     iret
asm     normal_return   label   near
setvect( 0x01, old_01 ) ;
asm     jmp     end_routine

asm     trace   label   near
asm     push    bp
asm     mov     bp, sp
asm     push    ax
asm     push    bx
asm     push    cx
asm     push    ds
asm     push    es
asm     mov     ax, cs
asm     mov     ds, ax
/*
 *      BP ->   0       old BP
 *              2       IP
 *              4       CS
 *              6       Flags
 *              8       IP or flags
 *             10       CS
 *             12       flags
 */
asm     cmp     trace_on, 1
asm     je      proceed_trace
stop_trace:
asm     and     byte ptr ss:[bp+6+1], NOT 1     /* clear TF     */
exit_trace:
asm     pop     es
asm     pop     ds
asm     pop     cx
asm     pop     bx
asm     pop     ax
asm     pop     bp
asm     iret
proceed_trace:
asm     mov     ax, ss:[bp+2]
asm     shr     ax, 1
asm     shr     ax, 1
asm     shr     ax, 1
asm     shr     ax, 1
asm     add     ax, ss:[bp+4]
asm     lea     bx, ROM_list
asm     mov     cx, ROM_count
look_next_ROM_block:
        asm     cmp     ax, ds:[bx].ROM_start
        asm     jb      bad_ROM
        asm     cmp     ax, ds:[bx].ROM_end
        asm     ja      bad_ROM
                asm     mov     ax, ss:[bp+2]
                asm     mov     word ptr entry_point + 0, ax
                asm     mov     ax, ss:[bp+4]
                asm     mov     word ptr entry_point + 2, ax
                asm     jmp     stop_trace
        bad_ROM:
        asm     add     bx, 4
        asm     loop    look_next_ROM_block

asm     les     bx, dword ptr ss:[bp+2]
asm     mov     ax, word ptr es:[bx]
asm     cmp     al, 0cfh
asm     je      trace_iret_command
asm     cmp     al, 09dh
asm     je      trace_popf_command
asm     cmp     al, 0cdh
asm     je      trace_intn_command
asm     cmp     al, 0cch
asm     je      trace_int3_command
asm     jmp     exit_trace

trace_iret_command:
asm     or      byte ptr ss:[bp+12+1], 1
asm     jmp     exit_trace
trace_popf_command:
asm     or      byte ptr ss:[bp+8+1], 1
asm     jmp     exit_trace
trace_int3_command:
asm     inc     word ptr ss:[bp+2]
asm     mov     ah, 3
asm     jmp     trace_interrupt
trace_intn_command:
asm     cmp     ah, 10h
asm     jb      OK_to_trace
asm     cmp     ah, 13h
asm     jb      exit_trace
asm     je      OK_to_trace
asm     cmp     ah, 1dh
asm     jb      exit_trace
OK_to_trace:
asm     add     word ptr ss:[bp+2], 2
asm     jmp     trace_interrupt
trace_interrupt:
asm     xor     bx, bx
asm     mov     es, bx
asm     mov     bl, ah
asm     shl     bx, 1
asm     shl     bx, 1
asm     mov     ax, word ptr es:[bx]
asm     mov     word ptr trace_dst, ax
asm     mov     ax, word ptr es:[bx+2]
asm     mov     word ptr trace_dst+2, ax
asm     pop     es
asm     pop     ds
asm     pop     cx
asm     pop     bx
asm     pop     ax
asm     pop     bp
asm     pushf
asm     push    word ptr cs:trace_dst + 2
asm     push    word ptr cs:trace_dst + 0
asm     iret

end_routine:;
return entry_point ;
}

int
detect_BIOS_entry( unsigned char disk )
{
if( scan_ROMs() == -1 ) return -1 ;
if( ( BIOS_entry = trace_to_BIOS( getvect( 0x13 ), disk ) ) == NULL ) return -1 ;
return 0 ;
}

int
detect_HDD_params( void )
{
if( read_HDD_params( HDD ) == -1 ) return -1 ;
fprintf( report, "Cyls = %u, Heads = %u, Sectors = %u\n", cyls + 1, heads + 1, sectors ) ;
printf( "Cyls = %u, Heads = %u, Sectors = %u\n", cyls + 1, heads + 1, sectors ) ;
if( detect_BIOS_entry( HDD ) == -1 ) return -1 ;
fprintf( report, "Hard disk BIOS entry point %Fp\n", BIOS_entry ) ;
printf( "Hard disk BIOS entry point %Fp\n", BIOS_entry ) ;
return 0 ;
}

int
init_system_timer( void )
{
init_timer_channel( 0 ) ;
return 0 ;
}

void
read_sector( unsigned cyl, unsigned head, unsigned sector, char buf[ 512 ] )
{
        unsigned        cx, dx ;

cx = ( sector & 0x3F ) | ( cyl << 8 ) | ( ( cyl >> 8 ) << 6 ) ;
dx = ( head << 8 ) | HDD ;
_ES = FP_SEG( buf ) ;
_BX = FP_OFF( buf ) ;
_CX = cx ;
_DX = dx ;
_AX = 0x0201 ;
BIOS_13() ;
switch( error_code = _AH ){
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 9:
        case 0x0D:
        case 0x0F:
        case 0x20:
        case 0x40:
        case 0x80:
        case 0xBB:
        case 0xCC:
        case 0xE0:
                fprintf( stderr, "%s", get_error_name( error_code ) ) ;
                exit( 255 ) ;
        }
}

int
detect_rotation_speed( void )
{
        int             i ;
        unsigned long   start, end ;
        char            buf[ 512 ] ;

_AX = 0 ; _DL = HDD ; BIOS_13() ;
read_sector( 0, 0, 1, buf ) ;
start = get_exact_time() ;
for( i = 0 ; i < 500 ; i++ ){
        _AX = 0 ; _DL = HDD ; BIOS_13() ;
        read_sector( 0, 0, 1, buf ) ;
        }
end   = get_exact_time() ;
revolution_time = ( end - start ) / i ;
fprintf( report, "Measured drive RPM is %lu\n", 60 * TIMER_CLOCK_RATE / revolution_time ) ;
printf( "Measured drive RPM is %lu\n", 60 * TIMER_CLOCK_RATE / revolution_time ) ;
if( ForcedRPS != 0.0 ){
        revolution_time = TIMER_CLOCK_RATE / ForcedRPS ;
        fprintf( report, "Forced drive RPM is %lu\n", 60 * TIMER_CLOCK_RATE / revolution_time ) ;
        printf( "Forced drive RPM is %lu\n", 60 * TIMER_CLOCK_RATE / revolution_time ) ;
        }
return 0 ;
}

int
check_sectors( unsigned cyl, unsigned head, struct _Z_ *p )
{
        int             secs = 0 ;
        unsigned        i ;
        char            buf[ 512 ] ;

for( i = 1 ; i <= sectors ; i++ ){
        read_sector( cyl, head, i, buf ) ;
        if( error_code != 0 )
                fprintf( report, "\t%s at sector %4u/%2u/%2u\n", get_error_name( error_code ), cyl, head, i ) ;
        if( error_code == 0 || error_code == 0x0A || error_code == 0x10 || error_code == 0x11 ){
                p++->sector = i ;
                secs++ ;
                }
        }
return secs ;
}

int
get_read_times( unsigned cyl, unsigned head, int sectors, struct _Z_ *table )
{
        int             i ;
        char            buf[ 512 ] ;
        unsigned long   index ;

read_sector( cyl, head, sectors + 1, buf ) ;
index = get_exact_time() ;
for( i = 0 ; i < sectors ; i += 2 ){
        read_sector( cyl, head, table[ i ].sector, buf ) ;
        table[ i ].position = get_exact_time() - index ;
        }
for( i = 1 ; i < sectors ; i += 2 ){
        read_sector( cyl, head, table[ i ].sector, buf ) ;
        table[ i ].position = get_exact_time() - index ;
        }
return 0 ;
}

int
cmp_positions( const struct _Z_ *a, const struct _Z_ *b )
{
if( a->position < b->position ) return -1 ;
if( a->position > b->position ) return  1 ;
return 0 ;
}

int
process_read_times( int sectors, struct _Z_ *table )
{
        int     i ;

for( i = 0 ; i < sectors ; i++ )
        while( table[ i ].position > revolution_time ) table[ i ].position -= revolution_time ;
qsort( table, sectors, sizeof( struct _Z_ ), cmp_positions ) ;
return 0 ;
}

int
report_track_ordering( int sectors, struct _Z_ *table )
{
        int     i ;

for( i = 0 ; i < sectors ; i++ ){
        if( i % 17 == 0 ){
                putc( '\t', report ) ;
                if( i != 0 ) putc( '\t', report ) ;
                }
        fprintf( report, "%02d ", table[ i ].sector ) ;
        if( i % 17 == 16 )
                putc( '\n', report ) ;
        }
if( i % 17 != 0 ) putc( '\n', report ) ;
return 0 ;
}

int
scan_track( unsigned cyl, unsigned head )
{
        struct _Z_      sector_table[ MAX_SECTORS ] ;
        int             sectors ;

if( ( sectors = check_sectors( cyl, head, sector_table ) ) == -1 ) return -1 ;
if( get_read_times( cyl, head, sectors, sector_table ) == -1 ) return -1 ;
if( process_read_times( sectors, sector_table ) == -1 ) return -1 ;
fprintf( report, "%4u/%2u\t", cyl, head ) ;
if( report_track_ordering( sectors, sector_table ) == -1 ) return -1 ;
return 0 ;
}

int
scan_surface( void )
{
        unsigned        cyl, head ;

for( cyl = 0 ; cyl <= cyls ; cyl++ ){
        for( head = 0 ; head <= heads ; head++ ){
                fprintf( stderr, "\rTrack %4d, head %2d ", cyl, head ) ;
                if( scan_track( cyl, head ) == -1 ) return -1 ;
                fflush( report ) ;
                }
        }
fputc( '\n', stderr ) ;
return -1 ;
}

int
main( int argc, char *argv[] )
{
if( parce_parameters( argc, argv ) == -1 ) return 1 ;
if( init_files() == -1 ) return 2 ;
if( detect_HDD_params() == -1 ) return 3 ;
if( init_system_timer() == -1 ) return 4 ;
if( detect_rotation_speed() == -1 ) return 5 ;
if( scan_surface() == -1 ) return 6 ;
return 0 ;
}
