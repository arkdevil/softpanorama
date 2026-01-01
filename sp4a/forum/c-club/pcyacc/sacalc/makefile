
MMODEL  =
CFLAGS  =-AS
LFLAGS  =-Fb -Lp
OBJS    =sacalc.obj

.c.obj:
	cl -c $(CFLAGS) $(MMODEL) $*.c

sacalc.exe: $(OBJS)
            cl $(LFLAGS) $(MMODEL) $(OBJS)

sacalc.c: sacalc.y
          pcyacc sacalc.y

