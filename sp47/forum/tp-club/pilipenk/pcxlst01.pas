program ShowBWPCX;

{ Программа визуализации черно-белых изображений в формате PCX. }
{ Автор программы : Олег Петрович Пилипенко                     }
{ Программа написана в МП "КИТ"                                 }

uses
    Crt,
    Dos,
    Graph;

const
    VideoBase   = $A000;
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

procedure ExpandBW;
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
               Move(ScrBuf[Start], Mem[VideoBase : Offset], XLen);
               Inc(Start, XLen);
               Inc(Offset, 80);
               Inc(NLines)
          end;

       if SBOfs > Start then
          Move(ScrBuf[Start], ScrBuf[1], SBOfs-Start);
       Dec(SBOfs, Pred(Start))
  end;

begin
     with Hdr do
          begin
               XLen:=BytesPerLine;
               YLen:=Succ(YH-YL)
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
          else if (BitsPerPixel > 1) or (NPlanes > 1) then
             begin
                  Writeln('Файл ', FName, 
                                   ' содержит цветное изображение');
                  Halt(1)
             end;

     DetectGraph(GD, GM);
     if not (GD in [EGA, VGA]) then
        begin
             Writeln('Видеоадаптер EGA/VGA не установлен');
             Halt(1)
        end;
     if Hdr.YRes = 200 then
        GM:=EGALo
     else if (Hdr.YRes > 350) and (GD = VGA) then
        GM:=VGAHi
     else
        GM:=EGAHi;
     InitGraph(GD, GM, '');
     ErrCode:=GraphResult;
     if ErrCode <> 0 then
        begin
             Writeln('Ошибка при инициализации графики');
             Halt(1)
        end;

     ExpandBW;

     Ch:=ReadKey;
     CloseGraph

end.
