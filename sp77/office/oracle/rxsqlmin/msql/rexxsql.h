/***********************************************************************/
/* rexxsql.h - REXX/SQL for mSQL                                       */
/***********************************************************************/
/*
 * REXX/SQL. A REXX interface to SQL databases.
 * Copyright Mark Hessling 1995.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to:
 *
 *    The Free Software Foundation, Inc.
 *    675 Mass Ave,
 *    Cambridge, MA 02139 USA.
 *
 *
 * If you make modifications to this software that you feel increases
 * it usefulness for the rest of the community, please email the
 * changes, enhancements, bug fixes as well as any and all ideas to 
 * address below.
 * This software is going to be maintained and enhanced as deemed
 * necessary by the community.
 *
 * Mark Hessling                     email: M.Hessling@qut.edu.au
 * 36 David Road                     Phone: +61 7 849 7731
 * Holland Park                      
 * QLD 4121
 * Australia
 *
 * Author:	Mark Hessling
 *
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#if defined(__OS2__)
#   define OS2 3
#   if defined(__DLL__)
#      define _DLL
#   endif
#   include <os2.h>
#endif

#if defined(UNIX)
#include <unistd.h>
#endif

#include "msql.h"
#if 0
#include "msql_priv.h"
#endif


#define MAX_COLS       75
#define MAX_NAMELEN   100

#if defined(MIN_PREFIX)
#define DLLNAME "REXXMIN"
#define DEFAULT_CONNECTION	"MIN"       /* Name of the unnamed connection */
#define DEFAULT_STEM		"MIN"   /* Default stem name of implicit stmt */
#else
#define DLLNAME "REXXSQL"
#define DEFAULT_CONNECTION	"SQL"       /* Name of the unnamed connection */
#define DEFAULT_STEM		"SQL"   /* Default stem name of implicit stmt */
#endif

/* Run time modes */
#define MODE_DEBUG	1
#define MODE_VERBOSE	2

#if __STDC__
int	InitRexxSQL(PSZ progname);
int	TerminateRexxSQL(PSZ progname);
#else
int	InitRexxSQL();
int	TerminateRexxSQL();
#endif

#if defined(__OS2__) && defined(__IBMC__)
#   if defined(__DLL__)
#      define DYNAMIC_LIBRARY 1
#   endif
#   if defined(THUNK)
#      define MSQL_RETURN_TYPE APIRET16 APIENTRY16
#   else
#      define MSQL_RETURN_TYPE ULONG APIENTRY
#   endif
#else
#   define MSQL_RETURN_TYPE int
#endif

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

/* Names of SQL interface functions */
#if defined(MIN_PREFIX)
#define NAME_SQLVARIABLE	"MINVARIABLE"
#define NAME_SQLCONNECT		"MINCONNECT"
#define NAME_SQLDISCONNECT	"MINDISCONNECT"
#define NAME_SQLDEFAULT		"MINDEFAULT"
#define NAME_SQLCOMMIT		"MINCOMMIT"
#define NAME_SQLROLLBACK	"MINROLLBACK"
#define NAME_SQLCOMMAND		"MINCOMMAND"
#define NAME_SQLPREPARE		"MINPREPARE"
#define NAME_SQLDISPOSE		"MINDISPOSE"
#define NAME_SQLOPEN		"MINOPEN"
#define NAME_SQLCLOSE		"MINCLOSE"
#define NAME_SQLFETCH		"MINFETCH"
#define NAME_SQLEXECUTE		"MINEXECUTE"
#define NAME_SQLEXEC		"MINEXEC"
#define NAME_SQLDESCRIBE	"MINDESCRIBE"
#if defined(DYNAMIC_LIBRARY)
#   define NAME_SQLLOADFUNCS	"MINLOADFUNCS"
#   define NAME_SQLDROPFUNCS	"MINDROPFUNCS"
#endif
#else
#define NAME_SQLVARIABLE	"SQLVARIABLE"
#define NAME_SQLCONNECT		"SQLCONNECT"
#define NAME_SQLDISCONNECT	"SQLDISCONNECT"
#define NAME_SQLDEFAULT		"SQLDEFAULT"
#define NAME_SQLCOMMIT		"SQLCOMMIT"
#define NAME_SQLROLLBACK	"SQLROLLBACK"
#define NAME_SQLCOMMAND		"SQLCOMMAND"
#define NAME_SQLPREPARE		"SQLPREPARE"
#define NAME_SQLDISPOSE		"SQLDISPOSE"
#define NAME_SQLOPEN		"SQLOPEN"
#define NAME_SQLCLOSE		"SQLCLOSE"
#define NAME_SQLFETCH		"SQLFETCH"
#define NAME_SQLEXECUTE		"SQLEXECUTE"
#define NAME_SQLEXEC		"SQLEXEC"
#define NAME_SQLDESCRIBE	"SQLDESCRIBE"
#if defined(DYNAMIC_LIBRARY)
#   define NAME_SQLLOADFUNCS	"SQLLOADFUNCS"
#   define NAME_SQLDROPFUNCS	"SQLDROPFUNCS"
#endif
#endif

/* Directory separator is:
 * UNIX		'/'
 * MS-DOS	'\'
 * OS/2	'\'
 * VMS		']' & ':'
 */

#ifdef OS2
#define BAD_ARGS	0
#define REXX_FAIL	1
#define DIRSEP(ch) (ch == '\\')
#define CURRENT_OS "OS/2"
#endif

#ifdef MSDOS
#define BAD_ARGS	0
#define REXX_FAIL	1
#define DIRSEP(ch) (ch == '\\')
#define CURRENT_OS "DOS"
#endif

#ifdef UNIX
#define BAD_ARGS	2
#define REXX_FAIL	1
#define DIRSEP(ch) (ch == '/')
#define CURRENT_OS "UNIX"
#endif

#ifdef VMS
#define BAD_ARGS	0
#define REXX_FAIL	0
#define DIRSEP(ch) (ch == ']' || ch == ':')
#define CURRENT_OS "VMS"
#endif

#define REXXSQL_VERSION "1.1"
#define REXXSQL_DATE    "10 Jun 1995"

#define NO_DATA_FOUND   1
