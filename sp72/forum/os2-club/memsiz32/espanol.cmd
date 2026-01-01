/* ESPAÑOL.CMD: Instalación de MEMSIZE en español */

'@Echo Off'

/* Cargar REXXUTIL */

Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
Call SysLoadFuncs


/* Initialize */
 
Signal On Failure Name FAILURE
Signal On Halt Name HALT
Signal On Syntax Name SYNTAX

Call SysCls
Say 'Instalación de MEMSIZE...'
Say ''


/* Verify the existence of the various component files. */

Language = 'ESPAÑOL'

Result = SysFileTree( 'MEMSIZE.EXE', 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'ERROR: ¡No se encuentra el MEMSIZE.EXE!'
  Signal DONE
  End

Result = SysFileTree( Language".DLL", 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'ERROR: ¡No se encuentra el 'Language'.DLL!'
  Signal DONE
  End

Result = SysFileTree( Language".HLP", 'Files', 'F' )
If Files.0 = 0 Then
  Do
  Say 'ERROR: ¡No se encuentra el 'Language'.HLP!'
  Signal DONE
  End

/* Ask for the target directory name. */
 
Say 'Por favor, escriba el nombre completo del directorio en el'
Say '  que quiere instalar el programa MEMSIZE (por defecto es C:\OS2\APPS): '
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
    Say 'ERROR: No se puede crear el directorio destino.'
    Signal DONE
    End
  End
Say ''


/* Ask for the target folder. */

Say "¿Quiere instalarlo de forma que se ejecute automáticamente al arrancar? (S/N)"
Pull YesNo
If YesNo = "S" Then
  Do
  Folder = '<WP_START>'
  Say "El objeto se copiará en la carpeta Inicio."
  End
Else
  Do
  Folder = '<WP_DESKTOP>'
  Say "El objeto se copiará en el Escritorio."
  End
Say ''


/* Perform the installation. */

Say 'Copiando MEMSIZE al directorio ' Directory '...'
Copy MEMSIZE.EXE Directory		    '1>NUL'
Copy Language".DLL" Directory"\MEMSIZE.DLL" '1>NUL'
Copy Language".HLP" Directory"\MEMSIZE.HLP" '1>NUL'

Say "Creando el objeto del programa..."
Type = 'WPProgram'
Title = 'Recursos del Sistema'
Parms = 'MINWIN=DESKTOP;PROGTYPE=PM;EXENAME='Directory'\MEMSIZE.EXE;STARTUPDIR='Directory';OBJECTID=<MEMSIZE>;NOPRINT=YES;'
Result = SysCreateObject( Type, Title, Folder, Parms, 'ReplaceIfExists' )
 
If Result = 1 Then
  Say "El objeto se ha creado.  Fin."
Else             
  Say "ERROR: ¡No se ha podido crear el objeto!"

Signal DONE

FAILURE:
Say 'Error del REXX.'
Signal DONE

HALT:
Say 'Se ha parado el REXX.'
Signal DONE

SYNTAX:
Say 'Error de síntaxis del REXX.'
Signal DONE

DONE:
Exit
