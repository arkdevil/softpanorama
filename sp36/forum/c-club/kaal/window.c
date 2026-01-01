/* --- WINDOW.C -----------------------------------------------------
**
** Version 2.08.01á
**
** DESQview aware text mode window package for IBM PC/AT and full
** compatibles.
**
** (c) by MacSoft 1990
**
**   All parts of this package are free to redistribute in original
** in noncommercial means. No part of the code may be include into
** another packages, except when linked to application program from
** library. For exceptional cases you need a written permission
** from author. When using this product I'm encouraging you to use
** wndversio() to get information about this product and show it
** on the title screen or somewhere, it's not essential of course,
** but after all, that's all you have to pay! 
**   The documentation however may be printed out for personal use
** in case Norton Guides engine is not satisfying.
**
**   Author: Tallinn, Estonia, 200108
**           Akadeemia str. 1
**           Tallinn Technical University
**           Dept. of Radiotechnics
**           Madis Kaal
**           Fido 2:490/30
**
** Norton Guides is (C) 1987 by Peter Norton Computing
** Turbo C, Turbo Assembler, Turbo Link and Turbo Lib are products
** of Borland International
** DESQview is product of Quartedeck Office Systems
**
** -----------------------------------------------------------------
**
** 12-Aug-90   Added viewport stuff making flat windows and shadows
**             possible.
**
** 27-Sep-90   Slight modifications to makewindow() for better zooming,
**             changed version number to 2.01
**
** 01-Oct-90   Added some optimization flags for better code. Modified
**             my node number in guide sources. Changed the contents of
**             distributuin archive for easier update. Version 2.02á
**
** 06-Oct-90   Fixed bug in makewnd() made some weeks ago. Added function
**             to detect and set video mode. Version 2.03á
**
** 13-Oct-90   Added _myrand() and _myseed(). Version 2.04á
**
** 17-Oct-90   Mart made some suggestions, added wndversio() function,
**             Updated Guide version. Version 2.05á
**
** 18-Oct-90   Collected some useful stuff from TC include files to
**             window.h, #include <dos.h> is no longer needed. Added
**             macros for DESQview task switching during scroll etc.
**             Updated guide, note about alloc and so on...
**             Version 2.06á.
**
** 31-Nov-90   Added DVpause macro, fixed bug in snowtest(), waitkey()
**             is giving up timeslices while waits for keystroke.
**             As I haven't any problems with malloc() mixed with
**             _mymalloc(), this stuff is removed from guide.
**             New problem has stated instead : Mouse cursor under DV.
**             "Licked over" all sources to look better and more alike
**             to each other. Fixed _drawbox(), can now draw one-line
**             box, using only 3 chars from frame string.
**             Version 2.07á.
**
** 08-Dec-90   Menu system rewritten to use new function - raw menu
**             driver.
**             Version 2.08á
**
** 06-Jan-91   Added some comments and released the bug fix release.
**             Version 2.08.01á
**
*/
#include "window.h"

WINDOW far *_curntwnd;

char far * far wndversio(void)
{
	return (char far *)"MacSoft's WINDOW screen I/O v2.08.01á";
}

/*
** ------------------------------------------------------------------
*/
