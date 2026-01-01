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

struct Stats {
	int Entry[3];
	};

typedef enum { arc, pak, zip, zoo, lzh, arj, none} ARC_TYPE;

#define ON  1
#define OFF 0

