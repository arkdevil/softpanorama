/* It's not appropriate place, but I don't know
 * where to put the following defines */

/* Define MSDOS for Turbo C and Power C */
#ifdef __POWERC
#  define __TURBOC__
#  define MSDOS
#endif
#ifndef MSDOS
#  ifdef __MSDOS__
#    define MSDOS
#  endif
#endif

/* use prototypes and ANSI libraries if __STDC__, or Microsoft or Borland C,
 * or Silicon Graphics, or Convex, or IBM C Set/2, or GNU gcc under emx,
 * or Watcom C, or Macintosh, or Windows NT.
 */
#if __STDC__
#  define MODERN
#endif
#ifndef MODERN
#  ifdef MSDOS
#    define MODERN
#  endif
#endif
#ifndef MODERN
#  ifdef ATARI_ST
#    define MODERN
#  endif
#endif
#ifndef MODERN
#  ifdef __TURBOC__
#    define MODERN
#  endif
#  ifdef CONVEX
#    define MODERN
#  endif
#  ifdef sgi
#    define MODERN
#  endif
#endif
#ifndef MODERN
#  ifdef __IBMC__
#    define MODERN
#  endif
#  ifdef __EMX__
#    define MODERN
#  endif
#  ifdef __WATCOMC__
#    define MODERN
#  endif
#  ifdef THINK_C
#    define MODERN
#  endif
#  ifdef MPW
#    define MODERN
#  endif
#  ifdef WIN32
#    define MODERN
#  endif
#endif
#ifndef MODERN
#  ifdef __BORLANDC__
#    define MODERN
#  endif
#  ifdef __alpha
#    ifdef VMS
#      define MODERN
#    endif
#  endif
#endif
#ifndef __ARGS__
#  ifdef MODERN
#    ifndef __COMPILER_KCC__
#      ifndef __GNUC__ /* f...d compiler! */
#        define __ARGS__(x) x
#      endif
#    endif
#  endif
#endif
#ifndef __ARGS__
#  define __ARGS__(x) ()
#endif
