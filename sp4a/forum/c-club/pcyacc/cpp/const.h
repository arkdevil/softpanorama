
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


/*
 * global constant definition
 */

#define FALSE 0
#define TRUE  1

#define NONFATAL 0
#define FATAL 1

#define EMPTY -1
#define NONTK -1

#define NMSZ 64
#define KWSZ 41
#define TBSZ 256

/*
 * for vec1
 */

#define ZERO 0x00000000

#define AUTO 0x00000001
#define REGI 0x00000002
#define EXTE 0x00000004
#define STAT 0x00000008
#define SCTP 0x0000000f

#define TDEF 0x00000010
#define CONS 0x00000020

#define FDEF 0x00000040
#define FDEC 0x00000080
#define DDEC 0x00000100

#define CSPE 0x00000200
#define USPE 0x00000400
#define ESPE 0x00000800

#define UNSI 0x00001000
#define CHAR 0x00002000
#define SHOT 0x00004000
#define INTE 0x00008000
#define LONG 0x00010000
#define FLOT 0x00020000
#define DOUB 0x00040000
#define VOID 0x00080000
#define TYPN 0x00100000
#define SIMP 0x001ff000

#define TBIT 0xffe00000
#define IEXP 0x00200000
#define ILST 0x00400000
#define IOBJ 0x00800000

#define PNTR 0x01000000
#define REFN 0x02000000
#define FTYP 0x04000000
#define ATYP 0x08000000

#define HASD 0x10000000
#define ISOP 0x20000000
#define FMOD 0x40000000 /* ft modifier */

/*
 * for vec2
 */

#define INLN 0x0001
#define VIRT 0x0002
#define FRND 0x0004
#define OVLD 0x0008

#define STRN 0x0010
#define CLAS 0x0020
#define ISPB 0x0040

