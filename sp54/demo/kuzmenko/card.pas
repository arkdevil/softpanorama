
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
   R.Assign(10, 4, 75, 17);
   TForm.Init(R, 'Картотека', 2);
   R.Assign(13, 2, 45, 3);
   B:=New(PLString, Init(R, 30));
   Insert(B);
   R.Assign(3, 2, 13, 3);
   Insert(New(PLabel, Init(R, 'Фамилия', B)));
   R.Assign(13, 4, 35, 5);
   B:=New(PLString, Init(R, 20));
   Insert(B);
   R.Assign(3, 4, 13, 5);
   Insert(New(PLabel, Init(R, 'Имя', B)));
   R.Assign(13, 6, 35, 7);
   B:=New(PLString, Init(R, 20));
   Insert(B);
   R.Assign(3, 6, 13, 7);
   Insert(New(PLabel, Init(R, 'Отчество', B)));
   R.Assign(20, 8, 27, 9);
   B:=New(PLWord, Init(R));
   Insert(B);
   R.Assign(3, 8, 20, 9);
   Insert(New(PLabel, Init(R, 'Табельный номер', B)));
   R.Assign(31, 10, 43, 11);
   B:=New(PLReal, Init(R, 10, 2));
   Insert(B);
   R.Assign(3, 10, 31, 11);
   Insert(New(PLabel, Init(R, 'Сумма на счету в сберкассе', B)));
   R.Assign(47, 1, 63, 3);
   B:=New(PButton, Init(R, '~З~аписать', 0, 0));
   Insert(B);
   R.Assign(47, 4, 63, 6);
   B:=New(PButton, Init(R, '~У~далить', 0, 0));
   Insert(B);
   R.Assign(47, 7, 63, 9);
   B:=New(PButton, Init(R, '~С~ледующий', 0, 0));
   Insert(B);
   R.Assign(47, 10, 63, 12);
   B:=New(PButton, Init(R, '~П~редыдущий', 0, 0));
   Insert(B);
   SelectNext(False);
  end;

