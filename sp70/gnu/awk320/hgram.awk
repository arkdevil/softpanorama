# histogram
#   input:  numbers between 0 and 99
#   output: histogram for the deciles

# AKW p70

{
    x[int($1/10)]++
}

END {
    for (i = 0; i < 10; i++)
        printf(" %2d - %2d: %3d %s\n",
            10*i, 10*i+9, x[i], rep(x[i], "*"))
}

function rep(n, s,  t) {  # return string of n s's
    while (n-- > 0)
        t = t s
    return t
}
