unit ObjWin;

{ Window objects }

interface
uses
    Crt, Win, Lists;

const
    ClearScreen  = 1;
    DrawBorder   = 2;
    SaveContents = 4;
    DefaultFlag  = 7;

type
    WinObj = object(Item)
                   Win        : WinState;
                   Border     : FrameChars;
                   BorderAttr : byte;
                   HeaderPtr  : ^TitleStr;
                   HeaderAttr : byte;
                   UserFlags  : byte;
                   constructor Init(LC, TR, RC, BR, WinAttr : byte;
                                    var Frame : FrameChars; FrameAttr : byte;
                                    Title : TitleStr; TitleAttr : byte;
                                    WinFlag : byte);
                   procedure Open; virtual;
             end;

    PopUpWinObj = object(WinObj)
                   BufferPtr  : pointer;
                   constructor Init(LC, TR, RC, BR, WinAttr : byte;
                                    var Frame : FrameChars; FrameAttr : byte;
                                    Title : TitleStr; TitleAttr : byte;
                                    WinFlag : byte);
                   procedure Open; virtual;
                   procedure Close; virtual;
                   procedure Select; virtual;
                   procedure ScrollUp; virtual;
                   procedure ScrollDn; virtual;
             end;

const
    NoBorder   : FrameChars = '        ';

var
    CurrentWin : ^PopUpWinObj;
    FullScreen : PopUpWinObj;

function Attr(Foreground : byte; Background : byte) : byte;

implementation

constructor WinObj.Init(LC, TR, RC, BR, WinAttr : byte;
                        var Frame : FrameChars; FrameAttr : byte;
                        Title : TitleStr; TitleAttr : byte;
                        WinFlag : byte);
begin   { Winobj.Init }
     Item.Init;
     Win.WindMin:=Pred(TR) shl 8 + Pred(LC);
     Win.WindMax:=Pred(BR) shl 8 + Pred(RC);
     Win.TextAttr:=WinAttr;
     Win.WhereX:=1;
     Win.WhereY:=1;
     Border:=Frame;
     BorderAttr:=FrameAttr;
     GetMem(HeaderPtr, Length(Title)+1);
     HeaderPtr^:=Title;
     HeaderAttr:=TitleAttr;
     UserFlags:=WinFlag
end;    { WinObj.Init }

procedure WinObj.Open;
begin   { WinObj.Open }
     RestoreWin(Win);
     if (UserFlags and DrawBorder) <> 0 then
        FrameWin(HeaderPtr^, Border, HeaderAttr, BorderAttr);
     if (UserFlags and ClearScreen) <> 0 then
        ClrScr
     else
        GotoXY(1, 1)
end;    { WinObj.Open }

constructor PopUpWinObj.Init(LC, TR, RC, BR, WinAttr : byte;
                             var Frame : FrameChars; FrameAttr : byte;
                             Title : TitleStr; TitleAttr : byte;
                             WinFlag : byte);
begin   { PopWinobj.Init }

     { It's very simply to write method if you have good ancestors! }

     WinObj.Init(LC, TR, RC, BR, WinAttr,
            Frame, FrameAttr, Title, TitleAttr, WinFlag);
     BufferPtr:=nil
end;    { PopWinObj.Init }

procedure PopUpWinObj.Open;
begin   { PopUpWinObj.Open }
     SaveWin(CurrentWin^.Win);
     RestoreWin(Win);
     if (UserFlags and SaveContents) <> 0 then
        begin
             GetMem(BufferPtr, WinSize);
             ReadWin(BufferPtr^)
        end;
     if (UserFlags and DrawBorder) <> 0 then
        FrameWin(HeaderPtr^, Border, HeaderAttr, BorderAttr);
     if (UserFlags and ClearScreen) <> 0 then
        ClrScr
     else
        GotoXY(1, 1);
     CurrentWin:=@Self		{ Mention use of the Self qualifier }
end;    { PopUpWinObj.Open }

procedure PopUpWinObj.Close;
var
    TempWin : ^PopUpWinObj;

begin   { PopUpWinObj.Close}
     if @Self = CurrentWin then
        begin
             if (UserFlags and DrawBorder) <> 0 then
                UnframeWin;
             SaveWin(Win);
             if (UserFlags and SaveContents) <> 0 then
                begin
                     WriteWin(BufferPtr^);
                     FreeMem(BufferPtr, WinSize);
                end;
             RestoreWin(FullScreen.Win);
             CurrentWin:=@FullScreen	{ We don't know what window was
					  opened previously }
        end
     else
        begin
             TempWin:=CurrentWin;
             SaveWin(CurrentWin^.Win);
             RestoreWin(Win);
             if (UserFlags and DrawBorder) <> 0 then
                UnframeWin;
             SaveWin(Win);
             if (UserFlags and SaveContents) <> 0 then
                begin
                     WriteWin(BufferPtr^);
                     FreeMem(BufferPtr, WinSize);
                end;
             RestoreWin(TempWin^.Win);
             CurrentWin:=TempWin
        end
end;    { PopUpWinObj.Close }

procedure PopUpWinObj.Select;
begin   { PopUpWinObj.Select}
     if @Self <> CurrentWin then	{ If window is currently active
				  why do we need to select it once more? }
        begin
             SaveWin(CurrentWin^.Win);
             RestoreWin(Win);
             CurrentWin:=@Self
        end
end;    { PopUpWinObj.Select }

procedure PopUpWinObj.ScrollUp;
var
    SaveY : byte;
begin
     if @Self = CurrentWin then
        begin
             SaveY:=WhereY;
             GotoXY(WhereX, 1);
             DelLine;
             GotoXY(WhereX, SaveY)
        end
end;

procedure PopUpWinObj.ScrollDn;
var
    SaveY : byte;
begin
     if @Self = CurrentWin then
        begin
             SaveY:=WhereY;
             GotoXY(WhereX, 1);
             InsLine;
             GotoXY(WhereX, SaveY)
        end
end;

function Attr(Foreground : byte; Background : byte) : byte;
begin
     Attr:=(Background shl 4) + Foreground
end;

begin

	{ Initialization code }

     FullScreen.Init(1, 1, 80, 25, TextAttr, NoBorder, 0, '', 0, 0);
     CurrentWin:=@FullScreen
end.
