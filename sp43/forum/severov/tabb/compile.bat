REM это файл компилирующий программу TABB.PRG
REM -----------------------------------------
clipper tabb /n/w/a/i\CLP\INCLUDE
rtlink fi tabb,getsys li \clp\lib\CLD,\clp\lib\CLIPPER,\clp\lib\DBFNTX,\clp\lib\EXTEND,\clp\lib\TERMINAL
del tabb.obj
