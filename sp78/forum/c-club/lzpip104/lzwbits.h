/* lzwbits.h */

/* Set USERMEM to the maximum amount of physical user memory available
 * in bytes.  USERMEM is used to determine the maximum BITS that can be used
 * for compression.
 *
 * SACREDMEM is the amount of physical memory saved for others; compress
 * will hog the rest.
 */
#ifndef SACREDMEM
# define SACREDMEM 0
#endif

#ifndef USERMEM
# define USERMEM 450000L /* default user memory */
#endif

#ifdef pdp11
# define BITS	12	/* max bits/code for 16-bit machine */
# define NO_UCHAR	/* also if "unsigned char" functions as signed char */
# undef USERMEM		/* don't forget to compile with -i */
#endif

#ifdef z8000
# define BITS 12
# undef vax	/* weird preprocessor */
# undef USERMEM
#endif

#ifdef __TURBOC__
# ifndef MSDOS
#  define MSDOS
# endif
#endif

#ifdef MSDOS
# define BIG
# undef USERMEM
# ifdef BIG		/* then this is a large data compilation */
#  define BITS	 16
#  define XENIX_16
# else			/* this is a small model compilation */
#  define BITS	 12
# endif
#else
#undef BIG
#endif

#ifdef pcxt
# define BITS	12
# undef USERMEM
#endif

#ifdef USERMEM
# if USERMEM >= (433484L+SACREDMEM)
#  define PBITS 16
# else
#  if USERMEM >= (229600L+SACREDMEM)
#   define PBITS	15
#  else
#   if USERMEM >= (127536L+SACREDMEM)
#    define PBITS	14
#   else
#    if USERMEM >= (73464L+SACREDMEM)
#     define PBITS	13
#    else
#     define PBITS	12
#    endif
#   endif
#  endif
# endif
# undef USERMEM
#endif

#ifdef PBITS
# ifndef BITS
#  define BITS PBITS /* Preferred BITS for this memory size */
# endif
#endif

#ifdef M_XENIX
# ifndef i386
#  if BITS == 16	/* Stupid compiler can't handle arrays with */
#   define XENIX_16	/* more than 65535 bytes - so we fake it */
#  else
#   if BITS > 13	/* Code only handles BITS = 12, 13, or 16 */
#    define BITS 13
#   endif
#  endif
# endif
#endif

/* signed compare is slower than unsigned (Perkin-Elmer) */
#ifdef interdata
#	define SIGNED_COMPARE_SLOW
#endif
#ifdef SIGNED_COMPARE_SLOW
#	define to_compare(x) (unsigned)(x)
#else
#	define to_compare(x) (x)
#endif

#if BITS == 16
# define _HSIZE	69001L	/* 95% occupancy */
#endif
#if BITS == 15
# define _HSIZE	35023L	/* 94% occupancy */
#endif
#if BITS == 14
# define _HSIZE	18013L	/* 91% occupancy */
#endif
#if BITS == 13
# define _HSIZE	9001L	/* 91% occupancy */
#endif
#if BITS <= 12
# define _HSIZE	5003L	/* 80% occupancy */
#endif

/* a code_int must be able to hold 2**BITS values of type int, and also -1 */
#if BITS > 15
#	define code_int long
#else
#	define code_int int
#endif

#ifdef SIGNED_COMPARE_SLOW
#	define count_int unsigned long
#else
#	define count_int long
#endif

#ifdef NO_UCHAR
#	define char_type char
#	define char_to_byte(x) ((x) & 0xff)
#else
#	define char_type unsigned char
#	define char_to_byte(x) (x)
#endif

/* Magic header bytes */
#define LZW_0TH_MAGIC 0x1f
#define LZW_1ST_MAGIC 0x9d
/* Defines for third byte of header */
/* Masks 0x40 and 0x20 are reserved for future. */
#define BIT_MASK   0x1f
#define BLOCK_MASK 0x80
#define INIT_BITS 9 /* initial number of bits/code */

#define MAXCODE(n_bits)	(((code_int) 1 << (n_bits)) - 1)

#ifdef XENIX_16
#	define PAGEXP   13
#	define PAGESIZE (1<<PAGEXP)
#	define PAGEMASK (PAGESIZE-1)
#	define MAXPAGES (int)((_HSIZE+PAGESIZE-1)/PAGESIZE)
#	define NUMPAGES (int)((((code_int)1 << BITS) + PAGESIZE-1)/PAGESIZE)
#endif

#define CHECK_GAP 10000 /* ratio check interval */

/* the next two codes should not be changed lightly, as they */
/* must not lie within the contiguous general code space.    */
#define FIRST	257	/* first free entry */
#define CLEAR	256	/* table clear output code */
