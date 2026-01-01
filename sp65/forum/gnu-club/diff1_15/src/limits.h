/* limits.h - implementation dependent limits
   Copyright (C) 1988, 1989 Free Software Foundation, Inc.

This file is part of GNU DIFF.

GNU DIFF is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU DIFF is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU DIFF; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
This port is also distributed under the terms of the GNU General
Public License as published by the Free Software Foundation.

Please note that this file is not identical to the original GNU release,
you should have received this code as patch to the official release.

$Header: e:/gnu/diff/RCS/limits.h 1.15.0.1 91/03/12 10:58:28 tho Exp $  */

/* Number of bits in a `char'.  */
#define CHAR_BIT 8

/* No multibyte characters supported yet.  */
#define MB_LEN_MAX 1

/* Minimum and maximum values a `signed char' can hold.  */
#define SCHAR_MIN (-128)
#define SCHAR_MAX 127

/* Maximum value an `unsigned char' can hold.  (Minimum is 0).  */
#define UCHAR_MAX 255U

/* Minimum and maximum values a `char' can hold.  */
#ifdef __CHAR_UNSIGNED__
#define CHAR_MIN 0
#define CHAR_MAX 255U
#else
#define CHAR_MIN (-128)
#define CHAR_MAX 127
#endif

/* Minimum and maximum values a `signed short int' can hold.  */
#define SHRT_MIN (-32768)
#define SHRT_MAX 32767

/* Maximum value an `unsigned short int' can hold.  (Minimum is 0).  */
#define USHRT_MAX 65535U

/* Minimum and maximum values a `signed int' can hold.  */
#define INT_MIN (-INT_MAX-1)
#ifdef MSDOS
#define INT_MAX 32767
#else
#define INT_MAX 2147483647
#endif

/* Maximum value an `unsigned int' can hold.  (Minimum is 0).  */
#ifdef MSDOS
#define UINT_MAX 65535U
#else
#define UINT_MAX 4294967295U
#endif


/* Minimum and maximum values a `signed long int' can hold.
   (Same as `int').  */
#define LONG_MIN (-LONG_MAX-1)
#define LONG_MAX 2147483647

/* Maximum value an `unsigned long int' can hold.  (Minimum is 0).  */
#define ULONG_MAX 4294967295U
