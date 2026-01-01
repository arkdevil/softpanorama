@echo off

:This batch file uses the FILEAGE program to tell whether the 
:Connect2 NETMGR.QUE file has been updated in the last 90 minutes or
:so.  I keep the Connect2 system polling a lot so if it
:hasn't then the Mail Gateway is locked up.  If so we need to
:bark at the Supervisor to reset the system. 

:I don't know if this works on Novell MHS or GMHS.  It all depends on
:whether it has a NETMGR.QUE file (I don't recall if it uses this file).
:You might have to check for another file.

if (%1)==() %0 SUPERVISOR
fileage %MV%MHS\MAIL\PUBLIC\NETMGR.QUE
if errorlevel 90 SEND "E-Mail Gateway is off-line,  Please Reset It!" TO %1