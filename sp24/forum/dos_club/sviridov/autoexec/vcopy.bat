@Echo off
Echo [22;8HCopying to virtual drive %VDISK%
Call Vcop D:\Bin\Command.com
Call Vcop D:\Bin\Command_.com
Call Vcop D:\Norton\Nc.ini
Call Vcop D:\Norton\Nc.mnu
Call Vcop D:\Norton\Nc.ext
Call Vcop D:\Norton\Nc.exe
Call Vcop D:\Norton\NcMain.exe
Call Vcop D:\Bin\What.exe
Call Vcop D:\Bin\Attr.com
Call Vcop D:\Bin\List.com
Call Vcop D:\Bin\Pkunpak.exe
Call Vcop D:\Norton\Ne.com
Call Vcop D:\Bin\Pkunzip.exe
Call Vcop D:\Bin\Ice.exe
Call Vcop D:\Bin\Narc.exe
Md %VDISK%\Bat
Echo [24;7H                                     [24;7HD:\Bat\*.Bat
Pkunpak -r D:\Bat\!bats.arc %VDISK%\Bat >nul
Ren F:\Command.com _Command.com
Ren F:\Command_.com Command.com
