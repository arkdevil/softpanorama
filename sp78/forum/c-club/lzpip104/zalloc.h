/*
 The following sorce code is derived from Info-Zip 'zip' 2.01
 distribution copyrighted by Mark Adler, Richard B. Wales,
 Jean-loup Gailly, Kai Uwe Rommel, Igor Mandrichenko and John Bush.
*/
#ifdef __COMPILER_KCC__
#  define TOPS20
#  define BIG_MEM
#endif
#ifdef MACOS
#  define DYN_ALLOC
#endif
/* Under MSDOS we may run out of memory when processing a large number
   of files. Compile with MEDIUM_MEM to reduce the memory requirements
   or with SMALL_MEM to use as little memory as possible. */
#ifndef DYN_ALLOC
#  ifdef BIG_MEM
#     define DYN_ALLOC
#  endif
#  ifdef MMAP
#     define DYN_ALLOC
#  endif
#endif
#ifdef MSDOS
#  ifndef __GO32__
#    ifndef WIN32
#      define DYN_ALLOC
#      ifdef __TURBOC__
#        include <alloc.h>
/* Turbo C 2.0 does not accept static allocations of large arrays */
         void far *zalloc(void far **, unsigned, unsigned);
#        define zfree(p) farfree(p);
#      else
#        include <malloc.h>
#        define zalloc(p,n,s) halloc((long)(n),(s));
#        define zfree(p)      hfree((void huge *)(p));
#      endif
#    endif
#  endif
#endif

#ifndef zfree
#  ifdef WIN32
#    include <malloc.h>
#  endif
#  ifdef __WATCOMC__
#    undef far
#    undef near
#  endif
#  ifndef __IBMC__
#    define far
#    define near
#    define huge
#  endif
#  define zalloc(p,n,s) calloc((long)(n),(s));
#  define zfree(p)      free((void huge *)(p));
#  ifndef MODERN
#    ifndef TOPS20
       char *calloc(); /* essential for 16 bit systems (AT&T 6300) */
#    endif
#  endif
#endif
