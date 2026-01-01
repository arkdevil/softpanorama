# verify that a record follows a pattern

NF==1{ if ( $1 ~ /^ab(ab|ba)*abba$/ ) print "yes" ; else print "no" }
