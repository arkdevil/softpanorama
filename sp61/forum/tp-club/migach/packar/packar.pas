
             {---------------------------------------------------}
             { Модуль определяет процедуры упаковки и распаковки }
             { байтовых массивов обьемом не более 64 Кбайт       }
             {---------------------------------------------------}
             { Язык программирования : Turbo Pascal  V 6.0       }
             {---------------------------------------------------}
             { Дата создания : 21/11/1991                        }
             { Дата последних изменений : 23/09/1992             }
             {---------------------------------------------------}
             { (c) 1991, 1992, Ирина Мигач, Ярослав Мигач        }
             {---------------------------------------------------}


 { Упакованный массив состоит из чередующихся упакованных и      }
 { неупакованных последовательностей. Первой всегда идет         }
 { неупакованная.                                                }

 { Формат упакованной последовательности:                        }
 {                                                               }
 {       Байт 1              Байт2      Байт3                    }
 {   |1|X|X|X|X|X|X|X|       \             /                     }
 {    ^  \__________/          \_________/                       }
 {    |       \                     |                            }
 {  Признак    Количество      Номер первого байта               }
 {  упаковки   байт повт.      последовательности                }
 {             послед.         в упакованном массиве             }
 {                                                               }
 {                                                               }
 {                                                               }
 { Формат неупакованной последовательности :                     }
 {                                                               }
 {              Байт 1      Байт 2     Байты i = 1...N           }
 {            /   \              /      \                        }
 {   Старший бит    \__________/          \  Байты               }
 {       0               \                   последовательности  }
 {   Признак            Количество байт                          }
 {  неупакованной       неупакованной                            }
 {  последовательности  последовательности                       }

UNIT PackAr;

INTERFACE

USES Crt, AnBuf;

PROCEDURE PackArray ( SrBoxPtr : BufferPtr; SrSize : WORD;
                      VAR DestBoxPtr : BufferPtr; VAR DestSize : WORD );
          { Упаковка массива }

PROCEDURE UnPackArray ( VAR SrBoxPtr : BufferPtr; VAR SrSize : WORD;
                          DestBoxPtr : BufferPtr; DestSize : WORD );
          { Распаковка массива }

IMPLEMENTATION

CONST
     MaxLend = 127;
               { Максимальная длина искомой повторяющейся }
               { последовательности                       }

     MaxSizeFind = $1000;
               { Максимальная глубина поиска 4 K byte }

     MinLend = 4;
               { Минимальная длина поиска }

     StepFind = MaxSizeFind DIV MaxLend;
               { Шаг поиска }

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

          { Выдача сообщения о критической ошибке }
BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTCOLOR ( LIGHTGRAY );
     TEXTBACKGROUND ( BLACK );
     CLRSCR;
     WRITELN ( #7 );
     WRITELN ( 'Критический сбой в модуле PackAr' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается...' );
     HALT ( 1 )

END; { proceddure FatalError }

{----------------------------------------------------------}

PROCEDURE PackArray ( SrBoxPtr : BufferPtr; SrSize : WORD;
                      VAR DestBoxPtr : BufferPtr; VAR DestSize : WORD );
          { Упаковка массива }
VAR
   Index_S : WORD;
         { Номер рассматриваемого элемента исходного массива }

   Index_D : WORD;
         { Номер рассматриеваемого элемента упакованного массива }

   HelpNumber : WORD;
         { Индекс начала длины последней последовательности }
         {         в упакованном массиве                    }

   AddrRecord : WORD;
         { Номер первого элемента повторяющейся последовательности }

   Lend : BYTE;
         { Длина повторяющейся последовательности }

   HelpArray : ARRAY [ 0..255 ] OF BYTE;
         { Вспомогательный массив поиска }

   Index : WORD;

  {..................................}


FUNCTION CheckRepeatBytes ( VAR Size : BYTE; { Сколько байт найдено }
            VAR Location : WORD { Гле расположены повторяющиеся байты }
            ) : BOOLEAN;
         { Функция определяет найдена ли повторяющаяся последовательность   }

         { Для ускорения поиска использованы алгоритмы поиска Боуера-Мура   }
         { и Кнута-Мориса-Пратта / см. Н.Вирт "Алгоритмы и структуры данных"}
VAR
   BeginFind : WORD;
         { Начальный адрес поиска последовательности }
         { в упакованном массиве                     }

   MaxFindLend : BYTE;
         { Максимальная фактическая длина искомой последовательности }

   CurrentIndex : WORD;
         { Адрес текущего сравниваемого симола }

   CurrentSize : BYTE;
         { Текущее количество }

   CurrentAddres : WORD;
         { Текущий адрес }

   CompByte, StartByte : BYTE;
         { Сравниваемый байт }

   SingFind : BOOLEAN;
         { Признак поиска }

   CurrentLend : BYTE;
         { Текущая максимальная длина поиска }

   SizeFind : WORD;
         { Глубина поиска }

BEGIN
       { Вычисляем  начальный адрес поиска последовательности }

     IF ( Index_S <= MaxSizeFind ) THEN
        BeginFind := 1
     ELSE
         BeginFind := Index_S - MaxSizeFind;

     SizeFind := Index_S - BeginFind;

       { Вычисляем максимальную фактическую длину }
       {   искомой последовательности             }

     IF ( SrSize - Index_S >= 127 ) THEN
        MaxFindLend := 127
     ELSE
         MaxFindLend := SrSize - Index_S;

     CurrentLend := SizeFind DIV StepFind;
     IF ( CurrentLend > MaxFindLend ) THEN
        CurrentLend := MaxFindLend;
     IF ( CurrentLend < MinLend ) THEN
        CurrentLend := MinLend;

       { Если максимальная длина < MinLend, то поиск не имеет смысла }

     IF ( MaxFindLend < MinLend ) THEN
        BEGIN
             CheckRepeatBytes := FALSE;
             EXIT
        END;

        { Инициализация переменных цикла }

     CurrentSize := 0;        { Текущий найденный размер }
     Size := MinLend - 1;     { Максимальный неупаковываемый размер }
     CurrentIndex := Index_S;
     StartByte := SrBoxPtr^ [ CurrentIndex ];
     CompByte := StartByte;
     CheckRepeatBytes := FALSE;

        { Цикл поиска последовательности }

     WHILE ( BeginFind < CurrentIndex ) DO

           IF ( SrBoxPtr^ [ BeginFind ] <> CompByte ) THEN
               BEGIN
                    { Рассмотрим два варианта :                       }
                    { 1. ранее сравниваемые байты совпали и Size <> 0 }
                    { и 2. не сопали - Size = 0                       }

                    IF ( CurrentSize = 0 ) THEN
                       BEGIN
                            { Если не совпали, то увеличиваем на 1 начальный }
                            { адрес поиска                                   }

                            INC ( BeginFind );

                            DEC ( SizeFind );
                            IF ( ( Lo ( SizeFind ) = 0 ) OR
                                 ( Lo ( SizeFind ) = 0 ) ) THEN
                               BEGIN
                                    CurrentLend := SizeFind DIV StepFind;
                                    IF ( CurrentLend > MaxFindLend ) THEN
                                       CurrentLend := MaxFindLend;
                                    IF ( CurrentLend < MinLend ) THEN
                                       CurrentLend := MinLend
                               END
                       END
                    ELSE
                        BEGIN
                             IF ( CurrentSize > Size ) THEN
                                { Если совпадает большее количество байт }
                                { чем ранее, то запоминаем параметры     }
                                { найденной последовательности           }
                                 BEGIN
                                      CheckRepeatBytes := TRUE;
                                      Size := CurrentSize;
                                      Location := CurrentAddres
                                 END;
                             CompByte := StartByte;
                             CurrentIndex := Index_S;
                             CurrentSize := 0
                        END
               END
           ELSE
               BEGIN
                    { Если ранее сравниваемые байты не совпали, то   }
                    { запоминаем адрес предполагамемого расположения }
                    { искомой последовательности                     }

                    IF ( CurrentSize = 0 ) THEN
                       BEGIN
                            { Поиск по алгоритму Боуера и Мура с использова }
                            { нием вспомогательного массива HelpArray       }
                            { Возможен переход на MinLend символов          }

                            IF ( SrBoxPtr^ [ BeginFind + MinLend - 1 ] <>
                                 SrBoxPtr^ [ CurrentIndex + MinLend - 1 ] ) THEN
                               BEGIN
                                    { Возможен переход на MinLend символов          }

                                    BeginFind := BeginFind +
                                       HelpArray [ SrBoxPtr^ [ BeginFind + MinLend - 1 ] ];
                                    SingFind := FALSE;
                               END
                            ELSE
                                BEGIN
                                     CurrentAddres := BeginFind;
                                     SingFind := TRUE
                                END
                       END;
                    { Увеличиваем на 1 размер, индекс поиска и адрес }
                    { начала поиска последовательности               }

                    IF ( SingFind ) THEN
                       BEGIN
                            INC ( CurrentSize );
                            INC ( CurrentIndex );
                            CompByte := SrBoxPtr^ [ CurrentIndex ];
                            INC ( BeginFind );

                            DEC ( SizeFind );
                            IF ( ( Lo ( SizeFind ) = 0 ) OR
                                 ( Lo ( SizeFind ) = 0 ) ) THEN
                               BEGIN
                                    CurrentLend := SizeFind DIV StepFind;
                                    IF ( CurrentLend > MaxFindLend ) THEN
                                       CurrentLend := MaxFindLend;
                                    IF ( CurrentLend < MinLend ) THEN
                                       CurrentLend := MinLend
                               END;

                    { Если совпало максимально-допустимое количество байт, }
                    { то прекращаем дальнейший поиск                       }

                            IF ( CurrentSize >= CurrentLend ) THEN
                               BEGIN
                                    CheckRepeatBytes := TRUE;
                                    Size := CurrentSize;
                                    Location := CurrentAddres;
                                    EXIT
                               END
                       END
             END


END; { function CheckRepeatBytes }

  {..................................}

PROCEDURE IncLend;

          { Увеличение определителя длины неупакованной }
          {        проследовательности на 1             }
BEGIN
     IF ( DestBoxPtr^ [ HelpNumber + 1 ] = 255 ) THEN
        BEGIN
             INC ( DestBoxPtr^ [ HelpNumber ] );
             DestBoxPtr^ [ HelpNumber + 1 ] := 0
        END
     ELSE
         INC ( DestBoxPtr^ [ HelpNumber + 1 ] )

END; { procedure IncLend }

  {..................................}

FUNCTION GetLend : WORD;

         { Возвращает текущую длину последней неупакованной }
         {        последовательности                        }
BEGIN
     GetLend := DestBoxPtr^ [ HelpNumber ] * $100 +
                DestBoxPtr^ [ HelpNumber + 1 ]

END; { function GetLend }

  {..................................}

BEGIN
     IF ( SrSize < 10 ) THEN
        FatalError ( 'Слишком маленькая входная последовательность' );

     Index_S := 1;
         { Подготовить вспомогательный массив поиска }

     FOR Index := 0 TO 255 DO
         HelpArray [ Index ] := MinLend;
     FOR Index := MinLend - 1 DOWNTO 1 DO
         HelpArray [ SrBoxPtr^ [ Index ] ] := Index;


          { Образуем информационный блок для неупакованной }
          {            последовательности                  }

     DestBoxPtr^[ 1 ] := 0; { Исходная длина неупакованной посл. }
     DestBoxPtr^[ 2 ] := 0; {   равна 0                          }

     HelpNumber := 1; { указатель на байты определения длины }

     Index_D := 3; { Первый свободный элемент упакованного массива }


     WHILE ( Index_S <= SrSize ) DO   {  цикл упаковки }

                { Вызываем функцию проверки наличия дублируемой  }
                {            последовательности                  }

           IF ( CheckRepeatBytes ( Lend, AddrRecord ) ) THEN
              BEGIN
                { Если длина дублируемой последовательности больше }
                { четырех байт, то "закрываем" информационный блок }
                { по неупакованной последовательности, создаем     }
                { блок по упакованной последовательности и затем   }
                { создаем новый блок пустой последовательности     }
                { Если блок неупакованной последовательности имеет }
                { нулевую длину, то блок упакованной создается на  }
                { его месте.                                       }

                   IF ( ( Lend > MaxLend ) OR ( Lend < MinLend ) ) THEN
                      FatalError ( 'Ошибка определения длины при упаковке' );

                      { Увеличиваем индекс текущего байта в исходном массиве }
                      { на длину найденной последовательности                }

                   Index_S := Index_S + Lend;

                      { Если длина предыдущей неупакованной }
                      { последовательности = 0, то блок     }
                      { упакованной создаем на его месте    }

                   IF ( GetLend = 0 ) THEN
                      DEC ( Index_D, 2 );

                      { Устанвливаем признак и длину   }
                      { упакованной последовательности }

                   DestBoxPtr^ [ Index_D ] := $80 OR Lend;
                   INC ( Index_D );

                      { Устанавливаем адрес упакованной  }
                      { последовательности в упакованном }
                      { массиве                          }

                   DestBoxPtr^ [ Index_D ] := Hi ( AddrRecord ); { Старшая }
                   INC ( Index_D );                              { часть   }

                   DestBoxPtr^ [ Index_D ] := Lo ( AddrRecord ); { Младшая }
                   INC ( Index_D );                              { часть   }

                   HelpNumber := Index_D; { указатель длины }

                   DestBoxPtr^[ Index_D ] := 0; { Исходная длина неупакованной посл. }
                   INC ( Index_D );             {   равна 0                          }
                   DestBoxPtr^[ Index_D ] := 0; 
                   INC ( Index_D )

              END
           ELSE
               BEGIN
                 { Иначе, добавляем один символ к неупакованной     }
                 { последрвательности, изменяем информацию о длине  }
                 { и переходим к следующему символу                 }


                    FOR Index := MinLend - 1 DOWNTO 1 DO
                        HelpArray [ SrBoxPtr^ [ Index + Index_S ] ] := Index;
                    HelpArray [ SrBoxPtr^ [ Index_S ] ] := MinLend;

                    DestBoxPtr^ [ Index_D ] := SrBoxPtr^ [ Index_S ];
                    IncLend;
                    INC ( Index_D );
                    INC ( Index_S );
                    IF ( GetLend = $7FFE ) THEN
                       BEGIN
                            HelpNumber := Index_D; { указатель длины }

                            DestBoxPtr^[ Index_D ] := 0; { Исходная длина неупакованной посл. }
                            INC ( Index_D );             {   равна 0                          }
                            DestBoxPtr^[ Index_D ] := 0;
                            INC ( Index_D )
                       END;
               END;

     DestSize := Index_D - 1

END; { procedure PackArray }

{----------------------------------------------------------}

PROCEDURE UnPackArray ( VAR SrBoxPtr : BufferPtr; VAR SrSize : WORD;
                         DestBoxPtr : BufferPtr; DestSize : WORD );
          { Распаковка массива }
CONST
     H = 127;

VAR
   LendHelp : WORD;
   Lend : WORD;
   i : INTEGER;
   Help : WORD;
   Index_S : WORD;
         { Номер рассматриваемого элемента исходного массива }

   Index_D : WORD;
         { Номер рассматриеваемого элемента упакованного массива }

    {.....................................}

FUNCTION Len : WORD;

BEGIN
     Len := DestBoxPtr^ [ Index_D ] * $100 +
                                 DestBoxPtr^ [ Index_D + 1 ]

END; { function Len }
 
    {.....................................}

BEGIN
     Index_S := 1;
     Index_D := 1;
     WHILE ( Index_D <= DestSize ) DO
        IF ( DestBoxPtr^ [ Index_D ] <= 127 ) THEN

              { Если последовательность в упакован. массиве неупакована }
          BEGIN
               LendHelp := Len;
               INC ( Index_D , 2 );
               FOR i := 1 TO LendHelp DO
                 BEGIN
                      SrBoxPtr^ [ Index_S ] := DestBoxPtr^ [ Index_D ];
                      INC ( Index_D );
                      INC ( Index_S )
                 END
          END

        ELSE
          BEGIN
               Lend := DestBoxPtr^ [ Index_D ] AND H;
               INC ( Index_D );
               Help := Len;
               FOR i := 1 TO Lend DO
                  BEGIN
                       SrBoxPtr^ [ Index_S ] := SrBoxPtr^ [ Help ];
                       INC ( Index_S );
                       INC ( Help )
                  END;
               INC ( Index_D, 2 )
          END;

     SrSize := Index_S - 1

END; { procedure UnPackArray }

{----------------------------------------------------------}

END.