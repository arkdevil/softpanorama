{*******************************************************}
{                                                       }
{       Turbo Pascal 7.0                                }
{       Fast Vision 1.1                                 }
{       String Handling Unit                            }
{                                                       }
{       Copyright (C) 1990,92 Borland International     }
{       Copyright (C) 1993, 94 by RDA Software          }
{                                                       }
{*******************************************************}

unit Strings;

{$S-}

      INTERFACE

{ StrLen returns the number of characters in Str, not counting  }
{ the null terminator.                                          }
function StrLen(Str: PChar): Word;

{ StrEnd returns a pointer to the null character that           }
{ terminates Str.                                               }
function StrEnd(Str: PChar): PChar;

{ StrMove copies exactly Count characters from Source to Dest   }
{ and returns Dest. Source and Dest may overlap.                }
function StrMove(Dest, Source: PChar; Count: Word): PChar;

{ StrCopy copies Source to Dest and returns Dest.               }
function StrCopy(Dest, Source: PChar): PChar;

{ StrECopy copies Source to Dest and returns StrEnd(Dest).      }
function StrECopy(Dest, Source: PChar): PChar;

{ StrLCopy copies at most MaxLen characters from Source to Dest }
{ and returns Dest.                                             }
function StrLCopy(Dest, Source: PChar; MaxLen: Word): PChar;

{ StrPCopy copies the Pascal style string Source into Dest and  }
{ returns Dest.                                                 }
function StrPCopy(Dest: PChar; Source: String): PChar;

{ StrCat appends a copy of Source to the end of Dest and        }
{ returns Dest.                                                 }
function StrCat(Dest, Source: PChar): PChar;

{ StrLCat appends at most MaxLen - StrLen(Dest) characters from }
{ Source to the end of Dest, and returns Dest.                  }
function StrLCat(Dest, Source: PChar; MaxLen: Word): PChar;

{ StrComp compares Str1 to Str2. The return value is less than  }
{ 0 if Str1 < Str2, 0 if Str1 = Str2, or greater than 0 if      }
{ Str1 > Str2.                                                  }
function StrComp(Str1, Str2: PChar): Integer;

{ StrIComp compares Str1 to Str2, without case sensitivity. The }
{ return value is the same as StrComp.                          }
function StrIComp(Str1, Str2: PChar): Integer;

{ StrLComp compares Str1 to Str2, for a maximum length of       }
{ MaxLen characters. The return value is the same as StrComp.   }
function StrLComp(Str1, Str2: PChar; MaxLen: Word): Integer;

{ StrLIComp compares Str1 to Str2, for a maximum length of      }
{ MaxLen characters, without case sensitivity. The return value }
{ is the same as StrComp.                                       }
function StrLIComp(Str1, Str2: PChar; MaxLen: Word): Integer;

{ StrScan returns a pointer to the first occurrence of Chr in   }
{ Str. If Chr does not occur in Str, StrScan returns NIL. The   }
{ null terminator is considered to be part of the string.       }
function StrScan(Str: PChar; Chr: Char): PChar;

{ StrRScan returns a pointer to the last occurrence of Chr in   }
{ Str. If Chr does not occur in Str, StrRScan returns NIL. The  }
{ null terminator is considered to be part of the string.       }
function StrRScan(Str: PChar; Chr: Char): PChar;

{ StrPos returns a pointer to the first occurrence of Str2 in   }
{ Str1. If Str2 does not occur in Str1, StrPos returns NIL.     }
function StrPos(Str1, Str2: PChar): PChar;

{ StrUpper converts Str to upper case and returns Str.          }
function StrUpper(Str: PChar): PChar;

{ StrLower converts Str to lower case and returns Str.          }
function StrLower(Str: PChar): PChar;

{ StrPas converts Str to a Pascal style string.                 }
function StrPas(Str: PChar): String;

{ StrNew allocates a copy of Str on the heap. If Str is NIL or  }
{ points to an empty string, StrNew returns NIL and doesn't     }
{ allocate any heap space. Otherwise, StrNew makes a duplicate  }
{ of Str, obtaining space with a call to the GetMem standard    }
{ procedure, and returns a pointer to the duplicated string.    }
{ The allocated space is StrLen(Str) + 1 bytes long.            }
function StrNew(Str: PChar): PChar;

{ StrDispose disposes a string that was previously allocated    }
{ with StrNew. If Str is NIL, StrDispose does nothing.          }
procedure StrDispose(Str: PChar);


{ ***************************************************
   Процедуры и функции для работы с областями памяти
  *************************************************** }

function MemCmp(var Buf1, Buf2; Length: Word): Boolean;


{ *********************************************************
   Процедуры и функции для работы со стандартными строками
  ********************************************************* }

function StrLength(Str: String): Byte;
inline($5F/$07/$26/$8A/$05);
{ Возвращает длину строки Str }

function StrToLower(Str: String): String;
{ Функция преобразует строку Str к нижнему регистру }

function StrToUpper(Str: String): String;
{ Функция преобразует строку Str к верхнему регистру }

function StrChr(Str: String; Sim: Char): Boolean;
{ Функция проверяет вхождение символа Chr в строку Str }

function StrIChr(Str: String; Sim: Char): Boolean;
{ Функция проверяет вхождение символа Chr в строку Str,
  считая при этом буквы верхнего и нижнего регистров
  эквивалентными }

function StrCmp(Str1, Str2: String): Integer;
{ Функция возвращает результат сравнения двух строк:
    -1, если Str1 < Str2
     0, если Str1 = Str2
     1, если Str1 > Str2
  Возвращаемый результат как раз подходит для метода Compare
  в сортированной коллекции }

function StrICmp(Str1, Str2: String): Integer;
{ Функция возвращает результат сравнения двух строк,
  считая буквы верхнего и нижнего регистров эквивалентными:
    -1, если Str1 < Str2
     0, если Str1 = Str2
     1, если Str1 > Str2 }

function StrNCmp(Str1, Str2: String; Count: Byte): Integer;
{ Функция возвращает результат сравнения двух строк,
  сравнивая не более, чем первые N символов:
    -1, если Str1 < Str2
     0, если Str1 = Str2
     1, если Str1 > Str2 }

procedure StrSet(var Str: String; Sim: Char);
{ Процедура устанавливает все символы строки в значение,
  задаваемое параметром Sim }

procedure StrNSet(var Str: String; Sim: Char; N: Byte);
{ Процедура устанавливает N символов строки в значение,
  задаваемое параметром Sim. Длина строки устанавливается в N }

function Contains(Str1, Str2: String): Boolean;
{ Функция возвращает True, если хотя бы один символ из Str2
  содержится в строке Str1 }

procedure DelRightSpace(var Str: String);
{ Процедура удаляет завершающие пробелы в строке Str }

procedure DelLeftSpace(var Str: String);
{ Процедура удаляет лидирующие пробелы в строке Str }

procedure DelREPChars(var Str: String; Sim: Char);
{ Процедура удаляет повторяющиеся символы Sim в строке Str }

function StrChrNum(Str: String; I: Word; Sim: Char): Byte;
{ Функция возвращает номер позиции I-го символа Sim в строке Str }

function StrChrCount(Str: String; Sim: Char): Byte;
{ Функция возвращает число символов Sim в строке Str }

function ReplaceChar(Str: String; OldSim, NewSim: Char): String;
{ Функция заменяет все символы OldSim на NewSim в строке Str }

procedure ReplaceStr(var Str: String; FindStr, RepStr: String);
{ Процедура заменяет все строки FindStr на RepStr в строке Str }

function TwoDigit(X: Word): String;
{ Функция преобразует число X из диапазона 0..99 в строку из 2 цифр,
  проверка принадлежности X диапазону не производится. Удобно для
  отображения даты/времени и т.п. }


{ ********************************
   Функции для работы с символами
  ******************************** }

function ToLower(Sim: Char): Char;
{ Функция преобразует символ Sim к нижнему регистру }

function ToUpper(Sim: Char): Char;
{ Функция преобразует символ Sim к верхнему регистру }

function IsDigit(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является десятичной цифрой }

function IsHexDigit(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является шестнадцатиричной цифрой }

function IsLatChar(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой латинского алфавита }

function IsRusChar(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой русского алфавита }

function IsAlpha(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является русской или латинской буквой }

function IsAlNum(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является русской
  или латинской буквой или цифрой }

function IsAlfa(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является печатной буквой
  (символом с кодом в диапазоне 20h..7Fh) }

function IsLower(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой нижнего регистра }

function IsUpper(Sim: Char): Boolean;
{ Функция возвращает TRUE, если Sim является буквой верхнего регистра }


      IMPLEMENTATION

{$W-}

{$L CType}

function StrLen(Str: PChar): Word; assembler;
asm
        CLD
        LES     DI, Str
        MOV     CX, 0FFFFH
        XOR     AX, AX
        REPNE   SCASB
        MOV     AX, 0FFFEH
        SUB     AX, CX
end;

function StrEnd(Str: PChar): PChar; assembler;
asm
        CLD
        LES     DI, Str
        MOV     CX, 0FFFFH
        XOR     AX, AX
        REPNE   SCASB
        MOV     AX, DI
        MOV     DX, ES
        DEC     AX
end;

function StrMove(Dest, Source: PChar; Count: Word): PChar; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI, Source
        LES     DI, Dest
        MOV     AX, DI
        MOV     DX, ES
        MOV     CX, Count
        CMP     SI, DI
        JAE     @@1
        STD
        ADD     SI, CX
        ADD     DI, CX
        DEC     SI
        DEC     DI
@@1:    REP     MOVSB
        CLD
        POP     DS
end;

function StrCopy(Dest, Source: PChar): PChar; assembler;
asm
        PUSH    DS
        CLD
        LES     DI, Source
        MOV     CX, 0FFFFH
        XOR     AX, AX
        REPNE   SCASB
        NOT     CX
        LDS     SI, Source
        LES     DI, Dest
        MOV     AX, DI
        MOV     DX, ES
        REP     MOVSB
        POP     DS
end;

function StrECopy(Dest, Source: PChar): PChar; assembler;
asm
        PUSH    DS
        CLD
        LES     DI, Source
        MOV     CX, 0FFFFH
        XOR     AX, AX
        REPNE   SCASB
        NOT     CX
        LDS     SI, Source
        LES     DI, Dest
        REP     MOVSB
        MOV     AX, DI
        MOV     DX, ES
        DEC     AX
        POP     DS
end;

function StrLCopy(Dest, Source: PChar; MaxLen: Word): PChar; assembler;
asm
        PUSH    DS
        CLD
        LES     DI, Source
        MOV     CX, MaxLen
        MOV     BX, CX
        XOR     AX, AX
        REPNE   SCASB
        SUB     BX, CX
        MOV     CX, BX
        LDS     SI, Source
        LES     DI, Dest
        MOV     BX, DI
        MOV     DX, ES
        REP     MOVSB
        STOSB
        XCHG    AX, BX
        POP     DS
end;

function StrPCopy(Dest: PChar; Source: String): PChar; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI, Source
        LES     DI, Dest
        MOV     BX, DI
        MOV     DX, ES
        XOR     AX, AX
        LODSB
        XCHG    AX, CX
        REP     MOVSB
        XOR     AL, AL
        STOSB
        XCHG    AX, BX
        POP     DS
end;

function StrCat(Dest, Source: PChar): PChar; assembler;
asm
        PUSH    Dest.Word[2]
        PUSH    Dest.Word[0]
        PUSH    CS
        CALL    NEAR PTR StrEnd
        PUSH    DX
        PUSH    AX
        PUSH    Source.Word[2]
        PUSH    Source.Word[0]
        PUSH    CS
        CALL    NEAR PTR StrCopy
        MOV     AX, Dest.Word[0]
        MOV     DX, Dest.Word[2]
end;

function StrLCat(Dest, Source: PChar; MaxLen: Word): PChar; assembler;
asm
        PUSH    Dest.Word[2]
        PUSH    Dest.Word[0]
        PUSH    CS
        CALL    NEAR PTR StrEnd
        MOV     CX, Dest.Word[0]
        ADD     CX, MaxLen
        SUB     CX, AX
        JBE     @@1
        PUSH    DX
        PUSH    AX
        PUSH    Source.Word[2]
        PUSH    Source.Word[0]
        PUSH    CX
        PUSH    CS
        CALL    NEAR PTR StrLCopy
@@1:    MOV     AX, Dest.Word[0]
        MOV     DX, Dest.Word[2]
end;

function StrComp(Str1, Str2: PChar): Integer; assembler;
asm
        PUSH    DS
        CLD
        LES     DI, Str2
        MOV     SI, DI
        MOV     CX, 0FFFFH
        XOR     AX, AX
        CWD
        REPNE   SCASB
        NOT     CX
        MOV     DI, SI
        LDS     SI, Str1
        REPE    CMPSB
        MOV     AL, DS:[SI-1]
        MOV     DL, ES:[DI-1]
        SUB     AX, DX
        POP     DS
end;

function StrIComp(Str1, Str2: PChar): Integer; assembler;
asm
        PUSH    DS
        CLD
        LES     DI, Str2
        MOV     SI, DI
        MOV     CX, 0FFFFH
        XOR     AX, AX
        CWD
        REPNE   SCASB
        NOT     CX
        MOV     DI, SI
        LDS     SI, Str1
@@1:    REPE    CMPSB
        JE      @@4
        MOV     AL, DS:[SI-1]
        CMP     AL, 'a'
        JB      @@2
        CMP     AL, 'z'
        JA      @@2
        SUB     AL, 20H
@@2:    MOV     DL, ES:[DI-1]
        CMP     DL, 'a'
        JB      @@3
        CMP     DL, 'z'
        JA      @@3
        SUB     DL, 20H
@@3:    SUB     AX, DX
        JE      @@1
@@4:    POP     DS
end;

function StrLComp(Str1, Str2: PChar; MaxLen: Word): Integer; assembler;
asm
        PUSH    DS
        CLD
        LES     DI,Str2
        MOV     SI,DI
        MOV     AX,MaxLen
        MOV     CX,AX
        JCXZ    @@1
        XCHG    AX,BX
        XOR     AX,AX
        CWD
        REPNE   SCASB
        SUB     BX,CX
        MOV     CX,BX
        MOV     DI,SI
        LDS     SI,Str1
        REPE    CMPSB
        MOV     AL,DS:[SI-1]
        MOV     DL,ES:[DI-1]
        SUB     AX,DX
@@1:    POP     DS
end;

function StrLIComp(Str1, Str2: PChar; MaxLen: Word): Integer; assembler;
asm
        PUSH    DS
        CLD
        LES     DI,Str2
        MOV     SI,DI
        MOV     AX,MaxLen
        MOV     CX,AX
        JCXZ    @@4
        XCHG    AX,BX
        XOR     AX,AX
        CWD
        REPNE   SCASB
        SUB     BX,CX
        MOV     CX,BX
        MOV     DI,SI
        LDS     SI,Str1
@@1:    REPE    CMPSB
        JE      @@4
        MOV     AL,DS:[SI-1]
        CMP     AL,'a'
        JB      @@2
        CMP     AL,'z'
        JA      @@2
        SUB     AL,20H
@@2:    MOV     DL,ES:[DI-1]
        CMP     DL,'a'
        JB      @@3
        CMP     DL,'z'
        JA      @@3
        SUB     DL,20H
@@3:    SUB     AX,DX
        JE      @@1
@@4:    POP     DS
end;

function StrScan(Str: PChar; Chr: Char): PChar; assembler;
asm
        CLD
        LES     DI,Str
        MOV     SI,DI
        MOV     CX,0FFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     CX
        MOV     DI,SI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     AX,0
        CWD
        JNE     @@1
        MOV     AX,DI
        MOV     DX,ES
        DEC     AX
@@1:
end;

function StrRScan(Str: PChar; Chr: Char): PChar; assembler;
asm
        CLD
        LES     DI,Str
        MOV     CX,0FFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     CX
        STD
        DEC     DI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     AX,0
        CWD
        JNE     @@1
        MOV     AX,DI
        MOV     DX,ES
        INC     AX
@@1:    CLD
end;

function StrPos(Str1, Str2: PChar): PChar; assembler;
asm
        PUSH    DS
        CLD
        XOR     AL,AL
        LES     DI,Str2
        MOV     CX,0FFFFH
        REPNE   SCASB
        NOT     CX
        DEC     CX
        JE      @@2
        MOV     DX,CX
        MOV     BX,ES
        MOV     DS,BX
        LES     DI,Str1
        MOV     BX,DI
        MOV     CX,0FFFFH
        REPNE   SCASB
        NOT     CX
        SUB     CX,DX
        JBE     @@2
        MOV     DI,BX
@@1:    MOV     SI,Str2.Word[0]
        LODSB
        REPNE   SCASB
        JNE     @@2
        MOV     AX,CX
        MOV     BX,DI
        MOV     CX,DX
        DEC     CX
        REPE    CMPSB
        MOV     CX,AX
        MOV     DI,BX
        JNE     @@1
        MOV     AX,DI
        MOV     DX,ES
        DEC     AX
        JMP     @@3
@@2:    XOR     AX,AX
        MOV     DX,AX
@@3:    POP     DS
end;

function StrUpper(Str: PChar): PChar; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI,Str
        MOV     BX,SI
        MOV     DX,DS
@@1:    LODSB
        OR      AL,AL
        JE      @@2
        CMP     AL,'a'
        JB      @@1
        CMP     AL,'z'
        JA      @@1
        SUB     AL,20H
        MOV     [SI-1],AL
        JMP     @@1
@@2:    XCHG    AX,BX
        POP     DS
end;

function StrLower(Str: PChar): PChar; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI,Str
        MOV     BX,SI
        MOV     DX,DS
@@1:    LODSB
        OR      AL,AL
        JE      @@2
        CMP     AL,'A'
        JB      @@1
        CMP     AL,'Z'
        JA      @@1
        ADD     AL,20H
        MOV     [SI-1],AL
        JMP     @@1
@@2:    XCHG    AX,BX
        POP     DS
end;

function StrPas(Str: PChar): String; assembler;
asm
        PUSH    DS
        CLD
        LES     DI,Str
        MOV     CX,0FFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     CX
        DEC     CX
        LDS     SI,Str
        LES     DI,@Result
        MOV     AL,CL
        STOSB
        REP     MOVSB
        POP     DS
end;

{$W+}

function StrNew(Str: PChar): PChar;
var
  L: Word;
  P: PChar;
begin
  StrNew := nil;
  if (Str <> nil) and (Str^ <> #0) then begin
    L := StrLen(Str) + 1;
    GetMem(P, L);
    if P <> nil then StrNew := StrMove(P, Str, L);
  end;
end;

procedure StrDispose(Str: PChar);
begin
  if Str <> nil then FreeMem(Str, StrLen(Str) + 1);
end;


{ ***************************************************
   Процедуры и функции для работы с областями памяти
  *************************************************** }

function MemCmp(var Buf1, Buf2; Length: Word): Boolean; assembler;
asm
        MOV     DX, DS
        LES     DI, Buf1
        LDS     SI, Buf2
        MOV     CX, Length
        JCXZ    @@2
        REPE    CMPSB
        MOV     AL, False
        JNE     @@2
@@1:    MOV     AL, True
@@2:    MOV     DS, DX
end;


{ *********************************************************
   Процедуры и функции для работы со стандартными строками
  ********************************************************* }

function StrToLower(Str: String): String; assembler;
asm
        MOV     DX, DS
        CLD
        LDS     SI, Str
        LES     DI, @Result
        XOR     CX, CX
        LODSB
        STOSB
        MOV     CL, AL
        JCXZ    @@4
@@1:    LODSB
        CMP     AL, 'A'
        JB      @@3
        CMP     AL, 'Z'
        JBE     @@2
        CMP     AL, 'А'
        JB      @@3
        CMP     AL, 'П'
        JBE     @@2
        CMP     AL, 'Я'
        JA      @@3
        ADD     AL, 48
@@2:    ADD     AL, 32
@@3:    STOSB
        LOOP    @@1
@@4:    MOV     DS, DX
end;

function StrToUpper(Str: String): String; assembler;
asm
        MOV     DX, DS
        CLD
        LDS     SI, Str
        LES     DI, @Result
        XOR     CX, CX
        LODSB
        STOSB
        MOV     CL, AL
        JCXZ    @@4
@@1:    LODSB
        CMP     AL, 'a'
        JB      @@3
        CMP     AL, 'z'
        JBE     @@2
        CMP     AL, 'а'
        JB      @@3
        CMP     AL, 'п'
        JBE     @@2
        CMP     AL, 'р'
        JB      @@3
        CMP     AL, 'я'
        JA      @@3
        SUB     AL, 48
@@2:    SUB     AL, 32
@@3:    STOSB
        LOOP    @@1
@@4:    MOV     DS, DX
end;

function StrChr(Str: String; Sim: Char): Boolean; assembler;
asm
        LES     DI, Str
        MOV     AL, Sim
        XOR     CX, CX
        MOV     CL, ES:[DI]
        JCXZ    @@1
        INC     DI
        CLD
        REPNE   scasb
        MOV     AL, 1
        JE      @@1
        XOR     AX, AX
@@1:
end;

function StrIChr(Str: String; Sim: Char): Boolean; assembler;
asm
        MOV     DX, DS
        LDS     SI, Str
        MOV     AL, Sim
        CALL    @@5
        MOV     BL, AL
        CLD
        LODSB
        XOR     CX, CX
        MOV     CL, AL
        JCXZ    @@8
@@1:    LODSB
        CALL    @@5
        CMP     AL, BL
        JE      @@3
        LOOP    @@1
@@2:    XOR     AX, AX
        JMP     @@8
@@3:    MOV     AL, 1
        JMP     @@8
@@5:    CMP     AL, 'A'      { преобразование символа к DownCase }
        JB      @@6
        CMP     AL, 'Z'
        JBE     @@7
        CMP     AL, 'А'
        JB      @@6
        CMP     AL, 'П'
        JBE     @@7
        CMP     AL, 'Я'
        JA      @@6
        ADD     AL, 80
@@6:    RETN
@@7:    ADD     AL, 32
        RETN
@@8:    MOV     DS, DX
end;

function StrCmp(Str1, Str2: String): Integer; assembler;
asm
        MOV     DX, DS
        CLD
        LDS     SI, Str1
        LES     DI, Str2
        LODSB                { AL = StrLen(Str1) }
        MOV     AH, ES:[DI]  { AH = StrLen(Str2) }
        MOV     BL, AL       { BL = StrLen(Str1) }
        INC     DI
        XOR     CX, CX
        MOV     CL, AL
        CMP     AL, AH       { StrLen(Str1) > StrLen(Str2) ? }
        JBE     @@1          { менньше или равна - уходим }
        MOV     CL, AH
@@1:    JCXZ    @@2
        REPE    CMPSB        { сравниваем, пока равны }
        JNE     @@3
@@2:    CMP     BL, AH       { сравнить длины строк }
@@3:    MOV     AX, -1
        JB      @@4          { Str1 < Str2 ? }
        MOV     AX, 1
        JA      @@4          { Str1 > Str2 ? }
        XOR     AX, AX       { Str1 = Str2 }
@@4:    MOV     DS, DX
end;

function StrICmp(Str1, Str2: String): Integer; assembler;
asm
        MOV     DX, DS
        CLD
        LDS     SI, Str1
        LES     DI, Str2
        LODSB                { AL = StrLen(Str1) }
        MOV     AH, ES:[DI]  { AH = StrLen(Str2) }
        MOV     BX, AX
        INC     DI
        XOR     CX, CX
        MOV     CL, AL
        CMP     AL, AH       { StrLen(Str1) > StrLen(Str2) ? }
        JBE     @@1          { менньше или равна - уходим }
        MOV     CL, AH
@@1:    JCXZ    @@3
@@2:    MOV     AL, ES:[DI]  { читаем из Str2 }
        CALL    @@5          { преобразуем к DownCase }
        MOV     AH, AL
        LODSB                { читаем из Str1 }
        CALL    @@5          { преобразуем к DownCase }
        CMP     AL, AH
        JNE     @@4          { Str1 <> Str2 ? }
        INC     DI
        LOOP    @@2
@@3:    CMP     BL, BH       { сравнить длины строк }
@@4:    MOV     AX, -1       { Str1 < Str2 }
        JB      @@8
        MOV     AX, 1        { Str1 > Str2 }
        JA      @@8
        XOR     AX, AX       { Str1 = Str2 }
        JMP     @@8
@@5:    CMP     AL, 'A'      { преобразование символа к DownCase }
        JB      @@6
        CMP     AL, 'Z'
        JBE     @@7
        CMP     AL, 'А'
        JB      @@6
        CMP     AL, 'П'
        JBE     @@7
        CMP     AL, 'Я'
        JA      @@6
        ADD     AL, 80
@@6:    RETN
@@7:    ADD     AL, 32
        RETN
@@8:    MOV     DS, DX
end;

function StrNCmp(Str1, Str2: String; Count: Byte): Integer; assembler;
asm
        MOV     DX, DS
        CLD
        LDS     SI, Str1
        LES     DI, Str2
        MOV     BH, Count
        LODSB                { AL = StrLen(Str1) }
        CMP     AL, BH
        JBE     @@0
        MOV     AL, BH
@@0:    MOV     AH, ES:[DI]  { AH = StrLen(Str2) }
        CMP     AH, BH
        JBE     @@1
        MOV     AH, BH
@@1:    MOV     BL, AL       { BL = StrLen(Str1) }
        INC     DI
        XOR     CX, CX
        MOV     CL, AL
        CMP     AL, AH       { StrLen(Str1) > StrLen(Str2) ? }
        JBE     @@2          { менньше или равна - уходим }
        MOV     CL, AH
@@2:    JCXZ    @@3
        REPE    CMPSB        { сравниваем, пока равны }
        JNE     @@4
@@3:    CMP     BL, Count
        CMP     BL, AH       { сравнить длины строк }
@@4:    MOV     AX, -1
        JB      @@5          { Str1 < Str2 ? }
        MOV     AX, 1
        JA      @@5          { Str1 > Str2 ? }
        XOR     AX, AX       { Str1 = Str2 }
@@5:    MOV     DS, DX
end;

procedure StrSet(var Str: String; Sim: Char); assembler;
asm
        LES     DI, Str
        MOV     AL, Sim
        XOR     CX, CX
        MOV     CL, ES:[DI]
        JCXZ    @@1
        INC     DI
        CLD
        REP     STOSB
@@1:
end;

procedure StrNSet(var Str: String; Sim: Char; N: Byte); assembler;
asm
        LES     DI, Str
        MOV     AL, N
        CLD
        STOSB
        XOR     CX, CX
        MOV     CL, AL
        MOV     AL, Sim
        JCXZ    @@1
        REP     STOSB
@@1:
end;

function Contains(Str1, Str2: String): Boolean; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI,Str1
        LES     DI,Str2
        MOV     DX,DI
        XOR     AX,AX
        LODSB
        MOV     BX,AX
        OR      BX,BX
        JZ      @@2
        MOV     AL,ES:[DI]
        MOV     CX,AX
@@1:    PUSH    CX
        MOV     DI,DX
        LODSB
        REPNE   SCASB
        POP     CX
        JE      @@3
        DEC     BX
        JNZ     @@1
@@2:    XOR     AL,AL
        JMP     @@4
@@3:    MOV     AL,1
@@4:    POP     DS
end;

procedure DelRightSpace(var Str: String); assembler;
asm
        LES     DI, Str
        STD
        XOR     CX, CX
        MOV     CL, ES:[DI]
        JCXZ    @@2
        MOV     SI, DI
        ADD     DI, CX        { DI указывает на последний символ строки }
        MOV     AL, ' '
        REPE    SCASB
        JCXZ    @@1
        INC     CX
@@1:    MOV     ES:[SI], CL
@@2:
end;

procedure DelLeftSpace(var Str: String); assembler;
asm
        LES     DI, Str
        XOR     CX, CX
        MOV     CL, ES:[DI]
        JCXZ    @@2
        MOV     BX, DI
        INC     DI
        MOV     SI, DI
        MOV     AL, ' '
        CLD
        REPE    SCASB
        MOV     AL, CL
        JCXZ    @@1
        INC     AL
        INC     CX
        DEC     DI
        PUSH    DS
        PUSH    ES
        POP     DS
        XCHG    DI, SI
        REP     MOVSB
        POP     DS
@@1:    MOV     DI, BX
        STOSB
@@2:
end;

procedure DelREPChars(var Str: String; Sim: Char); assembler;
asm
        CLD
        PUSH    DS
        LES     DI, Str
        MOV     AL, Sim
        XOR     CX, CX
        MOV     CL, ES:[DI]
        MOV     BX, CX
        JCXZ    @@2
        INC     DI
@@1:    REPNE   SCASB
        JNE     @@2
        CMP     ES:[DI], AL
        JNE     @@1
        JCXZ    @@2
        MOV     DX, ES
        MOV     DS, DX
        MOV     SI, DI
        DEC     DI
        PUSH    DI
        PUSH    CX
        REP     MOVSB
        POP     CX
        POP     DI
        DEC     BX
        JMP     @@1
@@2:    LES     DI, Str
        MOV     ES:[DI], BL
        POP     DS
end;

function StrChrNum(Str: String; I: Word; Sim: Char): Byte; assembler;
asm
        LES     DI, Str
        XOR     CX, CX
        MOV     CL, ES:[DI]
        JCXZ    @@2
        MOV     DX, I
        OR      DX, DX
        JZ      @@2
        INC     DI
        MOV     BX, CX
        MOV     AL, Sim
        CLD
@@1:    REPNE   SCASB
        JNE     @@2
        DEC     DX
        OR      DX, DX
        JNZ     @@1
        SUB     BX, CX
        MOV     AX, BX
        JMP     @@3
@@2:    XOR     AX, AX
@@3:
end;

function StrChrCount(Str: String; Sim: Char): Byte; assembler;
asm
        LES     DI, Str
        XOR     BX, BX
        XOR     CX, CX
        MOV     CL, ES:[DI]
        JCXZ    @@2
        CLD
        INC     DI
        MOV     AL, Sim
@@1:    REPNE   SCASB
        JNE     @@2
        INC     BX
        JMP     @@1
@@2:    MOV     AX, BX
end;

function ReplaceChar(Str: String; OldSim, NewSim: Char): String; assembler;
asm
        PUSH    DS
        CLD
        LDS     SI, Str
        LES     DI, @Result
        LODSB
        STOSB
        OR      AL, AL
        JZ      @@3
        XOR     CX, CX
        MOV     CL, AL
        MOV     BL, OldSim
        MOV     BH, NewSim
@@1:    LODSB
        CMP     AL, BL
        JNE     @@2
        MOV     AL, BH
@@2:    STOSB
        LOOP    @@1
@@3:    POP     DS
end;

procedure ReplaceStr(var Str: String; FindStr, RepStr: String);
var
  I: Integer;
begin
  I := 1;
  while I <= StrLength(Str) - StrLength(FindStr) do
    if MemCmp(Str[I], FindStr[1], StrLength(FindStr)) then begin
      Delete(Str, I, StrLength(FindStr));
      Insert(RepStr, Str, I);
      Inc(I, StrLength(RepStr));
     end else Inc(I);
end;

function TwoDigit(X: Word): String; assembler;
asm
        LES     DI, @Result
        CLD
        MOV     AL, 2
        STOSB
        MOV     AX, X
        MOV     DL, 10
        DIV     DL
        ADD     AL, 30H
        ADD     AH, 30H
        STOSW
end;

function ToLower; External;

function ToUpper; External;

function IsDigit; External;

function IsHexDigit; External;

function IsLatChar; External;

function IsRusChar; External;

function IsAlpha; External;

function IsAlNum; External;

function IsAlfa; External;

function IsLower; External;

function IsUpper; External;

end.
