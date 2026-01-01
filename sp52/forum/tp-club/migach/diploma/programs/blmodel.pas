
            {-------------------------------------------------}
            {           Модуль  BLModel  V 1.0                }
            {  программы моделирования цифровых электронных   }
            {                 схем                            }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания :01/04/1992                       }
            { Дата последних изменений : 07/04/1992           }
            {-------------------------------------------------}
            {    Модуль содержит обьекты для моделирования    }
            {   элементов комбинационных логических схем      }
            {      моделей  цифровых  электронных схем        }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}

UNIT BLModel;

    {===================== Ключи компиляции ===================}

{$F+,O+,A+,B-,X+,V-}

{$IFDEF DEBUGBLMODEL }
        {$D+,L+,R+,S+,I+}
{$ELSE}
        {$D-,L-,R-,S-,I-}
{$ENDIF}

    {==========================================================}

INTERFACE

USES Dos, Crt, GModel;

TYPE
    TypeLm = RECORD
                      { Данные о выводе элемента            }
                      { комбинационной логической схемы     }

                StLm : InformLm;
                      { Текущее состояние вывода }

                Friend : ConcatLm;
                      { Информация о подсоединениях }

                LogicState : BOOLEAN;
                      { Текущее логическое состояние }

                { Предполагается, что вывод комбинационной схемы    }
                { не может в процессе своей работы менять состояние }
                { с входного на выходной и наоборот                 }

                CASE StateLm OF

                      { Информация о выводе, если он является выходом }

                      OutLm : (
                           Out_1 : REAL;
                              { Напряжение выхода "1" }

                           Out_0 : REAL;
                              { Напряжение выхода "0" }

                           OutCount : REAL;
                              { Приращение напряжения переключения выхода }
                          );

                       { Информация о выводе, если он является входом }

                       InLm :  (
                           InPrU_1 : REAL;
                                { Пороговое напряжение идентификации "1" }

                           InPrU_0 : REAL;
                                { Пороговое напряжение перехода в "0"    }

                           InCounter : WORD;
                                 { Счетчик по входу }

                           InPrCounter_1 : WORD;
                                 { Пороговое значение для переброски в "1" }

                           InPrCounter_0 : WORD;
                                 { Пороговое значение для переброски в "0" }
                          )

                END; { record TypeLm }

{----------------------------------------------------------}

    StateBLModel = ARRAY [ 1..MaxDealLm ] OF TypeLm;
               { Массив состояния модели комбинационной схемы }

    StateBLModelPtr = ^StateBLModel;
               { Указатель на массив состояния модели комбинационной схемы }

{----------------------------------------------------------}

    BaseLogicModel = OBJECT ( BaseModel )
                     { Обьект базовой модели комбинационной схемы }

                      InfModel : StateBLModelPtr;
                            { Указатель на массив состояния выводов }

                      SingLogic : BOOLEAN;
                            { Признак установки логики }

                      Razbros : REAL;
                            { Разброс параметров в процентах по }
                            { выводам моделируемой схемы        }

                      Out_1_All : REAL;
                            { Общее напряжение выхода "1" }

                      Out_0_All : REAL;
                            { Общее напряжение выхода "0" }

                      Out_Count_All : REAL;
                            { Общее напряжение счетчика приращения }

                      InPr_1_All : REAL;
                            { Общее пороговое напряжение "1" }

                      InPr_0_All : REAL;
                            { Общее пороговое напряжение "0" }

                      InCount_1_All : WORD;
                            { Общее пороговое значение "1" счетчика задержки }

                      InCount_0_All : WORD;
                            { Общее пороговое напряжение "0" счетчика задержки }

                      CONSTRUCTOR Init ( Deal : BYTE; OU_1, OU_0, OU_C : REAL;
                                  IU_1, IU_0 : REAL; IC_1, IC_0 : WORD;
                                  RB : REAL );
                               { Инициализация модели, установка }
                               { начального состояния            }

                      PROCEDURE SetParamLm ( NumLm : BYTE; State : StateLm );
                                VIRTUAL;
                               { Установить параметры моделирования для }
                               {         указанного вывода              }

                      PROCEDURE GetStateLm ( NumLm : BYTE; VAR State : InformLm);
                               VIRTUAL;
                               { Получить текущее состояние   }
                               { выхода микросхемы            }

                      PROCEDURE ConnectLm ( MyNum, NumObj : BYTE;
                                           ObjPtr : BaseModelPtr;
                                           VAR Result : BYTE ); VIRTUAL;
                               { Установить соединение с другим обьектом }
                               { MyNum  - номер вывода данного обьекта   }
                               { NumObj - номер вывода подсоединяемого   }
                               {        обьекта                          }
                               { ObjPtr - указатель на подсоединяемый    }
                               {        обьект                           }
                               { Result - результат операции :           }
                               { > 0  - успешное соединение              }
                               { > 1  - соединение уже было задано       }
                               { > 2  - нет места для соединения         }
                               { > 3  - соединение невозможно            }

                      PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                      PROCEDURE SetStart; VIRTUAL;
                               { Устанавливает начальное состояние выходов }
                               { таким образом, чтобы оно соответсвовало   }
                               { состоянию - все единицы на всех входах    }

                      PROCEDURE RunModel; VIRTUAL;
                               { Произвести один такт моделирования  }
                               { изменив при необходимости состояние }
                               { выходов в соответствии с состоянием }
                               {              входов                 }

                      DESTRUCTOR Done; VIRTUAL;
                               { Уничтожение обьекта модели }

                END; { object BaseLogicModel }


    BaseLogicModelPtr = ^BaseLogicModel;
               { Указатель на обьект модели абстрактной логической }
               { схемы                                             }

{----------------------------------------------------------}

IMPLEMENTATION

{==========================================================}

CONSTRUCTOR BaseLogicModel.Init ( Deal : BYTE; OU_1, OU_0, OU_C : REAL;
                                  IU_1, IU_0 : REAL; IC_1, IC_0 : WORD;
                                  RB : REAL );
            { Инициализация модели, установка }
            { начального состояния            }

VAR
   Index : BYTE;
            { Индексная переменная по выводам }

   Hlp : BYTE;
            { Индексная переменная по подсоединениям }
BEGIN
            { Инициализация базовой модели }

     BaseModel.Init;

            { Установка размеров }

     DealLm := Deal;

        { Анализ ошибочной ситуации }

     IF ( ( DealLm > MaxDealLm ) OR ( DealLm = 0 ) ) THEN
        FatalError ( 'BLModel', 'BaseKeyModel.Init',
                     'слишком много выводов' );

        { Установка параметров по выходу }

     Out_1_All := OU_1;
     Out_0_All := OU_0;
     Out_Count_All := OU_C;

        { Анализ ошибочной ситуации }

     IF ( ABS ( Out_1_All - Out_0_All ) < ABS ( Out_Count_All ) ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.Init',
                     'Недопустимое значение напряжения приращения выхода' );

     IF ( OU_0 >= OU_1 ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.Init',
                     'Недопустимые значения пороговых напряжений по выходу' );

        { Установка параметров по входу }

     InPr_1_All := IU_1;
     InPr_0_All := IU_0;
     InCount_1_All := IC_1;
     InCount_0_All := IC_0;


        { Анализ ошибочной ситуации }

     IF ( ( InCount_1_All - InCount_0_All ) < 2 ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.Init',
                     'Недопустимый разнос порогов задержки по входу' );

     IF ( IC_0 < 1 ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.Init',
                     'Недопустимое значение нижнего порога сч. задержки' );

     IF ( IU_0 >= IU_1 ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.Init',
                     'Недопустимые значения пороговых напряжений по входу' );

        { Параметры разброса }

     Razbros := RB;

        { Анализ ошибочной ситуации }

     IF ( ( RB < 0.0 ) OR ( RB > 70.0 ) ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.Init',
                     'Недопустимое значени параметра разброса ' );

        { Распределение памяти }

     GETMEM ( InfModel, SIZEOF ( TypeLm ) * Deal );

        { Установка всех выводов в Error состояние }
        { посколько характер выводов определяется  }
        { индивидуально                            }

     FOR Index := 1 TO DealLm DO
         InfModel^[ Index ].StLm.State := Error;

        { Внутренняя логика не установлена }

     SingLogic := FALSE;

        { Подсоединения не установлены }

     FOR Index := 1 TO DealLm DO
         WITH InfModel^[ Index ] DO
              BEGIN
                   FOR Hlp := 1 TO MaxConnect DO
                       WITH Friend [ Hlp ] DO
                            BEGIN
                                 Point := NIL;
                                 Num := 0
                            END
              END;

END; { BaseLogicModel.Init }

{----------------------------------------------------------}

PROCEDURE BaseLogicModel.SetParamLm ( NumLm : BYTE; State : StateLm );
            { Установить параметры моделирования для }
            {         указанного вывода              }

VAR
   Index : BYTE;
         { Индексная переменная }

   Signum : REAL;
         { Знак + или - случайного числа }

   MaxAddReal : REAL;
         { Максимальное приращение напряжения }

   AddReal : REAL;
         { Имеющееся приращение напряжения }

   MaxAddCount : WORD;
         { Максимальное приращение счетчика }

   AddCount : WORD;
         { Имеющееся приращение счетчика }

   Rnd : WORD;
         { Случайное число }

BEGIN
        { Анализ ошибочной ситуации }

     IF ( ( NumLm > DealLm ) OR ( NumLm = 0 ) ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.SetParamLm',
                     'нет такого номера вывода' );

     IF ( NOT ( State IN [ InLm, OutLm ] ) ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.SetParamLm',
                     'запрещенное состояние' );

        { Установка вида вывода }

     InfModel^[ NumLm ].StLm.State := State;

        { Установка параметров по входу }

     IF ( State = InLm ) THEN
        BEGIN
             { Определяем максимально возможное приращение }

             MaxAddReal := ( InPr_1_All - InPr_0_All ) / 3.0;
             IF ( ( InPr_1_All / 100.0 ) * Razbros < MaxAddReal ) THEN
                MaxAddReal := ( InPr_1_All / 100.0 ) * Razbros;

             { Определяем знак приращения напряжения }

             Rnd := RANDOM ( 1 );
             IF ( Rnd = 1 ) THEN
                Signum := 1.0
             ELSE
                 Signum := -1.0;

             { Определяем пороговое напряжение "1" }

             Rnd := RANDOM ( 100 );
             AddReal := ( ( MaxAddReal / 100.0 ) * Rnd ) * Signum;
             InfModel^[ NumLm ].InPrU_1 := InPr_1_All + AddReal;

             { Определяем знак приращения напряжения }

             Rnd := RANDOM ( 1 );
             IF ( Rnd = 1 ) THEN
                Signum := 1.0
             ELSE
                 Signum := -1.0;

             { Определяем пороговое напряжение "0" }

             Rnd := RANDOM ( 100 );
             AddReal := ( ( MaxAddReal / 100.0 ) * Rnd ) * Signum;
             InfModel^[ NumLm ].InPrU_0 := InPr_0_All + AddReal;

             { Определяем максимальное значение приращения счетчика }

             MaxAddCount := ( InCount_1_All - InCount_0_All ) * 2;
             IF ( ( ROUND ( ( InCount_1_All / 100.0 ) * Razbros ) ) <
                  MaxAddCount ) THEN
                MaxAddCount := ROUND ( ( InCount_1_All / 100.0 ) * Razbros );

             { Определяем верхнее пороговое значение счетчика }

             AddCount := RANDOM ( MaxAddCount );
             InfModel^[ NumLm ].InPrCounter_1 := InCount_1_All + AddCount;

             { Определяем нижнее и среднее значения счетчика задержек }

             InfModel^[ NumLm ].InPrCounter_0 := InCount_0_All;
             InfModel^[ NumLm ].InCounter := InfModel^[ NumLm ].InPrCounter_0 +
                                      ( ( InfModel^[ NumLm ].InPrCounter_1 -
                                      InfModel^[ NumLm ].InPrCounter_0 ) DIV 2 )

        END;

        { Установка параметров по выходу }

     IF ( State = OutLm ) THEN
        BEGIN
             { Определяем максимально возможное приращение }

             MaxAddReal := ( Out_1_All - Out_0_All ) / 3.0;
             IF ( ( Out_1_All / 100.0 ) * Razbros < MaxAddReal ) THEN
                MaxAddReal := ( Out_1_All / 100.0 ) * Razbros;

             { Определяем знак приращения напряжения }

             Rnd := RANDOM ( 1 );
             IF ( Rnd = 1 ) THEN
                Signum := 1.0
             ELSE
                 Signum := -1.0;

             { Определяем пороговое напряжение "1" }

             Rnd := RANDOM ( 100 );
             AddReal := ( ( MaxAddReal / 100.0 ) * Rnd ) * Signum;
             InfModel^[ NumLm ].Out_1 := Out_1_All + AddReal;

             { Определяем знак приращения напряжения }

             Rnd := RANDOM ( 1 );
             IF ( Rnd = 1 ) THEN
                Signum := 1.0
             ELSE
                 Signum := -1.0;

             { Определяем пороговое напряжение "0" }

             Rnd := RANDOM ( 100 );
             AddReal := ( ( MaxAddReal / 100.0 ) * Rnd ) * Signum;
             InfModel^[ NumLm ].Out_0 := Out_0_All + AddReal;

             { Определяем максимально возможное приращение }

             MaxAddReal := ( Out_Count_All / 100.0 ) * Razbros;

             { Определяем напряжение приращения }

             Rnd := RANDOM ( 100 );
             AddReal := ( MaxAddReal / 100.0 ) * Rnd;
             InfModel^[ NumLm ].OutCount := Out_Count_All - AddReal

        END

END; { BaseLogicModel.SetParamLm }

{----------------------------------------------------------}

PROCEDURE BaseLogicModel.GetStateLm ( NumLm : BYTE; VAR State : InformLm);
            { Получить текущее состояние   }
            { выхода микросхемы            }

BEGIN
        { Анализ ошибочной ситуации }

     IF ( ( NumLm > DealLm ) OR ( NumLm = 0 ) ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.GetStateLm',
                     'нет такого номера вывода' );

        { Получить значение }

     State := InfModel^ [ NumLm ].StLm

END; { BaseLogicModel.GetStateLm }

{----------------------------------------------------------}

PROCEDURE BaseLogicModel.ConnectLm ( MyNum, NumObj : BYTE;
                                     ObjPtr : BaseModelPtr;
                                     VAR Result : BYTE );
            { Установить соединение с другим обьектом }
            { MyNum  - номер вывода данного обьекта   }
            { NumObj - номер вывода подсоединяемого   }
            {        обьекта                          }
            { ObjPtr - указатель на подсоединяемый    }
            {        обьект                           }
            { Result - результат операции :           }
            { > 0  - успешное соединение              }
            { > 1  - соединение уже было задано       }
            { > 2  - нет места для соединения         }
            { > 3  - соединение невозможно            }
VAR
   KeyFind : BOOLEAN;
          { признак поиска }

   Index : BYTE;
          { индексная переменная }

BEGIN
        { Анализ ошибочной ситуации }

     Result := 3;

     IF ( ( MyNum > DealLm ) OR ( MyNum = 0 ) ) THEN
        EXIT;

        { Поиск аналогичного соединения }

     Result := 1;

     FOR Index := 1 TO MaxConnect DO
         IF ( ( InfModel^[ MyNum ].Friend [ Index ].Num = NumObj ) AND
              ( InfModel^[ MyNum ].Friend [ Index ].Point = ObjPtr ) ) THEN
             EXIT;

        { Поиск свободного места }

     Result := 2;
     Index := 1;
     KeyFind := FALSE;

     WHILE ( ( Index <= MaxConnect ) AND ( NOT KeyFind ) ) DO
           WITH InfModel^ [ MyNum ] DO
                BEGIN
                     KeyFind := ( Friend [ Index ].Num = 0 );
                     INC ( Index )
                END;

     IF ( NOT KeyFind ) THEN
        EXIT;

        { Выполнить соединение }

     Result := 0;
     DEC ( Index );
     WITH InfModel^ [ MyNum ].Friend [ Index ] DO
          BEGIN
               Num := NumObj;
               Point := ObjPtr
          END

END; { BaseLogicModel.ConnectLm }

{----------------------------------------------------------}

PROCEDURE BaseLogicModel.CalcLogic ( LogicPtr : StateBlModelPtr );
            { Вычисление состояния выходов по  }
            { заданной логической функции      }

BEGIN
     AbstractModel ( 'BaseLogicModel.CalcLogic' )

END; { BaseLogicModel.CalcLogic }

{----------------------------------------------------------}

PROCEDURE BaseLogicModel.SetStart;
            { Устанавливает начальное состояние выходов }
            { таким образом, чтобы оно соответсвовало   }
            { состоянию - все единицы на всех входах    }

VAR
   Index : BYTE;
         { Индексная переменная }

   HelpS : STRING [ 3 ];
         { Строковый номер ошибочного вывода }

BEGIN
         { Проверяем установку логики }

     IF ( NOT SingLogic ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.GetStateLm',
                     'Внутренняя логика не установлена' );

        { Проверяем наличие установки выводов и устанавливаем "1" }
        {              по всем входам                             }

     FOR Index := 1 TO DealLm DO
         WITH InfModel^[ Index ] DO
              BEGIN
                   IF ( StLm.State = Error ) THEN
                      BEGIN
                           STR ( Index, HelpS );
                           FatalError ( 'BLModel', 'BaseLogicModel.GetStateLm',
                           'нет информации о характере вывода #'+ HelpS )
                      END;
                   IF ( StLm.State = InLm ) THEN
                      BEGIN
                           LogicState := TRUE;
                           InCounter := InPrCounter_0 +
                                        ( ( InPrCounter_1 - InPrCounter_0 ) DIV 2 );
                           IF ( InCounter > InPrCounter_1 ) THEN
                              InCounter := InPrCounter_1
                      END
              END;

        { Определяем сотояние выводов по всем "1" на входах }

     CalcLogic ( InfModel );

        { Устанавливаем соответствующие напряжения на выходах }

     FOR Index := 1 TO DealLm DO
         WITH InfModel^[ Index ] DO
              IF ( StLm.State = OutLm ) THEN
                 BEGIN
                      IF ( LogicState ) THEN
                         StLm.U := Out_1
                      ELSE
                          StLm.U := Out_0
                 END

END; { BaseLogicModel.SetStart }

{----------------------------------------------------------}

PROCEDURE BaseLogicModel.RunModel;
            { Произвести один такт моделирования  }
            { изменив при необходимости состояние }
            { выходов в соответствии с состоянием }
            {              входов                 }

VAR
   Index : BYTE;
         { Индексная переменная }

   CurrentState : InformLm;
         { Текущее состояние соединенных выводов }

BEGIN
         { Проверяем установку логики }

     IF ( NOT SingLogic ) THEN
        FatalError ( 'BLModel', 'BaseLogicModel.GetStateLm',
                     'Внутренняя логика не установлена' );

        { Устанавливаем состояние входов по логике подсоединений }
        {              по всем входам                             }

     FOR Index := 1 TO DealLm DO
         WITH InfModel^[ Index ] DO
              IF ( StLm.State = InLm ) THEN
                 BEGIN
                      { Установка предельной ситуации }

                      CurrentState.State := ZState;
                      CurrentState.U := 0.0;

                      { Установка промежуточного состояния по выводам }

                      SetKeyState ( Friend, CurrentState );

                      { Переустановка счетчика }

                      IF ( ( CurrentState.State = ZState ) OR
                         ( CurrentState.U >= InPrU_1 ) ) THEN
                         INC ( InCounter )
                      ELSE
                          IF ( CurrentState.U <= InPrU_0 ) THEN
                             DEC ( InCounter );

                      { Установка логического состояния }


                      IF ( InCounter > InPrCounter_1 ) THEN
                         BEGIN
                              InCounter := InPrCounter_1;
                              LogicState := TRUE
                         END;
                      IF ( InCounter < InPrCounter_0 ) THEN
                         BEGIN
                              InCounter := InPrCounter_0;
                              LogicState := FALSE
                         END
                 END;

        { Определяем сотояние выводов по всем входам }

     CalcLogic ( InfModel );

        { Устанавливаем соответствующие напряжения на выходах }

     FOR Index := 1 TO DealLm DO
         WITH InfModel^[ Index ] DO
              IF ( StLm.State = OutLm ) THEN
                 BEGIN
                      IF ( LogicState ) THEN
                         BEGIN
                              StLm.U := StLm.U + OutCount;
                              IF ( StLm.U > Out_1 ) THEN
                                 StLm.U := Out_1
                         END
                      ELSE
                          BEGIN
                               StLm.U := StLm.U - OutCount;
                               IF ( StLm.U < Out_0 ) THEN
                                  StLm.U := Out_0
                          END
                 END

END; { BaseLogicModel.RunModel }

{----------------------------------------------------------}

DESTRUCTOR BaseLogicModel.Done;
            { Уничтожение обьекта модели }

BEGIN
     FREEMEM ( InfModel, SIZEOF ( TypeLm ) * DealLm );
     BaseModel.Done

END; { BaseLogicModel.Done }

{----------------------------------------------------------}

END.
