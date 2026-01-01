
type

 PXForm = ^XForm;
 XForm  = object(TForm)
  constructor Init;
 end;

 constructor XForm.Init;
  var
   B : PView;
   R : TRect;
  begin
   R.Assign(8, 6, 68, 22);
   TForm.Init(R, 'EXAMPLE', 3);
   R.Assign(1, 1, 17, 2);
   Insert(New(PStaticText, Init(R, '  ┌ first field')));
   R.Assign(1, 6, 48, 7);
   Insert(New(PStaticText, Init(R, '                                └── real types')));
   R.Assign(1, 3, 35, 4);
   Insert(New(PStaticText, Init(R, '                                │')));
   R.Assign(1, 10, 40, 11);
   Insert(New(PStaticText, Init(R, '                        └─ string[255]')));
   R.Assign(1, 5, 35, 6);
   Insert(New(PStaticText, Init(R, '          │                     │')));
   R.Assign(1, 7, 13, 8);
   Insert(New(PStaticText, Init(R, '          │')));
   R.Assign(1, 9, 27, 10);
   Insert(New(PStaticText, Init(R, '          │             │')));
   R.Assign(1, 11, 13, 12);
   Insert(New(PStaticText, Init(R, '          │')));
   R.Assign(1, 14, 31, 15);
   Insert(New(PStaticText, Init(R, '          └──── ordinal types')));
   R.Assign(12, 2, 15, 3);
   B:=New(PLChar, Init(R));
   Insert(B);
   R.Assign(2, 2, 12, 3);
   Insert(New(PLabel, Init(R, 'Char', B)));
   R.Assign(12, 4, 17, 5);
   B:=New(PLByte, Init(R));
   Insert(B);
   R.Assign(2, 4, 12, 5);
   Insert(New(PLabel, Init(R, 'Byte', B)));
   R.Assign(12, 6, 19, 7);
   B:=New(PLWord, Init(R));
   Insert(B);
   R.Assign(2, 6, 12, 7);
   Insert(New(PLabel, Init(R, 'Word', B)));
   R.Assign(12, 8, 18, 9);
   B:=New(PLShort, Init(R));
   Insert(B);
   R.Assign(2, 8, 12, 9);
   Insert(New(PLabel, Init(R, 'ShortInt', B)));
   R.Assign(12, 10, 20, 11);
   B:=New(PLInteger, Init(R));
   Insert(B);
   R.Assign(2, 10, 12, 11);
   Insert(New(PLabel, Init(R, 'Integer', B)));
   R.Assign(12, 12, 25, 13);
   B:=New(PLLongint, Init(R));
   Insert(B);
   R.Assign(2, 12, 12, 13);
   Insert(New(PLabel, Init(R, 'LongInt', B)));
   R.Assign(34, 2, 46, 3);
   B:=New(PLReal, Init(R, 10, 2));
   Insert(B);
   R.Assign(24, 2, 34, 3);
   Insert(New(PLabel, Init(R, 'Real', B)));
   R.Assign(34, 4, 51, 5);
   B:=New(PLExtended, Init(R, 15, 5));
   Insert(B);
   R.Assign(24, 4, 34, 5);
   Insert(New(PLabel, Init(R, 'Extended', B)));
   R.Assign(32, 8, 58, 9);
   B:=New(PLString, Init(R, 255));
   Insert(B);
   R.Assign(24, 8, 32, 9);
   Insert(New(PLabel, Init(R, 'String', B)));
   R.Assign(28, 12, 55, 14);
   B:=New(PButton, Init(R, '~B~utton', 113, 0));
   Insert(B);
   SelectNext(False);
  end;

