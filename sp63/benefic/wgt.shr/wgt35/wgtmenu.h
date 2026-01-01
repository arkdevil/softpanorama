/* Include file for WGT Menus
Copyright 1993 Chris Egerter */

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	char *choice[10];
	int menux,menuy;
	int color;
	int bordercolor;
	int textcolor;
	} menulist; 

extern menulist dropdown[10];

extern void initdropdowns(void);
extern void removemenubar(void);
extern void showmenubar(void);
extern int checkmenu(void);

extern int menubarcolor;
extern int menubartextcolor;
extern int bordercolor;
extern int highlightcolor;
extern int mouseinstalled;
extern char menuhotkey;

extern wgtfont menufont;

#ifdef __cplusplus
}
#endif
