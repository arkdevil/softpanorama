
#       ABRAXAS SOFTWARE

#       WC, WORD COUNT  

#       wc < wc.l ; returns information on file.


WC.EXE: WC.OBJ
        cl wc

wc.obj: wc.c
        cl -c wc.c

wc.c:   wc.l
        pclex -t wc.l > wc.c



