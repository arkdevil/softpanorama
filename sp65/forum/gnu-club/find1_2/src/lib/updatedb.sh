#!/bin/sh
# updatedb -- build fast-find pathname database
# csh original by James Woods; sh conversion by David MacKenzie.
# Public domain.

# Non-network directories to put in the database.
SEARCHPATHS="/"

# Network directories to put in the database.
NFSPATHS=

# Entries that match this regular expression are omitted.
PRUNEREGEX='\(^/tmp$\)\|\(^/usr/tmp$\)\|\(^/var/tmp$\)'

# The directory containing the subprograms.
LIBDIR=XLIBDIR

# The directory containing find.
BINDIR=XBINDIR

# The database file.
FCODES=XFCODES

# User(s) to mail error messages about 'sort' overflows to.
FINDHONCHO="root"

# User to search network directories as.
NFSUSER=daemon

# Directory to hold intermediate files.
TMPDIR=/usr/tmp

PATH=$LIBDIR:$BINDIR:/usr/ucb:/bin:/usr/bin export PATH
bigrams=$TMPDIR/f.bigrams$$
filelist=$TMPDIR/f.list$$
errs=$TMPDIR/f.errs$$
trap 'rm -f $bigrams $filelist $errs' 0
trap 'rm -f $bigrams $filelist $errs; exit' 1 15

# Make a file list.  Alphabetize '/' before any other char with 'tr'.

{
if [ -n "$SEARCHPATHS" ]; then
  find $SEARCHPATHS \
  \( -fstype nfs -o -type d -regex "$PRUNEREGEX" \) -prune -o -print
fi
if [ -n "$NFSPATHS" ]; then
  su $NFSUSER -c \
  "find $NFSPATHS \\( -type d -regex \"$PRUNEREGEX\" -prune \\) -o -print"
fi
} | tr '/' '\001' | sort -f 2> $errs | tr '\001' '/' > $filelist

# Compute common bigrams.

bigram < $filelist | sort 2>> $errs | uniq -c | sort -nr |
  awk '{ if (NR <= 128) print $2 }' | tr -d '\012' > $bigrams

# Code the file list.

if test -s $errs; then
  echo 'updatedb: out of sort space' | mail $FINDHONCHO
else
  code $bigrams < $filelist > $FCODES
  chmod 644 $FCODES
fi
