
         {----------------------------------------------------}
         {     Программа обработки текстов и документов       }
         {                  LPrint                            }
         {             Модуль HLPrint V 1.0                   }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  30/12/1991             }
         {----------------------------------------------------}
         {   Модуль предназначен для обработки подсказок      }
         {                  программы LPrint                  }
         {----------------------------------------------------}
         { (c) 1991, Мигач Ярослав                            }
         {----------------------------------------------------}


UNIT HLPrint;

{$IFDEF DEBUGHELP }
        {$D+,L+,R+,S+}
{$ELSE}
        {$D-,L-,R-,S-}
{$ENDIF}
{$F+,O+,A+,B-,I-}

INTERFACE

USES Crt, Dos, Def, TWindow, LPtr, LcText, Fkey11, ViewT, EditT;

VAR
   Bll : FUNCTION ( Line : STRING; Next : RecLinePtr ) : RecLinePtr;
         { Функция построения строкового списка }

PROCEDURE SetBuildFunc;
PROCEDURE HelpForList;
PROCEDURE AddHelpEdit;
PROCEDURE AddExitHelp;
PROCEDURE HelpMenuBar;
PROCEDURE HelpForEditor;
PROCEDURE HelpForViewer;

IMPLEMENTATION

VAR
   HelpList : RecLinePtr;
            { Вспомогательный список }

   Stream : LocationProtectTextPtr;
            { Обрабатываемый поток }

   FileNameSpr : StandartString;
            { Имя файла справочника }

{----------------------------------------------------------}

PROCEDURE SetBuildFunc;

          { Установить функцию построения строкового списка }
BEGIN
     Bll := BuildLineList;
     HelpList := NIL

END; { SetBuildFunc }

{----------------------------------------------------------}

PROCEDURE HelpForList;

       { Подсказка по списку строк и уничтожение этого списка }
VAR
   Help : ViewTextPtr;
   Wind : TextWindowPtr;
   Num : LONGINT;

BEGIN
     NEW ( Wind, MakeWindow ( 3, 5, 77, 20, LIGHTGRAY, BLUE ) );
     Wind^.SetShade ( BLACK, BLACK );
     Wind^.FrameWindow ( 1, 1, 74, 15, 1, #205 );
     IF ( SizeListLine ( HelpList ) > 13 ) THEN
        BEGIN
             Wind^.SetColorSymbol ( BLACK );
             Wind^.SetColorFon ( WHITE );
             Wind^.WChar ( 74, 3, #24 );
             Wind^.WChar ( 74, 13, #25 );
        END;
     Wind^.SetColorFon ( CYAN );
     Wind^.SetColorSymbol ( BLACK );
     NEW ( Help, Init ( Wind,
           NEW ( LocationListTextPtr, Init ( HelpList, 200 ) ) ) );
     WITH Help^ DO
          BEGIN
               HideKey;
               SetState ( TRUE, TRUE );
               Control_Inf ( Num )
          END;
     DISPOSE ( Help, DoneWithStream );
     DISPOSE ( Wind, TypeDone );
     HelpList := NIL;
     HideKey

END; { procedure HelpForList }

{----------------------------------------------------------}

PROCEDURE AddHelpEdit;

          { добавить подсказку по редактированию полей }
VAR
   AddLst : RecLinePtr;

BEGIN
     AddLst :=
     Bll ( '',
     Bll ( ' Для редактирования поля используйте клавиши -',
     Bll ( '  '+#26+' , '+#27+'  - для перемещения внутри поля',
     Bll ( ' Delete или Ctrl + G - для удаления символа под курсором',
     Bll ( ' <-- или Ctrl + H    - для удаления символа перед курсором',
     Bll ( '             если нажать эту клавишу в первой позиции, то',
     Bll ( '             будут удалены все символы поля',
     Bll ( ' Enter или  Ctrl + '+#26+
           '  - для перемещения к следующему полю',
     Bll ( ' Ctrl + '+#27+'      - для перемещения к предыдущему полю',
     Bll ( '  '+#24+' , '+#25+' , PgUp, PgDown, End, Home - для перемещения',
     Bll ( '     по полям вверх и вниз',
     Bll ( '  Insert - для переключения режимов вставки/замещения',
     Bll ( '  ESC    - для отмены внесенных изменений',
     Bll ( '  F2     - для фиксирования внесеных изменений ',
     Bll ( '',
     Bll ( ' Нажмите Enter или ESC для выхода из подсказки ',
     NIL ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
     AddListLine ( HelpList, AddLst )

END; { procedure AddHelpEdit }

{----------------------------------------------------------}

PROCEDURE AddExitHelp;

         { добавить строки по выходу из подсказки }
VAR
   AddLst : RecLinePtr;

BEGIN
     AddLst :=
     Bll ( '',
     Bll ( ' Нажмите Enter или ESC для выхода из подсказки ',
     NIL ) );
     AddListLine ( HelpList, AddLst )

END; { procedure AddExitHelp }

{----------------------------------------------------------}

PROCEDURE HelpMenuBar;

          {   подсказка по использованию главного меню  }
BEGIN
     HelpList :=
     Bll ( '',
     Bll ( '  Вы находитесь в главном меню системы',
     Bll ( '',
     Bll ( '  Для перемешения по комадам меню используйте ',
     Bll ( '                '+#24+' , '+#25+' , '+#26+' , '+#27,
     Bll ( '  Для вызова под-меню или исполнения команды  Enter',
     Bll ( '  Для выхода на верхний уровень - ESC', NIL ) ) ) ) ) ) );
     AddExitHelp;
     HelpForList

END; { procedure HelpMenuBar }

{----------------------------------------------------------}

PROCEDURE HelpForEditor;

          { подсказка по текстовому редактору }
BEGIN
     HelpList :=
     Bll ( '',
     Bll ( ' Для редактирования текста используйте клавиши -',
     Bll ( '  '+#26+' , '+#27+'  - для перемещения по строке',
     Bll ( ' Delete или Ctrl + G - для удаления символа под курсором',
     Bll ( ' <-- или Ctrl + H    - для удаления символа перед курсором',
     Bll ( ' Ctrl + '+#26+
           '  - для перемещения к следующему слову',
     Bll ( ' Ctrl + '+#27+'      - для перемещения к предыдущему слову',
     Bll ( '  '+#24+' , '+#25+'  - для перемещения между строками',
     Bll ( ' PgUp   - для перемещения на страницу вверх',
     Bll ( ' PgDown - для перемещения на страницу вниз',
     Bll ( ' End    - для перемещения в начало строки',
     Bll ( ' Home - для перемещения в конец строки',
     Bll ( ' Ctl + '+#24+' - для перемещения в начало текста',
     Bll ( ' Ctl + '+#25+' - для перемещения в конец текста ',
     Bll ( '  Insert - для переключения режимов вставки/замещения',
     Bll ( '  Enter - для добавления строки в текст в режиме вставки',
     Bll ( '  ESC   - для завершения редактирования',
         NIL ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) );
     AddExitHelp;
     HelpForList

END; { procedure HelpForEditor }

{----------------------------------------------------------}

PROCEDURE HelpForViewer;

          { подсказка по текстовому просмотру }
BEGIN
     HelpList :=
     Bll ( '',
     Bll ( ' Для просмотра текста используйте клавиши -',
     Bll ( '',
     Bll ( '  '+#26+' , '+#27+'  - для перемещения текста влево и вправо',
     Bll ( '  '+#24+' , '+#25+'  - для перемещения по строкам',
     Bll ( ' PgUp   - для перемещения на страницу вверх',
     Bll ( ' PgDown - для перемещения на страницу вниз',
     Bll ( ' End    - для перемещения в начало текста',
     Bll ( ' Home - для перемещения в конец текста',
     Bll ( ' Enter - для завершения просмотра',
     Bll ( ' ESC   - для завершения просмотра',
         NIL ) ) ) ) ) ) ) ) ) ) );
     AddExitHelp;
     HelpForList

END; { procedure HelpForViewer }

{----------------------------------------------------------}

END.
