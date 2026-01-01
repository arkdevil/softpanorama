@rem    This batch file saves Far settings from the registry
@rem    to files FarSave1.reg and FarSave2.reg

regedit /e FarSave1.reg HKEY_CURRENT_USER\Software\Far
regedit /e FarSave2.reg HKEY_LOCAL_MACHINE\Software\Far
