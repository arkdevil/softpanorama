			WIZUNZIP 2.0 SOURCE FILES 					10/1/93

INTRODUCTION
This archive contains the source files which you can use to 
re-create WizUnZip 2.0.  WizUnZip is a non-profit Windows
unzipper product, based on the Info-ZIP group's 
product, unzip.  Johnny Lee and I, who wrote the Windows 
interface code, have chosen to place our code in the public domain 
for you to use freely.

DEVELOPMENT SYSTEM REQUIREMENTS
To re-create WizUnZip, you'll need a `C' Compiler and possibly
a Windows Software Development Kit.  I use Microsoft `C' 7.0 
and the Windows 3.1 SDK.  I don't guarantee that any other 
development environment will work.   I suspect Microsoft's
Visual C++ environment will work, but I haven't tried it.

APOLOGY TO BORLAND USERS
Borland users tell me that the Borland compiler does not
like the named segment construction that WizUnZip
uses widely, e.g.

	char __based(__segname("STRINGS_TEXT")) szString[] = 
            "String"; 

If you take out all the __based(__segname("STRINGS_TEXT"))
constructions, WizUnZip's data segment tends to be crowded
and WizUnZip runs out of stack.  Bummer.
I have no idea how Borland users can work around this.

LIST OF FILES
Those files described as "Info-ZIP" below, come from 
Info-ZIP's unzip 5.0p1 product.  They are actually a subset.
Where I have modified an Info-ZIP file to work with WizUnZip 2.0, 
I have labeled it "modified." 

Those files tagged "WizUnZip" are my and Johnny Lee's work.

The HELPICON.BMP and HELP.CUR files come from the Microsoft SDK.


NAME                            DESCRIPTION
==============		=================================
README.TXT              This file
WIZUNZIP.MK             WizUnZip MSC 7.0 makefile
WIZUNZIP.RC             WizUnZip resource file
WIZUNZIP.HPJ            WizUnZip help project file
WIZUNZIP.RTF            WizUnZip help file source in rich text format
WIZUNZIP.DEF            WizUnZip module definition file
HELPICON.BMP            Microsoft bitmap of help icon
HELP.CUR                Microsoft help cursor 
UNZIPPED.ICO            WizUnZip half-unzipped icon
WIZUNZIP.ICO            WizUnZip fully-zipped icon
WIZUNZIP.WAV            WizUnZip multi-media wave file of unzipping sound
WIZUNZIP.C              WizUnZip main file
STATUS.C                WizUnZip status window control
WINIT.C                 WizUnZip main window class initialization
REPLACE.C               WizUnZip "replace" dialog process
RENAME.C                WizUnZip "rename" dialog process
WNDPROC.C               WizUnZip main window process
ABOUT.C                 WizUnZip "about" dialog process
ACTION.C                WizUnZip interface to unzip
SIZEWNDW.C              WizUnZip resize main window logic
UPDATELB.C              WizUnZip update listbox logic
KBDPROC.C               WizUnZip keyboard proc
PATTERN.C               WizUnZip "pattern" dialog process
SELDIR.C                WizUnZip "unzip to..." subclass proc
SOUND.C                 WizUnZip "sound" dialog process
FILE_IO.C               Info-ZIP file I/O module. modified.
UNZIP.C                 Info-ZIP unzip main() module. modified.
MAPNAME.C               Info-ZIP DOS-to-UNIX name remapper. modified.
MATCH.C                 Info-ZIP pattern matching module
MISC.C                  Info-ZIP misc. module
EXPLODE.C               Info-ZIP explode method. modified.
UNREDUCE.C              Info-ZIP unreduce method
UNSHRINK.C              Info-ZIP unshrink method
EXTRACT.C               Info-ZIP extract method. modified.
INFLATE.C               Info-ZIP inflate method
HELPIDS.H               Help ID's for WizUnZip helpfile
PATTERN.H               WizUnZip include file for "pattern" dialog
RENAME.H                WizUnZip include file for "rename" dialog
REPLACE.H               WizUnZip include file for "replace" dialog
SELDIR.H                WizUnZip include file for "unzip to" dialog
SOUND.H                 WizUnZip include file for "sound" dialog
UNZIP.H                 WizUnZip Info-ZIP main include file. modified.
WIZUNZIP.H              WizUnZip main include file
ABOUT.DLG               WizUnZip "about" box template
PATTERN.DLG             WizUnZip "pattern" dialog template
RENAME.DLG              WizUnZip "rename" dialog template
REPLACE.DLG             WizUnZip "replace" dialog template
SELDIR.DLG              WizUnZip "unzip to" dialog template
SOUND.DLG               WizUnZip "sound" dialog template

THE "BIG BANG"
Once you've set up your development environment, and
de-archived the WizUnZip source, type

	nmake wizunzip.mk

You'll get a few odd compiler warnings, but shouldn't expect
any showstoppers. After the smoke clears, you'll have 

	WIZUNZIP.EXE, the WizUnZip 2.0 executable, and
	WIZUNZIP.HLP, the WizUnZip 2.0 help file.

There will be a number of .OBJ files, which you won't need
to save.  You should be able to run the executable file
and to browse the help file using WINHELP. 

WHERE TO GET UNZIP 5.0P1
You can get Info-ZIP's original UNZIP 5.0P1 from oak.oakland.edu
and other fine archive sites:

	/pub/msdos/zip/unz50p1.zip	(unzip source)
	/pub/misc/unix/unz50p1.tar-z	(unzip source)
	/pub/msdos/zip/unz50p1.exe	(unzip MSDOS exe)

DISTRIBUTION AND COPYING
Johnny Lee's and my work is public domain.  Help yourself.
Excerpts from Info-ZIP's policy appear in the Windows help file.

	Best wishes,
	Robert Heath
