{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Extended Strings Unit                           }
{       Version 1.1                                     }
{                                                       }
{       Copyright (c) 1993 by RDA Software              }
{                                                       }
{*******************************************************}

Unit  Strings_;

{$I-,S-,R-}

     INTERFACE


Procedure StrToLower(Var Str: String);
{ Процедура преобразует строку Str к нижнему регистру. }

Procedure StrToUpper(Var Str: String);
{ Процедура преобразует строку Str к верхнему регистру. }

Function  StrChr(Str: String; Sim: Char): Boolean;
{ Функция проверяет вхождение символа Chr в строку Str. }

Function  StrIChr(Str: String; Sim: Char): Boolean;
{ Функция проверяет вхождение символа Chr в строку Str,
  считая при этом буквы верхнего и нижнего регистров
  эквивалентными. }

Function  StrCmp(Str1, Str2: String): Integer;
{ Функция возвращает результат сравнения двух строк:
    -1, если Str1 < Str2;
     0, если Str1 = Str2;
     1, если Str1 > Str2. }

Function  StrICmp(Str1, Str2: String): Integer;
{ Функция возвращает результат сравнения двух строк,
  считая буквы верхнего и нижнего регистров эквивалентными:
    -1, если Str1 < Str2;
     0, если Str1 = Str2;
     1, если Str1 > Str2. }

Function  StrNCmp(Str1, Str2: String; N: Byte): Integer;
{ Функция возвращает результат сравнения двух строк,
  сравнивая не более, чем первые N символов:
    -1, если Str1 < Str2;
     0, если Str1 = Str2;
     1, если Str1 > Str2. }

Procedure  StrSet(Var Str: String; Sim: Char);
{ Процедура устанавливает все символы строки в значение,
  задаваемое параметром Sim.}

Procedure StrNSet(Var Str: String; Sim: Char; N: Byte);
{ Процедура устанавливает N символов строки в значение,
  задаваемое параметром Sim. Длина строки устанавливается в N. }

Function  StrLen(Str: String): Byte;
Inline($5F/$07/$26/$8A/$05);
{ Возвращает длину строки Str. }

Function  Contains(Str1, Str2: String): Byte;
{ Функция возвращает номер позиции первого символа из строки Str1,
  который содержится в строке Str2 или 0, если ни один символ из Str1
  не найден в Str2. }

Procedure DelRightSpace(Var Str: String);
{ Процедура удаляет завершающие пробелы в строке Str. }

Procedure DelLeftSpace(Var Str: String);
{ Процедура удаляет лидирующие пробелы в строке Str. }


     IMPLEMENTATION

{$L Strings}

Procedure StrToLower; External;

Procedure StrToUpper; External;

Function  StrChr; External;

Function  StrIChr; External;

Function  StrCmp; External;

Function  StrICmp; External;

Function  StrNCmp; External;

Procedure StrSet; External;

Procedure StrNSet; External;

Function  Contains; External;

Procedure DelRightSpace; External;

Procedure DelLeftSpace; External;

end.
