# dir - list directory with date interpretation
#
# date interpretation  COUNTRY=44

BEGIN {
    split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month, " ");
}
NF == 5 {
    if (date(4))
        $0 = sprintf("%-9s%-3s%9s%11s%8s", $1,$2,$3,f4=$4,$5)
}
NF == 4 {
    date(3)
    if ($2 ~ /<DIR>/)
        $0 = sprintf("%-9s%9s%14s%8s", $1,$2,$3,$4)
    else
        $0 = sprintf("%-9s%12s%11s%8s", $1,$2,$3,$4)
}
{ print }
function date(i) {
    if ($i ~ /[0-9]+-[0-9]+-[0-9]+/) {
        n = split($i, mdy, "-")
        mdy[1] = month[int(mdy[1])]
        $i = sprintf("%2d-%3s-%02d", mdy[2], mdy[1], mdy[3])
        return 1
    }
    return 0
}

