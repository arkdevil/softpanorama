:userdoc.
:title.'System Resources' Help
:body.

:h1 res=1.Introduction
:i1.Introduction
:artwork name='memsize.bmp' align=center.
:p.
This program displays several items related to system resources,
and updates the display once per second, providing it is given
CPU time to do so.  The items displayed are:
:p.
:hp2.Date/Time:ehp2. - The current date and time, in the format called for
in the default country information for your system, as specified in
the COUNTRY= entry of your CONFIG.SYS file.
:p.
:hp2.Elapsed Time:ehp2. - The elapsed time since the computer
was last restarted.
:p.
:hp2.Available Memory:ehp2. - The amount of virtual memory
available, according to the :hp1.DosQuerySysInfo:ehp1. function,
less the available swap space.  This is the sum of the free space
in memory and the free space within the swap file, and I have not
been able to find a way to separate the two yet.
:p.
:hp2.Swap File Size:ehp2. - The current size of the system
virtual memory swap file, SWAPPER.DAT.
To locate the file, the file CONFIG.SYS is scanned for its SWAPPATH entry.
That entry provides the full name of the swap-file's directory and
indicates the minimum free space that must be left on the swap-file's
disk drive.
:p.
:hp2.Available Swap Space:ehp2. - The amount of free disk space on the
logical disk drive where the system swap file resides, less the mininum
free space.  This is how much more the swap file could expand, if necessary.
:p.
:hp2.Spool File Size:ehp2. - The amount of disk space consumed by spool files.
:p.
:hp2.CPU Load (%):ehp2. - The approximate percentage of the CPU's available
horsepower that's being used at the moment.  It is averaged over the previous
second.
:note.This function and PULSE do not get along with each other.
:p.
:hp2.Active Task Count:ehp2. - The number of entries in the system switch list,
which is the list displayed when you press CTRL+ESC.
:note.Not all entries in the system switch list are displayed in the
Window List.  Some are marked for non-display.
:p.
:hp2.Total Free Disk Space:ehp2. - The amount of free space on all the
non-removable disks combined.
:p.
:hp2.Drive X Free:ehp2. - The amount of free space on drive X.
:p.
The help facility is active, as you've already seen, and those program
commands that exist may be accessed via the window's system menu.  The
following commands are available:
:sl compact.
:li.:hpt.Save Defaults:ehpt.:hdref res=11.
:li.:hpt.Reset Defaults:ehpt.:hdref res=12.
:li.:hpt.Hide Controls:ehpt.:hdref res=13.
:li.:hpt.Configure...:ehpt.:hdref res=14.
:li.:hpt.About:ehpt.:hdref res=15.
:esl.:p.
In addition to those features already described, this program accepts
commands from the OS/2 2.0 Font and Color Palette programs.

:h1 res=11.Save Defaults (Menu Option)
:i1.Save Defaults (Menu Option)
When you select this menu option, the program saves its current position
and the status of the Hide Controls option.  The next time the program
is started, it will be started with that position and with the controls
hidden (or not) according to the saved state.
:p.
The short-cut key for this command is F2.

:h1 res=12.Reset Defaults (Menu Option)
:i1.Reset Defaults (Menu Option)
Selecting this menu option will reset the program's font and color
attributes to their default values.

:h1 res=13.Hide Controls (Menu Option)
:i1.Hide Controls (Menu Option)
This menu option, when selected, will cause the program's frame controls
(the system menu, the titlebar and the minimize button) to be hidden.
This option can be toggled with a double-click on either mouse button.
Also, since I saw it as very useful to be able to move the window while
the controls were hidden, the window has been set up so that you can
drag it with either mouse button.
:p.
The key combination Alt+H will perform this function also.

:h1 res=14.Configure... (Menu Option)
:i1.Configure... (Menu Option)
This menu option, when selected, will cause the program's Configure dialog
to be displayed.
:p.
The key combination Alt+C will perform this function also.

:h1 res=140.Configure... (Dialog)
:i1.Configure... (Dialog)
This dialog box displays the list of available display items and allows
you to select which ones will be included in the program window.
Also, the program's Hide Controls option and Float-to-Top option can
each be set on or off here.
Finally, the program's window refresh interval can be viewed and
altered here.
:p.
Make the changes you wish, then press the ENTER key or click on the OK
button to cause them to take effect.
:p.
To abort the dialog without saving whatever changes may have been made,
press the ESC key or click on the ESCAPE button with the mouse.

:h1 res=15.About (Menu Option)
:i1.About (Menu Option)
This menu option, when selected, will cause the program's About dialog
to be displayed.

:h1 res=150.About (Dialog)
:i1.About (Dialog)
This dialog box displays the program name, icon and copyright information.
To exit the dialog, press the ENTER key, the SPACE bar or the ESCAPE key,
or click on the OK button with the mouse.

:h1 res=99.Keys Help
:i1.Keys Help
The following function keys have been defined for this program:
:sl compact.
:li.F1 - Help
:li.F2 - Save Defaults
:li.F3 - Exit
:li.Alt+H - Hide Controls
:esl.:p.

:h1 res=9900.Set Profile Path (Dialog)
:i1.Set Profile Path (Dialog)
This dialog is displayed when the program cannot find its profile (INI) file,
and asks you where the file is or where it is to be created.
:p.
Only a valid existing directory name will be accepted.
Once you have entered the name, press the ENTER key or click on the OK
button for the program to continue.
:p.
If you wish to abort the program's initialization sequence, press
the ESC key or click on the escape button.

:euserdoc.





