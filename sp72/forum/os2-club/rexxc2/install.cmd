/* ------------------------------------------------------------------ */
/* install program for REXXCC.CMD                                     */
/*                                                                    */
/* Initial Release: 11.08.1994 /bs                                    */
/* Last Update:     21.08.1994 /bs                                    */
/*                                                                    */
/* Usage: install                                                     */
/*                                                                    */
/* written by: Bernd Schemmer, Baeckerweg 48, D-60316 Frankfurt       */
/*             Germany, Compuserve: 100104,613                        */
/*                                                                    */
/* Note: This file needs the OS/2 REXX dll REXXUTIL                   */
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
                        /* install error handlers                     */

  signal on error  Name ErrorAbort
  signal on halt   Name UserAbort
  signal on syntax Name ErrorAbort

/* ------------------------------------------------------------------ */
                        /* get drive, path and name of this program   */

  parse source . . prog.FullName
            prog.Drive = filespec( "drive", prog.FullName )
             prog.Path = filespec( "path",  prog.FullName )
             prog.Name = filespec( "name",  prog.FullName )
              prog.Env = 'OS2ENVIRONMENT'
          prog.Version = 'V2.00'
           prog.CurDir = directory()
         prog.ExitCode = 1      /* return code of INSTALL.CMD         */

            prog.Files = 'REXXCC*.*'

/* ------------------------------------------------------------------ */
                        /* save the OS/2 environment                  */
  dummy = setlocal()

/* ------------------------------------------------------------------ */
                        /* flush the keyobard buffer                  */
  do while lines() <> 0
    dummy = lineIn()
  end /* do while lines() <> 0 */

/* ------------------------------------------------------------------ */
/* show the logo                                                      */

  do until InstallPath <> ''
    'cls'
    Say '[0;m [7;m' || '╔' || Left( '═', 75, '═' ) || '╗ '
    Say '[0;m [7;m' || '║' || Center( ' Installation program for REXXCC.CMD',75 ) || '║ '
    Say '[0;m [7;m' || '║' || Center( 'Version ' || prog.Version, 75 ) || '║ '
    Say '[0;m [7;m' || '║' || Center( '(c) Bernd Schemmer 1994',75 ) || '║ '
    Say '[0;m [7;m' || '╚' || Left( '═',75,'═' ) || '╝ '
    Say '[0;m'

    say 'Please enter the target directory for REXXCC ("." for current dir):'

    parse pull installPath
    installPath = translate( strip( InstallPath ) )

  end /* do until InstallPath <> '' */

  if right( installPath, 1 ) = '\' then
    installPath = substr( installPath, 1, length( installPath ) - 1 )

  testPath = stream( installPath || '\*.*', 'c', 'QUERY EXIST' )

  if testPath <> '' then
    testPath = fileSpec( "drive", TestPath ) || ,
               fileSpec( "path",  TestPath )
  else
    testPath = installPath

  if right( testPath, 1 ) = '\' then
    testPath = substr( testPath, 1, length( testPath ) - 1 )

  say 'Installing REXXCC in the directory "' || testPath || '" '

  if translate( testPath ) || '\' = translate( prog.drive || prog.Path ) then
  do
    say 'Error: You can not use the installation directory as target directory!'
    signal programAbort
  end /* if translate( ...*/

  if stream( installPath || '\*.*', 'c', 'QUERY EXIST' ) = '' then
  do
    say ''
    thisKey = AskUser( 'YNQX' 'The directory does not exist. Create it (Y/N)? ' )
    if thisKey <> 'Y' then
      signal programAbort

    say 'Creating the directory "' || installPath || '" ...'
    '@md ' installPath '1>NUL'
    if rc <> 0 then
    do
      say 'OS Error ' || rc || ' creating the directory "' || installPath || '"!'
      signal ProgramAbort
    end /* if rc <> 0 then */

  end /* if directory( installPath = '' ) then */

  if stream( installPath || '\' || prog.Files, 'c', 'QUERY EXIST' ) <> '' then
  do
    say 'Installed version of REXXCC detected in the target directory.'
    thisKey = AskUser( 'YNQX' 'Delete the old version (Y/N)? ')
    if thisKey <> 'Y' then
      signal programAbort

    say 'Deleting the old version of REXXCC in the directory "' || installPath || '" ...'

    '@attrib -r ' installPath || '\' || prog.Files '1>NUL'
    if rc <> 0 then
      '@del ' installPath || '\' || prog.Files '1>NUL'

    if rc <> 0 then
    do
      say 'OS Error ' || rc || ' deleting the old version!'
      signal ProgramAbort
    end /* if rc <> 0 then */
  end /* if stream( ... */

  say 'Copying the files for REXXCC to "' || installPath || '" ...'
  '@copy /f  ' prog.drive || prog.Path || prog.Files ' ' installPath || '\' || prog.Files '1>NUL'
  if rc <> 0 then
  do
    say 'OS Error ' || rc || ' copying the files!'
    signal ProgramAbort
  end /* if rc <> 0 then */
  '@attrib +r  ' installPath || '\' || prog.Files '1>NUL'

  say ''
  say 'REXXCC includes a WPS frontend named REXXCCW.CMD. This is a little program'
  say 'to enter the parameter for REXXCC in common dialog boxes rather than entering'
  say 'them on the commandline.'
  say 'To use REXXCCW.CMD the REXX extension VREXX2 must be installed. VREXX2 is a'
  say 'freeware package from the IBM EWS program. You can obtain it from your local'
  say 'BBS or any IBM mailbox.'
  say ''

  thisKey = AskUser( 'YNQ' 'Should I create an object for REXXCCW.CMD (Y/N)? ' )

  if thisKey = 'Y' then
  do
    thisKey = AskUser( 'YNQ' 'Do you have an SVGA- or XGA-Displayadapter (Y/N)? ' )
    if thiskey= 'Q' then
      signal ProgramAbort

    rexxccwParameter = ''
    if thiskey = 'N' then
      rexxccwParameter = rexxccwParameter || ' /VGA'

    thisKey = AskUser( 'YNQ' 'Do you want the help windows of REXXCCW (Y/N)? ' )
    if thiskey= 'Q' then
      signal ProgramAbort

    if thiskey = 'N' then
      rexxccwParameter = rexxccwParameter || '/NOHELP'

    say 'Creating an object for REXXCCW.CMD on your desktop ...'

    thisRC = RxFuncAdd( 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' )
    if thisRC <> 1 then
    do
      say 'Opps, Can not load the dll RexxUtil. Without this dll I can not'
      say 'create the object. You must create the object by hand.'
      signal ProgramEnd
    end /* if thisRC <> 1 then */

    call SysLoadFuncs

     objectID = '<REXXCCW>'
        title = 'REXXCCW'
    className = 'WPProgram'
     location = '<WP_DESKTOP>'
        setup = 'EXENAME=' || installPath || '\REXXCCW.CMD;' || ,
                'PARAMETERS=' || rexxccwParameter || ';' || ,
                'PROGTYPE=WINDOWABLEVIO;' || ,
                'MINIMIZED=YES;' || ,
                'NODROP=NO;' || ,
                'OBJECTID=' || objectID || ';'

    thisRC = SysCreateObject( className, title, location, setup , updateFlag )
    if thisRC <> 1 then
    do
      say 'Oops, can not create the object for REXXCCW.CMD.'
      say 'You must create it by hand.'
      signal ProgramEnd
    end /* if thisRC <> 1 */
    else
      prog.ExitCode = 0

  end /* if thisKey = 'Y' then */
  else
    prog.ExitCode = 0


  programEnd:

    say 'REXXCC successfully installed in the directory "' || installPath || '".'

  programExit:
                        /* restore the OS/2 environment               */
    dummy = endlocal()

    exit prog.ExitCode

  programAbort:
    say ''
    say 'Installation aborted.'
    signal ProgramExit

/* ------------------------------------------------------------------ */
/* AskUser - get input from the user                                  */
/*                                                                    */
/* Usage:    AskUser akeys prompt                                     */
/*                                                                    */
/* where:                                                             */
/*           akeys - allowed keys (all keys are translated to         */
/*                   uppercase)                                       */
/*           prompt - prompt for the ask                              */
/*                                                                    */
/* Returns:  the pressed key in uppercase                             */
/*                                                                    */
AskUser: PROCEDURE
  parse arg aKeys prompt

  aKeys = translate( akeys )

  call charout ,  prompt

  thisKey = ' '
  do UNTIL pos( thisKey ,  aKeys ) <> 0
    call charOut ,'[s[K' || ''
    thisKey = translate( charIn() )
    call CharOut , '[u'
    dummy = lineIn()
  end /* do until ... */
  say ''

RETURN thisKey

/* ------------------------------------------------------------------ */
/* error handler                                                      */

ErrorAbort:
  thisLineNo = sigl

  say ''
  say ' ------------------------------------------------------------------ '
  say ' ' || prog.Name || ' - Unexpected error ' || rc || ' in line ' || thisLineNo || ' detected!'
  say ''

  say ' The line reads: '

  thisprefix = ' *-* '

  do forever
    thisSourceLine = sourceLine( thisLineNo )
    say thisPrefix || thisSourceLine
    if right( strip( thisSourceLine ) ,1,1 ) <> ',' then
      leave
    thisLineNo = thisLineNo +1
    thisPrefix = '     '
  end /* do forever */

  if datatype( rc, 'W' ) = 1 then
    if rc > 0 & rc < 100 then
    do
     say ''
     say ' The REXX error message is: ' errorText( rc )
    end /* if datatype( rc, 'W' ) = 1 then */

  say ' ------------------------------------------------------------------ '
  say ''

  prog.ExitCode = 255
signal ProgramExit

/* break handler */
UserAbort:
    say ''
    say ' ------------------------------------------------------------------ '
    say ' ' || prog.Name || ' - Unexpected error 997 detected!'
    say ''
    say ' The error message is: Program aborted by the user!'
    say ' ------------------------------------------------------------------ '
    say ''

  prog.ExitCode = 254
signal ProgramExit

