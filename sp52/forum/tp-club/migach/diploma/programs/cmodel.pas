
            {-------------------------------------------------}
            {           Модуль  CModel  V 1.0                 }
            {  программы моделирования цифровых электронных   }
            {                 схем                            }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания : 17/03/1992                      }
            { Дата последних изменений : 07/04/1992           }
            {-------------------------------------------------}
            {    Модуль содержит обьекты для моделирования    }
            {   элементов общего назначения при построении    }
            {      моделей  цифровых  электронных схем        }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}

UNIT CModel;

    {===================== Ключи компиляции ===================}

{$F+,O+,A+,B-,X+,V-}

{$IFDEF DEBUGCMODEL }
        {$D+,L+,R+,S+,I+}
{$ELSE}
        {$D-,L-,R-,S-,I-}
{$ENDIF}

    {==========================================================}

INTERFACE

USES Dos, Crt, GModel;

TYPE
    PowerModel = OBJECT ( BaseModel )

                        { Модель источника опорного напряжения }

                      Power : REAL;
                        { Значение опорного напряжения }

                      CONSTRUCTOR Init ( UPw : REAL );
                               { Инициализация модели, установка }
                               { начального состояния            }

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

                      PROCEDURE SetStart; VIRTUAL;
                               { Устанавливает начальное состояние выходов }

                      PROCEDURE RunModel; VIRTUAL;
                               { Произвести один такт моделирования  }
                               { изменив при необходимости состояние }
                               { выходов в соответствии с состоянием }
                               {              входов                 }

                      DESTRUCTOR Done; VIRTUAL;
                               { Уничтожение обьекта модели }

                 END; { object PowerModel }


    PowerModelPtr = ^PowerModel;
         { Указатель на обьект модели источника опорного напряжения }

{----------------------------------------------------------}

    GroundModel = OBJECT ( BaseModel )

                        { Модель заземления }

                      CONSTRUCTOR Init;
                               { Инициализация модели, установка }
                               { начального состояния            }

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

                      PROCEDURE SetStart; VIRTUAL;
                               { Устанавливает начальное состояние выходов }

                      PROCEDURE RunModel; VIRTUAL;
                               { Произвести один такт моделирования  }
                               { изменив при необходимости состояние }
                               { выходов в соответствии с состоянием }
                               {              входов                 }

                      DESTRUCTOR Done; VIRTUAL;
                               { Уничтожение обьекта модели }

                  END; { object GroundModel }


    GroundModelPtr = ^GroundModel;
        { Указатель на обьект модели заземления }

{----------------------------------------------------------}

    StateWaitLine = ARRAY [ 1..255 ] OF REAL;
        { Тип массива состояния линии задержки }

    StateWaitLinePtr = ^StateWaitLine;
        { Указатель на массив состояния линии задержки }

{----------------------------------------------------------}

    WaitLineModel = OBJECT ( BaseModel )

           { Модель однонаправленной линии задержки  }
           {                                         }
           {        ---------------                  }
           { K1    | in       out  |       K2        }
           { ------|  ------->     |---------        }
           {       |               |                 }
           {        ---------------                  }

                      WaitTime : BYTE;
                               { Количество тактов задержки }

                      InfLine : StateWaitLinePtr;
                               { Указатель на массив внутреннего }
                               { состояния линии задержки        }

                      InfOut : InformLm;
                               { Информация по выходу }

                      Friend : ARRAY [ 1..2 ] OF ConcatLm;
                               { Информация о подсоединениях }

                      CONSTRUCTOR Init ( Wtm : BYTE );
                               { Инициализация модели, установка }
                               { начального состояния            }

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

                      PROCEDURE SetStart; VIRTUAL;
                               { Устанавливает начальное состояние выходов }

                      PROCEDURE RunModel; VIRTUAL;
                               { Произвести один такт моделирования  }
                               { изменив при необходимости состояние }
                               { выходов в соответствии с состоянием }
                               {              входов                 }

                      DESTRUCTOR Done; VIRTUAL;
                               { Уничтожение обьекта модели }

                    END; { object WaitLineModel }


    WaitLineModelPtr = ^WaitLineModel;
         { Указатель на обькт модели линии задержки }

{----------------------------------------------------------}

IMPLEMENTATION

{========== Модель источника опорного напряжения ==========}

CONSTRUCTOR PowerModel.Init ( UPw : REAL );
            { Инициализация модели, установка }
            { начального состояния            }
BEGIN
     Power := UPw

END; { CONSTRUCTOR PowerModel.Init }

{----------------------------------------------------------}

PROCEDURE PowerModel.GetStateLm ( NumLm : BYTE; VAR State : InformLm);
            { Получить текущее состояние   }
            { выхода микросхемы            }
BEGIN
     IF ( ( NumLm = 0 ) OR ( NumLm > MaxDealLm ) ) THEN
        FatalError ( 'CModel', 'PowerModel.GetStateLm',
                     'Недопустимое значение номера вывода' );

     State.State :=  OutLm;
     State.U := Power

END; { PROCEDURE PowerModel.GetStateLm }

{----------------------------------------------------------}

PROCEDURE PowerModel.ConnectLm ( MyNum, NumObj : BYTE;
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
BEGIN
     { Обьект модели источника опорного напряжения     }
     { имеет MaxDealLm выводов и практически возможно  }
     { подключенпие к любому из них                    }

     IF ( ( MyNum = 0 ) OR ( MyNum > MaxDealLm ) OR ( NumObj = 0 )
        OR ( NumObj > MaxDealLm ) OR ( ObjPtr = NIL ) ) THEN
        FatalError ( 'CModel', 'PowerModel.ConnectLm',
                     'Недопустимое значение входных параметров' );

     Result := 0

END; { PROCEDURE PowerModel.ConnectLm }

{----------------------------------------------------------}

PROCEDURE PowerModel.SetStart;
            { Устанавливает начальное состояние выходов }
BEGIN
     { Установка не требуется, так как значение напряжения на }
     { выходе не зависит от момента времени моделирования     }

END; { PROCEDURE PowerModel.SetStart }

{----------------------------------------------------------}

PROCEDURE PowerModel.RunModel;
            { Произвести один такт моделирования  }
            { изменив при необходимости состояние }
            { выходов в соответствии с состоянием }
            {              входов                 }
BEGIN
     { Обработка модели во времени не требуется }

END; { PROCEDURE PowerModel.RunModel }

{----------------------------------------------------------}

DESTRUCTOR PowerModel.Done;
            { Уничтожение обьекта модели }
BEGIN

END; { DESTRUCTOR PowerModel.Done }

{----------------------------------------------------------}
{=================== Модель заземления ====================}

CONSTRUCTOR GroundModel.Init;
            { Инициализация модели, установка }
            { начального состояния            }
BEGIN

END; { CONSTRUCTOR GroundModel.Init }

{----------------------------------------------------------}

PROCEDURE GroundModel.GetStateLm ( NumLm : BYTE; VAR State : InformLm);
            { Получить текущее состояние   }
            { выхода микросхемы            }
BEGIN
     IF ( ( NumLm = 0 ) OR ( NumLm > MaxDealLm ) ) THEN
        FatalError ( 'CModel', 'GroundModel.GetStateLm',
                     'Недопустимое значение номера вывода' );

     State.State :=  OutLm;
     State.U := 0.0

END; { PROCEDURE GroundModel.GetStateLm }

{----------------------------------------------------------}

PROCEDURE GroundModel.ConnectLm ( MyNum, NumObj : BYTE;
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
BEGIN
     { Обьект модели заземления                        }
     { имеет MaxDealLm выводов и практически возможно  }
     { подключенпие к любому из них                    }

     IF ( ( MyNum = 0 ) OR ( MyNum > MaxDealLm ) OR ( NumObj = 0 )
        OR ( NumObj > MaxDealLm ) OR ( ObjPtr = NIL ) ) THEN
        FatalError ( 'CModel', 'GroundModel.ConnectLm',
                     'Недопустимое значение входных параметров' );

     Result := 0

END; { PROCEDURE GroundModel.ConnectLm }

{----------------------------------------------------------}

PROCEDURE GroundModel.SetStart;
            { Устанавливает начальное состояние выходов }
BEGIN
     { Установка не требуется, так как значение напряжения на }
     { выходе не зависит от момента времени моделирования     }

END; { PROCEDURE GroundModel.SetStart }

{----------------------------------------------------------}

PROCEDURE GroundModel.RunModel;
            { Произвести один такт моделирования  }
            { изменив при необходимости состояние }
            { выходов в соответствии с состоянием }
            {              входов                 }
BEGIN
     { Обработка модели во времени не требуется }

END; { PROCEDURE GroundModel.RunModel }

{----------------------------------------------------------}

DESTRUCTOR GroundModel.Done;
            { Уничтожение обьекта модели }
BEGIN

END; { DESTRUCTOR GroundModel.Done }

{----------------------------------------------------------}
{================= Модель линии задержки ==================}

CONSTRUCTOR WaitLineModel.Init ( Wtm : BYTE );
            { Инициализация модели, установка }
            { начального состояния            }
VAR
   Index, Hlp : BYTE;
          { Индексные переменные }
BEGIN
     DealLm := 2;
     WaitTime := Wtm;
     GETMEM ( InfLine, WaitTime );
     FOR Index := 1 TO WaitTime DO
         InfLine^ [ Index ] := 0.0;

     InfOut.State := OutLm;
     InfOut.U := 0.0;

     FOR Index := 1 TO 2 DO
         FOR Hlp := 1 TO MaxConnect DO
             BEGIN
                  Friend [ Index ] [ Hlp ].Point := NIL;
                  Friend [ Index ] [ Hlp ].Num := 0
             END

END; { CONSTRUCTOR WaitLineModel.Init }

{----------------------------------------------------------}

PROCEDURE WaitLineModel.GetStateLm ( NumLm : BYTE; VAR State : InformLm);
            { Получить текущее состояние   }
            { выхода микросхемы            }
BEGIN
     IF ( NumLm = 2 ) THEN
        State := InfOut
     ELSE
         IF ( NumLm = 1 ) THEN
            State.State := InLm
         ELSE
             FatalError ( 'CModel', 'WaitLineModel.GetStateLm',
                          'Недопустимое значение номера вывода' )

END; { PROCEDURE WaitLineModel.GetStateLm }

{----------------------------------------------------------}

PROCEDURE WaitLineModel.ConnectLm ( MyNum, NumObj : BYTE;
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
         IF ( ( Friend [ MyNum ] [ Index ].Num = NumObj ) AND
              ( Friend [ MyNum ] [ Index ].Point = ObjPtr ) ) THEN
             EXIT;

        { Поиск свободного места }

     Result := 2;
     Index := 1;
     KeyFind := FALSE;

     WHILE ( ( Index <= MaxConnect ) AND ( NOT KeyFind ) ) DO
           BEGIN
                KeyFind := ( Friend [ MyNum ] [ Index ].Num = 0 );
                INC ( Index )
           END;

     IF ( NOT KeyFind ) THEN
        EXIT;

        { Выполнить соединение }

     Result := 0;
     DEC ( Index );
     WITH Friend [ MyNum ] [ Index ] DO
          BEGIN
               Num := NumObj;
               Point := ObjPtr
          END

END; { PROCEDURE WaitLineModel.ConnectLm }

{----------------------------------------------------------}

PROCEDURE WaitLineModel.SetStart;
            { Устанавливает начальное состояние выходов }
VAR
   Index, Hlp : BYTE;
          { Индексные переменные }
BEGIN
     FOR Index := 1 TO WaitTime DO
         InfLine^ [ Index ] := 0.0;

     InfOut.State := OutLm;
     InfOut.U := 0.0;

     FOR Index := 1 TO 2 DO
         FOR Hlp := 1 TO MaxConnect DO
             BEGIN
                  Friend [ Index ] [ Hlp ].Point := NIL;
                  Friend [ Index ] [ Hlp ].Num := 0
             END

END; { PROCEDURE WaitLineModel.SetStart }

{----------------------------------------------------------}

PROCEDURE WaitLineModel.RunModel;
            { Произвести один такт моделирования  }
            { изменив при необходимости состояние }
            { выходов в соответствии с состоянием }
            {              входов                 }
VAR
   GetState : InformLm;

BEGIN
         { Определяем текущее выходное напряжение }

     InfOut.U := InfLine ^ [ WaitTime ];

         { Сдвигаем линию задержки }

     MOVE ( InfLine^ [ 1 ], InfLine^ [ 2 ],
            ( ( WaitTime - 1 ) * SIZEOF ( REAL ) ) );

         { Устанавка предельной ситуации }

     GetState.U := 0.0;
     GetState.State := ZState;

         { Установка по подключенным выводам }

     SetKeyState ( Friend [ 1 ], GetState );

         { Определяем вход линии задержки }

     InfLine ^ [ 1 ] := GetState.U

END; { PROCEDURE WaitLineModel.RunModel }

{----------------------------------------------------------}

DESTRUCTOR WaitLineModel.Done;
            { Уничтожение обьекта модели }
BEGIN
     FREEMEM ( InfLine, WaitTime );

END; { DESTRUCTOR WaitLineModel.Done }

{----------------------------------------------------------}

END.
