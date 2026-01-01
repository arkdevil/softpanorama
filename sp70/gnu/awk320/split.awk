# split a string into separate fields in an array

BEGIN {
        xsplit("i j k", a); for (i in a) print i, a[i]
        xsplit("x y z", a); for (i in a) print i, a[i]
}
function xsplit(x, y) { split(x, y) }
