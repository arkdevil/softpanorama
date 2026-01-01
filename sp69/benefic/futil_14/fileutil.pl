#! c:/bin/perl.exe
# fileutils.pl - crude nroff -> texinfo conversion
# Copyright (C) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu

# $Header: e:/gnu/fileutil/RCS/fileutil.pl 1.4.0.1 90/09/19 13:26:15 tho Exp $
#

$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_]+=)(.*)/ && shift;
			# process any FOO=bar switches

print <<'!END!OF!INTRO!';
\input texinfo					@c -*-texinfo-*-
@setfilename fileutils.info
@settitle The GNU file utilities (MS-DOS Version)

@comment Don't bother about some overfull boxes from the manpages.
@iftex
@finalout
@end iftex

@ifinfo
This file documents the MS-DOS port of the GNU file utilities.

Copyright @copyright{} 1990 Thorsten Ohl, <ohl@gnu.ai.mit.edu>

Permission is granted to make and distribute verbatim copies of
this manual provided the copyright notice and this permission notice
are preserved on all copies.

@ignore
Permission is granted to process this file through TeX and print the
results, provided the printed document carries copying permission
notice identical to this one except for the removal of this paragraph
(this paragraph not being relevant to the printed manual).

@end ignore
Permission is granted to copy and distribute modified versions of this
manual under the conditions for verbatim copying, provided also that
the section entitled ``GNU General Public License'' is included exactly as in
the original, and provided that the entire resulting derived work is
distributed under the terms of a permission notice identical to this
one.

Permission is granted to copy and distribute translations of this
manual into another language, under the above conditions for modified
versions, except that the text of the translations of the section
entitled ``GNU General Public License'' must be approved for accuracy by the
Foundation.
@end ifinfo


@comment --------------------------------------------------------------

@node Top,,,(Dir)

@menu
* Copying::		Legal matters.
* Introduction::	Generalilties.
* Installation::	How to make the GNU fileutilities.
* MS-DOS::		How the MS-DOS version differs.
* Manpages::		Short description of the commands.
* Program Index::	A guide to key material.
@end menu

@node Copying, Introduction, Top, Top
@unnumbered GNU GENERAL PUBLIC LICENSE
@center Version 1, February 1989

@display
Copyright @copyright{} 1989 Free Software Foundation, Inc.
675 Mass Ave, Cambridge, MA 02139, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.
@end display

@unnumberedsec Preamble

  The license agreements of most software companies try to keep users
at the mercy of those companies.  By contrast, our General Public
License is intended to guarantee your freedom to share and change free
software---to make sure the software is free for all its users.  The
General Public License applies to the Free Software Foundation's
software and to any other program whose authors commit to using it.
You can use it for your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Specifically, the General Public License is designed to make
sure that you have the freedom to give away or sell copies of free
software, that you receive source code or can get it if you want it,
that you can change the software or use pieces of it in new free
programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of a such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must tell them their rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  The precise terms and conditions for copying, distribution and
modification follow.

@iftex
@unnumberedsec TERMS AND CONDITIONS
@end iftex
@ifinfo
@center TERMS AND CONDITIONS
@end ifinfo

@enumerate
@item
This License Agreement applies to any program or other work which
contains a notice placed by the copyright holder saying it may be
distributed under the terms of this General Public License.  The
``Program'', below, refers to any such program or work, and a ``work based
on the Program'' means either the Program or any work containing the
Program or a portion of it, either verbatim or with modifications.  Each
licensee is addressed as ``you''.

@item
You may copy and distribute verbatim copies of the Program's source
code as you receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice and
disclaimer of warranty; keep intact all the notices that refer to this
General Public License and to the absence of any warranty; and give any
other recipients of the Program a copy of this General Public License
along with the Program.  You may charge a fee for the physical act of
transferring a copy.

@item
You may modify your copy or copies of the Program or any portion of
it, and copy and distribute such modifications under the terms of Paragraph
1 above, provided that you also do the following:

@itemize @bullet
@item
cause the modified files to carry prominent notices stating that
you changed the files and the date of any change; and

@item
cause the whole of any work that you distribute or publish, that
in whole or in part contains the Program or any part thereof, either
with or without modifications, to be licensed at no charge to all
third parties under the terms of this General Public License (except
that you may choose to grant warranty protection to some or all
third parties, at your option).

@item
If the modified program normally reads commands interactively when
run, you must cause it, when started running for such interactive use
in the simplest and most usual way, to print or display an
announcement including an appropriate copyright notice and a notice
that there is no warranty (or else, saying that you provide a
warranty) and that users may redistribute the program under these
conditions, and telling the user how to view a copy of this General
Public License.

@item
You may charge a fee for the physical act of transferring a
copy, and you may at your option offer warranty protection in
exchange for a fee.
@end itemize

Mere aggregation of another independent work with the Program (or its
derivative) on a volume of a storage or distribution medium does not bring
the other work under the scope of these terms.

@item
You may copy and distribute the Program (or a portion or derivative of
it, under Paragraph 2) in object code or executable form under the terms of
Paragraphs 1 and 2 above provided that you also do one of the following:

@itemize @bullet
@item
accompany it with the complete corresponding machine-readable
source code, which must be distributed under the terms of
Paragraphs 1 and 2 above; or,

@item
accompany it with a written offer, valid for at least three
years, to give any third party free (except for a nominal charge
for the cost of distribution) a complete machine-readable copy of the
corresponding source code, to be distributed under the terms of
Paragraphs 1 and 2 above; or,

@item
accompany it with the information you received as to where the
corresponding source code may be obtained.  (This alternative is
allowed only for noncommercial distribution and only if you
received the program in object code or executable form alone.)
@end itemize

Source code for a work means the preferred form of the work for making
modifications to it.  For an executable file, complete source code means
all the source code for all modules it contains; but, as a special
exception, it need not include source code for modules which are standard
libraries that accompany the operating system on which the executable
file runs, or for standard header files or definitions files that
accompany that operating system.

@item
You may not copy, modify, sublicense, distribute or transfer the
Program except as expressly provided under this General Public License.
Any attempt otherwise to copy, modify, sublicense, distribute or transfer
the Program is void, and will automatically terminate your rights to use
the Program under this License.  However, parties who have received
copies, or rights to use copies, from you under this General Public
License will not have their licenses terminated so long as such parties
remain in full compliance.

@item
By copying, distributing or modifying the Program (or any work based
on the Program) you indicate your acceptance of this license to do so,
and all its terms and conditions.

@item
Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the original
licensor to copy, distribute or modify the Program subject to these
terms and conditions.  You may not impose any further restrictions on the
recipients' exercise of the rights granted herein.

@item
The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of the license which applies to it and ``any
later version'', you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
the license, you may choose any version ever published by the Free Software
Foundation.

@item
If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

@iftex
@heading NO WARRANTY
@end iftex
@ifinfo
@center NO WARRANTY
@end ifinfo

@item
BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM ``AS IS'' WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

@item
IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL
ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT
LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES
SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN
ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
@end enumerate

@iftex
@heading END OF TERMS AND CONDITIONS
@end iftex
@ifinfo
@center END OF TERMS AND CONDITIONS
@end ifinfo

@page
@unnumberedsec Appendix: How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to humanity, the best way to achieve this is to make it
free software which everyone can redistribute and change under these
terms.

  To do so, attach the following notices to the program.  It is safest to
attach them to the start of each source file to most effectively convey
the exclusion of warranty; and each file should have at least the
``copyright'' line and a pointer to where the full notice is found.

@smallexample
@var{one line to give the program's name and a brief idea of what it does.}
Copyright (C) 19@var{yy}  @var{name of author}

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
@end smallexample

Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this
when it starts in an interactive mode:

@smallexample
Gnomovision version 69, Copyright (C) 19@var{yy} @var{name of author}
Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.
@end smallexample

The hypothetical commands `show w' and `show c' should show the
appropriate parts of the General Public License.  Of course, the
commands you use may be called something other than `show w' and `show
c'; they could even be mouse-clicks or menu items---whatever suits your
program.

You should also get your employer (if you work as a programmer) or your
school, if any, to sign a ``copyright disclaimer'' for the program, if
necessary.  Here a sample; alter the names:

@example
Yoyodyne, Inc., hereby disclaims all copyright interest in the
program `Gnomovision' (a program to direct compilers to make passes
at assemblers) written by James Hacker.

@var{signature of Ty Coon}, 1 April 1989
Ty Coon, President of Vice
@end example

That's all there is to it!


@comment --------------------------------------------------------------

@node Introduction, Installation, Copying, Top
@chapter General introduction to the GNU file utilities

Please send bug reports
(preferably with fixes (@strong{context} @code{diff}'s!) to

@display
      Thorsten Ohl
      <ohl@gnu.ai.mit.edu>
@end display

I can make no promises to fix it immediately, but I might want to!


@comment --------------------------------------------------------------

@node Installation, MS-DOS, Introduction, Top
@chapter How to install the @code{GNUish MS-DOS} file utilities

@enumerate
@item
Edit the following variables in the makefile

@table @code

@item CFLAGS, LDFLAGS
These are for the Microsoft C compiler Version 6.0, edit them for your
system:

@table @code
@item -AS
Small memory model

@item -W4
Full warnings!

@item -Ox
Optimization.

@item -Za
@item -DSTDC_HEADERS
ANSI C.

@item -DUSG
Microsoft's C looks more like System V than BSD.

@item -DVPRINTF
The runtime library has @code{vprintf()}.

@item -DUTIMES_MISSING
The runtime library misses @code{utimes()}.

@item -DFCHMOD_MISSING
The runtime library misses @code{fchmod()}.

@item -DINT_16_BITS
32-bit @code{MS-DOS}?

@item -DBLKSIZE=0x4000
Use large blocksizes for @emph{fast} copying.

@item -DSMART_SHELL
Recognize the @code{GNUish MS-DOS} argument passing convention.

@item /e
Pack the executable.

@item /st:0x8000
Large stack.

@item /noe
If duplicate symbols in object files and libraries, use the one from the
object file.
@end table
@end table

@item
Say @code{make}.
@end enumerate

That's all.


@comment --------------------------------------------------------------

@node MS-DOS, Manpages, Installation, Top
@chapter How the @code{MS-DOS} version differs

All programs have additional options @samp{+version} and @samp{+copying}
for echoing the revision and a short copyleft notice respectively to
@file{stderr}.  This is mainly useful for identifying executables if
you do not yet have the sources.

@section Individual programs

@itemize
@item
@pindex cp
@pindex mv
GNU @code{cp} and @code{mv} can generate backup files with GNU
@code{emacs} style numbered backup suffixes (i.e. @file{foo.c} becomes
@file{foo.c.~1~}). Of course this is almost always impossible under
@code{MS-DOS}.  We have changed this convention to strip a part of the
original filename. The following examples should make the principle
clear:
@example
@file{foo} goes to @file{foo.~1~}
@file{foo.c} goes to @file{foo.c~1}
@file{foo.tex} goes to @file{foo.t~1}
@end example
This is not entirely foolproof (cf. @file{foo.txt} and @file{foo.tex}), and
is furthermore restructed to at most 9 generations of backup files.  But
here @code{MS-DOS}' limits are too restrictive to provide more.

@item
@pindex cp
GNU @code{cp} remembers all files it copies. This is primarily intended
for avoiding duplicate copying of linked files, but has the nice side
effect that by
@example
cp *.c foo.*
@end example
the file @file{foo.c} (if it exists) will not be copied twice.

Since @code{MS-DOS} has no inodes, this hashing doesn't work and has been
disabled. Future versions might provide either of the following:
@itemize
@item
Hashing based on filenames (no links!)

@item
An improved @file{ndir} library, which uses the starting cluster of a
file as an inode number.

@display
Suggestions for fast and @strong{portable} access to the @code{MS-DOS}
directory are very much appreciated.
@end display

@end itemize

@item
@pindex cat
@pindex head
@pindex tail
@code{cat}, @code{head} and @code{tail} have the new option:
@table @code
@item -B, +binary
Process the inputfiles and stdout in binary mode.  The has the effect of
switching of the @key{LF} @key{CR}@key{LF} conversions and allows reading
past a @ctrl{^Z}.
@end table

@item
@pindex dd
@code{dd} has the follwing new options:
@table @code
@item im=@{text,binary@}
Process the inputfile in binary mode.

@item om=@{text,binary@}
Process the outputfile in binary mode.
@end table


@item
@pindex ln
@pindex cp
There is no @code{ln}, since we can't link files under @code{MS-DOS}.
If one @emph{needs} to, one can use @code{cp}.  But this wastes disk
space, of course.

@item
@pindex mkfifo
There is no @code{mkfifo}, again for obvious reasons.

@item
@pindex install
There is no @code{install}.  I have no burning need for one, but for
completeness' sake, there might be one in the future.

@item
@pindex du
There is also no @code{du}.  This one I really miss, but it might be hard
to gather the information under @code{MS-DOS} - without going into too much
device dependent details.
@end itemize


@comment --------------------------------------------------------------

@node Manpages, Program Index, MS-DOS, Top
@chapter Manpages

These "manpages" have been translated automatically by a @code{perl}
script from the @code{nroff} sources, as supplied with the GNU distribution.

Thus they apply to the GNU version of these programs.  For @code{MS-DOS}
specific changes, additions, and omissions, @pxref{MS-DOS}


!END!OF!INTRO!

# O.k. now perl's work starts.

# This array will be used to determine the `next' fiels of a node.
@commands = ();

# Use all section 1 manpages in the `man' subdirectory.
@manpages = split (/[ \t\n]+/,<$MANDIR/*.1>);

# First pass: generate the menu.
print '@menu';

file: while ($manfile = shift @manpages)
  {
    chop;
    open (cur_file, $manfile) || die "can't open  $manfile.";

    while (<cur_file>)
      {
	# Take the menu entry from the `NAME' section.

	if (/^\.SH[ \t]+NAME/)
	  {
	    # Get the next line.
	    $_ = <cur_file>;
	    &preprocess;

	    ($name, $desc) = split ('[ \t]*-[ \t]*', $_, 2);
	    $name =~ s/[ \t]*,[ \t]*/ - /g;

	    # Print out a menu entry
	    printf "* %-22s%s\n", $name . "::", $desc;

	    # Save the name
	    push (@commands, $name);

	    next file;
	  }
      }

    die "Command has no name: $manfile.";	# oops...
  }

print '@end menu';

# Second pass: process the complete manpages.
shift (@commands);
$last = "";

# No open tables, etc. yet.
@pending = ();

@manpages = split (/[ \t\n]+/,<$MANDIR/*.1>);

file: while ($manfile = shift @manpages)
  {
    chop;
    open (cur_file, $manfile) || die "can't open  $manfile";

    # Close all open tables.
    &pop_pending;

  line: while (<cur_file>)
      {
	&preprocess;

	if (/^\./)
	  {
	    # We have found a command, interpret it.

	    ($cmd, $arg) = split (/[ \t]+/, $_, 2);

	    if ($cmd eq '.TH')
	      {
		# ignore the header section.

		next line;
	      }
	    elsif ($cmd eq '.SH')
	      {
		# A new section starts here

		# Close all open tables.
		&pop_pending;

		if ($arg eq 'NAME')
		  {
		    # The name section gives us the information
		    # for the @node.

		    $_ = <cur_file>;
		    &preprocess;

		    ($name, $desc) = split ('[ \t]*-[ \t]*', $_, 2);
		    $name =~ s/[ \t]*,[ \t]*/ - /g;

		    print '';
		    print '';
		    printf "@node %s, %s, %s, Manpages\n",
			   $name, shift (@commands), $last;
		    print '@section ' . $name;
		    print '@pindex ' . $name;
		    print '';
		    print '@unnumberedsubsec NAME';
		    print '@display';
		    print $_;
		    print '@end display';
		    print '';

		    # Remember the name for the `last' field 
		    # of the next node
		    $last = $name;

		    next line;
		  }
		elsif ($arg eq 'SYNOPSIS')
		  {
		    # `display' the `SYNOPSIS'

		    print '';
		    print '@unnumberedsubsec SYNOPSIS';
		    print '@display';

		    push (@pending, '@end display');
		  }
		elsif ($arg eq 'DESCRIPTION')
		  {
		    print '';
		    print '@unnumberedsubsec DESCRIPTION';
		    print '';
		  }
		else
		  {
		    die "unknown section: $_.";
		  }
	      }
	    elsif ($cmd eq '.SS')
	      {
		&pop_pending;

		if ($arg eq 'OPTIONS')
		  {
		    print '';
		    print '@unnumberedsubsec OPTIONS';
		    print '';
		  }
		else
		  {
		    die "unknown section: $_.";
		  }
	      }
	    elsif ($cmd eq '.TP')
	      {
		# This is usually for a table entry.

		print '';

		if (! $intable)
		  {
		    # We're not yet in a @table, open it.

		    $intable = 1;
		    print '@table @code';
		    push (@pending, "@end table");
		  }

		# Get rid of the next lines' formatting commands.
		$_ = <cur_file>;
		&preprocess;

		if (/^\.[BI]R?/)
		  {
		    ($junk, $_) = split ('[ \t]+', $_, 2);
		  }

		 print '@item ' . $_;
	      }
	    elsif ($cmd eq '.PP')
	      {
		# New paragraph

		print '';
	      }
	    elsif ($cmd eq '.br')
	      {
		# Break the line

		print '';
	      }
	    elsif ($cmd eq '.RS')
	      {
		# This should start another level of `@table'

		print '@table @asis';
	      }
	    elsif ($cmd eq '.RE')
	      {
		# This should end another level of `@table'

		print '@end table';
	      }
	    elsif ($cmd eq '.B')
	      {
		# Assume that boldface is like `@code'

		printf "@code{%s} ", $arg;
	      }
	    elsif ($cmd eq '.BR')
	      {
		printf "@code{%s}%s ", split (/[ \t]+/, $arg, 2);
	      }
	    elsif ($cmd eq '.I')
	      {
		# Assume that italics are like `@samp'

		printf "@samp{%s} ", $arg;
	      }
	    elsif ($cmd eq '.IR')
	      {
		printf "@samp{%s}%s ", split (/[ \t]+/, $arg, 2);
	      }
	    else
	      {
		die "unknown command: $_.";
	      }
	  }
	else
	  {
	    # Plain line, print it.

	    print;
	  }
      }
  }

# Close all pending `@table's.
&pop_pending;

print '

@comment --------------------------------------------------------------

@node Program Index, , Manpages, Top
@appendix Program Index

@printindex pg

@contents
@bye
';

# Trivial subroutines:

# handle special characters.
sub preprocess
{
  chop;
  s/\\-/-/g;
  s/@/@@/g;
  s/{/@{/g;
  s/}/@}/g;
}

# Close all pending `@table's.
sub pop_pending
{
  while ($tmp = pop (@pending))
    {
      print $tmp;
    }
  $intable = 0;
}

#
# Local Variables:
# mode:texinfo
# ChangeLog:ChangeLog
# compile-command:make
# End:

