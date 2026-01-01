# generate cross reference of identifiers in a program

#   Original program courtesy Bruce Feist of Arlington VA

{ 
# remove non alphanumeric characters
    gsub (/[`~!@#%\^&\*\(\)\+\|\-=\\\[\]{};':\",\./\<\>\?\/]/, " ")
# convert to upper case
    $0 = toupper($0)
# add reference
    for (i = 1; i <= NF; i++)
    {
        if ($i !~ /^[0-9]+$/ && done[$i] != NR)  # check if number or done
        {
            done[$i] = NR               # mark as done
            xref[$i] = xref[$i] " " NR  # add reference
        }
    }
}

END {
    for (i in xref)
        print i ": ", xref[i]
}



