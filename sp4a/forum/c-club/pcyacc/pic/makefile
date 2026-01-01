

OBJS=main.obj parse.obj scan.obj yysub.obj draw.obj

.c.obj:
         cl /c $*.c

pic.exe: $(OBJS)
         link $(OBJS),pic,,graphics

parse.c: parse.y
         pcyacc -Dpic.h parse.y

