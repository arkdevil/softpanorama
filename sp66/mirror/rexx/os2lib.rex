From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!hookup!swrinde!pipex!sunic!trane.uninett.no!eunet.no!nuug!EU.net!uunet!zib-berlin.de!informatik.tu-muenchen.de!lrz-muenchen.de!colin.muc.de!ars.muc.de!rommel Sun Aug 21 10:29:00 1994
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!hookup!swrinde!pipex!sunic!trane.uninett.no!eunet.no!nuug!EU.net!uunet!zib-berlin.de!informatik.tu-muenchen.de!lrz-muenchen.de!colin.muc.de!ars.muc.de!rommel
From: rommel@ars.muc.de (Kai Uwe Rommel)
Newsgroups: comp.lang.rexx
Subject: Re: How to shutdown in Rexx?
Distribution: inet
Message-ID: <2e566261.415253@ars.muc.de>
Date: Sat, 20 Aug 1994 22:06:57 +0200
References: <32u3gr$9ck@netnews.upenn.edu>
Organization: Private
Keywords: os2 Rexx
X-Posting-Software: UUPC/extended 1.12j inews ( 3Jun94 11:06)
Lines: 45

asseil54@equity.wharton.upenn.edu (Henri Robert Asseily) writes in article <32u3gr$9ck@netnews.upenn.edu>:
>Hi all,
>
>I just can't seem to find a way to have the computer shut down 
>automatically (by programming) in os2 2.1. Any ideas?
>Thanx.

There is a REXX Redbook from IBM ("OS/2 REXX: From Bark to Byte",
GG24-4199-00) that has a samples disk included. That contains source
code for an extension library which uses this code:

  #define INCL_WINWORKPLACE
  #include <os2.h>

  #define IDM_LOCKUP    0x2c1
  #define IDM_SHUTDOWN  0x2c0

  ULONG Shutdown(
  PUCHAR          Name,                   /* Function name             */
  ULONG           argc,                   /* Number of arguments       */
  RXSTRING        argv[],                 /* List of argument strings  */
  PSZ             Queuename,              /* Curre queue name          */
  PRXSTRING       Retstr)                 /* Returned result string    */
  {
     HWND deskFrame = WinQueryWindow(HWND_DESKTOP,QW_BOTTOM);

     WinPostMsg(deskFrame,WM_COMMAND,MPFROMSHORT(IDM_SHUTDOWN),
		    MPFROM2SHORT(CMDSRC_MENU,TRUE));

     BUILDRXSTRING(Retstr,"0");
     return(0);

  }

The file is extfunc.c/extfunc.dll.

Kai Uwe Rommel

--
/* Kai Uwe Rommel                                      Muenchen, Germany *
 * rommel@ars.muc.de                              CompuServe 100265,2651 *
 * rommel@informatik.tu-muenchen.de                  Fax +49 89 324 4524 */

DOS ... is still a real mode only non-reentrant interrupt
handler, and always will be.                -Russell Williams

