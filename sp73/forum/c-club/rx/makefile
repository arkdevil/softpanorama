# If working with TC2.0: I was often in trouble with
# register optimization (-r), so I don't use it anymore

CC=tcc
CFLAGS=-ml -r-

# Uncomment the next CC-/CFLAGS-lines if working with MSC
# packing structures (-Zp) is necessary!
# Note: I tried it, but I haven't fully tested it with MSC (it so slow...)

# CC=cl
# CFLAGS=-AL -Zp

rx.exe : rx.c
  $(CC) $(CFLAGS) rx.c

# that's it