# delete the opcode and comment fields of the output
# from the ASMGEN disassembler

NF < 1 || /^;/   {
    print
    next
}
$1 ~ /^;/ {
    i = 2; 
    printf ("\t%s\t", $1)
    while (i <= NF) {
        printf ("%s ", $i)
        i++
    }
    printf ("\n")
    next
}
{
    if ($0 ~ /^[ \t]/)
        i = 1
    else {
        printf ("%s", $1)
        i = 2
    }
    if (i <= NF) {
        printf ("\t%s\t", $i)
        i++
    }
    while (i <= NF) {
        if ($i ~ /;/)
            break
        printf ("%s ", $i)
        i++
    }
    printf ("\n")
}

