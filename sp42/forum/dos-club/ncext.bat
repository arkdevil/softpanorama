@echo off
REM В строке NC.EXT:
REM ext: ncext <d:> \path programname !:!\!.! !: !\
%1
cd %2
%3 %4
%5
cd %6
