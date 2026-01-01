# extract files from a text archive

$1=="-ARCHIVE-" {
    if (file)
        close(file)
    file = $2
    print file
    next
}
{
    print > file
}
