# delimit multiple line records and print the number of fields in each

BEGIN { RS = "" }
{ print NF, length($0), "----------------";print $0 }
END { print NR }

