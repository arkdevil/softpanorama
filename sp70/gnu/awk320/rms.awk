# A program to compute the square root of the
# sum of the squares of a set of numbers.
# The set of numbers is provided as input -
# one number to a record.
#
# NR is the current record number.  In the END
# section it is the number of records.

BEGIN {
        sum_of_squares = 0
}
{
        sum_of_squares += $1 * $1
}
END {
        root_mean_square = sqrt(sum_of_squares / NR)
        print root_mean_square
}
