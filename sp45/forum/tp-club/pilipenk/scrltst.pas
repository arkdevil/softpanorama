program ScrollTest;
uses
    Crt, Win, ScrlWin;
var
    A, B : Scrollable;
    C    : Chooseable;
    D    : PopUpWinObj;
    VIP  : VisualItemPtr;
    i    : byte;

procedure FileBrowse(var A : Scrollable; FName : string);
var
    S : string;
    F : text;
    VIP : VisualItemPtr;
begin
     Assign(F, FName);
     Reset(F);
     while not Eof(F) do
           begin
                Readln(F, S);
                New(VIP, Init);
                VIP^.PutEqualTo(S);
                A.ItemList^.InsertItem(VIP);
           end;
     A.Open;
     A.Browse;
end;

procedure AddBrowseItem(A : Chooseable; S : string);
var
    VIP : VisualItemPtr;
begin
     New(VIP, Init);
     VIP^.PutEqualTo(S);
     A.ItemList^.InsertItem(VIP)
end;

procedure InitPickList(A : Chooseable);
begin
     AddBrowseItem(C, 'Load');
     AddBrowseItem(C, 'Pick');
     AddBrowseItem(C, 'New');
     AddBrowseItem(C, 'Save');
     AddBrowseItem(C, 'Write to');
     AddBrowseItem(C, 'Directory');
     AddBrowseItem(C, 'Change dir');
     AddBrowseItem(C, 'OS shell');
     AddBrowseItem(C, 'Quit');
     AddBrowseItem(C, 'Special 1');
     AddBrowseItem(C, 'Special 2');
     AddBrowseItem(C, 'Special 3');
     AddBrowseItem(C, 'Special 4');
     AddBrowseItem(C, 'Special 5');
     AddBrowseItem(C, 'Special 6');
     AddBrowseItem(C, 'Special 7');
     AddBrowseItem(C, 'Special 8');
     AddBrowseItem(C, 'Special 9');
     AddBrowseItem(C, 'Special 10');
end;

begin
     A.Init(1, 1, 65, 15, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' SCRLTST.PAS ', Attr(Black, LightGray),
            DefaultFlag);
     B.Init(10, 10, 80, 24, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' SCRLWIN.PAS ', Attr(Black, LightGray),
            DefaultFlag);
     C.Init(15, 5, 45, 15, Attr(LightGray, Black), Attr(Black, LightGray),
            DoubleFrame, Attr(White, Black),
            ' Choose ! ', Attr(Black, LightGray),
            DefaultFlag);
     D.Init(5, 18, 75, 25, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' Process ', Attr(Black, LightGray),
            DefaultFlag);
     InitPickList(C);

     ClrScr;
     FileBrowse(A, 'SCRLTST.PAS');
     FileBrowse(B, 'SCRLWIN.PAS');
     C.Open;
     VIP:=C.Choose;
     if VIP <> nil then
        begin
          D.Open;
          VIP^.Show(5, 3, 80, TextAttr);
          Delay(3000)
        end;
end.
