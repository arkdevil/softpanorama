/***************************************************************/
/*                                                             */
/*                 KIVLIB include file MOUSE.H                 */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___MOUSE_H___
#define ___MOUSE_H___

#ifdef __cplusplus
extern "C" {
#endif


int cdecl MouseInstalled(int * buttons);
void cdecl MouseShow();
void cdecl MouseHide();

void cdecl MousePos(int *x, int *y, int *button);
// button & 1  left   button pressed
//          2  right  button pressed
//          4  middle button pressed

void cdecl TextMousePos(int *x, int *y, int *button);
// button & 1  left   button pressed
//          2  right  button pressed
//          4  middle button pressed

void cdecl MouseSetPos(int x, int y);
void cdecl TextMouseSetPos(int x, int y);
void cdecl MouseHorRange(int min, int max);
void cdecl TextMouseHorRange(int min, int max);
void cdecl MouseVerRange(int min, int max);
void cdecl TextMouseVerRange(int min, int max);

void cdecl TextMouseSetSoftCursor(unsigned ScreenMask, unsigned CursorMask);
// AND with ScreenMask
// XOR with CursorMask

void cdecl TextMouseSetHardCursor(unsigned StartLine, unsigned EndLine);
void cdecl MouseSetShape(void far * far buf, int hotCol, int hotRow);
void cdecl MouseSetShapeProc(void far * far shape); //from pseudo-function

void far cdecl MouseCross(); //Cross-shape cursor
void far cdecl MouseHand();
void far cdecl MousePricel();
void far cdecl MouseStrelka();
void far cdecl MouseWait();

unsigned cdecl MouseSaveBufferSize();
void cdecl MouseSaveState(void far * buf);
void cdecl MouseRestoreState(void far * buf);

void cdecl MouseSetSpeed(unsigned x, unsigned y);
//x,y -mickeys per 8 pixels

void cdecl MouseSetSpeedDoubling(unsigned speed);

void cdecl MouseSens(unsigned * xspeed, unsigned * yspeed,
			   unsigned * speeddoubling);


void far cdecl MouseSetHandler(void far (*Proc)(int mask, int button,
									  int hor, int ver,
									  int lasth, int lastv), unsigned mask);
/*
to disable handler use this function with mask==0
mask bits:
	  0 - mouse move
	  1 - left pressed
	  2 - left released
	  3 - right pressed
	  4 - right released
	  5 - center pressed
	  6 - center released
in Proc enter
	  mask   - mask
	  button - button status (same as MousePos)
	  hor    - horizontal pixels
	  ver    - vertical pixels
	  lasth  - last horizontal motioms
	  lastv  - last vertical motions
*/

int cdecl MouseInRegion(int x, int y, int x1, int y1, int *button);
int cdecl TextMouseInRegion(int x, int y, int x1, int y1, int *button);
int cdecl MouseWaitClickIn(int x, int y, int xx, int yy); //return buttons
int cdecl TextMouseWaitClickIn(int x, int y, int xx, int yy); //return buttons
int cdecl MouseClickOrKey(); // return if key - as bioskey
			  // button - high bits - button, low byte - 0xFF


#ifdef __cplusplus
 }
#endif



#endif

