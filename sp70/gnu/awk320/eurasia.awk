# accumulate the populations of Asia and Europe
# print these two totals at the end
# AKW p51

/Asia/   { pop["Asia"] += $3 }
/Europe/ { pop["Europe"] += $3 }
END      { print "Asian population is",
               pop["Asia"], "million."
           print "European population is",
               pop["Europe"], "million."
         }
