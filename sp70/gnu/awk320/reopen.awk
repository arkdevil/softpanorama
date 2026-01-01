# Date:  04-12-89  11:24
# From:  Jeff Clough
# To:    Rob Duff
# Subj:  Bug (I think) in AWK 2.12

#      The AWK documentation implied that I could write to a file and then use 
# that same file for input provided that I closed the file first. When I tried 
# to do this, I found that the file was erase as it was opened the second time 
# (for input). 

BEGIN {
    print "This is not a test, this is ROCK AND ROLL." > "reopen.dat"
    close ("reopen.dat");
    getline < "reopen.dat"
    print
}
