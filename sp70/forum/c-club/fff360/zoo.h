#ifndef DOS_DATE
#define DOS_DATE
typedef union {
	unsigned u;
	struct {
                unsigned Day   : 5;
		unsigned Month : 4;
		unsigned Year  : 7;
		} b;
	} DOS_FILE_DATE;
#endif

#ifndef DOS_TIME
#define DOS_TIME
typedef union {
	unsigned u;
	struct {
		unsigned Second : 5;
		unsigned Minute : 6;
		unsigned Hour   : 5;
		} b;
	} DOS_FILE_TIME;
#endif

/*----------------------------------------------------------------------*/
/*                  Maps of ZOO file headers and entries                */
/*----------------------------------------------------------------------*/

#define PATHSIZE   256                      /* Max length of pathname */
#define FNAMESIZE  13                       /* Size of DOS filename   */
#define LFNAMESIZE 256                      /* Size of long filename  */
#define SIZ_TEXT   20                       /* Length of header text  */
#define VALID_ZOO  0xFDC4A7DCL              /* Valid ZOO tag          */
#define FORMAT_ERROR 0xFF
#define END_OF_FILE 0xEF

typedef char HeaderTextType[SIZ_TEXT];
typedef char FNameType[FNAMESIZE];
typedef char LFNameType[LFNAMESIZE];
typedef char PathType[PATHSIZE];

typedef struct ZOOHeaderType {              /* ZOO file header          */
        HeaderTextType HeaderText;          /* Character text           */
        unsigned long ZOOTag;               /* Identifies archives      */
        unsigned long ZOOStart;             /* Where data starts        */
        unsigned long ZOOMinus;             /* Consistency check        */
        unsigned char ZOOMajor;             /* Major version #          */
        unsigned char ZOOMinor;             /* Minor version #          */
        } ZOO_HEADER_TYPE;                  /* One entry in ZOO library */

typedef struct ZOOFixedType {               /* Fixed part of entry            */
        unsigned long ZOOTag;               /* Tag -- redundancy check        */
        unsigned char ZOOType;              /* Type of directory entry        */
        unsigned char PackMethod;           /* 0 = no packing, 1 = normal LZW */
        unsigned long Next;                 /* Pos'n of next directory entry  */
        unsigned long Offset;               /* Position of this file          */
	DOS_FILE_DATE Date;
	DOS_FILE_TIME Time;
        unsigned int FileCRC;               /* CRC of this file                 */
        unsigned long OrgSize;              /* Original file size               */
        unsigned long SizeNow;              /* Compressed file size             */
        unsigned char MajorVer;             /* Version required to extract ...  */
        unsigned char MinorVer;             /* this file (minimum)              */
        unsigned char Deleted;              /* Will be 1 if deleted, 0 if not   */
        unsigned char Structure;            /* File structure if any            */
        unsigned long Comment;              /* Points to comment;  zero if none */
        unsigned int CmtSize;               /* Length of comment, 0 if none     */
        FNameType FName;                    /* Filename                         */
        int VarDirLen;                      /* Length of var part of dir entry  */
        unsigned char TimeZone;             /* Time zone where file was created */
        unsigned int DirCRC;                /* CRC of directory entry           */
	} ZOO_FIXED_TYPE;

/*  Variable part of entry */

typedef char ZOO_VARYING_TYPE[4 + PATHSIZE + LFNAMESIZE];

/*	Prototypes for ZOO Processing Functions		*/

void DoZOO (char *ZOOFileName);
int GetZOOHeader (FILE *ZOOFile, unsigned long *ZOOPos);
int GetNextZOOEntry (FILE *ZOOFile, unsigned long *ZOOPos, ZOO_FIXED_TYPE *ZOOEntry);
void DisplayZOOEntry (FILE *ZOOFile, char *ZOOFileName, ZOO_FIXED_TYPE *ZOOEntry);
