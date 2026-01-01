type
   FindRec = record
    InputLine : String[80];
    CheckBoxes:Word;
   end;
function Find(var Rec:FindRec):Word;
var
     Control,Control1 : PView;
     R : TRect;
     Dialog : PDialog;
begin
   R.Assign(12,6,68,17);
   Dialog := New(PDialog,Init(R,'Find'));
   with Dialog^ do
    begin
       R.Assign(17,2,51,3);
       Control := New(PInputLine,Init(R,80));
       Insert(Control);
       R.Assign(51,2,54,3);
       Insert(New(PHistory,Init(R,PInputLine(Control),101)));
       R.Assign(1,2,17,3);
       Insert(New(PLabel,Init(R,'~T~ext to Find:',Control)));
       R.Assign(2,5,26,7);
       Control := New(PCheckBoxes,Init(R,
                 NewSItem('~C~ase sensitive',
                 NewSItem('~W~hole words only',
                      nil))));
       Insert(Control);
       R.Assign(2,4,12,5);
       Insert(New(PLabel,Init(R,'~O~ptions',Control)));
       R.Assign(16,8,24,10);
       Control := New(PButton,Init(R,'~O~k',cmOk,bfDefault));
       Insert(Control);
       R.Assign(29,8,39,10);
       Control := New(PButton,Init(R,'Cancel',cmCancel,bfNormal));
       Insert(Control);
       SelectNext(False);
    end;
   Find := cmCancel;
   if Application^.ValidView(Dialog) <> nil then
     begin
      Dialog^.SetData(Rec);
      Find := DeskTop^.ExecView(Dialog);
      Dialog^.GetData(Rec);
      Dispose(Dialog,Done)
     end;
end;
