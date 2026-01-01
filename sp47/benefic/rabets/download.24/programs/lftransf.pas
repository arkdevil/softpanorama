{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V-}
{$M 16384,0,0}

program LoadFontTransfer; {V.S. Rabets 6-3-92 20:00}
     {Программка для извлечения изображений символов 24-иголочных загружаемых
      фонтов}
uses DOS, RVS;

const Copr = 'Load Font Transfer. (C) V.S. Rabets 1992';
var sf, tf: file;   {Files источник и приемник}
    SFname, TFname: PathStr;  {их имена}
    Char1st, CharLast, Tchar1, Tchar2: char; {1st и Last - диапазон-источник,
                                           Tchar1, Tchar2 - диапазон-приемник}
    S: string[5];
    Found: boolean;  {true если в файле-источнике извлекаемые символы найдены}
    R: array [1..2] of char;

procedure Help;
begin TA:=15;
  writeln ('Usage:'#13#10+
           '        LFTransf  SourceFile char1[..char2] TargetFile [char]'#10);
  writeln ('char2 can''t be less then char1.');
  writeln ('Expression "char1..char2" can''t contain spaces'#10#7);
  halt (1);
end;

procedure GetParameters;
var S: string[5];
begin
  if not (ParamCount in [3,4]) then Help;
  SFname:=ParamStr(1);  TFname:=ParamStr(3);
  S:=ParamStr(2); Char1st:=S[1];
  if length(S)=1 then CharLast:=S[1]
     else if (length(S)<>4) or (copy(S,2,2)<>'..') then Help
             else CharLast:=S[4];
  if CharLast<Char1st then Help;
  if ParamCount=3 then Tchar1:=Char1st
     else begin S:=ParamStr(4); Tchar1:=S[1]; if length(S)>1 then Help; end;
  if byte(CharLast)-byte(Char1st)>255-byte(Tchar1) then
     Error ('Target range out of available range (..255)');
  byte(TChar2):=byte(Tchar1)+(byte(CharLast)-byte(Char1st));
end;

procedure Pass (begR, endR: char; Transfer: boolean);
var Ch: char;
    Width: word;
    Buf: array [1..3+3*256] of byte;
begin for Ch:=begR to endR do
  begin BlockRead(sf,Buf,3);  {считаны в Buf[1] - левое поле}
                                        {Buf[2] - ширина символа}
                                        {Buf[3] - правое поле}
    Width:=Buf[2]*3;
    BlockRead(sf,Buf[4],Width);
    if Transfer and(Ch in [Char1st..CharLast]) then BlockWrite(tf,Buf,3+Width);
  end;
end;

{------------------------------------------------}
begin
  writeln (Copr);
  GetParameters;
  Open (sf, 'R', SFname);
  repeat BlockRead(sf,S[1],5); R[1]:=S[4]; R[2]:=S[5]; S[0]:=#3;
    if S<>#27#38#0 then Error ('Invalid file '+SFname+' format');
    writeln ('Found range ', R[1], '..', R[2]);
    Found:=(Char1st in [R[1]..R[2]]) and (CharLast in [R[1]..R[2]]);
    if not found then Pass(R[1],R[2],false)
  until Found or EOF(sf);
  if not Found then Error ('Range '''+Char1st+''''+'..'+''''+CharLast+''''+
                              ' is absent in '+SFname);
  Open (tf, 'W', TFname); S:=#27#38#0+Tchar1+Tchar2;
  if Yes ('Add prefix  '+S+'  to target file', 2) then BlockWrite(tf,S[1],5);
  Pass (R[1],R[2],true);
  Fclose(sf); Fclose(tf);
end.
