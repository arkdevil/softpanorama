# demonstrate set operations on an array

$1 == "IN" { if ($2 in a) print $2, a[$2]; else print $2, "is not in a"; next}
$1 == "DEL" { delete a[$2]; next }
$0 == "ALL" { for (i in a) printf("a[%s] = %s\n", i, a[i]) }
NF == 2 { a[$1] = $2 }

