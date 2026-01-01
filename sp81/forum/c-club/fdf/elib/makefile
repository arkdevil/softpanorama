CC = bcc
CFLAGS = -O -ml
HDRS = elib.h
OBJS = askuser.obj delete.obj dirs.obj fdates.obj ftimes.obj getopt.obj \
       hashpjw.obj input.obj marks.obj
SRCS = askuser.c delete.c dirs.c fdates.c ftimes.c getopt.c \
       hashpjw.c input.c marks.c
TLIB = tlib

.c.obj:
	$(CC) $(CFLAGS) -c $<

all:	elib.lib

elib.lib: $(OBJS) $(HDRS)
  $(TLIB) elib.lib @&&|
+askuser.obj \
+delete.obj \
+dirs.obj \
+fdates.obj \
+ftimes.obj \
+getopt.obj \
+hashpjw.obj \
+input.obj \
+marks.obj
|

