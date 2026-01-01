{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V-}
{$M 16384,0,0}

program LoadFontDrafter; {V.S. Rabets 6-3-92 21:00}
     {Программка для преобразования 24-иголочных
      загружаемых фонтов: из LQ в Draft}
uses DOS, RVS;

const Copr = 'Load Font Transformator (LQ ──>Draft).  (C) V.S. Rabets 1992';
      DnLoad = #27#38#0;      {Команда загрузки шрифта}
      MaxLQcharWidth = 42;    {Max ширина символа LQ,    колонок}
      MaxDraftCharWidth = 12; {Max ширина символа Draft, колонок}
const Left: boolean = false;   {сужение всех линий на 1 по горизонтали}
        Up: boolean = false;   {расширение всех линий на 1 вверх}
      Down: boolean = false;   {расширение всех линий на 1 вниз}
var sf, tf: file;   {Files источник и приемник}
    SFname, TFname: PathStr;  {их имена}
    S: string[5]; {В 1..3 байты считывается команда DnLoad, в 4..5 - диапазон}
                                                                   { символов}

procedure Help;
begin TA:=15;
  writeln ('Usage:'#13#10+
           '        LDrafter SourceLQfile TargetDraftFile [/U|/D] [/L]'#10#7);
  halt (1);
end;

procedure GetParameters;
var b: byte;
    S: string[4];
begin if not (ParamCount in [2..4]) then Help;
      SFname:=ParamStr(1);  TFname:=ParamStr(2);
      if ParamCount=2 then exit;
      for b:=ParamCount downto 3 do
      begin S:=ParamStr(b);
            if (S[0]<>#2) or (S[1]<>'/') then Help;
            case UpCase(S[2]) of 'L': Left:=true;
                                 'U':   Up:=true;
                                 'D': Down:=true;
            end; {of case}
      end;
end;

procedure SFormatError;
begin Error ('Invalid file '+SFname+' format'); end;

procedure BlockRead(var f:file; var Dat; Size: word);
var Result: word;
begin  System.BlockRead (f, Dat, Size, Result);
       if Result<>Size then SFormatError;
end;

procedure Pass (begR, endR: char);
var  LQ: array [1..MaxLQcharWidth+2,  1..3] of byte;   {изображение символа}
  Draft: array [1..MaxDraftCharWidth+1, 1..3] of byte; {изображение символа}
    LQwidth, DraftWidth: array [1..3] of byte;  {ширины символов}
    Ch: char;
    b, t: byte;
    Col: longint; ACol: array [-3..0] of byte absolute Col;
    i: integer;
begin for Ch:=begR to endR do  {по всему диапазону символов}
  begin BlockRead(sf,LQwidth,3);  {считаны в LQwidth[1] - левое поле}
                                            {LQwidth[2] - ширина символа}
                                            {LQwidth[3] - правое поле}
     if LQwidth[2]>MaxLQcharWidth then SFormatError;
     FillChar(LQ,SizeOf(LQ),#0);  BlockRead(sf,LQ,LQwidth[2]*3);
     if Up or Down then  for b:=1 to LQwidth[2] do
     begin  {уширение всех гориз. линий на 1}
      Col:=0;                             for t:=1 to 3 do ACol[-t]:=LQ[b][t];
      if Up then Col:=Col or (Col shl 1)
            else Col:=Col or (Col shr 1); for t:=1 to 3 do LQ[b][t]:=ACol[-t];
     end;

     if Left then  for b:=1 to LQwidth[2] do
       for t:=1 to 3 do       {сужение верт. линий на 1}
         LQ[b][t]:=LQ[b][t] and LQ[succ(b)][t];

     for b:=1 to 2 do DraftWidth[b]:=LQwidth[b] div 3;  {Расчет ширин Draft'а}
     if LQwidth[2] mod 3 >0 then inc(DraftWidth[2]);
     i:=0; i:=i+ ((LQwidth[1]+LQwidth[2]+LQwidth[3]) div 3) -
                   DraftWidth[2] - DraftWidth[1];
           if i>0 then DraftWidth[3]:=i else DraftWidth[3]:=0;
     if (DraftWidth[1]+DraftWidth[2]+DraftWidth[3])>MaxDraftCharWidth
         then writeln('':10, 'WARNING: character ''',Ch,''' too wide');

     for b:=1 to DraftWidth[2] do
       for t:=1 to 3 do                          {гориз. сжатие}
         Draft [b][t]:=LQ[b*3][t] or LQ[b*3-1][t] or LQ[b*3-2][t];

     BlockWrite(tf,DraftWidth,3);
     BlockWrite(tf,Draft,DraftWidth[2]*3);
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
