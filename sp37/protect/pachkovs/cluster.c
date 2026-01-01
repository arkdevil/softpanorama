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
static  char    __rights__[] = "(C) 1991 Serge S. Pachkovsky" ;

#pragma  inline
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <dir.h>
#include <dos.h>
#include <mem.h>
#include <string.h>
#include <ctype.h>
#include <alloc.h>
#include <limits.h>
#include <stdarg.h>

typedef struct  _DI {
        unsigned        char    drv ;           /* Drive number 0 - A:  */
        unsigned        char    subunit ;       /* From device header   */
        unsigned                sect_siz ;      /* Sector size          */
        unsigned        char    hi_sector ;     /* Hi sector in cluster */
        unsigned        char    cls_shift ;     /* Cluster to sector shf*/
        unsigned                boot_siz ;      /* Reserved sectors     */
        unsigned        char    fats ;          /* Number of FATs       */
        unsigned                max_dir ;       /* Number of root dir.. */
        unsigned                data_sec ;      /* First data cluster   */
        unsigned                hi_clust ;      /* Clusters + 2         */
        union   {
                struct  {
                        unsigned        char    fat_size ;      /* Sectors / FAT        */
                        unsigned                root_sec ;      /* Start of ROOT        */
                        void            far     *device ;       /* Addr of device header*/
                        unsigned        char    media ;         /* Media descriptor     */
                        unsigned        char    access ;        /* 0 if has been accesed*/
                        struct _DI      far     *next ;         /* Next disk info block */
                        } dos3 ;
                struct  {
                        unsigned                fat_size ;      /* Sectors / FAT        */
                        unsigned                root_sec ;      /* Start of ROOT        */
                        void            far     *device ;       /* Addr of device header*/
                        unsigned        char    media ;         /* Media descriptor     */
                        unsigned        char    access ;        /* 0 if has been accesed*/
                        struct _DI      far     *next ;         /* Next disk info block */
                        } dos4 ;
                } dos_dependent ;
        } DISK_INFO ;

typedef struct  {
        char            file_name[ 8 ] ;
        char            file_ext[ 3 ] ;
        char            file_attribute ;
        char            __unused[ 10 ] ;
        unsigned        time ;
        unsigned        date ;
        unsigned        cluster ;
        long            file_size ;
        } DIRECTORY_ENTRY ;

static  DISK_INFO       source_disk_info ;
enum {  FAT_16, FAT_12  } ;
static  int             fat_type = FAT_16 ;

static int near
get_disk_info( char *name )
{
        unsigned        char    drive ;
        DISK_INFO       far     *p ;

drive = toupper( *name ) - 'A' ;
asm     push    ds
asm     mov     dl, drive
asm     inc     dl
asm     mov     ah, 32h
asm     int     21h
asm     cmp     al, 0
asm     jne     error
asm     mov     dx, ds
asm     pop     ds
        p = MK_FP( _DX, _BX ) ;
        source_disk_info = *p ;
        return 0 ;
error:
asm     pop     ds
return -1 ;
}

static unsigned near
get_fat( char huge *fat, unsigned clust )
{
        unsigned        temp_clust ;
        unsigned        x ;

switch( fat_type ){
        case FAT_12:
                temp_clust = ( clust * 3 ) / 2 ;
                x = *(unsigned huge *)( fat + temp_clust ) ;
                if( ( clust & 1 ) == 0 )
                        x &= 0xfff ;
                else    x >>= 4 ;
                if( ( x & 0xfff ) > 0xff0 )
                        x |= 0xf000 ;
                break ;
        case FAT_16:
                x = *( (unsigned huge *)fat + clust ) ;
                break ;
        }
return x ;
}

static unsigned near
search_start_cluster( char *name )
{
        char            dir[ MAXDIR ] ;
        char            drive[ MAXDRIVE ] ;
        char            file[ MAXFILE ] ;
        char            ext[ MAXEXT ] ;
        struct  xfcb    xfcb ;
        struct  fcb     *fcb = &xfcb.xfcb_fcb ;
        char            dta[ sizeof( DIRECTORY_ENTRY ) + 9 ] ;
        char    far     *old_dta ;


printf( "Looking for first cluster number of %s\n", name ) ;
setdisk( toupper( *name ) - 'A' ) ;
if( getdisk() != toupper( *name ) - 'A' ){
        printf( "setdisk(%d) failure\n", toupper( *name ) - 'A' ) ;
        return 0xffff ;
        }
fnsplit( name, drive, dir, file, ext ) ;
if( strlen( dir ) > 1 )
        dir[ strlen( dir ) - 1 ] = 0 ;
if( chdir( dir ) == -1 ){
        printf( "chdir(%s) failure\n", dir ) ;
        return 0xffff ;
        }
old_dta = getdta() ;
setdta( dta ) ;
xfcb.xfcb_flag = 0xff ;
setmem( xfcb.xfcb_resv, sizeof( xfcb.xfcb_resv ), 0xff ) ;
xfcb.xfcb_attr = FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_ARCH ;
fcb->fcb_drive = 0 ;
setmem( fcb->fcb_name, 8 + 3, ' ' ) ;
memcpy( fcb->fcb_name, file, strlen( file ) ) ;
if( strlen( ext ) != 0 )
        memcpy( fcb->fcb_ext, ext + 1, strlen( ext + 1 ) ) ;
asm     push    ds
asm     mov     dx, ss
asm     mov     ds, dx
asm     lea     dx, xfcb
asm     mov     ah, 11h
asm     int     21h
asm     pop     ds
if( _AL != 0 ){
        printf( "DOS fun 11h failure (%u)\n", _AL ) ;
        return 0xffff ;
        }
setdta( old_dta ) ;
return ((DIRECTORY_ENTRY *)( dta + 8 ))->cluster ;
}

/*
 *      abs_read/abs_write section
 */
static  int     abs_error = 0 ;

static int near
abs_read( int drive, int start, int len, void far *buf )
{
asm     push    si
asm     push    di
asm     push    ds
        asm     mov     al, drive
        asm     mov     cx, len
        asm     mov     dx, start
        asm     lds     bx, dword ptr buf
        asm     int     25h
        asm     pop     dx
asm     pop     ds
asm     pop     di
asm     pop     si
        asm     jnc     no_error
        asm     mov     abs_error, ax
        return -1 ;
no_error:
return 0 ;
}

static char huge * near
load_fat( void )
{
        char    huge    *fat ;
        char    huge    *p ;
        unsigned        fat_size ;
        unsigned        sectors_per_call ;
        unsigned        fat_start ;

if( _osmajor >= 4 )
        fat_size = source_disk_info.dos_dependent.dos4.fat_size ;
else    fat_size = source_disk_info.dos_dependent.dos3.fat_size ;
if( ( fat = (char huge *)farmalloc( source_disk_info.sect_siz * fat_size ) ) == NULL )
        return NULL ;
sectors_per_call = 0x8000u / source_disk_info.sect_siz ;
for( p = fat, fat_start = source_disk_info.boot_siz ; fat_size > 0 ;
                fat_size -= min( sectors_per_call, fat_size ),
                p += sectors_per_call * source_disk_info.sect_siz,
                fat_start += sectors_per_call )
        if( abs_read( source_disk_info.drv, fat_start, min( fat_size, sectors_per_call ), (void far *)p ) == -1 ){
                farfree( (void far *)fat ) ;
                return NULL ;
                }
return fat ;
}

static void near
detect_fat_type( void )
{
if( _osmajor <= 2 )
        fat_type = FAT_12 ;
else    if( source_disk_info.hi_clust > 4086 )
                fat_type = FAT_16 ;
        else    fat_type = FAT_12 ;
}

static unsigned near
collect_chain( char huge *fat, unsigned start_cluster )
{
        unsigned        clusters ;

printf( "Clusters chain is :\n" ) ;
for( clusters = 0 ; start_cluster < 0xfff0 ; clusters++ ){
        start_cluster = get_fat( fat, start_cluster ) ;
        printf( "%5u ", start_cluster ) ;
        if( clusters % 10 == 9 ) putchar( '\n' ) ;
        }
if( clusters % 10 != 0 ) putchar( '\n' ) ;
return clusters ;
}

int
main( int argc, char *argv[] )
{
        unsigned        start_cluster ;
        char            huge    *fat ;  /* Must be HUGE for DOS 4.x     */
        unsigned        clusters ;
        char            directory[ MAXPATH + 1 ] ;
        int             disk ;
        char            *name ;


if( argc != 2 ){
        printf( "Type : Cluster full_file_name\n" ) ;
        return -1 ;
        }
name = argv[ 1 ] ;
disk = getdisk() ;
getcurdir( disk + 1, directory + 1 ) ;
directory[ 0 ] = '\\' ;
if( directory[ 1 ] == '\\' ) directory[ 1 ] = 0 ;
if( get_disk_info( name ) == -1 ){
        printf( "Get disk info failure\n" ) ;
        chdir( directory ) ;
        setdisk( disk ) ;
        return -1 ;
        }
if( ( start_cluster = search_start_cluster( name ) ) == 0xffff ){
        printf( "Get start cluster failure\n" ) ;
        chdir( directory ) ;
        setdisk( disk ) ;
        return -1 ;
        }
printf( "Starting cluster number is %u\n", start_cluster ) ;
if( start_cluster == 0 ){
        chdir( directory ) ;
        setdisk( disk ) ;
        return -1 ;
        }
if( ( fat = load_fat() ) == NULL ){
        printf( "Load FAT failure\n" ) ;
        chdir( directory ) ;
        setdisk( disk ) ;
        return -1 ;
        }
detect_fat_type() ;
clusters = collect_chain( fat, start_cluster ) ;
printf( "Total number of clusters is %d\n", clusters ) ;
farfree( (void far *)fat ) ;
chdir( directory ) ;
setdisk( disk ) ;
return 0 ;
}
