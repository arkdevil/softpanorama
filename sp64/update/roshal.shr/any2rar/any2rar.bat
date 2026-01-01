@Echo off
echo 
*** Total repack started. *** 

if exist *.arj call arj2rar *.arj
if exist *.zip call zip2rar *.zip
if exist *.lzh call lzh2rar *.lzh
if exist *.ice call ice2rar *.ice
:Exit
echo 
_______________________________________________________

echo ANY archive *.* -} *.rar (total) repack finished.

