Macro_file LGB6;

/************************************************************************
*                                                                       *
*  (C) Copyright Л.Г.Бунич -- Multi-Edit 6.1                            *
*  Список макро:                                                        *
*                                                                       *
*  FCmenu........ диалоговый интерфейс макроса FC (В.А.Мунтьянов)       *
*  Half_Up....... сдвиг на пол-экрана вверх                             *
*  Half_Down..... сдвиг на пол-экрана вниз                              *
*  Half_Right.... сдвиг на пол-экрана направо                           *
*  Half_Left..... сдвиг на пол-экрана налево                            *
*  Ind_Und_1..... сдвиг блока строк налево или направо на 1 колонку     *
*  UtCall........ вызов внешней программы или пакета для текущего       *
*                 файла в DOSSHELL.                                     *
*                                                                       *
************************************************************************/

Macro FCmenu {

  int mh, cw=Cur_Window, k;
  str FCparam=' ';

  mh = Menu_Create;
  Menu_Set_Item(mh,1,"Загрузить файлы: ", "/T=Нет/F=Да",
                     "/QK=1/L=2/C=2/W=3", 5, 1, 0);
  Menu_Set_Item(mh,2,"Формат сравнения плавающий: ", "/T=Нет/F=Да",
                     "/QK=1/L=3/C=2/W=3", 5, 1, 0);
  Menu_Set_Item(mh,3,"Различать заглавные и строчные буквы: ", "/T=Нет/F=Да",
                     "/QK=1/L=4/C=2/W=3", 5, 1, 0);
  Menu_Set_Item(mh,4,"Проводить сравнение в колонках......", "",
                     "/QK=1/L=5/C=2/W=3/MIN=1/MAX=999",1, 1,0);
  Menu_Set_Item(mh,5,"-", "", "/L=5/C=42",10, 1,0);
  Menu_Set_Item(mh,6,"", "", "/QK=1/L=5/C=43/W=3/MIN=1/MAX=999",1, 999,0);
  Return_Int = mh;
  RM("USERIN^DATA_IN /HN=1/#=6/T=Сравнение текстов");

  if (Return_Int) {
    if ( Menu_Item_Int(mh,1,2) == 1 ) {
      RM('FC^WIN1');  RM('WINDOW^NEXTWIN');
      RM('FC^WIN2');  RM('WINDOW^NEXTWIN');
      if (Cur_Window != cw) {                   // более двух окон
        Make_Message('  Пометьте первое окно для сравнения -');
        RM('WINDOW^WINOP /T=3');
        if (KEY2 == 1) { Make_Message('');  goto Finish; }
        RM('FC^WIN1');
        Make_Message('  Пометьте второе окно для сравнения -');
        RM('WINDOW^WINOP /T=3');
        if (KEY2 == 1) { Make_Message('');  goto Finish; }
        RM('FC^WIN2');
      }
    } else {
      // загрузим файлы в новое (разделенное) окно
      RM('WINDOW^MAKEWIN /L=1');
      if ( ( CAPS(File_Name) == '?NO-FILE?' ) || (Error_Level > 0) )
        { Delete_Window; goto Finish; }
      RM('FC^WIN1');
      Set_Global_Int('Win_No_File1',Window_Id);
      Set_Global_Str('FileName_1',File_Name);
      Run_Macro('SPLITWIN');
      if ( (Global_Int('s_direction') == 0) ) Goto Finish;      // нажато ESC
      RM('FC^WIN2');
    }

    if ( Menu_Item_Int(mh,2,2) == 0 )  FCparam = FCparam + '/I';
    if ( Menu_Item_Int(mh,3,2) == 1 )  FCparam = FCparam + '/U';
    k = Menu_Item_Int(mh,4,2);
    if (k != 1)   FCparam = FCparam + '/F=' + Str(k);
    k = Menu_Item_Int(mh,6,2);
    if (k != 999) FCparam = FCparam + '/T=' + Str(k);
    RM('FC ' + FCparam);
  }
Finish:
  Menu_Delete(mh);
}

macro Half_Up {

  int l = (Win_Y2 - Win_Y1)/2;

  while ( l > 0 )  { RM('MESYS^ScrollDn'); --l; };

};

macro Half_Down {

  int l = (Win_Y2 - Win_Y1)/2;

  while ( l > 0 )  { RM('MESYS^ScrollUp'); --l; };

};

macro Half_Right {

  int k = C_Col, l = (Win_X2 - Win_X1)/2;

  GoTo_Col(k - WhereX + Win_X2 - 1 + l);
  GoTo_Col(k - WhereX + Win_X2 - 1 + l);

};

macro Half_Left {

  int k = C_Col, l = (Win_X2 - Win_X1)/2;

  GoTo_Col(k - WhereX + Win_X1 + 1 - l);
  GoTo_Col(k - WhereX + Win_X1 + 1 - l);

};

Macro Ind_Und_1{

  int t = XPos ('|16', Format_Line, 1) - 1;

  RM ('MESYS^SETTABS /TS=1');
  if (Xpos('L',CAPS(Mparm_Str),1))  RM ('MEUTIL2^UNDBLK');
                              else  RM ('MEUTIL2^INDBLK');
  RM ('MESYS^SETTABS /TS=' + Str(t));

};

Macro UtCall FROM DOS_SHELL {

/***********************************************************************
*                                                                      *
*  Запуск (только в среде File Manager):                               *
*                                                                      *
*         UtCall  программа  [аргументы]                               *
*                                                                      *
*  Результат - формируется и выполняется командная строка:             *
*                                                                      *
*         программа  текущий_файл  [аргументы]                         *
*                                                                      *
***********************************************************************/

  int k, cw;

  if (Mode != DOS_Shell)  {
    Make_Message('UtCall: invalid ME mode!');  goto F;  }
  Refresh = False;  Working;
  k = Xpos(' ',Mparm_Str,1);

  cw = Cur_Window;  Switch_Window(Window_Count);
  Create_Window;
  if (k) Return_Str = Copy( Mparm_Str, 1, k ) + Dir_Entry +
                      Copy( Mparm_Str, k, Length(Mparm_Str) - k + 1 );
    else Return_Str = Mparm_Str + ' ' + Dir_Entry;
  Make_Message('Utility call: ' + Return_Str);
  RM('MEUTIL1^EXEC /MEM=0/CMD=1');

  Refresh = False;       Delete_Window;
  Switch_Window(cw);     Refresh = True;
  RM('UpdateDir /M=3');  Make_Message('File Manager restored.');
F:
}
