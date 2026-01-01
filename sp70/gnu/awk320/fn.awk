# print each line with the record number
# the record number within the file
# and the filename
# separate each file with a blank line

FILENAME != prev {
    printf "\n\n"
    prev = FILENAME
}
{
    print NR, FNR, FILENAME, substr($0, 1, 60)
}

