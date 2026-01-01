/*
 * far string library header file
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#ifndef _Cdecl
#if __STDC__
#define _Cdecl
#else
#define _Cdecl cdecl
#endif
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

size_t    _Cdecl fstrlen(const char far *s);

char far *_Cdecl fstrchr(const char far *s, int c);

char far *_Cdecl fstrupr(char far *dst, const char far *src);
char far *_Cdecl fstrlwr(char far *dst, const char far *src);

char far *_Cdecl fstrcat(char far *dst, const char far *src);
char far *_Cdecl fstrcpy(char far *dst, const char far *src);

int       _Cdecl fstrcmp(const char far *s1, const char far *s2);
char far *_Cdecl fstrstr(const char far *s1, const char far *s2);

char far *_Cdecl fstrncat(char far *dst, const char far *src, size_t maxlen);
char far *_Cdecl fstrncpy(char far *dst, const char far *src, size_t maxlen);


