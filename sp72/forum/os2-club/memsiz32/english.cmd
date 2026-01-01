/* ENGLISH.CMD: Install MEMSIZE in English. */

'@Echo Off'

/* Load REXXUTIL */

Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
Call SysLoadFuncs


/* Initialize */
 
Signal On Failure Name FAILURE
Signal On Halt Name HALT
Signal On Syntax Name SYNTAX

Call SysCls
Say 'Installing MEMSIZE...'
Say ''


/* Verify the existence of the various component files. */

Language = 'ENGLISH'

Result = SysFileTree( 'MEMSIZE.EXE', 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'ERROR: MEMSIZE.EXE not found!'
  Signal DONE
  End

Result = SysFileTree( Language".DLL", 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'ERROR: 'Language'.DLL not found!'
  Signal DONE
  End

Result = SysFileTree( Language".HLP", 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'ERROR: 'Language'.HLP not found!'
  Signal DONE
  End

/* Ask for the target directory name. */
 
Say 'Please enter the full name of the directory to which'
Say '  you want MEMSIZE installed (default C:\OS2\APPS): '
Pull Directory
If Directory = "" Then Directory = 'C:\OS2\APPS'


/* Create the target directory if necessary. */

Result = SysFileTree( Directory, 'Dirs', 'D' )
If Dirs.0 = 0 Then
  Do
  Result = SysMkDir( Directory )
  if Result == 0 Then
    Do
    End
  Else
    Do
    Say 'ERROR: Unable to create target directory.'
    Signal DONE
    End
  End
Say ''


/* Ask for the target folder. */

Say 'Do you wish to install to the startup folder? (Y/N)'
Pull YesNo
If YesNo = "Y" Then
  Do
  Folder = '<WP_START>'
  Say 'Object will be placed in the startup folder.'
  End
Else
  Do
  Folder = '<WP_DESKTOP>'
  Say 'Object will be placed on the desktop.'
  End
Say ''


/* Perform the installation. */

Say 'Copying MEMSIZE to ' Directory '...'
Copy MEMSIZE.EXE Directory		    '1>NUL'
Copy Language".DLL" Directory"\MEMSIZE.DLL" '1>NUL'
Copy Language".HLP" Directory"\MEMSIZE.HLP" '1>NUL'

Say 'Creating program object...'
Type = 'WPProgram'
Title = 'System Resources'
Parms = 'MINWIN=DESKTOP;PROGTYPE=PM;EXENAME='Directory'\MEMSIZE.EXE;STARTUPDIR='Directory';OBJECTID=<MEMSIZE>;NOPRINT=YES;'
Result = SysCreateObject( Type, Title, Folder, Parms, 'ReplaceIfExists' )
 
If Result = 1 Then
  Say 'Object created!  Done.'
Else             
  Say 'ERROR: Object not created.'

Signal DONE

FAILURE:
Say 'REXX failure.'
Signal DONE

HALT:
Say 'REXX halt.'
Signal DONE

SYNTAX:
Say 'REXX syntax error.'
Signal DONE

DONE:
Exit
