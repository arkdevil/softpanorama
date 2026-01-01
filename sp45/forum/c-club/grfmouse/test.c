/*****************************************************************************
 * PROJECT:  Mouse routines with 'real' graphic cursor in text mode.
 *****************************************************************************
 * MODULE:  TEST.C
 *****************************************************************************
 * DESCRIPTION:
 *   Test program.
 *
 *****************************************************************************
 * MODIFICATION NOTES:
 *    Date     Author Comment
 * 26-Oct-1990	 dk   Initial file.
 * 07-Jan-1991	 dk   Fixed bugs and set up for release to Usenet.
 *****************************************************************************
 *
 * DISCLAIMER:
 *
 * Programmers may incorporate any or all code into their programs, 
 * giving proper credit within the source. Publication of the 
 * source routines is permitted so long as proper credit is given 
 * to Dave Kirsch.
 *
 * Copyright (C) 1990, 1991 by Dave Kirsch.  You may use this program, or
 * code or tables extracted from it, as desired without restriction.
 * I can not and will not be held responsible for any damage caused from
 * the use of this software.
 *
 *****************************************************************************
 * This source works with Turbo C 2.0 and MSC 6.0 and above.
 *****************************************************************************/

#include <stdio.h>

#include "mou.h"

MOUINFOREC m;

int main(void)
{
int oldmx = -1, oldmy = -1;

  MOUinit();
  MOUshow();

  if (!mouseinstalled) {
    printf("Please install your mouse driver before running this test "
	   "program.\n");
    return 0;
  }

  MOUhide();
  printf("\x1b[2J"); /* Clear the screen with ANSI code. */

  printf("\x1b[5;1HClick here [■] with left mouse button to quit.");
  printf("\x1b[7;1HMouse routine demonstration program.");
  printf("\x1b[8;1HWith 'true' EGA/VGA mouse cursor.");
  printf("\x1b[9;1HCopyright (C) 1990, 1991 by Dave Kirsch.");
  MOUshow();

  for (;;) {
    if (mousex != oldmx || mousey != oldmy) {
      oldmx = mousex;
      oldmy = mousey;
      MOUconditionalhide(0, 0, 50, 0);
      printf("\x1b[1;1HMouse position: %3d, %3d", mousex, mousey);
      MOUshow();
    }

    if (MOUcheck()) { /* If mouse event waiting in buffer... */
      MOUget(&m);
      MOUconditionalhide(0, 1, 50, 2);
      if (m.buttonstat & LEFTBPRESS)
	printf("\x1b[2;1HLeft button pressed at %3d, %3d ", m.cx, m.cy);
      if (m.buttonstat & LEFTBRELEASE)
	printf("\x1b[2;1HLeft button released at %3d, %3d", m.cx, m.cy);
      if (m.buttonstat & RIGHTBPRESS)
	printf("\x1b[3;1HRight button pressed at %3d, %3d ", m.cx, m.cy);
      if (m.buttonstat & RIGHTBRELEASE)
	printf("\x1b[3;1HRight button released at %3d, %3d", m.cx, m.cy);
      MOUshow();

      if (m.buttonstat & LEFTBPRESS && m.cx > 11 && m.cx < 14 && m.cy == 4) {
	MOUdeinit();
	printf("\x1b[2J"); /* Clear the screen with ANSI code. */
	return 0;
      }
    }
  }
}
