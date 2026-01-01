
            {-------------------------------------------------}
            {         Модуль  GModel  V 1.0                   }
            {  программы моделирования цифровых электронных   }
            {                 схем                            }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания : 10/03/1992                      }
            { Дата последних изменений : 19/03/1992           }
            {-------------------------------------------------}
            { Модуль содержит универсальные обьекты для       }
            { соединения элементов при построении моделей     }
            {       цифровых электронных схем                 }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}


UNIT GModel;

    {===================== Ключи компиляции ===================}

{$F+,O+,A+,B-,X+,V-}

{$IFDEF DEBUGMODEL }
        {$D+,L+,R+,S+,I+}
{$ELSE}
        {$D-,L-,R-,S-,I-}
{$ENDIF}

    {==========================================================}

INTERFACE

USES Dos, Crt;

CONST
     MaxDealLm = 128;
            { Максимальное количество выводов микросхем }

     MaxConnect = 5;
            { Максимальное количество соединений в одном узле }

TYPE
    StateLm = ( Error, ZState, InLm, OutLm, GroundLm, PowerLm );
            { Тип определяющий текущее состояние вывода микросхемы }
            { Error     - состояние не определено                  }
            { ZState    - Z состояние выхода                       }
            { InLm      - Вход микросхемы                          }
            { OutLm     - Выход микросхемы                         }
            { GroundLm  - Земля                                    }
            { PowerLm   - Питание                                  }
            { Первые три состояния могут изменятся в процессе      }
            { моделирования в зависимости от внутренней логики     }
            { работы цифровой схемы                                }

{----------------------------------------------------------}

    InformLm = RECORD   { Информация о выводе микросхемы  :        }

                     State : StateLm;
                        { Текущее состояние вывода                 }

                     U     : REAL
                        { Напряжение на выводе, если он находится  }
                        { в состоянии OutLm                        }

               END; { record InformLm }

{----------------------------------------------------------}

    BaseModelPtr = ^BaseModel;
                   { Указатель на обьект базовой модели }

{----------------------------------------------------------}

   ConcatLm = ARRAY [ 1..MaxConnect ] OF RECORD
                              { Соединения с другими моделями }

                           Point : BaseModelPtr;
                              { указатель на соединяемую ЛЭС }

                           Num : BYTE
                              { номер подсоединяемого вывода }

               END; { record ConnectLm [ i ] }

{----------------------------------------------------------}

    FullStateLm = RECORD { Полная информация о выводе микросхемы }

                         Info  : InformLm;
                                { Состояние вывода }

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

                          Out_1 : REAL;
                                 { Напряжение выхода "1" }

                          Out_0 : REAL;
                                 { Напряжение выхода "0" }

                          OutCount : REAL;
                                 { Приращение напряжения переключения выхода }

                          Friend : ConcatLm;
                                        { Соединения с другими моделями }

                  END; { record FullStateLm }

{----------------------------------------------------------}

    StateModel = ARRAY [ 1..MaxDealLm ] OF FullStateLm;
               { Массив состояния модели }

    StateModelPtr = ^StateModel;
               { Указатель на массив состояния модели }

{----------------------------------------------------------}

    BaseModel = OBJECT { Обьект базовой модели }

                      DealLm : BYTE;
                               { Количество выводов модели }

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
                               { таким образом, чтобы оно соответсвовало   }
                               { состоянию - все единицы на всех входах    }

                      PROCEDURE RunModel; VIRTUAL;
                               { Произвести один такт моделирования  }
                               { изменив при необходимости состояние }
                               { выходов в соответствии с состоянием }
                               {              входов                 }

                      DESTRUCTOR Done; VIRTUAL;
                               { Уничтожение обьекта модели }

                END; { object BaseModel }

{----------------------------------------------------------}
{                Внешние процедуры и функции               }

PROCEDURE AbstractModel ( Line : STRING );
         { Процедура абстрактной модели }

PROCEDURE FatalError ( Un, Proc, Line : STRING );
          { Сообщение о критическом сбое в программе         }
          { Un   - Имя модуля                                }
          { Proc - Название процедуры ( функции или метода ) }
          { Line - Характер ошибки                           }

PROCEDURE ConnectModels ( Num1 : BYTE; Obj1Ptr : BaseModelPtr;
                         Num2 : BYTE; Obj2Ptr : BaseModelPtr;
                         VAR Result : BYTE );
         { Выполняет соединение двух выводов моделей }
         { соединение двух выводов одной и той же    }
         { модели допускается                        }
         { Num1    - номер вывода первого обьекта    }
         {         модели                            }
         { Obj1Ptr - указатель на первый обьект      }
         {         модели                            }
         { Num2    - номер вывода второго обьекта    }
         {         модели                            }
         { Obj2Ptr - указатель на второй обьект      }
         {         модели                            }
         { Result - результат операции :             }
         { > 0  - успешное соединение                }
         { > 1  - соединение уже было задано         }
         { > 2  - нет места для соединения           }
         { > 3  - соединение невозможно              }

PROCEDURE SetKeyState ( Friend : ConcatLm; VAR CurrentState : InformLm );
          { Установка состояния по моделям подключенным к     }
          { данному выводу                                    }
          { InfKey   - Информация о подключениях исследуемого }
          {          вывода                                   }
          { KeyState - Определяемое состояние                 }

{----------------------------------------------------------}

IMPLEMENTATION

PROCEDURE AbstractModel ( Line : STRING );
         { Процедура абстрактной модели }
VAR
   Rg : REGISTERS;

BEGIN
        { Переключаем дисплей в режим 80 X 25 text mode }

     Rg.AH := 0;
     Rg.Al := 3;
     INTR ( $10, Rg );

        { Выдача сообщения и прекращение работы }

     WINDOW ( 1, 1, 80, 25 );
     TEXTCOLOR ( LIGHTGRAY );
     TEXTBACKGROUND ( BLACK );
     CLRSCR;
     WRITELN;
     WRITELN ( 'Вызван медод принадлежащий обьекту абстрактной модели' );
     WRITELN ( '---> ', Line );
     WRITELN ( 'Выполнение программы прекращается, обращайтесь' );
     WRITELN ( 'к разработчику ПО ', #07 );
     WRITELN;
     HALT ( 99 )

END; { Procedure AbstractModel }

{----------------------------------------------------------}

PROCEDURE FatalError ( Un, Proc, Line : STRING );
          { Сообщение о критическом сбое в программе         }
          { Un   - Имя модуля                                }
          { Proc - Название процедуры ( функции или метода ) }
          { Line - Характер ошибки                           }
VAR
   Rg : REGISTERS;

BEGIN
        { Переключаем дисплей в режим 80 X 25 text mode }

     Rg.AH := 0;
     Rg.Al := 3;
     INTR ( $10, Rg );

        { Выдаем сообщение }

     WINDOW ( 1, 1, 80, 25 );
     TEXTCOLOR ( LIGHTGRAY );
     TEXTBACKGROUND ( BLACK );
     CLRSCR;
     WRITELN;
     WRITELN ( 'Обнаружена ошибка в программе' );
     WRITELN ( 'Модуль - ', Un );
     WRITELN ( 'Процедура - ', Proc );
     WRITELN ( 'Ошибка - ', Line );
     WRITELN ( 'Обращайтесь к разработчику,' );
     WRITELN ( 'выполнение программы прекращается...' );
     WRITELN;
     DELAY ( 2000 );
     HALT ( 99 )

END; { procedure FatalError }

{----------------------------------------------------------}

PROCEDURE ConnectModels ( Num1 : BYTE; Obj1Ptr : BaseModelPtr;
                         Num2 : BYTE; Obj2Ptr : BaseModelPtr;
                         VAR Result : BYTE );
         { Выполняет соединение двух выводов моделей }
         { соединение двух выводов одной и той же    }
         { модели допускается                        }
         { Num1    - номер вывода первого обьекта    }
         {         модели                            }
         { Obj1Ptr - указатель на первый обьект      }
         {         модели                            }
         { Num2    - номер вывода второго обьекта    }
         {         модели                            }
         { Obj2Ptr - указатель на второй обьект      }
         {         модели                            }
         { Result - результат операции :             }
         { > 0  - успешное соединение                }
         { > 1  - соединение уже было задано         }
         { > 2  - нет места для соединения           }
         { > 3  - соединение невозможно              }
BEGIN
     Obj1Ptr^.ConnectLm ( Num1, Num2, Obj2Ptr, Result );
     IF ( Result <> 0 ) THEN
        EXIT;
     Obj2Ptr^.ConnectLm ( Num2, Num1, Obj1Ptr, Result )

END; { FUNCTION ConnectModels }

{----------------------------------------------------------}

PROCEDURE SetKeyState ( Friend : ConcatLm; VAR CurrentState : InformLm );
          { Установка состояния по моделям подключенным к     }
          { данному выводу                                    }
          { InfKey   - Информация о подключениях исследуемого }
          {          вывода                                   }
          { KeyState - Определяемое состояние                 }

VAR
   Hlp : BYTE;
       { Индексная переменная }

   ExtentState : InformLm;
            { Состояние внешнего обьекта модели }
BEGIN
     FOR Hlp := 1 TO MaxConnect DO
              IF ( Friend [ Hlp ].Num <> 0 ) THEN
                 BEGIN
                      Friend [ Hlp ].Point^.GetStateLm ( Friend [ Hlp ].Num,
                                                         ExtentState );
                      IF ( ( ExtentState.State IN [ OutLm, PowerLm ] ) AND
                         ( CurrentState.State = ZState ) ) THEN
                         BEGIN
                              CurrentState.State := OutLm;
                              CurrentState.U := ExtentState.U
                         END;
                      IF ( ExtentState.State = GroundLm ) THEN
                         BEGIN
                              CurrentState.State := OutLm;
                              CurrentState.U := 0.0
                         END;
                       IF ( ( ExtentState.State IN [ PowerLm, OutLm ] ) AND
                            ( CurrentState.State = OutLm ) AND
                            ( ABS ( ExtentState.U ) <
                              ABS ( CurrentState.U ) ) ) THEN
                          CurrentState.U := ExtentState.U
                 END;

END; { PROCEDURE SetKeyState }

{----------------------------------------------------------}
{==========================================================}

CONSTRUCTOR BaseModel.Init;
            { Инициализация модели, установка }
            { начального состояния            }

BEGIN
     DealLm := 0

END; { CONSTRUCTOR BaseModel.Init }

{----------------------------------------------------------}

PROCEDURE BaseModel.GetStateLm ( NumLm : BYTE; VAR State : InformLm);
            { Получить текущее состояние   }
            { выхода микросхемы            }

BEGIN
     AbstractModel ( 'BaseModel.GetStateLm' )

END; { PROCEDURE BaseModel.GetStateLm }

{----------------------------------------------------------}

PROCEDURE BaseModel.ConnectLm ( MyNum, NumObj : BYTE; ObjPtr : BaseModelPtr;
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
     AbstractModel ( 'BaseModel.ConnectLm' )

END; { BaseModel.ConnectLm }

{----------------------------------------------------------}

PROCEDURE BaseModel.SetStart;
            { Устанавливает начальное состояние выходов }
            { таким образом, чтобы оно соответсвовало   }
            { состоянию - все единицы на всех входах    }

BEGIN
     AbstractModel ( 'BaseModel.SetStart' )

END; { PROCEDURE BaseModel.SetStart }

{----------------------------------------------------------}

PROCEDURE BaseModel.RunModel;
          { Произвести один такт моделирования  }
          { изменив при необходимости состояние }
          { выходов в соответствии с состоянием }
          {              входов                 }

BEGIN
     AbstractModel ( 'BaseModel.RunModel' )

END; { PROCEDURE BaseModel.RunModel }

{----------------------------------------------------------}

DESTRUCTOR BaseModel.Done;
          { Уничтожение обьекта модели }

BEGIN

END; { BaseModel.Done }

{----------------------------------------------------------}

END.
