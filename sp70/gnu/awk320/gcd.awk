# calculate the Greatest common divisor of each pair of inputs

{
        arg1 =$1; arg2 = $2;
        while (arg1 != arg2) {
                if (arg1 > arg2)
                        arg1 -= arg2
                else
                        arg2 -= arg1
        }
        print "The greatest common divisor of", $1, "and", $2, "is", arg1
}
