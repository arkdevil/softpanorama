#include <stdio.h>
#include <string.h>
#include <dir.h>

#include "elib.h"



/*
 * hashpjw
 *
 * hash function.  Used in P. J. Weinberger's portable C compiler and
 * gotten from page 436 of the Dragon book on compilers (Compilers: Principles,
 * Techniques and Tools, by Aho, Sethi and Ullman.  Copyright (c) 1986 by
 * Bell Telephone Laboratories).
 */
int hashpjw(char *s)

{
	char *p;
	unsigned long h = 0, g;

	g = h & 0xf0000000;

	for (p = s; *p != '\0'; p++) {
		h = (h << 4) + (*p);
		g = h & 0xf0000000;
		if (g) {
			h ^= (g >> 24);
			h ^= g;
		}
	}

	return h % HASH_TAB_SIZE;
}
