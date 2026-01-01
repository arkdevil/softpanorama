
#     ABRAXAS SOFTWARE, PCLEX example "date" makefile


mdate.exe:      mdate.obj ydate.obj ldate.obj

                cl mdate ydate ldate

ydate.c:        ydate.y

                pcyacc -D ydate.y

ldate.c:        ldate.l ydate.h

                pclex -t ldate.l > ldate.c

.c.obj:
                cl -c $*.c
