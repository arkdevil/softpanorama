{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Extended Unit                                   }
{       Version 1.0                                     }
{                                                       }
{       Copyright (c) 1993 by RDA Software              }
{                                                       }
{*******************************************************}

Unit  CType;

{$I-,S-,R-}

     INTERFACE

Function ToLower(Sim: Char): Char;
{ Функция преобразует символ Sim к нижнему регистру. }

Function ToUpper(Sim: Char): Char;
{ Функция преобразует символ Sim к верхнему регистру. }

Function  IsDigit(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является десятичной цифрой. }

Function  IsHexDigit(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является шестнадцатиричной цифрой. }

Function  IsLatChar(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой латинского алфавита. }

Function  IsRusChar(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой русского алфавита. }

Function  IsAlpha(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является русской или латинской буквой. }

Function  IsAlNum(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является русской
  или латинской буквой или цифрой. }

Function  IsAlfa(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является печатной буквой
  (символом с кодом в диапазоне 20h..7Fh). }

Function  IsLower(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой нижнего регистра. }

Function  IsUpper(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой верхнего регистра. }


     IMPLEMENTATION

{$L CType.obj}

Function ToLower; External;

Function ToUpper; External;

Function IsDigit; External;

Function IsHexDigit; External;

Function IsLatChar; External;

Function IsRusChar; External;

Function IsAlpha; External;

Function IsAlNum; External;

Function IsAlfa; External;

Function IsLower; External;

Function IsUpper; External;

end.
