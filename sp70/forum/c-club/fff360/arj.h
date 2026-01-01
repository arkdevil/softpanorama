typedef unsigned char  uchar;   /*  8 bits or more */
typedef unsigned int   uint;    /* 16 - 32 bits or more */
typedef unsigned short ushort;  /* 16 bits or more */
typedef unsigned long  ulong;   /* 32 bits or more */

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

typedef struct {
	unsigned char FirstHeaderSize;
	unsigned ArchivVersion;
	unsigned char HostOS;
	unsigned char ARJFlags;
	unsigned char Method;
	unsigned Reserved;
	DOS_FILE_TIME Time;
	DOS_FILE_DATE Date;
	unsigned long CompressedSize;
	unsigned long OriginalSize;
	unsigned long CRC;
	unsigned EntryNamePosition;
	unsigned FileMode;
	unsigned HostData;
	} ARJ_HEADER;

#define FNAME_MAX         512
#define FIRST_HDR_SIZE    sizeof(ARJ_HEADER)-4
#define COMMENT_MAX       2048
#define HEADERSIZE_MAX    (FIRST_HDR_SIZE + 10 + FNAME_MAX + COMMENT_MAX)

void DoArj (char *Path);
