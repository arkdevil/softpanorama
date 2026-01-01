{$A+,B-,D+,E+,F+,I-,L+,N+,O-,R-,S-,V-}
{$M 16384,0,655360}

unit TBDTM;

interface

uses
  Dos{, TpInline};

const
  DateLen = 20;              {maximum length of Picture strings}
type
    Date = LongInt;

  DayType = (Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday);
  DateString = string[DateLen];
  Time = LongInt;
  DateTimeRec =
    record
      D : Date;
      T : Time;
    end;
const
    MinYear = 1600;
    MaxYear = 3999;
    MinDate = $00000000;     {= 01/01/1600}
    MaxDate = $000D6025;     {= 12/31/3999}
    Date1900 = $0001AC05;    {= 01/01/1900}
    Date1980 = $00021E28;    {= 01/01/1980}
    BadDate = $FFFFFFFF;

  MinTime = 0;               {= 00:00:00 am}
  MaxTime = 86399;           {= 23:59:59 pm}
  BadTime = $FFFFFFFF;

  SecondsInDay = 86400;      {number of seconds in a day}
  SecondsInHour = 3600;      {number of seconds in an hour}
  SecondsInMinute = 60;      {number of seconds in a minute}
  HoursInDay = 24;           {number of hours in a day}
  MinutesInHour = 60;        {number of minutes in an hour}

var
  DefaultYear : Integer;     {default year--used by DateStringToDMY}

const
  {the following characters are meaningful in date Picture strings}
  MonthOnly = 'm';           {these are for date/time pictures, and allow}
  DayOnly = 'd';             {  numbers and spaces only}
  YearOnly = 'y';
  {if uppercase letters are used, numbers are padded with ' ' rather than '0'}
  MonthOnlyU = 'M';
  DayOnlyU = 'D';
  DateSlash = '/';
  SlashChar : Char = '/';

const
  {the following characters are meaningful in time Picture strings}
  HourOnly = 'h';
  MinOnly = 'm';
  SecOnly = 's';
  {if uppercase letters are used, numbers are padded with ' ' rather than '0'}
  HourOnlyU = 'H';
  MinOnlyU = 'M';
  SecOnlyU = 'S';
  {'hh:mm:ss te' -> '12:00:00 pm', 'hh:mmt' -> '12:00p'}
  TimeOnly = 't';            {generates 'p', 'P', 'a', or 'A'}
  EmOnly = 'e';              {optional--generates 'm' or 'M'}
  TimeColon = ':';
  ColonChar : Char = ':';
  UpCaseTime : Boolean = False; {if true, 't' and 'e' force upper case}

const
  MonthString : array[1..12] of string[9] = (
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December');
const
  DayString : array[DayType] of string[9] = (
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

  {-------julian date routines---------------}

function ValidDate(Day, Month, Year : Integer) : Boolean;
  {-Verify that day, month, year is a valid date}

function DMYtoDate(Day, Month, Year : Integer) : Date;
  {-Convert from day, month, year to a julian date}

procedure DateToDMY(Julian : Date; var Day, Month, Year : Integer);
  {-Convert from a julian date to day, month, year}

function IncDate(Julian : Date; Days, Months, Years : Integer) : Date;
  {-Add (or subtract) the number of days, months, and years to a date}

function DayOfWeek(Julian : Date) : DayType;
  {-Return the day of the week for the date}

function DateStringToDate(Picture, S : DateString) : Date;
  {-Convert S, a string of the form indicated by Picture, to a julian date.
    Picture and S must be of equal lengths}

function DateToDateString(Picture : DateString; Julian : Date) : DateString;
  {-Convert Julian to a string of the form indicated by Picture}

function Today : Date;
  {-Returns today's date as a julian}

function DateToSortString(Julian : Date) : string;
  {-Convert a date to a sortable string}

  {-------date string routines---------------}

function DateStringToDMY(Picture, S : DateString; var D, M, Y : Integer) : Boolean;
  {-Extract day, month, and year from S, returning true if string is valid}

function DMYtoDateString(Picture : DateString; Day, Month, Year : Integer) : DateString;
  {-Merge the month, day, and year into the picture}

function TodayString(Picture : DateString) : DateString;
  {-Returns today's date as a string of the specified form}

  {-------time routines---------------}

procedure TimeToHMS(T : Time; var Hours, Minutes, Seconds : Byte);
  {-Convert a Time variable to Hours, Minutes, Seconds}

function HMStoTime(Hours, Minutes, Seconds : Byte) : Time;
  {-Convert Hours, Minutes, Seconds to a Time variable}

function TimeStringToTime(Picture, S : DateString) : Time;
  {-Convert S, a string of the form indicated by Picture, to Time}

function TimeToTimeString(Picture : DateString; T : Time) : DateString;
  {-Convert T to a string of the form indicated by Picture}

function TimeToAmPmString(Picture : DateString; T : Time) : DateString;
  {-Convert T to a string of the form indicated by Picture. Times are always
    displayed in am/pm format.}

function CurrentTime : Time;
  {-Returns current time in seconds since midnight}

function CurrentTimeString(Picture : DateString) : DateString;
  {-Returns current time as a string of the specified form}

procedure TimeDiff(Time1, Time2 : Time; var Hours, Minutes, Seconds : Byte);
  {-Return the difference in hours,minutes,seconds between two times}

function IncTime(T : Time; Hours, Minutes, Seconds : Byte) : Time;
  {-Add the specified hours,minutes,seconds to T and return the result}

function TimeToSortString(T : Time) : string;
  {-Convert a time variable to a sortable string}

function RoundToNearestHour(T : Time; Truncate : Boolean) : Time;
  {-Round T to the nearest hour, or Truncate minutes and seconds from T}

function RoundToNearestMinute(T : Time; Truncate : Boolean) : Time;
  {-Round T to the nearest minute, or Truncate seconds from T}

  {-------- routines for DateTimeRec records ---------}

procedure IncDateTime(var DT1, DT2 : DateTimeRec; Days : Integer; Secs : LongInt);
  {-Increment (or decrement) DT1 by the specified number of days and seconds
    and put the result in DT2}

  {-------- routines for international date/time strings ---------}

function InternationalDate(WholeYear, ZeroPad : Boolean) : DateString;
  {-Return a picture mask for a date string, based on DOS's country info}

function InternationalTime(WithSeconds, ZeroPad : Boolean;
                           ExtraSpace, WithEm : Boolean) : DateString;
  {-Return a picture mask for a time string, based on DOS's country info}

  {-------- the following are interfaced for use by TPENTRY -------}

type
  CountryInfoPtr = ^CountryInfo;
  CountryInfo =
    record
      DateFormat : Word;     {0=US (mdy), 1=Europe (dmy), 2 = Japan (ymd)}
      case Byte of
        2 : (                  {DOS 2.x}
          CurrencySym : Char;  {'$' for US}
          Unused1 : Byte;      {0}
          CommaSym1 : Char;    {',' for US}
          Unused2 : Byte;      {0}
          DecimalSym1 : Char); {'.' for US}

        3 : (                  {DOS 3.x or higher}
          CurrencyStr : array[1..5] of Char; {ASCIIZ string}
          CommaSym2 : Char;    {',' for US}
          Unused3 : Byte;      {0}
          DecimalSym2 : Char;  {'.' for US}
          Unused4 : Byte;      {0}
          DateSym : Char;      {'-' for US}
          Unused5 : Byte;      {0}
          TimeSym : Char;      {':' for US}
          Unused6 : Byte;      {0}
          CurrencyForm : Byte; {0-4}
          Decimals : Byte;     {# of digits after decimal point}
          TimeForm : Byte;     {bit 0 = 0 for 12-hour clock; 1 for 24-hour}
          Unused7 : array[1..14] of Byte);
    end;

function GetCountryInfo(var Dos2 : Boolean; var Info : CountryInfo) : Boolean;
  {-Return a country information table in Info}

  {==========================================================================}

implementation

const
    First2Months = 59;         {1600 was a leap year}
    FirstDayOfWeek = Saturday; {01/01/1600 was a Saturday}

  function IsLeapYear(Year : Integer) : Boolean;
    {-Return True if Year is a leap year}
  begin
    IsLeapYear := (Year mod 4 = 0) and (Year mod 4000 <> 0) and
      ((Year mod 100 <> 0) or (Year mod 400 = 0));
  end;

  function DaysInMonth(Month, Year : Integer) : Integer;
    {-Return the number of days in the specified month of a given year}
  begin
    if Word(Year) < 100 then
      Inc(Year, 1900);
    case Month of
      1, 3, 5, 7, 8, 10, 12 :
        DaysInMonth := 31;
      4, 6, 9, 11 :
        DaysInMonth := 30;
      2 :
        DaysInMonth := 28+Ord(IsLeapYear(Year));
    else
      DaysInMonth := 0;
    end;
  end;

  function ValidDate(Day, Month, Year : Integer) : Boolean;
    {-Verify that day, month, year is a valid date}
  begin
    if Word(Year) < 100 then
      Inc(Year, 1900);

    if (Day < 1) or (Year < MinYear) or (Year > MaxYear) then
      ValidDate := False
    else case Month of
      1..12 :
        ValidDate := Day <= DaysInMonth(Month, Year);
    else
      ValidDate := False;
    end
  end;

  function DMYtoDate(Day, Month, Year : Integer) : Date;
    {-Convert from day, month, year to a julian date}
  begin
    if Word(Year) < 100 then
      Inc(Year, 1900);

    if not ValidDate(Day, Month, Year) then
      DMYtoDate := BadDate
    else if (Year = MinYear) and (Month < 3) then
      if Month = 1 then
        DMYtoDate := Pred(Day)
      else
        DMYtoDate := Day+30
    else begin
      if Month > 2 then
        Dec(Month, 3)
      else begin
        Inc(Month, 9);
        Dec(Year);
      end;
      Dec(Year, MinYear);
      DMYtoDate :=
        ((LongInt(Year div 100)*146097) div 4)+
        ((LongInt(Year mod 100)*1461) div 4)+
        (((153*Month)+2) div 5)+Day+First2Months;
    end;
  end;

  procedure DateToDMY(Julian : Date; var Day, Month, Year : Integer);
    {-Convert from a julian date to month, day, year}
  var
    I, J : LongInt;
  begin
    if Julian = BadDate then begin
      Day := 0;
      Month := 0;
      Year := 0;
    end
    else if Julian <= First2Months then begin
      Year := MinYear;
      if Julian <= 30 then begin
        Month := 1;
        Day := Succ(Julian);
      end
      else begin
        Month := 2;
        Day := Julian-30;
      end;
    end
    else begin
      I := (4*LongInt(Julian-First2Months))-1;
      J := (4*((I mod 146097) div 4))+3;
      Year := (100*(I div 146097))+(J div 1461);
      I := (5*(((J mod 1461)+4) div 4))-3;
      Month := I div 153;
      Day := ((I mod 153)+5) div 5;
      if Month < 10 then
        Inc(Month, 3)
      else begin
        Dec(Month, 9);
        Inc(Year);
      end;
      Inc(Year, MinYear);
    end;
  end;

  function IncDate(Julian : Date; Days, Months, Years : Integer) : Date;
    {-Add (or subtract) the number of months, days, and years to a date.
      Months and years are added before days. No overflow/underflow
      checks are made}
  var
    Day, Month, Year, Day28Delta : Integer;
  begin
    DateToDMY(Julian, Day, Month, Year);
    Day28Delta := Day-28;
    if Day28Delta < 0 then
      Day28Delta := 0
    else
      Day := 28;
    Inc(Month, Months-1);
    Inc(Year, Years+(Month div 12)-Ord(Month < 0));
    Month := Succ(Month mod 12);
    if Month <= 0 then
      Inc(Month, 12);
    Julian := DMYtoDate(Day, Month, Year);
    if Julian <> BadDate then begin
      Inc(Julian, Days);
      Inc(Julian, Day28Delta);
    end;
    IncDate := Julian;
  end;

  function DayOfWeek(Julian : Date) : DayType;
    {-Return the day of the week for the date}
  begin
    DayOfWeek := DayType((Julian+Ord(FirstDayOfWeek)) mod 7);
  end;

  procedure ExtractFromPicture(var Picture, S : DateString; Ch : Char; var I : Integer);
    {-Extract the value of the subfield specified by Ch from S and return in I}
  var
    Tmp : DateString;
    TLen : Byte absolute Tmp;
    PLen : Byte absolute Picture;
    J, K : Integer;
    Code : Word;
  begin
    {find the start of the subfield}
    I := 0;
    J := Pos(Ch, Picture);
    Ch := Upcase(Ch);
    K := Pos(Ch, Picture);
    if (J = 0) or ((K > 0) and (K < J)) then
      J := K;
    if (J = 0) or (Length(S) <> Length(Picture)) then
      Exit;

    {extract the substring}
    TLen := 0;
    while (Upcase(Picture[J]) = Ch) and (J <= PLen) do begin
      if S[J] <> ' ' then begin
        Inc(TLen);
        Tmp[TLen] := S[J];
      end;
      Inc(J);
    end;

    {convert to a value}
    Val(Tmp, I, Code);
    if Code <> 0 then
      I := 0;
  end;

  function DateStringToDMY(Picture, S : DateString; var D, M, Y : Integer) : Boolean;
    {-Extract day, month, and year from S, returning true if string is valid}
  begin
    ExtractFromPicture(Picture, S, MonthOnly, M);
    ExtractFromPicture(Picture, S, DayOnly, D);
    ExtractFromPicture(Picture, S, YearOnly, Y);
    if (M <> 0) and (D <> 0) then
      if (Y = 0) then
        Y := DefaultYear;
    DateStringToDMY := ValidDate(D, M, Y);
  end;

  function DateStringToDate(Picture, S : DateString) : Date;
    {-Convert S, a string of the form indicated by Picture, to a julian date.
      Picture and S must be of equal lengths}
  var
    Month, Day, Year : Integer;
  begin
    {extract day, month, year from S}
    if DateStringToDMY(Picture, S, Day, Month, Year) then
      {convert to julian date}
      DateStringToDate := DMYtoDate(Day, Month, Year)
    else
      DateStringToDate := BadDate;
  end;

  procedure SubstChar(var Picture : DateString; OldCh, NewCh : Char);
    {-Replace all instances of OldCh in Picture with NewCh}
  var
    I : Byte;
    UpCh : Char;
  begin
    UpCh := Upcase(OldCh);
    if (Pos(OldCh, Picture) <> 0) or (Pos(UpCh, Picture) <> 0) then
      for I := 1 to Length(Picture) do
        if Upcase(Picture[I]) = UpCh then
          Picture[I] := NewCh;
  end;

  procedure MergeIntoPicture(var Picture : DateString; Ch : Char; I : Integer);
    {-Merge I into location in Picture indicated by format character Ch}
  var
    Tmp : DateString;
    PLen : Byte absolute Picture;
    J, K : Integer;
    CPJ, CTI : Char;
  begin
    {find the start of the subfield}
    J := Pos(Ch, Picture);
    Ch := Upcase(Ch);
    if J = 0 then begin
      J := Pos(Ch, Picture);
      if J = 0 then
        Exit;
    end;

    {find the end of the subfield}
    while (J < PLen) and (Upcase(Picture[J+1]) = Ch) do
      Inc(J);

    {convert I to a string}
    Str(I:DateLen, Tmp);

    {now merge}
    I := DateLen;
    CPJ := Picture[J];
    while (Upcase(CPJ) = Ch) and (J > 0) and (I > 0) do begin
      CTI := Tmp[I];
      {change spaces to 0's if desired}
      if (CPJ >= 'a') and (CTI = ' ') then
        CTI := '0';
      Picture[J] := CTI;
      Dec(J);
      Dec(I);
      CPJ := Picture[J];
    end;
  end;

  function DMYtoDateString(Picture : DateString; Day, Month, Year : Integer) : DateString;
    {-Merge the month, day, and year into the picture}
  begin
    MergeIntoPicture(Picture, MonthOnly, Month);
    MergeIntoPicture(Picture, DayOnly, Day);
    MergeIntoPicture(Picture, YearOnly, Year);

    {map slashes}
    SubstChar(Picture, DateSlash, SlashChar);

    DMYtoDateString := Picture;
  end;

  function DateToDateString(Picture : DateString; Julian : Date) : DateString;
    {-Convert Julian to a string of the form indicated by Picture}
  var
    Month, Day, Year : Integer;
  begin
    if Julian = BadDate then begin
      {map picture characters to spaces}
      SubstChar(Picture, MonthOnly, ' ');
      SubstChar(Picture, DayOnly, ' ');
      SubstChar(Picture, YearOnly, ' ');

      {map slashes}
      SubstChar(Picture, DateSlash, SlashChar);

      DateToDateString := Picture;
    end
    else begin
      {convert Julian to day/month/year}
      DateToDMY(Julian, Day, Month, Year);

      {merge the month, day, and year into the picture}
      DateToDateString := DMYtoDateString(Picture, Day, Month, Year);
    end;
  end;

  function Today : Date;
    {-Returns today's date as a julian}
  var
    Year, Month, Day, DayOfWeek : Word;
  begin
    GetDate(Year, Month, Day, DayOfWeek);
    Today := DMYtoDate(Day, Month, Year);
  end;

  function TodayString(Picture : DateString) : DateString;
    {-Returns today's date as a string of the specified form}
  begin
    TodayString := DateToDateString(Picture, Today);
  end;

  function DateToSortString(Julian : Date) : string;
    {-Convert a date to a sortable string }
      const
        Result :
          record case Byte of
              0 : (Len : Byte; W1, W2 : Word);
              1 : (Str : string[4]);
          end = (Str : '    ');
      var
        DRec :
          record
            D1, D2 : Word;
          end absolute Julian;
  begin
    Result.W1 := Swap(DRec.D2);
    Result.W2 := Swap(DRec.D1);
    DateToSortString := Result.Str;
  end;

  procedure TimeToHMS(T : Time; var Hours, Minutes, Seconds : Byte);
    {-Convert a Time variable to Hours, Minutes, Seconds}
  begin
    if T = BadTime then begin
      Hours := 0;
      Minutes := 0;
      Seconds := 0;
    end
    else begin
      Hours := T div SecondsInHour;
      Dec(T, LongInt(Hours)*SecondsInHour);
      Minutes := T div SecondsInMinute;
      Dec(T, LongInt(Minutes)*SecondsInMinute);
      Seconds := T;
    end;
  end;

  function HMStoTime(Hours, Minutes, Seconds : Byte) : Time;
    {-Convert Hours, Minutes, Seconds to a Time variable}
  var
    T : Time;
  begin
    Hours := Hours mod HoursInDay;
    T := (LongInt(Hours)*SecondsInHour)+(LongInt(Minutes)*SecondsInMinute)+Seconds;
    HMStoTime := T mod SecondsInDay;
  end;

  function TimeStringToTime(Picture, S : DateString) : Time;
    {-Convert S, a string of the form indicated by Picture, to a Time variable}
  var
    Hours, Minutes, Seconds : Integer;
    I : Word;
  begin
    {extract hours, minutes, seconds from S}
    ExtractFromPicture(Picture, S, HourOnly, Hours);
    ExtractFromPicture(Picture, S, MinOnly, Minutes);
    ExtractFromPicture(Picture, S, SecOnly, Seconds);

    {check for TimeOnly}
    I := Pos(TimeOnly, Picture);
    if I <> 0 then
      case Upcase(S[I]) of
        'P' :
          if (Hours < 12) then
            Inc(Hours, 12)
          else if (Hours = 0) or (Hours > 12) then
            {force BadTime}
            Hours := HoursInDay;
        'A', ' ' :           {treat space like 'A'}
          if Hours = 12 then
            Hours := 0
          else if (Hours = 0) or (Hours > 12) then
            {force BadTime}
            Hours := HoursInDay;
      else
        {force BadTime}
        Hours := HoursInDay;
      end;

    {check for em}
    I := Pos(EmOnly, Picture);
    if I <> 0 then
      case Upcase(S[I]) of
        'M', ' ' : {ok} ;
        else Hours := HoursInDay; {force BadTime result}
      end;

    if (Hours > 23) or (Minutes > 59) or (Seconds > 59) then
      TimeStringToTime := BadTime
    else
      TimeStringToTime := HMStoTime(Hours, Minutes, Seconds);
  end;

  function TimeToTimeString(Picture : DateString; T : Time) : DateString;
    {-Convert T to a string of the form indicated by Picture}
  const
    AmPm : array[Boolean] of Char = ('a', 'p');
  var
    Hours, Minutes, Seconds : Byte;
    TPos, EPos : Byte;
    Ch1, Ch2 : Char;
  begin
    {merge the hours, minutes, and seconds into the picture}
    TimeToHMS(T, Hours, Minutes, Seconds);

    {check for TimeOnly}
    TPos := Pos(TimeOnly, Picture);
    if TPos <> 0 then begin
      Ch1 := AmPm[Hours >= 12];
      Ch2 := 'm';
      if UpCaseTime then begin
        Ch1 := Upcase(Ch1);
        Ch2 := 'M';
      end;

      {plug in the 'p' or 'a'}
      Picture[TPos] := Ch1;

      {get position of EmOnly}
      EPos := Pos(EmOnly, Picture);

      {adjust hours}
      case Hours of
        0 : Hours := 12;
        13..23 : Dec(Hours, 12);
      end;
    end
    else
      EPos := 0;

    if T = BadTime then begin
      {map picture characters to spaces}
      SubstChar(Picture, HourOnly, ' ');
      SubstChar(Picture, MinOnly, ' ');
      SubstChar(Picture, SecOnly, ' ');
    end
    else begin
      {merge the numbers into the picture}
      MergeIntoPicture(Picture, HourOnly, Hours);
      MergeIntoPicture(Picture, MinOnly, Minutes);
      MergeIntoPicture(Picture, SecOnly, Seconds);
    end;

    {map colons}
    SubstChar(Picture, TimeColon, ColonChar);

    {plug in the em now--if we do it earlier it looks like MinOnly}
    if EPos <> 0 then
      Picture[EPos] := Ch2;

    TimeToTimeString := Picture;
  end;

  function TimeToAmPmString(Picture : DateString; T : Time) : DateString;
    {-Convert T to a string of the form indicated by Picture. Times are always
      displayed in am/pm format.}
  var
    SaveLen : Byte;
  begin
    SaveLen := Length(Picture);
    if Pos(TimeOnly, Picture) = 0 then
      Picture := Picture+TimeOnly;
    TimeToAmPmString := TimeToTimeString(Picture, T);
    TimeToAmPmString[0] := Char(SaveLen);
  end;

  function CurrentTime : Time;
    {-Returns current time in seconds since midnight}
  var
    Hours, Minutes, Seconds, Sec100 : Word;
  begin
    GetTime(Hours, Minutes, Seconds, Sec100);
    CurrentTime := HMStoTime(Hours, Minutes, Seconds);
  end;

  function CurrentTimeString(Picture : DateString) : DateString;
    {-Returns current time as a string of the specified form}
  begin
    CurrentTimeString := TimeToTimeString(Picture, CurrentTime);
  end;

  procedure TimeDiff(Time1, Time2 : Time; var Hours, Minutes, Seconds : Byte);
    {-Return the difference in hours,minutes,seconds between two times}
  var
    T : Time;
  begin
    if Time1 > Time2 then
      T := Time1-Time2
    else
      T := Time2-Time1;
    TimeToHMS(T, Hours, Minutes, Seconds);
  end;

  function IncTime(T : Time; Hours, Minutes, Seconds : Byte) : Time;
    {-Add the specified hours,minutes,seconds to T and return the result}
  begin
    Hours := Hours mod HoursInDay;
    Inc(T, HMStoTime(Hours, Minutes, Seconds));
    IncTime := T mod SecondsInDay;
  end;

  function RoundToNearestHour(T : Time; Truncate : Boolean) : Time;
    {-Round T to the nearest hour, or Truncate minutes and seconds from T}
  var
    Hours, Minutes, Seconds : Byte;
  begin
    TimeToHMS(T, Hours, Minutes, Seconds);
    Seconds := 0;
    if not Truncate then
      if Minutes >= (MinutesInHour div 2) then
        Inc(Hours);
    Minutes := 0;
    RoundToNearestHour := HMStoTime(Hours, Minutes, Seconds);
  end;

  function RoundToNearestMinute(T : Time; Truncate : Boolean) : Time;
    {-Round T to the nearest minute, or Truncate seconds from T}
  var
    Hours, Minutes, Seconds : Byte;
  begin
    TimeToHMS(T, Hours, Minutes, Seconds);
    if not Truncate then
      if Seconds >= (SecondsInMinute div 2) then
        Inc(Minutes);
    Seconds := 0;
    RoundToNearestMinute := HMStoTime(Hours, Minutes, Seconds);
  end;

  function TimeToSortString(T : Time) : string;
    {-Convert a time variable to a sortable string}
  const
    Result :
      record case Byte of
          0 : (Len : Byte; W1, W2 : Word);
          1 : (Str : string[4]);
      end = (Str : '    ');
  var
    TRec :
      record
        T1, T2 : Word;
      end absolute T;
  begin
    Result.W1 := Swap(TRec.T2);
    Result.W2 := Swap(TRec.T1);
    TimeToSortString := Result.Str;
  end;

  procedure IncDateTime(var DT1, DT2 : DateTimeRec; Days : Integer; Secs : LongInt);
    {-Increment (or decrement) DT1 by the specified number of days and seconds
      and put the result in DT2}
  begin
    DT2 := DT1;

    {date first}
      Inc(DT2.D, LongInt(Days));

    if Secs < 0 then begin
      {change the sign}
      Secs := -Secs;

      {adjust the date}
      Dec(DT2.D, Secs div SecondsInDay);
      Secs := Secs mod SecondsInDay;

      if Secs > DT2.T then begin
        {subtract a day from DT2.D and add a day's worth of seconds to DT2.T}
        Dec(DT2.D);
        Inc(DT2.T, SecondsInDay);
      end;

      {now subtract the seconds}
      Dec(DT2.T, Secs);
    end
    else begin
      {increment the seconds}
      Inc(DT2.T, Secs);

      {adjust date if necessary}
      Inc(DT2.D, DT2.T div SecondsInDay);

      {force time to 0..SecondsInDay-1 range}
      DT2.T := DT2.T mod SecondsInDay;
    end;
  end;

  function GetCountryInfo(var Dos2 : Boolean; var Info : CountryInfo) : Boolean;
    {-Return a country information table in Info}
  var
    Regs : Registers;
  begin
    with Regs do begin
      {get DOS version}
      AX := $3000;
      Intr($21, Regs);
      Dos2 := (AL = 2);

      {get pointer to country information table}
      AX := $3800;
      DS := Seg(Info);
      DX := Ofs(Info);
      Intr($21, Regs);
      GetCountryInfo := not Odd(Flags);
    end;
  end;

  function InternationalDate(WholeYear, ZeroPad : Boolean) : DateString;
    {-Return a picture mask for a date string, based on DOS's country info}
  var
    Info : CountryInfo;
    Dos2 : Boolean;
  begin
    {assume failure}
    InternationalDate[0] := #0;

    {get country information table}
    if not GetCountryInfo(Dos2, Info) then
      Exit;

    {get date string format}
    with Info do begin
      {use US format if number is out of known bounds}
      if DateFormat > 2 then
        DateFormat := 0;
      case DateFormat of
        0 :                  {US}
          begin
            InternationalDate := 'mm/dd/yyyy';
            if not ZeroPad then begin
              InternationalDate[1] := 'M';
              InternationalDate[2] := 'M';
            end;
            if not WholeYear then
              InternationalDate[0] := #8;
          end;
        1 :                  {Europe}
          begin
            InternationalDate := 'dd/mm/yyyy';
            if not ZeroPad then begin
              InternationalDate[1] := 'D';
              InternationalDate[2] := 'D';
            end;
            if not WholeYear then
              InternationalDate[0] := #8;
          end;
        2 :                  {Japan}
          if WholeYear then
            InternationalDate := 'yyyy/mm/dd'
          else
            InternationalDate := 'yy/mm/dd';
      end;

      {set SlashChar}
      if not Dos2 then
        SlashChar := DateSym;
    end;
  end;

  function InternationalTime(WithSeconds, ZeroPad : Boolean;
                             ExtraSpace, WithEm : Boolean) : DateString;
    {-Return a picture mask for a time string, based on DOS's country info}
  var
    Info : CountryInfo;
    Dos2 : Boolean;
    TS : string[10];
    TSlen : Byte absolute TS;
  begin
    {assume failure}
    InternationalTime[0] := #0;

    {get pointer to country info}
    if not GetCountryInfo(Dos2, Info) then
      Exit;

    {format the default string}
    TS := 'hh:mm:ss';
    if not ZeroPad then begin
      TS[1] := 'H';
      TS[2] := 'H';
    end;
    if not WithSeconds then
      TS[0] := #5;

    {DOS 2.x doesn't provide any information about time strings}
    if not Dos2 then
      with Info do begin
        {set ColonChar}
        ColonChar := TimeSym;

        {if bit 0 not set, it's a 12-hour clock}
        if (TimeForm and $01) = 0 then begin
          if ExtraSpace then begin
            Inc(TSlen);
            TS[TSlen] := ' ';
          end;
          Inc(TSlen);
          TS[TSlen] := 't';
          if WithEm then begin
            Inc(TSlen);
            TS[TSlen] := 'e';
          end;
        end;
      end;

    InternationalTime := TS;
  end;

  procedure SetDefaultYear;
    {-Initialize the DefaultYear variable}
  var
    Month, Day, DayOfWeek : Word;
  begin
    GetDate(Word(DefaultYear), Month, Day, DayOfWeek);
  end;

begin
  {initialize DefaultYear}
  SetDefaultYear;
end.
