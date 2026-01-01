@D:\Bin\Etc\Passwd E:\Etc\Password. E:\Etc\!Syslog.
@Echo off
D:\Bin\Etc\Chmod >nul
D:\Bin\Etc\Prot-c
Set SYSLOG=E:\Etc\!Syslog.
C:\Sys\Avb C:\Sys\Avb.dat >nul
if errorlevel 5 goto Bootch
if errorlevel 4 goto Partch
if errorlevel 3 goto Hardderr
if errorlevel 2 goto Filenf
goto TESTOK
:Bootch
Cls
Echo.
Echo.
Echo   Boot information changed !!! 
Echo          Boot information changed !!!>>%SYSLOG%
goto Virusmb
:Partch
Cls
Echo.
Echo.
Echo   Partition table changed !!! 
Echo          Partition table changed !!!>>%SYSLOG%
:Virusmb
Echo   Your system may be infected by VIRUS !!!
goto Errcnt
:Hardderr
Echo.
Echo   Hard Disk Error during Boot Antivirus check 
goto Errcnt
:Filenf
Echo.
Echo   return 2
goto QU
:Errcnt
Echo.
Echo   Please, notify Sviridov I.A., Ph. # 263-87-70, Kiev
Echo.
Echo.
Echo   Press any key to continue ( it may be dangerous ! ).
Pause >nul
:TESTOK
D:\Bin\Etc\Drive_a ON
If Errorlevel 1 Echo 
Break on
C:\Sys\Disks
if not errorlevel 9 goto NOVIRT
Set VDISK=F:
Copy C:\Sys\Autovirt.Bat %VDISK%\ >nul
If Not Exist %VDISK%\Autovirt.Bat goto NOVIRT
C:\Sys\AutoRes
:NOVIRT
Set VDISK=Nul:
C:\Sys\AutoRes
