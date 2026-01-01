/***************************************************************/
/*                                                             */
/*               KIVLIB include file  MNU.H                    */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef  ____M_E_N_U____
#define  ____M_E_N_U____

#ifndef ___FAST_H___
#include <fastw.h>
#endif
#ifndef ___WINS_H___
#include <wins.h>
#endif


typedef struct MenuItem {
	      char * name;
	      int x;
	      int y;
	      int l;
	      int command;
	      unsigned key;
	      int helpIndex;
	      struct MenuItem * next;
	      struct MenuItem * prev;
	      struct SubMenu * sub;
	      struct SubMenu * parent;
	      };

typedef struct SubMenu {
	     int sr;
	     int sc;
	     frametype fr;
	     int shadowed;
	     int wattr;
	     int fattr;
	     int hattr;
	     int shattr;
	     int selattr;
	     char * header;
	     int dir;     //0-vertical, 1-horizontal
	     struct MenuItem * first;
	     struct MenuItem * parent;
	     };

#ifdef __cplusplus
extern "C" {
#endif

struct MenuItem * cdecl newMenuItem(char * name, int command,
				    unsigned key,int help,
				    struct MenuItem * next,
				    struct SubMenu  * sub);
struct SubMenu * cdecl newSubMenu( int sr, int sc, frametype FR,
				   int shadow,
				   int winattr,
				   int frattr,
				   int hattr,
				   int shattr,
				   int selattr,
				   char * header,
				   int dir,
				   struct MenuItem * first);
void cdecl freeMenuItem(struct MenuItem * m);
void cdecl freeSubMenu(struct SubMenu * s);

int cdecl MenuChoise(struct SubMenu * S, void ___FUNCS (*HELP)(int));

int cdecl MenuChoiseWithHelp(struct SubMenu * S, void ___FUNCS (*HELP)(int),
                       int row, int col, int lens, int attr, char * ___FUNCS(*HelpStr)(int));


char * cdecl MenuItemName(struct SubMenu * S, int command);

#ifdef __cplusplus
};
#endif

#endif