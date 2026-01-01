
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
   R.Assign(2, 1, 28, 13);
   TForm.Init(R, 'Menu', 1);
   R.Assign(1, 2, 24, 4);
   B:=New(PButton, Init(R, '~К~арточки', 0, 0));
   Insert(B);
   R.Assign(1, 4, 24, 6);
   B:=New(PButton, Init(R, '~П~ример ввода', 0, 0));
   Insert(B);
   R.Assign(1, 6, 24, 8);
   B:=New(PButton, Init(R, '~В~ывод данных', 0, 0));
   Insert(B);
   R.Assign(6, 9, 17, 11);
   B:=New(PButton, Init(R, 'Выход', 0, 0));
   Insert(B);
   SelectNext(False);
  end;

