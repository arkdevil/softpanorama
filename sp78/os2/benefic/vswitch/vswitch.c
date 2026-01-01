/*
         VSWITCH -- switch between full-screen OS/2 sessions

   Based on code by David Burton (Burton Systems Software) and Peter
   Fitzsimmons (A:Ware).

         A:Ware BBS: (416)867-9663 or (416)867-9664
         Burton BBS: (919)233-0106

   Task list modifications by Scott Dudley.

   This program is not copyrighted (public domain).

----------------------------------------------------------------------------
*/

#define INCL_DOSSEMAPHORES
#define INCL_DOSPROCESS
#define INCL_SUB
#define INCL_DOSMONITORS
#define INCL_DOSINFOSEG
#define INCL_WIN
#define INCL_WINSWITCHLIST
#include <os2.h>

#include <stdio.h>
#include <conio.h> /*SJD Wed  08-12-1992  19:52:45 */
#include <string.h>
#include <stdlib.h>
#include <process.h>

/* Bit mask to distinguish key press from key release */
enum {RELEASE=0x40};

/* Maximum number of task list sessions we can examine */
enum {MAXNUMSESS=32};

enum {MINSES=2, MAXSES=19};  /* we'll monitor sessions numbered 2..9 */
/* Note: start with session 2 to skip dos box (session 0) and PM (session 1) */

/* KBD monitor data record */
struct KeyPacket
  {
    unsigned mnflags;
    KBDKEYINFO cp;
    unsigned ddflags;
  };

/* keyboard handle from monitor open */
HKBD KBDHandle;

/* RAM semaphore cleared to kill program when any thread dies */
static ULONG semDead = 0;

/* Activate pop-up screem? */
static ULONG semPopup = 0;

/* ThreadProc_t is the type of the pointer-to-function parameter
   expected by _beginthread() */

typedef void (_cdecl _far * ThreadProc_t)(void _far *);




/* Switch to the specified session */

static void near switch_session(PSWBLOCK pswb, USHORT usSession) /*SJD Wed  08-12-1992  22:20:46 */
{
  WinSwitchToProgram(pswb->aswentry[usSession].hswitch);
}




/* Find the current process's entry in the task list, if any */

static USHORT near set_default(PSWBLOCK pswb, USHORT pidForeground)
{
  USHORT i;
  USHORT pid;
/*  char temp[100];

  sprintf(temp,"\r\nforeground PID is %d\r\n", pidForeground);
  VioWrtTTY(temp, strlen(temp), 0);*/

  for (i=0; i < pswb->cswentry; i++)
  {
/*  sprintf(temp,"\r\nchecking %d\r\n", i);
    VioWrtTTY(temp, strlen(temp), 0);*/

    /* See if this PID is for any of the parents in the session */

    pid=pidForeground;

    do
    {
/*    sprintf(temp, "checked pid %x (%s)  ", pid,
              pid==pidForeground ? "PID" : "PPID");

      VioWrtTTY(temp, strlen(temp), 0);*/

      if (pid && pid==pswb->aswentry[i].swctl.idProcess)
      {
/*      sprintf(temp,"\r\nmatch on %d\r\n", i);
        VioWrtTTY(temp, strlen(temp), 0);*/
        return i;
      }
    }
    while (pid && DosGetPPID(pid, &pid)==0);
  }

  /* Else find the first available entry */

  if (pswb->aswentry[i].swctl.uchVisibility==SWL_VISIBLE)
    return i;

  while (i < pswb->cswentry-1)
    if (pswb->aswentry[++i].swctl.uchVisibility==SWL_VISIBLE)
      return i;

  return 1;
}




/* Get screen dimensions */

static void near get_dims(USHORT *pusWidth, USHORT *pusHeight) /*SJD Wed  08-12-1992  19:52:28 */
{
  VIOMODEINFO vmi;

  VioGetMode(&vmi, 0);
  *pusWidth=vmi.col;
  *pusHeight=vmi.row;
}



#define SELECTED 0x4000u    /* Bitmask indicating that <enter> or <space>   *
                             * was pressed                                  */

static USHORT near get_key(PSWBLOCK pswb, USHORT usSelection) /*SJD Wed  08-12-1992  22:20:42 */
{
  USHORT usOrigSel=usSelection;
  USHORT i, usTry;
  int ch;

  switch (ch=getch())
  {
    case 0x1b:    /* esc */
      return (USHORT)-1;

    case 0:   /* cursor key */
    case 0xe0:
      switch (getch())
      {
        case 45: /* alt-x */
          return (USHORT)-2;

        case 79: /* end */
        case 81: /* pgdn */
          usSelection=pswb->cswentry-1;

          if (pswb->aswentry[usSelection].swctl.uchVisibility==SWL_VISIBLE)
            break;
          /* else fall-thru */

        case 72: /* up */
        case 75: /* left */
          while (usSelection != 0)
          {
            if (pswb->aswentry[--usSelection].swctl.uchVisibility==SWL_VISIBLE)
              break;
          }

          if (pswb->aswentry[usSelection].swctl.uchVisibility != SWL_VISIBLE)
            usSelection=usOrigSel;
          break;

        case 71: /* home */
        case 73: /* pgup */
          usSelection=0;

          if (pswb->aswentry[usSelection].swctl.uchVisibility==SWL_VISIBLE)
            break;
          /* else fall-thru */

        case 77: /* right */
        case 80: /* down */
          while (usSelection < pswb->cswentry-1)
          {
            if (pswb->aswentry[++usSelection].swctl.uchVisibility==SWL_VISIBLE)
              break;
          }

          if (pswb->aswentry[usSelection].swctl.uchVisibility != SWL_VISIBLE)
            usSelection=usOrigSel;
          break;
      }
      break;

    case 13:  /* enter */
    case 32:  /* space */
      return usSelection | SELECTED;
      break;

    default:  /* select a session by letter */
      ch=tolower(ch);
      usTry=(USHORT)-1;

      for (i=0; i < pswb->cswentry; i++)
        if (ch==tolower(*pswb->aswentry[i].swctl.szSwtitle))
        {
          if (usSelection==i ||
              (i < usSelection &&
               tolower(*pswb->aswentry[usSelection].swctl.szSwtitle)==ch))
          {
            /* If this letter is already selected, skip to the next         *
             * one with this name.                                          */

            if (usTry==(USHORT)-1)
              usTry=i;

            continue;
          }

          return i;
        }

      if (usTry != (USHORT)-1)
        return usTry;
      break;
  }

  return usSelection;
}

#define ATTR_NORMAL 31
#define ATTR_SELECT 14

/* Ugly code which draws a task list window */

static void near draw_list(PSWBLOCK pswb, USHORT usWidth, USHORT usHeight, USHORT usSelection) /*SJD Wed  08-12-1992  22:20:37 */
{
  BYTE abCell[2];
  USHORT usMenuWidth, usMenuHeight;
  char temp[120];
  USHORT usLeft, usTop;
  USHORT i, len;
  BYTE bAttr;

  usMenuWidth=usMenuHeight=0;

  /* Determine the size required to hold all task names */

  for (i=0; i < pswb->cswentry; i++)
  {
    if (pswb->aswentry[i].swctl.uchVisibility != SWL_VISIBLE)
      continue;

    if ((len=strlen(pswb->aswentry[i].swctl.szSwtitle)) > usMenuWidth)
      usMenuWidth=len;

    usMenuHeight++;
  }

  /* Leave space for the border */

  usMenuWidth += 4;
  usMenuHeight += 2;

  /* Center window */

  usLeft=(usWidth-usMenuWidth) >> 1;
  usTop=(usHeight-usMenuHeight) >> 1;

  /* Draw the top border */

  abCell[1]=ATTR_NORMAL;

  abCell[0]='╔';  VioWrtNCell(abCell, 1, usTop, usLeft, 0);
  abCell[0]='═';  VioWrtNCell(abCell, usMenuWidth-2, usTop, usLeft+1, 0);
  abCell[0]='╗';  VioWrtNCell(abCell, 1, usTop, usLeft+usMenuWidth-1, 0);
  usTop++;

  /* Draw the switch entries */

  for (i=0; i < pswb->cswentry; i++)
  {
    if (pswb->aswentry[i].swctl.uchVisibility != SWL_VISIBLE)
      continue;

    /* left border */

    bAttr=ATTR_NORMAL;
    VioWrtCharStrAtt("║", 1, usTop, usLeft, &bAttr, 0);

    /* Draw the application name */

    bAttr=(BYTE)((i==usSelection) ? ATTR_SELECT : ATTR_NORMAL);
    sprintf(temp, " %-*s ", usMenuWidth-4,
            pswb->aswentry[i].swctl.szSwtitle);

    VioWrtCharStrAtt(temp, usMenuWidth-2, usTop, usLeft+1, &bAttr, 0);

    /* right border */

    bAttr=ATTR_NORMAL;
    VioWrtCharStrAtt("║", 1, usTop, usLeft+usMenuWidth-1, &bAttr, 0);

    /* draw shadow */

    bAttr=7;
    VioWrtNAttr(&bAttr, 1, usTop, usLeft+usMenuWidth, 0);

    usTop++;
  }

  /* bottom border */

  abCell[0]='╚';  VioWrtNCell(abCell, 1, usTop, usLeft, 0);
  abCell[0]='═';  VioWrtNCell(abCell, usMenuWidth-2, usTop, usLeft+1, 0);
  abCell[0]='╝';  VioWrtNCell(abCell, 1, usTop, usLeft+usMenuWidth-1, 0);

  /* Draw bottom of shadow */

  abCell[1]=7;
  abCell[0]=' ';  VioWrtNAttr(&bAttr, 1, usTop, usLeft+usMenuWidth, 0);

  bAttr=7;        VioWrtNAttr(&bAttr, usMenuWidth, usTop+1, usLeft+1, 0);
}


/* Do the pop-up vio screen */

static void near do_popup(void) /*SJD Wed  08-12-1992  19:52:31 */
{
  SEL selG, selL;
  GINFOSEG far *pgis;

  USHORT usSelection=0;
  PSWBLOCK pswb;
  ULONG ulcEntries;
  ULONG usSize;
  USHORT pfWait;
  USHORT usWidth, usHeight;
  USHORT pidForeground;

  /* Get the PID of the current foreground session */

  DosGetInfoSeg(&selG, &selL);
  pgis=MAKEPGINFOSEG(selG);
  pidForeground=pgis->pidForeground;

  /* Get a pop-up screen.  If we can't make it transparent, it means that   *
   * some Vio program is in graphics mode.  In that case, try to make       *
   * it opaque.                                                             */

  pfWait=VP_NOWAIT | VP_TRANSPARENT;

  if (VioPopUp(&pfWait, 0) != 0)
  {
    pfWait=VP_NOWAIT | VP_OPAQUE;

    if (VioPopUp(&pfWait, 0) != 0)
    {
      DosSemSet(&semPopup);
      return;
    }
  }

  /* Get the switch list information */

  ulcEntries=WinQuerySwitchList(0, NULL, 0);
  usSize=sizeof(SWBLOCK)+sizeof(HSWITCH)+(ulcEntries+4)*(long)sizeof(SWENTRY);

  /* Allocate memory for list */

  if ((pswb=malloc((unsigned)usSize)) != NULL)
  {
    /* Put the info in the list */

    ulcEntries=WinQuerySwitchList(0, pswb, (USHORT)(usSize-sizeof(SWENTRY)));

    /* Get screen size */

    get_dims(&usWidth, &usHeight);

    /* Set the default entry on our task list */

    usSelection=set_default(pswb, pidForeground);

    do
    {
      draw_list(pswb, usWidth, usHeight, usSelection);
      usSelection=get_key(pswb, usSelection);
    }
    while ((usSelection & SELECTED)==0);
  }

  /* Get rid of the pop-up screen */

  VioEndPopUp(0);

  /* Did the user press alt-x? */

  if (usSelection==(USHORT)-2)
    DosSemClear(&semDead);
  else if (usSelection != (USHORT)-1)
    switch_session(pswb, usSelection & ~SELECTED);

  if (pswb)
    free(pswb);

  /* Set the pop-up semaphore for next time 'round */

  DosSemSet(&semPopup);
}


void far _loadds cdecl monitor( long session )
  {
   struct KeyPacket keybufr;
   USHORT count;  /* number of chars in monitor read/write buffer */
   MONIN InBuff;  /* buffers for monitor read/writes: */
   MONOUT OutBuff;

   keybufr.cp.chChar = 0;
   InBuff.cb = sizeof(InBuff);
   OutBuff.cb = sizeof(OutBuff);

    /* register the buffers to be used for monitoring */
    if (DosMonReg( KBDHandle, (PBYTE)&InBuff, (PBYTE)&OutBuff, MONITOR_BEGIN,
                   (USHORT)session ))
        return;

    /* Main loop: read key into monitor buffer, examine it and take action
       if it is one of our hot keys, otherwise pass it on to device driver */
    for(;;)
      {
        count = sizeof(keybufr);

        if (DosMonRead( (PBYTE)&InBuff, IO_WAIT, (PBYTE)&keybufr, (PUSHORT)&count ))
            break;

        if ((keybufr.ddflags & RELEASE)==0 && keybufr.cp.chScan==53 &&
            (keybufr.cp.fsState & RIGHTALT))
        {
            DosSemClear(&semPopup);
        }
        else
        {
            if (DosMonWrite( (PBYTE)&OutBuff, (PBYTE)&keybufr, count ))
                break;
        }
      }/*for*/
  } /* monitor */


int cdecl main (void)
  {
    USHORT usSem; /* number of cleared semaphore */
    DEFINEMUXSEMLIST(mxs, 2)
    int i;

    /* Get a handle for registering buffers */
    DosMonOpen ( "KBD$", &KBDHandle );

    /* Bump up the process priority so that Ctrl-Break (for instance) is
       seen immediately */
    (void)DosSetPrty( PRTYS_PROCESSTREE, PRTYC_TIMECRITICAL, 0, 0 );

    /* set semaphore (which will be cleared when the user presses hotkey) */

    DosSemSet(&semDead);
    DosSemSet(&semPopup);


    /* For each session, start a thread which installs itself as a keyboard
       monitor to watch for hot-keys */

    for (i=MINSES; i<=MAXSES; i++)
        _beginthread( (ThreadProc_t)monitor, NULL, 2048, (void far *)(long)i);

    /* Now set up the array for DosMuxSemWait */

    mxs.cmxs=2;

    mxs.amxs[0].zero=0;
    mxs.amxs[0].hsem=&semPopup;

    mxs.amxs[1].zero=0;
    mxs.amxs[1].hsem=&semDead;

    do
    {
      /* Wait until one of the specified semaphores is cleared */

      if (DosMuxSemWait(&usSem, &mxs, SEM_INDEFINITE_WAIT) != 0)
        usSem=-1;

      if (usSem==0)
        do_popup();

      DosSleep(1L); /* magic */
    }
    while (usSem==0); /* loop until we get a semDead */

    /* Close connection with keyboard */
    DosMonClose ( KBDHandle );

    /* Exit - kill all threads */
    DosExit ( EXIT_PROCESS, 0 );
    return 0;  /* shut up compiler warning */
  } /*main*/

