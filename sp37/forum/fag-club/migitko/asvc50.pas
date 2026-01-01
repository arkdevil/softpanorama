Program ASVC50;   {$I-,R-,D-,S-,V-}

USES DOS,CRT,PRINTER;

Type
  St80 = String[80];

Var
  R                                : Registers;
  FileInfection                    : File Of Byte;
  SearchFile                       : SearchRec;
  Mas                              : Array[0..80] of St80;
  MasByte                          : Array[1..3] of Byte;
  Position,I,J,K                   : Byte;
  Num,NumberOfFile,NumberOfInfFile : Word;
  St                               : St80;
  Flag,NextDisk,Error              : Boolean;
  Dt                               : DateTime;
  Key1,Key2,Key3,NumError          : Byte;
  MasScreen                        : Array[0..24,0..159] Of Byte Absolute $B800:0000;
  Ch,Disk                          : Char;

Procedure ProcedureError;

Var StError : String[80];

Begin
  Case NumError Of
      100 : StError:=' Ошибка чтения диска. ';
      101 : StError:=' Ошибка записи на диск. ';
      102 : StError:=' Файлу не присвоенно имя. ';
      103 : StError:=' Файл не открыт. ';
      104 : StError:=' Файл не открыт для ввода. ';
      105 : StError:=' Файл не открыт для вывода. ';
      106 : StError:=' Неверный числовой формат. ';
      150 : StError:=' Диск защищен от записи. ';
      151 : StError:=' Неизвестный модуль. ';
      152 : StError:=' Дисковод не готов. ';
      153 : StError:=' Неизвестная команда. ';
      154 : StError:=' Ошибка в исходных данных. ';
      155 : StError:=' Неправильная длина структуры. ';
      156 : StError:=' Ошибка установки головки на диске. ';
      157 : StError:=' Неизвестный тип носителя. ';
      158 : StError:=' Сектор не найден. ';
      160 : StError:=' Ошибка при записи на устройство. ';
      161 : StError:=' Ошибка при чтении с устройства. ';
      162 : StError:=' Сбой аппаратуры. ';
      202 : StError:=' Переполнение стека. ';
      Else  StError:=' Неизвестная команда. ';
  End;
  Sound(1000);
  Delay(400);
  NoSound;
  GoToXY(1,9);
  Writeln('Ошибка ввода-вывода!!  ',StError);
End;

Procedure Cure(St : St80);

Var
  I       : Byte;
  MasCure : Array[1..24] Of Byte;

  Begin
    Assign(FileInfection,St);
    Reset(FileInfection);
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Seek(FileInfection,FileSize(FileInfection) - ($0C1F - $0C1A));
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Read(FileInfection,Key1);   { AH }
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Read(FileInfection,Key2);   { DH }
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Seek(FileInfection,FileSize(FileInfection) - ($0C1F - $0BAA));
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    For I:=1 to 24 do
       Begin
         Read(FileInfection,MasCure[i]);
         NumError:=IOResult;
         If (NumError <> 0) Then Begin Error:=True; Exit; End;
         Key3:=MasCure[i];
         InLine($50/                { PUSH AX           }
                $8A/$26/KEY1/       { MOV AH,KEY1       }
                $30/$26/KEY3/       { XOR KEY3,AH       }
                $A0/KEY2/           { MOV AL,KEY2       }
                $00/$C4/            { ADD AH,AL         }
                $88/$26/KEY1/       { MOV KEY1,AH       }
                $58                 { POP AX            }
               );
         MasCure[i]:=Key3;
       End;
    Seek(FileInfection,0);
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    For I:=1 to 24 do Write(FileInfection,MasCure[i]);
    Seek(FileInfection,FileSize(FileInfection) - $0C1F);
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Truncate(FileInfection);
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Close(FileInfection);
    NumError:=IOResult;
    If (NumError <> 0) Then Begin Error:=True; Exit; End;
    Num:=Num+1;
  End;


Procedure F1(St : St80);

  Begin
    FindFirst(St + '*.*', $3F, SearchFile);
    While (SearchFile.Attr = $10) And (DosError = 0) And
          ((SearchFile.Name = '.') Or (SearchFile.Name = '..')) Do
         Begin
           FindNext(SearchFile);
         End;
    While (DosError = 0) Do
         Begin
           If KeyPressed Then
             If (Ord(ReadKey) = 27) Then Halt;
           If (SearchFile.Attr = $10) Then
             Begin
               Mas[k]:=St + SearchFile.Name + '\';
               K:=K+1;
             End;
           If ( SearchFile.Attr <> $10) Then
             Begin
               NumberOfFile:=NumberOfFile + 1;
               UnpackTime(SearchFile.Time, DT);
               For I:=18 to 70 do MasScreen[6,2*i]:=$20;
               GoToXY(18,7);
               Write(St + SearchFile.Name,'   ');
               If (Dt.Sec = 60) Then
                 Begin
                   Assign(FileInfection,St + SearchFile.Name);
                   Reset(FileInfection);
                   NumError:=IOResult;
                   If (NumError <> 0) Then Begin Error:=True; Exit; End;
                   Seek(FileInfection,FileSize(FileInfection) - $8A);
                   NumError:=IOResult;
                   If (NumError <> 0) Then Begin Error:=True; Exit; End;
                   For I:=1 to 3 do Read(FileInfection,MasByte[i]);
                   Close(FileInfection);
                   NumError:=IOResult;
                   If (NumError <> 0) Then Begin Error:=True; Exit; End;
                   If (MasByte[1] = $35) And (MasByte[2] = $2E) And
                      (MasByte[3] = $30) Then
                     Begin
                       NumberOfInfFile:=NumberOfInfFile + 1;
                       GoToXY(1,8);
                       Sound(600);
                       Delay(400);
                       NoSound;
                       Write( St + SearchFile.Name,' инфицирован. Удалить [Y/N] ');
                       Repeat
                           Ch:=ReadKey;
                           If (Ord(Ch) = 27) Then Exit;
                       Until (Ch = 'Y') Or (Ch = 'y') Or (Ch = 'N') Or (Ch = 'n');
                       If (Ch = 'Y') Or (Ch = 'y') Then
                         Begin
                           Cure(St + SearchFile.Name);
                           If (NumError <> 0) Then Exit;
                         End;
                       For I:=0 to 79 do MasScreen[7,2*i]:=$20;
                     End;
                 End;
             End;
            FindNext(SearchFile);
         End;
  End;

Begin
  Repeat
       Flag:=True;
       TextAttr:=$1F;
       Repeat
            ClrScr;
            GoToXY(29,1);
            TextAttr:=$1E;
            Writeln('(C) 1991, Mигитко И.А.');
            GoToXY(20,2);
            TextAttr:=$17;
            Writeln('Программа для поиска и излечения файлов,');
            GoToXY(28,3);
            Writeln('зараженных вирусом SVC50.');
            TextAttr:=$4F;
            GoToXY(1,25);
            Write(' ESC - выход                                                                   ');
            TextAttr:=$1F;
            GoToXY(1,6);
            Write('Какой диск тестировать ? (A,B..)  ');
            Disk:=ReadKey;
            If (Ord(Disk) = 27) Then Exit;
            R.Ah:=$0E;
            R.Dl:=Ord(UpCase(Disk))-65;
            Intr($21,R);
            R.Ah:=$19;
            Intr($21,R);
            Flag:=(R.Al = (Ord(UpCase(Disk))-65));
            If Not(Flag) Then
              Begin
                Sound(1000);
                Delay(400);
                NoSound;
              End;
       Until Flag;
       NextDisk:=True;
       Error:=False;
       Num:=0;
       K:=0;
       St:=UpCase(Disk) + ':\';
       GoToXY(1,6);
       Writeln('Тестируется диск ',St,'                       ');
       Writeln('Тестируется файл ');
       NumberOfFile:=0;
       NumberOfInfFile:=0;
       F1(St);
       If Error Then ProcedureError;
       If (k = 0) Or Error Then Flag:=False;
       If (k > 0) Then K:=K-1;
       While Flag Do
            Begin
              If (k=0) Then Flag:=False;
              F1(Mas[k]);
              If Error Then Begin ProcedureError; Flag:=False; End;
              If (k > 0) Then K:=K-1;
            End;
       GoToXY(1,10);
       Writeln('Проверено файлов - ',NumberOfFile);
       Writeln('Заражено  файлов - ',NumberOfInfFile);
       Writeln('Излечено  файлов - ',Num);
       Write('Другой диск ? [Y/N]');
       Repeat
            Ch:=ReadKey;
            If (Ord(Ch) = 27) Then Exit;
       Until (Ch = 'Y') Or (Ch = 'y') Or (Ch = 'N') Or (Ch = 'n');
       If (Ch = 'N') Or (Ch = 'n') Then NextDisk:=False;
  Until Not(NextDisk);
End.

