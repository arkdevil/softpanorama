XLISP version 1.4 Distribution Disk - December 31, 1984

By:  David Betz
     114 Davenport Ave.
     Manchester, NH 03103
     (603) 625-4691 (home)

This disk contains the following files:

Documentation

XLISP.MEM	XLISP document
README.TXT	this file

Executable program

XLISP.EXE	XLISP for MS-DOS (CI-C86 small model)

Interpreter sources

XLISP.C		the main entry point
XLISP.H		XLISP include file
XLREAD.C	reader (including the load function)
XLEVAL.C	evaluator
XLPRIN.C	printer
XLDBUG.C	debugging and error handling routines
XLSUBR.C	built-in subr/fsubr support routines
XLBIND.C	symbol binding routines
XLJUMP.C	non-local jump routines
XLINIT.C	initialization code
XLSYM.C		symbol table routines
XLIO.C		i/o support routines
XLDMEM.C	dynamic memory routines (garbage collector)
XLGLOB.C	global variable declarations

Built-in functions

XLFTAB.C	function initialization table
XLBFUN.C	basic functions
XLSETF.C	setf function
XLLIST.C	list functions
XLCONT.C	control functions
XLMATH.C	arithmetic functions
XLFIO.C		file i/o functions
XLSTR.C		string functions
XLSYS.C		system functions

Object-oriented programming support

XLOBJ.C		object-oriented programming support
XLSTUB.C	stubs for XLOBJ.C (to remove object support)

Sample XLISP code

INIT.LSP	sample initialization file
PROLOG.LSP	tiny prolog interpreter
PT.LSP		programmable turtle program
FACT.LSP	factorial function
TRACE.LSP	simple trace facility
ART.LSP		code from the Byte article on XLISP

Note:

In order to create a version of XLISP with object-oriented programming
support, include the file XLOBJ and leave out XLSTUB.  In order to
create a version without object-oriented programming support, include
the file XLSTUB and not the file XLOBJ.
