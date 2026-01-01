echo Example for J-CHECK executing
 j-check *.*
pause
echo Save listing to CHECK.DAT file.
 j-check *.*  > check.dat
pause
echo Check current file and CHECK.DAT
 j-check *.*  check.dat
