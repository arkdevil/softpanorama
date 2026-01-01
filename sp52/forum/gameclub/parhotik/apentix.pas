{$A+,B+,D+,E-,F-,I-,L+,N-,O-,R-,S-,V+}
{$M 6384,0,0000}

Uses Dos,Crt;

Var Stack       : Array [0..7000] of byte;   { Новый стек       }
    OldStack    : pointer;                   { и старые вектора }
    Old09,New09 : pointer;
    Old1C,New1C : pointer;

Var Glass,GlassF: Array [1..12,1..22+4] of byte;
    Fig,FigR    : Array [1..5,1..5] of byte;
    FigSt,FigLn : integer;
    FigSLArray  : Array [1..4] of record St,Ln :integer; end;
    FigUnq      : word;
    RezTab      : Array [1..12*4] of integer;
    TryNum      : integer;

Const  RightKBD = $4900;
       LeftKBD  = $4700;
       RotateKBD= $4800;
       KickKBD  = $3920;

Procedure Stuff(key:word);                  { Запихивание в буфер клавиатуры  }
Inline($B8/$00/$05    {MOV    AX,0500}
      /$59            {POP    CX}
      /$CD/$16);      {INT    16}


Procedure SetStack(p:pointer);                    { Установка указателя стека }
Inline($58            {POP    AX}
      /$5B            {POP    BX}
      /$8E/$D3        {MOV    SS,BX}
      /$89/$C4);      {MOV    SP,AX}


Procedure MakeGlass;
  Var x,y : integer;
      w   : word;
Begin
  For x:=1 to 12 do                               { Считывание с экрана }
    For y:=1 to 22 do begin                       { содержимого стакана }
       w:=memW[$B800:(y-1)*160+(x*4)+48];
       Glass[x,y]:=byte((lo(w)=$DB) and (hi(w)>0));
      end;
  FigUnq:=0;
  FillChar(Fig,SizeOf(Fig),#0);
  For x:=1 to 5 do                                { Считывание новой фигуры }
    For y:=1 to 4 do begin
       Fig[x,y]:=Glass[x+3,y];
       FigUnq:=FigUnq shl 1 +Fig[x,y];            { Получение битового образа }
       Glass[x+3,y]:=0;                           { для идентификации }
      end;
End;


Var AlgRot     : Array [2..4] of byte;
    RRx,RRy    : integer;


Procedure SetFig(a2,a3,a4,rx,ry:byte);
Begin                                  { Установка }
  AlgRot[2]:=a2;                       { алгоритмов поворота - 90° }
  AlgRot[3]:=a3;                       { - 180° }
  AlgRot[4]:=a4;                       { - 270° }
  RRx:=rx;                             { Центр вращения *2 }
  RRy:=ry;                             { ───//───          }
End;


Procedure NormFig(Rnum:integer);       { Определение левого поля и }
Var x : integer;                       { ширины фигуры             }
Begin
  x:=1;
  While Fig[x,1]+Fig[x,2]+Fig[x,3]+Fig[x,4]+Fig[x,5] = 0 do Inc(x);
  FigSt:=x;
  While (Fig[x,1]+Fig[x,2]+Fig[x,3]+Fig[x,4]+Fig[x,5]<>0) and (x<6) do Inc(x);
  FigLn:=x-FigSt;
  FigSLArray[Rnum].Ln:=FigLn;   { ширина }
  FigSLArray[Rnum].St:=FigSt;   { поле   }
End;

Procedure MakeFig;
Begin
  NormFig(1);
  Case FigUnq of
     3720 : SetFig(1,1,1,4*2,2*2);
    36480 : SetFig(1,1,1,3*2,2*2);
    35936 : SetFig(1,1,1,3*2,2*2);
    19552 : SetFig(1,1,1,3*2,2*2);
    27712 : SetFig(1,1,1,3*2,2*2);
    25792 : SetFig(1,0,0,3*2,2*2);     {  *____ }
    50272 : SetFig(1,0,0,3*2,2*2);     {      * }
    17472 : SetFig(1,0,0,3*2,2*2);     {***}
    17476 : SetFig(1,0,0,4*2,2*2);     {****}
     8738 : SetFig(1,0,0,3*2,3*2);     {*****}
    17984 : SetFig(1,1,1,3*2,2*2);
    1648  : SetFig(1,1,1,3*2+1,2*2+1);
    1888  : SetFig(1,1,1,3*2+1,2*2+1);
    3200  : SetFig(1,1,1,3*2+1,1*2+1);
    2244  : SetFig(1,0,0,4*2,2*2);     { ****      }
    1224  : SetFig(1,0,0,4*2,2*2);     {   ****    }
    17478 : SetFig(1,1,1,3*2+1,2*2+1); { ****_  }
    25668 : SetFig(1,1,1,3*2+1,2*2+1); { _****  }
    17988 : SetFig(1,1,1,3*2+1,2*2+1); { *_***  }
    17506 : SetFig(1,1,1,3*2+1,2*2+1); { ***__  }
    17508 : SetFig(1,1,1,3*2+1,2*2+1); { ***_*  }
     9796 : SetFig(1,1,1,3*2+1,2*2+1); { __**** }
     2048 : SetFig(0,0,0,0,1);         { . }
    20032 : SetFig(0,0,0,0,1);         { + }
     3264 : SetFig(0,0,0,0,1);         { * }
     2176 : SetFig(2,0,0,0,1);         { ** }
     3208 : SetFig(3,4,5,0,1);         {.-- }
     2188 : SetFig(6,7,8,0,1);         { --.}
    51392 : SetFig(9,10,11,0,1);       { V  }
    else  SetFig(0,0,0,0,0);
   end{Case};
End;

Procedure Rotate(Rnum:integer);
Var x,y    : integer;
    xx,yy  : integer;
{  Вращение фигур. Те, которые врашаются по правилам - Алгоритм N1 }
{  Для остальных - индивидуальные "алгоритмы"  (N2-N11)              }

Begin
  FillChar(FigR,SizeOf(FigR),#0);

  If AlgRot[Rnum]=1 then begin
     For x:=1 to 5 do
       For y:=1 to 5 do begin
         If Fig[x,y]=1 then
              FigR[(RRx-RRy) div 2 +y,(RRx+RRy) div 2 -x]:=1;
        end;
    end;

  If AlgRot[Rnum]=2 then begin
     FigR[3,1]:=1;
     FigR[3,2]:=1;
    end;

  If AlgRot[Rnum]=3 then begin
     FigR[3,1]:=1;
     FigR[3,2]:=1;           {  *     }
     FigR[3,3]:=1;           {  *__   }
     FigR[4,3]:=1;
    end;

  If AlgRot[Rnum]=4 then begin
     FigR[3,2]:=1;
     FigR[4,2]:=1;            { ___* }
     FigR[5,2]:=1;
     FigR[5,1]:=1;
    end;

  If AlgRot[Rnum]=5 then begin
     FigR[4,1]:=1;
     FigR[4,2]:=1;            { --   }
     FigR[4,3]:=1;            {  |   }
     FigR[3,1]:=1;
    end;

  If AlgRot[Rnum]=6 then begin
     FigR[4,1]:=1;
     FigR[4,2]:=1;            {  --  }
     FigR[4,3]:=1;            {  |   }
     FigR[5,1]:=1;
    end;

  If AlgRot[Rnum]=7 then begin
     FigR[3,2]:=1;
     FigR[4,2]:=1;            { *___ }
     FigR[5,2]:=1;
     FigR[3,1]:=1;
    end;

  If AlgRot[Rnum]=8 then begin
     FigR[4,1]:=1;
     FigR[4,2]:=1;           {    *   }
     FigR[4,3]:=1;           {  __*   }
     FigR[3,3]:=1;
    end;

  If AlgRot[Rnum]=9 then begin
     FigR[3,1]:=1;
     FigR[2,1]:=1;           {  C  }
     FigR[2,2]:=1;
     FigR[2,3]:=1;
     FigR[3,3]:=1;
    end;

  If AlgRot[Rnum]=10 then begin
     FigR[2,1]:=1;
     FigR[2,2]:=1;           {  V  }
     FigR[3,2]:=1;
     FigR[4,2]:=1;
     FigR[4,1]:=1;
    end;

  If AlgRot[Rnum]=11 then begin
     FigR[3,1]:=1;
     FigR[4,1]:=1;           {  Э }
     FigR[4,2]:=1;
     FigR[4,3]:=1;
     FigR[3,3]:=1;
    end;

  Fig:=FigR;
  NormFig(Rnum);             { Получить новые параметры фигуры }
End;


Function GoodPos(i,h:integer):boolean;
Var x,y : integer;           { TRUE - изображение фигуры и содер- }
Begin                        { жимого не пересекается             }
  GoodPos:=true;
  For x:=0 to FigLn-1 do
    For y:=0 to 4 do
      If Glass[i+x,h+y]+Fig[FigSt+x,y+1]>1 then GoodPos:=false;
End;


Procedure AnalPos(i,h:integer);
Var x,y,d,t : integer;
    Contur,                               { Контур исходный      }
    ConturF : Array [1..12] of integer;   { Контур с фигурой     }
    {  ════════════  Основные критерии (и глубина) ════════════  }
    PCont   : integer;                    { Неровность контура   }
    PDirk   : integer;                    { Кол-во дырок         }
    PFill   : integer;                    { Заполненность слоев  }
    PZaval  : integer;                    { Заваленные дырки     }

Const VesFill : Array [0..12] of integer =
       (6,5,5,5,5,5,5,5,5,5,5,5,10);      { баллы за заполнение слоя }

Begin
  { Получили стакан с упавшей фигурой }
  GlassF:=Glass;
  For x:=0 to FigLn-1 do
    For y:=0 to 4 do
      GlassF[i+x,h+y]:=GlassF[i+x,h+y] or (Fig[FigSt+x,y+1]*2);

  { Нашли контур без фигуры и с ней }
  For x:=1 to 12 do begin
     y:=3;
     While Glass[x,y]=0 do Inc(y);
     Contur[x]:=y;
     y:=3;
     While GlassF[x,y]=0 do Inc(y);
     ConturF[x]:=y;
    end;

  { Проверяем запролненность линий }
  PFill:=0;
  For y:=3 to 22 do begin
     t:=0;
     For x:=1 to 12 do
       If GlassF[x,y]<>0 then Inc(t);
     Inc(PFill,VesFill[t]);  { за каждый процент заполнения - свой бал }
    end;

  { Находим неровность контура        }
  { Можно ввести проверку "колодцев"  }
  PCont:=0;
  For x:=2 to 12 do begin
     t:=abs(ConturF[x]-ConturF[x-1]);
     Inc(PCont,t);
    end;
  t:=ConturF[1]-ConturF[2];         { Не забыли про стенки }
  If t>0 then Inc(PCont,t);
  t:=ConturF[12]-ConturF[11];
  If t>0 then Inc(PCont,t);
  If (i=1) or (i=(13-FigLn)) then Inc(PCont);  { Жмись к стенкам }

  { Находим состояние стакана после удаления заполненных линий }
  For y:=2 to 22 do begin
     t:=0;
     For x:=1 to 12 do If GlassF[x,y]<>0 then Inc(t);
     If t=12 then
        For d:=1 to 12 do
           Move(GlassF[d,1],GlassF[d,2],y-1);
    end;

  { Находим новый контур после удаления линий }
  For x:=1 to 12 do begin
     y:=3;
     While GlassF[x,y]=0 do Inc(y);
     ConturF[x]:=y;
    end;


  { Находим количество дырок до и после падения фигуры }
  t:=0; d:=0;
  For x:=1 to 12 do begin
     For y:=Contur[x]+1 to 22 do
       If Glass[x,y]=0 then Inc(t);
     For y:=ConturF[x]+1 to 22 do
       If GlassF[x,y]=0 then Inc(d);
    end;
  PDirk:=d-t;

  { Находим количество заваливаемых дырок (1 или 2 балла) }
  d:=0;
  For x:=i to i+FigLn-1 do begin
     For y:=Contur[x]+1 to Contur[x]+2 do          { ! vv }
       If GlassF[x,y]=0 then Inc(d,3-(y-Contur[x]));
    end;
  PZaval:=d;

  { Подсчитываем общий бал. Должен быть больше нуля }
  RezTab[tryNum]:=1000-PCont-PDirk*7+PFill-PZaval*1+h*2;
End;



Procedure Search(rot:byte);   { Поиск лучшей позиции при данном повороте }
Var i,h   : integer;
Begin
  If (rot>1) and (AlgRot[rot]=0) then Exit;
  If rot>1 then Rotate(rot);
  For i:=1 to 13-FigLn do begin
     h:=1;
     While GoodPos(i,h) do Inc(h);
     AnalPos(i,h-1);
     Inc(tryNum);
    end;
End;


Procedure Choice;
Var i,r      : integer;
    m,n,nn   : integer;
    ToLeft   : integer;
Begin                      { Поиск максимального балла из всех }
  n:=1;
  m:=0;
  For i:=1 to 12*4 do
    If RezTab[i]>m then begin
       m:=RezTab[i]; n:=i;
      end;
  nn:=(n-1) mod 12 +1;     { Вычисление нужных нажатий на клавиши }
  r:=(n-1) div 12;
  ToLeft:=3-nn+FigSLArray[r+1].St;
                           { Запихивание в буфер клавиатуры       }
  For i:=1 to r do Stuff(RotateKBD);
  For i:=1 to ToLeft do Stuff(LeftKBD);
  For i:=1 to -ToLeft do Stuff(RightKBD);
  Stuff(KickKBD);
End;


Procedure MainWork;
Var i : integer;
Begin
  MakeGlass;                            { Получаем стакан             }
  MakeFig;                              { Определяем фигуру           }
  If RRy=0 then Exit;                   { Если не определена - выход  }
  FillChar(RezTab,SizeOf(RezTab),#0);   { Стереть таблицу результатов }
  tryNum:=1;
  Search(1);                            { Анализ позиций при всех поворотах }
  tryNum:=13;
  Search(2);
  tryNum:=25;
  Search(3);
  tryNum:=37;
  Search(4);
  Choice;                               { Выбор лучшего хода                }
End;


Procedure Int65; interrupt;
Begin
  OldStack:=ptr(SSeg,SPtr);      { Смена стека }
  SetStack(@Stack[7000]);
  GetIntVec($09,New09);          { Смена векторов                     }
  GetIntVec($1C,New1C);          { - необходима для нормальной работы }
  SetIntVec($09,Old09);          {   отладчика Pascal                 }
  SetIntVec($1C,Old1C);
  Inline($FB); {STI}

  Sound(500); Delay(1); NoSound; { Щелчек }

  MainWork;

  SetIntVec($09,New09);          { Вернуть назад }
  SetIntVec($1C,New1C);
  SetStack(OldStack);
End;


Procedure Init;
Var x : integer;
Begin
  SetIntVec($65,@Int65);      { Сохранение старых векторов 09h и 1Ch }
  GetIntVec($09,Old09);
  GetIntVec($1C,Old1C);
  FillChar(Glass,SizeOf(Glass),#1);
End;


Procedure RunPentix;
Var StartPath : string;
Begin
  StartPath:=ParamStr(0);
  While StartPath[length(StartPath)]<>'\' do
     Delete(StartPath,length(StartPath),1);
  { Запускаем из каталога с APENTIX }
  Exec(StartPath+'PENTIX.OVL','');
  Inline($B8/$03/$00/$CD/$10);
  Writeln ('PENTIX AutoPlayer V1.0  (C) Copypight 1992 by Dima P.');
  If DosError<>0 then Writeln ('File ',StartPath,'PENTIX.OVL not found');
End;

Procedure Done;
Begin
End;

Begin
  Init;
  RunPentix;
  Done;
End.
