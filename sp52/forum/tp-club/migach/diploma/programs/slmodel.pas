
            {-------------------------------------------------}
            {           Модуль  SLModel  V 1.0                }
            {  программы моделирования цифровых электронных   }
            {                 схем                            }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания :06/04/1992                       }
            { Дата последних изменений : 07/04/1992           }
            {-------------------------------------------------}
            {    Модуль содержит обьекты для моделирования    }
            { простейших элементов комбинационных цифровых    }
            {           цифровых  электронных схем            }
            {   НЕ, 2И-НЕ, 2ИЛИ-НЕ, 2И, 2ИЛИ, 2ИСКЛ-ИЛИ-НЕ,   }
            {   2-ИСКЛ-ИЛИ, 3И-НЕ, 3ИЛИ-НЕ, 8И-НЕ, 8ИЛИ-НЕ.   }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}

UNIT SLModel;

    {===================== Ключи компиляции ===================}

{$F+,O+,A+,B-,X+,V-}

{$IFDEF DEBUGSLMODEL }
        {$D+,L+,R+,S+,I+}
{$ELSE}
        {$D-,L-,R-,S-,I-}
{$ENDIF}

    {==========================================================}

INTERFACE

USES Dos, Crt, GModel, BLModel;

TYPE
    Logic_NOT = OBJECT ( BaseLogicModel )

         {                                                       }
         {               ┌────┐  НЕ                              }
         {           k1  │    │     k2                           }
         {            ───┤    №────                              }
         {               │    │                                  }
         {               └────┘                                  }

                CONSTRUCTOR Init ( OU_1, OU_0, OU_C : REAL;
                                   IU_1, IU_0 : REAL;
                                   IC_1, IC_0 : WORD;
                                   RB : REAL );
                               { Инициализация модели, установка }
                               { начального состояния            }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                END; { object Logic_NOT }

    Logic_NOTPtr = ^Logic_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}


    Logic_2AND_NOT = OBJECT ( BaseLogicModel )

         {                                                       }
         {           k1  ┌────┐  2И-НЕ                           }
         {            ───┤  & │                                  }
         {           k2  │    №────  k3                          }
         {            ───┤    │                                  }
         {               └────┘                                  }

                CONSTRUCTOR Init ( OU_1, OU_0, OU_C : REAL;
                                   IU_1, IU_0 : REAL;
                                   IC_1, IC_0 : WORD;
                                   RB : REAL );
                               { Инициализация модели, установка }
                               { начального состояния            }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                     END; { object Logic_2AND_NOT }

    Logic_2AND_NOTPtr = ^Logic_2AND_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_2OR_NOT = OBJECT ( Logic_2AND_NOT )

         {                                                       }
         {           k1  ┌────┐  2ИЛИ-НЕ                         }
         {             ──┤  1 │                                  }
         {           k2  │    №────  k3                          }
         {             ──┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                    END; { object Logic_2OR_NOT }

    Logic_2OR_NOTPtr = ^Logic_2OR_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_2AND = OBJECT ( Logic_2AND_NOT )

         {                                                       }
         {           k1  ┌────┐   2И                             }
         {             ──┤  & │                                  }
         {           k2  │    ├────  k3                          }
         {             ──┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                 END; { object Logic_2AND }

    Logic_2ANDPtr = ^Logic_2AND;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_2OR = OBJECT ( Logic_2AND_NOT )

         {                                                       }
         {           k1  ┌────┐   2ИЛИ                           }
         {             ──┤  1 │                                  }
         {           k2  │    ├────  k3                          }
         {             ──┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                END; { object Logic_2OR }

    Logic_2ORPtr = ^Logic_2OR;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_2XOR_NOT = OBJECT ( Logic_2AND_NOT )

         {                                                       }
         {           k1  ┌────┐  2ИСКЛ-ИЛИ-НЕ                    }
         {             ──┤ =1 │                                  }
         {           k2  │    №────  k3                          }
         {             ──┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                    END; { object Logic_2XOR_NOT }

    Logic_2XOR_NOTPtr = ^Logic_2XOR_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_2XOR = OBJECT ( Logic_2AND_NOT )

         {                                                       }
         {           k1  ┌────┐   2ИСКЛ-ИЛИ                      }
         {             ──┤ =1 │                                  }
         {           k2  │    ├────  k3                          }
         {             ──┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                 END; { object Logic_2XOR }

    Logic_2XORPtr = ^Logic_2XOR;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_3AND_NOT = OBJECT ( BaseLogicModel )

         {                                                       }
         {          k1   ┌────┐  3И-НЕ                           }
         {            ───┤  & │                                  }
         {          k2   │    │                                  }
         {            ───┤    №──── k4                           }
         {          k3   │    │                                  }
         {            ───┤    │                                  }
         {               └────┘                                  }

                CONSTRUCTOR Init ( OU_1, OU_0, OU_C : REAL;
                                   IU_1, IU_0 : REAL;
                                   IC_1, IC_0 : WORD;
                                   RB : REAL );
                               { Инициализация модели, установка }
                               { начального состояния            }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                     END; { Logic_3AND_NOT }

    Logic_3AND_NOTPtr = ^Logic_3AND_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_3OR_NOT = OBJECT ( Logic_3AND_NOT )

         {                                                       }
         {          k1   ┌────┐  3ИЛИ-НЕ                         }
         {            ───┤  1 │                                  }
         {          k2   │    │                                  }
         {            ───┤    №──── k4                           }
         {          k3   │    │                                  }
         {            ───┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                    END; { object Logic_3OR_NOT }

    Logic_3OR_NOTPtr = ^Logic_3OR_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}

    Logic_8AND_NOT = OBJECT ( BaseLogicModel )

         {                                                       }
         {          k1   ┌────┐  8И-НЕ                           }
         {            ───┤  & │                                  }
         {          k2   │    │                                  }
         {            ───┤    │                                  }
         {          k3   │    │                                  }
         {            ───┤    │                                  }
         {          k4   │    │                                  }
         {            ───┤    │                                  }
         {          k5   │    №───── k9                          }
         {            ───┤    │                                  }
         {          k6   │    │                                  }
         {            ───┤    │                                  }
         {          k7   │    │                                  }
         {            ───┤    │                                  }
         {          k8   │    │                                  }
         {            ───┤    │                                  }
         {               └────┘                                  }

                CONSTRUCTOR Init ( OU_1, OU_0, OU_C : REAL;
                                   IU_1, IU_0 : REAL;
                                   IC_1, IC_0 : WORD;
                                   RB : REAL );
                               { Инициализация модели, установка }
                               { начального состояния            }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                     END; { object Logic_8AND_NOT }

    Logic_8AND_NOTPtr = ^Logic_8AND_NOT;
         { Указатель на обьектный тип модели }

{----------------------------------------------------------}


    Logic_8OR_NOT = OBJECT ( Logic_8AND_NOT )

         {                                                       }
         {           k1  ┌────┐  8ИЛИ-НЕ                         }
         {            ───┤  1 │                                  }
         {           k2  │    │                                  }
         {            ───┤    │                                  }
         {           k2  │    │                                  }
         {            ───┤    │                                  }
         {           k4  │    │                                  }
         {            ───┤    │                                  }
         {           k5  │    №───── k9                          }
         {            ───┤    │                                  }
         {           k6  │    │                                  }
         {            ───┤    │                                  }
         {           k7  │    │                                  }
         {            ───┤    │                                  }
         {           k8  │    │                                  }
         {            ───┤    │                                  }
         {               └────┘                                  }

                PROCEDURE CalcLogic ( LogicPtr : StateBlModelPtr );
                                VIRTUAL;
                               { Вычисление состояния выходов по  }
                               { заданной логической функции      }

                    END; { object Logic_8OR_NOT }

    Logic_8OR_NOTPtr = ^Logic_8OR_NOT;
         { Указатель на обьектный тип модели }

IMPLEMENTATION

{----------------------------------------------------------}
{==================== НЕ ==================================}

CONSTRUCTOR Logic_NOT.Init ( OU_1, OU_0, OU_C : REAL;
                         IU_1, IU_0 : REAL;
                         IC_1, IC_0 : WORD;
                         RB : REAL );
            { Инициализация модели, установка }
            { начального состояния            }

BEGIN
     BaseLogicModel.Init ( 2, OU_1, OU_0, OU_C, IU_1, IU_0,
                              IC_1, IC_0, RB );
     SetParamLm ( 1, InLm );
     SetParamLm ( 2, OutLm );
     SingLogic := TRUE

END; { constrructor Logic_NOT.Init }

{----------------------------------------------------------}

PROCEDURE Logic_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 2 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState )

END; { procedure Logic_NOT.CalcLogic }

{----------------------------------------------------------}
{==================== 2И-НЕ ===============================}

CONSTRUCTOR Logic_2AND_NOT.Init ( OU_1, OU_0, OU_C : REAL;
                         IU_1, IU_0 : REAL;
                         IC_1, IC_0 : WORD;
                         RB : REAL );
            { Инициализация модели, установка }
            { начального состояния            }

BEGIN
     BaseLogicModel.Init ( 3, OU_1, OU_0, OU_C, IU_1, IU_0,
                              IC_1, IC_0, RB );
     SetParamLm ( 1, InLm );
     SetParamLm ( 2, InLm );
     SetParamLm ( 3, OutLm );
     SingLogic := TRUE

END; { constructor Logic_2AND_NOT.Init }

{----------------------------------------------------------}

PROCEDURE Logic_2AND_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 3 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState AND
                                        LogicPtr^[ 2 ].LogicState )

END; { procedure Logic_2AND_NOT.CalcLogic }

{----------------------------------------------------------}
{==================== 2ИЛИ-НЕ =============================}

PROCEDURE Logic_2OR_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 3 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState OR
                                        LogicPtr^[ 2 ].LogicState )

END; { procedure Logic_2OR_NOT.CalcLogic }

{----------------------------------------------------------}
{==================== 2И ==================================}

PROCEDURE Logic_2AND.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 3 ].LogicState := ( LogicPtr^[ 1 ].LogicState AND
                                        LogicPtr^[ 2 ].LogicState )

END; { procedure Logic_2AND.CalcLogic }

{----------------------------------------------------------}
{===================== 2ИЛИ ===============================}

PROCEDURE Logic_2OR.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 3 ].LogicState := ( LogicPtr^[ 1 ].LogicState OR
                                        LogicPtr^[ 2 ].LogicState )

END; { procedure Logic_2OR.CalcLogic }

{----------------------------------------------------------}
{===================== 2ИСКЛ-ИЛИ-НЕ =======================}

PROCEDURE Logic_2XOR_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 3 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState XOR
                                        LogicPtr^[ 2 ].LogicState )

END; { procedure Logic_2XOR_NOT.CalcLogic }

{----------------------------------------------------------}
{===================== 2ИСКЛ-ИЛИ ==========================}

PROCEDURE Logic_2XOR.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 3 ].LogicState := ( LogicPtr^[ 1 ].LogicState XOR
                                        LogicPtr^[ 2 ].LogicState )

END; { procedure Logic_2XOR.CalcLogic }

{----------------------------------------------------------}
{===================== 3И-НЕ ==============================}

CONSTRUCTOR Logic_3AND_NOT.Init ( OU_1, OU_0, OU_C : REAL;
                         IU_1, IU_0 : REAL;
                         IC_1, IC_0 : WORD;
                         RB : REAL );
            { Инициализация модели, установка }
            { начального состояния            }

BEGIN
     BaseLogicModel.Init ( 4, OU_1, OU_0, OU_C, IU_1, IU_0,
                              IC_1, IC_0, RB );
     SetParamLm ( 1, InLm );
     SetParamLm ( 2, InLm );
     SetParamLm ( 3, InLm );
     SetParamLm ( 4, OutLm );
     SingLogic := TRUE

END; { constrructor Logic_3AND_NOT.Init }

{----------------------------------------------------------}

PROCEDURE Logic_3AND_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 4 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState AND
                                        LogicPtr^[ 2 ].LogicState AND
                                        LogicPtr^[ 3 ].LogicState )

END; { procedure Logic_3AND_NOT.CalcLogic }

{----------------------------------------------------------}
{====================== 3ИЛИ-НЕ ===========================}

PROCEDURE Logic_3OR_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 4 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState OR
                                        LogicPtr^[ 2 ].LogicState OR
                                        LogicPtr^[ 3 ].LogicState )

END; { procedure Logic_3OR_NOT.CalcLogic }

{----------------------------------------------------------}
{====================== 8И-НЕ =============================}

CONSTRUCTOR Logic_8AND_NOT.Init ( OU_1, OU_0, OU_C : REAL;
                         IU_1, IU_0 : REAL;
                         IC_1, IC_0 : WORD;
                         RB : REAL );
            { Инициализация модели, установка }
            { начального состояния            }

BEGIN
     BaseLogicModel.Init ( 9, OU_1, OU_0, OU_C, IU_1, IU_0,
                              IC_1, IC_0, RB );
     SetParamLm ( 1, InLm );
     SetParamLm ( 2, InLm );
     SetParamLm ( 3, InLm );
     SetParamLm ( 4, InLm );
     SetParamLm ( 5, InLm );
     SetParamLm ( 6, InLm );
     SetParamLm ( 7, InLm );
     SetParamLm ( 8, InLm );
     SetParamLm ( 9, OutLm );
     SingLogic := TRUE

END; { constrructor Logic_8AND_NOT.Init }

{----------------------------------------------------------}

PROCEDURE Logic_8AND_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 9 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState AND
                                        LogicPtr^[ 2 ].LogicState AND
                                        LogicPtr^[ 3 ].LogicState AND
                                        LogicPtr^[ 4 ].LogicState AND
                                        LogicPtr^[ 5 ].LogicState AND
                                        LogicPtr^[ 6 ].LogicState AND
                                        LogicPtr^[ 7 ].LogicState AND
                                        LogicPtr^[ 8 ].LogicState )

END; { procedure Logic_8AND_NOT.CalcLogic }

{----------------------------------------------------------}
{====================== 8ИЛИ-НЕ ===========================}

PROCEDURE Logic_8OR_NOT.CalcLogic ( LogicPtr : StateBlModelPtr );
          { Вычисление состояния выходов по  }
          { заданной логической функции      }

BEGIN
     LogicPtr^[ 9 ].LogicState := NOT ( LogicPtr^[ 1 ].LogicState OR
                                        LogicPtr^[ 2 ].LogicState OR
                                        LogicPtr^[ 3 ].LogicState OR
                                        LogicPtr^[ 4 ].LogicState OR
                                        LogicPtr^[ 5 ].LogicState OR
                                        LogicPtr^[ 6 ].LogicState OR
                                        LogicPtr^[ 7 ].LogicState OR
                                        LogicPtr^[ 8 ].LogicState )

END; { procedure Logic_8OR_NOT.CalcLogic }

{----------------------------------------------------------}

END.

