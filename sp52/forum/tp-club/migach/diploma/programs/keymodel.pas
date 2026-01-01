
            {-------------------------------------------------}
            {         Модуль  KeyModel  V 1.0                 }
            {  программы моделирования цифровых электронных   }
            {                 схем                            }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания : 11/03/1992                      }
            { Дата последних изменений : 07/04/1992           }
            {-------------------------------------------------}
            {    Модуль содержит обьекты для моделирования    }
            { переключателей при построении моделей  цифровых }
            {             электронных схем                    }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}

UNIT KeyModel;

    {===================== Ключи компиляции ===================}

{$F+,O+,A+,B-,X+,V-}

{$IFDEF DEBUGKEYMODEL }
        {$D+,L+,R+,S+,I+}
{$ELSE}
        {$D-,L-,R-,S-,I-}
{$ENDIF}

    {==========================================================}

INTERFACE

USES Dos, Crt, GModel;

CONST
     MaxDealSwitch = 256;
            { Максимально возможное количество замыкаемых контактов }
            {             в модели переключателя                    }

{----------------------------------------------------------}

TYPE

    KeyLm = RECORD { полная информация о выводе переключателя }

                  InfOut : InformLm;
                              { Состояние вывода }

                  Friend : ConcatLm;
                              { Соединения с другими моделями }

            END; { record KeyLm }

{----------------------------------------------------------}

    StateKeyModel = ARRAY [ 1..MaxDealLm ] OF KeyLm;
            { Состояние выводов модели переключателя в текущий }
            {        момент времени моделирования              }

    StateKeyModelPtr = ^StateKeyModel;
            { Указатель на массив состояний выводов переключателей }

    StateSwitch = ARRAY [ 1..MaxDealSwitch ] OF BOOLEAN;
            { Массив состояния контактов переключателя }
            { FALSE - выключено                        }
            { TRUE  - включено                         }

    StateSwitchPtr = ^StateSwitch;
            { Указатель на массив состояния контактов  }

{----------------------------------------------------------}

          { Обьект модели абстрактного переключателя с N выводами }

    BaseKeyModel = OBJECT ( BaseModel )

                       InfLm : StateKeyModelPtr;
                             { указатель на массив состояний выводов }

                       DealSwitch : WORD;
                             { количество замыкаемых контактов }

                       InfSwitch : StateSwitchPtr;
                             { указатель на массив состояний контактов }

                       CONSTRUCTOR Init ( DLm : BYTE; DSwitch : WORD );
                             { инициализация обьекта для N контактного }
                             {              переключателя              }

                       PROCEDURE GetStateLm ( NumLm : BYTE; VAR State : InformLm);
                                     VIRTUAL;
                             { получить текущее состояние вывода }

                       PROCEDURE SetSwitch ( NumberSwitch : WORD ); VIRTUAL;
                             { установить состояние заданного контакта }
                             { в положение "Включено"                  }

                       PROCEDURE DoneSwitch ( NumberSwitch : WORD ); VIRTUAL;
                             { установить состояние заданного контакта  }
                             { в положение "Выключено"                  }

                       FUNCTION GetStateSwitch ( NumberSwitch : WORD )
                                               : BOOLEAN; VIRTUAL;
                              { получить текущее состояние заданного    }
                              {               контакта                  }


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

                       PROCEDURE SetStart; VIRTUAL;
                             { установка модели в исходное состояние }

                       PROCEDURE RunModel; VIRTUAL;
                              { произвести один шаг моделирования }

                       DESTRUCTOR Done; VIRTUAL;
                             { деинициализация обьекта }

                   END; { object BaseKeyModel }


    BaseKeyModelPtr = ^BaseKeyModel;
               { Указатель на обьект модели абстрактного переключателя }

{----------------------------------------------------------}

            { Обьект модели позиционного переключателя 1 X nn }
            {                     s1                          }
            {     K1  _________|__ ___ ______  K2             }
            {                  |       ______  K3             }
            {                  .  s2     ......               }
            {                  |       ______  Knn            }
            {                  |  sN                          }
            {                                                 }

    PositionKey = OBJECT ( BaseKeyModel )

                       CONSTRUCTOR Init ( DSwitch : WORD );
                             { инициализация обьекта для N контактного }
                             {              переключателя              }

                       PROCEDURE SetSwitch ( NumberSwitch : WORD ); VIRTUAL;
                             { установить состояние заданного контакта }
                             { в положение "Включено"                  }

                       PROCEDURE DoneSwitch ( NumberSwitch : WORD ); VIRTUAL;
                             { установить состояние заданного контакта  }
                             { в положение "Выключено"                  }

                       PROCEDURE SetStart; VIRTUAL;
                             { установка модели в исходное состояние }

                       PROCEDURE RunModel; VIRTUAL;
                              { произвести один шаг моделирования }

                       DESTRUCTOR Done; VIRTUAL;
                             { деинициализация обьекта }

                  END; { object PositionKey }


    PositionKeyPtr = ^PositionKey;
            { Указатель на обьект модели позиционного переключателя }

{----------------------------------------------------------}

            { Обьект модели кнопочного переключателя          }
            {                     s1                          }
            {     K1  _________/ ______  K2                   }
            {                                                 }

    SimpleKey = OBJECT ( BaseKeyModel )

                       CONSTRUCTOR Init;
                             { инициализация обьекта для 2-х контактного }
                             {              переключателя                }

                       PROCEDURE SetStart; VIRTUAL;
                             { установка модели в исходное состояние }

                       PROCEDURE RunModel; VIRTUAL;
                              { произвести один шаг моделирования }

                       DESTRUCTOR Done; VIRTUAL;
                             { деинициализация обьекта }

                END; { object SimpleKey }

    SimpleKeyPtr = ^SimpleKey;
            { Указатель на обьект модели кнопочного переключателя }

{----------------------------------------------------------}

            { Обьект модели переключателя типа сетка nn X mm  }
            {           1     N+1   2N+1           M*N+1      }
            {     K1  ___/| ___/| ___/| ___ ..... ___/| ___   }
            {           2 |     |     |               |       }
            {     K2  ___/| ___/| ___/| ___ ..... ___/| ___   }
            {           3 |     |     |               |       }
            {     K3  ___/| ___/| ___/| ___ ..... ___/| ___   }
            {             .     .     .               .       }
            {         .....................................   }
            {           N .     .     .               .       }
            {     Kn  ___/| ___/| ___/| ___ ..... ___/| ___   }
            {             |     |     |               |       }
            {             |     |     |               |       }
            {           Kn+1   Kn+2  Kn+3            Kn+m     }
            {                                                 }

    NetwareKey = OBJECT ( BaseKeyModel )

                       DealNLm : BYTE;
                             { Колическтво контактов в плоскости N }

                       DealMLm : BYTE;
                             { Количество контактов в плоскости M }

                       CONSTRUCTOR Init ( DNLm, DMLm : BYTE );
                             { инициализация обьекта для N x M контактного }
                             {              переключателя                  }

                       PROCEDURE SetStart; VIRTUAL;
                             { установка модели в исходное состояние }

                       PROCEDURE RunModel; VIRTUAL;
                              { произвести один шаг моделирования }

                       DESTRUCTOR Done; VIRTUAL;
                             { деинициализация обьекта }

                 END; { object NetwareKey }


    NetwareKeyPtr = ^NetwareKey;
            { Указатель на обьект модели переключателя типа сетка }

IMPLEMENTATION

{----------------------------------------------------------}
{============ Модель абстрактного переключателя ===========}


CONSTRUCTOR BaseKeyModel.Init ( DLm : BYTE; DSwitch : WORD );
            { инициализация обьекта для N контактного }
            {              переключателя              }
VAR
   Index, Hlp : WORD;
        { индексная переменная }

BEGIN
            { Инициализация базовой модели }

     BaseModel.Init;

            { Установка размеров }

     DealLm := DLm;
     DealSwitch := DSwitch;

        { Анализ ошибочной ситуации }

     IF ( ( DealLm > MaxDealLm ) OR ( DealLm = 0 ) ) THEN
        FatalError ( 'KeyModel', 'BaseKeyModel.Init',
                     'слишком много выводов' );

     IF ( ( DealSwitch > MaxDealSwitch ) OR ( DealSwitch = 0 ) ) THEN
        FatalError ( 'KeyModel', 'BaseKeyModel.Init',
                     'слишком много переключателей' );

            { Распределение памяти }

     GETMEM ( InfLm, ( DealLm * SIZEOF ( KeyLm ) ) );
     GETMEM ( InfSwitch, ( DealSwitch * SIZEOF ( BOOLEAN ) ) );

            { Установка всех выводов в Z состояние }

     FOR Index := 1 TO DealLm DO
         BEGIN
              WITH InfLm^ [ Index ].InfOut DO
                   BEGIN
                        State := ZState;
                        U := 0.0
                   END;
              FOR Hlp := 1 TO MaxConnect DO
                  WITH InfLm^ [ Index ].Friend [ Hlp ] DO
                       BEGIN
                            Point := NIL;
                            Num := 0
                       END
         END;

           { Установка всех контактов в положение "Выключено" }

     FOR Index := 1 TO DealSwitch DO
         InfSwitch^ [ Index ] := FALSE

END; { CONSTRUCTOR BaseKeyModel.Init }

{----------------------------------------------------------}

PROCEDURE BaseKeyModel.GetStateLm ( NumLm : BYTE; VAR State : InformLm);
            { получить текущее состояние вывода }
BEGIN
        { Анализ ошибочной ситуации }

     IF ( ( NumLm > DealLm ) OR ( NumLm = 0 ) ) THEN
        FatalError ( 'KeyModel', 'BaseKeyModel.GetStateLm',
                     'нет такого номера вывода' );

        { Получить значение }

     State := InfLm^ [ NumLm ].InfOut

END; { PROCEDURE BaseKeyModel.GetStateLm }

{----------------------------------------------------------}

PROCEDURE BaseKeyModel.SetSwitch ( NumberSwitch : WORD );
            { установить состояние заданного контакта }
            { в положение "Включено"                  }
BEGIN
        { Анализ ошибочной ситуации }

     IF ( ( NumberSwitch > DealSwitch ) OR ( NumberSwitch = 0 ) ) THEN
        FatalError ( 'KeyModel', 'BaseKeyModel.SetSwitch',
                     'нет такого номера вывода' );

        { Установка в положение "Включено" }

     InfSwitch^ [ NumberSwitch ] := TRUE

END; { PROCEDURE BaseKeyModel.SetSwitch }

{----------------------------------------------------------}

PROCEDURE BaseKeyModel.DoneSwitch ( NumberSwitch : WORD );
            { установить состояние заданного контакта  }
            { в положение "Выключено"                  }
BEGIN
        { Анализ ошибочной ситуации }

     IF ( ( NumberSwitch > DealSwitch ) OR ( NumberSwitch = 0 ) ) THEN
        FatalError ( 'KeyModel', 'BaseKeyModel.DoneSwitch',
                     'нет такого номера вывода' );

        { Установка в положение "Выключено" }

     InfSwitch^ [ NumberSwitch ] := FALSE

END; { PROCEDURE BaseKeyModel.DoneSwitch }

{----------------------------------------------------------}

FUNCTION BaseKeyModel.GetStateSwitch ( NumberSwitch : WORD ) : BOOLEAN;
            { получить текущее состояние заданного    }
            {               контакта                  }
BEGIN
        { Анализ ошибочной ситуации }

     IF ( ( NumberSwitch > DealSwitch ) OR ( NumberSwitch = 0 ) ) THEN
        FatalError ( 'KeyModel', 'BaseKeyModel.GetStateSwitch',
                     'нет такого номера вывода' );

        { Получить состояние }

     GetStateSwitch := InfSwitch^ [ NumberSwitch ]

END; { FUNCTION BaseKeyModel.GetStateSwitch }

{----------------------------------------------------------}

PROCEDURE BaseKeyModel.ConnectLm ( MyNum, NumObj : BYTE;
                                 ObjPtr : BaseModelPtr; VAR Result : BYTE );
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
         IF ( ( InfLm^[ MyNum ].Friend [ Index ].Num = NumObj ) AND
              ( InfLm^[ MyNum ].Friend [ Index ].Point = ObjPtr ) ) THEN
             EXIT;

        { Поиск свободного места }

     Result := 2;
     Index := 1;
     KeyFind := FALSE;

     WHILE ( ( Index <= MaxConnect ) AND ( NOT KeyFind ) ) DO
           WITH InfLm^ [ MyNum ] DO
                BEGIN
                     KeyFind := ( Friend [ Index ].Num = 0 );
                     INC ( Index )
                END;

     IF ( NOT KeyFind ) THEN
        EXIT;

        { Выполнить соединение }

     Result := 0;
     DEC ( Index );
     WITH InfLm^ [ MyNum ].Friend [ Index ] DO
          BEGIN
               Num := NumObj;
               Point := ObjPtr
          END

END; { BaseKeyModel.ConnectLm }

{----------------------------------------------------------}

PROCEDURE BaseKeyModel.SetStart;
            { установка модели в исходное состояние }
BEGIN
     AbstractModel ( 'BaseKeyModel.SetStart' )

END; { PROCEDURE BaseKeyModel.SetStart }

{----------------------------------------------------------}

PROCEDURE BaseKeyModel.RunModel;
            { произвести один шаг моделирования }
BEGIN
     AbstractModel ( 'BaseKeyModel.RunModel' )

END; { PROCEDURE BaseKeyModel.RunModel }

{----------------------------------------------------------}

DESTRUCTOR BaseKeyModel.Done;
            { деинициализация обьекта }
BEGIN
            { Перераспределение памяти }

     FREEMEM ( InfLm, ( DealLm * SIZEOF ( KeyLm ) ) );
     FREEMEM ( InfSwitch, ( DealSwitch * SIZEOF ( BOOLEAN ) ) );

            { Деинициализация базовой модели }

     BaseModel.Done

END; { DESTRUCTOR BaseKeyModel.Done }

{----------------------------------------------------------}
{============ Модель позиционного переключателя ===========}

CONSTRUCTOR PositionKey.Init ( DSwitch : WORD );
            { инициализация обьекта для N контактного }
            {              переключателя              }
VAR
   DLm : BYTE;

BEGIN
         { Определяем количество контактных площадок }

     DLm := DSwitch + 1;

        { Анализ ошибочной ситуации }

     IF ( ( DSwitch + 1 ) > MaxDealLm ) THEN
        FatalError ( 'KeyModel', 'PositionKey.Init',
                     'слишком много переключателей' );

     IF ( DSwitch < 2 ) THEN
        FatalError ( 'KeyModel', 'PositionKey.Init',
                     'попытка установки кнопочного выключателя' );

        { Инициализация }

     BaseKeyModel.Init ( DLm, DSwitch )

END; { CONSTRUCTOR PositionKey.Init }

{----------------------------------------------------------}

PROCEDURE PositionKey.SetSwitch ( NumberSwitch : WORD );
          { установить состояние заданного контакта }
          { в положение "Включено"                  }
VAR
   Index : WORD;
         { индексная переменная }
BEGIN
            { Установка всех выводов в Z состояние }

     FOR Index := 1 TO DealLm DO
         WITH InfLm^ [ Index ].InfOut DO
              BEGIN
                   State := ZState;
                   U := 0.0
              END;

           { Установка всех контактов в положение "Выключено" }

     FOR Index := 1 TO DealSwitch DO
         InfSwitch^ [ Index ] := FALSE;

            { Установить контакт }

     BaseKeyModel.SetSwitch ( NumberSwitch )

END; { PositionKey.SetSwitch }

{----------------------------------------------------------}

PROCEDURE PositionKey.DoneSwitch ( NumberSwitch : WORD );
          { установить состояние заданного контакта  }
          { в положение "Выключено"                  }
BEGIN
     FatalError ( 'KeyModel', 'PositionKey.DoneSwitch',
                  'применение метода запрещено' )

END; { PositionKey.DoneSwitch }

{----------------------------------------------------------}

PROCEDURE PositionKey.SetStart;
            { установка модели в исходное состояние }
VAR
   Index : WORD;
         { Индексная переменная }
BEGIN
            { Установка всех выводов в Z состояние }
            {        кроме первой пары             }

     FOR Index := 1 TO DealLm DO
         WITH InfLm^ [ Index ].InfOut DO
              BEGIN
                   State := ZState;
                   U := 0.0
              END;

     FOR Index := 1 TO 2 DO
         WITH InfLm^ [ Index ].InfOut DO
              BEGIN
                   State := OutLm;
                   U := 0.0
              END;

           { Установка всех контактов в положение "Выключено" }
           {             кроме первой пары                    }

     FOR Index := 1 TO DealSwitch DO
         InfSwitch^ [ Index ] := FALSE;

     InfSwitch^ [ 1 ] := TRUE;

END; { PROCEDURE PositionKey.SetStart }

{----------------------------------------------------------}

PROCEDURE PositionKey.RunModel;
            { произвести один шаг моделирования }
VAR
   CurrentState : InformLm;
            { Текущее состояние соединенных выводов }

   ConnectNumber : WORD;
            { Номер вывода, подключенного к первому }

   DealOn : WORD;
            { Количество подключенных выводов }

   Index : WORD;
            { Индексная переменная по ключам }
BEGIN
          { Поиск подключенного вывода }

     ConnectNumber := 0;
     DealOn := 0;
     FOR Index := 1 TO DealSwitch DO
         IF ( InfSwitch^ [ Index ] ) THEN
            BEGIN
                 ConnectNumber := Index;
                 INC ( DealOn )
            END;

         { Анализ ошибочной ситуации }

     IF ( DealOn <> 1 ) THEN
        FatalError ( 'KeyModel', 'PositionKey.RunModel',
                     'количество подключенных выводов <> 1' );

         { Установка предельной ситуации }

     CurrentState.State := ZState;
     CurrentState.U := 0.0;

         { Установка по первому контакту }

     SetKeyState ( InfLm^ [ 1 ].Friend, CurrentState );

         { Установка по подключенному контакту }

     SetKeyState ( InfLm^ [ ConnectNumber ].Friend, CurrentState );

         { Установка полученного состояния выводов }

     InfLm^ [ 1 ].InfOut := CurrentState;
     InfLm^ [ ConnectNumber ].InfOut := CurrentState

END; { PROCEDURE PositionKey.RunModel }

{----------------------------------------------------------}

DESTRUCTOR PositionKey.Done;
            { деинициализация обьекта }
BEGIN
     BaseKeyModel.Done

END; { DESTRUCTOR PositionKey.Done }

{----------------------------------------------------------}
{============ Модель кнопочного переключателя =============}

CONSTRUCTOR SimpleKey.Init;
            { инициализация обьекта для 2-х контактного }
            {              переключателя                }
VAR
   DLm : BYTE;
       { Количество контактных площадок }

   DSwitch : WORD;
       { Количество переключателей }

BEGIN
     DLm := 2;
     DSwitch := 1;
     BaseKeyModel.Init ( DLm, DSwitch )

END; { CONSTRUCTOR SimpleKey.Init }

{----------------------------------------------------------}

PROCEDURE SimpleKey.SetStart;
            { установка модели в исходное состояние }
VAR
   Index : BYTE;
         { Индексная переменная }
BEGIN
            { Установка всех выводов в Z состояние }

     FOR Index := 1 TO DealLm DO
         WITH InfLm^ [ Index ].InfOut DO
              BEGIN
                   State := ZState;
                   U := 0.0
              END;

           { Установка контактов в положение "Выключено" }

     InfSwitch^ [ 1 ] := FALSE

END; { PROCEDURE SimpleKey.SetStart }

{----------------------------------------------------------}

PROCEDURE SimpleKey.RunModel;
            { произвести один шаг моделирования }
VAR
   CurrentState : InformLm;
            { Текущее состояние соединенных выводов }
BEGIN
     IF ( NOT InfSwitch^ [ 1 ] ) THEN
        SetStart
     ELSE
         BEGIN
               { Установка предельной ситуации }

              CurrentState.State := ZState;
              CurrentState.U := 0.0;

               { Установка промежуточного состояния по выводам }

              SetKeyState ( InfLm^ [ 1 ].Friend, CurrentState );
              SetKeyState ( InfLm^ [ 2 ].Friend, CurrentState );

               { Установка полученного состояния выводов }

              InfLm^ [ 1 ].InfOut := CurrentState;
              InfLm^ [ 2 ].InfOut := CurrentState
         END

END; { PROCEDURE SimpleKey.RunModel }

{----------------------------------------------------------}

DESTRUCTOR SimpleKey.Done;
            { деинициализация обьекта }
BEGIN
     BaseKeyModel.Done

END; { DESTRUCTOR SimpleKey.Done }

{----------------------------------------------------------}
{============ Модель сеточного переключателя ==============}

CONSTRUCTOR NetwareKey.Init ( DNLm, DMLm : BYTE );
            { инициализация обьекта для N x M контактного }
            {              переключателя                  }
VAR
   DLm : BYTE;
       { Количество контактных площадок }

   DSwitch : WORD;
       { Количество переключателей }

   SumDealLm : WORD;
       { Суммарное количество площадок }
BEGIN
       { Анализ ошибочных ситуаций }

     SumDealLm := DNLm + DMLm;

     IF ( SumDealLm > MaxDealLm ) THEN
        FatalError ( 'KeyModel', 'NetwareKey.Init',
                     'Количество площадок слишком велико' );

        { Установка }

     DealNLm := DNLm;
     DealMLm := DMLm;
     DLm := DNLm + DMLm;
     DSwitch :=DNLm * DMLm;
     BaseKeyModel.Init ( DLm, DSwitch )

END; { CONSTRUCTOR NetwareKey.Init }

{----------------------------------------------------------}

PROCEDURE NetwareKey.SetStart;
            { установка модели в исходное состояние }
VAR
   Index : WORD;
         { Индексная переменная }
BEGIN
            { Установка всех выводов в Z состояние }

     FOR Index := 1 TO DealLm DO
         WITH InfLm^ [ Index ].InfOut DO
              BEGIN
                   State := ZState;
                   U := 0.0
              END;

           { Установка всех контактов в положение "Выключено" }

     FOR Index := 1 TO DealSwitch DO
         InfSwitch^ [ Index ] := FALSE

END; { PROCEDURE NetwareKey.SetStart }

{----------------------------------------------------------}

PROCEDURE NetwareKey.RunModel;
            { произвести один шаг моделирования }

         {..............................................}

FUNCTION CoordConnect ( NNum, MNum : BYTE ) : BOOLEAN;
         { Функция проверяет соединение контактов номера }
         { которых заданны в координатах плоскостей      }
         { Проверка на допустимость диапазона входных    }
         { параметров не производится                    }
BEGIN
     CoordConnect := InfSwitch^ [ ( ( MNum - 1 ) * DealNLm ) + NNum ]

END; { FUNCTION CoordConnect }

         {..............................................}

FUNCTION FindConnect ( MyNum, ToNum : BYTE ) : BOOLEAN;
         { Проверяет соединение контактов MyNum и ToNum }
VAR
   NLm, MLm : BYTE;
         { Номер вывода в заданной плоскости }

   N1, N2 : BYTE;
         { Номера выводов в плоскости N }

   M1, M2 : BYTE;
         { Номера выводов в плоскости M }

   IndexN, IndexM : BYTE;
         { Индексные переменные просмотра плоскостей }

   Result : BOOLEAN;
         { Накопитель результата просмотра }
BEGIN
         { Начальные установки }

     FindConnect := TRUE;
     Result := FALSE;
     NLm := 0;
     MLm := 0;

         { Проверка допустимости параметров }

     IF ( MyNum = ToNum ) THEN
        EXIT;

     IF ( ( MyNum = 0 ) OR ( ToNum = 0 ) OR ( MyNum > DealLm )
           OR ( ToNum > DealLm ) ) THEN
         FatalError ( 'KeyModel', 'NetwareKey.RunModel / FindConnect',
         'Недопустимые значения параметров' );

        { Определения номера контакта в заданной плоскости }

     IF ( MyNum <= DealNLm ) THEN
        NLm := MyNum
     ELSE
         MLm := MyNum - DealNLm;

     IF ( ToNum <= DealNLm ) THEN
        NLm := ToNum
     ELSE
         MLm := ToNum - DealNLm;

        { Идентификация соединения }

     IF ( MLm = 0 ) THEN { Выводы находятся в плоскости N }
        BEGIN
                { Устанавливаем номера контактов для плоскости N }

             N1 := MyNum;
             N2 := ToNum;

                { Поик косвенного соединения }

             FOR IndexM := 1 TO DealMLm DO
                 Result := ( Result OR ( CoordConnect ( N1, IndexM ) AND
                                         CoordConnect ( N2, IndexM ) ) );

             FindConnect := Result
        END
     ELSE
         IF ( NLm = 0 ) THEN  { Выводы лежат в плоскости M }
            BEGIN
                    { Устанавливаем номера контактов для плоскости M }

                 M1 := MyNum - DealNLm;
                 M2 := MyNum - DealNLm;

                    { Поиск косвенного соединения }

                 FOR IndexN := 1 TO DealNLm DO
                     Result := ( Result OR ( CoordConnect ( IndexN, M1 ) AND
                                             CoordConnect ( IndexN, M2 ) ) );

                 FindConnect := Result;
            END
         ELSE       { Выводы лежат в разных плоскостях }
             BEGIN
                  FindConnect := CoordConnect ( NLm, MLm )
             END

END; { FUNCTION FindConnect }

         {..............................................}

VAR
   IndexFind, IndexLm : BYTE;
         { Индексные переменные опроса контактов }

   CurrentState : InformLm;
            { Текущее состояние соединенных выводов }
BEGIN
     FOR IndexFind := 1 TO DealLm DO { общий цикл опроса }
         BEGIN
                  { Установка предельной ситуации }

              CurrentState.State := ZState;
              CurrentState.U := 0.0;

               { Установка промежуточного состояния по выводам }

              FOR IndexLm := 1 TO DealLm DO
                  IF ( FindConnect ( IndexFind, IndexLm ) ) THEN
                     SetKeyState ( InfLm^ [ IndexLm ].Friend, CurrentState );

               { Установка полученного состояния выводов }

              InfLm^ [ IndexFind ].InfOut := CurrentState

         END

END; { PROCEDURE NetwareKey.RunModel }

{----------------------------------------------------------}

DESTRUCTOR NetwareKey.Done;
            { деинициализация обьекта }
BEGIN
     BaseKeyModel.Done

END; { DESTRUCTOR NetwareKey.Done }

{----------------------------------------------------------}

END. { Unit KeyModel }
