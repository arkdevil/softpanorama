

		   DOSLYNX V0.8 ALPHA RELEASE INFORMATION 

Contents: 

   Introduction 
   System Requirements 
   Obtaining DosLynx 
   Required Files 
   Installing DosLynx 
   Configuring DosLynx 
   Command Line Options 
   Using DosLynx 
   Special Notes on Usage 
   New DosLynx Features 
   Distributing DosLynx 
   Credits 



Introduction

   This is an alpha release of DosLynx for DOS compatible computers written
   by Garrett Arch Blythe for The University of Kansas.

   DosLynx is a distributed hypertext browser with some World Wide Web
   capabilities.

   This file provides information about installing, configuring, and using
   DosLynx v0.8a.

   DosLynx is copyrighted by the University of Kansas and is free for
   instructional and research educational use. Non-educational use will be
   licensed at a later date.

   DosLynx is available in its source and binary forms.



System Requirements

   One of DosLynx's goals is to provide support for as many DOS users as
   possible. We have scaled DosLynx towards this end.

   The known system requirements are:   

   CPU    8086 compatible. 

   Memory 512 kilobytes free or more recommended. 

   Hard Drive
	  Required. 2 megabytes free or more recommended. 

   Monitor
	  Monochrome, Black and White, and Color supported. 

   Graphics capability
	  Optional. 

   Mouse  Optional. 

   Network
	  None, or Class 1 (ethernet) packet driver connected to 
	  a TCP/IP network. You may, of course, emulate a Class 1 packet
	  driver 
	  if you have the required software for your particular system
	  (i.e. 
	  PPP, ODI, SLIP, etc). 


   DosLynx is known not to work on the following systems:       

   DOS    Versions below 3.0 will not work properly. 


   Release 0.7a stated erroneously that computers using Lan Workplace for
   DOS (or any other comparable TCP/IP stack) were not compatible with
   DosLynx. See the Installating DosLynx section on how to properly setup
   your computer when running an existing TCP/IP stack like Lan Workplace
   but would like to use DosLynx.

   If your system is also not supportable, we would very much like to know
   your system configuration. Please mail the DosLynx developer at this
   Internet address:


    lynx-help@ukanaix.cc.ukans.edu



Obtaining DosLynx

   DosLynx v0.8a is available via binary anonymous FTP at ftp2.cc.ukans.edu
   in the pub/WWW/DosLynx directory. DosLynx version 0.8 alpha will be the
   file named DLX0_8A.EXE which is a self-extracting archive.

   URL notation is ftp://ftp2.cc.ukans.edu/pub/WWW/DosLynx/DLX0_8A.EXE

   DosLynx will be updated periodically as new changes are made to the
   application. You will be able to find the new versions via binary
   anonymous FTP to ftp2.cc.ukans.edu in the pub/WWW/DosLynx directory
   under an appropriately named archive.

   URL notation for the directory is
   ftp://ftp2.cc.ukans.edu/pub/WWW/DosLynx/



Required Files

   DosLynx version 0.8 alpha has the following files shipped with it. If
   you do not have all of the files listed below we suggest obtaining a
   complete release from the Internet address listed above. 



   DOSLYNX.EXE
	  The DosLynx v0.8a executable. 

   DOSLYNX.CFG
	  The DosLynx v0.8a configuration file. 

   README.HTM
	  The HTML equivalent of this file. 

   README.TXT
	  The text equivalent of this file. 

   ERROR.HTM
	  The default DosLynx HTML error page. 

   HOTLIST.HTM
	  The default DosLynx HTML hotlist. 




Installing DosLynx

   This section assumes that you have not already installed DosLynx version
   0.8 alpha on your hard drive. If you already have, you may skip this
   section.

   Obtain a copy of DosLynx and place it in an appropriately named
   directory on your hard drive.

   Enter the command "DLX0_8A" from your DOS prompt in the directory which
   you placed the DosLynx v0.8a archive.

   The required files should be written by the self-extracting archive into
   the directory. You may now remove the DLX0_8A.EXE from the directory if
   you wish by entering the command "del DLX0_8A.EXE".

   For those users with a TCP/IP stack already loaded (such as Lan
   Workplace for DOS) you will need to configure your computer so that you
   can unload the TCP/IP stack at your convienience. When you are ready to
   run DosLynx, you must first unload your TCP/IP stack; for LWP, the
   command is "tcpip /u". Next, if need be, load a packet driver emulator
   for your system configuration. You should now be ready to run DosLynx.
   After using DosLynx, you may want to return your system to its previous
   configuration. Do this by unloading the packet driver emulator if one
   was loaded. Load your TCP/IP stack again to finish this process.



Configuring DosLynx

   Edit the DosLynx v0.8a configuration file named DOSLYNX.CFG with any
   text editor. Go through each keyword and provide the appropriate value.
   Ample configuration instructions are included in the distribution
   configuration file. Once finished, save the modifed file as ASCII text.
   If you wish to save your hotlist which was used in your old version of
   DosLynx, simply change the hotlist keyword in the configuration file to
   point to your old hotlist file.



Command Line Options

   DosLynx has the following command line switches and options. All command
   line options supercede their configuration file equivalents. All command
   line options are case insensitive except for URLs.



   /B     This option will hide the clock, socket activity, free 
	  free temporary disk space, free heap space, and message window 
	  for the duration of the current DosLynx session. This option 
	  was added to not clutter the screen for blind users as this 
	  causes some problems with screen readers, but makes for an 
	  all around cleaner display for all users if you wish to use /B. 

   /P     This is the most important command line option. If you will 
	  be executing DosLynx from a directory other than the one you 
	  installed DosLynx in, you must use the /P option. /P specifies 
	  the directory in which DosLynx may find its configuration file 
	  DOSLYNX.CFG and the errorhtml file ERROR.HTM. If you installed 
	  DosLynx in the directory C:\DLX then you should use the /P option

	  as follows:
	  doslynx /PC:\DLX
	  To avoid having to retype the /P option every time you wish to 
	  use DosLynx, create a DOS batch file automatically specifying 
	  the /P option for you and place the batch file a directory 
	  specified in your DOS PATH environment variable. 

   /T     This option specifies the temporary directory where DosLynx 
	  will create its temporary files. If you wanted to use the 
	  directory C:\TEMP as the place to store temporary files, then you

	  would use /T in the following manner:
	  doslynx /TC:\TEMP\

   /L     This option tells DosLynx how many loaded documents to keep 
	  in memory before it starts releasing the oldest unviewed file. If

	  you wanted DosLynx to keep the last 5 ready in memory, then you 
	  would use the /L option in the follwing way:
	  doslynx /L5

   /V     This option tells DosLynx what text mode to begin in. /VLOW 
	  tells DosLynx to use the 25 row text mode. /VHIGH tells DosLynx 
	  to attempt to use the 43 or 50 row text modes available to EGA
	  and 
	  VGA compatible video adapters. 

   /H     This option tells DosLynx if it should load the home page 
	  you specified in the configuration file. /HON tells DosLynx to 
	  load the home page on startup. /HOFF tells DosLynx to not load 
	  the home page on startup. /HOFF is automatically assumed if you 
	  also use a URL on the command line unless /HON follows the
	  command 
	  line URL. 

   /N     This option tells DosLynx if it will allow network access. 
	  To turn off network access, use /NNO. To allow network access, 
	  use /NYES. 

   URL    This command line option is actually any URL that you would 
	  like DosLynx to load from the command line. It can be any valid 
	  URL or it can be a DOS path to a file. Once a URL is specified on

	  the command line, your home page will not be loaded unless you 
	  also append the /HON to your command line following the URL. To 
	  have DosLynx load this document on startup, execute one of the 
	  following commands from the directory in which you installed 
	  DosLynx:

	  doslynx readme.htm

	  doslynx file:///readme.htm




Using DosLynx

   DosLynx is a straightforward menu driven application.

   A user has several ways to activate the DosLynx menu; pressing F10,
   pressing ALT and one of the highlighted menu letters, and by a single
   left button mouse click.

   Following are a listing of all menu items and their functionality. Menu
   titles and the appropriate menu choice are presented side by side with
   the '|' character as a separator.



   File|Open URL
	  Allows you to enter a user specified URL. Once 
	  entered, DosLynx will attempt to load the URL. 

   File|Open Local
	  Allows you to select a local file from an 
	  available DOS path. DosLynx will convert the file name into 
	  a URL and attempt to load the file. 

   File|Close
	  When this menu item is selected, DosLynx will close 
	  the currently active window so that it is no longer viewable 
	  on your display. 

   File|Save Rendering
	  When selected, DosLynx will prompt you 
	  for a local file name in which to save the document in the
	  currently 
	  active window as ASCII text exactly as seen on your display. 

   File|Print Rendering
	  When selected, DosLynx will prompt you 
	  for a DOS device to which to print the rendering. The appropriate

	  DOS device to enter is the one to which your line printer is 
	  connected, such as LPT1. 

   File|Dos Shell
	  DosLynx spawns your command interpreter so that 
	  you may take action outside of DosLynx while it is still 
	  running. After selecting this item, you should always exit 
	  the command interpreter and return to DosLynx after you are 
	  finished. 

   File|Exit
	  This will cause the DosLynx application to exit 
	  therefore ending your session inside DosLynx. 

   Navigate|Find
	  Allows you to enter a search string that 
	  DosLynx will find in your currently active window. 

   Navigate|Find Again
	  DosLynx will again find the last 
	  entered search string from the find command. 

   Navigate|Next Anchor
	  This will move you to the next selectable 
	  anchor in the active window. 

   Navigate|Previous Anchor
	  This will move you to the previous 
	  selectable anchor in the active window. 

   Navigate|Activate Anchor
	  This will cause DosLynx to attempt to 
	  load the destination URL of the currently active anchor. 

   Navigate|Prior Document
	  This will cause DosLynx to attempt to 
	  load the last visited URL in the currently active window. 

   Navigate|Search Index
	  Some loaded documents are searchable 
	  indexes. To cause DosLynx to search the index of the currently 
	  active window, select this command. This command will not 
	  be active if the window contains no searchable index. 

   Navigate|Show Destination URL
	  Select this if you desire to 
	  view the URL of the currently active anchor. 

   Options|Toggle Low/High Text Mode
	  Allows you to switch back 
	  and forth between the default 25 line text mode and the 43 or 
	  50 line text mode of EGA or VGA video adapters. 

   Window|Messages
	  This will cause the window containing all 
	  DosLynx message to appear as the active window. 

   Window|Clone Window
	  Use this if you wish to create a duplicate 
	  of the currently active window. The window should be the 
	  same in every respect except for window number and size. 

   Window|Zoom
	  Use this command to switch a window to its maximum 
	  possible size and its previous size before Zoom. 

   Window|Cascade
	  Use this command to organize all open windows 
	  in a cascading arrangement on your display. 

   Window|Tile
	  Use this command to organize all open windows 
	  in a tiled arrangement on your display. 

   Hotlist|View
	  This command causes DosLynx to load the user 
	  specified HotList file for easy access to anchors which you 
	  speicify. 

   Hotlist|Add current to Hotlist
	  This command will add the URL 
	  of the currently active window to your hotlist file and then 
	  prompt you for a name by which to remember the URL. 

   Hotlist|Home Page
	  Use this command to open a new window with 
	  the user specified home page loaded within. 

   Help|About DosLynx
	  Miscellaneous information regarding DosLynx. 

   Help|Mail Developer
	  Use this command to send a suggestion or 
	  bug report to the developer of DosLynx if you are connected 
	  to a network. 


   DosLynx also has many other ways of obtaining user input.

   All hotkey equivalents are listed beside the menu choices while running
   DosLynx.

   In addition to the listed keys, you can use the UNIX vi keys (HJKL) or
   your numeric keypad with your number lock on for anchor navigation. This
   differs from the 0.7a release of DosLynx that allowed the user to use
   the Lynx arrow keys for anchor navigation which is no longer supported
   as the arrow keys are reserved for scrolling only.

   Page up, page down, the arrow keys, and the space bar allow you to look
   through a document that is longer than your display itself. Further, if
   you utilize a mouse with DosLynx, you can select an anchor by using a
   single left button click, and activate an anchor by using a double left
   button click. A special case arises when attempting to select an inline
   image which also is has a destination; see the Special Notes section.

   Items contained in the status bar (the bottom line of your screen while
   running DosLynx) correlate directly with items in the navigate menu
   which are selectable by the mouse only. In addition, the right mouse
   button is the same as issuing the Window|Clone Window command.



Special Notes on Usage

   As of the DosLynx v0.8a release, only the following URL types are
   supported: 


	file
	ftp
	gopher
	http
	news
	wais


   If you notice extremely poor system performace, such as the hard drive
   being continually accessed, install a disk cache such as SMARTDRV.

   When attempting to select an inline image with a mouse, it may not work
   as you expect. Some inline images also have destinations, in which case
   you will be taken to that destination. Use the keyboard to specifically
   select an inline image which also has a destination.

   For the best DosLynx performance, specify the temporary file directory
   in your configuration file or on the command line to be a directory on a
   RAMDRIVE. See your DOS documentation for setting up a RAMDRIVE specific
   to your system.

   DosLynx is a MDI (multiple document interface) application. This may
   confuse new users that are used to other World Wide Web clients. As a
   rule of thumb, when you open any URL or document through DosLynx's menu
   or equivalent hotkeys, then it will exists in it's very own window.
   Windows are numbered in their upper right corner and you can switch
   between windows by pressing the ALT key and the window number
   simultaneously.

   Each window represents an open file at any given time. If you open more
   windows than you have FILES specified in your CONFIG.SYS file then
   DosLynx may crash. Increase the number of open files your machine can
   have if you plan to use multiple windows a lot.

   When DosLynx has used most of your computer's memory attempting to use
   the File|Dos Shell command will not work. Your computer simply does not
   have enough memory to execute your command interpretor.

   When you ftp a file or activate an anchor that DosLynx cannot display as
   text, you are asked to give a file name to save the information in; a
   filename is now suggested by DosLynx. These files are not removed by
   DosLynx when you exit the application. This allows you as the user to do
   what you will with such files after exiting DosLynx. If you are prompted
   to save a file that is already on your hard drive (such as a local
   image) do not use the same name in the same directory. This option is
   being left in since some users may wish to use DosLynx on a LAN and copy
   the selected files to their workstation's hard drive.

   DosLynx has been known to crash when it encounters a file containing a
   large number of selectable anchors in it. This is due to an unavoidable
   memory limitation. Large files with few anchors will be loaded fine.
   Future releases of DosLynx will address this problem in a more stable
   manner.

   When DosLynx terminates unexpectedly, the temporary files it creates
   remain in the temporary file directory you specified in the
   configuration file or on the command line. The temporary files follow
   the pattern of DLX*.$$$. You will have to remove these files yourself if
   this occurs. As DosLynx is improved upon you can expect it to become a
   more stable application and prevent you from having to worry about this
   temporary file problem.

   If you are wondering, the menu bar contains the current time in the
   upper right had corner. In the status bar are three numbers in the lower
   right corner. The numbers are from left to right the current network
   activity in bytes, the size in bytes of the temporary drive you
   specified, and the amount of available heap memory in bytes. These were
   originally run-time debugging tools for the developer of DosLynx but
   were left in as they are harmless and give the user some information of
   what is currently happening when DosLynx is at work. They can be turned
   off with the /B command line option.

   If your computer does not use a packet driver, which DosLynx requires,
   to access the network, ask your local network administrator if there is
   a packet emulator available for your particular workstation
   configuration. For instance, if your computer utilizes an ODI driver for
   network access, in order to use DosLynx you will need to install the a
   packet driver emulator if one is available to you.

   Once one program is utilizing your computer's packet driver, like
   DosLynx, no other program may do so at the same time. If you have need
   to run more than one packet driver utilizing program at the same time,
   we suggest asking your local network administrator if your computer can
   be configured to use a packet multiplexor. If so, you will need to find
   a suitable packet multiplexor and install it on your computer.

   To correctly view the ISO Latin I characters supported by HTML, you must
   configure DOS to use multilingual code page of 850. Consult your DOS
   manuals on how to specify the appropriate code page for your computer.

   To force DosLynx into a supported black and white video mode, type "mode
   BW80" at your DOS prompt. Consider doing this if you monitor is black
   and white but DosLynx considers it a color monitor (monochrome EGA
   monitors).

   If you are interested in registering with the DosLynx development
   listserv group, send a mail message to listserv@ukanaix.cc.ukans.edu.
   Please do not send subscribe requests to the doslynx-dev list directly.
   In the body of the message, send only the following information where
   username@node is your internet mailing address: 


		subscribe doslynx-dev Your Name Here


   Remember that this version of DosLynx is an alpha and has been released
   as a feedback tool only. Expect problems, and when you encounter one
   please mail the developer at the following address and inform the
   creator of the problem you encountered and your system configuration.


    lynx-bug@falcon.cc.ukans.edu



New DosLynx Features

   The following new features were added in this release of DosLynx:    

   Inline Images
	  DosLynx can now download any inline image and 
	  display inline GIFs. 

   Blind Support
	  The /B command line option was implemented to 
	  aid blind users using DosLynx with a screen reader. 

   Mail Developer
	  The mail developer command now takes much less 
	  time to send the message you enter, and no longer hangs your 
	  computer. 

   Local GIFs
	  Local GIFs will now load correctly. 

   Suggested Filenames
	  DosLynx will now suggest a 
	  filename when prompting the user to save a file. 




Distributing DosLynx

   You may distribute DosLynx version 0.8 alpha at your convenience so long
   that you distribute the orignal self-extracting archive obtained by the
   means listed in the Obtaining DosLynx section of this document.



Credits

   The University of Kansas would like to thank the following organizations
   and people for their aid in the creation of DosLynx. 


	Generous financial assistance given by O'Reilly and Associates
		and Intel Corporation.
	Fundamental GIF display routines by David Koblas
	GIF support and dithering routines by Thomas Boutell
	World Wide Web Source Library by CERN
	Waterloo TCP by Erick Engelke
	FTP code from James W. Matthews, Dartmouth Software Development
	Borland C/C++ and TurboVision by Borland International


   Further, The University by Kansas recognizes the following:  

   Borland C/C++ and TurboVision
	  Trademarks of and Copyright by Borland International. 

   World Wide Web Source Library
	  Copyright by CERN, Geneva, Switzeralnd. 

   Waterloo TCP Library
	  Copyright by Erick Engelke. 

   FTP code
	  Portions Copyright 1994 Trustees by Dartmouth College. 

   GIF display routines
	  Copyright by David Koblas along with the following notice: 



/* +-------------------------------------------------------------------+ */
/* | Copyright 1990, David Koblas.                                     | */
/* |   Permission to use, copy, modify, and distribute this software   | */
/* |   and its documentation for any purpose and without fee is hereby | */
/* |   granted, provided that the above copyright notice appear in all | */
/* |   copies and that both that copyright notice and this permission  | */
/* |   notice appear in supporting documentation.  This software is    | */
/* |   provided "as is" without express or implied warranty.           | */
/* +-------------------------------------------------------------------+ */


   Last Modified: 08-11-94 by Garrett Arch Blythe

   Report errors to the following address:


    lynx-bug@ukanaix.cc.ukans.edu

   Request help from the following address:


    lynx-help@ukanaix.cc.ukans.edu


