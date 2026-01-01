{ standard application module }

uses Objects, Drivers, Views, Menus, App, GadGets, Dialogs, VLIST;

type
  TWorkApp = object(TApplication)
    Clock  : PClockView;
    Heap   : PHeapView;
    constructor Init;
    procedure Idle; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

{ TMyApp }

 constructor TWorkApp.Init;
  var
   R: TRect;
   D: PDialog;
   V: PListBox;
  begin
   TApplication.Init;
   GetExtent(R);
   R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
   Clock := New(PClockView, Init(R));
   Insert(Clock);
   GetExtent(R);
   R.A.X := R.B.X - 20; R.B.X:=R.B.X - 11;
   R.B.Y := R.A.Y + 1;
   Heap := New(PHeapView, Init(R));
   Insert(Heap);

{***** Testing VList Object *****}
   R.Assign(1,1,20,18);
   D:=New(PDialog, Init(R, 'Test'));
   D^.Flags:=D^.Flags or wfGrow;
   D^.GetExtent(R); R.Grow(-1, -1);
   V:=New(PVList, Init(R, 1, D^.StandardScrollBar(sbHandleKeyBoard+sbVertical)));
   V^.GrowMode:=V^.GrowMode or gfGrowHiX or gfGrowHiY;
   D^.Insert(V);
   DeskTop^.Insert(D);

{***** Let's create some items ... *****}
   V^.NewList(New(PStringCollection, Init(20,3)));
   V^.List^.Insert(NewStr('00000000000'));
   V^.List^.Insert(NewStr('11111111111111111'));
   V^.List^.Insert(NewStr('22222222222'));
   V^.List^.Insert(NewStr('33333333333'));
   V^.List^.Insert(NewStr('44444444444'));
   V^.List^.Insert(NewStr('55555555555'));
   V^.List^.Insert(NewStr('66666666666'));
   V^.List^.Insert(NewStr('777777777777'));
   V^.List^.Insert(NewStr('888888888888'));
   V^.List^.Insert(NewStr('99999999999'));
   V^.List^.Insert(NewStr('aaaaa'));
   V^.List^.Insert(NewStr('bbbbbb'));
   V^.List^.Insert(NewStr('ccccccc'));
   V^.List^.Insert(NewStr('dddddddd'));
   V^.List^.Insert(NewStr('eeeeeeeee'));
   V^.List^.Insert(NewStr('ffffffffff'));
   V^.List^.Insert(NewStr('gggggggggg'));
   V^.List^.Insert(NewStr('hhhhhhhhhh'));
   V^.SetRange(V^.List^.Count);
   V^.DrawView;
  end;

 procedure TWorkApp.Idle;
  begin
   TApplication.Idle;
   Clock^.Update;
   Heap^.Update;
  end;

 procedure TWorkApp.HandleEvent(var Event: TEvent);
  begin
   TApplication.HandleEvent(Event);
  end;

 procedure TWorkApp.InitMenuBar;
  var R: TRect;
  begin
   GetExtent(R);
   R.B.Y := R.A.Y + 1;
   MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('', hcNoContext, NewMenu(
     NewItem('',            '', kbNoKey,  cmOk, hcNoContext,
     NewLine(
     NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil)))), nil))));
  end;

 procedure TWorkApp.InitStatusLine;
  var R: TRect;
  begin
   GetExtent(R);
   R.A.Y := R.B.Y - 1;
   StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbNoKey, cmOk,
      NewStatusKey('', kbNoKey, cmOk,
      NewStatusKey('', kbNoKey, cmOk,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Выход',   kbAltX,  cmQuit,
      nil)))))),
    nil)));
  end;

var
  WorkApp: TWorkApp;

begin
  WorkApp.Init;
  WorkApp.Run;
  WorkApp.Done;
end.
