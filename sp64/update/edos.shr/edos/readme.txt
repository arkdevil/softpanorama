                            R E A D M E . T X T
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    This version of EDOS V3.65d.

A BBS, where you can download updated files. See below.

New support for setting the title in a Windowed Dos Session.
A "ETITLE" command that accepts a string argument in double quotes.
Also, by default a unique number is added to the title each time
a DOS session is started.

The KILL.BAT file should be run FROM the edos directory,
if you already had EDOS installed. Also, the path's may not be correct
for the 704k and 736k sessions(not likely).

ALL files from the install, are put in the EDOS subdirectory, not the
Windows directory, where possible.

Fixes for problems with 736k oversize sessions. More help, more diagnostics.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We have a electronic bulletin board (BBS) where you can call to 
download updated files. The phone number is: 503-643-8396. It is normally
working from 9 PM to Noon the next day, Pacific Time. Sometimes it is
on 24 hours a day. This phone number is only a temporary number and
may be changed in the future with little notice. We are presently sharing
this number, as soon as possible it will be changed or supplemented with
a permanent number. Until further notice, meaning here or on the BBS,
do not expect to be able to leave messages and expect to recieve a timely
response. I do not log on to it more than once or twice a week.
The BBS is only for downloads, at this time. Sorry.

See the advanced.txt file for more advanced information, on IRQ's
and other esoteric subjects.

Tested but not thoroughly with Windows for Workgroups.

You can load TSR's in a single DOS session. Like CDROM support
programs(MSCDEX) or FAX support TSR's.

We are experimenting with a loader that will load
real mode device drivers, the kind you ordinarily load in config.sys, but
instead can load at the command line in a single DOS session. Using these
methods save precious space in the lower 640k. Or, if you need these drivers
or TSR's only in Windows programs, put the TSR's in WinStart.BAT.

For more details concerning the loading of device drivers contact EDOS
tech support.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
NETWORKS:


If you installed Windows using "SETUP /N", then edos may not install 
correctly. If you encounter any difficulty please let me know as soon
as possible.

Network installations are not generally a problem. But a few people have
had difficulty. Don't be bashful, if you do, give me call or send E-Mail.

Be sure to use the wstacks.exe program to change the stack for DOS sessions
if using a NETWORK. (Stacksiz.exe can be used if DOS is running).

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Features not documented in documentation:

EDOS no longer has a hidden DOS session.
This saves about 150k of extended memory, when Windows is running.

ETITLE command, sets a new title in the caption of the windowed DOS session.
ETITLE  "This is a new title", puts the quoted string in the Window caption.

"UniqueTitle=1", 
This feature assigns a unique number to a DOS session.
The feature is enabled/disabled by this switch and it goes in the
EDOS.INI file.

The View Menu item as a new item: Always On Top. Setting this feature
forces Windows to keep the DOS session on top, even when not active.

There is a new DIAGNOSTICS menu item. You can now check the stack usage,
state of the display drivers and some special state information about DOS
using this new menu item.


###########################

Mistakes in documentation:
WINPMT, see explanation at end of this file.
p. 2, EDOSLIB.EXE should be EDOSLIB.DLL
p. 16, the use of !DOSMEM!.COM should include /p or /x
p. 21
Status /V now prints out the id of the Virtual Machine that owns the com ports.

Status /y & /n turn on/off executing of Windows Apps from the DOS command
line.

P. 25. The "NOTE" about hidden DOS session is no longer valid.
p. 33, EDOSLIB.EXE should be EDOSLIB.DLL

p. 35, EDOSLIB.EXE, has been renamed to edoslib.DLL, and moved
to the EDOS subdirectory. ALL references to EDOSLIB.EXE in the
manual should be changed to read EDOSLIB.DLL.


p. 36, Section at bottom of page, starts: "B:\EDOS",
should read: "B:\"

p. 36, EDOS.INI is installed in the windows\EDOS subdirectory.
p. 38, EDOS.INI section, should read edos.ini IS INSTALLED.


P. 41. EDOSTEMP.COM is no longer on the diskette.
P. 43. EDOSTEMP.COM & ESOTEMP.PIF, section is no longer valid.


  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!!!!!!!!!!!!!!!!!!!!!!!!!!!
LAST SECOND CHANGES ! ! ! ! ! 

DR DOS has a fix to their command.com that
WILL work with EDOS. Contact EDOS or DRDOS tech support for further
information. The file is dated about 8-4-92.


-----------------------------------------
If you have ANY technical problems involving DOS/Windows intereactions,
or desire a feature that involves this environment, then by all means
give EDOS Tech Support a call. Users who make suggestions are listened to
and occassionally receive exactly what they want. Sooner or later!
The feature set in EDOS is NOT STATIC and is influenced heavily by user
requests.

Here follows a couple of topics that we are presently considering:

1. An editing tool to add comments onto PIF files(DONE !, in new EPIFEDITor).
2. Graphics screen print capability, ala DOS with graphics.com
installed, when Windows is the screen.

3. Better support for DOS communications programs.
4. Pop up help and status in full-screen sessions.
__________________________________________




Note: There is a bug in Windows 3.1 in that
672 bytes of memory is not freed after you run a dos session. This problem
is cumulative such that starting 5 dos sessions and closing them
will result in 5*672 bytes not being freed. Eventually you could run
out of free memory, We suggest that you not open and close more than
about 500 dos sessions without closing Windows and restarting it.
This bug is NOT in EDOS. We hope that you find this amusing!
This bug is fixed in V3.01b of EDOS.

If closing all DOS sessions will free the memory.


There is a bug in VBRUN100.DLL, the vbrun200.dll is ok. VBRUN is a
support library for Visual Basic.


If you use the PRINT command in a DOS session, be carefull about exiting
and killing the session before the print job is completed. The print job
will terminate along with the session. This is NOT an EDOS problem. But
it will be fixed.

By the way, EDOSLIB.DLL is now compiled using a real 386 code generating
compiler. It contains real 386 code instruction sequences. Makes it a
little bit faster.

\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Known problems:

Closing a DOS session that has an ALARM pending, will generate no
warning message. The alarm will be discarded.

PS/1 & PS/2 and other micro-channel machines often have a data space called
the "EBIOS" (extended bios). If this is mapped at 9f00:0000 then you will
not be able to use the 704k or 736k DOS session feature. This is being 
looked into.

           In an oversize DOS session:
If the screen lines are changed, say to 50
from 25 when a DOS application starts and reset back to 25 when
it exits, sometimes the font does not get reset. The fix is to:
"mode CO80". Also, sometimes "exit" won't exit the DOS session. Do
it a second time or use Alt-F4. This is being worked on.
The 50/25 line menu items DO NOT work, if the session is oversize. But
the menu items are not grayed out. The graying will be fixed, if the
support can not be implemented.

&&&&&&&&&&&&&&&&&&&&
Windows Bugs.


The Windows PIFEDIT.EXE program has a bug, which SHOULD be harmless, but
may not be. With the Windows Debug Kernels installed, start Windows.
Start the pif editor, start a DOS Windowed session, start a second copy
of pifedit, change the mouse and keyboard focus by clicking on the DOS
session. GetClientRect near offset 0:80 in the pif editor will fail with
an invalid (NULL) window handle. This may not be the only bug or way in
which to generate the error. Be careful. There is no known workaround.

Windows has a bug which will crash windows and hang your machine.
 The bug can be shown by, create a pif file, using command.com as
 the command. Use "/P" as the optional argument. Run the pif file.
 Use the "MEM" command or any similar program that walks the memory
 arena blocks. Windows will crash. The culprit is the "/P" optional
 argument. So... Beware. Don't make this mistake when creating a PIF file.

Windows sometimes resets the keyboard repeat rate, and then fails
to reset it upon exit. If you have trouble with a too fast repeat
rate when exiting Windows contact EDOS tech support. We are working
on a fix.

EDOS "ERROR #1050" or "ERROR Class TTY not found" indicate severe errors
during the startup phase of Windows and EDOS. If you see these errors
it means that some device driver or applications program is defective and
causing problems during the startup phase. The fix is to isolate the 
offending application and contact the maker of the software. Problems of
this type can be caused or made worse by a bug in Windows itself.
Contact EDOS tech support for details if necessary.

--------------------------------------------------
There are several new SYSTEM.INI switches intended for tracking down bugs
in Windows. These switches are not documented in the manual or
here. But are available if you need technical support. Our technical support
is very good. I ought to know, I am the support. See instructions at end
of this file.


The 50 and 25 line menu items do not change lines correctly with all
VGA display adapters. In addition, they are dumb screen switchers similar
to "MODE CON: lines=50". Because of this changing screen lines does not
always result in a screen "that will make you burst with pride". This
will be improved in a future verion, IF POSSIBLE.


######################################################

EDOS contains an interface for DOS programmers to call. 

There are 3 calls supported at the present time.

1. A version call.
2. A way to call the alarm feature, with custom message.
3. A way to execute a Windows application, from a DOS app.
4. A way to change priorities, background & exclusive.

(some simple DDE support is being added.)
 
For detailed information contact EDOS technical support.


There is a test program on the floppy called testv86.asm and .com
that demonstrates the alarm feature.

Also tstwinex.asm and .com demonstrates how to execute a 
Windows application from a DOS app.


--------------------------------------------------------------------

NOTE: share violations responded to with FAIL, will display the file name!!
of the file that is the subject of the fail, VERY useful!

There is a subdirectory on the DISKETTE which contains files
of information about SHARE.EXE. These are located in the SHARE subdirectory.
Trust you will find the information useful.
++++++++++++++++++++++++++WARNING ! +++++++++++++++++++++++++++++++

Windows contains a bug situation that can occur at random: 
 
1. Attempting to switch a WINDOWED DOS session into 36/43/50/60 lines (also,
graphics) can cause corruption of the system. The code that is at fault is 
in the Virtual Display Driver(VDD).  

2. Not all VDD's are prone to this problem. 
3. The problem seems to happen only if paging is on and paging is under way.
(The pager is busy).  All of these conditions must be true for the problem 
to occur. 


4. It is VERY difficult to protect yourself from this.  
 
The suggested workaround is as follows: 
1. Use: Initial video mode = HiGraphics + Retain Video, in the PIF for
any session that you will switch to a higher screen line count. 

2. Both PIF settings MUST BE set or the corruption can occur. 


 
This "fix" will also protect you from applications that switch themselves into
50 line mode. This problem is NOT AN EDOS problem. The corruption can and
will occur regardless of how the session is switched into 50 line mode and
regardless of whether EDOS is installed or not. EDOS will warn you if the
PIF settings are not ok, before you attempt to use our menu items to make
the switch. Other applications WILL NOT warn.

The results of the corruption are not necessarily OBVIOUS! However, testing
using the debug kernels supplied with the SDK/DDK generates the following
errors: 

ERROR: Allocation failed, pager busy! 
ERROR: PageReallocate failed. 
Allocation failed for display plane 00. 
 
Symptoms can range from: none observable to complete crashes occurring
quite sometime after the switch is made. 


==================================
Note: twin DOS sessions, with dir *.* in a batch file loop, result in
screen dislocations WITH or WITHOUT edos.


#######################################################

Mike Maurice 8-28-93

Phones ----------------------

For ORDERS: 800-248-0809
            503-694-2282

For Tech Support and Information: 503-694-2221
Hours 10 am to 10 pm, Pacific Time.
Hours 1 pm to 1 am, Eastern Time.

E-Mail------------------------

Compuserve: 71171,47

Internet: 71171.47@COMPUSERVE.COM



WINPMT  !!!!

In order to conform to the method used by Win 3.1, EDOS was modified.

1. The EDOSPrompt system.ini switch has been dropped.

2. EDOS users may now have the DOS prompt set to THEIR way, in Windows
   3.1.

The method is as follows:
Use the DOS "SET" command to create an environment variable "WINPMT".
Like this:

SET WINPMT=$p$l

This will result in a prompt that looks like: C:\WINDOWS<
when you are in Windows in a DOS session.

The SET command should be installed in autoexec.bat, do not install 
it in WINSTART.BAT!


YOU may use any legal prompt string when setting WINPMT.
The DOS prompt will use your WINPMT string when Windows is running
in a DOS session and will return to the original PROMPT when Windows
exits back to plain DOS.


This trick will work in Win 3.1 with or without EDOS.

It is necessary to have both a PROMPT string and a WINPMT string for
this to work.







