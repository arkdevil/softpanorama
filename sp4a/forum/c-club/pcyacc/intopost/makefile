
MMODEL  =-AS
CFLAGS  =
LFLAGS  =-Fb -Lp
OBJS    =intopost.obj

.c.obj:
          CL -c $(CFLAGS) $(MMODEL) $*.c
        
intopost.exe: $(OBJS)

          cl $(LFLAGS) $(MMODEL) $(OBJS)

intopost.c: intopost.y

          pcyacc intopost.y

