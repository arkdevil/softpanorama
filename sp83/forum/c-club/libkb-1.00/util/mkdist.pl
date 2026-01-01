#!/usr/bin/perl
##
## vi:ts=4
##
##---------------------------------------------------------------------------##
##  Author:
##      Markus F.X.J. Oberhumer         markus.oberhumer@jk.uni-linz.ac.at
##  Copyright:
##      Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer
##      For conditions of distribution and use, see copyright notice in kb.h 
##  Description:
##      Select files for tar/zip distribution
##---------------------------------------------------------------------------##

@Files = (
	'bin/*dos.exe',
	'bin/*lnx.out',
	'bin/*nt.exe',
	'bin/*os2.exe',
	'bin/cwsdpmi*',
###	'jump/*',
	'desc.sdi',
	'cha*log',
	'copying*',
	'file_id.diz',
	'makefile*',
	'readme*',
	'*.bat',
	'*.btm',
	'*.c',
	'*.doc',
	'*.h',
	'*.hh',
	'*.in',
	'*.lsm',
	'*.mk',
	'*.mod',
	'*.pl',
);

# config
$dirsep  = $ENV{'COMSPEC'} ? '\\' : '/';		# directory separator

# get dirname
$dirname = shift;			
$dirname .= $dirsep if $dirname;	# add trailing '/'

# make a Perl regexp
$Files = '(^|[\\\/])((' . join(')|(', @Files) . '))$';
$Files =~ s/\./\\\./g;				# quote all '.'
$Files =~ s/\*/\.\*/g;				# change all '*' to '.*'


#
# process files or stdin
#

@f = ();

$i = 0;
while (<>) {
	chop;
	next if /^\s*$/;				# skip empty lines
	next if /^\s*\#/;				# skip comment lines

	next if /^\.{1,2}$/;			# skip '.' and '..'

	s/\\/\//g;

	## s/^(\.\.\/)+//;				# remove leading '../'
	s/^(\.\/)+//;					# remove leading './'

	next unless (/$Files/io);		# ignore case in filename matching

	push(@f,${dirname} . $_); 
	$i++;
}

# print info message
print STDERR "$0: $i files\n";


#
# sort
#

sub ext_cmp {
	local ($aa, $bb);

	#        |dir| |file  | |  ext?  | | ext  |
	$a =~ m%^(.*/)?([^./]+)?([^./]*\.)*([^./]*)$%;
	$aa = $4 . '.' . $2 . '.' . $1;
	$aa =~ tr/A-Z/a-z/;
	$b =~ m%^(.*/)?([^./]+)?([^./]*\.)*([^./]*)$%;
	$bb = $4 . '.' . $2 . '.' . $1;
	$bb =~ tr/A-Z/a-z/;
	## print STDERR "$a='$aa'   $b='$bb'\n";

	$aa cmp $bb;
}

# sort by extension
## @f = sort(ext_cmp @f);

# sort by name
## @f = sort(@f);


#
# print
#

for (@f) {
	s/\//$dirsep/g;
	print "$_\n";
}

exit(0);
