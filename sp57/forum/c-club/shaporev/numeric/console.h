#define	BLACK		0
#define	BLUE            1
#define	GREEN           2
#define	CYAN            3
#define	RED             4
#define	MAGENTA         5
#define	BROWN           6
#define	LIGHTGRAY       7
#define	DARKGRAY        8
#define	LIGHTBLUE       9
#define	LIGHTGREEN      10
#define	LIGHTCYAN       11
#define	LIGHTRED        12
#define	LIGHTMAGENTA    13
#define	YELLOW          14
#define	WHITE           15
#define BLINK		128
#define BOLD		8

#define attribute(f,b)  ((f)|((b)<<4))

struct	VideoSettings
{
	union {
		unsigned x;
                struct {
                   unsigned char l, h;
                } h;
	} vs_cursor;
	unsigned      vs_segment;
	unsigned      vs_blocks;
	unsigned char vs_width;
	unsigned char vs_height;
	unsigned char vs_mode;
	unsigned char vs_page;
	unsigned char vs_point;
	unsigned      vs_color:1;
	unsigned      vs_graph:1;
	unsigned      vs_hivid:1;
};
void AskVideo ( struct VideoSettings far * );

void     biosputs ( char far * );
void     biosputc ( char );
void     scrwipe  ( short, short, short, short, short );
void     scrolup  ( short, short, short, short, short, short );
void     scrolld  ( short, short, short, short, short, short );
void     scrgoto  ( short, short );
void     scrputs  ( char far * );
void     scrputc  ( char );
void     scrouts  ( short, short, char far * );
void     scrpage  ( short );
void     scrmove  ( short, short, short, short, short, short);
void     scrpick  ( short, short, short, short, void far * );
void     scrload  ( short, short, short, short, void far * );
unsigned scrpeek  ( void );
void     scrpoke  ( unsigned );
void     scraddr  ( short far *, short far *);

extern unsigned char _scrpage;

int      keyready ( void );
unsigned keyinput ( void );
unsigned keyflags ( void );
void     keyclear ( void );

#define KEY_SCAN 0xFF00
#define KEY_CHAR 0x00FF
#define KEY_NONE 0
#define KEY_101K 0xE0

#define KEY_ESC  0x011B
#define KEY_AP2  KEY_ESC
#define KEY_F1   0x3B00
#define KEY_F2   0x3C00
#define KEY_F3   0x3D00
#define KEY_F4   0x3E00
#define KEY_F5   0x3F00
#define KEY_F6   0x4000
#define KEY_F7   0x4100
#define KEY_F8   0x4200
#define KEY_F9   0x4300
#define KEY_F10  0x4400
#define KEY_F11  0x8500
#define KEY_F12  0x8600
#define KEY_TAB  0x0F09
#define KEY_RET  0x1C0D
#define KEY_ENT  0xE00D
#define KEY_HOME 0x4700
#define KEY_UP   0x4800
#define KEY_PGUP 0x4900
#define KEY_LEFT 0x4B00
#define KEY_RIGT 0x4D00
#define KEY_END  0x4F00
#define KEY_DOWN 0x5000
#define KEY_PGDN 0x5100
#define KEY_INS  0x5200
#define KEY_DEL  0x5300
