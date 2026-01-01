vswitch.exe: vswitch.obj
        link /PM:VIO /STACK:2048 vswitch.obj, vswitch.exe,nul /A:16 /BA /E /F /PACKC;

vswitch.obj: vswitch.c
        cl /W4 /MT /AL /Osxaz /G2r /Lp /Zp /BATCH vswitch.c

