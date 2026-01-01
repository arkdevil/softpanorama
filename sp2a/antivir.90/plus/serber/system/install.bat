@Echo off
if /%1==/ goto Help
if %2==\ goto Other
Md %1%2
:Other
Echo Device = %1%2\CerbDrv.Sys >> %1\tmp
ren config.sys config.old
copy Config.old + tmp config.sys 
del tmp
Copy/B  *.* %1%2 > Nul
%1
cd %2
Cerberus
goto EndBat
:Help
Echo Copyright (C) : Ideas & Service , 1990
Echo Usage :
Echo        Install Drive: Path
:EndBat
Echo On
