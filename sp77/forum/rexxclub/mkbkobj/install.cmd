/*

   Installs the MkBkObj utility on the Desktop

   (C) 1994 by Ralf G. R. Bergs <rabe@pool.informatik.rwth-aachen.de>
   Released as "Freeware"

 */

'@echo off'

Call RxFuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Say "Where do you want to install MkBkObj?"
pull dest
'copy' MkBkObj.cmd dest

ret = SysCreateObject( 'WPProgram', 'Make Book^Object', '<WP_DESKTOP>', ,
        'OBJECTID=<MkBkObj>;EXENAME=' || dest || '\MkBkObj.CMD', 'U' )
