/* ------------------------------------------------------------------ */
/* REXXCCW.CMD - simple wps front end for REXXCC.CMD                  */
/*                                                                    */
/* (c) 1994 Bernd Schemmer                                            */
/*                                                                    */
/* Initial Release: 11.08.1994 /bs                                    */
/* Last Update:     21.08.1994 /bs                                    */
/*                  27.10.1994 /bs                                    */
/*                                                                    */
/* Usage: REXXCCW {/NOHELP} {/VGA} {parameter_for_rexxcc}             */
/*                                                                    */
/* where:                                                             */
/*               /NOHELP - do not show help windows                   */
/*                         (def. show help windows)                   */
/*                  /VGA - use VGA resolution (def.: SVGA resolution) */
/*  parameter_for_rexxcc - parameter for REXXCC.CMD                   */
/*                                                                    */
/* written by: Bernd Schemmer, Baeckerweg 48, D-60316 Frankfurt       */
/*             Germany                                                */
/*                                                                    */
/* Note: This program needs the OS/2 REXX dll REXXUTIL and            */
/*       the IBM EWS package VREXX2.                                  */
/*       This program also needs the OS/2 programs ATTRIB and         */
/*       RXQUEUE to be in one directory saved in the environment      */
/*       variable "PATH".                                             */
/*       See also the file REXXCC.CMD for further information         */
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
                        /* names of the variables all procedures must */
                        /* know                                       */

exposeList = 'prog. helpMsgs. dialogs. compiler. status. '

/* ------------------------------------------------------------------ */
                        /* get drive, path and name of this program   */

parse source . . prog.FullName
            prog.Drive = filespec( "drive", prog.FullName )
             prog.Path = filespec( "path",  prog.FullName )
             prog.Name = filespec( "name",  prog.FullName )
              prog.Env = 'OS2ENVIRONMENT'
           prog.CurDir = directory()
         prog.ExitCode = 0      /* return code of REXXCCW.CMD         */
     prog.VRexx2Loaded = 0      /* <> 0 : VREXX2 loaded               */
   prog.RexxUtilLoaded = 0      /* <> 0 : RexxUtil loaded             */

                                /* name of the EAs to store data      */

                                /* EA for the REXXCC program to use   */
     prog.RexxCCNameEA = 'REXXCC.FullName'

                                /* EA for the default REXXCC options  */
  prog.RexxCCOptionsEA = 'REXXCC.Options'

                                /* EA for the default directory for   */
                                /* target files                       */
prog.RexxCCTargetDirEA = 'REXXCC.DefaultTargetDir'

                                /* attributes for error messages in   */
                                /* textmode (bright yellow on red)    */
 prog.ErrorAttributess = '[33;m[41;m[1;m'

                                /* reset attributes in textmode       */
 prog.NormalAttributes = '[0;m'

                                /* factor to calculate the width for  */
                                /* the help windows                   */
   prog.DisplayAdapterDelta = 1.1

/* ------------------------------------------------------------------ */
                        /* install error handlers                     */

signal on error  Name ErrorAbort
signal on halt   Name UserAbort
signal on syntax Name ErrorAbort

/* ------------------------------------------------------------------ */
                        /* check the parameter                        */
parse upper arg prog.Parms

                        /* check for the parameter /NOHELP            */
if pos('/NOHELP', prog.Parms ) <> 0 then
do
                        /* parameter /NOHELP found: set variable and  */
                        /* delete the /NOHELP parameter               */
  parse var prog.parms part1 '/NOHELP' part2
  prog.parms = strip(part1)  strip(part2)
  prog.ShowHelp = 0
  drop part1 part2
end /* if pos( ... */

                        /* check for the parameter /VGA               */
if pos('/VGA', prog.Parms ) <> 0 then
do
                        /* parameter /VGA found: set variable and     */
                        /* delete the /VGA parameter                  */
  parse var prog.parms part1 '/VGA' part2
  prog.parms = strip(part1)  strip(part2)
  prog.DisplayAdapterDelta = 2.0
  drop part1 part2
end /* if pos( ... */

                        /* get parameter for sourceFile if any        */
   sourceFile = GetNextParameter()

                        /* get parameter for targetfile if any        */
   targetFile = GetNextParameter()
   if translate( targetFile ) = 'TO' then
     targetFile = GetNextParameter()

                        /* get parameter for copyrightfile if any     */
   CopyrightFile = GetNextParameter()
   if translate( CopyrightFile ) = 'WITH' then
     CopyrightFile = GetNextParameter()

                        /* get parameter for options if any           */
   options = GetNextParameter()

/* ------------------------------------------------------------------ */
                        /* init some variables                        */

                        /* name of the compiler                       */
compiler.InitName = 'REXXCC.CMD'

                        /* name and path of the used compiler         */
compiler.UsedName = ''

                        /* title for error messages                   */
dialogs.errorTitle = prog.Name || ' - Error Message'

                        /* colors for the messages                    */
dialogs.msgForeColor1 = 'GREEN'
dialogs.msgForeColor2 = 'PINK'
dialogs.msgForeColor3 = 'YELLOW'
dialogs.msgBackColor  = 'BLUE'

                        /* background color for the help window       */
helpMsgs.backColor    = 'CYAN'

                        /* id of the help window                      */
                        /* '' : no help window open                   */
helpMsgs.helpWindowID = ''

                        /* id of the status window                    */
                        /* '' : no status window open                 */
status.WindowID = ''

/* ------------------------------------------------------------------ */

if LoadDlls() = 1 then
do
                        /* init the stem with the help messages       */
  call InitHelpmessage

                        /* get the path of REXXCC.CMD                 */
  compiler.UsedName = GetCompilerName( compiler.UsedName )

  if compiler.UsedName <> '' then
  do

                        /* get the default target dir                 */
    prog.DefaultTargetDir = ReadEA( '"' || prog.FullName          || '"'  ,
                                    '"' || prog.RexxCCTargetDirEA || '"'    )

   if sourceFile <> ''   & ,
      targetFile = ''    & ,
      copyrightFile = '' then
    do
      targetFile = prog.DefaultTargetDir || filespec( "name", sourceFile )
      copyrightFile = sourceFile
    end /* if sourceFile <> '' & ... */

                        /* check if we can use the saved options from */
                        /* the EAs                                    */
    if options = '' then
      options = ReadEA( '"' || prog.FullName        || '"'  ,
                        '"' || prog.RexxCCOptionsEA || '"'    )

                        /* init the stems for the main dialog         */
    prompt.0 = 5
    prompt.1 = 'Sourcefile:'
    prompt.2 = 'TargetFile:'
    prompt.3 = 'CopyrightFile:'
    prompt.4 = 'Options:'
    prompt.5 = 'Compiler:'

    width.  = 32
    width.0 = prompt.0

    hide. = 0
    hide.0 = prompt.0

    result.0 = prompt.0
    result.1 = sourceFile
    result.2 = targetFile
    result.3 = copyrightFile
    result.4 = options
    result.5 = compiler.UsedName

                        /* get the parameter for REXXCC               */
    do until ParameterOK <> 0
      parameterOK = 0

                        /* get the width for the main dialog          */
      j = width.1
      do i = 1 to result.0
        j = max( j, length( result.i ) )
      end /* do i = 1 to result.0 */
      width. = j

                        /* init the stem variable with the result     */
                        /* fields for the main dialog                 */
      result.1 = sourceFile
      result.2 = targetFile
      result.3 = copyrightFile
      result.4 = options
      result.5 = compiler.UsedName


                        /* set the position for the windows and dlgs  */
      call VDialogPos 50, 20

                        /* show the main dialog                       */
      call ShowHelpMessage 2
      button = VMultBox(center( filespec( 'N', compiler.InitName ) || ' Main Dialog', width.1 ) , 'prompt', 'width', 'hide', 'result', 3 )
      call ShowHelpMessage 0

      sourceFile        = translate( result.1 )
      targetFile        = translate( result.2 )
      copyrightFile     = translate( result.3 )
      options           = translate( result.4 )
      compiler.UsedName = translate( result.5 )

      if button <> 'OK' then
        parameterOK = -1        /* dialog canceled                    */
      else
      do
        message.0 = 1   /* init the stem for the error messages       */
        message.1 = ''

                        /* check the path and name of REXXCC.CMD      */
        compiler.UsedName = GetCompilerName( compiler.UsedName )

        if compiler.UsedName <> '' then
        do
                        /* check the parameter                        */
          if sourceFile = '' then
          do
                        /* get the source file via a file dialog      */
            sourceFile = AskUserForFileName( ,
                           '""',
                           '"' || directory() || '"' ,
                           '"' || prog.Name || ' - Select the source file' || '"',
                           '"' || dialogs.errorTitle || '"' ,
                           1,
                           3 )

            if targetFile = '' & sourceFile <> '' then
            do
                         /* get the target file via a file dialog     */
              targetFile = AskUserForFileName( ,
                             '""',
                             '"' || fileSpec( "drive", sourceFile ) || ,
                                    fileSpec( "path", sourceFile )  || '"' ,
                             '"' || prog.Name || ' - Select a name for the target file' || '"',
                             '"' || dialogs.errorTitle || '"' ,
                             2 ,
                             4 )

              if copyrightFile = '' & sourceFile <> '' & targetFile <> '' then
              do
                         /* get the copyright file via a file dialog  */
                copyrightFile = AskUserForFileName( ,
                                  '""',
                                  '"' || fileSpec( "drive", sourceFile ) || ,
                                         fileSpec( "path", sourceFile )  || '"' ,
                                  '"' || prog.Name || ' - Select the copyright file' || '"',
                                  '"' || dialogs.errorTitle || '"' ,
                                  2 ,
                                  5 )

              end /* if copyrightFile = '' & ... */
            end /* if targetFile = '' & ... */

            if ( sourceFile <> '' &  getExtension( sourceFile ) <> 'CMD' ) | ,
               ( targetFile <> '' &  getExtension( targetFile ) <> 'CMD' ) then
              if pos( '/IEXT=1', translate( options ) ) = 0 then
                if options = '' then
                  options = '/IExt=1'
                else
                  options = options || ' /IExt=1'

          end /* if sourceFile = '' then */
          else
          do
            if CheckWildCards( sourceFile ) = 1 then
              message.1 = 'You can not use wildcards in the name for the source file!'
            else if stream( sourceFile, 'c', 'QUERY EXIST' ) = '' then
              message.1 = 'The source file does not exist!'
            else
            do
              if targetFile = '' then
              do
                         /* get the target file via a file dialog     */
                targetFile = AskUserForFileName( ,
                               '""' ,
                               '"' || fileSpec( "drive", sourceFile ) || ,
                                   fileSpec( "path", sourceFile )  || '"' ,
                               '"' || prog.Name || ' - Select a name for the target file' || '"',
                               '"' || dialogs.errorTitle || '"' ,
                               2 ,
                               4 )
                if targetFile = '' then
                  parameterOK = -2
              end /* if targetFile = '' then */
              else
              do
                if targetFile = '' then
                  message.1 = 'You must enter a targetfile for ' || filespec( 'N', compiler.InitName) || '!'
                else if checkWildCards( targetFile ) = 1 then
                  message.1 = 'You can not use wildcards in the name for the targetfile!'
                else if stream( targetFile, 'c', 'QUERY EXIST' ) = stream( sourceFile, 'c', 'QUERY EXIST' ) then
                  message.1 = 'The targetfile can not be equal to the sourcefile!'
                else if stream( targetFile, 'c', 'QUERY EXIST' ) <> '' then
                do
                                /* target file exists : ask user if   */
                                /* we should overwrite it             */
                  if pos( 'OVERWRITE', translate( options ) ) = 0 then
                  do
                    message1.0 = 5
                    message1.1 = 'The target file '
                    message1.2 = '"' || targetFile || '"'
                    message1.3 = 'already exist!'
                    message1.4 = '                                    '
                    message1.5 = 'Overwrite it?'

                    button = VMsgBox( dialogs.errorTitle , message1, 3 )
                    if button = 'OK' then
                      options = options || ' /Overwrite'
                    else
                      parameterOK = 2
                  end /* if pos( ... */
                end /* else if stream( tragetFile, ...*/
                else if copyrightFile <> '' then
                do
                  if checkWildCards( copyrightFile ) = 1 then
                    message.1 = 'You can not use wildcards in the name for the copyrightfile!'
                  if copyrightFile <> '=' & ,
                     stream( copyrightFile, 'c', 'QUERY EXIST' ) = '' then
                    message.1 = 'The copyright file does not exist!'
                end /* else if copyrightFile <> '' then */

              end /* else */
            end /* else */

            if message.1 <> '' then
            do
              message.1 = '  ' || message.1
              call VMsgBox dialogs.errorTitle , message, 1
            end /* if message.1 <> '' then */
            else
              if parameterOK <> -2 then
                parameterOK = 1
              else
                parameterOK = 0

          end /* else */
        end /* if compiler.UsedName <> '' then */
      end /* else */
    end /* do until parameterOK <> 0 */

    if parameterOK = 1 then
    do

                        /* update the EAs                             */
      if options <> '' then
        dummy = WriteEA( '"' || prog.FullName        || '"' ,
                         '"' || prog.RexxCCOptionsEA || '"' ,
                         '"' || options || '"'                )

      prog.DefaultTargetDir = filespec( "drive", targetFile ) || ,
                              fileSpec( "path", targetFile )

      if prog.DefaultTargetDir <> '' then
        dummy = WriteEA( '"' || prog.FullName          || '"' ,
                         '"' || prog.RexxCCTargetDirEA || '"' ,
                         '"' || prog.DefaultTargetDir  || '"'   )


                        /* prepare the parameter for REXXCC           */
      sourceFile        = '"' || sourceFile        || '"'
      targetFile        = '"' || targetFile        || '"'
      copyrightFile     = '"' || copyrightFile     || '"'
      compiler.UsedName = '"' || compiler.UsedName || '"'

      rexxCCParameter = sourceFile ' TO ' targetFile
      if copyrightFile <> '""' then
        rexxCCParameter = rexxCCParameter ' WITH ' copyrightFile

      if options <> '' then
      do
                        /* add the leading '/' to the options if      */
                        /* neccessary                                 */
        do i = 1 to words( options )
          if left( word( options, i ) ,1 ) = '-' | ,
             left( word( options, i ) ,1 ) = '/' then
            rexxCCParameter = rexxCCParameter || ' ' || word( options, i )
          else
            rexxCCParameter = rexxCCParameter || ' /' || word( options, i )
        end /* do i = 1 to words( options ) */
      end /* if options <> '' then */

                        /* show the compile status window             */
      call ShowStatusMessage

                        /* we don't need colors - so set the          */
                        /* environment variable ANSI to '0'           */
      oldAnsi = value( 'ANSI', '0', prog.env )

                        /* call REXXCC                                */
      'cmd /c ' '"' compiler.UsedName rexxCCParameter '"' '| RXQUEUE'
      prog.thisRC = rc  /* save the return code                       */
                        /* change the status message in the status    */
                        /* window                                     */
      call VForeColor  status.windowID, dialogs.MsgForeColor3
      if prog.ThisRC = 0 then
        call VSay status.windowID, status.x, status.y, 'Status: Compiling was successfull.'
      else
        call VSay status.windowID, status.x, status.y, 'Status: Compiling endet with errorcode ' || rc || '.'

                        /* restore the value of the environment       */
                        /* variable ANSI                              */
      oldAnsi = value( 'ANSI', oldAnsi, prog.env )


      output.0 = 0      /* put the output of REXXCC in a stem var     */
      do while queued() <> 0
        j = output.0 +1
        output.j=LineIN('QUEUE:')
        output.0 = j
                        /* split the line into 80 char lines          */
        do forever
          if length( output.j ) > 80 then
          do
            k = j + 1
            output.k = substr( output.j, 81 )
            output.j = substr( output.j, 1, 80)
            j = k
          end /* if length( ... */
          else
            leave
        end /* do forever */
        output.0 = j
      end /* do while queued() <> 0 */

                        /* show the output of REXXCC                  */
      call VDialogPos 50, 15
      call VListBox  filespec( 'N', compiler.InitName ) || ' output window', output, 80, 6, 1

                        /* close the compile in progress window       */
      call VCloseWindow status.windowID

    end /* if parameterOK = 1 then */
    else
      prog.ExitCode = 1         /* REXXCCW canceled by the user       */
  end /* if rexxCCFound = 1 then */
  else
    prog.ExitCode = 1           /* REXXCC.CMD not found               */
end /* if loadDlls() = 1 */

/* ------------------------------------------------------------------ */

ProgramEnd:
                        /* restore the current directory              */
  if symbol( 'prog.CurDir' ) = 'VAR' then
    call directory prog.CurDir

                        /* unload VREXX2 if neccessary                */
  if prog.VRexx2Loaded = 1 then
    call VExit

                        /* unload RexxUtils if neccessary             */
  if prog.RexxUtilLoaded = 1 then
    call SysDropFuncs

exit prog.ExitCode

/* ------------------------------------------------------------------ */
/* GeteExtension                                                      */
/*                                                                    */
/* Function: returns the extension of a file                          */
/*                                                                    */
/* Usage:    GetExtension file_name                                   */
/*                                                                    */
/* where:    file_name = name of the file                             */
/*                                                                    */
/* returns:  1 - wildcards found in the string                        */
/*           0 - no wildcards found in the string                     */
/*                                                                    */
GetExtension: PROCEDURE expose (exposeList)
  parse upper arg thisFileName .

  if lastPos( '.', thisFileName ) = 0 then
    return ''
  else
    return translate( substr( thisFileName, lastPos( '.', thisFileName ) +1, 3 ) )

/* ------------------------------------------------------------------ */
/* CheckWildCards                                                     */
/*                                                                    */
/* Function: check if a string contains the chars '?' or '*'          */
/*                                                                    */
/* Usage:    CheckWildCards string_to_test                            */
/*                                                                    */
/* where:    string_to_test = string to test                          */
/*                                                                    */
/* returns:  1 - wildcards found in the string                        */
/*           0 - no wildcards found in the string                     */
/*                                                                    */
CheckWildCards: PROCEDURE expose (exposeList)
  parse arg TestString
  return pos( '?' , teststring ) <> 0 | pos( '*' , testString ) <> 0

/* ------------------------------------------------------------------ */
/* GetCompilerName                                                    */
/*                                                                    */
/* Function: get the path and name of the compiler                    */
/*                                                                    */
/* Usage:    GetCompilerName curCompilerName                          */
/*                                                                    */
/* where:    curCompilerName - current name for the compiler          */
/*                                                                    */
/* returns:     '' file not found                                     */
/*             else Name and Path of the file                         */
/*                                                                    */
GetCompilerName: PROCEDURE expose (exposeList)
  parse arg curCompilerName

                        /* get the path of REXXCC                     */

                        /* check the EAs of this file                 */
  if curCompilerName = '' then
    curCompilerName = ReadEA( '"' || prog.FullName     || '"'  ,
                              '"' || prog.RexxCCNameEA || '"'     )

                        /* check if the compiler exists in the        */
                        /* directory with REXXCCW.CMD                 */
  if curCompilerName = '' then
    curCompilerName = prog.Drive || prog.Path || compiler.InitName

                        /* search compiler in the PATH                */
  if stream( curCompilerName , 'c', 'QUERY EXIST' ) = '' then
    curCompilerName = SearchFileInPath( compiler.InitName )

                        /* ask user which compiler to use if we       */
                        /* couldn't find the compiler                 */
  if curCompilerName = '' then
    curCompilerName = AskUserForFileName( ,
                        '"' || compiler.InitName || '"',
                        '"' || directory() || '"',
                        '"' || prog.Name || ' - Select the compiler to use' || '"',
                        '"' || dialogs.errorTitle || '"' ,
                        1 ,
                        1 )

                        /* update the EAs of this file                */
  if curCompilerName <> '' then
    dummy = WriteEA( '"' || prog.FullName      || '"'   ,
                     '"' || prog.RexxCCNameEA  || '"'   ,
                     '"' || curCompilerName    || '"'     )

RETURN curCompilerName

/* ------------------------------------------------------------------ */
/* SearchFileInPath                                                   */
/*                                                                    */
/* Function: Check, if a file exists in one of the directorys in the  */
/*           environment variable PATH                                */
/*                                                                    */
/* Usage:    SearchFileInPath file_to_search                          */
/*                                                                    */
/* where:    file_to_search - name of the file to search              */
/*                                                                    */
/* returns:  '' file not found                                        */
/*           else Name and Path of the file                           */
/*                                                                    */
SearchFileInPath: PROCEDURE expose (exposeList)
  parse arg fileToSearch .

  foundedFileName = ''
                        /* get the value of the environment variable  */
                        /* path                                       */
  searchPath = value( 'PATH', , prog.env )

  do until searchPath = '' | foundedFileName <> ''
    parse var searchPath curPath ';' searchpath

    curPath = strip( curPath )
    if curPath <> '' then
    do
      if right( curPath, 1 ) <> '\' then
        curPath = curPath || '\'
      foundedFileName = stream( curPath || fileToSearch, 'c', 'QUERY EXIST' )
    end /* if curPath <> '' then */
  end /* do until searchPath = '' ... */

RETURN foundedFileName

/* ------------------------------------------------------------------ */
/* AskUserForFilename                                                 */
/*                                                                    */
/* Function: Get the name and path of a file from the user            */
/*                                                                    */
/* Usage:                                                             */
/*   AskUserForFileName "file_to_search" "searchDir"  ,               */
/*                      "title" "errorTitle" ,                        */
/*                      exist helpNo                                  */
/*                                                                    */
/* where:                                                             */
/*   "file_to_search" - name of the file to search                    */
/*        "searchDir" - name of the directory to start the search     */
/*            "title" - title for the file search dialog              */
/*       "errorTitle" - title for error messages                      */
/*              exist - 1: file must exist, 0: file must not exist    */
/*                      else: file maybe exist                        */
/*             helpNo - no. of the stem with the online help          */
/*                                                                    */
/* returns:     '' file not found                                     */
/*             else Name and Path of the file                         */
/*                                                                    */
/* Notes:                                                             */
/*   if file_to_search is "" or if file_to_search contains wildcards, */
/*   no name checking is done                                         */
/*   You must enter the double quotes!                                */
/*                                                                    */
AskUserForFileName: PROCEDURE expose (exposeList)

  parse arg '"' fileToSearch '"' . '"' searchDir '"' . '"' title '"' . '"' errorTitle '"' exist helpNO

  call VDialogPos 50, 45
  if fileToSearch = '' then
    fileToSearch = '*.*'

  if right( searchDir, 1 ) <> '\' then
    searchDir = searchDir || '\'

                        /* show the help window if neccessary         */
  if helpNo <> '' then
    call ShowHelpMessage helpNo


  do until fileFound <> 0
    fileFound = 0
    foundedFile = ''

                        /* init the stem for the error message        */
    message.0 = 1
    message.1 = ''

    button = VFileBox( title, searchDir || fileToSearch ,  fileName )

    if button = 'OK' then
    do
      if fileName.vstring <> '' then
        searchDir = filespec( "drive", fileName.vstring ) || ,
                    fileSpec( "path", fileName.vstring )

                        /* file must exist                            */
      if exist = 1 & stream( filename.vstring , 'c', 'QUERY EXIST' ) = '' then
      do
        if length( filename.vstring ) > 40 then
          errMsgFileName = '...' || right( fileName.Vstring, 15 )
        else
          errMsgFileName = fileName.vstring

        message.1 = 'The file "' || errMsgFilename || '" does not exist!'
      end /* if exist = 1  ... */

      else if exist = 0 & stream( filename.vstring , 'c', 'QUERY EXIST' ) <> '' then
      do
        if length( filename.vstring ) > 40 then
          errMsgFileName = '...' || right( fileName.Vstring, 15 )
        else
          errMsgFileName = fileName.vstring

        message.1 = 'The file "' || errMsgFilename || '" already exist!'
      end /* else if exist = 0  ... */

      else if fileToSearch <> ''                 & ,
              CheckWildCards( fileToSearch ) = 0 & ,
              translate( fileSpec( "name", fileName.vstring ) ) <> fileToSearch then
      do
        message.1 = 'The name of the program must be "'  || fileToSearch || '"!'
      end /* if fileToSearch <> '' & ... */

      else
      do
        fileFound = 1
        foundedFile = filename.Vstring
      end /* else */

      if message.1 <> '' then
        call VMsgBox errorTitle, message, 1

    end /* if button = 'OK' then */
    else
      fileFound = -1
  end /* do until fileFound <> 0 */

                        /* close the help window if neccessary        */
  if helpNo <> '' then
    call ShowHelpMessage 0

RETURN foundedFile

/* ------------------------------------------------------------------ */
/* InitHelpMessage                                                    */
/*                                                                    */
/* Function: init the stem with the help messages                     */
/*                                                                    */
/* Usage:    InitHelpMessage                                          */
/*                                                                    */
/* where:                                                             */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
InitHelpMessage:
  helpMsgs.0 = 5

  helpMsgs.1.0 = 3
  helpMsgs.1.delta = 200
  helpMsgs.1.faktor = 5
  helpMsgs.1.1 = 'Select the compiler to use and click on OK.'
  helpMsgs.1.2 = 'Note: The name of the compiler must be "' || compiler.InitName || '".'
  helpMsgs.1.3 = ''

  helpMsgs.2.0  = 16
  helpMsgs.2.delta = 55
  helpMsgs.2.faktor = 2.5
  helpMsgs.2.StartY = 900
  helpmsgs.2.1  = 'Fill all neccessary fields and click on OK.'
  helpMsgs.2.2  = 'Click on CANCEL to abort ' || prog.name || '.'
  helpMsgs.2.3  = 'Hint: Click on OK without filling the fields'
  helpMsgs.2.4  = '      if you want to use file select dialogs.'
  helpMsgs.2.5  = 'Note: You must fill the fields SourceFile and TargetFile.'
  helpMsgs.2.6  = '      If the name of a filename begins with one or more blanks'
  helpMsgs.2.7  = '      you must enter it with a path (".\" for the current directory)'
  helpMsgs.2.8  = '      Possible options are:'
  helpmsgs.2.9  = '        /IExt=1    : do not check the file extensions'
  helpmsgs.2.10 = '        /IVer=1    : do not check the REXX version'
  helpMsgs.2.11 = '        /IDate=1   : do not check the date of the source file'
  helpMsgs.2.12 = '        /Overwrite : overwrite an existing target file'
  helpMsgs.2.13 = '        /UseSource : use the source file as copyright file '
  helpmsgs.2.14 = '        /LineCount=n : use the first n lines of the source file'
  helpmsgs.2.15 = '                       as copyright file. This option is only valid,'
  helpmsgs.2.16 = '                       if you use the source file as copyright file.'

  helpMsgs.3.0 = 5
  helpMsgs.3.delta = 100
  helpMsgs.3.faktor = 5
  helpMsgs.3.1 = 'Select the source file to compile and click on OK'
  helpMsgs.3.2 = 'or click on CANCEL to go back to the main dialog.'
  helpMsgs.3.3 = 'Note: The source file must exist.'
  helpMsgs.3.4  = '      If the name of the filename begins with one or more blanks'
  helpMsgs.3.5  = '      you must enter it with a path (".\" for the current directory)'

  helpMsgs.4.0 = 4
  helpMsgs.4.delta = 150
  helpMsgs.4.faktor = 5
  helpMsgs.4.1  = 'Select a name for the target file and click on OK'
  helpMsgs.4.2  = 'or click on CANCEL to go back to the main dialog.'
  helpMsgs.4.3  = 'Note: If the name of the filename begins with one or more blanks'
  helpMsgs.4.4  = '      you must enter it with a path (".\" for the current directory)'

  helpMsgs.5.0 = 5
  helpMsgs.5.delta = 100
  helpMsgs.5.faktor = 5
  helpMsgs.5.1  = 'Select the copyright file to compile and click on OK'
  helpMsgs.5.2  = 'or click on CANCEL to go back to the main dialog.'
  helpMsgs.5.3  = 'Note: You can only choose an existing file as copyright file.'
  helpMsgs.5.4  = '      If the name of the filename begins with one or more blanks'
  helpMsgs.5.5  = '      you must enter it with a path (".\" for the current directory)'

RETURN

/* ------------------------------------------------------------------ */
/* ShowHelpMessage                                                    */
/*                                                                    */
/* Function: Show a help message                                      */
/*                                                                    */
/* Usage:    ShowHelpMessage  helpNo                                  */
/*                                                                    */
/* where:    helpNo = no. of the help message                         */
/*           special: helpNo = 0 -> close the help window             */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
ShowHelpMessage:
  parse arg helpNo .

  if prog.ShowHelp = 0 then
    return

                        /* close the help window */
  if helpMsgs.HelpWindowID <> '' then
    call VCloseWindow helpMsgs.helpWindowID
  helpMsgs.helpWindowID = ''

  if helpNO <> 0 then
  do
                        /* calculate the width for the window         */
    j = 10
    do i = 1 to helpMsgs.helpNo.0
      j = max( j, length( helpMsgs.helpNo.i ) )
    end /* do i = 1 to helpMsgs.helpNo.0 */

    j = trunc( 100 - (j * prog.DisplayAdapterDelta) ) / 2
    if j < 5 then
      j = 5

                        /* caclculate the height of the window        */
    if symbol( 'helpmsgs.helpNo.Faktor' ) <> 'VAR' then
      curfaktor = 5
    else
      curfaktor = helpMsgs.helpNo.faktor

    pos.left = j
    pos.right = 100 - j
    pos.bottom = 95 - (helpMsgs.helpNo.0 * curFaktor )
    pos.top = 95

                        /* create the window                          */
    call VDialogPos 10 10
    HelpMsgs.helpWindowID = VOpenWindow( prog.Name ' - Help ', helpMsgs.BackColor , pos )
    call VDialogPos dialogs.X dialogs.Y

                        /* calculate the space between the lines      */
    if symbol( 'helpmsgs.helpNo.Delta' ) <> 'VAR' then
      curDelta = 100
    else
      curDelta = helpMsgs.helpNo.Delta

                        /* write the help messages                    */
    if symbol( 'helpmsgs.helpNo.StartY' ) <> 'VAR' then
      posY = 800
    else
      posy = helpMsgs.helpNo.StartY

    do i = 1 to helpMsgs.helpNo.0
      call VSay HelpMsgs.helpWindowID, 20, posY, helpMsgs.helpNo.i
      posY = posY - curDelta
    end /* do i = 1 to helpMsgs.helpNo.0 */
  end /* if helpNo <> 0 then */
RETURN

/* ------------------------------------------------------------------ */
/* ShowStatusMessage                                                  */
/*                                                                    */
/* Function: Build and show the compile in progress message           */
/*                                                                    */
/* Usage:    ShowStatusMessage                                        */
/*                                                                    */
/* where:                                                             */
/*                                                                    */
/* returns:  coordinates for the status message (e.g "50,70")         */
/*                                                                    */
ShowStatusMessage:

                        /* calculate the width for the window         */
  j = max( 45                          ,,
           length( sourceFile )        ,,
           length( targetFile )        ,,
           length( copyrightFile )     ,,
           length( options )           ,,
           length( compiler.UsedName ) ,,
         )

  j = trunc( 100 - (j * prog.DisplayAdapterDelta) ) / 2
  if j < 5 then
    j = 5

  pos.left = j
  pos.right = 100 - j
  pos.bottom = 50
  pos.top = 95

                        /* create the window                          */
  status.windowID = VOpenWindow( prog.Name ' - Status window ', dialogs.MsgBackColor , pos )

  msgDelta = 75

  posY = 910
  call VForeColor status.windowID, dialogs.msgForeColor1
  call VSay status.windowID, 50, posY, 'Compiling the source file'

  posY = posY - msgDelta
  call VForeColor status.windowID, dialogs.msgForeColor2
  call VSay status.windowID, 70, posY,  sourceFile
  posY = posY - msgDelta
  call VForeColor status.windowID, dialogs.msgForeColor1
  call VSay status.windowID, 50, posY, 'to the target file '
  posY = posY - msgDelta
  call VForeColor status.windowID, dialogs.msgForeColor2
  call VSay status.windowID, 70, posY, targetFile
  posY = posY - msgDelta
  if copyrightFile <> '""' then
  do
    call VForeColor status.windowID, dialogs.msgForeColor1
    call VSay status.windowID, 50, posY, 'with the copyright file'
    posY = posY - msgDelta
    call VForeColor status.windowID, dialogs.msgForeColor2
    call VSay status.windowID, 70, posY, copyrightFile
    posY = posY - msgDelta
  end /* if copyrightFile <> '""' then */

  if options <> '' then
  do
    call VForeColor status.windowID, dialogs.msgForeColor1
    call VSay status.windowID, 50, posY, 'The compiler options are:'
    posY = posY - msgDelta
    call VForeColor status.windowID, dialogs.msgForeColor2
    call VSay status.windowID, 70, posY, options
    posY = posY - msgDelta
  end /* if options <> '' then */

  call VForeColor status.windowID, dialogs.msgForeColor1
  call VSay status.windowID, 50, posY, 'The compiler used is'
  posY = posY - msgDelta
  call VForeColor status.windowID, dialogs.msgForeColor2
  call VSay status.windowID, 70, posY, compiler.UsedName

  posY = posY - msgDelta
  call VForeColor status.windowID, dialogs.MsgForeColor3
  call VSay status.windowID, 50, posY, 'Status: Compiling ...'

                        /* save coordinates for status messages       */
  status.x = 50
  status.y = posY
RETURN

/* ------------------------------------------------------------------ */
/* GetNextParameter - get the next parameter                          */
/*                                                                    */
/* Usage: GetNextParameter                                            */
/*                                                                    */
/* where:                                                             */
/*                                                                    */
/* Returns: current Parameter or an empty string                      */
/*          The variable prog.parms holds the rest of the parameter   */
/*                                                                    */
GetNextParameter:
  prog.Parms = strip( prog.Parms )

  if left( prog.Parms, 1 ) = '"' then
    parse var prog.Parms '"' curParameter '"' prog.Parms
  else if left( prog.Parms, 1 ) = "'" then
    parse var prog.Parms "'" curParameter "'" prog.Parms
  else
  do
    parse var prog.Parms curParameter prog.Parms
    curParameter = strip( curParameter )
  end /* else */
RETURN curParameter

/* ------------------------------------------------------------------ */
/* WriteEA - create or update an EA of a file                         */
/*                                                                    */
/* Usage:   WriteEA "fileName" "eaName" "eaDdata"                     */
/*                                                                    */
/* where:   fileName - name of the file                               */
/*          eaName   - name of the ea                                 */
/*          eaData  - new data for the EA                             */
/*                                                                    */
/* Returns:    0 - ok                                                 */
/*          else - error loading the dlls                             */
/*                                                                    */
WriteEA: PROCEDURE expose (exposeList)
  parse arg '"' fileName '"' . '"' eaName '"' . '"' eaData '"' .

  thisRC = sysPutEA( fileName, eaName, eaData )

RETURN thisRC

/* ------------------------------------------------------------------ */
/* ReadEA - read an EA of a file                                      */
/*                                                                    */
/* Usage:   ReadEA "fileName" "eaName"                                */
/*                                                                    */
/* where:   fileName - name of the file                               */
/*          eaName   - name of the EA                                 */
/*                                                                    */
/* Returns: '' - error or EA not found                                */
/*          else data of the EA                                       */
/*                                                                    */
/*                                                                    */
ReadEA: PROCEDURE expose (exposeList)
  parse arg '"' fileName '"' . '"' eaName '"' dummy

  if sysGetEA( fileName, eaName, eaData ) <> 0 then
    eaData = ''

RETURN eaData

/* ------------------------------------------------------------------ */
/* LoadDlls - load the neccessary dlls                                */
/*                                                                    */
/* Usage: LoadDlls                                                    */
/*                                                                    */
/* Returns:  1 - ok                                                   */
/*           0 - error loading the dlls                               */
/*                                                                    */
LoadDlls: PROCEDURE expose (exposeList)

                        /* init the return code                       */
  thisRC = 1

                        /* load RexxUtil if not already loaded        */
  if rxFuncQuery( 'SysLoadFuncs' ) <> 0 then
  do
    if RxFuncAdd( 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' ) = 0 then
    do
      call SysLoadFuncs
      prog.RexxUtilLoaded = 1
    end /* if rxFuncQuery( SysLoadFuncs) <> 0 then */
  end /* if rxFuncQuery( ... */
  else
  do
                        /* RexxUtil already loaded, avoid dropping it */
                        /* at program end!                            */
    call SysLoadFuncs
    prog.RexxUtilLoaded = 2
  end /* else */

  if prog.RexxUtilLoaded = 0 then
  do
                              /* can not load the RexxUtil dll      */
    say prog.ErrorAttributess
    say ' ------------------------------------------------------------------ '
    say ' ' || prog.Name || ' - Unexpected error 998 detected!'
    say ''
    say ' The error message is: Can not load the "RexxUtil" dll'
    say ' ------------------------------------------------------------------ ' prog.NormalAttributes
    say ''
    thisRC = 0
  end /* if prog.RexxUtilLoaded = 0 then */

                        /* load VREXX2                                */
  call RxFuncAdd 'VInit', 'VREXX', 'VINIT'

  if rxfuncQuery( 'VInit' ) = 0 then
  do
    initcode = VInit()
    if initcode <> 'ERROR' then
      prog.VRexx2Loaded = 1
  end /* if rxFuncQuery( 'VInit' ) = 0 then */

  if prog.VRexx2Loaded = 0 then
  do
                              /* can not load the VREXX2 package    */
    say prog.ErrorAttributess
    say ' ------------------------------------------------------------------ '
    say ' ' || prog.Name || ' - Unexpected error 999 detected!'
    say ''
    say ' The error message is: Can not load the "VREXX2" package!'
    say ' ------------------------------------------------------------------ ' prog.NormalAttributes
    say ''

    thisRC = 0
  end /* if prog.VRexx2Loaded <> 0 then */

return thisRC

/* ------------------------------------------------------------------ */
/* error handler                                                      */

ErrorAbort:
  thisLineNo = sigl

                        /* change color to bright yellow on red       */
  say prog.ErrorAttributess
  say ' ------------------------------------------------------------------ '
  say ' ' || prog.Name || ' - Unexpected error ' || rc || ' in line ' || thisLineNo || ' detected!'
  say ''

                        /* if this is a compiled program, we can not */
                        /* show the sourceline                       */
  if sourceLine( thisLineNo ) <> '' then
  do
    say ' The line reads: '

    thisprefix = ' *-* '

                        /* handle multi line statements correct!      */
    do forever
      thisSourceLine = sourceLine( thisLineNo )
      say thisPrefix || thisSourceLine
      if right( strip( thisSourceLine) ,1,1 ) <> ',' then
        leave
      thisLineNo = thisLineNo +1
      thisPrefix = '     '
    end /* do forever */
  end /* if sourceLine( thisLineNo ) <> '' then */

  if datatype( rc, 'W' ) = 1 then
    if rc > 0 & rc < 100 then
    do
      say ''
      say ' The REXX error message is: ' errorText( rc )
    end /* if datatype( rc, 'W' ) = 1 then */

  say ' ------------------------------------------------------------------ ' prog.NormalAttributes
  say ''

  prog.ExitCode = 255
/*
  trace ?a
  nop
*/
signal ProgramEnd

/* break handler */
UserAbort:
    say prog.ErrorAttributess
    say ' ------------------------------------------------------------------ '
    say ' ' || prog.Name || ' - Unexpected error 997 detected!'
    say ''
    say ' The error message is: Program aborted by the user!'
    say ' ------------------------------------------------------------------ ' prog.NormalAttributes
    say ''

  prog.ExitCode = 254
signal ProgramEnd

