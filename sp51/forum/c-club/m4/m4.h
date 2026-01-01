/* header file for m4                                                       */

#define EVALSIZE        4096
#define MAXTOKEN        512
#define ARGSIZE         128
#define CALLSIZE        128
#define IBUFSIZ         4096
#define ISTSIZE         8
#define AQUOTSZ         4

#define OUTNAME         "M4TEMPX.$$$"
#define OUTIDX          6

#define DEFTYPE         0x80
#define IFTYPE          0x81
#define INCRTYPE        0x82
#define DECRTYPE        0x83
#define SUBTYPE         0x84
#define EVTYPE          0x85
#define CHQTYPE         0x86
#define UNDTYPE         0x87
#define IFDTYPE         0x88
#define INCLTYPE        0x89
#define SINCLTYPE       0x8a
#define DIVTYPE         0x8b
#define UNDIVTYPE       0x8c
#define DIVNTYPE        0x8d
#define LENTYPE         0x8e
#define INDTYPE         0x8f
#define TRANSTYPE       0x90
#define ERRTYPE         0x91
#define DUMPTYPE        0x92
#define DNLTYPE         0x93
#define CHARGTYPE       0x94
#define AQUOTYPE        0x95
#define NOBUILTTYPE     0x96
#define CMNTTYPE        0x97
#define MACTYPE         0x98
#define MKTMPTYPE       0x99
#define SYSCMDTYPE      0x9a

#define COMMA           ','
#define LPAREN          '('
#define RPAREN          ')'
#define LQUOTE          '`'
#define RQUOTE          0x27
#define EOS             '\0'
#define ARGFLAG         '$'
#define COMMENT         '#'

#define ALPHA           'a'

#undef TRUE
#undef FALSE
#define TRUE            1
#define FALSE           0

#ifdef AZTEC
#include <ctype.h>
#define putc            aputc
#define getc            agetc
#endif
