
TXForm::TXForm() :
   TDialog( TRect(2, 1, 28, 13), "Menu"),
   TWindowInit( &TXForm::initFrame )
{
   TRect r;
   TView *b;
   r = TRect(1, 2, 24, 4);
   b = new TButton(r, "~К~арточки", 0, 0);
   insert(b);
   r = TRect(1, 4, 24, 6);
   b = new TButton(r, "~П~ример ввода", 0, 0);
   insert(b);
   r = TRect(1, 6, 24, 8);
   b = new TButton(r, "~В~ывод данных", 0, 0);
   insert(b);
   r = TRect(6, 9, 17, 11);
   b = new TButton(r, "Выход", 0, 0);
   insert(b);
   selectNext( (Boolean) 0);
}

