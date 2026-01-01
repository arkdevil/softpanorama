USES
     DskTools,
     DrvTools;

begin

Write (^J^M^J^M^J^M'');

Write ('XMS Driver ______ ');
if XMSDrvInstalled Then WriteLn('     installed')
                     else WriteLn(' not installed');
Write ('ANSI.SYS ________ ');
if AnsiSysInstalled Then WriteLn('     installed')
                    else WriteLn(' not installed');
Write ('F_Defender ______ ');
if F_DefenderInstalled Then WriteLn('     installed')
                       else WriteLn(' not installed');
Write ('CACHE ___________ ');
if CacheActive       Then WriteLn('     installed')
                     else WriteLn(' not installed');
Write ('800 II __________ ');
if Drv800Installed Then WriteLn('     installed')
                   else WriteLn(' not installed');
Write ('VIDRAM __________ ');
if VidRAMInstalled Then WriteLn('     installed')
                   else WriteLn(' not installed');
Write ('EGA2MEM _________ ');
if EGA2MemInstalled Then WriteLn('     installed')
                    else WriteLn(' not installed');
Write ('GRAPHICS.COM ____ ');
if GraphicsInstalled Then WriteLn('     installed')
                     else WriteLn(' not installed');
Write ('GRAFTABL.COM ____ ');
if GrafTablInstalled Then WriteLn('     installed')
                     else WriteLn(' not installed');
end.
