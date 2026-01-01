#ifndef DOS_DATE
#define DOS_DATE
typedef union {
	unsigned u;
	struct {
		unsigned Day : 5;
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
        char ArcMark;                           /* arc mark = 0x1A                          */
	char HeaderVersion;			/* header version 0 = end, else pack method */
        char Name[13];                          /* file name                                */
        unsigned long Size;                     /* size of compressed file                  */
	DOS_FILE_DATE Date;
	DOS_FILE_TIME Time;
        unsigned Crc;                           /* cyclic redundancy check                  */
        unsigned long Length;                   /* true file length                         */
        } ARCHIVE_HEADER;                       /* the next size bytes after the header     */
                                                /* are the file, then another header ...    */

/*	Prototypes for ARC Processing Functions	*/

void DoArc (char *Path);
