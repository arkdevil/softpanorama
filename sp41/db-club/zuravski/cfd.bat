@echo off
c:
cd c:\sx\cfd
pkunzip cfd *.dbf *.fxp *.com *.exe>nul
foxprort cfd
ASK 'DBF has been UPDATED ?(Y/N)',NY
if errorlevel = 2 pkzip cfd mat.dbf
del *.fxp>nul
del *.com>nul
del *.exe>nul
del *.dbf>nul
del *.idx>nul
cd c:\