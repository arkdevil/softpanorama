{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Source Generator Demo           }
{   Copyright (c) 1992 by Phase Corporation      }
{                                                }
{************************************************}

{$X+,S-}
{$M 16384,8192,655360}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, MsgBox, App;
const
  cmOpen = 100;
type

  { TTVDemo }

  PTVDemo = ^TTVDemo;
  TTVDemo = object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

var
  EXEName: PathStr;
  RezFile: TResourceFile;
  RezStream: PStream;

{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  RunError(255);
end;

{ TTVDemo }
constructor TTVDemo.Init;
var
  R: TRect;
  I: Integer;
  FileName: PathStr;
begin
  { Initialize resource file }

  RezStream := New(PProtectedStream, Init(EXEName, stOpenRead, 4096));
  RezFile.Init(RezStream);

  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;

  TApplication.Init;

end;

procedure TTVDemo.HandleEvent(var Event: TEvent);
var
    D : PDialog;
begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmOpen:
             begin
               { This object have been created by TVGEN and saved into FIND.DLG
                 and DEMO.RSC }
               D := PDialog(RezFile.Get('Find'));
               DeskTop^.Insert(D);
             end;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TTVDemo.InitMenuBar;
begin
  { This menu have been created by TVGEN and saved into MENU.MNU and DEMO.RSC }
  MenuBar := PMenuBar(RezFile.Get('MenuBar'));
end;

procedure TTVDemo.InitStatusLine;
begin
  { This statusline have been created by TVGEN and saved into STATUS.STL and 
   DEMO.RSC }
  StatusLine := PStatusLine(RezFile.Get('StatusLine'));
end;

var
  Demo: TTVDemo;
begin
  { This is resource file created by TVGEN }
  EXEName := 'Demo.RSC';
  Demo.Init;
  Demo.Run;
  Demo.Done;
end.
