{ Copyright (c) VES   Волынский Е.С.  v1.1  2.10.92 }

Unit VESStr;
{ П/п работы со строками }
interface

type
      CharSet = set of char;

const
      Leading  = 0;
      Trailing = 1;
      Both     = 2;

      LowStr  = 0;
      HighStr = 1;

      Left  = 0;
      Right = 1;

      Present    = 0;
      NotPresent = 1;

      Lower = 0;
      Upper =1;

      WordDelim : CharSet = [
                              ' ', ',', '"', ':', ';', '.',
                              '(', ')', '{', '}', '[', ']',
                              '!', '?', '/', '\', '*', '=',
                              '+', '-', '_', '<', '>', '#',
                              '@', '$', '%', '&', '^', #39, { <- ' }
                              '`', '~', '|'
                            ];

{ ───────────────────────────────────────────────────────────────────────── }
{ Удаление начальных и/или конечных символов строки                         }
{       Leading  - удаление       начальных      символов                   }
{ Key = Trailing -   - " -        конечных         - " -                    }
{       Both     -   - " -  начальных и конечных   - " -                    }
{ Удаляемые символы определяются значением DelChr                           }
Function Trim ( s : string;  Key : integer;  DelChr : CharSet ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Копирование строки заданное число раз                                     }
Function Copies ( s : string;  NumCopies : byte ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Формирование строки заданной длины, которая заведомо не больше/не меньше  }
{ любой другой строки той же длины                                          }
{ Key = LowStr  - формирование минимальной строки                           }
{       HighStr - формирование максимальной строки                          }
Function HighLow ( n : byte;  Key : integer ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Перевод строчных/прописных букв в строке в прописные/строчные             }
{ Обрабатываются буквы как латиницы, так и кириллицы ( в альт. кодировке )  }
{ Key = Lower - перевод прописных букв в строчные                           }
{       Upper - перевод строчных букв в прописные                           }
Function UpLowStr ( s : string;  Key : integer ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Получение строки, состоящей из символов, находящихся между двумя          }
{ заданными символами                                                       }
Function RangeStr ( StSimbol : char;  EndSimbol : char ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Выравнивание строки слева/справа по заданной длине заданным заполнителем  }
{ Key = Left  - Выравнивание строки по левой границе                        }
{       Right - Выравнивание строки по правой границе                       }
Function LeftRight ( s : string;  Len : byte;
                     FillChr : char;  Key : integer ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Проверка усечения для строки                                              }
{ s - строка, для которой проверяется усечение                              }
{ AbbrStr - усечение для заданной строки, которое проверяется на            }
{           правильность задания                                            }
{ AbbrLen - минимальная длина усечения                                      }
Function Abbrev ( s : string;  AbbrStr : string;  AbbrLen : byte ) : boolean;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Центрирование строки по заданной длине с заданным заполнителем            }
Function Center ( s : string;  Len : byte;  FillChr : char ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Сравнение двух строк                                                      }
{ Выдает позицию первого несовпадающего символа или 0 при совпадении        }
Function StrCmp ( s1 : string;  s2 : string;  FillChr : char ) : integer;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Поиск строки s2 в строке s1                                               }
{ StartPos определяет начальную позицию поиска в строке s1                  }
{ Выдает позицию первого символа искомой строки или 0, если не найдена      }
Function IndexStr ( s1 : string;  s2 : string;  StartPos : byte ) : integer;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Проверка входимости символов строки s2 в строку s1                        }
{ Key = Present    ─ требуется определить позицию первого символа s2,       }
{                    присутствующего также и в s1                           }
{     = NotPresent ─ требуется определить позицию первого символа s2,       }
{                    отсутствующего в s1                                    }
{ StartPos определяет номер позиции символа в s2, начиная с которого        }
{          символы это строки разыскиваются в s1                            }
{ Выдает позицию первого символа, присутствующего ( Present ) или           }
{ отсутствующего ( NotPresent ) в строке, или 0, если все символы           }
{ отсутствуют ( присутствуют )                                              }
Function VerifyStr ( s1 : string;  s2 : string;
                     Key : integer;  StartPos : byte ) : integer;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Перекрытие строк символов s1 строкой s2                                   }
{ StartPos определяет позицию символа строки s1, начиная с которого она     }
{ будет перекрываться строкой s2                                            }
{ Len определяет длину перекрывающей строки s2                              }
Function OverStr ( s1 : string;  s2 : string;  StartPos : byte;
                   Len : byte;  FillChr : char ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Замена указанных символов строки                                          }
{ Каждая строка s2, входящая в s1, заменяется на строку s3                  }
{ Поиск начинается с позиции StartPos                                       }
Function ReplStr ( s1 : string;  s2 : string;
                   s3 : string;  StartPos : byte ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Реверсирование строки                                                     }
Function ReverseStr ( s : string ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Определение количества слов в строке и извлечение слова из строки         }
{*********************************************************}
{*                  TPSTRING.PAS 5.05                    *}
{*        Copyright (c) TurboPower Software 1987.        *}
{* Portions copyright (c) Sunny Hill Software 1985, 1986 *}
{*     and used under license to TurboPower Software     *}
{*                 All rights reserved.                  *}
{*********************************************************}
{--------------- Word manipulation -------------------------------}

function WordCount(S : string; WordDelims : CharSet) : Byte;
  {-Given a set of word delimiters, return number of words in S}

function ExtractWord(N : Byte; S : string; WordDelims : CharSet) : string;
  {-Given a set of word delimiters, return the N'th word in S}
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Определение длины слова                                                   }
function WordLength ( n : byte;  s : string;  WordDelims : CharSet ) : integer;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Определение позиции первого символа указанного слова в строке             }
Function WordIndex ( n : byte;  s : string;  WordDelims : CharSet ) : integer;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Извлечение указанного количества слов из строки                           }
Function SubWords ( StartWord : byte;  NumWords : byte;
                   s : string;  WordDelims : CharSet ) : string;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Преобразование значения типа Byte в значение типа Char                    }
function ByteToChar ( B : Byte ) : Char;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
{ Преобразование значения типа Char в значение типа Byte                    }
function CharToByte ( C : Char ) : Byte;
{ ───────────────────────────────────────────────────────────────────────── }

implementation

{ ───────────────────────────────────────────────────────────────────────── }
Function Trim ( s : string;  Key : integer;  DelChr : CharSet ) : string;

var
    string1 : string;
    SLen1 : byte absolute s;

begin
    string1:=s;
    case Key of
       Leading  : while string1 [1] IN DelChr do  Delete (string1, 1, 1);

       Trailing : while string1 [SLen1] IN DelChr do begin
                      Delete (string1, SLen1, 1); Dec (SLen1)
                                                     end;

       Both     : begin
                      while string1 [SLen1] IN DelChr do begin
                          Delete (string1, SLen1, 1); Dec (SLen1)
                                                         end;
                      while string1 [1] IN DelChr do  Delete (string1, 1, 1);
                  end;
    end;
    Trim:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function HighLow ( n : byte;  Key : integer ) : string;

var
    byte1 : byte;
    string1  : string;

begin
  case Key of
    LowStr  :   for byte1:=1 to n do
                         string1 [byte1]:=Chr(0);
    HighStr :   for byte1:=1 to n do
                         string1 [byte1]:=Chr($FF);
  end;
  HighLow:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function RangeStr ( StSimbol : char;  EndSimbol : char ) : string;

var
    string1 : string;
    int1 : integer;

begin
  string1:='';
  if Ord (StSimbol) <= Ord (EndSimbol) then
              for int1:=Ord (StSimbol)  to  Ord (EndSimbol)  do
                      string1:=Concat (string1, Chr (int1) )
                                       else begin
              for int1:=Ord (StSimbol)  to  255  do
                      string1:=Concat (string1, Chr (int1) );
              for int1:=0  to  Ord (EndSimbol)  do
                      string1:=Concat (string1, Chr (int1) );
                                            end;
  RangeStr:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function Copies ( s : string;  NumCopies : byte ) : string;

var
    byte1 : byte;
    string1 : string;

begin
  string1:='';
  for byte1:=1 to NumCopies do
        string1:=Concat ( s, string1 );
  Copies:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function LeftRight ( s : string;  Len : byte;
                     FillChr : char;  Key : integer ) : string;

var
    SLen1 : byte absolute s;
    string1 : string;

begin
  case Key of
    Left  : begin
              if SLen1 <= Len then
                          string1:=Concat (s, Copies (FillChr, Len-SLen1))
                             else
                          string1:=Copy (s, 1, Len);
            end;
    Right : begin
              if SLen1 <= Len then
                          string1:=Concat (Copies (FillChr, Len-SLen1), s)
                             else
                          string1:=Copy (s, SLen1-Len+1, Len);
            end;
  end;
  LeftRight:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function Abbrev ( s : string;  AbbrStr : string;  AbbrLen : byte ) : boolean;

var
    string1 : string;

begin
  string1:=LeftRight (AbbrStr, AbbrLen, ' ', Left);
  if Copy (s, 1, AbbrLen)=string1 then  Abbrev:=True  else  Abbrev:=False;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function Center ( s : string;  Len : byte;  FillChr : char ) : string;

var
    SLen1 : byte absolute s;
    int1 : integer;
    byte1, byte2 : byte;
    string1 : string;

begin
  byte1:=Abs (SLen1-Len);
  if Odd (byte1) then begin
               byte1:=byte1 div 2; byte2:=byte1+1;
                      end
                 else begin
               byte1:=byte1 div 2; byte2:=byte1;
                      end;
  if SLen1 <= Len then
     string1:=Concat ( Copies (FillChr, byte1), s, Copies (FillChr, byte2) )
                 else begin
     string1:=LeftRight ( s, Len+byte2, ' ', Right);
     string1:=LeftRight ( string1, Len, ' ', Left);
                      end;
  Center:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function StrCmp ( s1 : string;  s2 : string;  FillChr : char ) : integer;

var
    SLen1 : byte absolute s1;
    SLen2 : byte absolute s2;
    int1, int2 : integer;
    byte1 : byte;
    string1, string2 : string;
    
begin
  if SLen1 <= SLen2 then begin
            string1:=LeftRight ( s1, SLen2, FillChr, Left );
            string2:=s2;
                         end
                    else begin
            string1:=s1;
            string2:=LeftRight ( s2, SLen1, FillChr, Left )
                                     end;

  int1:= Length (string1); byte1:=0; int2:=1;
  while ( int2 <= int1 ) AND ( byte1=0 ) do
   begin
     if string1 [int2] <> string2 [int2] then byte1:=int2;
     Inc (int2);
   end;
   StrCmp:=byte1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function IndexStr ( s1 : string;  s2 : string;  StartPos : byte ) : integer;

var
    SLen1 : byte absolute s1;
    SLen2 : byte absolute s2;
    int1, int2 : integer;
    string1 : string;

begin
  int1:=StartPos;
  if SLen1 < SLen2 then begin  IndexStr:=-1; Exit  end;
  if (StartPos > SLen1) OR (StartPos = 0 ) then begin IndexStr:=-2; Exit end;
  while SLen1 >= (SLen2+int1-1) do
   begin
     string1:= Copy ( s1, int1, SLen2 );
     int2:=StrCmp ( string1, s2, ' ' );
     if int2=0 then begin  IndexStr:=int1; Exit  end
               else Inc (int1);
   end;
   IndexStr:=0;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function VerifyStr ( s1 : string;  s2 : string;
                     Key : integer;  StartPos : byte ) : integer;

var
    SLen1 : byte absolute s1;
    SLen2 : byte absolute s2;
    int1 : integer;
    set1 : CharSet;

begin
  if (StartPos > SLen2) OR (StartPos = 0) then begin VerifyStr:=-1; Exit end;
  set1:=[]; for int1:=1 to SLen1 do set1:=set1+[ s1 [int1] ];
  case Key of
    Present    : begin
                   for int1:=StartPos to SLen2 do
                         if  s2 [int1] IN set1 then begin
                                 VerifyStr:=int1; exit;
                                                    end;
                 end;
    NotPresent : begin
                   for int1:=StartPos to SLen2 do
                         if NOT ( s2 [int1] IN set1 ) then begin
                                 VerifyStr:=int1; exit;
                                                           end;
                 end;
  end;
  VerifyStr:=0;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function UpLowStr ( s : string;  Key : integer ) : string;

var
    SLen1 : byte absolute s;
    int1 : integer;
    string1 : string;

begin
  case Key of
    Lower : for int1:=1 to SLen1 do
                case s [int1] of
                  'A'..'Z',
                  'А'..'П' : string1 [int1]:=Chr ( Ord (s [int1])+32 );
                  'Р'..'Я' : string1 [int1]:=Chr ( Ord (s [int1])+80 );
                       'Ё' : string1 [int1]:='ё';
                end;
    Upper : for int1:=1 to SLen1 do
                case s [int1] of
                  'a'..'z' : string1 [int1]:=UpCase (s [int1]);
                  'а'..'п' : string1 [int1]:=Chr ( Ord (s [int1])-32 );
                  'р'..'я' : string1 [int1]:=Chr ( Ord (s [int1])-80 );
                       'ё' : string1 [int1]:='Ё';
                end;
  end;
  UpLowStr:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function OverStr ( s1 : string;  s2 : string;  StartPos : byte;
                   Len : byte;  FillChr : char ) : string;
var
    SLen1 : byte absolute s1;
    int1, int2 : integer;
    string1, string2, string3 : string;
    String1Len : byte absolute string1;

begin
  string1:=s1;  string2:=LeftRight ( s2, Len, FillChr, Left );  string3:='';
  if StartPos-1 > SLen1 then
                string1:=LeftRight ( s1, StartPos-1, FillChr, Left );

  if String1Len >= StartPos+Len-1 then int2:=String1Len
                                  else int2:=StartPos+Len-1;
  for int1:= 1 to int2 do
     if int1 < StartPos then
                  Insert ( string1 [int1], string3, int1 )
                        else
     if int1 IN [StartPos..StartPos+Len-1] then
                  Insert ( string2 [int1-StartPos+1], string3, int1 )
                        else
     if int1 >= StartPos+Len then
                  Insert ( string1 [int1], string3, int1 );

  OverStr:=string3;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function ReplStr ( s1 : string;  s2 : string;
                   s3 : string;  StartPos : byte ) : string;

var
    SLen2 : byte absolute s2;
    string1 : string;
    int1, int2 : integer;

begin
  string1:=s1;
  while True do begin
     int1:= IndexStr ( string1, s2, StartPos );
     if int1 <= 0 then begin ReplStr:=string1; Exit end;
     Delete ( string1, int1, SLen2 );  Insert ( s3, string1, int1 );
                end;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function ReverseStr ( s : string ) : string;

var
    SLen : byte absolute s;
    string1 : string;
    int1 : integer;

begin
  string1:='';
  for int1:=1 to SLen do
            Insert ( s [SLen-int1+1], string1, int1 );
  ReverseStr:=string1;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
  function WordCount(S : string; WordDelims : CharSet) : Byte;
    {-Given a set of word delimiters, return number of words in S}
  var
    I, Count : Byte;
    SLen : Byte absolute S;
  begin
    Count := 0;
    I := 1;

    while I <= SLen do begin
      {skip over delimiters}
      while (I <= SLen) and (S[I] in WordDelims) do
        Inc(I);

      {if we're not beyond end of S, we're at the start of a word}
      if I <= SLen then
        Inc(Count);

      {find the end of the current word}
      while (I <= SLen) and not(S[I] in WordDelims) do
        Inc(I);
    end;

    WordCount := Count;
  end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
  function ExtractWord(N : Byte; S : string; WordDelims : CharSet) : string;
    {-Given a set of word delimiters, return the N'th word in S}
  var
    I, Count, Len : Byte;
    SLen : Byte absolute S;
  begin
    Count := 0;
    I := 1;
    Len := 0;
    ExtractWord[0] := #0;

    while (I <= SLen) and (Count <> N) do begin
      {skip over delimiters}
      while (I <= SLen) and (S[I] in WordDelims) do
        Inc(I);

      {if we're not beyond end of S, we're at the start of a word}
      if I <= SLen then
        Inc(Count);

      {find the end of the current word}
      while (I <= SLen) and not(S[I] in WordDelims) do begin
        {if this is the N'th word, add the I'th character to Tmp}
        if Count = N then begin
          Inc(Len);
          ExtractWord[0] := Char(Len);
          ExtractWord[Len] := S[I];
        end;

        Inc(I);
      end;
    end;
  end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
function WordLength ( n : byte;  s : string;  WordDelims : CharSet ) : integer;
begin
  WordLength := Length ( ExtractWord ( n, s, WordDelims ) );
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function WordIndex ( n : byte;  s : string;  WordDelims : CharSet ) : integer;

var
    Count : Byte;
    SLen : Byte absolute s;
    int1 : integer;

begin
    Count := 0;
    int1 := 1;

    while (int1 <= SLen) AND (Count<>n) do begin
      while (int1 <= SLen) and (s [int1] in WordDelims) do
        Inc (int1);

      if int1 <= SLen then   Inc (Count);
      
      if Count = n then begin  WordIndex:=int1; Exit;  end;

      while (int1 <= SLen) and not(s [int1] in WordDelims) do
        Inc (int1);
                                           end;

    WordIndex:=0;
  end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
Function SubWords ( StartWord : byte;  NumWords : byte;
                   s : string;  WordDelims : CharSet ) : string;

var
    int1, int2 : integer;

begin
  SubWords:='';

  { Позиция первого слова, выход если слово не найдено }  
  int1:=WordIndex ( StartWord, s, WordDelims );  
  if int1=0 then Exit;

  { Позиция последнего слова; если слово не найдено, берется конец строки   }  
  int2:=WordIndex ( StartWord+NumWords, s, WordDelims );
  if int2=0 then int2:=Length (s)+1;

  { Извлечение заданного количества слов (или до конца строки)              }
  SubWords:=Copy ( s, int1, int2-int1 );
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
function ByteToChar ( B : Byte ) : Char;

var
    C : Char absolute B;

begin
  ByteToChar := C;
end;
{ ───────────────────────────────────────────────────────────────────────── }

{ ───────────────────────────────────────────────────────────────────────── }
function CharToByte ( C : Char ) : Byte;

var
    B : Byte absolute C;

begin
  CharToByte := B;
end;
{ ───────────────────────────────────────────────────────────────────────── }

end.
