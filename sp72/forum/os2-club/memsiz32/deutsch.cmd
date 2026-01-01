/* DEUTSCH.CMD: Installation von MEMSIZE in Deutsch. */

'@Echo Off'

/* REXXUTIL laden */

Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
Call SysLoadFuncs


/* Initialisieren */
 
Signal On Failure Name FAILURE
Signal On Halt Name HALT
Signal On Syntax Name SYNTAX

Call SysCls
Say 'Installation von MEMSIZE...'
Say ''


/* Nachprüfen, ob bestimmte Bestandteile vorhanden sind. */

Language = 'DEUTSCH'

Result = SysFileTree( 'MEMSIZE.EXE', 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'FEHLER: MEMSIZE.EXE nicht gefunden!'
  Signal DONE
  End

Result = SysFileTree( Language".DLL", 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'FEHLER: 'Language'.DLL nicht gefunden!'
  Signal DONE
  End

Result = SysFileTree( Language".HLP", 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'FEHLER: 'Language'.HLP nicht gefunden!'
  Signal DONE
  End

/* Zielverzeichnis erfragen. */
 
Say 'Bitte geben Sie den vollen Verzeichnisnamen ein, wohin'
Say '  MEMSIZE installiert werden soll (Standard: C:\OS2\APPS): '
Pull Directory
If Directory = "" Then Directory = 'C:\OS2\APPS'


/* Zielverzeichnis, falls nötig, anlegen. */

Result = SysFileTree( Directory, 'Dirs', 'D' )
If Dirs.0 = 0 Then
  Do
  Result = SysMkDir( Directory )
  if Result == 0 Then
    Do
    End
  Else
    Do
    Say 'FEHLER: Kann das Zielverzeichnis nicht anlegen.'
    Signal DONE
    End
  End
Say '';


/* Im Systemstart-Ordner installieren? */

Say 'Möchten Sie das Programmobjekt im Ordner Systemstart haben? (J/N)'
Pull YesNo
If YesNo = "J" Then
  Do
  Folder = '<WP_START>'
  Say 'Objekt wird im Systemstart-Ordner plaziert.'
  End
Else
  Do
  Folder = '<WP_DESKTOP>'
  Say 'Objekt wird auf der Arbeitsoberfläche plaziert.'
  End
Say ''


/* Installation durchführen. */

Say 'Kopiere MEMSIZE nach ' Directory '...'
Copy MEMSIZE.EXE Directory		    '1>NUL'
Copy Language".DLL" Directory"\MEMSIZE.DLL" '1>NUL'
Copy Language".HLP" Directory"\MEMSIZE.HLP" '1>NUL'

Say 'Erzeuge Programmobjekt...'
Type = 'WPProgram'
Title = 'Systemresourcen'
Parms = 'MINWIN=DESKTOP;PROGTYPE=PM;EXENAME='Directory'\MEMSIZE.EXE;STARTUPDIR='Directory';OBJECTID=<MEMSIZE>;NOPRINT=YES;'
Result = SysCreateObject( Type, Title, Folder, Parms, 'ReplaceIfExists' )
 
If Result = 1 Then
  Say 'Objekt erzeugt!  Fertig.'
Else             
  Say 'FEHLER: Nicht erzeugt!'

Signal DONE

FAILURE:
Say 'Fehler in der REXX-Ausführung.'
Signal DONE

HALT:
Say 'REXX-Halt.'
Signal DONE

SYNTAX:
Say 'REXX-Syntaxfehler.'
Signal DONE

DONE:
Exit
