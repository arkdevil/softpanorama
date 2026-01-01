{$M 3024,0,0}
{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
program TBExec;
uses Dos,TBextend;

var
  Command: string[127];
  Sdir : PathStr;
begin
      GetDir(0,Sdir);
      Command:=ParamStr(1)+' '+ParamStr(2)+' '+ParamStr(3)+' '+ParamStr(4)+' '+
               ParamStr(5)+' '+ParamStr(6)+' '+ParamStr(7)+' '+ParamStr(8)+' '+
               ParamStr(9);

      SwapVectors;
      Exec(GetEnv('COMSPEC'), '/C ' + Command);
      SwapVectors;

      if DosError <> 0 then
           WriteLn('Ошибка при работе TBEXEC.EXE: DosError=',DosError);

      ChDir(Sdir);

  TBEXIT;

end.
