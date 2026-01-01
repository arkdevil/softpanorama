/*
 The following sorce code is derived from Info-Zip 'zip' 2.01
 distribution copyrighted by Mark Adler, Richard B. Wales,
 Jean-loup Gailly, Kai Uwe Rommel, Igor Mandrichenko and John Bush.
*/
#ifdef __human68k__
#  define OS_CODE 3 /* pretend it's Unix */
#endif
/* The following OS codes are defined in pkzip appnote.txt */
#ifdef AMIGA
#  define OS_CODE 1
#endif
#ifdef VMS
#  define OS_CODE 2
#endif
/* unix    3 */
/* vms/cms 4 */
#ifdef ATARI_ST
#  define OS_CODE 5
#endif
#ifdef OS2
#  define OS_CODE 6
#endif
#ifdef MACOS
#  define OS_CODE 7
#endif
/* z system 8 */
/* cp/m     9 */
#ifdef TOPS20
#  define OS_CODE 10
#endif
#ifdef WIN32
#  define OS_CODE 11
#endif
/* qdos 12 */

#ifndef OS_CODE
#  ifdef MSDOS
#    define OS_CODE 0
#  else
#    define OS_CODE 3 /* assume Unix */
#    ifndef UNIX
#      define UNIX
#    endif
#  endif
#endif
