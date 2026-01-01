program ShowCGAPCX;

{ Программа визуализации черно-белых и цветных изображений }
{ в формате PCX для видеоадаптера CGA.                     }
{ Автор программы : Олег Петрович Пилипенко                }
{ Программа написана в МП "КИТ"                            }

uses
    Crt,
    Dos,
    Graph;

const
    VideoBase   = $A000;
    SCIndex     = $3C4;
    SCData      = $3C5;
    MapMask     = 2;
    DiskBufSize = $8000;
    ScrBufSize  = 150;

type
    PCXHeader = record
                      PCXId        : byte;
                      VersionNo    : byte;
                      Encoding     : byte;
                      BitsPerPixel : byte;
                      XL, YL       : word;
                      XH, YH       : word;
                      XRes, YRes   : word;
                      Palette      : array[1..48] of byte;
                      Reserved     : byte;
                      NPlanes      : byte;
                      BytesPerLine : word;
                      PaletteInfo  : word;
                      Reserved2    : array[1..58] of byte
                end;

var
    GD       : integer;
    GM       : integer;
    ErrCode  : integer;
    Ch       : char;
    FName    : PathStr;
    Hdr      : PCXHeader;
    F        : file;
    DiskBuf  : array[1..DiskBufSize] of byte;
    ScrBuf   : array[1..ScrBufSize] of byte;

procedure ExpandCGA;
var
    Mask, Cnt : byte;
    DBOfs, SBOfs, XLen, YLen, Offset, NLines, BytesRead : word;
    FileEnd : Boolean;

  procedure NextBlock;
  begin
       BlockRead(F, DiskBuf, DiskBufSize, BytesRead);
       DBOfs:=1
  end;

  procedure ShowLine;
  var
      Start : byte;
  begin
       Start:=1;

       while (SBOfs - Start) >= XLen do
          begin
               if Odd(NLines) then
                  Move(ScrBuf[Start], Mem[$B800 : Offset], XLen)
               else
                  begin
                       Move(ScrBuf[Start], Mem[$BA00 : Offset], XLen);
                       Inc(Offset, 80);
                  end;
               Inc(Start, XLen);
               Inc(NLines)
          end;

       if SBOfs > Start then
          Move(ScrBuf[Start], ScrBuf[1], SBOfs-Start);
       Dec(SBOfs, Pred(Start));
  end;

begin
     with Hdr do
          begin
               XLen:=BytesPerLine;
               YLen:=Succ(YH-YL);
               if Ylen > 200 then
                  Ylen:=200
          end;
     NextBlock;
     Offset:=0;
     SBOfs:=1;
     Mask:=1;
     NLines:=0;

     repeat
           if SBOfs > XLen then
              ShowLine;
           if (DiskBuf[DBOfs] - $C0) > 0 then
              if DBOfs = DiskBufSize then
                 begin
                      Cnt:=DiskBuf[DBOfs]-$C0;
                      NextBlock;
                      FillChar(ScrBuf[SBOfs], Cnt, DiskBuf[DBOfs]);
                      Inc(SBOfs, Cnt);
                      Inc(DBOfs)
                 end
              else
                 begin
                      FillChar(ScrBuf[SBOfs], DiskBuf[DBOfs] - $C0,
                                                  DiskBuf[DBOfs+1]);
                      Inc(SBOfs, DiskBuf[DBOfs] - $C0);
                      Inc(DBOfs, 2)
                 end
           else
              begin
                   ScrBuf[SBOfs]:=DiskBuf[DBOfs];
                   Inc(SBOfs);
                   Inc(DBOfs)
              end;
           if DBOfs > DiskBufSize then
              NextBlock
     until NLines >= YLen

end;

begin

     FName:=ParamStr(1);
     if Pos('.', FName) = 0 then
        FName:=ParamStr(1)+'.PCX';
     Assign(F, FName);
     Reset(F, 1);
     BlockRead(F, Hdr, 128);

     with Hdr do
          if PCXId <> $0A then
             begin
                  Writeln('Файл ', FName, ' - не файл формата PCX');
                  Halt(1)
             end
          else if (BitsPerPixel > 2) or (NPlanes > 1) then
             begin
                  Writeln('Файл ', FName, ' содержит изображение, ',
                          'не подходящее для видеоадаптера CGA');
                  Halt(1)
             end;

     DetectGraph(GD, GM);
     if not (GD in [CGA, EGA, VGA]) then
        begin
             Writeln('Видеоадаптер, совместимый с CGA, отсутствует');
             Halt(1)
        end;
     GD:=CGA;
     if Hdr.BitsPerPixel = 1 then
        GM:=CGAHi
     else
        GM:=CGAC1;
     InitGraph(GD, GM, '');
     ErrCode:=GraphResult;
     if ErrCode <> 0 then
        begin
             Writeln('Ошибка при инициализации графики');
             Halt(1)
        end;

     ExpandCGA;

     Ch:=ReadKey;
     CloseGraph

end.
