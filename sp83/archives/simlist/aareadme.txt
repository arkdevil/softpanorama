From: cctarch@SimTel.Coast.NET (Coast to Coast Archivist)
Subject: How to find files in the Coast to Coast (CCT) collections (960605)

[File: /SimTel/msdos/filedocs/aareadme.txt  Last revised: June 5, 1996]

Lists of all MS-DOS files available from the Coast to Coast
Software Repository (tm), and utilities to display, search, or print
them are contained in directory /SimTel/msdos/filedocs as follows:

simindex.zip contains SIMIBM.IDX, a comma-delimited listing of all files
     in the MSDOS subdirectories with a brief one line description for
     each file, which is suitable for importing into a database program.
     This file is updated at approximate 10 day intervals.

simlist.zip contains SIMIBM.LST, the latest SIMIBM.IDX in text format
     for those who would rather not deal with the comma-delimited index.
     The format of this file is the same as that produced by the SIMCVT
     programs.

These programs can be used to display and search the index:

simdir22.zip displays the file SIMIBM.IDX.  You can browse through the
     list by moving a highlight bar and by pressing function keys.
     The file is displayed as a two-level hierarchy.  The upper
     (initial) level consists of a list of directories, and the lower
     level consists of a list of files within a single directory.  At
     the lower level, you can move directly to the next or previous
     directory by pressing a single key, and you can search across
     directory for strings of text.  At either level, you can exclude
     all files that were uploaded before a specified date.  It will
     optionally create an output file of selected file names, suitable
     for use with the BSD Unix batchftp or autoftp programs which are
     available in OAK.Oakland.Edu's /pub/misc/unix directory.

msrch10a.zip performs fast searches of SIMIBM.IDX comma delimited file
     for user-specified text; the search takes only about 3 secs to
     search the entire file.  Output of all matches are written to
     screen one page at a time or continuously.  The program runs in
     interactive mode or via command line parameters.

simlst1.zip is a menu-driven program which allows the user to search
     for a file or application by the file name, directory, or do a
     pattern match on the description.  It takes the SIMIBM.IDX file
     as its input and can be updated with the monthly update files.

simsrch2.c facilitates searching through the SIMIBM.IDX file.  It
     supports keyword searches within selectable fields, starting and
     ending date boundaries, and user specified index files.  This program
     will compile and run under Turbo-C 2.0, UNIX ANSI C, and VAX/VMS C. 

simsch14.zip is a utility for Windows 3.x to scan/select entries from
     CCT's SIMIBM.IDX index file.

simvw25.zip and simvwdll.zip is a Windows 3.x utility to search, browse,
     and view SIMIBM.IDX.

wsim21.zip is a Windows 3.x program that can convert SIMIBM.IDX to a
     dBase III .DBF file.  It then uses this file to do searches on
     filename, directory or description.  All searches are substring
     searches and are not case sensitive.

Also available:

cnvsim10.zip is a program which will convert the SIMIBM.IDX file to a
     Paradox table.

idx2dat2.zip is C source for a simple program to convert a file in the
     format of SIMIBM.IDX into a data file compatible with the UNIX
     autoftp or batchftp programs (which do background ftp downloads). 
     The normal usage is to filter simibm.idx to extract just the lines
     of the programs you want to download.

simcvt.bas and simcvt2.bas are BASICA/GWBASIC/QBASIC programs to convert
     SIMIBM.IDX to a human-readable text file.

simcvt.c is a Unix C program to print SIMIBM.IDX.

simcvt2.awk is an Awk script which converts CCT .IDX index files
     to .LST list files.

simcvt2.c is a Unix C program to search and print SIMIBM.IDX.

simcvt.exc is a VM/CMS REXX program to print SIMIBM.IDX.

simcvax.bas is a VAX/VMS BASIC V3.3 program to print SIMIBM.IDX.

simcvt.for is VAX/VMS FORTRAN program to print SIMIBM.IDX.

simcvt.sps is VAX/VMS SPS program to print SIMIBM.IDX.

simcvt3.zip is a SIMIBM.IDX conversion utility for Turbo C

simdisp.awk is an Awk script for displaying SIMIBM.IDX in outline form.

simdisp.doc explains how to use simdisp.awk.

simdisp.pl is a Perl script to print CCT's SIMIBM.IDX.

simflt10.zip extracts dirs from SIMIBM.IDX, writes to new file.

simgrep2.prl is a Perl script to search SIMIBM.LST and display the
     selected files with directory and date.

simgrep2.prl is a Perl script to perform regular expression searching on
     the SIMIBM.LST file.  The search is case-insensitive.  Matching
     entries are printed along with the directory in which they occur.

simgrep2.sh is a Unix shell script to search and display SIMIBM.LST.

simibm.db3 tells how to use SIMIBM.IDX with dBASEIII.

simibm.hdr is a PC-File+ database header for use with SIMIBM.IDX.

simibm.inf contains information on record structure of SIMIBM.IDX.

simraz12.zip is a program to merge, shorten, rearrange CCT indices.

idx2dat.c is a program to make autoftp/batchftp scripts from SIMIBM.IDX.

simail50.zip reads the output file of the SIMDIR22 program and translates
     it to multiple output files suitable for mailing to LISTSERV or
     TRICKLE file servers.

fildif.zip is a program for comparing a previous copy of
     /SimTel/msdos/FILES.IDX with a new copy.  It displays files added
     and deleted since you got an older index.  This is useful if you
     are trying to maintain an archive in sync with CCT.  It can
     generate output scripts for batch FTP
     processing.

/SimTel/msdos/FILES.IDX is a comma-delimited file, without descriptions,
     of the msdos directories, suitable for importing into PC-File+ or
     DBase III.  This file is updated on a daily basis (sometimes several
     times a day when a lot of new files are uploaded).  It is used by
     the mirror and TRICKLE sites.

It's impossible to make a daily updated list with descriptions with the
quantity of new programs available.  We average about 360 new files per
month.

             Mirror Sites That Offer Coast to Coast Files

See file /SimTel/msdos/filedocs/download.inf for the latest list of
mirror sites.

         Where To Send Complaints, Problems, Questions

Messages about files in the MS-DOS collection should be directed to
cctarch@SimTel.Coast.NET.

Messages about the mirror sites should be sent the administrator of
the mirror site.

Messages about the BITNET or EARN file servers should be directed to
the system administrator at the server location.

                          Internet                     BITNET

        "John Fisher" <FISHER@VM.ECS.RPI.EDU>      <FISHER@RPIECS>
"TRICKLE Maintainers" <RED-BUG@VM3090.EGE.EDU.TR>  <RED-BUG@TREARN>

Coast to Coast does NOT run these servers.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~ Jenifer L. Burke, Archivist  E-mail: cctarch@simtel.coast.net       ~
~ Manager: Coast to Coast Software Repository (tm)                    ~
~ http://www.coast.net OR ftp://ftp.coast.net  login: anonymous       ~ 
~ 								      ~ 
~ 	"640K ought to be enough for anybody." 			      ~
~				--  Bill Gates, 1981	              ~
~								      ~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


