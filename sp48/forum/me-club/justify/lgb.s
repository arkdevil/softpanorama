macro_file LGB;
/*************************************************************************
*                                                                        *
*  Разные макро -- Л.Г.Бунич -- Multi-Edit 6.00P                         *
*                                                                        *
*  Extend_Block.. расширить блок до текущего места                       *
*  Erase_Word.... заменить текущее слово пробелами                       *
*  TO_WORD_END..  направо на слово, но курсор (в отличие от              *
*                 WORD_RIGHT) устанавливается в позицию ЗА КОНЦОМ слова  *
*                                                                        *
*************************************************************************/

macro Extend_Block{
 if (Block_Stat && !Marking) {
   Refresh = FALSE; Mark_Pos;
   RM('MESYS^TOPBLOCK');
   if (Block_Stat == 1)
     Block_Begin;
   else if (Block_Stat == 2)
     Col_Block_Begin;
   else
     Str_Block_Begin;
   GoTo_Mark;
   Block_End; Refresh = TRUE;
 }
};

Macro Erase_Word {

  int im;

  Push_Undo; Refresh = FALSE;
  im = Insert_Mode; Insert_Mode = FALSE;
  if ( Xpos(Cur_Char,Word_Delimits,1)  ) {
    Text(' ');         // мы вне слова
  } else {
    Right; Word_Left;  // мы внутри слова
    while ((Xpos(Cur_Char,Word_Delimits,1) == 0) || (Cur_Char == ' '))
      Text (' ');
  };
  Insert_Mode = im;  Refresh = TRUE;  Pop_Undo;
}

macro To_Word_End{

  Forward_Till_Not(Word_Delimits);
  Forward_Till(Word_Delimits);

};
