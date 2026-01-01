/* Compares current directory to zip file.		  */
/* Deletes files that no longer exist after confirmation. */

parse arg windos winos2
if winos2='' | windos='' then do
  '@prompt'
  say "This utility will fix winos2 so that it may be used from MSDOS."
  say "Then you don't have to keep a copy of Windows 3.1 on your hard drive."
  say "It does this by changing three files in your \OS2\MDOS\WINOS2\SYSTEM"
  say "directory each time you boot."
  say ""
  say "In order to use this program you must first install Microsoft"
  say "Windows 3.1 (3.11 might work.)  This must be installed from DOS."
  say "Go ahead and install any video drivers if you like."
  say ""
  say "Then from OS/2 you need to install WINOS2 to a FAT partition."
  say "If your OS2 drive is HPFS, you will need to hit the MORE button"
  say "next to WINOS2 support and change the drive letter when you"
  say "install.  When you setup the WINOS2 desktop, be sure to tell"
  say "OS2 to copy the existing Microsoft Windows 3.1 desktop."
  say ""
  say "Finally, run this program specifying the complete path of MS Windows"
  say "and WINOS2 in that order.  This will copy a bunch of files from"
  say "your MS Windows to WINOS2 and change your MSDOS autoexec.bat and"
  say "OS/2 config.sys.  Then, everytime you reboot, wdisplay.exe will be"
  say "run to copy 3 files to your \OS2\MDOS\WINOS2\SYSTEM directory and"
  say "set the display.drv line in your system.ini."
  say "WARNING: This may not work right on a dual-boot system."
  say ''
  say "This program is donated to the public domain by Scott Maxwell."
  '@pause'
  say ''
  say "Usage: fix-os2 <ms_windows_path> <winos2_path>"
  exit(1)
end

if substr(winos2,2,2) \= ':\' then do
   say "Path name must include drive letter and '\' -" winos2
   exit(1)
end
if Right(winos2,1) = '\' then
    winos2 = Left(winos2,length(winos2)-1)
if Stream(winos2'\system\os2k386.exe', 'C', 'QUERY EXISTS') = '' then do
    say winos2 "does not appear to contain WINOS2"
    exit(1)
end

if substr(windos,2,2) \= ':\' then do
   say "Path name must include drive letter and '\' -" windos
   exit(1)
end
if Right(windos,1) = '\' then
    windos = Left(windos,length(windos)-1)
if Stream(windos'\system\krnl386.exe', 'C', 'QUERY EXISTS') = '' then do
    say windos "does not appear to contain MS Windows"
    exit(1)
end

  doslen = Length(windos)
  os2len = Length(winos2)
  CALL RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
  Call SysLoadFuncs
  Call SysFileTree windos'\*','dosdirs','DSO'
  do i=1 to dosdirs.0
    Call SysMkDir topath(dosdirs.i)
  end

  say "Copying MS Windows files to" winos2
  Call SysFileTree windos'\*','dosfiles','FSO'
  Call SysFileTree winos2'\*','os2files','FSO'
  do i = 1 to os2files.0
    hold = translate(SubStr(os2files.i,os2len+1))
    os2files.hold = 1
    drop os2files.i
  end
  do i = 1 to dosfiles.0
    hold = translate(SubStr(dosfiles.i,doslen+1))
    if os2files.hold \= 1 then do
      "@copy" dosfiles.i topath(dosfiles.i) "> nul"
      say "Copying" dosfiles.i
    end
  end
  say "Making OS/2 and MS-DOS directories"
  Call SysMkDir winos2'\SYSTEM\DOS'
  Call SysMkDir winos2'\SYSTEM\OS2'
  "@copy" winos2"\SYSTEM\user.exe" winos2"\SYSTEM\OS2 > nul"
  "@copy" winos2"\SYSTEM\gdi.exe" winos2"\SYSTEM\OS2 > nul"
  "@copy" winos2"\SYSTEM\mouse.drv" winos2"\SYSTEM\OS2 > nul"
  "@copy" windos"\SYSTEM\user.exe" winos2"\SYSTEM\DOS > nul"
  "@copy" windos"\SYSTEM\gdi.exe" winos2"\SYSTEM\DOS > nul"
  "@copy" windos"\SYSTEM\mouse.drv" winos2"\SYSTEM\DOS > nul"
  say "Fixing AutoExec.Bat and Config.Sys"
  call 'Search' "C:\AutoExec.Bat" windos winos2
  call 'Search' "C:\Config.Sys" windos winos2
  call SysFileSearch "wdisplay","C:\AutoExec.Bat",'line.','N'
  if line.0 = 0 then do
     say "Adding WDisplay.Exe to C:\AutoExec.Bat"
     hold = charin("C:\AutoExec.Bat",,Chars("C:\AutoExec.Bat"))
     call charout "C:\AutoExec.Bat"
     call SysFileDelete 'c:\autoexec.bat'
     call charout "C:\AutoExec.Bat",winos2"\wdisplay "winos2"\system.ini"'0d0a'x||hold
     call charout "C:\AutoExec.Bat"
  end
  root=FileSpec('Drive',Value('SYSTEM_INI',,'OS2ENVIRONMENT'))
  Say "Fixing" root"\Config.Sys"
  call SysFileSearch "wdisplay",root"\Config.Sys",'line.'
  if line.0 = 0 then do
     say "Adding WDisplay.Exe to" root"\Config.Sys"
     call charout root"\Config.Sys","CALL="winos2"\wdisplay.exe"'0d0a'x
     call charout root"\Config.Sys"
  end

  say "Fixing ProgMan.Ini"
  call 'Search' winos2"\ProgMan.Ini" windos winos2

  say "Fixing System.Ini"
  call SysFileSearch "display.dos",winos2"\System.Ini",'line.'
  if line.0 = 0 then do
     call SysFileSearch "display.drv",windos"\System.Ini",'line.'
     do lnum = 1 to line.0
	if Translate(Left(line.lnum,11)) = "DISPLAY.DRV" then leave
     end
     file = winos2"\System.Ini"
     lp = LastPos('.',file)
     bakfile = Left(file,LastPos('.',file))'bak'

     if Stream(bakfile,'C','QUERY EXISTS') \= '' then
	call SysFileDelete bakfile
  
     '@ren' file bakfile '> nul'
     l = ''
     do while l \= "[boot]"
	l = linein(bakfile)
	call lineout file, l
     end
     call lineout file,Left(line.lnum,8)'dos'SubStr(line.lnum,12)
     do while lines(bakfile)
	l = linein(bakfile)
	call lineout file,l
     end
     call lineout bakfile
     call lineout file
  end
  '@copy wdisplay.exe' winos2' > nul'
  
exit(0)

topath:
  arg name
  return winos2||SubStr(name,doslen+1)

Directory: procedure
  arg Name
  if Length(Name) > 3 then
    if Right(Name,1) = '\' then
      Name = Left(Name,LENGTH(Name)-1)
  n = 'DIRECTORY'(Name)
  if Right(n,1) \= '\' then
    n = n'\'
  return n
