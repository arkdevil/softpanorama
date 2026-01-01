{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,0}
uses DOS, TpCRT, TpString;

const CopyR ='WVW_tune, ver. 1.00   (C) V.S. Rabets, 1994';

type FontCode = (font866, fontWin);
     tFont = record FName: PathStr;   { Имя файла со шрифтом        }
                    FLen:  word;      { Длина файла со шрифтом      }
                    Code:  FontCode;  { Кодировка шрифта            }
                    FOfs:  word;      { Смещение [фрагмента] шрифта }
             end;                     {              в WinView.com  }
const Font: array [1..6] of tFont = (
            (FName:'866_08.FNT'; FLen:2048; Code:font866; FOfs:$07A2-$100),
            (FName:'866_14.FNT'; FLen:3584; Code:font866; FOfs:$11A2-$100),
            (FName:'866_16.FNT'; FLen:4096; Code:font866; FOfs:$2722-$100),
            (FName:'WIN_08.FNT'; FLen:2048; Code:fontWin; FOfs:$0FA2-$100),
            (FName:'WIN_14.FNT'; FLen:3584; Code:fontWin; FOfs:$1FA2-$100),
            (FName:'WIN_16.FNT'; FLen:4096; Code:fontWin; FOfs:$3722-$100) );

type tSwitch = record SName: char;         { Имя ключа командной строки WVW }
                      SNum:  byte;         { Порядковый номер ключа         }
                      SVal:  byte;         { Состояние ключа                }
                      SDescr: string[44];  { Описание ключа                 }
               end;
const sCount = 8;                        { Число настраиваемых ключей WVW   }
      ofsSw_Name = $3E30 - $100;         { Смещение таблицы имён ключей     }
      ofsSw_Val  = $3E3D - $100;         { Смещение таблицы значений ключей }
      wSwitch: array [1..sCount] of tSwitch = (
   (SName:'^'; SNum:3; SVal: 0; SDescr:'НЕ использовать Правый_Ctrl'),
   (SName:'S'; SNum:4; SVal: 0; SDescr:'сохранять скан-коды клавиш'),
   (SName:'B'; SNum:5; SVal: 0; SDescr:'изображать символы 00 и FF пробелом'),
   (SName:'C'; SNum:6; SVal: 0; SDescr:'НЕ поддерживать таблицу UpCase'),
   (SName:'I'; SNum:7; SVal: 0; SDescr:'НЕ индицировать режим рамкой'),
   (SName:'L'; SNum:8; SVal: 0; SDescr:'установить белорусскую клавиатуру'),
   (SName:'K'; SNum:9; SVal: 0; SDescr:'установить украинскую клавиатуру'),
   (SName:'X'; SNum:10;SVal: 0; SDescr:'НЕ отслеживать завершение программ'));

type tBord = record BOfs: word;            { Смещение рамки в WVW.com }
                    BVal,                  { Текущее значение рамки   }
                    BDef: byte;            { Стандартное значение     }
                    BDescr: string[29];    { Описание                 }
             end;
const BordCount = 10;                      { Число настраиваемых рамок }
      wBord: array [1..BordCount] of tBord = (
  (BOfs:$41D-$100; BVal:0; BDef:$00; BDescr:'Русская 866 ЛАТ'),
  (BOfs:$41E-$100; BVal:0; BDef:$38; BDescr:'Русская 866 КИР'),
  (BOfs:$425-$100; BVal:0; BDef:$04; BDescr:'Русская Win ЛАТ'),
  (BOfs:$426-$100; BVal:0; BDef:$24; BDescr:'Русская Win КИР'),
  (BOfs:$63B-$100; BVal:0; BDef:$08; BDescr:'Белорусская 866 ЛАТ'),
  (BOfs:$63C-$100; BVal:0; BDef:$01; BDescr:'Белорусская 866 КИР'),
  (BOfs:$626-$100; BVal:0; BDef:$10; BDescr:'Украинская 866 ЛАТ'),
  (BOfs:$627-$100; BVal:0; BDef:$02; BDescr:'Украинская 866 КИР'),
  (BOfs:$427-$100; BVal:0; BDef:$05; BDescr:'Белорусско-украинская Win ЛАТ'),
  (BOfs:$428-$100; BVal:0; BDef:$2D; BDescr:'Белорусско-украинская Win КИР'));

type tName = array [1..11] of char;
     pName = ^tName;
const wLen = 20443;                { Длина файла WVW.com                    }
      ofsName = $0766 - $100;      { Смещение имени WinVieW в файле WVW.com }
      wName = 'WinVieW1.00';       { Имя WinVieW и версия                   }

var wBuf: array [0..wLen-1] of byte;   { Буфер для считывания WVW.com }
    fBuf: array [0..4096-1] of byte;   { Буфер для считывания шрифтов }

procedure Help;
begin
  ClrScr;
  writeln (CopyR);
  writeln (   'Настройщик драйвера WinVieW версии 1.00');
  writeln (#10'   Файл WVW.com драйвера WinVieW должен быть в текущем каталоге.');
  writeln (#10'   Для замены шрифта укажите в командной строке файлы шрифтов.');
  writeln (   '      Файлы шрифтов в формате EVAfont должны называться');
  writeln (   '        866_08  866_14  866_16  Win_08  Win_14  или  Win_16,');
  writeln (   '      с расширением .fnt  (из Win_*.fnt используются только символы 80h-BFh).');
  writeln (#10'   Ключ /S - сброс всех настраиваемых параметров в стандартное состояние.');
  writeln (#10'   Номер прерывания для поиска резидентной копии драйвера');
  writeln (   '      в WVW.com находится в байте по смещению 3FBCh.');
  writeln ;
  writeln ('        02-05-94                   В.С. Рабец'                 );
  writeln ('                         e-mail:   rabets@icph20.sherna.msk.su');
  writeln ('                          Адрес:   142 432'                    );
  writeln ('                                   Московская обл.'            );
  writeln ('                                   Ногинский р-н'              );
  writeln ('                                   п. Черноголовка'            );
  writeln ('                                   Школьный б-р, 18, кв. 241'  );
  halt;
end;

procedure Err (Mes: string);            { Сообщение об ошибке и выход }
begin
   TextAttr:=$4F;
   ClrScr;
   writeln (#10'  ',Mes,#7);
   halt;
end;

procedure DefaultParams;     { Установка параметров в значение по умолчанию }
var b: byte;
begin
  for b:=1 to sCount do wSwitch[b].SVal:=0;
  for b:=1 to BordCount do with wBord[b] do BVal:=BDef;
  writeln ('Установлены стандартные значения параметров WinVieW');
end;

procedure TuneBord (N: byte);                           { Настройка рамки }
type tColor = record CName: char;        { Название цвета }
                     CVal:  byte;        { Значение       }
                     CDescr: string[13]; { Описание       }
              end;
const BColor: array [1..6] of tColor = (
              (CName:'r'; CVal:32; CDescr:'Тёмно-красный'),
              (CName:'g'; CVal:16; CDescr:'Тёмно-зелёный'),
              (CName:'b'; CVal: 8; CDescr:'Тёмно-синий'  ),
              (CName:'R'; CVal: 4; CDescr:'Красный'      ),
              (CName:'G'; CVal: 2; CDescr:'Зелёный'      ),
              (CName:'B'; CVal: 1; CDescr:'Синий'        ) );
var R: registers;
    SaveBord: byte;
    BCh: char;
    b: byte;
begin
  with wBord[N] do repeat
    Window (9,9, 71,25); TextAttr:=$34; ClrScr;
    FastWrite ('  ENTER - установить рамку, ESC - нет  ',25,20,$70);
    writeln (' Настраивается рамка: ', BDescr); TextAttr:=$31;
    writeln (#10' Для изменения активности компонента рамки нажимайте буквы');
    writeln (   ' R,G,B в нужном регистре:'#10);
    for b:=1 to 6 do with BColor[b] do begin
        write   ('        '); if (BVal and CVal)>0 then write (#8'√');
        writeln (' ',CName, '   ',CDescr);
    end;
    R.AX:=$1001; R.BH:=BVal; Intr($10,R);  { Установка рамки }
    BCh:=ReadKey; if BCh=#0 then ReadKey; if BCh=#27{Esc} then BVal:=BDef;
    for b:=1 to 6 do with BColor[b] do if BCh=CName then BVal:=BVal xor CVal;
    R.AX:=$1001; R.BH:=BVal; Intr($10,R);  { Установка рамки }
  until (BCh=#27{Esc}) or (BCh=#13{Enter});
  TextAttr:=$1B; ClrScr; Window (1,1, 80,25);
end;

{ ---------------------------------------------------------------- MAIN --- }
label ParValid;
var SaveMode: word;
    Par: ComStr;
    fW,fF: file;
    CharSize: byte;
    w,b: byte;
    Ch: char;
    SaveWVW: boolean;
begin
  SaveMode:=LastMode; TextMode(Co80); TextAttr:=$1E; ClrScr;
  writeln (CopyR); TextAttr:=$1B;
  assign(fW,'WVW.com');
  reset (fW,1); if IOresult>0 then
            Err('В текущем каталоге не найден файл WVW.com драйвера WinVieW');
  if FileSize(fW)<>wLen then Err ('Неверная длина файла WVW.com');
  BlockRead (fW, wBuf, wLen);
       if IOresult>0 then Err('Ошибка чтения файла WVW.com драйвера WinVieW');
  if tName( Ptr(Seg(wBuf),Ofs(wBuf)+ofsName)^ )<>wName
     then Err ('Неверный файл WVW.com, либо версия драйвера - не 1.00');

  for b:=1 to sCount do with wSwitch[b] do begin
     if SName<>char(wBuf[ofsSw_Name+SNum]) then Err ('Неверный файл WVW.com');
     SVal:=wBuf[ofsSw_Val+SNum];
     { Настроенные ключи равны $80, остальные - 0 }
     if (SVal and $7F)>0 then Err ('Неверный файл WVW.com');
  end;
  for b:=1 to BordCount do with wBord[b] do BVal:=wBuf[BOfs];

  for w:=1 to ParamCount do begin              { Разбор командной строки }
    Par:=StUpcase(ParamStr(w));
    if Par='/?' then Help;
    if Par='/S' then begin DefaultParams; continue end;
    for b:=1 to 6 do if JustFilename(Par)=Font[b].FName then goto ParValid;
        Err ('Неверный параметр командной строки: '+Par);
    ParValid:
    with Font[b] do begin
      assign(fF,Par);
      reset (fF,1); if IOresult>0 then Err ('Не найден файл шрифта ' + Par);
      if FileSize(fF)<>FLen then Err ('Неверная длина файла шрифта ' + Par);
      BlockRead (fF, fBuf, FLen);
                if IOresult>0 then Err ('Ошибка чтения файла шрифта '+ Par);
      CharSize:=Flen div 256;
      if Code=font866 then move (fBuf, wBuf[FOfs], Flen)
         else move (fBuf[CharSize*$80], wBuf[FOfs], CharSize*($BF-$80+1));
      close (fF); if IOresult>0 then Err('Ошибка закрытия файла шрифта '+Par);
      writeln ('Земенён шрифт ', FName);
    end;
  end;

  HiddenCursor;
  repeat
    SaveWVW:=false;
    FastWrite (
    '  F2 - запись параметров в WVW.com, ESC - выход без записи  ',25,9,$70);
    gotoXY (1,9);
    writeln ('Нажмите соответствующую букву для изменения состояния ключа:');
    for b:=1 to sCount do with wSwitch[b] do begin
        write ('     '); if SVal=$80 then write (#8'√');
        writeln (' ', SName, '   ', SDescr);
    end;
    writeln (#10'Нажмите цифру 0-9 для установки соответствующей рамки:');
    writeln ('                   РУССКАЯ    БЕЛОРУССКАЯ    УКРАИНСКАЯ');
    writeln ('        866-ЛАТ       0            4             6');
    writeln ('        866-КИР       1            5             7');
    writeln ('        Win-ЛАТ       2            8             8');
    writeln ('        Win-КИР       3            9             9');
    Ch:=UpCase(ReadKey); if Ch=#0 then SaveWVW:=ReadKey=#60{F2};
    for b:=1 to sCount do with wSwitch[b] do
        if Ch=SName then SVal:=SVal xor $80;
    if Ch in ['0'..'9'] then TuneBord (succ(byte(Ch)-byte('0')));
  until (Ch=#27) or SaveWVW;
  if SaveWVW then begin
     for b:=1 to sCount do with wSwitch[b] do wBuf[ofsSw_Val+SNum]:=SVal;
     for b:=1 to BordCount do with wBord[b] do wBuf[BOfs]:=BVal;
     Seek(fW,0); BlockWrite (fW, wBuf, wLen); close (fW);
       if IOresult>0 then Err('Ошибка записи файла WVW.com драйвера WinVieW');
  end;
  TextMode(SaveMode);
end.
