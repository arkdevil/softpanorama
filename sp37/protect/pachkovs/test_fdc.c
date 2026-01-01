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
static  char    __rights__[] = "AT FDC exerciser module. (C) 1991 Serge S. Pachkovsky" ;
#if 0

                        DISCLAIMER

        This program accesses PC hardware in a manner which was not
        approved by hardware manufactures and can hitherto cause
        hardware, software or disk media damage. Author can't be
        held responsible for any such damage, neither direct nor
        consequential. You was warned, so USE THIS SOFTWARE ON YOUR
        OWN RISK.


#endif
#if ! defined( __TURBOC__ )
#error This program uses Turbo C 2.00 - style in-line assemble !
#else
#pragma inline
#endif
#if ! defined( __SMALL__ )
#error Should be compiled in Small model !
#endif
#include <stdio.h>
#include <dos.h>
#include <bios.h>
#include <limits.h>
#include <stdlib.h>
#include <ctype.h>
#include <setjmp.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <mem.h>

/*
 *      FDC_BASE selects controller number.
 *      0x3F0 is Primary FDC, 0x370 is Secondary FDC.
 *
 */
#define FDC_BASE        0x3F0
#define FDC_MSR         (FDC_BASE+4)
#define FDC_DATA        (FDC_BASE+5)
#define FDC_DIGITAL     (FDC_BASE+2)
#define FDC_RATE        (FDC_BASE+7)
/*
 *      RATE_??? should be send to FDC_RATE to select WR CLK value.
 */
#define RATE_250	2
#define RATE_300	1
#define RATE_500	0

/*
 *      The following typedefs describe 8272A status registers format.
 *      Note: this definitions are compiler implementation dependent.
 */
typedef struct	{
        unsigned        ds : 2 ;        /* Drive select         */
        unsigned        h  : 1 ;        /* Head select          */
        unsigned        nr : 1 ;        /* Not ready            */
        unsigned        ec : 1 ;        /* Equipment check      */
        unsigned        se : 1 ;        /* Seek ended           */
        unsigned        ic : 2 ;        /* Interrupt code       */
	} ST0 ;

typedef struct	{
        unsigned        ma : 1 ;        /* Missing address mark */
        unsigned        nw : 1 ;        /* Write protect        */
        unsigned        nd : 1 ;        /* Sector not found     */
        unsigned        _1 : 1 ;
        unsigned        or : 1 ;        /* Overrun error        */
        unsigned        de : 1 ;        /* Data error           */
	unsigned	_2 : 1 ;
        unsigned        en : 1 ;        /* End of track error   */
	} ST1 ;

typedef struct	{
        unsigned        md : 1 ;        /* Missing data AM      */
        unsigned        bc : 1 ;        /* IBM bad track        */
        unsigned        sn : 1 ;        /* Scan not satisfied   */
        unsigned        sh : 1 ;        /* Scan hit             */
        unsigned        wc : 1 ;        /* Wrong cylinder       */
        unsigned        dd : 1 ;        /* Sector data error    */
        unsigned        cm : 1 ;        /* Control mark         */
	unsigned	_1 : 1 ;
	} ST2 ;

typedef struct	{
        unsigned        ds : 2 ;        /* Drive select         */
        unsigned        h  : 1 ;        /* Head select          */
        unsigned        ts : 1 ;        /* Two-sided            */
        unsigned        t0 : 1 ;        /* Track 00             */
        unsigned        rdy: 1 ;        /* Ready                */
        unsigned        wp : 1 ;        /* Write protect        */
        unsigned        ft : 1 ;        /* Fault                */
	} ST3 ;

/*
 *      FDC_MSR fields
 */
typedef struct	{
	unsigned	A_buzy : 1 ;
	unsigned	B_buzy : 1 ;
	unsigned	C_buzy : 1 ;
	unsigned	D_buzy : 1 ;
        unsigned        cb : 1 ;        /* Controller busy      */
        unsigned        ndm : 1 ;       /* non-DMA mode         */
        unsigned        dio : 1 ;       /* I/O direction        */
        unsigned        rqm : 1 ;       /* Request for master   */
	} STATE ;
/*
 *      Parameters for specify command.
 */
typedef struct	{
        unsigned        hut : 4 ;       /* Head unload time     */
        unsigned        srt : 4 ;       /* Step rate            */
        unsigned        nd  : 1 ;       /* non-DMA              */
        unsigned        hlt : 7 ;       /* Head load time       */
	} SPECIFY ;

/*
 *      BIOS diskette parameter block, pointer by vector 1Eh.
 */
typedef struct	{
	SPECIFY specify ;
        char    motor_wait ;            /* 55-ms increments     */
        char    sector_size ;           /* length code          */
        char    EOT ;
        char    GAP1 ;                  /* read/write           */
        char    DTL ;                   /* FFh                  */
        char    GAP2 ;                  /* format               */
        char    fill_char ;             /* format               */
        char    head_settle ;           /* ms                   */
        char    motor_startup ;         /* 1/8 sec              */
	} BIOS_DISK ;

/*
 *      8272A parameters for R/W operations
 */
typedef struct	{
	char	c ;
	char	h ;
	char	r ;
	char	n ;
	char	eot ;
	char	gpl ;
	char	dtl ;
	} RW_INPUT ;

/*
 *      Ticks until drive motor off.
 */
#define MOTOR_COUNT     (*(unsigned char far *)MK_FP(0,0x440))

/*
 *      write_data() and read_data() sends (waits for) data to and from
 *      8272A
 */

#define write_data(x)		\
	{\
	while( ( inportb( FDC_MSR ) & 0xc0 ) != 0x80 ) ;\
	outportb( FDC_DATA, (x) ) ;\
	}

#define read_data(x)	       \
	{\
	while( ( inportb( FDC_MSR ) & 0xc0 ) != 0xc0 ) ;\
	(x) = inportb( FDC_DATA ) ;\
	}

/*
 *      defining LOOK_TIME enables 8272A commands execution time monitor.
 */
#define LOOK_TIME

/*
 *      defining HANG_ABORT enables brute-force termination of staled
 *      rotine after ABORT_WAIT system timer ticks.
 */
#define HANG_ABORT

#ifdef	LOOK_TIME
	#define START	start_time = get_exact_time()
	#define END	elapsed_time = get_exact_time() - start_time
#else
	#define START
	#define END
#endif

#ifdef	HANG_ABORT
	#define HANG_START(x)	hang_start(x)
	#define HANG_END	hang_end()
#else
	#define HANG_START(x)
	#define HANG_END
#endif

char    FDD     = 0 ;                   /* Current drive number */

#define ABORT_WAIT	(2*16)		/* Approx.  2 sec	*/

#define BUFFER_SIZE	(32*1024)

#define MAX_SECTORS	40

/*
 *      REVOLUTION_TIME is currently tuned for 1.2 Mb AT HD drive.
 *      For all other drives change 166L to 200L
 */
#define REVOLUTION_TIME (166L*2*1193)

BIOS_DISK	far	*bios_disk ;
union	{	char	c ;	ST0	x ;	} st0 ;
union	{	char	c ;	ST1	x ;	} st1 ;
union	{	char	c ;	ST2	x ;	} st2 ;
union	{	char	c ;	ST3	x ;	} st3 ;
unsigned char   r_c ;                   /* Cyl # from last operation    */
unsigned char   r_h ;                   /* Head ...                     */
unsigned char   r_r ;                   /* Sector ...                   */
unsigned char   r_n ;                   /* Sector size code             */
unsigned long	start_time ;
unsigned long	elapsed_time ;
unsigned char   *buffer ;
unsigned	buffer_bytes = 0 ;
volatile unsigned long bios_time = 0 ;
jmp_buf 	hang_reset ;
char		*current_function ;
unsigned        rest_ticks ;            /* Before abortion              */
char		abort_on_hangup ;
FILE		*out ;
unsigned char   mfm = 0x40 ;            /* 0 for FM, 0x40 for MFM       */

void	interrupt	(*old_int_0eh)( void ) ;
void	interrupt	(*old_int_08h)( void ) ;

/*
 *      get_exact_time() returns 32-bit time since program start.
 *      In order to convert to seconds, divide by 2,386,360.
 */
static	unsigned	long
get_exact_time( void )
{
asm	pushf
asm	sti
asm	jmp	$+2
asm	cli
asm	mov	al, 0c2h
asm	out	43h, al
asm	jmp	$+2
asm	jmp	$+2
asm	in	al, 40h
asm	mov	bl, al		/* Counter state byte	*/
asm	jmp	$+2
asm	jmp	$+2
asm	in	al, 40h
asm	mov	ah, al
asm	jmp	$+2
asm	jmp	$+2
asm	in	al, 40h
asm	xchg	ah, al
asm	neg	ax
asm     mov     dx, word ptr bios_time
asm     rcl     bl, 1
asm     cmc
asm     rcl     dx, 1
asm	popf
return( ( (unsigned long)_DX << 16 ) + _AX ) ;
}

void interrupt
int_0eh( void )
{
/*
 *      This should never occure !
 */
outportb( 0x20, 0x20 ) ;
printf( "Unexpected FDC interrupt !\n" ) ;
}

void
report_st0( void )
{
printf( "Drive %c, head %d :\n", 'A' + st0.x.ds, st0.x.h ) ;
switch( st0.x.ic ){
	case 0: break ;
	case 1:
		printf( "Abnormal operation termination\n" ) ;
		break ;
	case 2:
		printf( "Illegal command\n" ) ;
		break ;
	case 3:
		printf( "Disk drive ready condition changed\n" ) ;
		break ;
	}
if( st0.x.se )
	printf( "Seek ended\n" ) ;
if( st0.x.ec )
	printf( "Drive fault\n" ) ;
if( st0.x.nr )
	printf( "Drive not ready or head 1 selected on single-sided drive\n" );
}

void
hang_start( char *f )
{
current_function = f ;
rest_ticks = ABORT_WAIT ;
abort_on_hangup = 1 ;
}

void
hang_end( void )
{
abort_on_hangup = 0 ;
}

void
install_fdc_driver( void )
{
_AH = 0 ; _DL = FDD ; 
geninterrupt( 0x13 ) ;                          /* BIOS floppy reset    */
delay( 500 ) ;
disable() ;
bios_time = biostime( 0, 0 ) ;
old_int_0eh = getvect( 0x0e ) ;
old_int_08h = getvect( 0x08 ) ;
outportb( 0x21, inportb( 0x21 ) | 0x40 ) ;      /* disable floppy interrupts    */
setvect( 0x0e, int_0eh ) ;
asm	mov	dx, offset int_08h_routine
asm	push	ds
asm	mov	ax, cs
asm	mov	ds, ax
asm	mov	ax, 02508h
asm	int	21h
asm	pop	ds
bios_disk = (void far *) getvect( 0x1e ) ;
enable() ;
asm	jmp	exit

asm int_08h_routine label near
asm	extrn	DGROUP@:word
asm	push	ax
asm	push	ds
asm	mov	ds, cs:DGROUP@
asm	add	word ptr bios_time, 1
asm	adc	word ptr bios_time + 2, 0
asm	push	ds
asm	mov	ax, 40h
asm	mov	ds, ax
asm	mov	byte ptr ds:[40h], 0ffh
asm	pop	ds
asm	mov	al, 20h
asm	out	20h, al
asm	cmp	abort_on_hangup, 0
asm	je	done
asm	dec	rest_ticks
asm	jg	done
        longjmp( hang_reset, -1 ) ;             /* Stuck routine        */
done:;
asm	pop	ds
asm	pop	ax
asm	iret

exit:;
}

void
specify( SPECIFY parms )
{
START ;
HANG_START( "Specify" ) ;
parms.nd = 1 ;
write_data( 0x03 ) ;
write_data( *(char *)&parms ) ;
write_data( *((char *)&parms + 1 ) ) ;
HANG_END ;
END ;
printf( "HUT = %d ms\n", parms.hut * 16 ) ;
printf( "HLT = %d ms\n", parms.hlt *  2 ) ;
printf( "SRT = %d ms\n", 16 - parms.srt ) ;
printf( "%sDMA mode\n", parms.nd ? "non-" : "" ) ;
}

void
sence_is( void )
{
write_data( 0x08 ) ;
read_data( st0.c ) ;
if( st0.c != 0x80 )                             /* Invalid command      */
	read_data( r_c ) ;
}

void
wait_interrupt( void )
{
do      outportb( 0x20, 0x0a ) ;                /* Request 8259A IRR    */
while( ( inportb( 0x20 ) & 0x40 ) != 0x40 ) ;
outportb( 0x20, 0x08 ) ;                        /* Standard state       */
}

int
recalibrate( void )
{
START ;
HANG_START( "Recalibrate" ) ;
write_data( 0x07 ) ;
write_data( FDD ) ;
wait_interrupt() ;
do	sence_is() ;
	while( st0.x.se != 1 ) ;
HANG_END ;
END ;
if( ! st0.x.se || st0.x.ic != 0 )
	report_st0() ;
if( r_c == 0 )
        return 0 ;
return -1 ;
}

int
seek( unsigned char cyl )
{
START ;
HANG_START( "Seek" ) ;
write_data( 0x0f ) ;
write_data( FDD ) ;
write_data( cyl ) ;
wait_interrupt() ;
do	sence_is() ;
	while( st0.x.se != 1 ) ;
HANG_END ;
END ;
if( ! st0.x.se || st0.x.ic != 0 )
	report_st0() ;
if( r_c == cyl )
        return 0 ;
return -1 ;
}

void
start_operations( void )
{
	SPECIFY temp ;

temp = bios_disk->specify ;
temp.nd = 1 ;
MOTOR_COUNT = UCHAR_MAX - 1 ;
outportb( FDC_DIGITAL, FDD ) ;
delay( 1 ) ;
outportb( FDC_DIGITAL, 0x04 | FDD ) ;
delay( 1 ) ;
outportb( FDC_RATE, RATE_300 ) ;
specify( temp ) ;
outportb( FDC_DIGITAL, ( 0x10 << FDD ) | 0x0C | FDD ) ;
delay( bios_disk->motor_startup * 120 ) ;
}

void
reset_old_fdc( void )
{
setvect( 0x0e, old_int_0eh ) ;
setvect( 0x08, old_int_08h ) ;
outportb( 0x21, inportb( 0x21 ) & ~0x40 ) ;
biostime( 1, bios_time ) ;
MOTOR_COUNT = 1 ;
_AH = 0 ;
_DL = 0 ;
geninterrupt( 0x13 ) ;
}

void
read_ST3( void )
{
START ;
HANG_START( "read_ST3" ) ;
write_data( 0x04 ) ;
write_data( FDD ) ;
read_data( st3.c ) ;
HANG_END ;
END ;
}

/*
 *      Running floppies in non-DMA mode is CPU-demanding task, so
 *      read_operation, write_operation and format_track will disable
 *      interrupts for a long period of time. Sorry.
 */
void
read_operation( int code, int head, RW_INPUT *param, char far *buf, unsigned max_len )
{
	char	*p = (void *)param ;
	int	i = sizeof( RW_INPUT ) ;

buffer_bytes = 0 ;
START ;
HANG_START( "R/W operation" ) ;
/*
 *      Send command w/ parameters to 8272A
 */
write_data( code ) ;
write_data( ( ( head & 1 ) << 2 ) | FDD ) ;
for( ; i > 0 ; i--, p++ ) write_data( *p ) ;
/*
 *      Wait until start of execution phase
 */
while( !( inportb( FDC_MSR ) & 0x20 ) ) ;
disable() ;
/*
 *      Get ready to transmit data
 */
asm	mov	cx, max_len
asm	mov	dx, FDC_MSR
asm	les	di, buf
asm	xor	si, si
asm	mov	bx, 1+1
asm	cld
input_loop:
asm	in	al, dx
asm	test	al, 20h
asm	jz	exit
asm	test	al, 80h
asm	jz	input_loop
asm	inc	dx
asm	in	al, dx
asm	stosb
asm	inc	si
asm	dec	dx
asm	loop	input_loop
exit:;
enable() ;
asm	mov	buffer_bytes, si
/*
 *      Wait execution phase end
 */
wait_interrupt() ;
/*
 *      Read result
 */
read_data( st0.c ) ;
read_data( st1.c ) ;
read_data( st2.c ) ;
read_data( r_c ) ;
read_data( r_h ) ;
read_data( r_r ) ;
read_data( r_n ) ;
HANG_END ;
END ;
}

void
write_operation( int code, int head, RW_INPUT *param, char far *buf, unsigned max_len )
{
	char	*p = (void *)param ;
	int	i = sizeof( RW_INPUT ) ;

buffer_bytes = 0 ;
START ;
HANG_START( "R/W operation" ) ;
/*
 *      Send command w/ parameters to 8272A
 */
write_data( code ) ;
write_data( ( ( head & 1 ) << 2 ) | FDD ) ;
for( ; i > 0 ; i--, p++ ) write_data( *p ) ;
/*
 *      Wait until start of execution phase
 */
while( !( inportb( FDC_MSR ) & 0x20 ) ) ;
disable() ;
/*
 *      Get ready to transmit data
 */
asm	push	ds
asm	mov	cx, max_len
asm	mov	dx, FDC_MSR
asm	lds	si, buf
asm	xor	di, di
asm	cld
wait_start:
asm	in	al, dx
asm	test	al, 20h
asm	jz	wait_start

output_loop:
asm	in	al, dx
asm	test	al, 20h
asm	jz	exit
asm	test	al, 80h
asm	jz	output_loop
asm	inc	dx
asm	outsb
asm	inc	di
asm	dec	dx
asm	loop	output_loop
        /*
         *      FDC wants more data, but no data left, so we will
         *      knock it down.
         */
	outportb( FDC_DIGITAL, 0 ) ;
	delay( 5 ) ;
	outportb( FDC_DIGITAL, ( 0x10 << FDD ) | 0x0C | FDD ) ;
	asm	pop	ds
	asm	mov	buffer_bytes, di
	HANG_END ;
	END ;
	enable() ;
	specify( bios_disk->specify ) ;
	return ;
exit:;
enable() ;
asm	pop	ds
asm	mov	buffer_bytes, di
/*
 *      Wait execution phase end
 */
wait_interrupt() ;
/*
 *      Read result
 */
read_data( st0.c ) ;
read_data( st1.c ) ;
read_data( st2.c ) ;
read_data( r_c ) ;
read_data( r_h ) ;
read_data( r_r ) ;
read_data( r_n ) ;
HANG_END ;
END ;
}

void
format_track( int head, int n, int sc, int gpl, int d, char far *buf, int lim )
{
START ;
HANG_START( "Format a track" ) ;
/*
 *      Send command w/ parameters to 8272A
 */
write_data( 0x0D | mfm ) ;
write_data( ( ( head & 1 ) << 2 ) | FDD ) ;
write_data( n	) ;
write_data( sc	) ;
write_data( gpl ) ;
write_data( d	) ;
/*
 *      Wait until start of execution phase
 */
while( !( inportb( FDC_MSR ) & 0x20 ) ) ;
disable() ;
/*
 *      Get ready to transmit data
 */
asm	push	ds
asm	mov	cx, lim
asm	mov	dx, FDC_MSR
asm	lds	si, buf
asm	xor	di, di
asm	cld
output_loop:
asm	in	al, dx
asm	test	al, 20h
asm	jz	exit
asm	test	al, 80h
asm	jz	output_loop
asm	inc	dx
asm	lodsb
asm	out	dx, al
asm	inc	di
asm	dec	dx
asm	loop	output_loop
        /*
         *      FDC wants more data, but no data left, so we will
         *      knock it down.
         */
	delay( 1 ) ;
	outportb( FDC_DIGITAL, 0 ) ;
	delay( 5 ) ;
	outportb( FDC_DIGITAL, ( 0x10 << FDD ) | 0x0C | FDD ) ;
	asm	pop	ds
	asm	mov	buffer_bytes, di
	HANG_END ;
	END ;
	enable() ;
	specify( bios_disk->specify ) ;
	return ;
exit:;
enable() ;
asm	pop	ds
asm	mov	buffer_bytes, di
/*
 *      Wait execution phase end
 */
wait_interrupt() ;
/*
 *      Read result
 */
read_data( st0.c ) ;
read_data( st1.c ) ;
read_data( st2.c ) ;
read_data( r_c ) ;
read_data( r_h ) ;
read_data( r_r ) ;
read_data( r_n ) ;
HANG_END ;
END ;
}


void
read_sector( int head, RW_INPUT *param )
{
read_operation( 0x06 | mfm, head, param, buffer, BUFFER_SIZE ) ;
}

void
read_deleted( int head, RW_INPUT *param )
{
read_operation( 0x0C | mfm, head, param, buffer, BUFFER_SIZE ) ;
}

void
read_track( int head, RW_INPUT *param )
{
read_operation( 0x02 | mfm, head, param, buffer, BUFFER_SIZE ) ;
}

void
write_sector( int head, unsigned count, RW_INPUT *param )
{
write_operation( 0x05 | mfm, head, param, buffer, count ) ;
}

void
write_deleted( int head, unsigned count, RW_INPUT *param )
{
write_operation( 0x09 | mfm, head, param, buffer, count ) ;
}

void
read_address( int head )
{
START ;
HANG_START( "Read_address" ) ;
write_data( 0x0a | mfm ) ;
write_data( ( ( head & 1 ) << 2 ) | FDD ) ;
wait_interrupt() ;
read_data( st0.c ) ;
read_data( st1.c ) ;
read_data( st2.c ) ;
read_data( r_c ) ;
read_data( r_h ) ;
read_data( r_r ) ;
read_data( r_n ) ;
HANG_END ;
END ;
}

void
explain_ST3( void )
{
printf( "ST3 is %02X\n", st3.c ) ;
printf( "Drive %c is %s\n", 'A' + st3.x.ds, st3.x.rdy ? "ready" : "not ready" ) ;
printf( "Selected head %d\n", st3.x.h ) ;
if( st3.x.ft )
	printf( "!!!!! Drive fault !!!!!\n" ) ;
if( st3.x.wp )
	printf( "Write protected\n" ) ;
if( st3.x.t0 )
	printf( "Currently at track 0\n" ) ;
}

void
print_rw_return( void )
{
printf( "STn : %02x %02x %02x\n", st0.c, st1.c, st2.c ) ;
printf( "Drive %c, head %d :\n", 'A' + st0.x.ds, st0.x.h ) ;
switch( st0.x.ic ){
	case 0: break ;
	case 1:
		printf( "Abnormal operation termination\n" ) ;
		break ;
	case 2:
		printf( "Illegal command\n" ) ;
		break ;
	case 3:
		printf( "Disk drive ready condition changed\n" ) ;
		break ;
	}
if( st0.x.se )
	printf( "Seek ended\n" ) ;
if( st0.x.ec )
	printf( "Drive fault\n" ) ;
if( st0.x.nr )
	printf( "Drive not ready or head 1 selected on single-sided drive\n" );
if( st1.x.en )
	printf( "End of track error\n" ) ;
if( st1.x.de )
	if( st2.x.dd )
		printf( "User data CRC error\n" ) ;
	else	printf( "Sector ID CRC error\n" ) ;
if( st1.x.or )
	printf( "Overrun error\n" ) ;
if( st1.x.nd )
	printf( "Sector not found\n" ) ;
if( st1.x.nw )
	printf( "Write protect error\n" ) ;
if( st1.x.ma )
	printf( "Missing address mark\n" ) ;
if( st2.x.cm )
	printf( "Control mark - Deleted data on Read Data or reverse\n" ) ;
if( st2.x.wc )
	printf( "Sector ID cylinder number do not match\n" ) ;
if( st2.x.sh )
	printf( "Scan condition hit\n" ) ;
if( st2.x.sn )
	printf( "Scan not satisfied\n" ) ;
if( st2.x.bc )
	printf( "IBM bad track\n" ) ;
if( st2.x.md )
	printf( "Missing data address mark\n" ) ;
}

void
read_rw_input( RW_INPUT *p )
{
	int	temp ;

printf( "C = " ) ;
scanf( "%x", &temp ) ; p->c = temp ;
printf( "H = " ) ;
scanf( "%x", &temp ) ; p->h = temp ;
printf( "R = " ) ;
scanf( "%x", &temp ) ; p->r = temp ;
printf( "N = " ) ;
scanf( "%x", &temp ) ; p->n = temp ;
printf( "EOT = " ) ;
scanf( "%x", &temp ) ; p->eot = temp ;
printf( "GPL = " ) ;
scanf( "%x", &temp ) ; p->gpl = temp ;
printf( "DTL = " ) ;
scanf( "%x", &temp ) ; p->dtl = temp ;
}

void
print_chrn( void )
{
printf( "Cyl = %2x Head = %2x Sect = %2x Siz = %1x\n", r_c, r_h, r_r, r_n ) ;
}

/*
 *      analyze_track() is a very simple track analyzer based on read
 *      sector ID command. It's not able to find any deliberately hidden
 *      sectors.
 */
void
analyze_track( int cyl, int head )
{
	struct	_x	{
		char	c, h, r, n ;
		long	time_diff ;
		} ;
	struct	_x	sector_table[ MAX_SECTORS ] ;
	struct	_x	*p ;
	int		i ;
	long		start, end ;
	int		track_size ;
	RW_INPUT	param ;

seek( cyl ) ;
fprintf( stderr, "Analyzing track %02X ... Please Wait\n", cyl ) ;

param.c = 0xff ;
param.h = 0xff ;
param.r = 0x0 ;
param.n = 0xff ;
param.eot = 0xff ;
param.gpl = 0x20 ;
param.dtl = 0xff ;
disable() ;
/*
 *      The following read_sector terminated immediately after index
 *      hole.
 */
do {
	param.r-- ;
	read_sector( head, &param ) ;
	} while( ( ! st1.x.nd ) && ( ! st1.x.ma ) ) ;
if( st1.x.ma ){
	print_rw_return() ;
	return ;
	}
start = get_exact_time() ;
for( i = 0, p = sector_table ; i < MAX_SECTORS ; i++, p++ ){
	read_address( head ) ;
	end = get_exact_time() ;
	enable() ;
	p->c = r_c ;
	p->h = r_h ;
	p->r = r_r ;
	p->n = r_n ;
	if( st1.x.ma ){
		print_rw_return() ;
		return ;
		}
	p->time_diff = end - start ;
	if( p->time_diff > REVOLUTION_TIME )
		break ;
	}
track_size = i ;
fprintf( out, "%02X sectors found on track %02X side %1X\n", track_size, cyl, head ) ;
fprintf( out, "      Cyl Hd Sec  N   Pos (ms) Off (ms)       Cyl Hd Sec  N   Pos (ms) Off (ms)\n" ) ;
for( i = 0, p = sector_table ; i < track_size ; i++, p++ ){
	fprintf( out, "#%2d - %02X   %1X  %02X  %1X   %7.3lf %7.3lf%c", i,
		p->c, p->h, p->r, p->n, p->time_diff / ( 1193.18 * 2 ),
		( i == ( track_size - 1 ) ? ( sector_table->time_diff + REVOLUTION_TIME - p->time_diff ) :
		( (p+1)->time_diff - p->time_diff ) ) / ( 1193.18 * 2 ),
		i % 2 ? '\n' : '\t' ) ;
	}
if( i % 2 == 1 ) fputc( '\n', out ) ;
}

void
analyze_disk( int from, int count )
{
	int	i ;

for( i = 0 ; i < count ; i++, from++ ){
	analyze_track( from, 0 ) ;
	analyze_track( from, 1 ) ;
	}
}

#define LINE_SIZE	16
#define SCREEN_SIZE	10
#define PAGE_SIZE	(SCREEN_SIZE*LINE_SIZE)

void
draw_buffer( char *start, unsigned lines, unsigned num_start )
{
	int	i ;

for( ; lines-- > 0 ; num_start += LINE_SIZE, start += LINE_SIZE ){
	printf( "%04X ", num_start ) ;
	for( i = 0 ; i < LINE_SIZE ; i++ )
		printf( "%02X ", start[ i ] ) ;
	for( i = 0 ; i < LINE_SIZE ; i++ )
		putchar( isprint( start[ i ] ) ? start[ i ] : '.' ) ;
	putchar( '\n' ) ;
	}
}

void
buffer_operations( void )
{
	unsigned	current_offset = 0 ;
	int		need_redraw = 1 ;
	unsigned	offset, len ;
	unsigned	pattern ;
	char		temp[ 80 ] ;
	int		handle ;

START ;
while( 1 ){
	if( need_redraw ){
		draw_buffer( buffer + current_offset, SCREEN_SIZE, current_offset ) ;
                printf( "[H,U,D,G,F,S,E,R,W,C,X]\n" ) ;
		}
	need_redraw = 1 ;
	switch( toupper( (char)bioskey( 0 ) ) ){
		case 'X':
		case 0x1b:
			END ;
			return ;
		case 'U':
			if( current_offset >= PAGE_SIZE )
				current_offset -= PAGE_SIZE ;
			else	need_redraw = 0 ;
			break ;
		case 'D':
			if( current_offset < BUFFER_SIZE - 2 * PAGE_SIZE )
				current_offset += PAGE_SIZE ;
			else	need_redraw = 0 ;
			break ;
		case 'G':
			printf( "Go to offset : " ) ;
			scanf( "%x", &current_offset ) ;
			if( current_offset >= BUFFER_SIZE - PAGE_SIZE )
				current_offset = 0 ;
			break ;
		case 'F':
			printf( "Fill from offset : " ) ;
			scanf( "%x", &offset ) ;
			printf( "Length : " ) ;
			scanf( "%x", &len ) ;
			printf( "Pattern : " ) ;
			scanf( "%x", &pattern ) ;
			setmem( buffer + offset, len, pattern ) ;
			break ;
		case 'S':
			printf( "Set at offset : " ) ;
			scanf( "%x", &offset ) ;
			printf( "Value : " ) ;
			scanf( "%x", &pattern ) ;
			buffer[ offset ] = pattern ;
			break ;
		case 'E':
			printf( "Set at offset : " ) ;
			scanf( "%x", &offset ) ;
			printf( "Byte count : " ) ;
			scanf( "%x", &len ) ;
			for( ; len-- > 0 ; offset++ ){
				printf( "Value : " ) ;
				scanf( "%x", &pattern ) ;
				buffer[ offset ] = pattern ;
				}
			break ;
		case 'R':
			printf( "Read to offset : " ) ;
			scanf( "%x", &offset ) ;
			printf( "Byte count : " ) ;
			scanf( "%x", &len ) ;
			printf( "File : " ) ;
			scanf( "%s", temp ) ;
			if( ( handle = _open( temp, O_RDONLY | O_BINARY ) ) == -1 ){
				perror( temp ) ;
				break ;
				}
			if( _read( handle, buffer + offset, len ) != len )
				perror( temp ) ;
			_close( handle ) ;
			break ;
		case 'W':
			printf( "Write from offset : " ) ;
			scanf( "%x", &offset ) ;
			printf( "Byte count : " ) ;
			scanf( "%x", &len ) ;
			printf( "File : " ) ;
			scanf( "%s", temp ) ;
			if( ( handle = _creat( temp, 0 ) ) == -1 ){
				perror( temp ) ;
				break ;
				}
			if( _write( handle, buffer + offset, len ) != len )
				perror( temp ) ;
			_close( handle ) ;
			break ;
		case 'C':
			printf( "Set at offset : " ) ;
			scanf( "%x\n", &offset ) ;
			printf( "Type string : " ) ;
			gets( temp ) ;
			memcpy( buffer + offset, temp, strlen( temp ) ) ;
			break ;
                case 'H':
                        printf( "U - Up     D - Down  G - Go to  F - Fill  S - Set byte\n"
                                "E - Enter  R - Read  W - Write  X - Exit  C - set string\n" ) ;
		default:
			need_redraw = 0 ;
		}
	}
}

main( int argc, char *argv[] )
{
	int		cyl, hd ;
	char		key ;
	RW_INPUT	rw ;
	char		name[ 20 ] ;
	int		n, sc, gpl, d, lim ;

if( ( buffer = malloc( BUFFER_SIZE ) ) == NULL ){
	printf( "Can't allocate buffer space !\n" ) ;
	return( 3 ) ;
	}
if( argc > 1 ) FDD = atoi( argv[ 1 ] ) ;
delay( 1 ) ;
install_fdc_driver() ;
start_operations() ;
do {
	switch( setjmp( hang_reset ) ){
		case 0: break ;
		default:
			fprintf( stderr, "Unexpected hangup in function %s\n", current_function ) ;
			start_operations() ;
		}
	fprintf( stderr, "-----[H,S,D,R,A,E,B,T,F,L,P,W,C,O,I,M,Z] : " ) ;
	do	key = toupper( bioskey( 0 ) ) ;
	while( key == 0 ) ;
	printf( "%c\n", key ) ;
	switch( key ){
		case 'H':
			printf("H - Help        S - Seek        D - ST3         R - Read sector\n" ) ;
			printf("A - Read ID     E - Recalibrate B - BufOps      T - Analyze track\n" ) ;
			printf("F - AnalizeDisk L - ReadDeleted P - Data rate   W - WriteData\n" ) ;
			printf("C - read traCk  O - fOrmat      I - wrItedelete M - MFM/FM toggle\n" ) ;
			printf("Z - Exit\n" ) ;
			break ;
		case 'S':
			printf( "*Seek to cylinder : " ) ;
			scanf( "%x", &cyl ) ;
			seek( cyl ) ;
			break ;
		case 'D':
			read_ST3() ;
			explain_ST3() ;
			break ;
		case 'R':
			printf( "*Read data\n" ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			read_rw_input( &rw ) ;
				read_sector( hd, &rw ) ;
				print_rw_return() ;
			printf( "%d (%#4x) bytes read\n", buffer_bytes, buffer_bytes ) ;
			printf( "Operation time is not reliable !\n" ) ;
			break ;
		case 'L':
			printf( "*Read deleted data\n" ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			read_rw_input( &rw ) ;
				read_deleted( hd, &rw ) ;
				print_rw_return() ;
			printf( "%d (%#4x) bytes read\n", buffer_bytes, buffer_bytes ) ;
			printf( "Operation time is not reliable !\n" ) ;
			break ;
		case 'C':
			printf( "*Read a track\n" ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			read_rw_input( &rw ) ;
				read_track( hd, &rw ) ;
				print_rw_return() ;
			printf( "%d (%#4x) bytes read\n", buffer_bytes, buffer_bytes ) ;
			printf( "Operation time is not reliable !\n" ) ;
			break ;
		case 'W':
			printf( "*Write data\n" ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			printf( "Byte count : " ) ;
			scanf( "%x", &cyl ) ;
			read_rw_input( &rw ) ;
				write_sector( hd, cyl, &rw ) ;
				print_rw_return() ;
			printf( "%d (%#4x) bytes written\n", buffer_bytes, buffer_bytes ) ;
			printf( "Operation time is not reliable !\n" ) ;
			break ;
		case 'I':
			printf( "*Write deleted\n" ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			printf( "Byte count : " ) ;
			scanf( "%x", &cyl ) ;
			read_rw_input( &rw ) ;
				write_deleted( hd, cyl, &rw ) ;
				print_rw_return() ;
			printf( "%d (%#4x) bytes written\n", buffer_bytes, buffer_bytes ) ;
			printf( "Operation time is not reliable !\n" ) ;
			break ;
		case 'A':
			printf( "*Read address\n" ) ;
			printf( "Head = " ) ;
			scanf( "%x", &cyl ) ;
			read_address( cyl ) ;
			print_rw_return() ;
			print_chrn() ;
			break ;
		case 'E':
			printf( "*Recalibrating\n" ) ;
			recalibrate() ;
			break ;
		case 'B':
			buffer_operations() ;
			break ;
		case 'T':
			printf( "Analyze cylinder : " ) ;
			scanf( "%x", &cyl ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			out = stdout ;
			analyze_track( cyl, hd ) ;
			break ;
		case 'F':
			printf( "Analyze from cylinder : " ) ;
			scanf( "%x", &cyl ) ;
			printf( "Cylinder count : " ) ;
			scanf( "%x", &hd ) ;
			printf( "File for output : " ) ;
			scanf( "%s", name ) ;
			if( ( out = fopen( name, "wt" ) ) == NULL ){
				perror( name ) ;
				break ;
				}
			analyze_disk( cyl, hd ) ;
			fclose( out ) ;
			break ;
		case 'P':
			printf( "Select rate : 0 - 500 KBS, 1 - 300 KBS, 2 - 250 KBS\n" ) ;
			scanf( "%x", &cyl ) ;
			outportb( FDC_RATE, cyl ) ;
			break ;
		case 'O':
			printf( "*Format a track using IDs from buffer\n" ) ;
			printf( "Head : " ) ;
			scanf( "%x", &hd ) ;
			printf( "N   = " ) ;
			scanf( "%x", &n ) ;
			printf( "SC  = " ) ;
			scanf( "%x", &sc ) ;
			printf( "GPL = " ) ;
			scanf( "%x", &gpl ) ;
			printf( "D   = " ) ;
			scanf( "%x", &d ) ;
			printf( "TC  = " ) ;
			scanf( "%x", &lim ) ;
				format_track( hd, n, sc, gpl, d, buffer, lim ) ;
				print_rw_return() ;
			printf( "%x bytes transferred as IDs\n", buffer_bytes ) ;
			break ;
		case 'M':
			if( mfm ) mfm = 0 ;
			else	  mfm = 0x40 ;
			printf( "Current mode is %s\n", mfm ? "MFM" : "FM" ) ;
			break ;
		case 'Z':
			reset_old_fdc() ;
			return( 0 ) ;
		default:
			printf( "No action for this key : %c\n", key ) ;
			break ;
		}
	printf( "Elapsed time is %8.3f ms\n", elapsed_time / ( 1193.180 * 2 ) ) ;
	} while( 1 ) ;
}
