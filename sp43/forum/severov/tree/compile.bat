REM это файл компилирующий программу TREE.PRG
REM -----------------------------------------
clipper tree /i\CLP\INCLUDE
rtlink fi tree,getsys li \clp\lib\CLD,\clp\lib\CLIPPER,\clp\lib\DBFNTX,\clp\lib\EXTEND,\clp\lib\TERMINAL
del tree.obj
