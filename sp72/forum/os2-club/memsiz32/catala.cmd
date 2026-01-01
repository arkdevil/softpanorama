/* CATALA.CMD: Instal·lació de MEMSIZE en català */

"@Echo Off"

/* Càrregar REXXUTIL */

Call RxFuncAdd "SysLoadFuncs", "REXXUTIL", "SysLoadFuncs"
Call SysLoadFuncs


/* Initialize */
 
Signal On Failure Name FAILURE
Signal On Halt Name HALT
Signal On Syntax Name SYNTAX

Call SysCls
Say "Instal·lació de MEMSIZE..."
Say ""


/* Verify the existence of the various component files. */

Language = "CATALA"

Result = SysFileTree( "MEMSIZE.EXE", "Files", "F" )
If Files.0 = 0 Then
  Do
  Say "ERROR: No se troba el MEMSIZE.EXE!"
  Signal DONE
  End

Result = SysFileTree( Language".DLL", "Files", "F" )
If Files.0 = 0 Then
  Do
  Say "ERROR: No se troba el "Language".DLL!"
  Signal DONE
  End

Result = SysFileTree( Language".HLP", "Files", "F" )
If Files.0 = 0 Then
  Do
  Say "ERROR: No se troba el "Language".HLP!"
  Signal DONE
  End

/* Ask for the target directory name. */
 
Say "Si us plau, escribiu el nom complet del directori on voleu"
Say "  instal·lar el programa MEMSIZE (per defecte és C:\OS2\APPS): "
Pull Directory
If Directory = "" Then Directory = "C:\OS2\APPS"


/* Create the target directory if necessary. */

Result = SysFileTree( Directory, "Dirs", "D" )
If Dirs.0 = 0 Then
  Do
  Result = SysMkDir( Directory )
  if Result == 0 Then
    Do
    End
  Else
    Do
    Say "ERROR: No se pot crear el directori destí."
    Signal DONE
    End
  End
Say ""


/* Ask for the target folder. */

Say "Voleu instal·lar-lo de forma que s'executi automàticament a l'arrencar? (S/N)"
Pull YesNo
If YesNo = "S" Then
  Do
  Folder = "<WP_START>"
  Say "L'objecte es copiarà a la carpeta Inici."
  End
Else
  Do
  Folder = "<WP_DESKTOP>"
  Say "L'objecte es copiarà a l'escriptori."
  End
Say ""


/* Perform the installation. */

Say "Copiant MEMSIZE al directori " Directory "..."
Copy MEMSIZE.EXE Directory		    "1>NUL"
Copy Language".DLL" Directory"\MEMSIZE.DLL" "1>NUL"
Copy Language".HLP" Directory"\MEMSIZE.HLP" "1>NUL"

Say "Creant l'objecte del programa..."
Type = "WPProgram"
Title = "Recursos del Sistema"
Parms = "MINWIN=DESKTOP;PROGTYPE=PM;EXENAME="Directory"\MEMSIZE.EXE;STARTUPDIR="Directory";OBJECTID=<MEMSIZE>;NOPRINT=YES;"
Result = SysCreateObject( Type, Title, Folder, Parms, "ReplaceIfExists" )
 
If Result = 1 Then
  Say "L'objecte s'ha creat.  Final"
Else             
  Say "ERROR: No s'ha pogut crear l'objecte!"

Signal DONE

FAILURE:
Say "Errada del REXX."
Signal DONE

HALT:
Say "S'atura el REXX."
Signal DONE

SYNTAX:
Say "Error de síntaxi del REXX."
Signal DONE

DONE:
Exit
