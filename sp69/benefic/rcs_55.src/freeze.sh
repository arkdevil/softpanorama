# freeze - assign a symbolic revision number to a configuration of RCS files

#       The idea is to run freeze each time a new version is checked
#       in. A unique symbolic revision name is then assigned to the most
#       recent revision of each RCS file of the main trunk.
#
#       A log message is requested from the user which is saved for future
#       references.
#
#       The shell script works only on all RCS files at one time.
#       It is important that all changed files are checked in (there are
#       no precautions against any error in this respect).

# Check whether we have an RCS subdirectory, so we can have the right
# prefix for our paths.

test -d RCS
if ($status == 0) then
	set RCSDIR=RCS
else
	set RCSDIR=.
endif

# Version number stuff, log message file
set VERSIONFILE=$RCSDIR/freeze.ver
set LOGFILE=$RCSDIR/freeze.log

# Initialize, if freeze never run before in the current directory

test -r $VERSIONFILE
if ($status '!=' 0) then
	echo 0 > $VERSIONFILE
	echo >> $LOGFILE
endif


# Get Version number, increase it, write back to file.
cp $VERSIONFILE ./frztemp
set VER=$`frztemp`
@ VER = $VER + 1
echo $VER > $VERSIONFILE

# Symbolic Revision Number
set SYMREVNAME=$1

# Allow the user to give a meaningful symbolic name to the revision.

if (strcmp(,$1) == 0) then
	echo "Error: Symbolic name needed for configuration"
	echo
	echo "Usage: freeze name"
	echo
	echo "Freezes the current configuration by applying the symbol name"
	echo "to the latest revision on each file"
	echo
	exit 1
endif

# Stamp the logfile. Because we order the logfile the most recent
# first we will have to save everything right now in a temporary file.

set TMPLOG=frzxxxxx

echo $SYMREVNAME : $d $t > $TMPLOG

# Now ask for a log message, continously add to the log file

set STOP = 0

	echo Version: $SYMREVNAME
    echo "--------" 
	echo "enter description for configuration, terminated with a single '.'"
	while ($STOP '!=' 1)
		echo -n ">> "
		read MESS 
		switch ($MESS)
			case .:
				set STOP=1
				echo >> $TMPLOG
				break;
			default:
				echo $SYMREVNAME : $MESS >> $TMPLOG
		endsw
 	end

# combine old and new logfiles
cat $TMPLOG $LOGFILE >frztemp
rm -f $TMPLOG $LOGFILE; mv frztemp $LOGFILE

# make the log and version files hidden while we process the RCS files

chmod +h $VERSIONFILE $LOGFILE

# Now the real work begins by assigning a symbolic revision number
# to each rcs file. Take the most recent version of the main trunk.

foreach FILE in ($RCSDIR/*.*)
#   get the revision number of the most recent revision
	rlog -h $FILE | sed -n "s/^head:[ \t]*//p" > frztemp
	set REV=$`frztemp`

#	assign symbolic name to it
	echo freeze: $REV $FILE
	rcs -q -n$SYMREVNAME\:$REV $FILE
end

# tidy up; delete scratch files and make log and version files visible

rm frztemp
chmod -h $LOGFILE $VERSIONFILE
exit 0
