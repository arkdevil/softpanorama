
type

 PXForm = ^XForm;
 XForm  = object(TForm);
  constructor Init;
 end;

 constructor XForm.Init;
  var
   B : PView;
   R : TRect;
  begin
   R.Assign(48, 6, 77, 22);
   TForm.Init(R, 'Menu', 0);
   R.Assign(1, 2, 27, 4);
   Insert(New(PButton, Init(R, 'New Form', 2000, 0)));
   R.Assign(1, 4, 27, 6);
   Insert(New(PButton, Init(R, 'Load Form', 2001, 0)));
   R.Assign(1, 6, 27, 8);
   Insert(New(PButton, Init(R, 'Save Form', 2002, 0)));
   R.Assign(1, 8, 27, 10);
   Insert(New(PButton, Init(R, 'Text Gen', 2003, 0)));
   R.Assign(1, 10, 27, 12);
   Insert(New(PButton, Init(R, 'Record Gen', 2004, 0)));
   R.Assign(9, 13, 19, 15);
   Insert(New(PButton, Init(R, 'Exit', 2005, 0)));
   SelectNext(False);
  end;

