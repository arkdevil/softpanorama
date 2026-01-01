
Thank you for your interest in Source View V3.2c.  This file
is the latest addendum for the current release.

1. What's new in Source View V3.2c?

   1a. Undo/Redo feature is available now. The depth of undo
       is limited only by the amount  of  free  conventional
       memory.

   1b. Auto UNIX/DOS text format sensing.

   1c. There is no confirmation  on  Delete Block [Ctrl K Y]
       when undo is enabled.

   1d. [Ctrl U] is now assigned to Undo,  and [Ctrl Q L]  is
       assigned to Undelete Line ([Ctrl U] in V3.1).

   1e. The Restore Line ([Ctrl Q L] in V3.1) is obsolete.

2. Even though a lot of the  features  in  Source  View  are
   designed for programmers, you  can  also  use  it  as  an
   advance text  editor.  Another  good  way  of  using  the
   editing power of Source  View  is  software  integration.
   Many  programs  allow  users  to  designate   an   editor
   replacement. For example:

   2a. The 1Word editor in XTGOLD can edit only one file  no
       larger than 64K.  You can designate  Source  View  as
       a replacement in the  configuration  (Alt-F10)  under
       item "Editor program:".

   2b. The  PCEdit  in  ProComm  Plus  also  has  the   same
       limitation and can be  replaced  by  Source  View  in
       SETUP UTILITY (Alt-S) under item  FILE/PATH  Options.
       The QLEdit in QuickLink II/Fax can be replaced  in  a
       similar manner.

   2c. The default editor  in  FoxPro  can  be  replaced  by
       adding the following line to CONFIG.FP:
       
	 TEDIT = /0 SV.COM
 
3. You might know the SysEdit program in Windows  3.1  which
   automatically opens the four system  files  for  DOS  and
   Windows.  Here is a tip on how you can do it in DOS  with
   Source View:

   3a. Create a one-line batch file SYSED.BAT as follows:
 
	 @SV C:\WINDOWS\SYSTEM.INI C:\WINDOWS\WIN.INI C:\AUTOEXEC.BAT C:\CONFIG.SYS
 
   3b. Place both  SYSED.BAT  and  SV.COM  in  one  of  your
       directories included in your PATH.
       
   3c. At any DOS prompt, type SYSED <CR>.

4. All Source View opened files  must  fit  in  conventional
   memory.  Therefore, the total size of all open files  can
   not exceed 640K.  The maximum number  of  open  files  is
   only subject to memory availability.

   Source View works fine in the DOS Window of Windows  3.x.
   Further, the Paste function in the system menu (Edit)  of
   the DOS Window also works well, provided that the  Indent
   Mode must be turned off to allow correct  pasting.  Using
   this function, the Source View  Editor  can  receive  any
   text contents from the Windows clipboard.

5. A number of bugs in V3.1k, V3.2a and V3.2c were fixed:

   5a. When Find & Replace ALL forward, cursor does not stop
       at the end of the last replacement string.
   
   5b. Erase to End of Line  [Ctrl Q Y]  corrupts  files  if
       invoked beyond the end of the last line of the file.

   5c. If no extension or period is specified during  Rename
       Current File [Ctrl O N], Read Block from File [Ctrl K
       R] and Save File as [Ctrl K A], system crashes.
   
   5d. If the default extensions specified in Setup does not
       end with an semi-colon, the editor fails  to  a  open
       file with no extension when period is not specified.
   
   5e. In some  cases,  the  editor  fails  to  display  the
       current  file  properly  after  a  inter-file  string
       replace ([Ctrl Q A] with the "I" option).

6. Since the first shareware version (V3.0i) of Source  View
   published in 1993,  the  response  I  received  has  been
   minimum.  It is obvious to me that the golden age of  DOS
   text mode software has come  and  gone.  I  have  decided
   that V3.2x is the last version of Source View for DOS.

   A 16-bit version of Source View for Windows is  currently
   under development.  It is written in C++, and I  plan  to
   offer it in two parts: one is the Source View Editor Core
   which includes all editing functions in  DLL  or  OBJ/LIB
   form, along with complete documentations; the second part
   is the front end GUI based on  the  Microsoft  Foundation
   Class V2.x, complete with all source code and  resources.
   A 32-bit version is will also be developed  when  Windows
   95 is available.

   I have selected the SimTel  Software  Repository  as  the
   primary release site for current and future  versions  of
   Source View.  Other shareware publishing channels that  I
   use include PC-SIG Library and JCS Marketing  (now  owned
   by OWOBOPTE Industries, Inc.).

	Publisher:	SimTel Software Repository
	FTP site:	oak.oakland.edu (anonymous)
	Directory:	SimTel/msdos/editor
	File name:	sv32e.zip

	Publisher:	PC-SIG Library
	Address:	1030 D East Duane Ave.
			Sunnyvale, CA. 94086-2600
	Phone:		(408)730-9291
	Fax:		(408)730-2107

	Publisher:	JCSM Shareware Collection
	Address:	OWOBOPTE Industries Inc.
			3101 Sibley Memorial Hwy.
			Eagan, MN. 55121
	Phone:		(612)686-0405
	Fax:		(612)686-0312

   If you have any feedback, feel free to write  to  me  via
   internet "wchen@neptune.calstatela.edu", or by mail:

	Michael W. Chen
	11309 Elmcrest Street
	El Monte, CA. 91732
