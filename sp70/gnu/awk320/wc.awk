# word count -- prints lines, words, characters

{ nf += NF; nc += length($0) + 2 }; END { print NR, nf, nc }
