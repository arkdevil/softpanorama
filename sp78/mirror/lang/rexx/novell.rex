From: elbaz@clark.net (Bernard H. Basel, Jr.)
Newsgroups: comp.lang.rexx
Subject: OS/2 Rexx & Novell Netware
Date: 12 Oct 1995 18:26:29 GMT

I am having an interesting problem with a rexx script with Novell Netware
3.12.What I am trying to do is read in lines from a text file, and everything
exceptfor a specified line will be outputted to temporary file.  When I find
the lineI want, I output a modified line to the temp file.  I then close both
files,delete the input file, and rename the temporary file to the name of the
inputfile.  My problem is that when I try to rename the temporary file, I am
sometimestold that the file is in use by another process.

Here is the section of code I am having problems with.

***********

outfile = "y:\settings.txt"
temp_file = "y:\temp.txt"

rc = stream(temp_file,'c','close')         /* Close file */
rc = stream(outfile,'c','close')           /* Close file */
del outfile
ren temp_file 'settings.txt'

call SysFileTree outfile , 'there' , 'F'
if there.0 then
        'attrib +r' outfile
else do
        CLS
        Say
        Say
        Say "Change did not run successfully, call the help desk."
        pause
        end  /* Do */

*************

As you can see I am using the standard OS/2 DELETE and RENAME commands.
This is what I have observed and tried so far.  The failure is not completely
random.  when it doesfail, it will continue to fail for several minutes, this
and the fact that I never hadthis problem when I was running the script on a
dedicated test server leads me to believethat it is some sort of server
issue.  I tried putting up to a 30 second wait betweenwhen I closed the files
and when I tried to delete and rename the files, with no affect.I tried
renaming to a filename other then the input file with no luck.

Any suggestions would be appreciated


------------------------------------------------

Bernie Basel - OS/2 Empowered! - elbaz@clark.net

------------------------------------------------


