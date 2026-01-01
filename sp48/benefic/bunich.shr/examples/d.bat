@echo off
  MB P=DOS(GetDate d.m.y)
  echo ---------------------------- %P%>PRN
  MB P=sub(1,1,"%1")
  If NOT '%1'=='' GoTo :SetPar
:OnlyDir
  dir/a/o %1 %2>PRN
  GoTo :Fin
:SetPar
  If '%1'=='/2' GoTo :Col2_4
  If NOT '%1'=='/4' GoTo :Arch
:Col2_4
  ndos.com /c dir %1v %2 %3>prn
  GoTo :Fin
:Arch
  If '%P%'=='/' GoTo :OnlyDir
  rv %1 %2 %3>PRN
:Fin
  Set P=
