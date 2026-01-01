/*

   MkBkObj - create a "book"/documentation object

   (C) 1994 by Ralf G. R. Bergs <rabe@pool.informatik.rwth-aachen.de>
   Released as "Freeware"

   accepts as parameters path specs to doc files
   creates a program object that calls VIEW.EXE if the path specs points
     to an .INF files, otherwise calls E.EXE

 */

'@echo off'

if arg()>0 then do

  Call RxFuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  Call SysLoadFuncs

  do i=1 to words( arg( 1 ) )
    path = word( arg( 1 ), i )

    /* separate "stem" and extension
       example:
         C:\DOS\KEYB.COM: name="KEYB", ext="COM" */

    name = filespec( "name", path )
    p = pos( ".", name )
    if p>0 then do
      ext = substr( name, p+1, length(name)-p )
    end
    else do
      ext = ''
    end
    stem = substr( name, 1, p-1 )

    if translate( ext ) = "INF" then do
      viewer = "VIEW.EXE"
    end
    else do
      viewer = "E.EXE"
    end

    ret = SysCreateObject( 'WPProgram', Name, '<WP_DESKTOP>', ,
        'OBJECTID=<Bk_' || Stem || '>;EXENAME=' || viewer || ';PARAMETERS=' ,
        || path, 'U' )
  end /* do i=1 to arg() */
end /* if arg()>0 */