# print all the command line arguments of the program

BEGIN { for (i in ARGV) print i, ARGV[i] }
