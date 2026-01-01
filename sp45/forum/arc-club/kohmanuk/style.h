/*	style.h

	Useful types, macros, etc.
*/


typedef	signed char	BYTE;
typedef	signed int	WORD;
typedef	signed long	LONG;
typedef	unsigned char	UBYTE;
typedef	unsigned int	UWORD;
typedef	unsigned long	ULONG;


#define	arraySize(array)	(sizeof (array) / sizeof ((array) [0]) )
