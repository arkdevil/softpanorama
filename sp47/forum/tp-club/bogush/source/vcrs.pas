{ VCRS.PAS                                                         }
{ Редактор цветовых сочетаний для VGA адаптера                     }
{ Автор : Богуш Андрей Витальевич                                  }
{         Минск (0172) 27-29-37р                                   }
{                      52-69-93д                                   }
{ Компилятор Turbo Pascal 5.5                                      }
{ В программе использованы unitы пакетов Turbo-Professional 5.11   }
{ и Bonus (слегка подправленный int24.pas прилагается)             }



uses int24, tpcrt, tpstring, dos, tpedit ,tpdir, tppick;
{$I-}
const
     combFrame    : FrameArray = '╒╘╕╛═│';
     doubleFrame  : FrameArray = '╔╚╗╝═║';
     singleFrame  : FrameArray = '┌└┐┘─│';

type
    coltype = array[0..15,1..3] of byte;

const
    standart : array[0..63,1..3] of byte=(
{  0 }      (0,0,0),
{  1 }      (0,0,42),
{  2 }      (0,42,0),
{  3 }      (0,42,42),
{  4 }      (48,0,0),
{  5 }      (42,0,42),
{  6 }      (42,42,0),
{  7 }      (42,42,42),
{  8 }      (0,0,21),
{  9 }      (0,0,63),
{ 10 }      (0,42,21),
{ 11 }      (0,42,63),
{ 12 }      (42,0,21),
{ 13 }      (42,0,63),
{ 14 }      (42,42,21),
{ 15 }      (42,42,63),
{ 16 }      (0,21,0),
{ 17 }      (0,21,42),
{ 18 }      (0,63,0),
{ 19 }      (0,63,42),
{ 20 }      (42,21,0),
{ 21 }      (42,21,42),
{ 22 }      (42,63,0),
{ 23 }      (42,63,42),
{ 24 }      (0,21,21),
{ 25 }      (0,21,63),
{ 26 }      (0,63,21),
{ 27 }      (0,63,63),
{ 28 }      (42,21,21),
{ 29 }      (42,21,63),
{ 30 }      (42,63,21),
{ 31 }      (42,63,63),
{ 32 }      (21,0,0),
{ 33 }      (21,0,42),
{ 34 }      (21,42,0),
{ 35 }      (21,42,42),
{ 36 }      (63,0,0),
{ 37 }      (63,0,42),
{ 38 }      (63,42,0),
{ 39 }      (63,42,42),
{ 40 }      (21,0,21),
{ 41 }      (21,0,63),
{ 42 }      (21,42,21),
{ 43 }      (21,42,63),
{ 44 }      (63,0,21),
{ 45 }      (63,0,63),
{ 46 }      (63,42,21),
{ 47 }      (63,42,63),
{ 48 }      (21,21,0),
{ 49 }      (21,21,42),
{ 50 }      (21,63,0),
{ 51 }      (21,63,42),
{ 52 }      (63,21,0),
{ 53 }      (63,21,42),
{ 54 }      (63,63,0),
{ 55 }      (63,63,42),
{ 56 }      (21,21,21),
{ 57 }      (21,21,63),
{ 58 }      (21,63,21),
{ 59 }      (21,63,63),
{ 60 }      (63,21,21),
{ 61 }      (63,21,63),
{ 62 }      (63,63,21),
{ 63 }      (63,63,63));
Var
    vgacol   : coltype;
    beam     : byte;
    fname    : string;

Procedure SetcolReg(rno:byte);
Var
   r : registers;
   cr : byte;
begin
  r.ah := $10;
  r.al := $7;
  r.bl :=rno;
  Intr($10,r);
  cr   := r.bh;

  r.ah := $10;
  r.al := $10;
  r.bx := cr;
  r.dh := vgacol[rno,1];
  r.ch := vgacol[rno,2];
  r.cl := vgacol[rno,3];
  Intr($10,r);
end;

Procedure SetPalette;
Var
   k : byte;
begin
  for k:=0 to 15 do SetcolReg(k);
end;


Procedure GetcolReg(rno:byte);
Var
   r : registers;
   cr:byte;
begin
  r.ah := $10;
  r.al := $7;
  r.bl :=rno;
  Intr($10,r);
  cr   := r.bh;


  r.ah := $10;
  r.al := $15;
  r.bx := cr;
  Intr($10,r);
  vgacol[rno,1] := r.dh and (not 192);
  vgacol[rno,2] := r.ch and (not 192);
  vgacol[rno,3] := r.cl and (not 192);
end;

Function ColReg(col:byte):byte;
Var
   cr : byte;
   r  : registers;
begin
  r.ah := $10;
  r.al := $7;
  r.bl := col;
  Intr($10,r);
  cr   := r.bh;
  ColReg:=cr;
end;

Procedure GetPalette;
Var
   k : byte;
begin
  for k:=0 to 15 do GetcolReg(k);
end;



Procedure DrawMap(xc,yc:byte);
Var
   x,y : byte;

begin
FrameChars:=combFrame;
  For x:=0 to $F do
    For y:=0 to $7 do
      FastWrite(chr(254),yc+1+y,xc+1+x, (y*$10)+x);
  FrameWindow(xc,yc,xc+17,yc+9,$03,$0F,' Color map ');
end;

Procedure DrawSingle(xc,yc,color:byte; aktive:boolean);
Var
   nst : string;
   fcol : byte;
begin
  fcol:=$07;
  if aktive then begin
                 FrameChars:=doubleFrame;
                 fcol:=$03;
                 end
     else FrameChars:=singleFrame;

  nst:=Long2Str(color);
  if not aktive then nst:=nst+'─'
     else nst:=nst+'═';
  FrameWindow(xc,yc,xc+4,yc+3,fcol,fcol,nst);
  FastWrite('███',yc+1,xc+1,color);
  FastWrite('███',yc+2,xc+1,color);

 if aktive then FastWrite('╤',yc+3,xc+2,fcol);
end;

Function Color2String(color:byte):string;
Var s:string;
begin
s:='';
  Case color of
   0 : s:='Black';
   1 : s:='Blue';
   2 : s:='Green';
   3 : s:='Cyan';
   4 : s:='Red';
   5 : s:='Magenta';
   6 : s:='Brown';
   7 : s:='White';
   8 : s:='Gray';
   9 : s:='Light blue';
  10 : s:='Light green';
  11 : s:='Light cyan';
  12 : s:='Light red';
  13 : s:='Light magenta';
  14 : s:='Yellow';
  15 : s:='Light white';
  end;
Color2String:=s;
end;

Procedure DrawTests(x,y,c:byte);
Var
   xp,k : byte;
begin
  xp:=x;
  For k:=0 to 7 do
      begin
       FastWrite('  Test  ',y,xp,(c*$10)+k);
       inc(xp,7);
      end;
  xp:=x;
  For k:=8 to $F do
      begin
       FastWrite('  Test  ',y+1,xp,(c*$10)+k);
       inc(xp,7);
      end;
end;

Function NumBars(current,bm:byte):byte;
begin
 NumBars:=vgacol[current,bm];
end;

Procedure DrawStats(xc,yc,current,bm:byte);
begin
Case bm of
0: begin
   FastWrite(CharStr(' ',63),yc+7,xc+10,$00);
   FastWrite(CharStr(' ',63),yc+9,xc+10,$00);
   FastWrite(CharStr(' ',63),yc+11,xc+10,$00);
   FastWrite(CharStr('░',NumBars(current,1)),yc+7,xc+10,$4c);
   FastWrite(CharStr('░',NumBars(current,2)),yc+9,xc+10,$2a);
   FastWrite(CharStr('░',NumBars(current,3)),yc+11,xc+10,$19);
   FastWrite(Pad(Long2Str((NumBars(current,1)*100) div 63)+'%',4),yc+7,xc+74,$03);
   FastWrite(Pad(Long2Str((NumBars(current,2)*100) div 63)+'%',4),yc+9,xc+74,$03);
   FastWrite(Pad(Long2Str((NumBars(current,3)*100) div 63)+'%',4),yc+11,xc+74,$03);
   end;

1: begin
   FastWrite(CharStr(' ',63),yc+7,xc+10,$00);
   FastWrite(CharStr('░',NumBars(current,1)),yc+7,xc+10,$4c);
   FastWrite(Pad(Long2Str((NumBars(current,1)*100) div 63)+'%',4),yc+7,xc+74,$03);
   end;

2: begin
   FastWrite(CharStr(' ',63),yc+9,xc+10,$00);
   FastWrite(CharStr('░',NumBars(current,2)),yc+9,xc+10,$2a);
   FastWrite(Pad(Long2Str((NumBars(current,2)*100) div 63)+'%',4),yc+9,xc+74,$03);
   end;

3: begin
   FastWrite(CharStr(' ',63),yc+11,xc+10,$00);
   FastWrite(CharStr('░',NumBars(current,3)),yc+11,xc+10,$19);
   FastWrite(Pad(Long2Str((NumBars(current,3)*100) div 63)+'%',4),yc+11,xc+74,$03);
   end;

end;
end;


Procedure DrawRegs(xc,yc,current:byte);
begin
   FrameChars:=doubleFrame;  {|}
   FrameWindow(xc+1,yc+5,xc+1+77,yc+6+6,$03,$0F,' Color register : '+Color2String(current)+' ');
   FastVert('││││',yc+5,xc,$03);
   FastWrite('└╢',yc+9,xc,$03);

   FastWrite('╟───────┬───────────────────────────────────────────────────────────────┬────╢',yc+6,xc+1,$03);
   FastWrite('║ Red   │                                                               │    ║',yc+7,xc+1,$03);
   FastWrite('╟───────┼───────────────────────────────────────────────────────────────┼────╢',yc+8,xc+1,$03);
   FastWrite('╢ Green │                                                               │    ║',yc+9,xc+1,$03);
   FastWrite('╟───────┼───────────────────────────────────────────────────────────────┼────╢',yc+10,xc+1,$03);
   FastWrite('║ Blue  │                                                               │    ║',yc+11,xc+1,$03);
   FastWrite('╚═══════╧═══════════════════════════════════════════════════════════════╧',yc+12,xc+1,$03);
   DrawStats(xc,yc,current,0);
   Case beam of
     1 : FastWrite('Red',yc+7,xc+2,$0f);
     2 : FastWrite('Green',yc+9,xc+2,$0f);
     3 : FastWrite('Blue',yc+11,xc+2,$0f);
   end;

end;


Procedure DrawColors(xc,yc,current:byte);
Var
   posx,k  : byte;
   lstr    : string;
begin

  posx :=0;
  For k:=0 to $F do
      begin
      DrawSingle(xc+posx,yc,k,(k=current));
      if k=current then
         begin
           FastWrite(CharStr(' ',80),yc+4,1,0);
          lstr :='┌'+CharStr('─',posx+1)+'┘';
          FastWrite(lstr,yc+4,1,$03);
         end;
      inc(posx,5);
      end;

   DrawRegs(xc,yc,current);

   FrameWindow(xc,yc-5,xc+58,yc-2,$03,$0f,' Test ');
   DrawTests(xc+1,yc-4,current);
end;

Procedure DisplayAll(curcol,curbeam:byte);
begin
  beam := curbeam;
  SetPalette;
  DrawColors(1,13,curcol);
end;

Procedure IncBeam(col,beam:byte);
begin
  if vgacol[col,beam]<63 then
   begin
    inc(vgacol[col,beam]);
    DrawStats(1,13,col,beam);
    SetcolReg(col);
   end;
end;


Procedure DecBeam(col,beam:byte);
begin
if vgacol[col,beam]>0 then
 begin
  dec(vgacol[col,beam]);
  DrawStats(1,13,col,beam);
  SetcolReg(col);
 end;
end;


Function GetAdapter:string;
Var
   s: string;
begin
  s:='Unknown';
  Case CurrentDisplay of
    MonoHerc : s:='Hercules';
    CGA      : s:='CGA';
    MCGA     : s:='MCGA';
    EGA      : s:='EGA';
    VGA      : s:='VGA';
    PGC      : s:='PGC';
  end;
  GetAdapter:=s;
end;

Procedure DrawInfo;
begin
  FastWrite(CenterCh(' VGA color registers service. Copyright (C) Fsoft 1992 by Bogush A.V. ','■',80),1,1,$04);
  FrameWindow(1,2,59,7,$03,$0f,' Info ');
   FastWrite(
 ','+chr(26)+'-change color.,-change beam. F5-reset default value.',3,2,7);
 FastWrite(
 'Gray+/Gray- - controls beam intensity. F2/F3 - save/load.'
 ,4,2,7);
 FastWrite(Pad('Esc - quit.',57),5,2,7);
 FastWrite(CharStr(' ',57),6,2,$00);
 FastWrite('Adapter : ',6,2,$03);
 FastWrite(GetAdapter,6,12,$0f);
 FastWrite('FileName : ',6,25,$03);
 FastWrite(JustFileName(fname),6,36,$0f);
end;

Procedure SaveFile;
Var
   f:file of byte;
   mask : string;
   Esc  : boolean;
   k,i  : byte;
begin
  mask:=fname;
  if mask='--------' then mask:='colors.vga';

  ReadString('FileName to save :',6,2,38,$0f,$1f,$0c,Esc,mask);
  if not Esc then
     begin
       fname:=mask;
       Assign(f,fname);
       Rewrite(f);
       k:=ord('V');
       Write(f,k);
       for k :=0 to 15 do
         for i:=1 to 3 do Write(f,vgacol[k,i]);
       Close(f);
     end;
  DrawInfo;
end;

Procedure LoadFile;
const
     GFC : PickColorArray = ($70,$71,$7E,$30,$71,$31,$78);
Var
   f:file of byte;
   mask : string;
   Esc  : boolean;
   k,i  : byte;
begin
  mask:=fname;
  if mask='--------' then mask:='*.vga';

  ReadString('FileName to load :',6,2,38,$0f,$1f,$0c,Esc,mask);
  if not Esc then
     begin
       if (GetFileName(mask,AnyFile,10,10,20,3,GFC,
          fname)<>0) or (fname='') then begin
                         fname:='--------';
                         DrawInfo;
                         Exit;
                         end;
       Assign(f,fname);
       Reset(f);
       Read(f,k);
       if chr(k)='V' then
        begin
          for k:=0 to 15 do
           for i:=1 to 3 do  Read(f,vgacol[k,i]);
        end
          else begin
               FastWrite('Error in file...',6,36,$4E);
               Sound(2000);
               Delay(100);
               NoSound;
               Delay(1000);
               fname:='--------';
               end;

       Close(f);
     end;
  SetPalette;
  DrawInfo;
end;

Procedure MainLoop;
Var
   col,bm : byte;
   done   : boolean;
   key    : word;
begin
   col:=0;
   bm:=1;
   DisplayAll(col,bm);
   done :=false;
   key :=0;
   While not done do
     begin
       key:=ReadKeyWord;
       Case key of
         $011b : done:=true; {esc}

         $4d00 : begin
                 if col<15 then inc(col)    {left}
                    else col:=0;
                 DrawColors(1,13,col);
                 end;

         $4b00 : begin
                 if col>0 then dec(col)      {right}
                    else col:=15;
                 DrawColors(1,13,col);
                 end;

         $4800 : begin
                 if bm>1 then dec(bm)        {up}
                    else bm:=3;
                 beam:=bm;
                 DrawRegs(1,13,col);
                 end;

         $5000 : begin
                 if bm<3 then inc(bm)        {down}
                    else bm:=1;
                 beam:=bm;
                 DrawRegs(1,13,col);
                 end;

         $4a2d : DecBeam(col,bm);             {-}

         $4e2b : IncBeam(col,bm);             {+}

         $3f00 : begin
                 vgacol[col,1]:=standart[ColReg(col),1];
                 vgacol[col,2]:=standart[ColReg(col),2];
                 vgacol[col,3]:=standart[ColReg(col),3];
                 DrawRegs(1,13,col);
                 SetcolReg(col);
                 end;

         $3c00 : SaveFile;

         $3d00 : begin
                 LoadFile;
                 DrawRegs(1,13,col);
                 end;

       end;
     end;
end;


begin
 TextColor(7);
 TextBackGround(0);
 ClrScr;
 HiddenCursor;
 fname:='--------';
 SetBlink(false);
{ vgacol:=standart;}
GetPalette;
 beam := 1;
 SetPalette;
 DrawInfo;
 DrawMap(63,2);
 Mainloop;
 TextColor(7);
 TextBackGround(0);
 ClrScr;
 SetBlink(true);
 NormalCursor;
end.