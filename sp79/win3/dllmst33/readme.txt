Thank you for trying DLL Master.  We hope you will find it a
useful Windows tool.

DLL Master lists all modules currently loaded in Windows' 
memory, and allows you to load, unload, or decrement the use 
count of DLLs--at your own risk, of course.  Module path, 
datetime, filesize and internal version and header info are 
shown; multiple lists are kept, lists can be compared, 
printed, saved to and restored from disk. Specific DLLs can 
also be loaded at Windows' startup. Requires Windows 3.1 or
later.

DLL Master is a shareware program written in Visual Basic, 
and as such requires the VB 3.0 runtime module VBRUN300.DLL 
as well as certain other modules in order to run. Since these 
files take up a lot of space and increase download time, the 
large VBRUN300.DLL is not included in the shareware version. 
VBRUN300.DLL is available on many bulletin boards including 
Compuserve. If you can't get hold of it send us $3.00 for 
shipping/handling and we'll send it to you.

The registered version of DLL Master, DLLMSTRG.ZIP, contains 
all the necessary files, since it is normally provided on 
disk by mail.


TO INSTALL DLL MASTER FROM DLLMSTSW.ZIP:

This zipfile contains only the program, helpfile, supporting DLL
and some accompanying text files. It does not contain VBRUN300.DLL,
GRID.VBX, THREED.VBX, CMDIALOG.VBX or COMMDLG.DLL, which are 
required for running DLL Master. If you are reading this README file 
having unzipped it from DLLMSTSW.ZIP, you have already completed the
installation. Just run DLL Master from the File/Run menu or set
up an icon for it.

DLL Master was compiled in the presence of the following VBX versions:

        THREED   VBX     64432 07-16-93   3:28p
        CMDIALOG VBX     18688 04-28-93  12:00a
        GRID     VBX     44656 04-28-93  12:00a

Older versions of THREED.VBX in particular can cause problems. If
you experience problems which you think might be caused by outdated
DLLs or VBXs, download DLLMST33.ZIP, which contains adequate
versions of all needed files.  DLLMST33.ZIP can be found on
Compuserve.


TO INSTALL DLL MASTER FROM DLLMST33.ZIP or DLLMSTRG.ZIP:

1) Create a temporary directory on your hard disk. For example:
        
        md c:\dllmtemp

2) Using PKUNZIP, unzip DLLMST33.ZIP or DLLMSTRG.ZIP into the new 
   directory. For example:

        pkunzip a:dllmst33 c:\dllmtemp

3) Go into Windows, select the File/Run menu, and run SETUP:

        c:\dllmtemp\setup.exe

   Setup will properly install DLL Master as a Windows application,
   into the directory of your choice. After this has been done you 
   may delete the temporary directory and its contents.


WHAT TO DO IF SETUP CANNOT INSTALL A FILE:

Sometimes the SETUP program cannot install a newer version of a DLL 
or other module because an existing version of the module is in use 
and Windows will not allow it to be overlaid. In this case, you will 
want to install the module manually. Here are the steps to do this:

1) Exit from Windows.

2) Use the EXPAND utility to decompress the file from the temporary
   directory. The compressed version of the file has an underscore 
   as the last character of the extension. For example, THREED.VBX 
   will appear as THREED.VB_. (In fact, THREED.VBX may very well 
   be in use when you run install DLL Master.) In this example, you
   would expand the file by running the following command from the 
   DOS prompt:

        expand c:\dlltemp\threed.vb_ \windows\system\threed.vbx

   The various file extensions are transformed as follows: any VB_ 
   extension becomes VBX, DL_ becomes DLL, EX_ becomes EXE, etc.
   
   EXPAND.EXE should exist on your system in both the \WINDOWS and
   \DOS directories.
   
3) Verify that the new version was indeed expanded and copied, and
   then restart Windows.


Please contact us if you have any questions, problems or suggestions
for improvements to DLL Master. We also request that you register
your copy if you find yourself continuing to use DLL Master (please
read the Registration topic in the Help file or LICENSE.TXT).


KNOWN ISSUES AND INCOMPATIBILITIES:

THREED.VBX, a module used by DLL Master, underwent several revisions 
in 1993.  Also, a separate version was apparently included with certain 
versions of printer software accompanying laser printers from a very 
excellent company which shall remain nameless. Which one is the "right"
one? We don't know. If, when the mouse pointer rests on one of the 
toolbar icons for over half a second, a yellow 'tool tip' or help 
balloon does not pop up just beneath the pointer, then you probably 
have a version of THREED.VBX on your machine which is slightly 
incompatible with the one used when DLL Master was compiled. Another 
symptom is that the toolbar and the logo that displays at startup are 
white instead of gray. You can download the most current version of 
THREED.VBX from Compuserve ('GO SHERIDAN').  DLL Master 3.2 ships
with the 7/16/93 version (filesize 64432, internal version 3.0.1).

If you display version information for CPQHQV08.EXE version 3.10.00  
(this is a Compaq QVision display driver), the Language combo will
list 8 languages.  However, no matter which one you select, the 
string file information still displays in English. This is not a
DLL Master bug. The version resource inside CPQHQV08.EXE actually
contains a subsection for each of the languages--all identical, all
in English.

(DLL Master is a trademark of Shaftel Software. Windows and Visual
Basic are trademarks of Microsoft Corporation.)
