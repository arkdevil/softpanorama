type
  Scrollable = object(PopUpWinObj)
                 ItemList   : ListPtr;
                 TotalRows  : byte;
                 TotalCols  : byte;
                 constructor Init(LC, TR, RC, BR, WinAttr : byte;
                                  var Frame : FrameChars; FrameAttr : byte;
                                  Title : TitleStr; TitleAttr : byte;
                                  WinFlag : byte);
                 procedure Open; virtual;
                 procedure Browse; virtual;
               private
                 TopItem    : VisualItemPtr;
                 BotItem    : VisualItemPtr;
                 procedure MoveUp; virtual;
                 procedure MoveDn; virtual;
               end;

