
TXForm::TXForm() :
   TDialog( TRect(8, 6, 68, 22), "EXAMPLE"),
   TWindowInit( &TXForm::initFrame )
{
   TRect r;
   TView *b;
   r = TRect(1, 1, 17, 2);
   insert(new TStaticText(r, "  ┌ first field"));
   r = TRect(1, 6, 48, 7);
   insert(new TStaticText(r, "                                └── real types"));
   r = TRect(1, 3, 35, 4);
   insert(new TStaticText(r, "                                │"));
   r = TRect(1, 10, 40, 11);
   insert(new TStaticText(r, "                        └─ string[255]"));
   r = TRect(1, 5, 35, 6);
   insert(new TStaticText(r, "          │                     │"));
   r = TRect(1, 7, 13, 8);
   insert(new TStaticText(r, "          │"));
   r = TRect(1, 9, 27, 10);
   insert(new TStaticText(r, "          │             │"));
   r = TRect(1, 11, 13, 12);
   insert(new TStaticText(r, "          │"));
   r = TRect(1, 14, 31, 15);
   insert(new TStaticText(r, "          └──── ordinal types"));
   r = TRect(12, 2, 15, 3);
   b = new LChar(r);
   insert(b);
   r = TRect(2, 2, 12, 3);
   insert(new TLabel(r, "Char", b));
   r = TRect(12, 4, 17, 5);
   b = new LByte(r);
   insert(b);
   r = TRect(2, 4, 12, 5);
   insert(new TLabel(r, "Byte", b));
   r = TRect(12, 6, 19, 7);
   b = new LWord(r);
   insert(b);
   r = TRect(2, 6, 12, 7);
   insert(new TLabel(r, "Word", b));
   r = TRect(12, 8, 18, 9);
   b = new LShort(r);
   insert(b);
   r = TRect(2, 8, 12, 9);
   insert(new TLabel(r, "ShortInt", b));
   r = TRect(12, 10, 20, 11);
   b = new LInteger(r);
   insert(b);
   r = TRect(2, 10, 12, 11);
   insert(new TLabel(r, "Integer", b));
   r = TRect(12, 12, 25, 13);
   b = new LLongint(r);
   insert(b);
   r = TRect(2, 12, 12, 13);
   insert(new TLabel(r, "LongInt", b));
   r = TRect(34, 2, 46, 3);
   b = new LReal(r, 10, 2);
   insert(b);
   r = TRect(24, 2, 34, 3);
   insert(new TLabel(r, "Real", b));
   r = TRect(34, 4, 51, 5);
   b = new LExtended(r, 15, 5);
   insert(b);
   r = TRect(24, 4, 34, 5);
   insert(new TLabel(r, "Extended", b));
   r = TRect(32, 8, 58, 9);
   b = new LString(r, 255);
   insert(b);
   r = TRect(24, 8, 32, 9);
   insert(new TLabel(r, "String", b));
   r = TRect(28, 12, 55, 14);
   b = new TButton(r, "~B~utton", 113, 0);
   insert(b);
   selectNext( (Boolean) 0);
}

