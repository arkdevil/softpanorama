# generate text archive

BEGIN {
    arcfile = ARGV[1]
    delete ARGV[1]
}
FILENAME != filename {
    print ("-ARCHIVE-", FILENAME) >arcfile
    print filename = FILENAME
}
{
    print >arcfile
}

