#ifndef LIFESCR_H			/* To prevent redefinition	*/

#define  LOCAL		static
#define  ENTRY		extern

#define EMPTY_SYM	249
#define CELL_SYM	7
#define EMPTY_ATTR	dsp_doAttr(DSP_CYAN,DSP_BLUE)
#define CELL_ATTR	dsp_doAttr(DSP_LIGHTCYAN,DSP_BLUE)

#include "life.h"

extern long scrX, scrY;
extern long scrOldX, scrOldY;

ENTRY void hideCell (CELL *cell);
     /* Убрать точку с экрана.                                  */
ENTRY void showCell (CELL *cell);
     /* Вывести точку на экран.                                 */
ENTRY void ReDraw(void);
ENTRY void drawLand(void);
ENTRY void OutStatistics(char *mode);
ENTRY void StartStatisticsOut(void);
ENTRY void HideStatisticsWnd(void);
ENTRY void ShowStatisticsWnd(void);

#define LIFESCR_H			/* Prevents redefinition	*/

#endif					/* Ends "#ifndef LIFESCR_H"	*/

