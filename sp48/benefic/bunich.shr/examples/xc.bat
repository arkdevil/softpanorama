@echo off
  if %1.==. goto :Missing
  mb F=sub(1,1,"%1")
  mb T=sub(2,1,"%1")
  xcopy %F%: %T%: /s
  goto :Fin
:Missing
  echo XC: operand needed
:Fin
