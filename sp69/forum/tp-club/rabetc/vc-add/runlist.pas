{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 1120,0,0}
{BP 7.0}
{ В целях максимального высвобождения памяти для выполнения команд здесь ис- }
{ пользуются противоправные для Паскаля вещи, как то открытие текстового бу- }
{фера поверх неиспользуемого кода. В этих же целях освобождается Environment.}

uses DOS;

const CopyR = 'RunList, ver. 1.00. (C) V.S. Rabets, 1994';
      Parent = $16;  { Смещения в PSP }
      EnvPtr = $2C;
var CtrlBreak: byte absolute 0:$471;
    f: text;
    FileList: PathStr;
    Parameters, S: ComStr;
    Drive: string[2];
    Dir: DirStr;
    Name:NameStr;
    Ext: ExtStr;
    Echo: boolean;
    b: byte;

procedure WriteCopyR;   begin  writeln (#10+CopyR)  end;

procedure TextBufStart; assembler; asm end; { Метка начала текстового буфера }

procedure HelpRus;
begin
  WriteCopyR;
  writeln (#10'For English help type   RUNLIST /H'#10);
  writeln ('Формат запуска:   RunList  FileList Command Parameters'#10);
  writeln ('где FileList - файл со списком обрабатываемых файлов');
  writeln ('               (например, созданный макрокомандой !@ в VC.mnu).');
  writeln ('RunList для каждого файла из списка FileList запускает команду Command');
  writeln ('с параметрами Parameters (точнее, запускает %COMSPEC% /C Command Parameters),');
  writeln ('производя для каждого запуска следующие подстановки в Command и Parameters:');
  writeln ('   *.* заменяется на Имя_с_расширением текущуго файла из FileList');
  writeln ('   *              на Имя_файла_без_расширения');
  writeln ('   .*             на Расширение');
  writeln ('   *:             на Букву_диска: из имени файла');
  writeln ('   *\             на Путь');
  writeln ('   **             на *');
  writeln ('Возвращаемые значения ErrorLevel:');
  writeln ('    0 - успешное выполнение Command.com (не обязательно с правильной командой!)');
  writeln ('    1 - выдан справочный экран');
  writeln ('    2 - неправильные параметры либо ошибка запуска Command.com');
  writeln ('    255 - выполнение прервано пользователем по Ctrl-Break');
  write   ('Если команда начинается с @ - eё текст не выводится на экран (как в BAT-файлах)');
  halt (1);
end;

procedure HelpEng;
begin
  WriteCopyR;
  writeln (#10'For Russian help type   RUNLIST /?'#10);
  writeln ('         Usage:   RUNLIST  FILELIST COMMAND PARAMETERS'#10);
  writeln ('FILELIST - file with list of files to be processed');
  writeln ('               (for example created by macro !@ in VC.mnu).');
  writeln ('RUNLIST executes COMMAND with PARAMETERS for every file of list from FILELIST');
  writeln ('(or rather executes  %COMSPEC% /C COMMAND PARAMETERS) and performs following');
  writeln ('substitutions before each execution ',
           '(for both COMMAND and PARAMETERS):');
  writeln ('   *.* replaces by FileName_with_Extension of current file from FILELIST');
  writeln ('   *               FileName_without_Extension');
  writeln ('   .*              Extension');
  writeln ('   *:              Drive_Letter:');
  writeln ('   *\              Path');
  writeln ('   **              *');
  writeln ('Returned ERRORLEVEL:');
  writeln ('    0 - successful Command.com execution (may be with wrong COMMAND!)');
  writeln ('    1 - was in Help mode');
  writeln ('    2 - wrong parameters or can''t execute Command.com');
  writeln ('    255 - user interrupt (Ctrl-Break)');
  write   ('COMMAND with @ prefix executed without echo (like in BATCH-files)');
  halt (1);
end;

procedure ParamError (const Mes: string);
begin
  WriteCopyR;
  writeln (Mes, #13#10'Type  RUNLIST /H  - for English help,'#13#10 +
                      '      RUNLIST /?  - for Russian help.'#7);
  halt (2);
end;

procedure TextBufEnd; assembler; asm end;   { Метка конца текстового буфера }

procedure Error (const Mes: string);
begin
  WriteCopyR;
  writeln (Mes, #7);
  halt (2);
end;

procedure Replace (var S: ComStr; const Src, Dest: string);
var P: byte;
begin
  repeat
    P:=pos(Src,S);
    if P=0 then exit;
    delete (S, P, length(Src));
    insert (Dest, S, P);
  until false;
end;

begin
  FileList:=ParamStr(1);
  if FileList='/?' then HelpRus;
  if (FileList='/H') or (FileList='/h') then HelpEng;
  if FileList='' then ParamError ('Insufficient number of parameters.');
  if ParamStr(2)='' then ParamError ('COMMAND to be executed missing.');
  asm
     mov  ES,PrefixSeg
     mov  ES,ES:EnvPtr
     mov  AH,49h
     int  21h
  end;
  MemW[PrefixSeg:EnvPtr] := MemW[ MemW[PrefixSeg:Parent] : EnvPtr];

  assign (f, FileList);
  SetTextBuf (f, (@TextBufStart)^, ofs(TextBufEnd) - ofs(TextBufStart));
  reset (f); if IOResult>0 then Error ('Can''t open file '+FileList);
  while not EOF(f) do begin
      CtrlBreak:=CtrlBreak and not 128;
      readln (f, S); if IOResult>0 then Error('Error reading file '+FileList);
      FSplit (S, Dir, Name, Ext);       Drive:='';
      if copy (Dir, 2,1)=':' then begin Drive:=Dir; delete (Dir,1,2) end;
      Parameters:='/C';
      for b:=2 to ParamCount do begin
          S:=ParamStr(b);
          if b=2 then begin Echo:=copy(S,1,1)<>'@'; { ParamStr(2)=Command }
                            if not Echo then delete(S,1,1);
          end;
          Replace (S, '**', #13);  { #13 не может появиться в Cmd. строке }
          Replace (S, '*.*', Name+Ext);
          Replace (S, '*:',  Drive);
          Replace (S, '*\',  Dir);
          Replace (S, '.*',  Ext);
          Replace (S, '*',   Name);
          Replace (S, #13,  '*');
          Parameters:=Parameters + ' ' + S;
      end;
      GetDir (0,S);
      if Echo then writeln (copy(S,1,1), '>', copy (Parameters,3,255));
      Flush (OutPut);
         SwapVectors;
         Exec(GetEnv('COMSPEC'), Parameters);
         SwapVectors;
      if DosError>0 then Error ('Can''t execute '+ GetEnv('COMSPEC'));
      if CtrlBreak>=128 then begin
         write ('Terminate RunList job ? (Y/N) '#7);
         repeat readln(S[1]); S[1]:=UpCase(S[1]); if S[1]='Y' then halt(255);
         until S[1]='N';
      end;
  end;
  close (f);  if IOResult>0 then Error ('Can''t close file '+FileList);
end.
