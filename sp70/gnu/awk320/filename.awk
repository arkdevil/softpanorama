# Date: 06-03-90  19:07
# From: Herb Martin
# To:   Rob Duff
# Subj: comparison:sample

FNR < 3 {
  # the output ALWAYS claims the filenames are equal AFTER the first
  # file, even though the strings printed are DIFFERENT
 
  printf("FNR %d: [%14s]-[%14s]  ", FNR, lastfile, FILENAME) ;
  if (lastfile != FILENAME) print "they are NOT equal"
  else                      print "they are equal"
  lastfile = FILENAME
}
 
FNR == 3 { print "" }
