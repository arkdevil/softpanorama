
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 6.0                        }
{       VListViewer. Turbo Vision Unit                  }
{                                                       }
{       Copyright (c) 1991 Dimarker's Software          }
{                                                       }
{*******************************************************}

unit VList;

{$F+,O+,S-,X+}

interface

uses Objects, Views, Drivers, Dialogs;

type

  PVList   = ^TVList;
  TVList   = object(TListBox)
   ColSize : integer;
   constructor Init(var Bounds: TRect; ANumCols: Word;
                    AScrollBar: PScrollBar);
    procedure Draw; virtual;
   constructor Load(var S: TStream);
   procedure   Store(var S: TStream);
  end;

const
 RVListRec: TStreamRec = (
  ObjType : 1533;
  VmtLink : Ofs(TypeOf(TVList)^);
  Load    : @TVList.Load;
  Store   : @TVList.Store);

 procedure RegisterVList;

implementation

 constructor TVList.Init(var Bounds: TRect; ANumCols: Word;
                        AScrollBar: PScrollBar);
 begin
  TListBox.Init(Bounds, ANumCols, AScrollBar);
  if ANumCols > 0 then
   ColSize:=(Bounds.B.X - Bounds.A.X) div ANumCols
  else
   ColSize:=Bounds.B.X - Bounds.A.X;
 end;

 procedure TVList.Draw;
  var
   i: integer;
   ArStep, PgStep: Integer;
  begin
   i:=NumCols;
   if (Size.X div ColSize) > NumCols then
    Inc(NumCols);
   if (Size.X div ColSize) < NumCols then
    if NumCols > 1 then
     Dec(NumCols);
   if i <> NumCols then
    begin
     if VScrollBar <> nil then
     begin
       if NumCols = 1 then
       begin
         PgStep := Size.Y -1;
         ArStep := 1;
       end else
       begin
         PgStep := Size.Y * NumCols;
         ArStep := Size.Y;
       end;
       VScrollBar^.SetStep(PgStep, ArStep);
     end;
     if HScrollBar <> nil then HScrollBar^.SetStep(Size.X div NumCols, 1);
    end;
   TListBox.Draw;
  end;

 constructor TVList.Load(var S: TStream);
  begin
   TListBox.Load(S);
   S.Read(ColSize, SizeOf(integer));
  end;

 procedure TVList.Store(var S: TStream);
  begin
   TListBox.Store(S);
   S.Write(ColSize, SizeOf(integer));
  end;

 procedure RegisterVList;
  begin
   RegisterType(RVListRec);
  end;

end.