#include       <dos.h>
#include       <dir.h>
#include        <io.h>
#include     <fcntl.h>
#include      <bios.h>
#include     <conio.h>
#include     <alloc.h>
#include    <stdlib.h>
#include    <string.h>
#include    <stdarg.h>
#include  <sys\stat.h>

#define LST form[0]
#define BST form[1]
#define EST form[2]

#define AT	79
#define ATB	112
#define VSG	0xb800
#define COL	80
#define LIN	25
#define TB	8

#define CTRL_ENT 284
#define ENT	28
#define TAB	15
#define BS	14
#define ESC	1
#define END	79
#define INS	82
#define DEL	83
#define HOME	71
#define AL	75
#define AR	77
#define C_AL	115
#define C_AR	116
#define MF	2
#define SS	3
#define GOTO	4
#define UP	72
#define DOWN	80
#define PGUP	73
#define PGDN	81
#define C_END	117
#define C_HOME	119
#define C_PGDN	118
#define C_PGUP	132
#define C_Y	256+21
#define F	59
#define S_F	84
#define C_F	94
#define A_F	104
#define ALT	120
#define ALTBS	14

#define FunTab(c)	((c+TB)&-8)
#define BELL		{ putch('\a'); return; }
#define PUT_CHA(x,y,c,a) poke(VSG,((y)*160+(x)*2),c|(a)<<8)
#define INIT_MOUSE	inter(0)		// инициализ. драйвера мыши
#define SHOW_CURSOR	inter(1)		// сделать курсор видимым
#define HIDE_CURSOR	inter(2)		// сделать курсор невидимым,
#define READ_CURSOR	inter(3)		// определить состояние курсора
#define CURSOR_SET(x,y)	inter(4,(x)*8-1,(y)*8-1)// установка в позицию экрана

#define WX	(w->wx)
#define WY	(w->wy)
#define WW	(w->ww)
#define WH	(w->wh)
#define TX	(w->tx)
#define TY	(w->ty)
#define BX	(w->bx)
#define FS	(w->fs)
#define NS	(w->ns)
#define PS	(w->ps)
#define BM	(w->bm)
#define MRY	(w->mry)
#define MRX	(w->mrx)
#define CLIN	(w->clin)
#define CORR	(w->corr)
#define L_EN	(w->l_en)
#define ATRM	(w->atrm)
#define ATRF	(w->atrf)
#define F_INS	(w->f_ins)
#define LIMM	(w->limm)
#define LIM	(w->lim)
#define L_M	(w->l_m)
#define PCUR	(w->pcur)
#define AREA	(w->area)
#define ARR	(w->arr)
#define F_N	(w->f_n)
#define S_SC	(w->s_sc)

#define _IS_SP  1				// is space
#define _IS_DIG 2				// is digit indicator
#define _IS_UPP 4				// is upper case
#define _IS_LOW 8				// is lower case
#define _IS_HEX 16				// [0..9] or [A-F] or [a-f]
#define _IS_CTL 32				// Control
#define _IS_PUN 64				// punctuation

#define isalnum(c)	(ctype[c] & (_IS_DIG |_IS_UPP |_IS_LOW))
#define isalpha(c)	(ctype[c] & (_IS_UPP |_IS_LOW))
#define isdigit(c)	(ctype[c] &_IS_DIG)
#define islower(c)	(ctype[c] &_IS_LOW)
#define ispunct(c)	(ctype[c] &_IS_PUN)
#define isspace(c)	(ctype[c] &_IS_SP)
#define isupper(c)	(ctype[c] &_IS_UPP)

char  ctype[256] = {
//    0	       		 	  	                  
  _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL,_IS_CTL,
//           \t       \n                                        
  _IS_CTL, _IS_CTL|_IS_SP,
		    _IS_SP|_IS_CTL,
			     _IS_SP|_IS_CTL,
				      _IS_SP|_IS_CTL,
					       _IS_SP|_IS_CTL,
							_IS_CTL,_IS_CTL,
//                                                           
  _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL,_IS_CTL,
//                   ->                                       
  _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL, _IS_CTL,_IS_CTL,
//             !        "        #        $        %        &       '
  _IS_SP,  _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN,_IS_PUN,
//    (        )        *        +        ,        -        .       /
  _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN,_IS_PUN,
//    0        1        2        3        4        5        6       7
  _IS_DIG, _IS_DIG, _IS_DIG, _IS_DIG, _IS_DIG, _IS_DIG, _IS_DIG,_IS_DIG,
//    8        9        :        ;        <        =        >       ?
  _IS_DIG, _IS_DIG, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN,_IS_PUN,
//    @        A        B        C        D        E        F       G
  _IS_PUN, _IS_UPP|_IS_HEX,
		    _IS_HEX|_IS_UPP,
			     _IS_UPP|_IS_HEX,
				      _IS_UPP|_IS_HEX,
					       _IS_UPP|_IS_HEX,
							_IS_UPP|_IS_HEX,
								_IS_UPP,
//    H        I        J        K        L        M        N       O
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP,_IS_UPP,
//    P        Q        R        S        T        U        V       W
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP,_IS_UPP,
//    X        Y        Z        [        \        ]        ^       _
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN,_IS_PUN,
//    `        a        b        c        d        e        f       g
  _IS_PUN, _IS_LOW|_IS_HEX,
		    _IS_HEX|_IS_LOW,
			     _IS_LOW|_IS_HEX,
				      _IS_LOW|_IS_HEX,
					       _IS_LOW|_IS_HEX,
							_IS_LOW|_IS_HEX,
								_IS_LOW,
//    h        i        j        k        l        m        n       o
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW,_IS_LOW,
//    p        q        r        s        t        u        v       w
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW,_IS_LOW,
//    x        y        z        {        |        }        ~       
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_PUN, _IS_PUN, _IS_PUN, _IS_PUN,_IS_CTL,

//    А        Б        В        Г        Д        Е        Ж       З
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP,_IS_UPP,
//    И        Й        К        Л        М        Н        О       П
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP,_IS_UPP,
//    Р        С        Т        У        Ф        Х        Ц       Ч
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP,_IS_UPP,
//    Ш        Щ        Ъ        Ы        Ь        Э        Ю       Я
  _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP, _IS_UPP,_IS_UPP,
//    а        б        в        г        д        е        ж       з
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW,_IS_LOW,
//    и        й        к        л        м        н        о       п
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW,_IS_LOW,

//    ░        ▒        ▓        │        ┤        ╡        ╢       ╖
      0,       0,       0,       0,       0,       0,       0,      0,
//    ╕        ╣        ║        ╗        ╝        ╜        ╛       ┐
      0,       0,       0,       0,       0,       0,       0,      0,
//    └        ┴        ┬        ├        ─        ┼        ╞       ╟
      0,       0,       0,       0,       0,       0,       0,      0,
//    ╚        ╔        ╩        ╦        ╠        ═        ╬       ╦
      0,       0,       0,       0,       0,       0,       0,      0,
//    ╨        ╤        ╥        ╙        ╘        ╒        ╓       ╫
      0,       0,       0,       0,       0,       0,       0,      0,
//    ╪        ┘        ┌        █        ▄        ▌        ▐       ▀
      0,       0,       0,       0,       0,       0,       0,      0,

//    р        с        т        у        ф        х        ц       ч
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW,_IS_LOW,
//    ш        щ        ъ        ы        ь        э        ю       я
  _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW, _IS_LOW,_IS_LOW,
//    Ё        ё        Ґ        ґ        Є        є        І       і
  _IS_UPP, _IS_LOW,     0,       0,       0,       0,       0,      0,
//    Ї        ї        ·        √        №        ¤        ■
      0,       0,       0,       0,       0,       0,       0,      0
};

//          ПРОТОТИПЫ ФУНКЦИЙ

void	AF1(void);
void	AF2(void);
void	AF3(void);
void	AF4(void);
void	AF5(void);
void	AF6(void);
void	AF7(void);
void	AF8(void);
void	AF9(void);
void	AF10(void);
int	TextContext(void);
void	iTOa(int, char *);
void	Format(void);
void	Cent(void);
void	Form(void);
void	FindLine(char *);
void	CheckScreen(int);
void	CheckLine(int);
void	CheckCol(int);
int	CheckMark(char *);
void	DelMar(void);
void	Subst(void);
int	BegStr(char *);
void	Lift(int);
void	PushScreen(void);
void	PopScreen(void);
char	*CpyBox(void);
void	Ascii(void);
int	IsFile(char *);
void	Back(char*);
void	PushVar(void);
void	PopVar(int);
int	CheckBorder(int);
void	PutRecoder(void);
void	SetRecoder(void);
void	strdec(char *,int);
void	strinc(int);
void	PopCursor(void);
void	PushCursor(void);
void	Word(void);
void	StartMacro(void);
void	Start(void);
void	Command(void);
void	Directory(void);
void	MacroSub(char *,int);
void	BlockBegin(void);
void	BlockEnd(void);
int 	LoadName(char *);
int	Atoi(char *);
char	*Itoa(unsigned, char *);
char	*ReadFile(char *,int);
void	InitEdit(void);
void	Condtion(void);
void	ReadHelp(void);
void	NextLine(int);
void	LoadIndex(void);
void	BlockLoad(void);
void	HelpDir(void);
void	CreatBakFile(void);
void	PopWindow(void);
void	Macro(void);
void	LoadMacro(void);
void	ResetScreen(void);
void	SizeMove(int);
void	InputChar(void);
void	CtrlY(void);
void	Delete(void);
void	MoveFrame(void);
void	ReSize(void);
void	Enter(void);
void	Escap(void);
void	Tab(void);
void	BackSpase(void);
void	Insert(void);
void	End(void);
void	Home(void);
void	Left(void);
void	CtrlRight(void);
void	CtrlLeft(void);
void	PageUp(void);
void	Up(void);
void	CtrlPageDoun(void);
void	CtrlPageUp(void);
void	CtrlEnd(void);
void	CtrlHome(void);
void	HelpEdit(void);
void	Set(void);
void	CreatFrame(void);
void	SaveFile(void);
void	GotoLine(void);
void	FindContext(void);
void	SaveAs(void);
void	WriteDir(char *,char *,int);
void	LoadFile(void);
void	BlockCopyMove(void);
void	BlockOff(void);
void	BlockSto(void);
void	BlockSave(void);
void	BlockPop(void);
void	Dos(void);
void	Zoom(void);
void	Empty(void);
char	*pos(char *, int);
void	border(void);
int 	edit(int,int,int,int,char *,int);
void	PutScreen(char *);
void	PutStr(int,int,char *,int);
int 	read_str(char *,int,int,int,int);
int 	inter(int,...);
int 	GetChar(void);
void	frame(int,int,char *,int);
int 	question(int,char *,char *);

typedef void(*PF)(void);

typedef struct win {
int	wx,wy,ww,wh,
	ox,oy,ow,oh,
	tx,ty,cw,bx,
	mrx,mry, nw,
	f_ins,fs,ns,
	clin,corr,
	atrm,atrf;
unsigned lim,limm,l_m;
int	*s_sc;
char	*ps,*area,
	*arr,*bm,
	*pcur,
	f_n[20];
} sw;
sw *w, *v, *win[9];

char near but_col[] = {112,79},cursor[] = {_SOLIDCURSOR,_NORMALCURSOR};

char near fb[] = { F, C_F, S_F, A_F };

char near *fun[] = {
	"1  Help  2 Save  3 Wmove 4 Wsize 5 WNew  6  Goto  7 Find 8  Zoom 9 Form  0 Cent ",
	"1 BlCop  2 BlMov 3 BlOff 4 BlSto 5 BlPop 6  BlSav 7 Dos  8 BlBeg 9 BlEnd 0 BlLod",
	"1 FLoad  2 SavAs 3 PushC 4 PopC  5 MWord 6  MLoad 7 Next 8 Subst 9 SetRc 0 Ascii",
	"1        2       3       4       5       6        7      8       9       0      "
//	"1  AF1   2  AF2  3  AF3  4  AF4  5  AF5  6   AF6  7  AF7 8  AF8  9  AF9  0 AF10 "
};

char near AltKod[] = {30,48,46,32,18,33,34,35,23,36,37,38,50, 49,24,25,16,19,31,20,22,47,17,45,21,44,0},
	*AltChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

PF	fileoptions[] = {Condtion,LoadMacro,ReadHelp,Start,Format};
char	*options[]    = {"bak","macro","help","start","format",0};

typedef struct keyfile {
  char	flag;
  int	key;
  char	*namekey;
  PF	nameutil;
} kf;

kf near *pkf,arrkey[] = {
{1,0,      "INPUT",	InputChar},
{1,SS,     "RESIZE",	ReSize},	{0,ENT,	  "ENTER",  Enter},	    {0,ESC,	"ESCAP",  Escap},     {1,TAB,	 "TAB",	  Tab},
{1,BS,     "BS",	BackSpase},	{0,INS,	  "INSERT", Insert},	    {1,DEL,	"DELETE", Delete},    {0,END,	 "END",   End},
{0,HOME,   "HOME",	Home},		{0,AR,	  "RIGHT",  Left},	    {0,AL,	"LEFT",	  Left},      {0,C_AR,	 "^RIGHT",CtrlRight},
{0,C_AL,   "^LEFT",	CtrlLeft},	{0,PGDN,  "PGDN",   PageUp},	    {0,PGUP,	"PGUP",	  PageUp},    {0,DOWN,	 "DOWN",  Up},
{0,UP,     "UP",	Up},		{0,C_END, "^END",   CtrlEnd},	    {0,C_HOME,	"^HOME",  CtrlHome},  {0,C_PGDN, "^PGDN", CtrlPageDoun},
{0,C_PGUP, "^PGUP",	CtrlPageUp},	{1,C_Y,   "^Y",	    CtrlY},	    {1,F,	"F1",	  HelpEdit},  {1,F+1,	 "F2",	  SaveFile},
{0,F+2,    "F3",	Set},		{1,F+3,   "F4",	    Set},	    {1,F+4,	"F5",	  CreatFrame},{0,F+5,	 "F6",	  GotoLine},
{0,F+6,    "F7",	FindContext},	{1,F+7,   "F7",     Zoom},	    {1,F+8,	"F9",	  Form},      {1,F+9,	 "F10",	  Cent},
{1,C_F,    "^F1",	BlockCopyMove},	{1,C_F+1, "^F2",    BlockCopyMove}, {0,C_F+2,	"^F3",	  BlockOff},  {0,C_F+3,  "^F4",	  BlockSto},
{1,C_F+4,  "^F5",	BlockPop},	{0,C_F+5, "^F6",    BlockSave},	    {1,C_F+6,	"^F7",	  Dos},       {0,C_F+7,  "^F8",	  BlockBegin},
{0,C_F+8,  "^F9",	BlockEnd},	{1,C_F+9, "^F10",   BlockLoad},	    {0,S_F,	"SF1",	  Directory}, {1,S_F+1,  "SF2",	  SaveAs},
{0,S_F+2,  "SF3",	PushCursor},	{1,S_F+3, "SF4",    PopCursor},     {1,S_F+4,	"SF5",	  Word},      {0,S_F+5,  "SF6",	  StartMacro},
{0,S_F+6,  "SF7",	FindContext},	{1,S_F+7, "SF8",    Subst},         {0,S_F+8,	"SF9",	  SetRecoder},{1,S_F+9,	 "SF10",  Ascii},
{1,ALT,	   "A1",	PopWindow},	{1,ALT+1, "A2",	    PopWindow},     {1,ALT+2,	"A3",	  PopWindow}, {1,ALT+3,  "A4",	  PopWindow},
{1,ALT+4,  "A5",	PopWindow},	{1,ALT+5, "A6",     PopWindow},     {1,ALT+6,	"A7",	  PopWindow}, {1,ALT+7,  "A8",	  PopWindow},
{1,ALT+8,  "A9",	PopWindow},	{1,ALT+9, "A10",    PopWindow},     {0,MF,	"MF",	  MoveFrame},
//{1,A_F   "AF1",	AF1},		{1,A_F+1, "AF2",    AF2},	    {1,A_F+2,	"AF3",	  AF3},
//{1,A_F+3 "AF4",	AF4},		{1,A_F+4, "AF5",    AF5},	    {1,A_F+5,	"AF6",	  AF6},
//{1,A_F+6 "AF7",	AF7},		{1,A_F+7, "AF8",    AF8},	    {1,A_F+8,	"AF9",	  AF9},
//{1,A_F+9 "AF10",	AF10},
{0,GOTO,   "GOTO",	Empty},		{1,255,	  "ALT",    Macro}};
