/*	squo.h

	General-purpose library for array-oriented packing
*/

#include <stdlib.h>

extern	char	SquoVersion [];

typedef	size_t	ReadFunc (void * buffer, size_t size);
typedef	size_t	WriteFunc (void * buffer, size_t size);

extern	int	SquoPack (ReadFunc *reader, WriteFunc *writer);
extern	int	SquoUnpack (ReadFunc *reader, WriteFunc *writer);
