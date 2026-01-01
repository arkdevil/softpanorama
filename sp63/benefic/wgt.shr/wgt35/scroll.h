// WGT Multidirectional scrolling library
#ifdef __cplusplus
extern "C" {
#endif


extern block scroll1,scroll2;
extern int windowminx,windowminy,windowmaxx,windowmaxy;
extern int worldx,worldy;

extern wgtmap wloadmap(char *);
extern void winitscroll(int,int);
extern void wshowwindow(int,int,wgtmap);
extern void installkbd(void);
extern void uninstallkbd(void);
extern int mapwidth,mapheight;

extern void wscrollwindow(int,int, wgtmap);		// scroll the screen down
extern void wshowobjects();
extern int soverlap(int,int);
wgtmap wloadmap(char *);
void wsavemap(char *,wgtmap);
extern int wgetworldblock(int,int,wgtmap);
extern void wputworldblock(int,int,int,wgtmap);
extern void wfreemap(wgtmap);
extern void wendscroll(void);
extern void wcopyscroll(int,int);

typedef struct {
	char on;
	int x;
	int y;
	unsigned int num;
	} scrollsprites;

extern scrollsprites wobject[1001];
extern int numsprites;
extern int spritewidth[1001],spriteheight[1001];
extern char tiletype[201];

#ifdef __cplusplus
}
#endif
