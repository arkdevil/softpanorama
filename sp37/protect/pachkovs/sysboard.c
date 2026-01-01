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
static  char    __rights__[] = "Motherboard indentifier module. (C) 1991 Serge S. Pachkovsky" ;

#pragma inline
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <alloc.h>

#define INSTRUCTIONS    (16*1024u)

void
init_timer_channel( unsigned char channel )
{
asm     pushf
asm     cli
asm     mov     al, channel
asm     ror     al, 1
asm     ror     al, 1
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

unsigned
read_sound_timer( void )
{
/*
 *      ! This function should not change any register except AX !
 */
asm     mov     al, 80h
asm     out     43h, al
asm     jmp     $+2
asm     jmp     $+2
asm     in      al, 42h
asm     jmp     $+2
asm     mov     ah, al
asm     in      al, 42h
asm     xchg    ah, al
asm     neg     ax
return _AX ;
}

#define disable_count() (outportb(0x61,inportb(0x61)&(unsigned char)~1))
#define enable_count()  (outportb(0x61,inportb(0x61)|(unsigned char)1))

void
instruction_fill( char far *buf, unsigned cnt, char instr[ 2 ] )
{
while( cnt-- > 0 ){
        *buf++ = instr[ 0 ] ;
        *buf++ = instr[ 1 ] ;
        }
*buf++ = 0xCB ; /* retf */
}

unsigned
measure( char far *routine )
{
        unsigned        time ;

init_timer_channel( 2 ) ;
disable_count() ;
asm     push    cs
asm     lea     ax, ret_point
asm     push    ax
asm     les     bx, routine
asm     push    es
asm     push    bx
asm     xor     dx, dx
asm     mov     bx, 1
asm     cli
        enable_count() ;
asm     mov     ax, bx
asm     retf
asm     ret_point       label   near
        disable_count() ;
        time = read_sound_timer() ;
asm     sti
return time ;
}

int
main( int argc, char *argv[] )
{
        char    far     *buf ;
        unsigned        idle_time ;
        unsigned        CPU_mark, mem_mark, DMA_mark ;

if( ( buf = farmalloc( INSTRUCTIONS * 2 + 1 ) ) == NULL ){
        perror( "No memory" ) ;
        return -1 ;
        }
            instruction_fill( buf, 0, NULL ) ;
idle_time = measure( buf ) ;
            instruction_fill( buf, INSTRUCTIONS, "\xF7\xF3" ) ;
CPU_mark  = measure( buf ) - idle_time ;                /* div bx       */
            instruction_fill( buf, INSTRUCTIONS, "\xC4\x07" ) ;
mem_mark  = measure( buf ) - idle_time ;                /* les ax, [bx] */
            instruction_fill( buf, INSTRUCTIONS, "\xE6\x0C" ) ;
DMA_mark  = measure( buf ) - idle_time ;                /* out 0Ch, al  */
printf( "Idle time   = %u\n", idle_time ) ;
printf( "CPU mark    = %u\n", CPU_mark ) ;
printf( "Memory mark = %u\n", mem_mark ) ;
printf( "DMA mark    = %u\n", DMA_mark ) ;
return 0 ;
}
