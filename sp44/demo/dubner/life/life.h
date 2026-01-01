#ifndef LIFE_H				/* To prevent redefinition	*/

#define LIFE_H				/* Prevents redefinition	*/

#define  LOCAL		static
#define  ENTRY		extern

#include <istypes.h>

typedef struct cell {
   struct cell *next;
   struct {
      long x,y;
   } loc;
   int 	mode;
} CELL;

#define	DELETE	0x4

extern CELL *mainList;
extern long scrX, scrY;
extern long scrOldX, scrOldY;
extern big  stepNo;

ENTRY int  addCell (long x, long y, CELL **head);
     /* Добавляет точку с координатами (x, y) в список,      	*/
     /* голова которого расположена в head.                  	*/
     /* Возвращает:  1, если все в порядке;                    	*/
     /*             -1, если точка с такими координатами       	*/
     /*                 уже имеется в списке;                  	*/
     /*		     0, если не хватило памяти.			*/
ENTRY void wipeLand(void);
	/* Почистить список - убрать из него все точки.		*/
ENTRY void clearLand(void);
     /* Убрать из списка точки, помеченные на удаление          */

ENTRY CELL *findCell (long x, long y);
ENTRY void makeStep(void);
ENTRY big listLen (void);

ENTRY void Animate(void);
ENTRY void askTime(void);

#endif					/* Ends "#ifndef LIFE_H"	*/
