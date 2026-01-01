
TXForm::TXForm() :
   TDialog( TRect(10, 4, 75, 17), "Картотека"),
   TWindowInit( &TXForm::initFrame )
{
   TRect r;
   TView *b;
   r = TRect(13, 2, 45, 3);
   b = new LString(r, 30);
   insert(b);
   r = TRect(3, 2, 13, 3);
   insert(new TLabel(r, "Фамилия", b));
   r = TRect(13, 4, 35, 5);
   b = new LString(r, 20);
   insert(b);
   r = TRect(3, 4, 13, 5);
   insert(new TLabel(r, "Имя", b));
   r = TRect(13, 6, 35, 7);
   b = new LString(r, 20);
   insert(b);
   r = TRect(3, 6, 13, 7);
   insert(new TLabel(r, "Отчество", b));
   r = TRect(20, 8, 27, 9);
   b = new LWord(r);
   insert(b);
   r = TRect(3, 8, 20, 9);
   insert(new TLabel(r, "Табельный номер", b));
   r = TRect(31, 10, 43, 11);
   b = new LReal(r, 10, 2);
   insert(b);
   r = TRect(3, 10, 31, 11);
   insert(new TLabel(r, "Сумма на счету в сберкассе", b));
   r = TRect(47, 1, 63, 3);
   b = new TButton(r, "~З~аписать", 0, 0);
   insert(b);
   r = TRect(47, 4, 63, 6);
   b = new TButton(r, "~У~далить", 0, 0);
   insert(b);
   r = TRect(47, 7, 63, 9);
   b = new TButton(r, "~С~ледующий", 0, 0);
   insert(b);
   r = TRect(47, 10, 63, 12);
   b = new TButton(r, "~П~редыдущий", 0, 0);
   insert(b);
   selectNext( (Boolean) 0);
}

