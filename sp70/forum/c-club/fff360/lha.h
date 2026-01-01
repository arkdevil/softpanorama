#include <time.h>

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
	unsigned int	ft_tsec	 : 5;	/* Two second interval */
        unsigned int    ft_min   : 6;   /* Minutes             */
        unsigned int    ft_hour  : 5;   /* Hours               */
        unsigned int    ft_day   : 5;   /* Days                */
        unsigned int    ft_month : 4;   /* Months              */
        unsigned int    ft_year  : 7;   /* Year                */
} ftime;

typedef struct {
	unsigned short time;
	unsigned short date;
}datetime;

typedef union {                                  /* time stamp */
	unsigned long u;
	ftime s;
	datetime t;
} stamp;

typedef struct {
        int           headersize;
        char          method[6];
	unsigned long packed;
	unsigned long skip;
	unsigned long original;
        stamp         dostime;
        time_t        utc;
        int           attr;
        int           level;
	unsigned int  filecrc;
	unsigned int  headcrc;
        int           dos;
        char          *pathname;
        char          *filename;
        int           dirnlen;
        int           filenlen;
        int           info;
        long          currentpos;
        char          *crcpos;
} head;


void DoLzh (char *Path);
