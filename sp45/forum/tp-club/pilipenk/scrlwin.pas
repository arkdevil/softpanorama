unit ScrlWin;

{ Advanced version of window objects }

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

    VisualItemPtr = ^VisualItem;
    VisualItem = object(Item)
                   Str    : ^string;
                   MaxLen : byte;
                   constructor Init;
                   procedure PutEqualTo(Value : string);
                   procedure Show(X, Y, Len, Attr : byte);
                   destructor Done; virtual;
                 end;

    Scrollable = object(PopUpWinObj)
                   ItemList   : ListPtr;
                   TopItem    : VisualItemPtr;
                   BotItem    : VisualItemPtr;
                   TotalRows  : byte;
                   TotalCols  : byte;
                   constructor Init(LC, TR, RC, BR, WinAttr : byte;
                                    var Frame : FrameChars; FrameAttr : byte;
                                    Title : TitleStr; TitleAttr : byte;
                                    WinFlag : byte);
                   procedure Open; virtual;
                   procedure MoveUp; virtual;
                   procedure MoveDn; virtual;
                   procedure Browse; virtual;
             end;

    Chooseable = object(PopUpWinObj)
                   ItemList   : ListPtr;
                   Hilight    : byte;
                   TotalRows  : byte;
                   TotalCols  : byte;
                   CurRow     : byte;
                   constructor Init(LC, TR, RC, BR, WinAttr, HiAttr : byte;
                                    var Frame : FrameChars; FrameAttr : byte;
                                    Title : TitleStr; TitleAttr : byte;
                                    WinFlag : byte);
                   procedure Open; virtual;
                   procedure MoveUp; virtual;
                   procedure MoveDn; virtual;
                   function Choose : VisualItemPtr; virtual;
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

constructor VisualItem.Init;
begin
     Item.Init;
     MaxLen:=0;
     Str:=nil
end;

procedure VisualItem.PutEqualTo(Value : string);
var
    L : byte;
begin
     L:=Length(Value);
     if L > MaxLen then
        begin
             if Str <> nil then
                FreeMem(Str, MaxLen+1);
             MaxLen:=(L div 8) * 8 + 7;
             GetMem(Str, MaxLen+1);
             MaxLen:=L
        end;
     Str^:=Value
end;

procedure VisualItem.Show(X, Y, Len, Attr : byte);
var
    L : byte;
begin
     L:=Length(Str^);
     WriteStr(X, Y, Str^, Attr);
     WriteChar(X+L, Y, 80, ' ', Attr)
end;

destructor VisualItem.Done;
begin
     FreeMem(Str, MaxLen+2);
     Item.Done
end;

constructor Scrollable.Init(LC, TR, RC, BR, WinAttr : byte;
                 var Frame : FrameChars; FrameAttr : byte;
                 Title : TitleStr; TitleAttr : byte;
                 WinFlag : byte);
begin
     PopUpWinObj.Init(LC, TR, RC, BR, WinAttr,
                      Frame, FrameAttr,
                      Title, TitleAttr, WinFlag);
     New(ItemList, Init);
     TopItem:=nil;
     BotItem:=nil;
     if (WinFlag and DrawBorder) > 0 then
        begin
             TotalRows:=Pred(BR-TR);
             TotalCols:=Pred(RC-LC)
        end
     else
        begin
             TotalRows:=Succ(BR-TR);
             TotalCols:=Succ(RC-LC)
        end
end;

procedure Scrollable.Open;
var
    i   : byte;
    VIP : VisualItemPtr;
begin
     PopUpWinObj.Open;
     i:=1;
     with ItemList^ do
          begin
               ResetList;
               repeat
                     VIP:=VisualItemPtr(CurrentItem);
                     VIP^.Show(1, i, TotalCols, TextAttr);
                     if AtHeadOfList then
                        TopItem:=VIP
                     else
                        BotItem:=VIP;
                     NextItem;
                     Inc(i)
               until (i > TotalRows) or AtHeadOfList
          end
end;

procedure Scrollable.MoveUp;
begin
     if TopItem <> VisualItemPtr(ItemList^.Head) then
        begin
             PopUpWinObj.ScrollDn;
             TopItem:=VisualItemPtr(TopItem^.Prev);
             BotItem:=VisualItemPtr(BotItem^.Prev);
             TopItem^.Show(1, 1, TotalCols, TextAttr)
        end
end;

procedure Scrollable.MoveDn;
begin
     if BotItem^.Next <> ItemList^.Head then
        begin
             PopUpWinObj.ScrollUp;
             TopItem:=VisualItemPtr(TopItem^.Next);
             BotItem:=VisualItemPtr(BotItem^.Next);
             BotItem^.Show(1, TotalRows, TotalCols, TextAttr)
        end
end;

procedure Scrollable.Browse;
var
    Terminate : boolean;
    Ch        : char;
begin
     Terminate:=FALSE;
     repeat
           Ch:=ReadKey;
           case Ch of
                #0 : begin
                          Ch:=ReadKey;
                          case Ch of
                               #80 : MoveDn;
                               #72 : MoveUp;
                               else
                                  Write(#7)
                          end
                     end;
                #27: Terminate:=TRUE;
                else
                   Write(#7)
           end
     until Terminate
end;

constructor Chooseable.Init(LC, TR, RC, BR, WinAttr, HiAttr : byte;
                 var Frame : FrameChars; FrameAttr : byte;
                 Title : TitleStr; TitleAttr : byte;
                 WinFlag : byte);
begin
     PopUpWinObj.Init(LC, TR, RC, BR, WinAttr,
                      Frame, FrameAttr,
                      Title, TitleAttr, WinFlag);
     Hilight:=HiAttr;
     CurRow:=1;
     New(ItemList, Init);
     if (WinFlag and DrawBorder) > 0 then
        begin
             TotalRows:=Pred(BR-TR);
             TotalCols:=Pred(RC-LC)
        end
     else
        begin
             TotalRows:=Succ(BR-TR);
             TotalCols:=Succ(RC-LC)
        end
end;

procedure Chooseable.Open;
var
    i   : byte;
    VIP : VisualItemPtr;
begin
     PopUpWinObj.Open;
     i:=1;
     with ItemList^ do
          begin
               ResetList;
               repeat
                     VIP:=VisualItemPtr(CurrentItem);
                     if i = CurRow then
                        VIP^.Show(1, 1, TotalCols, Hilight)
                     else
                        VIP^.Show(1, i, TotalCols, TextAttr);
                     NextItem;
                     Inc(i)
               until (i > TotalRows) or AtHeadOfList;
               ResetList
          end
end;

procedure Chooseable.MoveUp;
var
    VIP : VisualItemPtr;
begin
     with ItemList^ do
          if not AtHeadOfList then
             begin
                  VIP:=VisualItemPtr(CIP);
                  VIP^.Show(1, CurRow, TotalCols, TextAttr);
                  PrevItem;
                  VIP:=VisualItemPtr(CIP);
                  if CurRow = 1 then
                     PopUpWinObj.ScrollDn
                  else
                     Dec(CurRow);
                  VIP^.Show(1, CurRow, TotalCols, Hilight)
             end
end;

procedure Chooseable.MoveDn;
var
    VIP : VisualItemPtr;
begin
     with ItemList^ do
          if not AtEndOfList then
             begin
                  VIP:=VisualItemPtr(CIP);
                  VIP^.Show(1, CurRow, TotalCols, TextAttr);
                  NextItem;
                  VIP:=VisualItemPtr(CIP);
                  if CurRow = TotalRows then
                     PopUpWinObj.ScrollUp
                  else
                     Inc(CurRow);
                  VIP^.Show(1, CurRow, TotalCols, Hilight)
        end
end;

function Chooseable.Choose : VisualItemPtr;
var
    Terminate : boolean;
    Ch        : char;
begin
     Terminate:=FALSE;
     repeat
           Ch:=ReadKey;
           case Ch of
                #0 : begin
                          Ch:=ReadKey;
                          case Ch of
                               #80 : MoveDn;
                               #72 : MoveUp;
                               else
                                  Write(#7)
                          end
                     end;
                #13: begin
                          Terminate:=TRUE;
                          Choose:=VisualItemPtr(ItemList^.CIP)
                     end;
                #27: begin
                          Terminate:=TRUE;
                          Choose:=nil
                     end
                else
                   Write(#7)
           end
     until Terminate
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


