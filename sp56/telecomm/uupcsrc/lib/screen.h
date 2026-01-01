#define WDEBUG 0
#define WTRANS 1
#define WLINK  2
#define NWINS  3

struct rccoord {
	short row;
	short col;
};

#define NCOLORS 16

typedef enum {
	SL_CALLEDBY,
	SL_CONNECTED,
	SL_CALLING
} Slmesg;

typedef enum {
	SM_CONNECT,
	SM_BUSY,
	SM_NOREPLY,
	SM_NOCARRY,
	SM_NOTONE,
	SM_NOPOWER,
	SM_INIT,
	SM_NOBAUD,
	SM_DIALING
} Smdmesg;

typedef enum {
	SF_SEND,
	SF_RECV,
	SF_SDONE,
	SF_RDONE,
	SF_DELIVER
} Sfmesg;

void Srestoreplace(void);
void Ssaveplace(int);
void Serror(const char *fmt, ...);
void Slink(Slmesg, const char *, const char *);
void Smodem(Smdmesg, int);
void Smisc(const char *,...);
void Sinfo(const char *);
void Swputs(int, const char *);
void Saddbytes(long, Sfmesg);
void Sftrans(Sfmesg, const char *, const char *);
void Sclear(void);
void Sheader(const char *);
void Spacket(int, char, int);
void Spakerr(int);
void Stoterr(int);
void Sundo(void);
