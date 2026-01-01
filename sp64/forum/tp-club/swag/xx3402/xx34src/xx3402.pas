
(******************************************************************************)
(*                                                                            *)
(* TITLE   : XX3402 ver 0.2                                                   *)
(*                                                                            *)
(* AUTHOR  : Guy McLoughlin                                                   *)
(*                                                                            *)
(* DATE    : January 28, 1994                                                 *)
(*                                                                            *)
(* PURPOSE : Modified XX encoder/decoder.                                     *)
(*                                                                            *)
(* NOTES   : XX3402.PAS source-code released to the public domain.            *)
(*           This source-code requires Edwin T. Floyd's public domain         *)
(*           (see author's notes) CRC.PAS unit to compile.                    *)
(*                                                                            *)
(******************************************************************************)

              (* Compiler directives.                                         *)
 {$I COMP.SET}
 {$M 4096, 32768, 131072}

program Xx3402;
uses
  dos,
  crc;

(********************** START OF GLOBAL DATA DEFINITIONS **********************)

type
  T_Ch2  = array[1..2]  of char;
  T_Ch3  = array[1..3]  of char;
  T_Ch4  = array[1..4]  of char;
  T_Ch5  = array[1..5]  of char;
  T_Ch6  = array[1..6]  of char;
  T_Ch7  = array[1..7]  of char;
  T_Ch8  = array[1..8]  of char;
  T_Ch10 = array[1..10] of char;
  T_Ch12 = array[1..12] of char;
  T_Ch14 = array[1..14] of char;
  T_Ch27 = array[1..27] of char;
  T_Ch62 = array[1..62] of char;
  T_Ch64 = array[0..63] of char;

  T_By256 = array[0..255] of byte;
  T_Wo255 = array[1..255] of word;
  T_Lo255 = array[1..255] of longint;

  T_St2  = string[2];
  T_St3  = string[3];
  T_St8  = string[8];
  T_St12 = string[12];
  T_St20 = string[20];

  T_3Ch2 = array[1..3] of T_Ch2;

  T_By80 = array[43..122] of byte;

  T_Header1 = T_Ch62;

  T_Header2 = record
                Spacer0  : T_Ch8;
                Size     : T_Ch6;
                Spacer1  : char;
                Fday     : T_Ch2;
                Fmonth   : T_Ch2;
                Fyear    : T_Ch2;
                Spacer2  : char;
                FCols    : T_Ch3;
                Spacer3  : char;
                FRows    : T_Ch3;
                Spacer4  : char;
                CrcValue : T_Ch5;
                Spacer5  : char;
                HexFlag  : char;
                Spacer6  : T_Ch2;
                FName    : T_Ch12;
                Block    : T_Ch3;
                Spacer7  : T_Ch3;
                BlockTot : T_Ch3;
                Spacer8  : T_Ch2;
              end;

const
  co_MaxBuffSize = 65520;

type
  T_EncBuff    = array[1..co_MaxBuffSize] of char;
  T_EncBuffPtr = ^T_EncBuff;

  T_BinBuff    = array[1..((co_MaxBuffSize div 4) * 3)] of byte;
  T_BinBuffPtr = ^T_BinBuff;

(******************************** CONSTANTS ***********************************)
const
              (* Column, row default size.                                    *)
  co_ColDef = 72;
  co_RowDef = 85;

              (* Minimum and maximum column size.                             *)
  co_MinCol = 60;
  co_MaxCol = 100;

              (* Minimum and maximum row size.                                *)
  co_MinRow = 10;
  co_MaxRow = 600;

              (* Encoded block maximum.                                       *)
  co_BlockMax = 255;

              (* Size of encoded header.                                      *)
  co_HeaderSize  = sizeof(T_Header1);

              (* File date constants.                                         *)
  co_ThisCentury = 1900;
  co_NextCentury = 2000;

              (* Numeric error constant.                                      *)
  co_NumError    = -1111111111;

              (* Maximum encodeable binary file size in bytes.                *)
  co_MaxFilesize = 11455875;

              (* Keypress constants.                                          *)
  co_EnterKey     = #13;
  co_BackSpaceKey = #8;

(************************* PRE-INITIALIZED VARIABLES **************************)

              (* Encoding boolean flag.                                       *)
  bo_Encoding  : boolean = false;

              (* Test-mode boolean flag.                                      *)
  bo_TestMode  : boolean = false;

              (* Split encoded output flag.                                   *)
  bo_SplitOutput : boolean = false;

              (* Erase corrupt output file flag.                              *)
  bo_EraseOutFile : boolean = false;

              (* Carriage-return and line-feed constants.                     *)
  co_CrLf      : T_Ch2 = #13#10;
  co_CrLf2     : T_Ch4 = #13#10#13#10;

              (* Initial encoded block delimiter.                             *)
  co_XxBlockID : T_Ch7 = '*XX3402';

              (* Alternative delimiter character set.                         *)
  co_AltDelSet : array[0..9] of char = '*:#@=$?%&!';

              (* Alternative delimiter look-up string.                        *)
  co_AltDelStr : T_Ch27 = 'AD1AD2AD3AD4AD5AD6AD7AD8AD9';

              (* Encoded block end marker constants.                          *)
  co_EndMark1  : T_Ch5  = '*****';

  co_EndMark2  : T_Ch14 = ' END OF BLOCK ';

              (* Encoded block header constant.                               *)
  co_Header1   : T_Header1 =
                          '*XX3402-000000-000000--72--85-00000------------.-------OF---' + #13#10;

              (* Standard XX encoding character array.                        *)
  co_XxChar1   : T_Ch64 = '+-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

              (* Standard XX encoding character set.                          *)
  co_XxChar2   : set of char = ['+','-','0'..'9','A'..'Z','a'..'z'];

              (* Translation table for encoded characters.                    *)
  co_BinTable  : T_By80 = ( 0,  0,  1,  0,  0,  2,  3,  4,  5,  6,
                            7,  8,  9, 10, 11,  0,  0,  0,  0,  0,
                            0,  0, 12, 13, 14, 15, 16, 17, 18, 19,
                           20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
                           30, 31, 32, 33, 34, 35, 36, 37,  0,  0,
                            0,  0,  0,  0, 38, 39, 40, 41, 42, 43,
                           44, 45, 46, 47, 48, 49, 50, 51, 52, 53,
                           54, 55, 56, 57, 58, 59, 60, 61, 62, 63);

              (* First parameter look-up string.                              *)
  co_Params1   : T_Ch10 = 'eEdDestTES';

              (* Hexidecimal character array.                                 *)
  co_HexChars  : array[0..15] of char = '0123456789ABCDEF';

              (* Set of valid DOS filename characters.                        *)
  se_FNameChars : set of char = [#33, #35..#41, #45, '0'..'9', '@'..'Z', '^'..'{', '}', '~'];

(********************** END OF GLOBAL DATA DEFINITIONS ************************)


  (***** Convert BYTE to HEX string.                                          *)
  (*                                                                          *)
  function Byte2Hex({input }
                       by_IN : byte) :
                    {output}
                       T_St2;
  begin
    Byte2Hex[0] := #2;
    Byte2Hex[1] := co_HexChars[(by_IN SHR 4)];
    Byte2Hex[2] := co_HexChars[(by_IN AND $F)]
  end;        (* Byte2Hex.                                                    *)


  (***** Convert LONGINT to HEX string.                                       *)
  (*                                                                          *)
  function Long2Hex({input }
                       lo_IN : longint) :
                    {output}
                       T_St8;
  var
    by_4 : array[1..4] of byte absolute lo_IN;
  begin
    Long2Hex[0] := #8;
    Long2Hex[1] := co_HexChars[(by_4[4] SHR 4)];
    Long2Hex[2] := co_HexChars[(by_4[4] AND $F)];
    Long2Hex[3] := co_HexChars[(by_4[3] SHR 4)];
    Long2Hex[4] := co_HexChars[(by_4[3] AND $F)];
    Long2Hex[5] := co_HexChars[(by_4[2] SHR 4)];
    Long2Hex[6] := co_HexChars[(by_4[2] AND $F)];
    Long2Hex[7] := co_HexChars[(by_4[1] SHR 4)];
    Long2Hex[8] := co_HexChars[(by_4[1] AND $F)]
  end;        (* Long2Hex.                                                    *)


  (***** Search data buffer with TP's POS function.                           *)
  (*                                                                          *)
  function PosSearch({input }
                     var Buffer;
                         wo_BuffSize : word;
                         st_Pattern  : string) :
                     {output}
                         word;
  type
    T_Wo2   = array[1..2] of word;
    T_Ch255 = array[1..255] of char;
  var
    po_Buffer   : ^T_Ch255;
    by_Pos,
    by_IncSize,
    by_PredSize : byte;
    wo_Index    : word;
  begin
              (* Initialize variables.                                        *)
    wo_Index := 0;
    po_Buffer := addr(Buffer);
    by_PredSize := pred(length(st_Pattern));
    by_IncSize := (255 - by_PredSize);

              (* Repeat..Until "pattern" found, or buffer completely searched *)
    repeat
              (* Search for "pattern" string.                                 *)
      by_Pos := pos(st_Pattern, po_Buffer^);

              (* If "pattern" not found, then advance pointer address.        *)
      if (by_Pos = 0) then
        begin
          inc(wo_Index, by_IncSize);
          inc(T_Wo2(po_Buffer)[1], by_IncSize);

              (* Normalize pointer.                                           *)
          inc(T_Wo2(po_Buffer)[2], (T_Wo2(po_Buffer)[1] SHR 4));
          T_Wo2(po_Buffer)[1] := (T_Wo2(po_Buffer)[1] MOD $10)
        end
      else
              (* Else "pattern" was found, advance index variable.            *)
        inc(wo_Index, by_Pos)
    until (by_Pos <> 0) OR (wo_Index > wo_BuffSize);

              (* If "pattern" not found, then...                              *)
    if (by_Pos = 0) OR (wo_Index > (wo_BuffSize - by_PredSize)) then
      PosSearch := 0
    else
              (* Else "pattern" was found.                                    *)
      PosSearch := wo_Index
  end;        (* PosSearch.                                                   *)


  (***** Convert a numerical string to a LONGINT.                             *)
  (*                                                                          *)
  function Str2Long({input }
                       st_IN     : T_St20;
                       bo_HexNum : boolean) :
                    {output}
                       longint;
  var
    in_Error : integer;
    lo_Temp  : longint;
  begin
    while (pos('-', st_IN) <> 0) do
      delete(st_IN, pos('-', st_IN), 1);
    if bo_HexNum then
      st_IN := '$' + st_IN;
    val(st_IN, lo_Temp, in_Error);
    if (in_Error <> 0) then
      Str2Long := co_NumError
    else
      Str2Long := lo_Temp
  end;        (* Str2Long.                                                    *)


const         (* Hexidecimal-mode boolean flag.                               *)
  bo_HexMode : boolean = false;


  (***** Convert a WORD to numerical character string.                        *)
  (*                                                                          *)
  procedure Word2Char1({input }
                           wo_IN : word;
                       {output}
                       var ch_OUT);
  var
    by_Temp : byte;
    st_Temp : string[6];
  begin
    if bo_HexMode then
      begin
        st_Temp := Byte2Hex(lo(wo_IN));
        by_Temp := 1;
        while (st_Temp[by_Temp] = '0') do
          begin
            delete(st_Temp, by_Temp, 1);
            inc(by_Temp)
          end
      end
    else
      str(wo_IN, st_Temp);
    by_Temp := succ(length(st_Temp));
    fillchar(st_Temp[by_Temp], (sizeof(st_Temp) - by_Temp), #32);
    move(st_Temp[1], ch_OUT, 2)
  end;        (* Word2Char1.                                                  *)


  (***** Convert a WORD to numerical character string.                        *)
  (*                                                                          *)
  procedure Word2Char2({input }
                          wo_IN : word;
                       {output}
                       var ch_OUT);
  var
    by_Temp : byte;
    st_Temp : string[6];
  begin
    if bo_HexMode then
      begin
        st_Temp := Byte2Hex(lo(wo_IN));
        by_Temp := 1;
        while (st_Temp[by_Temp] = '0') do
          begin
            st_Temp[by_Temp] := '-';
            inc(by_Temp)
          end
      end
    else
      str(wo_IN, st_Temp);
    while (length(st_Temp) < 3) do
      st_Temp := '-' + st_Temp;
    move(st_Temp[1], ch_OUT, 3)
  end;        (* Word2Char2.                                                  *)


  (***** Convert a LONGINT to a numerical character string.                   *)
  (*                                                                          *)
  procedure Long2Str({input }
                         lo_IN   : longint;
                         by_Size : byte;
                     {update}
                     var Data);
  var
    st_Temp : T_St12;
  begin
    str(lo_IN, st_Temp);
    while (length(st_Temp) < by_Size) do
      st_Temp := '0' + st_Temp;
    move(st_Temp[1], Data, by_Size)
  end;        (* Long2Str.                                                    *)


  (***** Convert a string to uppercase chars.                                 *)
  (*                                                                          *)
  function UpStr({input }
                    st_IN : string) :
                 {output}
                    string;
  var
    by_Index : byte;
  begin
    for by_Index := 1 to length(st_IN) do
      st_IN[by_Index] := upcase(st_IN[by_Index]);
    UpStr := st_IN
  end;        (* UpStr.                                                       *)


  (***** Function to indicate if a key-press is in the keyboard buffer.       *)
  (*                                                                          *)
  function KeyPressed : {output}
                           boolean; assembler;
  asm
    mov ah, 01h
    int 16h
    mov ax, 00h
    jz @1
    inc ax
    @1:
  end;        (* KeyPressed.                                                  *)


  (***** Read a key-press.                                                    *)
  (*                                                                          *)
  function ReadKey: {output}
                       char; assembler;
  asm
    mov ah, 00h
    int 16h
  end;        (* ReadKey.                                                     *)


  (***** Obtain Yes/No/Rename response from user.                             *)
  (*                                                                          *)
  function YesNoRename : {output}
                            char;
  var
    ch_Key : char;
  begin
    while KeyPressed do
      ch_Key := ReadKey;
    if bo_Encoding then
      repeat
        ch_Key := upcase(ReadKey)
      until(ch_Key in ['N','Y'])
    else
      repeat
        ch_Key := upcase(ReadKey)
      until(ch_Key in ['N','R','Y']);
    writeln(ch_Key);
    YesNoRename := ch_Key
  end;        (* YesNoRename.                                                 *)


  (***** Obtain a valid filename from end user.                               *)
  (*                                                                          *)
  function EnterFileName : T_St12;
  var
    by_DotPos,
    by_CharIndex : byte;
    bo_EntryOK,
    bo_BackSpace : boolean;
    ch_Key       : char;
    st_Name      : T_St12;
  begin
    by_CharIndex := 1;
    by_DotPos    := 0;
    st_Name      := '';
    repeat
      bo_EntryOK   := false;
      bo_BackSpace := false;
      ch_Key := upcase(readkey);
      if ch_Key IN se_FNameChars then
        bo_EntryOK := true
      else
        case ch_Key of
          '.' : if  (by_CharIndex > 1)
                and (by_DotPos = 0) then
                  by_CharIndex := 9;
          co_BackSpaceKey : bo_BackSpace := true
        end;
      if  bo_BackSpace
      and (by_CharIndex > 1) then
        begin
          if by_DotPos > 0 then
            dec(by_DotPos);
          if (by_DotPos = 0) then
            by_CharIndex := length(st_Name)
          else
            dec(by_CharIndex);
          dec(st_Name[0]);
          write(co_BackSpaceKey, ' ', co_BackSpaceKey)
        end
      else
        if  (by_CharIndex = 9)
        and (ch_Key <> co_EnterKey) then
          begin
            bo_EntryOK := true;
            ch_Key := '.';
            inc(by_DotPos)
          end;
      if  bo_EntryOK
      and (by_CharIndex < 13) then
        begin
          st_Name := st_Name + ch_Key;
          write(ch_Key);
          if (by_CharIndex > 9) then
            inc(by_DotPos);
          inc(by_CharIndex)
        end
    until (ch_Key = co_EnterKey) and (st_Name <> '');
    EnterFileName := st_Name
  end;        (* EnterFilename.                                               *)


  (****** Calculate a 16-bit CRC check for the data buffer.                   *)
  (*                                                                          *)
  function CalcCRC16({input }
                     var Data;
                         wo_DataSize : word)
                     {output} :
                         word;
  var
    wo_CRC : word;
  begin
    wo_CRC := 0;
    wo_CRC := UpdateCrc16(wo_CRC, Data, wo_DataSize);
    CalcCRC16 := wo_CRC
  end;        (* CalcCRC16.                                                   *)


  (***** Display program syntax.                                              *)
  (*                                                                          *)
  procedure Syntax;
  begin
    writeln;
    writeln(' XX3402  Binary Encoder/Decoder  Version 0.2  01-28-94');
    writeln('         Public-Domain Utility by Guy McLoughlin  ');
    writeln;
    writeln('   Usage: XX3402 <E|ES|D|T> [d:][path]<filename> [cols] [rows] [ADn]');
    writeln;
    writeln('   Encode Parameters');
    writeln('        <E> Encode binary file (single output file)');
    writeln('       <ES> Encode binary file (split output files)');
    writeln('     [cols] Min = 60, Max = 100 (default = 72)');
    writeln('     [rows] Min = 10, Max = 600 (default = 85)');
    writeln('      [ADn] Alternative delimiter (n = 1..9)');
    writeln;
    writeln('   Decode Parameters');
    writeln('        <D> Decode encoded file (Halt on any error  )');
    writeln('        <T> Test encoded blocks (Test for CRC errors)');
    writeln;
    writeln('   Examples');
    writeln('     XX3402 E  MYFILE.ZIP (Encode MYFILE.ZIP, using defaults )');
    writeln('     XX3402 ES MYFILE.ZIP (Encode MYFILE.ZIP, split output   )');
    writeln('     XX3402 D  MYFILE.XX  (Decode MYFILE.XX,  using defaults )');
    writeln('     XX3402 T  MYFILE.XX  (Test   MYFILE.XX,  display results)');
    halt(0)
  end;        (* Syntax.                                                      *)


  (***** Set alternative delimiter.                                           *)
  (*                                                                          *)
  procedure SetAltDel({input}
                         ch_AD : char);
  begin
    co_XxBlockID[1] := ch_AD;
    co_Header1[1] := ch_AD;
    fillchar(co_EndMark1, sizeof(co_EndMark1), ch_AD)
  end;        (* SetAltDel.                                                   *)


var
  st_DirIN      : dirstr;
  st_NameIN     : namestr;
  st_ExtIN      : extstr;
  wo_EncRowSize : word;
  wo_EncColSize : word;
  co_Header2    : T_Header2 absolute co_Header1;


  (***** Process the command-line parameters.                                 *)
  (*                                                                          *)
  procedure ProcessParams;
  begin
              (* If too many or too few parameters, then display syntax.      *)
    if (paramcount > 5)
    OR (paramcount < 2) then
      Syntax;

              (* Process first parameter.                                     *)
    case pos(paramstr(1), co_Params1) of
       1, 2 : bo_Encoding := true;      (* 'e'  or 'E'                        *)
       3, 4 :;                          (* 'd'  or 'D'                        *)
       7, 8 : bo_TestMode := true;      (* 't'  or 'T'                        *)
       5, 9 : begin                     (* 'es' or 'ES'                       *)
                bo_Encoding    := true;
                bo_SplitOutput := true
              end
    else
      Syntax
    end;
              (* Assign the name of the input file.                           *)
    fsplit(fexpand(paramstr(2)), st_DirIN, st_NameIN, st_ExtIN);

              (* If we are encoding binary data, then...                      *)
    if bo_Encoding then
      begin
              (* Set encoded column size.                                     *)
        if (paramcount > 2) then
          begin
            wo_EncColSize := Str2Long(paramstr(3), false);

              (* Force size to a multiple of 4.                               *)
            wo_EncColSize := (wo_EncColSize SHR 2) SHL 2;

              (* If column size is too small or too big, use default size.    *)
            If (wo_EncColSize < co_MinCol)
            OR (wo_EncColSize > co_MaxCol) then
              wo_EncColSize := co_ColDef;

              (* Assign column size to the encoded block header.              *)
            Word2Char2(wo_EncColSize, co_Header2.FCols)
          end
        else
          wo_EncColSize := co_ColDef;

              (* Set encoded block row size.                                  *)
        if (paramcount > 3) then
          begin
            wo_EncRowSize := Str2Long(paramstr(4), false);

              (* If row size is too small or too big, use default size.       *)
            If (wo_EncRowSize < co_MinRow)
            OR (wo_EncRowSize > co_MaxRow) then
              wo_EncRowSize := co_RowDef;

              (* Assign row size to the encoded block header.                 *)
            Word2Char2(wo_EncRowSize, co_Header2.FRows)
          end
        else
          wo_EncRowSize := co_RowDef;

              (* Set alternative encoded block delimiter.                     *)
        if (paramcount = 5) then
          case pos(UpStr(paramstr(5)), co_AltDelStr) of
           1 : SetAltDel(co_AltDelSet[1]);
           4 : SetAltDel(co_AltDelSet[2]);
           7 : SetAltDel(co_AltDelSet[3]);
          10 : SetAltDel(co_AltDelSet[4]);
          13 : SetAltDel(co_AltDelSet[5]);
          16 : SetAltDel(co_AltDelSet[6]);
          19 : SetAltDel(co_AltDelSet[7]);
          22 : SetAltDel(co_AltDelSet[8]);
          25 : SetAltDel(co_AltDelSet[9]);
        else
          Syntax
        end
      end
  end;        (* ProcessParams.                                               *)


  (***** Check if a file exists.                                              *)
  (*                                                                          *)
  function FileExist({input}
                        st_Path : pathstr) :
                     {output}
                        boolean;
  begin
    FileExist := (FSearch(st_Path, '') <> '')
  end;        (* FileExist.                                                   *)


  (***** Close file variable *only* if open.                                  *)
  (*                                                                          *)
  procedure CloseFile({update}
                      var fi_IN);
  begin
    case filerec(fi_IN).mode of
      fminput,
      fmoutput,
      fminout  : close(file(fi_IN))
    end;
    if (ioresult <> 0) then
      halt(1)
  end;        (* CloseFile.                                                   *)


var
  wo_EncBlockNum : word;
  lo_FileTime    : longint;
  st_NameOUT     : namestr;
  st_ExtOUT      : extstr;
  st_FilenameOUT : T_St12;
  fi_IN          : file;
  fi_OUT         : file;


  (***** Close all data files.                                                *)
  (*                                                                          *)
  procedure CloseDataFiles;
  begin
              (* Close input file.                                            *)
    CloseFile(fi_IN);

              (* If not test-mode, then...                                    *)
    if NOT bo_TestMode then
      begin
              (* If decoding and output file is not corrupt, then...          *)
        if  (NOT bo_Encoding)
        AND (NOT bo_EraseOutFile) then
          begin

              (* Set the output file date to the original binary file date.   *)
            setftime(fi_OUT, lo_FileTime);
            if (doserror <> 0) then
              begin
                writeln(co_CrLf, 'ERROR SETTING DECODED FILE DATE ATTRIBUTE');
                halt(1)
              end
          end;

              (* Close output file.                                           *)
        CloseFile(fi_OUT);

              (* If output file is corrupt, then errase it.                   *)
        if bo_EraseOutFile then
          begin
            erase(fi_OUT);
            writeln(co_CrLf, 'OUTPUT FILE (', st_FilenameOUT, ') ERASED');
            halt(1)
          end
      end
  end;         (* CloseDataFiles.                                             *)


var
  bo_FileSizeFail  : boolean;
  bo_FileDateFail  : boolean;
  bo_BlockSizeFail : boolean;
  bo_FileNameFail  : boolean;


  (***** Convert byte to block number string.                                 *)
  (*                                                                          *)
  function BlockNumStr({input }
                          by_Block : byte) :
                       {output}
                          T_St2;
  var
    st_Num : T_St2;
  begin
    if bo_HexMode then
      BlockNumStr := Byte2Hex(by_Block)
    else
      begin
        str(by_Block, st_Num);
        BlockNumStr := st_Num
      end
  end;        (* WriteBlockNum                                                *)


  (***** Display error message.                                               *)
  (*                                                                          *)
  procedure ErrorMsg({input }
                      const st_Path  : pathstr;
                            by_Block : byte;
                            by_Lfeed : byte;
                            in_Error : integer;
                            bo_Halt  : boolean);
  var
    by_Index : byte;
  begin
    for by_Index := 1 to by_Lfeed do
      writeln;
    case in_Error of
        2 : writeln('FILE NOT FOUND ---> ', st_Path);
        4 : writeln('TOO MANY FILES OPEN');
        5 : writeln('FILE ACCESS DENIED ---> ', st_Path);
       15 : writeln('INVALID DRIVE ---> ', st_Path[1] + ':');
      100 : writeln('DISK ', st_Path[1], ': READ ERROR');
      101 : writeln('DISK ', st_Path[1], ': WRITE ERROR');
      150 : writeln('DISK ', st_Path[1], ': IS WRITE PROTECTED');
      152 : writeln('DRIVE ', st_Path[1], ': NOT READY');
      500 : writeln('ZERO BYTE FILE (CONTAINS NO DATA) ---> ', st_Path);
      501 : writeln('FILE IS TOO LARGE TO ENCODE ---> ', st_Path);
      502 : writeln('XX-BLOCK SIZE IS TOO SMALL TO ENCODE ---> ', st_Path);
      503 : writeln('CANNOT OVERWRITE FILE TO ENCODE');
      504 : writeln('NOT ENOUGH FREE MEMORY');
      505 : writeln('XX34 HEADER ID NOT FOUND');
      506 : writeln('INVALID FILE SIZE ---> BLOCK ', BlockNumStr(by_Block));
      507 : writeln('BLOCK NUMBER GREATER THAN BLOCK TOTAL ---> BLOCK ', BlockNumStr(by_Block));
      508 : writeln('XX HEADER FILE SIZES DO NOT MATCH ---> BLOCK ', BlockNumStr(by_Block));
      509 : writeln('XX HEADER FILE DATES DO NOT MATCH ---> BLOCK ', BlockNumStr(by_Block));
      510 : writeln('XX HEADER COLUMN/ROW SIZES DO NOT MATCH ---> BLOCK ', BlockNumStr(by_Block));
      511 : writeln('XX HEADER FILE NAMES DO NOT MATCH ---> BLOCK ', BlockNumStr(by_Block));
      512 : writeln('CANNOT OVERWRITE FILE TO DECODE');
      513 : writeln('OUTPUT FILE IS READ-ONLY ---> ', st_Path);
      514 : writeln('ERROR CONVERTING DATE-STRING TO DATE-RECORD FORMAT');
      515 : writeln('CRC FAILURE ---> BLOCK ', BlockNumStr(by_Block))
    else
      writeln('DOS ERROR = ', in_Error)
    end;
    if bo_Halt then
      begin
        CloseDataFiles;
        halt(1)
      end
  end;        (* ErrorMsg.                                                    *)


var
  in_Error         : integer;
  wo_EncBlockSize  : word;
  wo_BinBlockSize  : word;
  wo_EncBlockTotal : word;
  lo_FileSizeIN    : longint;
  rc_FileDate      : datetime;


  (***** Open input and output files.                                         *)
  (*                                                                          *)
  procedure OpenFiles;
  var
    st_Temp : T_St8;
  begin
              (* Check if input file exists.                                  *)
    if FileExist(st_DirIN + st_NameIN + st_ExtIN) then
      assign(fi_IN, (st_DirIN + st_NameIN + st_ExtIN))
    else
      ErrorMsg((st_DirIN + st_NameIN + st_ExtIN), 0, 1, 2, true);

              (* Set TP's filemode variable to read-only.                     *)
    filemode := 0;

              (* Try to open the input file.                                  *)
    reset(fi_IN, 1);
    in_Error := ioresult;
    if (in_Error <> 0) then
      ErrorMsg((st_DirIN + st_NameIN + st_ExtIN), 0, 1, in_Error, true);

              (* Record the input file size in bytes.                         *)
    lo_FileSizeIN := filesize(fi_IN);

              (* Check if input file is a "zero-byte" file.                   *)
    if (lo_FileSizeIN = 0) then
      ErrorMsg((st_DirIN + st_NameIN + st_ExtIN), 0, 1, 500, true);

              (* If encoding, then...                                         *)
    if bo_Encoding then
      begin
              (* Check if input file is too big to encode.                    *)
        if (lo_FileSizeIN > co_MaxFileSize) then
          ErrorMsg((st_DirIN + st_NameIN + st_ExtIN), 0, 1, 501, true);

              (* Calculate encoded block size.                                *)
        wo_EncBlockSize := wo_EncColSize * pred(wo_EncRowSize);

              (* Calculate binary block size.                                 *)
        wo_BinBlockSize := (wo_EncBlockSize div 4) * 3;

              (* Calculate total number of encoded blocks required.           *)
        wo_EncBlockTotal := (lo_FileSizeIN div wo_BinBlockSize);
        if ((lo_FileSizeIN mod wo_BinBlockSize) <> 0) then
          inc(wo_EncBlockTotal);

              (* If encoded block total is equal to one, do not split output. *)
        if (wo_EncBlockTotal = 1) then
          bo_SplitOutput := false;

              (* If binary block size is too small to encode the input file.  *)
        if (wo_EncBlockTotal > co_BlockMax) then
          ErrorMsg((st_DirIN + st_NameIN + st_ExtIN), 0, 1, 502, true);

              (* Set hex-mode flag if block total is greater than 99, or if   *)
              (* binary file size is greater than 999,999 bytes.              *)
        bo_HexMode := (wo_EncBlockTotal > 99) OR (lo_FileSizeIN > 999999);

              (* If hex-mode, then set encoded block header hex-flag.         *)
        if bo_HexMode then
          co_Header2.HexFlag := 'H';

              (* Read input file date.                                        *)
        getftime(fi_IN, lo_FileTime);
        in_Error := doserror;
        if (in_Error <> 0) then
          ErrorMsg((st_DirIN + st_NameIN + st_ExtIN), 0, 1, in_Error, true);
        unpacktime(lo_FileTime, rc_FileDate);

              (* Assign input file date to the encoded header.                *)
        with rc_FileDate do
          begin
            Long2Str(day,   2, co_Header2.Fday);
            Long2Str(month, 2, co_Header2.Fmonth);
            if (year < co_NextCentury) then
              dec(year, co_ThisCentury)
            else
              dec(year, co_NextCentury);
            Long2Str(year,  2, co_Header2.Fyear)
          end;

              (* Assign input file size to the encoded header.                *)
        if bo_HexMode then
          begin
            st_Temp := Long2Hex(lo_FileSizeIN);
            delete(st_Temp, 1, 2);
            move(st_Temp[1], co_Header2.Size, 6)
          end
        else
          Long2Str(lo_FileSizeIN, 6, co_Header2.Size);

              (* Assign input filename to the encoded header.                 *)
        with co_Header2 do
          begin
            move(st_NameIN[1], Fname[9 - length(st_NameIN)], length(st_NameIN));
            move(st_ExtIN[1],  Fname[9], length(st_ExtIN))
          end;

              (* Assign encoded block total to the encoded header.            *)
        Word2Char2(wo_EncBlockTotal, co_Header2.BlockTot);

              (* Assign input file name to output file name.                  *)
        st_NameOUT := st_NameIN;

              (* Assign output file extension.                                *)
        if bo_SplitOutput then
          st_ExtOUT := '.X01'
        else
          st_ExtOUT  := '.XX';

              (* Assign output filename.                                      *)
        assign(fi_OUT, (st_NameOUT + st_ExtOUT));

              (* Check if output file already exists.                         *)
        if FileExist(st_NameOUT + st_ExtOUT) then
          begin

              (* File exists, is it OK to overwrite this file?                *)
            write(co_CrLf, st_NameOUT + st_ExtOUT, ' already exists. Overwrite? [Y/N] ');
            case YesNoRename of

              (* No it's NOT OK to overwrite this file. STOP!                 *)
              'N' : begin
                      writeln(co_CrLf, 'ENCODING ABORTED');
                      CloseDataFiles;
                      halt(0)
                    end;

              (* Yes it's OK to overwrite this file.                          *)
              'Y' : begin

              (* You cannot overwrite the file you want to encode.            *)
                      if ((st_NameIN + st_ExtIN) = (st_NameOUT + st_ExtOUT)) then
                        ErrorMsg('', 0, 1, 503, true);

              (* Rewrite output file.                                         *)
                      rewrite(fi_OUT, 1);
                      in_Error := ioresult;
                      if (in_Error <> 0) then
                        ErrorMsg(fexpand(st_NameOUT + st_ExtOUT), 0, 1, in_Error, true)
                    end
            end
          end

              (* Else, the file does not exist.                               *)
        else
          begin
              (* Create the output file.                                      *)
            rewrite(fi_OUT, 1);
            in_Error := ioresult;
            if (in_Error <> 0) then
              ErrorMsg(fexpand(st_NameOUT + st_ExtOUT), 0, 1, in_Error, true)
          end
      end
  end;        (* OpenFiles.                                                   *)


var
  wo_MaxBlockSize : word;
  wo_EncBuffSize  : word;
  wo_BinBuffSize  : word;
  po_HeapMark     : pointer;
  po_EncBuff      : T_EncBuffPtr;
  po_BinBuff      : T_BinBuffPtr;


  (***** Create data buffers.                                                 *)
  (*                                                                          *)
  procedure CreateBuffers;
  begin
              (* Determine buffer sizes.                                      *)
    if bo_Encoding then
              (* Encoded block size + size of CrLf's + 128 for header/footer. *)
      wo_MaxBlockSize := wo_EncBlockSize + (wo_EncRowSize SHL 1) + 128;
    wo_EncBuffSize := wo_MaxBlockSize;
    wo_BinBuffSize := (wo_EncBuffSize SHR 2) * 3;

              (* Allocate buffers.                                            *)
    mark(po_HeapMark);
    getmem(po_BinBuff, wo_BinBuffSize);
    if (po_BinBuff = NIL) then
      ErrorMsg('', 0, 1, 504, true);
    getmem(po_EncBuff, wo_EncBuffSize);
    if (po_EncBuff = NIL) then
      ErrorMsg('', 0, 1, 504, true)
  end;        (* CreateBuffers.                                               *)


var
  wo_BytesIN       : word;
  wo_BlockCount    : word;
  wo_EncBuffOffset : word;
  wo_SkipIndex     : word;


  (***** Set encoded block header.                                            *)
  (*                                                                          *)
  procedure SetEncHeader;
  begin
              (* Calculate and set the CRC-16 string for the encoded header.  *)
    Long2Str(CalcCRC16(po_BinBuff^, wo_BytesIN), 5, co_Header2.CrcValue);

              (* Set the encoded block's block number.                        *)
    Word2Char2(wo_BlockCount, co_Header2.Block);

              (* Write encoded block header to encoding buffer.               *)
    move(co_CrLf2, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_CrLf2));
    inc(wo_EncBuffOffset, sizeof(co_CrLf2));
    inc(wo_SkipIndex, sizeof(co_CrLf2));
    move(co_Header2, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_Header2));

              (* Advance the buffer index variables.                          *)
    inc(wo_EncBuffOffset,  sizeof(co_Header2));
    inc(wo_SkipIndex, sizeof(co_Header2))
  end;        (* SetEncHeader.                                                *)


  (***** Set encoded block footer.                                            *)
  (*                                                                          *)
  procedure SetEncFooter;
  var
    ar_BlockNum : T_Ch2;
  begin
              (* Write encoded block footer to the encoding buffer.           *)
    move(co_EndMark1, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_EndMark1));
    inc(wo_EncBuffOffset,  sizeof(co_EndMark1));
    inc(wo_SkipIndex, sizeof(co_EndMark1));
    move(co_EndMark2, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_EndMark2));
    inc(wo_EncBuffOffset,  sizeof(co_EndMark2));
    inc(wo_SkipIndex, sizeof(co_EndMark2));
    Word2Char1(wo_BlockCount, ar_BlockNum);
    move(ar_BlockNum, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(ar_BlockNum));
    inc(wo_EncBuffOffset, sizeof(ar_BlockNum));
    inc(wo_SkipIndex, sizeof(ar_BlockNum));

    if bo_HexMode then
      begin
        if (po_EncBuff^[wo_EncBuffOffset] = #32) then
          po_EncBuff^[wo_EncBuffOffset] := 'h'
        else
          begin
            po_EncBuff^[succ(wo_EncBuffOffset)] := 'h';
            inc(wo_EncBuffOffset);
            inc(wo_SkipIndex)
          end
      end;

    if (po_EncBuff^[wo_EncBuffOffset] <> #32) then
      begin
        po_EncBuff^[succ(wo_EncBuffOffset)] := #32;
        inc(wo_EncBuffOffset);
        inc(wo_SkipIndex)
      end;

    move(co_EndMark1, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_EndMark1));
    inc(wo_EncBuffOffset,  sizeof(co_EndMark1));
    inc(wo_SkipIndex, sizeof(co_EndMark1));
    move(co_CrLf2, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_CrLf2));
    inc(wo_EncBuffOffset,  sizeof(co_CrLf2));
    inc(wo_SkipIndex, sizeof(co_CrLf2))
  end;        (* SetEncFooter.                                                *)


  (***** Open new output file.                                                *)
  (*                                                                          *)
  procedure OpenNewFile;
  var
    st_Temp : T_St3;
  begin
              (* Close output file.                                           *)
    close(fi_OUT);
    in_Error := ioresult;
    if (in_Error <> 0) then
      ErrorMsg(fexpand(st_NameOUT + st_ExtOUT), 0, 1, in_Error, true);

              (* Create new ouput file extension.                             *)
    st_Temp := BlockNumStr(lo(wo_BlockCount));
    move(st_Temp[1], st_ExtOUT[5 - length(st_Temp)], length(st_Temp));

              (* Open new output file.                                        *)
    assign(fi_OUT, (st_NameOUT + st_ExtOUT));
    rewrite(fi_OUT, 1);
    in_Error := ioresult;
    if (in_Error <> 0) then
      ErrorMsg(fexpand(st_NameOUT + st_ExtOUT), 0, 1, in_Error, true)
  end;        (*  OpenNewFile.                                                *)


var
  wo_BytesOUT      : word;
  wo_BinBuffOffset : word;


  (***** Encode binary file.                                                  *)
  (*                                                                          *)
  procedure Encode34;
  var
    lo_BytesEncoded : longint;
  begin

    CreateBuffers;

              (* Display encoding message.                                    *)
    writeln(co_CrLf, 'ENCODING BLOCK');

              (* Initialize variables.                                        *)
    wo_BlockCount   := 0;
    lo_BytesEncoded := 0;

              (* Repeat until entire binary file has been encoded.            *)
    repeat

      wo_SkipIndex     := 0;
      wo_BinBuffOffset := 0;
      wo_EncBuffOffset := 0;

              (* Clear the data buffers.                                      *)
      fillchar(po_BinBuff^, wo_BinBuffSize, 0);
      fillchar(po_EncBuff^, wo_EncBuffSize, 0);

              (* Fill the input buffer.                                       *)
      blockread(fi_IN, po_BinBuff^, wo_BinBlockSize, wo_BytesIN);
      in_Error := ioresult;
      if (in_Error <> 0) then
        ErrorMsg(fexpand(st_NameIN + st_ExtIN), 0, 1, in_Error, true);

              (* Ensure the number of bytes to encode is a multiple of 3.     *)
      if ((wo_BytesIN mod 3) <> 0) then
        wo_BytesIN := succ(wo_BytesIN div 3) * 3;

              (* Advance encoded block counter.                               *)
      inc(wo_BlockCount);

              (* Display block number being encoded.                          *)
      write(BlockNumStr(lo(wo_BlockCount)):4);

              (* Write encoded block header to output buffer.                 *)
      SetEncHeader;

      repeat  (* Until all bytes in the input buffer are processed.           *)

              (* Encode 3 input bytes into 4 encoded XX output characters.    *)
        po_EncBuff^[succ(wo_EncBuffOffset)] :=
                                          co_XxChar1[(po_BinBuff^[succ(wo_BinBuffOffset)] SHR 2)];

        po_EncBuff^[wo_EncBuffOffset + 2] :=
                  co_XxChar1[((po_BinBuff^[succ(wo_BinBuffOffset)] AND 3) SHL 4)
                                                    OR (po_BinBuff^[wo_BinBuffOffset + 2] SHR 4)];

        po_EncBuff^[wo_EncBuffOffset + 3] :=
                   co_XxChar1[((po_BinBuff^[wo_BinBuffOffset + 2] AND 15) SHL 2)
                                                    OR (po_BinBuff^[wo_BinBuffOffset + 3] SHR 6)];

        po_EncBuff^[wo_EncBuffOffset + 4] :=
                         co_XxChar1[(po_BinBuff^[wo_BinBuffOffset + 3] AND 63)];

              (* Advance the buffer indexes.                                  *)
        inc(wo_BinBuffOffset, 3);
        inc(wo_EncBuffOffset, 4);

              (* If encoded character row is complete, then...                *)
        if (((wo_EncBuffOffset - wo_SkipIndex) mod wo_EncColSize) = 0) then
          begin

              (* Add a CrLf to the encoded buffer.                            *)
            move(co_CrLf, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_CrLf));

              (* Advance the buffer indexes.                                  *)
            inc(wo_EncBuffOffset, sizeof(co_CrLf));
            inc(wo_SkipIndex, sizeof(co_CrLf))
          end

              (* Until all bytes in the input buffer are processed.           *)
      until (wo_BinBuffOffset >= wo_BytesIN);

              (* If the last line of encoded output is not complete,then...   *)
      if (((wo_EncBuffOffset - wo_SkipIndex) mod wo_EncColSize) <> 0) then
        begin
              (* Add a CrLf to the encoding buffer.                           *)
          move(co_CrLf, po_EncBuff^[succ(wo_EncBuffOffset)], sizeof(co_CrLf));

              (* Advance the buffer indexes.                                  *)
          inc(wo_EncBuffOffset, sizeof(co_CrLf));
          inc(wo_SkipIndex, sizeof(co_CrLf))
        end;

              (* Write encoded block footer to the output buffer.             *)
      SetEncFooter;

              (* If encoded output is split, then...                          *)
      if  bo_SplitOutput
      AND (wo_BlockCount > 1) then
        OpenNewFile;

              (* Write encoded buffer to output file.                         *)
      blockwrite(fi_OUT, po_EncBuff^, wo_EncBuffOffset, wo_BytesOUT);
      in_Error := ioresult;
      if (in_Error <> 0) then
        ErrorMsg(fexpand(st_NameOUT + st_ExtOUT), 0, 1, in_Error, true);
      inc(lo_BytesEncoded, wo_BinBuffOffset)
    until (lo_BytesEncoded >= lo_FileSizeIN);

              (* Release heap memory used.                                    *)
    release(po_HeapMark);
    writeln
  end;        (* Encode34.                                                    *)


var
  wo_ScanPos : word;


  (***** Scan input file for encoded block identifier.                        *)
  (*                                                                          *)
  procedure ScanForXxID;
  var
    wo_Index : word;
  begin
              (* Display scanning message.                                    *)
    write(co_CrLf, 'SCANNING FOR BLOCK IDENTIFIER');

              (* Calculate buffer size.                                       *)
    if (lo_FileSizeIN < (60 * 1024)) then
      wo_EncBuffSize := lo_FileSizeIN
    else
      wo_EncBuffSize := 60 * 1024;

              (* Create scan buffer.                                          *)
    mark(po_HeapMark);
    getmem(po_EncBuff, wo_EncBuffSize);
    if (po_EncBuff = NIL) then
      ErrorMsg('', 0, 2, 504, true);

              (* Clear scan buffer.                                           *)
    fillchar(po_EncBuff^, wo_EncBuffSize, 0);

              (* Load the scan buffer.                                        *)
    blockread(fi_IN, po_EncBuff^, wo_EncBuffSize, wo_BytesIN);
    in_Error := ioresult;
    if (in_Error <> 0) then
      ErrorMsg(fexpand(st_DirIN + st_NameIN + st_ExtIN), 0, 1, in_Error, true);

              (* Search for encoded block ID.                                 *)
    wo_Index := 1;
    repeat
      wo_ScanPos := PosSearch(po_EncBuff^, wo_EncBuffSize, co_XxBlockID);

              (* If encoded block ID was not found, then...                   *)
      if (wo_ScanPos = 0) then
        begin

              (* If all 10 ID delimiters were tried, and version number = '2' *)
          if  (wo_Index = 10)
          AND (co_XxBlockID[7] = '2') then
            begin

              (* Set version number to '1'.                                   *)
              co_XxBlockID[7] := '1';

              (* Reset loop variable.                                         *)
              wo_Index := 0
            end;

              (* Set new block ID delimiter.                                  *)
          if (wo_Index < 10) then
            co_XxBlockID[1] := co_AltDelSet[wo_Index];

              (* Advance loop variable.                                       *)
          inc(wo_Index)
        end
    until (wo_ScanPos <> 0) OR (wo_Index = 11);

              (* If block ID was not found, then...                           *)
    if (wo_ScanPos = 0) then
      begin
        writeln;
        ErrorMsg('', 0, 1, 505, true)
      end
    else
      writeln('  OK')
  end;        (* ScanForXxID.                                                 *)


var
  lo_EncFileOffset  : longint;
  lo_FileSizeOUT    : longint;
  ar_BinFileDate    : T_3Ch2;
  ar_Crc16          : T_Wo255;
  ar_EncBlockFound  : T_By256;
  ar_EncBlockPos    : T_Lo255;
  ar_BinBlockSize   : T_Wo255;
  ar_PhysBlockSize  : T_Lo255;


  (***** Scan for all encoded block headers.                                  *)
  (*                                                                          *)
  procedure ScanForXxHeaders;
  var
    wo_Index,
    wo_TempColSize,
    wo_TempRowSize,
    wo_TempBlockNum,
    wo_TempBlockSize,
    wo_TempBlockTotal : word;
    lo_Temp,
    lo_TempFileSize   : longint;
    ar_TempFileDate   : T_3Ch2;
    st_TempOutName    : T_St12;
  begin
              (* Display new message.                                         *)
    write('SCANNING FOR BLOCK HEADERS');
    bo_FileSizeFail  := false;
    bo_FileDateFail  := false;
    bo_BlockSizeFail := false;
    bo_FileNameFail  := false;
    wo_EncBuffOffset := 0;
    wo_BlockCount    := 0;
    lo_EncFileOffset := 0;
    fillchar(ar_EncBlockFound, sizeof(ar_EncBlockFound), 0);
    fillchar(ar_Crc16, sizeof(ar_Crc16), 0);
    fillchar(ar_EncBlockPos, sizeof(ar_EncBlockPos), 0);
    fillchar(ar_BinBlockSize, sizeof(ar_BinBlockSize), 0);
    fillchar(ar_PhysBlockSize, sizeof(ar_PhysBlockSize), 0);

              (* Repeat until the entire input file has been scanned.         *)
    repeat
              (* Determine XX34 header position in the encoded buffer.        *)
      wo_ScanPos := PosSearch(po_EncBuff^[succ(wo_EncBuffOffset)],
                                 (wo_BytesIN - (wo_EncBuffOffset + co_HeaderSize)), co_XxBlockID);

              (* If an encoded header was found, then...                      *)
      if (wo_ScanPos <> 0) then
        begin
              (* Record encoded header position, and advance block count.     *)
          inc(wo_EncBuffOffset, wo_ScanPos);
          inc(wo_BlockCount);

              (* Clear the initialed encoded header variable.                 *)
          fillchar(co_Header1, sizeof(co_Header1), 0);

              (* Copy the encoded header found to the header variable.        *)
          move(po_EncBuff^[wo_EncBuffOffset], co_Header1, sizeof(co_Header1));

              (* Process encoded header data.                                 *)
          with co_Header2 do
            begin
              bo_HexMode := (HexFlag = 'H');

              lo_TempFileSize := Str2Long(Size, bo_HexMode);

              if (lo_TempFileSize = co_NumError)
              or (lo_TempFileSize < 1) then
                ErrorMsg('', lo(wo_BlockCount), 2, 506, true);

              ar_TempFileDate[1] := Fday;
              ar_TempFileDate[2] := Fmonth;
              ar_TempFileDate[3] := Fyear;

              wo_TempColSize := Str2Long(FCols, false);
              wo_TempRowSize := Str2Long(FRows, false);

              st_TempOutName := Fname;

              wo_TempBlockNum   := Str2Long(Block,    bo_HexMode);
              wo_TempBlockTotal := Str2Long(BlockTot, bo_HexMode);

              ar_Crc16[wo_TempBlockNum] := Str2Long(CrcValue, false)
            end;

              (* Check if block number from the encoded header is valid.      *)
          if (wo_TempBlockNum > wo_TempBlockTotal) then
            ErrorMsg('', lo(wo_BlockCount), 2, 507, true);

              (* Record encoded block number found.                           *)
          inc(ar_EncBlockFound[wo_TempBlockNum]);

              (* Assign the encoded block file position.                      *)
          if (ar_EncBlockPos[wo_TempBlockNum] = 0) then
            inc(ar_EncBlockPos[wo_TempBlockNum], wo_EncBuffOffset);
          if (lo_EncFileOffset <> 0) then
            inc(ar_EncBlockPos[wo_TempBlockNum], lo_EncFileOffset);

              (* Calculate temp encoded block size.                           *)
          wo_TempBlockSize := pred(wo_TempRowSize) * (wo_TempColSize + 2);

              (* Record temp encoded block size.                              *)
          ar_BinBlockSize[wo_TempBlockNum] :=
                                            (((wo_TempColSize * pred(wo_TempRowSize)) SHR 2) * 3);

              (* If this is physically the first encoded block, record the    *)
              (* encoded block values.                                        *)
          if (wo_BlockCount = 1 ) then
            begin
              lo_FileSizeOUT   := lo_TempFileSize;
              ar_BinFileDate   := ar_TempFileDate;
              wo_EncRowSize    := wo_TempRowSize;
              wo_EncBlockSize  := wo_TempBlockSize;
              st_FilenameOUT   := st_TempOutName;
              wo_EncBlockTotal := wo_TempBlockTotal
            end

              (* Else, this is not the first block found, check for errors.   *)
          else
            begin
              if (lo_TempFileSize <> lo_FileSizeOUT)
              AND (bo_FileSizeFail = false) then
                byte(bo_FileSizeFail) := wo_TempBlockNum;

              if  (T_Ch6(ar_TempFileDate) <> T_Ch6(ar_BinFileDate))
              AND (bo_FileDateFail = false) then
                byte(bo_FileDateFail) := wo_TempBlockNum;

              if  (wo_TempBlockSize <> wo_EncBlockSize)
              AND (bo_BlockSizeFail = false) then
                byte(bo_BlockSizeFail) := wo_TempBlockNum;

              If (st_TempOutName <> st_FilenameOUT)
              AND (bo_FileNameFail = false) then
                byte(bo_FileNameFail) := wo_TempBlockNum
            end;

              (* Advance the encoded buffer index.                            *)
          if (wo_EncBuffOffset < (wo_BytesIN - co_HeaderSize)) then
            inc(wo_EncBuffOffset, co_HeaderSize)
        end

              (* Else, no additional encoded headers were found.              *)
      else
        begin
              (* Advance the input file offset.                               *)
          inc(lo_EncFileOffset, (wo_BytesIN - co_HeaderSize));

              (* If input file not completely scanned, then reload buffer.    *)
          if ((lo_EncFileOffset + co_HeaderSize) < lo_FileSizeIN) then
            begin

              (* Reset control variables.                                     *)
              wo_EncBuffOffset := 0;

              (* Clear scan buffer.                                           *)
              fillchar(po_EncBuff^, wo_EncBuffSize, 0);

              (* Reset input file pointer.                                    *)
              seek(fi_IN, lo_EncFileOffset);
              in_Error := ioresult;
              if (in_Error <> 0) then
                ErrorMsg(fexpand(st_NameIN + st_ExtIN), 0, 1, in_Error, true);

              (* Load the scan buffer.                                        *)
              blockread(fi_IN, po_EncBuff^, wo_EncBuffSize, wo_BytesIN);
              in_Error := ioresult;
              if (in_Error <> 0) then
                ErrorMsg(fexpand(st_NameIN + st_ExtIN), 0, 1, in_Error, true)
            end
        end
              (* Until the entire input file has been scanned.                *)
    until (lo_EncFileOffset + co_HeaderSize) > pred(lo_FileSizeIN);

              (* Release heap memory used.                                    *)
    release(po_HeapMark);
    writeln('     OK');

              (* Encoded block size + 2x CrLF size + 128 for header/footer.   *)
    wo_MaxBlockSize := wo_EncBlockSize + (wo_EncRowSize SHL 2) + 128;

              (* Set the maximum physical size for encoded blocks.            *)
    for wo_Index := 1 to wo_EncBlockTotal do
      if (ar_EncBlockFound[wo_Index] = 1) then
        ar_PhysBlockSize[wo_Index] := wo_MaxBlockSize;

              (* Calculate binary size of last encoded block.                 *)
    wo_Index := 1;
    while (ar_EncBlockFound[wo_Index] <> 1)
    and   (wo_Index < wo_EncBlockTotal) do
      inc(wo_Index);
    lo_Temp := lo_FileSizeOUT - (longint(ar_BinBlockSize[wo_Index]) * pred(wo_EncBlockTotal));
    if (lo_Temp < ar_BinBlockSize[wo_Index]) then
      begin
        ar_BinBlockSize[wo_EncBlockTotal]  := lo_Temp;
        ar_PhysBlockSize[wo_EncBlockTotal] := ((lo_Temp div 3) SHL 2) + (wo_EncRowSize SHL 2)
      end
  end;        (* ScanForXxHeaders.                                            *)


  (***** Check for encoded block errors.                                      *)
  (*                                                                          *)
  procedure CheckForXxErrors;
  var
    wo_Index : word;
  begin
              (* Display error checking message.                              *)
    write('CHECKING FOR BLOCK ERRORS');

              (* Check for encoded block data errors.                         *)
    if bo_FileSizeFail then
      ErrorMsg('', byte(bo_FileSizeFail),  2, 508, true);

    if bo_FileDateFail then
      ErrorMsg('', byte(bo_FileDateFail),  2, 509, true);

    if bo_BlockSizeFail then
      ErrorMsg('', byte(bo_BlockSizeFail), 2, 510, true);

    if bo_FileNameFail then
      ErrorMsg('', byte(bo_FileNameFail),  2, 511, true);

              (* Check for duplicate/missing encoded blocks.                  *)
    for wo_Index := 1 to wo_EncBlockTotal do
      if (ar_EncBlockFound[wo_Index] <> 1) then
        inc(ar_EncBlockFound[0]);

              (* If a duplicate/missing encoded block found, then...          *)
    if (ar_EncBlockFound[0] <> 0) then
      begin
        writeln('     FAIL');
        writeln;
        for wo_Index := 1 to wo_EncBlockTotal do
          if (ar_EncBlockFound[wo_Index] > 1) then
            writeln('DUPLICATE BLOCK ', BlockNumStr(lo(wo_Index)))
          else
            if (ar_EncBlockFound[wo_Index] = 0) then
              writeln('  MISSING BLOCK ', BlockNumStr(lo(wo_Index)));
        if NOT bo_TestMode then
          begin
            CloseDataFiles;
            halt(1)
          end
      end
    else
      writeln('      OK')
  end;        (* CheckForXxErrors.                                            *)


  (***** Remove '-' chars from filename.                                      *)
  (*                                                                          *)
  procedure CleanFileName;
  begin
    while (st_FilenameOUT[1] = '-') do
      delete(st_FilenameOUT, 1, 1);
    while (st_FilenameOUT[length(st_FilenameOUT)] = '-') do
      delete(st_FilenameOUT, length(st_FilenameOUT), 1)
  end;        (* CleanFileName.                                               *)


  (***** Prepare the output file for the decoded binary data.                 *)
  (*                                                                          *)
  procedure CheckOutputFile;
  label
    CheckAgain;
  var
    wo_FileAttr : word;
  begin
              (* Assign the output file name.                                 *)
    assign(fi_OUT, st_FilenameOUT);

              (* Check if binary output file already exists.                  *)
    if FileExist(st_FilenameOUT) then
      begin

  CheckAgain:

              (* Check to see if it's OK to over-write this file.             *)
        write(co_CrLf, st_FilenameOUT,' already exists. Overwrite? [Y/N/R] ');
        case YesNoRename of

              (* NO it's NOT OK to overwrite this file. STOP!                 *)
          'N' : begin
                  writeln(co_CrLf, 'DECODING ABORTED');
                  CloseDataFiles;
                  halt(0)
                end;

              (* Rename output filename.                                      *)
          'R' : begin
                  write('New output name? ');
                  st_FilenameOUT := EnterFilename;
                  writeln;

              (* If new name exists too, then start over.                     *)
                  if FileExist(st_FilenameOUT) then
                    goto CheckAgain;

              (* Create new output file.                                      *)
                  assign(fi_Out, st_FilenameOUT);
                  rewrite(fi_OUT, 1);
                  in_Error := ioresult;
                  if (in_Error <> 0) then
                    ErrorMsg(fexpand(st_FilenameOUT), 0, 1, in_Error, true)
                end;

              (* Yes it's OK to overwrite file.                               *)
          'Y' : begin

              (* You cannot overwrite the file you want to decode.            *)
                  if ((st_NameIN + st_ExtIN) = st_FilenameOUT) then
                    ErrorMsg('', 0, 1, 512, true);

              (* Check to see if the output file is 'READ-ONLY'.              *)
                  getfattr(fi_OUT, wo_FileAttr);
                  in_Error := doserror;
                  if (in_Error <> 0) then
                    ErrorMsg(fexpand(st_FilenameOUT), 0, 1, in_Error, true);
                  if ((wo_FileAttr AND 1) <> 0) then
                    ErrorMsg(fexpand(st_FilenameOUT), 0, 1, 513, true);

              (* Create new output file.                                      *)
                  rewrite(fi_OUT, 1);
                  in_Error := ioresult;
                  if (in_Error <> 0) then
                    ErrorMsg(fexpand(st_FilenameOUT), 0, 1, in_Error, true)
                end
        end
      end
              (* Else the file does not exist, create it.                     *)
    else
      begin
        rewrite(fi_OUT, 1);
        in_Error := ioresult;
        if (in_Error <> 0) then
          ErrorMsg(fexpand(st_FilenameOUT), 0, 1, in_Error, true)
      end
  end;        (* CheckOutputFile.                                             *)


  (***** Set the file date for the output file.                               *)
  (*                                                                          *)
  procedure PrepareFileDate;
  var
    in_Error : integer;
  begin
              (* Determine original binary file date from XxHeader            *)
    with rc_FileDate do
      begin
        val(ar_BinFileDate[3], year, in_Error);
        if (in_Error <> 0) then
          ErrorMsg('', 0, 1, 514, true);
        inc(year, co_ThisCentury);
        val(ar_BinFileDate[2], month, in_Error);
        if (in_Error <> 0) then
          ErrorMsg('', 0, 1, 514, true);
        val(ar_BinFileDate[1], day, in_Error);
        if (in_Error <> 0) then
          ErrorMsg('', 0, 1, 514, true);
        hour := 0;
        min  := 0;
        sec  := 0
      end;
    packtime(rc_FileDate, lo_FileTime)
  end;        (* PrepareFileDate.                                             *)


  (***** Decode/Test the encoded input file.                                  *)
  (*                                                                          *)
  procedure Decode43;
  var
    lo_BytesDecoded : longint;
  begin

    ScanForXxID;

    ScanForXxHeaders;

    CheckForXxErrors;

    if NOT bo_TestMode then
      begin
        CleanFileName;
        CheckOutputFile;
        PrepareFileDate
      end;

              (* Display testing/decoding message.                            *)
    if bo_TestMode then
      writeln(co_CrLf, 'TESTING BLOCK')
    else
      writeln(co_CrLf, 'DECODING BLOCK');

              (* Initialize variables.                                        *)
    wo_BytesOUT      := 0;
    wo_EncBlockNum   := 0;
    lo_BytesDecoded  := 0;
    lo_EncFileOffset := 0;

    CreateBuffers;

    repeat    (* Until the original binary file has been completely re-built. *)

              (* Advance the encoded block number to read into the buffer.    *)
      inc(wo_EncBlockNum);

              (* Advance the block number until an encoded block is found,    *)
              (* and block number is less than the encoded the block total.   *)
      while (ar_EncBlockFound[wo_EncBlockNum] <> 1)
      and   (wo_EncBlockNum < wo_EncBlockTotal) do
        inc(wo_EncBlockNum);

              (* If a valid block exists, then...                             *)
      if (ar_EncBlockFound[wo_EncBlockNum] = 1) then
        begin
              (* Initialize the buffer variables.                             *)
          wo_BinBuffOffset := 0;
          wo_EncBuffOffset := co_HeaderSize;

              (* Clear binary buffer.                                         *)
          fillchar(po_BinBuff^, wo_BinBuffSize, 0);

              (* Clear encoded buffer.                                        *)
          fillchar(po_EncBuff^, wo_EncBuffSize, 0);

              (* Position input file pointer.                                 *)
          seek(fi_IN, pred(ar_EncBlockPos[wo_EncBlockNum]));
          in_Error := ioresult;
          if (in_Error <> 0) then
            ErrorMsg(fexpand(st_DirIN + st_NameIN + st_ExtIN), 0, 1, in_Error, true);

              (* Load encoded block into buffer.                              *)
          blockread(fi_IN, po_EncBuff^, ar_PhysBlockSize[wo_EncBlockNum], wo_BytesIN);
          in_Error := ioresult;
          if (in_Error <> 0) then
            ErrorMsg(fexpand(st_DirIN + st_NameIN + st_ExtIN), 0, 1, in_Error, true);

              (* Display encoded block number.                                *)
          write(BlockNumStr(lo(wo_EncBlockNum)):4);

              (* Until entire encoded block is decoded.                       *)
          repeat

              (* Advance encoded buffer offset, while character is not in the *)
              (* XX character set.                                            *)
            while NOT (po_EncBuff^[succ(wo_EncBuffOffset)] IN co_XxChar2) do
              inc(wo_EncBuffOffset);

              (* Decode 4 encoded chars into 3 binary bytes.                  *)
            po_BinBuff^[succ(wo_BinBuffOffset)] :=
                                     (co_BinTable[ord(po_EncBuff^[succ(wo_EncBuffOffset)])] SHL 2)
                                 OR (co_BinTable[ord(po_EncBuff^[(wo_EncBuffOffset + 2)])] SHR 4);

            po_BinBuff^[wo_BinBuffOffset + 2] :=
                            ((co_BinTable[ord(po_EncBuff^[(wo_EncBuffOffset + 2)])] AND 15) SHL 4)
                                 OR (co_BinTable[ord(po_EncBuff^[(wo_EncBuffOffset + 3)])] SHR 2);

            po_BinBuff^[wo_BinBuffOffset + 3] :=
                             ((co_BinTable[ord(po_EncBuff^[(wo_EncBuffOffset + 3)])] AND 3) SHL 6)
                                OR (co_BinTable[ord(po_EncBuff^[(wo_EncBuffOffset + 4)])] AND 63);

              (* Advance buffer indexes.                                      *)
            inc(wo_EncBuffOffset, 4);
            inc(wo_BinBuffOffset, 3)

              (* Until encoded block is completely decoded.                   *)
          until (wo_BinBuffOffset > pred(ar_BinBlockSize[wo_EncBlockNum]));

              (* Compare new CRC value with encoded block header CRC value.   *)
          if (CalcCRC16(po_BinBuff^, wo_BinBuffOffset) <> ar_Crc16[wo_EncBlockNum]) then
            begin
              if NOT bo_TestMode then
                begin
                  bo_EraseOutFile := true;
                  ErrorMsg('', lo(wo_EncBlockNum), 2, 515, true)
                end
              else
                writeln(' CRC FAILED')
            end
          else
            if bo_TestMode then
              writeln(' CRC OK');

              (* Write the decoded binary bytes to disk.                      *)
          if NOT bo_TestMode then
            begin
              blockwrite(fi_OUT, po_BinBuff^, ar_BinBlockSize[wo_EncBlockNum], wo_BytesOUT);
              in_Error := ioresult;
              if (in_Error <> 0) then
                ErrorMsg(fexpand(st_FilenameOUT), 0, 1, in_Error, true);

              (* Advance the binary bytes decoded count.                      *)
              inc(lo_BytesDecoded, wo_BytesOUT)
            end
        end;

              (* If in "test mode", and last encoded block has been tested,   *)
              (* then break repeat until loop.                                *)
      if bo_TestMode AND (wo_EncBlockNum = wo_EncBlockTotal) then
        break

              (* Until original binary file has been rebuilt.                 *)
    until (lo_BytesDecoded > pred(lo_FileSizeOUT));

              (* Return buffer memory to the heap.                            *)
    release(po_HeapMark);

    if NOT bo_TestMode then
      writeln
  end;        (* Decode43.                                                    *)


  (***** Custom heap error function. Returns NIL pointer if error occurs.     *)
  (*                                                                          *)
  function CustHeapError({input}
                            wo_Size : word) :
                         {output}
                            integer; far;
  begin
    CustHeapError := 1
  end;        (* CustHeapError.                                               *)


BEGIN
              (* Install custom heap error function.                          *)
  HeapError := addr(CustHeapError);

  ProcessParams;
  OpenFiles;
  if bo_Encoding then
    Encode34
  else
    Decode43;
  CloseDataFiles
END.


