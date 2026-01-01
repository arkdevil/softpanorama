
            {-------------------------------------------------}
            {         Модуль  BaseData  V 1.2                 }
            {-------------------------------------------------}
            { Язык программирования : Borland Pascal V 7.0    }
            {-------------------------------------------------}
            { Дата создания : 21/04/1992                      }
            { Дата последних изменений : 28/06/1993           }
            {-------------------------------------------------}
            {   Модуль содержит определения наиболее часто    }
            { встречающихся типов данных отличных от стандарта}
            { и используемых в программах обрабтки данных     }
            {-------------------------------------------------}
            {  (c) 1992 - 1993 Ярослав Мигач                  }
            {-------------------------------------------------}

UNIT BaseData;

    {===================== Ключи компиляции ===================}

{$F+,O+,A+,B-,X+,V-}

{$IFDEF DEBUGBASEDATA }
        {$D+,L+,R+,S+,I+}
{$ELSE}
        {$D-,L-,R-,S-,I-}
{$ENDIF}

    {==========================================================}

INTERFACE

USES Dos, Crt, Def;

TYPE
    ShortDate = LONGINT;
              { Дата в формате  ГГГГММ }

    FullDate  = LONGINT;
              { Дата в формате ГГГГММДД }

    ShortTime = WORD;
              { Время в формате ЧЧММ }

    FullTime  = LONGINT;
              { Время в формате ЧЧММСС }

    ShortVoc  = BYTE;
              { Короткий целочисленный идентификатор по словарю }

    NumVoc    = WORD;
              { Целочисленный идентификатор по словарю }

    RealVoc   = REAL;
              { Вещественный идентификатор по словарю }

    StringVoc = STRING [ 15 ];
              { Строковый идентификатор по словарю }

    LevelVoc  = LongInt;
              { Идентификатор по двух-уровневому словарю "2/3" }

{----------------------------------------------------------}

FUNCTION GetYearInFullDate ( Num : FullDate ) : WORD;
FUNCTION GetYearInShortDate ( Num : ShortDate ) : WORD;
FUNCTION GetMonthInShortDate ( Num : ShortDate ) : BYTE;
FUNCTION GetMonthInFullDate ( Num : FullDate ) : BYTE;
FUNCTION GetDayInFullDate ( Num : FullDate ) : BYTE;
FUNCTION StrShortDate ( Num : ShortDate ) : STRING;
FUNCTION StrFullDate ( Num : FullDate ) : STRING;
FUNCTION ValShortDate ( Line : STRING; VAR Num : ShortDate ) : BYTE;
FUNCTION ValFullDate ( Line : STRING; VAR Num : FullDate ) : BYTE;
PROCEDURE IncShortDate ( VAR Num : ShortDate );
PROCEDURE IncFullDate ( VAR Num : FullDate );
FUNCTION ShortToFullDate ( Num : ShortDate ) : FullDate;
FUNCTION FullToShortDate ( Num : FullDate ) : ShortDate;
FUNCTION CheckShortDate ( Dt, Min, Max : ShortDate ) : BOOLEAN;
FUNCTION CheckFullDate ( Dt, Min, Max : FullDate ) : BOOLEAN;
FUNCTION GetSystemFullDate : FullDate;
PROCEDURE SetSystemFullDate ( Num : FullDate );
FUNCTION DealDays ( Num1, Num2 : FullDate ) : WORD;
FUNCTION DealMonthes ( Num1, Num2 : ShortDate ) : WORD;

{----------------------------------------------------------}

FUNCTION GetHourInShortTime ( Num : ShortTime ) : WORD;
FUNCTION GetHourInFullTime ( Num : FullTime ) : WORD;
FUNCTION GetMinuteInShortTime ( Num : ShortTime ) : WORD;
FUNCTION GetMinuteInFullTime ( Num : FullTime ) : WORD;
FUNCTION GetSecondInFullTime ( Num : FullTime ) : WORD;
FUNCTION StrShortTime ( Num : ShortTime ) : STRING;
FUNCTION StrFullTime ( Num : FullTime ) : STRING;
FUNCTION ValShortTime ( Line : STRING; VAR Num : ShortTime ) : BYTE;
FUNCTION ValFullTime ( Line : STRING; VAR Num : FullTime ) : BYTE;
FUNCTION IncShortTime ( VAR Num : ShortTime ) : BYTE;
FUNCTION IncFullTime ( VAR Num : FullTime ) : BYTE;
FUNCTION ShortToFullTime ( Num : ShortTime ) : FullTime;
FUNCTION FullToShortTime ( Num : FullTime ) : ShortTime;
FUNCTION CheckShortTime ( Tm, Min, Max : ShortTime ) : BOOLEAN;
FUNCTION CheckFullTime ( Tm, Min, Max : FullTime ) : BOOLEAN;
FUNCTION GetSystemFullTime : FullTime;
PROCEDURE SetSystemFullTime ( Num : FullTime );
FUNCTION DealSecond ( Num1, Num2 : FullTime ) : WORD;

{----------------------------------------------------------}

FUNCTION StrStringVoc ( Num : StringVoc ) : STRING;
FUNCTION StrNumVoc ( Num : NumVoc ) : STRING;
FUNCTION StrShortVoc ( Num : ShortVoc ) : STRING;
FUNCTION StrRealVoc ( Num : RealVoc; VHi, VLo : BYTE ) : STRING;
FUNCTION StrLevelVoc ( Num : LevelVoc ) : STRING;
FUNCTION CheckLevelVoc  ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;
FUNCTION ValLevelVoc ( Line : STRING; VAR Num : LevelVoc;
                       FlName : StandartString ) : BYTE;
FUNCTION CheckStringVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;
FUNCTION CheckShortVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;
FUNCTION CheckNumVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;
FUNCTION CheckRealVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;
FUNCTION ValShortVoc ( Line : STRING; VAR Num : ShortVoc;
                       FlName : StandartString ) : BYTE;
FUNCTION ValNumVoc ( Line : STRING; VAR Num : NumVoc;
                       FlName : StandartString ) : BYTE;
FUNCTION ValRealVoc ( Line : STRING; VAR Num : RealVoc;
                       FlName : StandartString ) : BYTE;

IMPLEMENTATION

{----------------------------------------------------------}

FUNCTION GetYearInFullDate ( Num : FullDate ) : WORD;

       { получить значение года из полной даты }

BEGIN
     GetYearInFullDate := Num DIV 10000

END; { function GetYearInFullDate }

{----------------------------------------------------------}

FUNCTION GetYearInShortDate ( Num : ShortDate ) : WORD;

       { получить значение года из сокращенной даты }

BEGIN
     GetYearInShortDate := Num DIV 100

END; { function GetYearInShortDate }

{----------------------------------------------------------}

FUNCTION GetMonthInShortDate ( Num : ShortDate ) : BYTE;

         { получить месяц из сокращенной даты }
BEGIN
     GetMonthInShortDate := Num MOD 100

END; { FUNCTION GetMonthInShortDate }

{----------------------------------------------------------}

FUNCTION GetMonthInFullDate ( Num : FullDate ) : BYTE;

         { получить месяц из полной даты }
BEGIN
     GetMonthInFullDate := ( Num DIV 100 ) MOD 100

END; { FUNCTION GetMonthInFullDate }

{----------------------------------------------------------}

FUNCTION GetDayInFullDate ( Num : FullDate ) : BYTE;

         { получить день из полной даты }
BEGIN
     GetDayInFullDate := Num MOD 100

END; { function GetDayInFullDate }

{----------------------------------------------------------}

FUNCTION StrShortDate ( Num : ShortDate ) : STRING;

         { Строковое преобразование сокращенной даты }
VAR
   LineYear, LineMonth : STRING [ 4 ];

BEGIN
     STR ( GetYearInShortDate ( Num ), LineYear );
     STR ( GetMonthInShortDate ( Num ), LineMonth );
     WHILE ( LENGTH ( LineYear ) < 4 ) DO
           LineYear := '0' + LineYear;
     WHILE ( LENGTH ( LineMonth ) < 2 ) DO
           LineMonth := '0' + LineMonth;
     StrShortDate := LineMonth + '/'+LineYear

END; { FUNCTION StrShortDate }

{----------------------------------------------------------}

FUNCTION StrFullDate ( Num : FullDate ) : STRING;

         { Строковое преобразование полной даты }
VAR
   LineYear, LineMonth, LineDay : STRING [ 4 ];

BEGIN
     STR ( GetYearInFullDate ( Num ), LineYear );
     STR ( GetMonthInFullDate ( Num ), LineMonth );
     STR ( GetDayInFullDate ( Num ), LineDay );
     WHILE ( LENGTH ( LineYear ) < 4 ) DO
           LineYear := '0' + LineYear;
     WHILE ( LENGTH ( LineMonth ) < 2 ) DO
           LineMonth := '0' + LineMonth;
     WHILE ( LENGTH ( LineDay ) < 2 ) DO
           LineDay := '0' + LineDay;
     StrFullDate := LineDay + '/' + LineMonth + '/'+LineYear

END; { FUNCTION StrFullDate }

{----------------------------------------------------------}

FUNCTION ValShortDate ( Line : STRING; VAR Num : ShortDate ) : BYTE;

         { Преобразование строки в формат сокращенной даты }
VAR
   Err : INTEGER;
   LineYear, LineMonth : STRING [ 4 ];
   ResultYear, ResultMonth : LONGINT;

BEGIN
     ValShortDate := 01;
     IF ( LENGTH ( Line ) <> 7 ) THEN
        EXIT;
     LineMonth := Line [ 1 ] + Line [ 2 ];
     LineYear := Line [ 4 ] + Line [ 5 ] + Line [ 6 ] + Line [ 7 ];
     VAL ( LineMonth, ResultMonth, Err );
     IF ( ( Err <> 0 ) OR ( ResultMonth = 0 ) OR ( ResultMonth > 12 ) ) THEN
        EXIT;
     VAL ( LineYear, ResultYear, Err );
     IF ( ( Err <> 0 ) OR ( ResultYear > 5000 ) ) THEN
        EXIT;
     ValShortDate := 0;
     Num := ResultYear * 100 + ResultMonth;
     IF ( Num < 199001 ) THEN
       ValShortDate := 1

END; { FUNCTION ValShortDate }

{----------------------------------------------------------}

FUNCTION CheckDay ( Year, Month, Day : LONGINT ) : BOOLEAN; NEAR;

         { Функция проверки допустимости порядкового номера дня }
         { при заданном месяце и годе                           }
BEGIN
     CheckDay := FALSE;
     IF ( ( Day = 0 ) OR ( Day > 31 ) ) THEN
        EXIT;
     CASE Month OF
                   { Февраль }
           2  : IF ( ( Year MOD 4 ) = 0 ) THEN
                   BEGIN
                        IF ( Day > 29 ) THEN
                           EXIT
                   END
                ELSE
                    BEGIN
                         IF ( Day > 28 ) THEN
                            EXIT
                    END;

                   { Апрель }
           4  : IF ( Day > 30 ) THEN
                   EXIT;

                   { Июнь }
           6  : IF ( Day > 30 ) THEN
                   EXIT;

                   { Сентябрь }
           9  : IF ( Day > 30 ) THEN
                   EXIT;

                   { Ноябрь }
           11 : IF ( Day > 30 ) THEN
                   EXIT
     END;
     CheckDay := TRUE

END; { FUNCTION CheckDay }

{----------------------------------------------------------}

FUNCTION ValFullDate ( Line : STRING; VAR Num : FullDate ) : BYTE;

         { Преобразование строки в формат полной даты }
VAR
   Err : INTEGER;
   LineYear, LineMonth, LineDay : STRING [ 4 ];
   ResultYear, ResultMonth, ResultDay : LONGINT;

BEGIN
     ValFullDate := 01;
     IF ( LENGTH ( Line ) <> 10 ) THEN
        EXIT;
     LineDay := Line [ 1 ] + Line [ 2 ];
     LineMonth := Line [ 4 ] + Line [ 5 ];
     LineYear := Line [ 7 ] + Line [ 8 ] + Line [ 9 ] + Line [ 10 ];
     VAL ( LineMonth, ResultMonth, Err );
     IF ( ( Err <> 0 ) OR ( ResultMonth = 0 ) OR ( ResultMonth > 12 ) ) THEN
        EXIT;
     VAL ( LineYear, ResultYear, Err );
     IF ( ( Err <> 0 ) OR ( ResultYear > 5000 ) ) THEN
        EXIT;
     VAL ( LineDay, ResultDay, Err );
     IF ( ( Err <> 0 ) OR
          ( NOT CheckDay ( ResultYear, ResultMonth, ResultDay ) ) ) THEN
        EXIT;
     ValFullDate := 0;
     Num := ResultYear * 10000 + ResultMonth * 100 + ResultDay;
     IF ( Num < 19000101 ) THEN
       ValFullDate := 1

END; { FUNCTION ValFullDate }

{----------------------------------------------------------}

PROCEDURE IncShortDate ( VAR Num : ShortDate );

          { Инкремент сокращенной даты на 1 месяц }
VAR
   Year, Month : LONGINT;

BEGIN
     Year := Num DIV 100;
     Month := Num MOD 100;
     INC ( Month );
     IF ( Month > 12 ) THEN
        BEGIN
             INC ( Year );
             Month := 1
        END;
     Num := Year * 100 + Month

END; { PROCEDURE IncShortDate }

{----------------------------------------------------------}

PROCEDURE IncFullDate ( VAR Num : FullDate );

          { Инкремент полной даты на 1 день }
VAR
   Year, Month, Day : LONGINT;

BEGIN
     Year := Num DIV 10000;
     Month := ( Num DIV 100 ) MOD 100;
     Day := Num MOD 100;
     INC ( Day );
     IF ( NOT CheckDay ( Year, Month, Day ) ) THEN
        BEGIN
             Day := 1;
             INC ( Month );
             IF ( Month > 12 ) THEN
                BEGIN
                     INC ( Year );
                     Month := 1
                END
        END;
     Num := Year * 10000 + Month * 100 + Day

END; { PROCEDURE IncFullDate }

{----------------------------------------------------------}

FUNCTION FullToShortDate ( Num : FullDate ) : ShortDate;

         { Преобразование полной даты в сокращенную путем }
         { отброса порядкового номера дня                 }
VAR
   Hlp : LONGINT;

BEGIN
     Hlp := GetYearInFullDate ( Num );
     Hlp := Hlp * 100 + GetMonthInFullDate ( Num );
     FullToShortDate := Hlp

END; { FUNCTION FullToShortDate }

{----------------------------------------------------------}

FUNCTION ShortToFullDate ( Num : ShortDate ) : FullDate;

         { Преобразование короткой даты в полную и установка }
         { первого дня месяца полной даты                    }
VAR
   Hlp : LONGINT;

BEGIN
     Hlp := GetYearInShortDate ( Num );
     Hlp := Hlp * 10000 + GetMonthInShortDate ( Num ) * 100 + 01;
     ShortToFullDate := Hlp

END; { FUNCTION ShortToFullDate }

{----------------------------------------------------------}

FUNCTION CheckShortDate ( Dt, Min, Max : ShortDate ) : BOOLEAN;

         { Контроль короткой даты на вхождение в заданный диапазон }
         { с дополнительной проверкой допустимости значений всех   }
         {                указанных параметров                     }
VAR
   Line : STRING;

BEGIN
     CheckShortDate := FALSE;
     IF ( ValShortDate ( StrShortDate ( Dt ), Dt ) <> 0 ) THEN
        EXIT;
     IF ( ValShortDate ( StrShortDate ( Min ), Min ) <> 0 ) THEN
        EXIT;
     IF ( ValShortDate ( StrShortDate ( Max ), Max ) <> 0 ) THEN
        EXIT;
     IF ( ( Dt < Min ) OR ( Dt > Max ) ) THEN
        EXIT;
     CheckShortDate := TRUE

END; { FUNCTION CheckShortDate }

{----------------------------------------------------------}

FUNCTION CheckFullDate ( Dt, Min, Max : FullDate ) : BOOLEAN;

         { Контроль полной даты на вхождение в заданный диапазон }
         { с дополнительной проверкой допустимости значений      }
         {          всех передаваемых параметров                 }
VAR
   Line : STRING;

BEGIN
     CheckFullDate := FALSE;
     IF ( ValFullDate ( StrFullDate ( Dt ), Dt ) <> 0 ) THEN
        EXIT;
     IF ( ValFullDate ( StrFullDate ( Min ), Min ) <> 0 ) THEN
        EXIT;
     IF ( ValFullDate ( StrFullDate ( Max ), Max ) <> 0 ) THEN
        EXIT;
     IF ( ( Dt < Min ) OR ( Dt > Max ) ) THEN
        EXIT;
     CheckFullDate := TRUE

END; { FUNCTION CheckFullDate }

{----------------------------------------------------------}

FUNCTION GetSystemFullDate : FullDate;

         { Получение и преобразование системной даты }
         {        в формат полной даты               }
VAR
   Year, Month, Day, DayOfWeek : WORD;
   Num : LONGINT;

BEGIN
     GETDATE ( Year, Month, Day, DayOfWeek );
     Num := Year;
     Num := Num * 10000;
     Num := Num + 100 * Month;
     Num := Num + Day;
     GetSystemFullDate := Num

END; { FUNCTION GetSystemFullDate : FullDate }

{----------------------------------------------------------}

PROCEDURE SetSystemFullDate ( Num : FullDate );

          { Установка новой системной даты по формату полной даты }
BEGIN
     SETDATE ( GetYearInFullDate ( Num ), GetMonthInFullDate ( Num ),
               GetDayInFullDate ( Num ) )

END; { PROCEDURE SetSystemFullDate }

{----------------------------------------------------------}

FUNCTION DealDays ( Num1, Num2 : FullDate ) : WORD;

         { Вычисление количества прошедших дней между двумя }
         {                полными датами                    }
VAR
   Swp : FullDate;
   Count : WORD;

BEGIN
     IF ( Num1 > Num2 ) THEN
        BEGIN
             Swp := Num1;
             Num1 := Num2;
             Num2 := Swp
        END;
     Count := 0;
     WHILE ( Num1 <> Num2 ) DO
           BEGIN
                IncFullDate ( Num1 );
                INC ( Count )
           END;
     DealDays := Count

END; { FUNCTION DealDays }

{----------------------------------------------------------}

FUNCTION DealMonthes ( Num1, Num2 : ShortDate ) : WORD;

         { Вычисление количества прошедших месяцев между }
         {          двумя короткими датами               }
VAR
   Swp : ShortDate;
   Count : WORD;

BEGIN
     IF ( Num1 > Num2 ) THEN
        BEGIN
             Swp := Num1;
             Num1 := Num2;
             Num2 := Swp
        END;
     Count := 0;
     WHILE ( Num1 <> Num2 ) DO
           BEGIN
                IncShortDate ( Num1 );
                INC ( Count )
           END;
     DealMonthes := Count

END; { FUNCTION DealMonthes }

{==========================================================}
{---------            Время                     -----------}

FUNCTION GetHourInShortTime ( Num : ShortTime ) : WORD;

         { Получить значение часов из формата короткого времени }
BEGIN
     GetHourInShortTime := Num DIV 100

END; { FUNCTION GetHourInShortTime }

{----------------------------------------------------------}

FUNCTION GetHourInFullTime ( Num : FullTime ) : WORD;

         { Получить значение в часах из формата полного времени }
BEGIN
     GetHourInFullTime := Num DIV 10000

END; { FUNCTION GetHourInFullTime }

{----------------------------------------------------------}

FUNCTION GetMinuteInShortTime ( Num : ShortTime ) : WORD;

         { Получить значение минут из формата короткого времени }
BEGIN
     GetMinuteInShortTime := Num MOD 100

END; { FUNCTION GetMinuteInShortTime }

{----------------------------------------------------------}

FUNCTION GetMinuteInFullTime ( Num : FullTime ) : WORD;

         { Получить значение минут из формата полного времени }
BEGIN
     GetMinuteInFullTime := ( Num DIV 100 ) MOD 100

END; { FUNCTION GetMinuteInFullTime }

{----------------------------------------------------------}

FUNCTION GetSecondInFullTime ( Num : FullTime ) : WORD;

         { Получить значение секунд из формата полного времени }
BEGIN
     GetSecondInFullTime := Num MOD 100

END; { FUNCTION GetSecondInFullTime }

{----------------------------------------------------------}

FUNCTION StrShortTime ( Num : ShortTime ) : STRING;

         { Строковое преобразование формата короткого времени }
VAR
   LineHour, LineMinute : STRING [ 2 ];

BEGIN
     STR ( GetHourInShortTime ( Num ), LineHour );
     STR ( GetMinuteInShortTime ( Num ), LineMinute );
     IF ( LENGTH ( LineHour ) = 1 ) THEN
        LineHour := '0' + LineHour;
     IF ( LENGTH ( LineMinute ) = 1 ) THEN
        LineMinute := '0' + LineMinute;
     StrShortTime := LineHour + ':' + LineMinute

END; { FUNCTION StrShortTime }

{----------------------------------------------------------}

FUNCTION StrFullTime ( Num : FullTime ) : STRING;

         { Строковое преобразование формата полного времени }
VAR
   LineHour, LineMinute, LineSecond : STRING [ 2 ];

BEGIN
     STR ( GetHourInFullTime ( Num ), LineHour );
     STR ( GetMinuteInFullTime ( Num ), LineMinute );
     STR ( GetSecondInFullTime ( Num ), LineSecond );
     IF ( LENGTH ( LineHour ) = 1 ) THEN
        LineHour := '0' + LineHour;
     IF ( LENGTH ( LineMinute ) = 1 ) THEN
        LineMinute := '0' + LineMinute;
     IF ( LENGTH ( LineSecond ) = 1 ) THEN
        LineSecond := '0' + LineSecond;
     StrFullTime := LineHour + ':' + LineMinute + ':' + LineSecond

END; { FUNCTION StrFullTime }

{----------------------------------------------------------}

FUNCTION ValShortTime ( Line : STRING; VAR Num : ShortTime ) : BYTE;

         { Преобразование строки в формат короткого времени }
VAR
   LineHour, LineMinute : STRING [ 2 ];
   ResultHour, ResultMinute : WORD;
   Err : INTEGER;

BEGIN
     ValShortTime := 1;
     IF ( LENGTH ( Line ) <> 5  ) THEN
        EXIT;
     LineHour := Line [ 1 ] + Line [ 2 ];
     LineMinute := Line [ 4 ] + Line [ 5 ];
     VAL ( LineHour, ResultHour, Err );
     IF ( ( Err <> 0 ) OR ( ResultHour > 23 ) ) THEN
        EXIT;
     VAL ( LineMinute, ResultMinute, Err );
     IF ( ( Err <> 0 ) OR ( ResultMinute > 59 ) ) THEN
        EXIT;
     Num := ResultHour * 100 + ResultMinute;
     ValShortTime := 0

END; { FUNCTION ValShortTime }

{----------------------------------------------------------}

FUNCTION ValFullTime ( Line : STRING; VAR Num : FullTime ) : BYTE;

         { Преобразование строки в формат полного времени }
VAR
   LineHour, LineMinute, LineSecond : STRING [ 2 ];
   ResultHour, ResultMinute, ResultSecond : WORD;
   Err : INTEGER;

BEGIN
     ValFullTime := 1;
     IF ( LENGTH ( Line ) <> 8 ) THEN
        EXIT;
     LineHour := Line [ 1 ] + Line [ 2 ];
     LineMinute := Line [ 4 ] + Line [ 5 ];
     LineSecond := Line [ 7 ] + Line [ 8 ];
     VAL ( LineHour, ResultHour, Err );
     IF ( ( Err <> 0 ) OR ( ResultHour > 23 ) ) THEN
        EXIT;
     VAL ( LineMinute, ResultMinute, Err );
     IF ( ( Err <> 0 ) OR ( ResultMinute > 59 ) ) THEN
        EXIT;
     VAL ( LineSecond, ResultSecond, Err );
     IF ( ( Err <> 0 ) OR ( ResultSecond > 59 ) ) THEN
        EXIT;
     Num := ResultHour;
     Num := Num * 10000 + ResultMinute * 100 + ResultSecond;
     ValFullTime := 0

END; { FUNCTION ValFullTime }

{----------------------------------------------------------}

FUNCTION IncShortTime ( VAR Num : ShortTime ) : BYTE;

         { Инкриметн минут формата короткого времени }
VAR
   Hour, Minute : WORD;

BEGIN
     IncShortTime := 0;
     Hour := GetHourInShortTime ( Num );
     Minute := GetMinuteInShortTime ( Num );
     INC ( Minute );
     IF ( Minute > 59 ) THEN
        BEGIN
             Minute := 0;
             INC ( Hour );
             IF ( Hour > 23 ) THEN
                BEGIN
                     Hour := 0;
                     IncShortTime := 1
                END
        END;
     Num := Hour * 100 + Minute

END; { PROCEDURE IncShortTime }

{----------------------------------------------------------}

FUNCTION IncFullTime ( VAR Num : FullTime ) : BYTE;

         { Инкримент секунд формата полного времени }
VAR
   Hour, Minute, Second : WORD;

BEGIN
     IncFullTime := 0;
     Hour := GetHourInFullTime ( Num );
     Minute := GetMinuteInFullTime ( Num );
     Second := GetSecondInFullTime ( Num );
     INC ( Second );
     IF ( Second > 59 ) THEN
        BEGIN
             Second := 0;
             INC ( Minute );
             IF ( Minute > 59 ) THEN
                BEGIN
                     Minute := 0;
                     INC ( Hour );
                     IF ( Hour > 23 ) THEN
                        BEGIN
                             Hour := 0;
                             IncFullTime := 1
                        END
                END
        END;
     Num := Hour;
     Num := Num * 10000 + Minute * 100 + Second

END; { PROCEDURE IncFullTime }

{----------------------------------------------------------}

FUNCTION ShortToFullTime ( Num : ShortTime ) : FullTime;

        { Преобразование короткого времени в полное }
VAR
   Hour, Minute : LONGINT;

BEGIN
     Hour := GetHourInShortTime ( Num );
     Minute := GetMinuteInShortTime ( Num );
     ShortToFullTime := Hour * 10000 + Minute * 100 + 00

END; { FUNCTION ShortToFullTime }

{----------------------------------------------------------}

FUNCTION FullToShortTime ( Num : FullTime ) : ShortTime;

         { Преобразование полного времени в короткое }
VAR
   Hour, Minute : WORD;

BEGIN
     Hour := GetHourInFullTime ( Num );
     Minute := GetMinuteInFullTime ( Num );
     FullToShortTime := Hour * 100 + Minute

END; { FUNCTION FullToShortTime }

{----------------------------------------------------------}

FUNCTION CheckShortTime ( Tm, Min, Max : ShortTime ) : BOOLEAN;

         { Контроль данных в формате короткого времени на       }
         { вхождение в допустимый диапазон значений с проверкой }
         { на допустимость всех передаваемых параметров         }
BEGIN
     CheckShortTime := FALSE;
     IF ( ValShortTime ( StrShortTime ( Tm ), Tm ) <> 0 ) THEN
        EXIT;
     IF ( ValShortTime ( StrShortTime ( Min ), Min ) <> 0 ) THEN
        EXIT;
     IF ( ValShortTime ( StrShortTime ( Max ), Max ) <> 0 ) THEN
        EXIT;
     IF ( ( Tm < Min ) OR ( Tm > Max ) ) THEN
        EXIT;
     CheckShortTime := TRUE;

END; { FUNCTION CheckShortTime }

{----------------------------------------------------------}

FUNCTION CheckFullTime ( Tm, Min, Max : FullTime ) : BOOLEAN;

         { Контроль данных в формате полного времени на         }
         { вхождение в допустимый диапазон значений с проверкой }
         { на допустимость всех передаваемых параметров         }
BEGIN
     CheckFullTime := FALSE;
     IF ( ValFullTime ( StrFullTime ( Tm ), Tm ) <> 0 ) THEN
        EXIT;
     IF ( ValFullTime ( StrFullTime ( Min ), Min ) <> 0 ) THEN
        EXIT;
     IF ( ValFullTime ( StrFullTime ( Max ), Max ) <> 0 ) THEN
        EXIT;
     IF ( ( Tm < Min ) OR ( Tm > Max ) ) THEN
        EXIT;
     CheckFullTime := TRUE;

END; { FUNCTION CheckFullTime }

{----------------------------------------------------------}

FUNCTION GetSystemFullTime : FullTime;

         { Получение значения системных часов в формате полного времени }
VAR
   Hour, Minute, Second, Sec100 : WORD;
   Num : LONGINT;

BEGIN
     GETTIME ( Hour, Minute, Second, Sec100 );
     Num := Hour;
     GetSystemFullTime := Num * 10000 + Minute * 100 + Second

END; { FUNCTION GetSystemFullTime }

{----------------------------------------------------------}

PROCEDURE SetSystemFullTime ( Num : FullTime );

          { Установка значения системных часов по данным в }
          {          формате полного времени               }
VAR
   Hour, Minute, Second : WORD;

BEGIN
     Hour := GetHourInFullTime ( Num );
     Minute := GetMinuteInFullTime ( Num );
     Second := GetSecondInFullTime ( Num );
     SETTIME ( Hour, Minute, Second, 0 )

END; { PROCEDURE SetSystemFullTime }

{----------------------------------------------------------}

FUNCTION DealSecond ( Num1, Num2 : FullTime ) : WORD;

         { Получить количество секунд между двумя значениями полного времени }
VAR
   Swp : FullTime;
   Count : WORD;

BEGIN
     IF ( Num1 > Num2 ) THEN
        BEGIN
             Swp := Num1;
             Num1 := Num2;
             Num2 := Swp
        END;
     Count := 0;
     WHILE ( Num1 <> Num2 ) DO
           BEGIN
                IncFullTime ( Num1 );
                INC ( Count )
           END;
     DealSecond := Count

END; { FUNCTION DealSecond }

{==========================================================}
{-----                 Словари                        -----}
{----------------------------------------------------------}
{  Во многих случаях удобно представлять часть данных в закодированном
виде. Где каждому значению кода из допустимого диапазона соответствует
расшифровка представленная в текстовом или ином виде. Таим образом удобно
хранить в памяти машины информацию по наименованиям дожностей,
видам деятельности предприятий, наименованиям типовых элементов и их
стоимости и т. п. Поскольку пользователю неудобно, да и при больших
количествах наименований просто невозможно оперировать с кодами в
цифровом виде, вводится понятие словаря ( справочника, классификатора ),
по которому из программы можно очень быстро сопоставить значению
кода конкретную расшифровку. Кроме всего, словари могут быть вложенными,
когда некоторому коду ставится в соответствие имя файла более
конкретизированного словаря. Подобные древовидные словари гораздо удобнее
в использовании. Как правило необходимость работы с такими словарями
возникает при увеличении количества просматриваемых позиций более
ста. В этом случае поиск по линейному словарю становится утомительным.

  Предлагается следующий формат словаря :

                  З А Г О Л О В О К

----------------------------------------------------------
 Поле кода :  Поле 1   :   Поле2  :! Поле3 : Поле4  .....
----------------------------------------------------------
 . Имя раздела
 Код
      . . . . . . . . . . . . . . . . . . . . . . . . .

      Первым в словаре следует поле кода или имени раздела
Поле кода всегда начинается со второй позиции и оканчивается
прибелом или двоеточием. Имя раздела обозначается точкой во
второй позиции.
       Если в первой позиции проставлен восклицательный
знак, то поле является невидимым и не отображаентся при выводе
на экран. Если в первой позиции стоит значек #, то за ним следует
имя файла подчиненного словря. Значек # может применяться только
в первой строке расшифровки кода. Если в первой строке такой значек
не обнаружен, то код интерпритируется как конечный код словаря.
Последняя строка словаря всегда должна быть пустой.

-----------------------------------------------------------}

FUNCTION StrShortVoc ( Num : ShortVoc ) : STRING;

         { Строковое преобразование кода короткого словря }
VAR
   Line : STRING [ 3 ];

BEGIN
     STR ( Num, Line );
     StrShortVoc := Line

END; { FUNCTION StrShortVoc }

{----------------------------------------------------------}

FUNCTION StrNumVoc ( Num : NumVoc ) : STRING;

         { Строковое преобразование кода обычного словаря }
VAR
   Line : STRING [ 3 ];

BEGIN
     STR ( Num, Line );
     StrNumVoc := Line

END; { FUNCTION StrNumVoc }

{----------------------------------------------------------}

FUNCTION StrLevelVoc ( Num : LevelVoc ) : STRING;

         { Строковое преобразование кода двух-уровневого словаря }
VAR
   Line : STRING [ 10 ];

BEGIN
     STR ( Num, Line );
     StrLevelVoc := Line

END; { FUNCTION StrLevelVoc }

{----------------------------------------------------------}

FUNCTION StrRealVoc ( Num : RealVoc; VHi, VLo : BYTE ) : STRING;

         { Строковое преобразование кода дробного словаря }
VAR
   Line : STRING [ 20 ];

BEGIN
     STR ( Num : VHi : VLo, Line );
     StrRealVoc := Line

END; { FUNCTION StrRealVoc }

{----------------------------------------------------------}

FUNCTION StrStringVoc ( Num : StringVoc ) : STRING;

         { Фиктивное строковое преобразование символьного кода }
BEGIN
     StrStringVoc := Num

END; { FUNCTION StrStringVoc }

{----------------------------------------------------------}

FUNCTION CheckStringVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;

         { Проверка наличия строкового кода в словаре }
VAR
   Line : STRING;
   KeyFind : BOOLEAN;
   HelpS : STRING [ 15 ];
   Index : BYTE;
   Counter : LONGINT;

BEGIN
     CheckStringVoc := 0;

        { Выделение памяти для промежуточного буфера }

     SetMaxBuf ( MaxAvail );

         { Открытие файла справочника }

     SetNameText ( FlName );
     IF ( DefResult <> 0 ) THEN
        BEGIN
             CloseText;
             DefResult;
             Voc := '';
             EXIT
        END;

        {  Цикл поиска кода по строкам }

     KeyFind := FALSE;
     Counter := 0;
     WHILE ( ( NOT EofText ) AND ( DefResult = 0 ) AND ( NOT KeyFind ) ) DO
           BEGIN
                ReadText ( Line );
                IF ( NOT ( KeyFind ) ) THEN
                   INC ( Counter );
                IF ( ( LENGTH ( Line ) > 5 ) AND
                     ( Line [ 1 ] IN [ ' ', ':', '!', '#' ] ) AND
                     ( Line [ 2 ] <> ' ' ) ) THEN
                   BEGIN
                             { Анализ строки }
                        HelpS := '';
                        Index := 2;
                        WHILE ( ( NOT ( Line [ Index ]
                                IN [ ':', '!', '#' ] ) ) AND
                                ( LENGTH ( Line ) >= Index ) ) DO
                              BEGIN
                                   HelpS := HelpS + Line [ Index ];
                                   INC ( Index )
                              END;
                        WHILE ( HelpS [ LENGTH ( HelpS ) ] = ' ' ) DO
                              DELETE ( HelpS, LENGTH ( HelpS ), 1 );
                        KeyFind := ( Voc = HelpS )
                   END
           END;

     CloseText;
     DefResult;
     SetMaxBuf ( $1000 );
     IF ( KeyFind ) THEN
        CheckStringVoc := Counter

END; { FUNCTION CheckStringVoc }

{----------------------------------------------------------}

FUNCTION CheckShortVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;

         { Проверка наличия строкового кода в словаре }
VAR
   Line : STRING;
   KeyFind : BOOLEAN;
   NumVoc, NumFind : BYTE;
   ErrVoc, ErrFind : INTEGER;
   HelpS : STRING [ 15 ];
   Index : BYTE;
   Counter : LONGINT;

BEGIN
     CheckShortVoc := 0;

        { Выделение памяти для промежуточного буфера }

     SetMaxBuf ( MaxAvail );

     VAL ( Voc, NumVoc, ErrVoc );
     IF ( ErrVoc <> 0 ) THEN
        EXIT;

         { Открытие файла справочника }

     SetNameText ( FlName );
     IF ( DefResult <> 0 ) THEN
        BEGIN
             CloseText;
             DefResult;
             Voc := '';
             EXIT
        END;

        {  Цикл поиска кода по строкам }

     KeyFind := FALSE;
     Counter := 0;
     WHILE ( ( NOT EofText ) AND ( DefResult = 0 ) AND ( NOT KeyFind ) ) DO
           BEGIN
                ReadText ( Line );
                IF ( NOT ( KeyFind ) ) THEN
                   INC ( Counter );
                IF ( ( LENGTH ( Line ) > 5 ) AND
                     ( Line [ 1 ] IN [ ' ', ':', '!', '#' ] ) AND
                     ( Line [ 2 ] <> ' ' ) ) THEN
                   BEGIN
                             { Анализ строки }
                        HelpS := '';
                        Index := 2;
                        WHILE ( NOT ( Line [ Index ]
                                IN [ ' ', ':', '!', '#' ] ) ) DO
                              BEGIN
                                   HelpS := HelpS + Line [ Index ];
                                   INC ( Index )
                              END;
                        VAL ( HelpS, NumFind, ErrFind );
                        IF ( ErrFind = 0 ) THEN
                           KeyFind := ( NumVoc = NumFind )
                   END
           END;

     CloseText;
     DefResult;
     SetMaxBuf ( $1000 );
     IF ( KeyFind ) THEN
        CheckShortVoc := Counter

END; { FUNCTION CheckShortVoc }

{----------------------------------------------------------}

FUNCTION CheckNumVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;

         { Проверка наличия строкового кода в словаре }
VAR
   Line : STRING;
   KeyFind : BOOLEAN;
   NumVoc, NumFind : WORD;
   ErrVoc, ErrFind : INTEGER;
   HelpS : STRING [ 15 ];
   Index : BYTE;
   Counter : LONGINT;

BEGIN
     CheckNumVoc := 0;

        { Выделение памяти для промежуточного буфера }

     SetMaxBuf ( MaxAvail ) ;

     VAL ( Voc, NumVoc, ErrVoc );
     IF ( ErrVoc <> 0 ) THEN
        EXIT;

         { Открытие файла справочника }

     SetNameText ( FlName );
     IF ( DefResult <> 0 ) THEN
        BEGIN
             CloseText;
             DefResult;
             Voc := '';
             EXIT
        END;

        {  Цикл поиска кода по строкам }

     KeyFind := FALSE;
     Counter := 0;
     WHILE ( ( NOT EofText ) AND ( DefResult = 0 ) AND ( NOT KeyFind ) ) DO
           BEGIN
                ReadText ( Line );
                IF ( NOT ( KeyFind ) ) THEN
                   INC ( Counter );
                IF ( ( LENGTH ( Line ) > 5 ) AND
                     ( Line [ 1 ] IN [ ' ', ':', '!', '#' ] ) AND
                     ( Line [ 2 ] <> ' ' ) ) THEN
                   BEGIN
                             { Анализ строки }
                        HelpS := '';
                        Index := 2;
                        WHILE ( NOT ( Line [ Index ]
                                IN [ ' ', ':', '!', '#' ] ) ) DO
                              BEGIN
                                   HelpS := HelpS + Line [ Index ];
                                   INC ( Index )
                              END;
                        VAL ( HelpS, NumFind, ErrFind );
                        IF ( ErrFind = 0 ) THEN
                           KeyFind := ( NumVoc = NumFind )
                   END
           END;

     CloseText;
     DefResult;
     SetMaxBuf ( $1000 );
     IF ( KeyFind ) THEN
        CheckNumVoc := Counter

END; { FUNCTION CheckNumVoc }

{----------------------------------------------------------}

FUNCTION CheckRealVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;

         { Проверка наличия строкового кода в словаре }
VAR
   Line : STRING;
   KeyFind : BOOLEAN;
   NumVoc, NumFind : REAL;
   ErrVoc, ErrFind : INTEGER;
   HelpS : STRING [ 15 ];
   Index : BYTE;
   Counter : LONGINT;

BEGIN
     CheckRealVoc := 0;

        { Выделение памяти для промежуточного буфера }

     SetMaxBuf ( MaxAvail );

     VAL ( Voc, NumVoc, ErrVoc );
     IF ( ErrVoc <> 0 ) THEN
        EXIT;

         { Открытие файла справочника }

     SetNameText ( FlName );
     IF ( DefResult <> 0 ) THEN
        BEGIN
             CloseText;
             DefResult;
             Voc := '';
             EXIT
        END;


        {  Цикл поиска кода по строкам }

     KeyFind := FALSE;
     Counter := 0;
     WHILE ( ( NOT EofText ) AND ( DefResult = 0 ) AND ( NOT KeyFind ) ) DO
           BEGIN
                ReadText ( Line );
                IF ( NOT ( KeyFind ) ) THEN
                   INC ( Counter );
                IF ( ( LENGTH ( Line ) > 5 ) AND
                     ( Line [ 1 ] IN [ ' ', ':', '!', '#' ] ) AND
                     ( Line [ 2 ] <> ' ' ) ) THEN
                   BEGIN
                             { Анализ строки }
                        HelpS := '';
                        Index := 2;
                        WHILE ( NOT ( Line [ Index ]
                                IN [ ' ', ':', '!', '#' ] ) ) DO
                              BEGIN
                                   HelpS := HelpS + Line [ Index ];
                                   INC ( Index )
                              END;
                        VAL ( HelpS, NumFind, ErrFind );
                        IF ( ErrFind = 0 ) THEN
                           KeyFind := ( NumVoc = NumFind )
                   END
           END;

     CloseText;
     DefResult;
     SetMaxBuf ( $1000 );
     IF ( KeyFind ) THEN
        CheckRealVoc := Counter

END; { FUNCTION CheckRealVoc }

{----------------------------------------------------------}

FUNCTION CheckLevelVoc ( VAR Voc : STRING; FlName : StandartString ) : LONGINT;

         { Проверка наличия строкового кода в словаре }
Var
  FirstCod : String [ 2 ];
  LastCod : String [ 5 ];
  Dir, Name, Ext : PathStr;
BEGIN
  CheckLevelVoc := 0;
  if Length ( Voc ) = 4 then
    FirstCod := '0' + Voc [ 1 ]
  else
    if Length ( Voc ) = 5 then
      FirstCod := Voc [ 1 ] + Voc [ 2 ]
    else
      Exit;
  if CheckShortVoc ( FirstCod, FlName ) > 0 then Begin
    FSplit ( FlName, Dir, Name, Ext );
    LastCod := Voc;
    if Length ( LastCod ) = 5 then
      Delete ( LastCod, 1, 2 )
    else
      Delete ( LastCod, 1, 1 );
    CheckLevelVoc := CheckNumVoc ( LastCod, Dir + Name + FirstCod + Ext )
  End

END; { FUNCTION CheckLevelVoc }

{----------------------------------------------------------}

FUNCTION ValShortVoc ( Line : STRING; VAR Num : ShortVoc;
                       FlName : StandartString ) : BYTE;

         { Преобразование строки в формат кода короткого словаря }
VAR
   Err : INTEGER;

BEGIN
     IF ( Line = '' ) THEN
        BEGIN
             Num := 0;
             ValShortVoc := 0;
             EXIT
        END;
     IF ( CheckShortVoc ( Line, FlName ) = 0 ) THEN
        BEGIN
             ValShortVoc := 01
        END
     ELSE
         BEGIN
              VAL ( Line, Num, Err );
              IF ( Err = 0 ) THEN
                 ValShortVoc := 00
              ELSE
                  ValShortVoc := 01
         END

END; { FUNCTION ValShortVoc }

{----------------------------------------------------------}

FUNCTION ValNumVoc ( Line : STRING; VAR Num : NumVoc;
                       FlName : StandartString ) : BYTE;

         { Преобразование строки в формат кода обычного словаря }
VAR
   Err : INTEGER;

BEGIN
     IF ( Line = '' ) THEN
        BEGIN
             Num := 0;
             ValNumVoc := 0;
             EXIT
        END;
     IF ( CheckNumVoc ( Line, FlName ) = 0 ) THEN
        BEGIN
             ValNumVoc := 01
        END
     ELSE
         BEGIN
              VAL ( Line, Num, Err );
              IF ( Err = 0 ) THEN
                 ValNumVoc := 00
              ELSE
                  ValNumVoc := 01
         END

END; { FUNCTION ValNumVoc }

{----------------------------------------------------------}

FUNCTION ValRealVoc ( Line : STRING; VAR Num : RealVoc;
                       FlName : StandartString ) : BYTE;

         { Преобразование строки в формат кода дробного словаря }
VAR
   Err : INTEGER;

BEGIN
     IF ( Line = '' ) THEN
        BEGIN
             Num := 0;
             ValRealVoc := 0;
             EXIT
        END;
     IF ( CheckRealVoc ( Line, FlName ) = 0 ) THEN
        BEGIN
             ValRealVoc := 01
        END
     ELSE
         BEGIN
              VAL ( Line, Num, Err );
              IF ( Err = 0 ) THEN
                 ValRealVoc := 00
              ELSE
                  ValRealVoc := 01
         END

END; { FUNCTION ValRealVoc }

{----------------------------------------------------------}

FUNCTION ValLevelVoc ( Line : STRING; VAR Num : LevelVoc;
                       FlName : StandartString ) : BYTE;

         { Преобразование строки в формат кода двух-уровневого словаря }
VAR
   Err : INTEGER;

BEGIN
     IF ( Line = '' ) THEN
        BEGIN
             Num := 0;
             ValLevelVoc := 0;
             EXIT
        END;
     if Length ( Line ) = 4 then
       Line := '0' + Line;
     IF ( CheckLevelVoc ( Line, FlName ) = 0 ) THEN
        BEGIN
             ValLevelVoc := 01
        END
     ELSE
         BEGIN
              VAL ( Line, Num, Err );
              IF ( Err = 0 ) THEN
                 ValLevelVoc := 00
              ELSE
                  ValLevelVoc := 01
         END

END; { FUNCTION ValLevelVoc }

{----------------------------------------------------------}

END. { UNIT BaseData }
