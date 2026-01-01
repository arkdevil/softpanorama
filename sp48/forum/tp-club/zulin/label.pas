{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S+,V+,X-}
{$M $4000,$8000,$8000}
{
    ┌──────────────────────────────────────────────────────────┐
    │                                                           █
    │                     LABEL (FREEWARE)                      █
    │          Demonstration program to DSKTOOLS.TPU            █
    │             (C) BZSoft Inc., sep 1992.                    █
    │             (C) GalaSoft United Group International.      █
    │                      version 1.01                         █
    │                                                           █
    └─▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
}
program _Label;
uses
    {**************** BZSoft Inc. ***************}
    DskTools,
    {**************** Turbo Power ***************}
    TPCrt,
    TPEdit,
    TPString,
    TPWindow;

var Disk : char;
    i,
    ND   : byte;
    C,X,PY,
    Y    : byte;
    key  : word;
    sa,
    s,
    ss   : string;
    Escape,
    W,
    Ok   : boolean;
    Win  : WindowPtr;
    SSS  : array[1..26] of char;
    TTT  : array[1..26] of DiskClass;
    All  : boolean;

procedure Copyright; assembler; { глюк для RELEASE }
asm
	jmp	@go
	db	'(C) BZSoft Inc., v1.01 92'
@go:
end;

procedure Help;
begin
WriteLn;
WriteLn('        Данная программа предназначена для ввода и изменения метки тома.');
WriteLn('        По умолчанию разрешается изменение метки тома на гибких дисках и');
WriteLn('        разделах фиксированного диска. При указании  ключа /A (All) дос-');
WriteLn('        туп открывается к дискам,  образованным  драйверами,  но  всегда');
WriteLn('        запрещается изменение метки тома на сетевых, защищенных DiskReet');
WriteLn('        дисках, также переприсвоенных командами ASSIGN и SUBST.');
WriteLn('        Как Вы уже убедились, ключ /? (/H) вызывает эту подсказку.');
WriteLn('        Для выбора диска при работе ислользуются традиционно клавиши уп-');
WriteLn('        равления курсором, ESC - выход из программы, ENTER - запись вве-');
WriteLn('        денной метки или подтверждение готовности  устройства.  Допуска-');
WriteLn('        ется набор метки всеми символами таблицы  ASCII,  кроме  символа');
WriteLn('        Nul (#0), поддерживаются разделы фиксированного диска,  размером');
WriteLn('        более 32M. Допускается ввод метки и из  командной строки, но при');
WriteLn('        этом метка не должна содержать управляющие коды и  пробел  (сим-');
WriteLn('        волы с кодом менее 33 (21h)),максимальная длина 11 символов. При');
WriteLn('        вводе метки из командной строки опции запрещены!');
WriteLn('        Пример : LABEL C: SystemDisk');
WriteLn('                                  г.Шебекино (07248)4-51-96 Борис Зулин.');
Halt;
end;

procedure WriteError;
begin
 FastWriteWindow('!!!',4,19,156);
 FastWriteWindow( 'Ошибка ввода/вывода устройства '+
                  (SSS[c])+':',4, 23, 26);
 w := true;
end;

procedure WriteDiskName(N, C : byte);
var s : string;
begin
  s:=' '+SSS[N]+': ';
  if PhantomDisk(SSS[N]) Then s:=s+'Phantom' else
    case TTT[N] of
     Floppy        : s:=s+'Floppy ';
     HD0           : s:=s+'HD0    ';
     HD1           : s:=s+'HD1    ';
     BernoulliDisk : s:=s+'Bernoul';
     DeviceDriven  : s:=s+'Dev Dr ';
     VDisk, EgaDisk: s:=s+'Virtual';
    end; {case}
  FastWriteWindow(S,C,1,30)
end;

begin


DirectVideo := false; {Это чтобы при EGA2MEM и т.п. на EGA был виден курсор}
Copyright;            {ясно}

WriteLn(^M^J'   Label version 1.01, (C) Copyright BZSoft Inc., september 1992.');
WriteLn('   Portion copyright (C) GalaSoft United Group International, 1992.');

  if not AddEditCommand(RSuser0, 1, $4800, 00) Then Halt(1);
  if not AddEditCommand(RSuser1, 1, $5000, 00) Then Halt(1);

  if not DskToolsVarInit Then InitDiskVariable;

  All:=false; ND := 0; Shadow := true; SoundFlagW := false;
  Explode := false; ShadowAttr:=3;

  if ParamCount>0 Then {разбор ключей}
     begin
       s:=''; for i:=1 to ParamCount do s:=s+ParamStr(i);
       s:=StUpCase(s);
       if (pos('/?',s)>0) or (pos('/H',s)>0) or (pos('-H',s)>0) or
       (pos('-?',s)>0) then Help;
       All := (pos('-A',s)>0) or (pos('/A',s)>0);
     end;
  {режим командной строки}
  if ParamCount > 0 Then begin s:=ParamStr(1); {разбор указания метки тома}
     if (Length(s)>1) and (s[2]=':') Then begin
     if ParamCount>1 Then sa:=ParamStr(2) else sa:='';
     if Length(sa)>11 Then sa[0]:=#11; s[1]:=UpCase(s[1]);
     ss := s[1];
     key := SearchStr(DiskNameArray, NumDrive, 0, ss);
     if Key<NumDrive Then Inc(Key);
     if AvailableDisk(s[1]) and (key<=NumDrive) and
        (DiskTypeArray[Lo(key)] in [Floppy, BernoulliDisk, HD0, HD1,
        DeviceDriven, VDisk, EgaDisk]) Then begin
        if SetVolumeLabel(s[1], sa)>0 Then begin
           WriteLn('   Label:  Ошибка установки метки диска '+s[1]+':');
           Halt(2);
           end else Halt
        end;
     end;
  end;
  { диалоговый режим }
  if not MakeWindow( Win, 8, 9, 72, 17, true, true, true, 30, 31, 31, '')
     Then Halt(1);
  if not DisplayWindow(Win) Then begin KillWindow(Win); Halt(1) end;
  {строим таблицу имен}
  for y:=1 to NumDrive do
    case DiskTypeArray[y] of
     Floppy, HD0, HD1 :
             begin
               Inc(ND); SSS[ND]:=DiskNameArray[y];
               TTT[ND] := DiskTypeArray[y]
             end;
     BernoulliDisk, DeviceDriven,
     VDisk, EgaDisk:
            if All Then
               begin
                 Inc(ND); SSS[ND]:=DiskNameArray[y];
                 TTT[ND] := DiskTypeArray[y]
               end
    end; {case}
  {заполняем окно}
  if ND>7 Then Key:=7 else Key:=ND;
  if ND>7 Then s:=#30'│││││││'#31 else s:='╤│││││││╧';
  FastVert(s, 9,21,31);
  for y:=1 to Key do WriteDiskName(y,y);

  Y:= 1; c:=1; Ok := false;
  Disk := CurrentDriveChar; W:=false; HiddenCursor;
  if (TTT[c]=Floppy) or (PhantomDisk(SSS[c])) Then w:=true;

repeat {циклимся}
  ChangeAttributeWindow(12,y,1,112);
  if w Then
     begin
       FastWriteWindow(#16,4,19,159);
       FastWriteWindow('Подготовьте диск '+SSS[c]+': и нажмите ENTER',
      4, 21, 27);
     end;
  if not w Then begin FastWriteWindow(CharStr(' ',46),4,14,30);
     if GetVolumeLabel(SSS[c],sa)<>0 Then begin
        WriteError; Key:= ReadKeyWord; end
        else begin
             s:=sa; ReadString('Enter volume label : ',13,30,11,31,15,11,Escape,s);
             case RSCommand of
             RSQuit  : Key := $011B;
             RSEnter : begin
                        Key := $1C0D;
                        if s<>sa Then
                           if SetVolumeLabel(SSS[c],s)<>0
                           Then WriteError;
                       end;
             RSUser0 : Key := $4800;
             RSUser1 : Key := $5000;
             end
             end
     end else Key := ReadKeyWord;
  ChangeAttributeWindow(12,y,1,30);
  case Key of
   $011B : Ok := true; { esc }
   $4800 : if (y=1) and (c=1) Then if ND<8 Then begin
             Y:=ND; C:=ND; end else else
           if (y=1) and (c>1) Then begin
             Dec(c);
             for i:=c to c+6 do WriteDiskName(i,i-c+1);
           end else begin Dec(c); Dec(y); end; {up}
   $5000 :
           if c=ND Then
             if ND<8 Then begin y:=1; c:=1 end else
               else if y=7 Then begin
               Inc(c);
               for i:=c-6 to c do WriteDiskName(i,i+7-c)
               end
               else begin Inc(c); Inc(y) end; {down}
  end;
  if ((TTT[c]=Floppy) or (PhantomDisk(SSS[c])))
     and (Key<>$1C0D)
         Then w := true
         else w := false;
until Ok;
  SafeSetDisk(Disk);
  KillWindow(Win);
  NormalCursor;
end.
