{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V-}
{$M 16384,0,0}

program LoadFontMargins; {V.S. Rabets 9-3-92 21:00}
     {Программка для изменения свободного пространства вокруг
      изображений символов 24-иголочных загружаемых фонтов}
uses DOS, RVS;

const Copr = 'Load Font Margins.  (C) V.S. Rabets 1992';
      DnLoad = #27#38#0; {Команда загрузки шрифта}
      MinCharWidth = 5;       {Min ширина символа, колонок}
      MaxLQcharWidth = 42;    {Max ширина символа LQ,    колонок}
      MaxDraftCharWidth = 12; {Max ширина символа Draft, колонок}
      MaxCharWidth = MaxLQcharWidth; {= либо MaxLQcharWidth, }
                                     {  либо MaxDraftCharWidth}
var sf, tf: file;   {Files источник и приемник}
    SFname, TFname: PathStr;  {их имена}
    S: string[5]; {В 1..3 байты считывается команда DnLoad, в 4..5 - диапазон}
                                                                   { символов}
    Total: byte;
const Left: byte = 4;
      Right:byte = 4;
      Prop: boolean = true;  {mode Proportional}
      ClearBlank:boolean = false; {удаление пустых колонок по краям символа}

procedure Help;
begin TA:=15;
  writeln ('Usage:'#13#10'        '+
      'LFmargin SourceFile TargetFile [/C] [/P|/10|/Tn]|[[/Ln][/Rn]]'+
       #10#7);
  halt (1);
end;

procedure Val (S:string; var I: byte);
var code: integer;
begin System.Val(S,I,code); if code>0 then Help; end;

procedure GetParameters;
var b: byte;
begin if not (ParamCount in [3..5]) then Help;
      SFname:=ParamStr(1);  TFname:=ParamStr(2);
      for b:=3 to ParamCount do
      begin S:=ParamStr(b); S[2]:=UpCase(S[2]);
        if S='/C'  then ClearBlank:=true                         else
        if S='/P'  then begin Prop:=true; Left:=4; Right:=4; end else
        if S='/10' then begin Prop:=false; Total:=36;        end else
        if (S[1]<>'/') or (S[0]<#3) then Help                    else
        case  S[2] of
             'T': begin Prop:=false;Val(copy(S,3,255),Total); end;
             'L': begin Prop:=true; Val(copy(S,3,255),Left);  end;
             'R': begin Prop:=true; Val(copy(S,3,255),Right); end;
              else Help;
        end; {of case}
      end;
      if ClearBlank and (ParamCount=3) then Help; {должна быть заданы поля}
end;

procedure SFormatError;
begin Error ('Invalid file '+SFname+' format'); end;

procedure BlockRead(var f:file; var Dat; Size: word);
var Result: word;
begin  System.BlockRead (f, Dat, Size, Result);
       if Result<>Size then SFormatError;
end;

procedure Pass (begR, endR: char);
var Sym: array [1..MaxCharWidth+1,  1..3] of byte;   {изображение символа}
    Width: array [1..3] of byte;  {ширины символов}
    Ch: char;
    b, t, beg, en: byte;
begin for Ch:=begR to endR do  {по всему диапазону символов}
  begin BlockRead(sf,Width,3);   {считаны в Width[1] - левое поле}
                                           {Width[2] - ширина символа}
                                           {Width[3] - правое поле}
     if Width[2]>MaxCharWidth then SFormatError;
     BlockRead(sf,Sym,Width[2]*3);

     if ClearBlank then   {удаление пустых колонок по краям символа:}
     begin beg:=Width[2]; en:=1;
       for b:=Width[2] downto 1 do    for t:=1 to 3 do      {из начала}
                                         if Sym[b][t]>0 then beg:=b;
       move (Sym[beg,1],Sym[1,1],SizeOf(Sym));  dec(Width[2],pred(beg));
      for b:=1 to Width[2] do    for t:=1 to 3 do      {из конца}
                                        if Sym[b][t]>0 then en:=b;
      Width[2]:=en;
       for b:=Width[2]+1 to MinCharWidth do   for t:=1 to 3 do   Sym[b][t]:=0;
       if Width[2]<MinCharWidth then Width[2]:=MinCharWidth;
     end;

     if Prop then begin Width[1]:=Left; Width[3]:=Right end
        else begin Width[1]:=0; Width[3]:=0;
                   if Width[2] < Total then
                   begin Width[1]:=(Total-Width[2]) div 2;
                         Width[3]:= Total-Width[2]-Width[1];
                   end
             end;
     if (Width[1]+Width[2]+Width[3])>MaxCharWidth then
        writeln('':10, 'WARNING: character ''',Ch,''' too wide');

     BlockWrite(tf,Width,3);
     BlockWrite(tf,Sym,Width[2]*3);
  end;
end;

{------------------------------------------------}
begin
  writeln (Copr);
  GetParameters;
  Open (sf, 'R', SFname);  Open (tf, 'W', TFname);
  repeat BlockRead(sf,S[1],5);  S[0]:=#3;
    if S<>DnLoad then SFormatError;
    writeln ('  Processing range ', S[4], '..', S[5]);
    BlockWrite (tf,S[1],5);
    Pass (S[4],S[5]);
  until EOF(sf);
  Fclose(sf); Fclose(tf);
end.
