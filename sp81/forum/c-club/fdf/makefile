CC = bccx
CFLAGS = -O -ml
HDRS = cmp.h fdf.h fdfcomm.h fdfstat.h elib.h sfdf.h
OBJS = cmp.obj fdf.obj fdfcomm.obj fdfstat.obj
SFDF_OBJS = cmp.obj fdfcomm.obj fdfstat.obj sfdf.obj
SRCS = cmp.c sfdf.c fdf.c fdfcomm.c

.c.obj:
	$(CC) $(CFLAGS) -c $<

all:	fdf.exe sfdf.exe

cmp.obj:	cmp.h

fdf.obj:	fdfcomm.h fdfstat.h fdf.h

fdfcomm.obj:	cmp.h fdfcomm.h elib.h

fdfstat.obj:	fdfcomm.h fdfstat.h

sfdf.obj:	fdfcomm.h fdfstat.h elib.h sfdf.h

fdf.exe:	$(OBJS)
	$(CC) $(CFLAGS) -e$* $(OBJS) ..\elib\elib.lib

sfdf.exe:	$(SFDF_OBJS)
	$(CC) $(CFLAGS) -e$* $(SFDF_OBJS) ..\elib\elib.lib
