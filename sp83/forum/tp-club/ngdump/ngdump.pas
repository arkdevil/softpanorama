{$R+,I+,V-}

program ngdump;

uses crt, dos,
     BufIO;

const progname = 'NGDUMP';
      version  = 'V1.0';
      copyright = 'Copyright 1989 J.P.Pedersen, 1990 E.v.Asperen';

      MaxNameLen = 40;
      MaxLineLen = 160;

type gentry = record                    {General entry type}
                filptr:longint;
                name:string[MaxNameLen];
              end;
     line   = string[MaxLineLen];

var
     mennu:array[0..3,0..8] of gentry;  {Buffer to hold variable part of guide menu structure}
     itemlist:array[0..3] of byte;               {Menu structure info}
     errorinfo:array[3..6] of string[14];        {Buffer for error messages}
     f:file;                                                                                    {The guide file}
     propath,homedir,streng:string;              {String variables, mostly for path and file use}
     erro,
        seealsonum,
        menuantal,
        menunr : byte;                           {Byte variables}
     entrytype : (et_misc, et_short, et_long);
     guidename : line;

const MaxLevel = 10;
      OutBufSize   = 4096;

type FileBuffer = array [1..OutBufSize] of byte;

var  outf    : array [1..MaxLevel] of text;
     flevel  : 1..MaxLevel;
     OutBuf  : array [1..MaxLevel] of ^FileBuffer;
     Nfiles  : word;
     numentries : longint;



procedure threenitvars;                 {Initialize variables}
begin
    menunr := 0;
end;

procedure twonitvars;                   {Initialize variables}
begin
    threenitvars;
end;

procedure initvars;                     {Initialize variables}
var str5:string;
begin
    twonitvars;
    errorinfo[3] := 'File not found';
    errorinfo[4] := 'Not an NG file';
    errorinfo[5] := 'Unexpected EOF';
    errorinfo[6] := 'Corrupted file';
    str5 := '';propath := paramstr(0);
    while (pos('\',propath) > 0) do begin
        str5 := str5+copy(propath,1,pos('\',propath));
        propath := copy(propath,pos('\',propath)+1,length(propath)-(pos('\',propath)+1));
    end;
    propath := str5;
end;

var attr, startattr : byte;

procedure WriteNgString(var outf:text; s:string);
var i,j:byte;
    c:char;
begin
    i := 1;
    attr := startattr;
    while (i <= length(s)) do begin
        c := s[i];
        if c = #255 then begin
            {Expand spaces}
            inc(i);
            c := s[i];
            for j := 1 to ord(c) do begin
                write(outf, ' ');
            end;
        end
        else begin
            if (c = '!') and (i = 1) then write(outf, c);
            write(outf, c);
        end;
        inc(i);
    end;

    writeln(outf);
end;

procedure WriteString(s:string);
begin
  WriteNgString(outf[flevel], s);
end;

const Fx = 10; Fy = 2;
      Gx = 10; Gy = 3;
      Mx = 10; My = 5;
      Cx = 10; Cy = 7;
      Lx = 10; Ly = 8;
      Sx = 10; Sy = 10;


procedure ShowShort(s:string);
begin
  gotoxy(Sx, Sy);  ClrEol;
  gotoxy(1, Sy+1); ClrEol;
  gotoxy(Sx, Sy);  WriteNgString(Output, s);
end;

procedure ShowLong(n:longint);
begin
  gotoxy(Lx, Ly); write(n:7);
end;

procedure ShowEndLong;
begin
  gotoxy(Lx, Ly); ClrEol;
end;

procedure ShowFile(s:string);
begin
  gotoxy(Fx, Fy); ClrEol; write(s);
end;

procedure ShowGuide(s:string);
begin
  gotoxy(Gx, Gy); ClrEol; write(s);
end;

procedure ShowCount(n:longint);
begin
  gotoxy(Cx, Cy); write(n:7);
end;

procedure ShowMenu(s:string);
begin
  gotoxy(Mx, My); ClrEol; WriteNgString(output, s);
end;

procedure ScreenInit;
begin
  ClrScr;
  gotoxy(Fx-8, Fy); write(' file:');
  gotoxy(Gx-8, Gy); write('guide:');
  gotoxy(Mx-8, My); write(' menu:');
  gotoxy(Cx-8, Cy); write('count:');
  gotoxy(Lx-8, Ly); write('lines:');
  gotoxy(Sx-8, Sy); write('entry:');
end;

procedure ScreenExit;
begin
  gotoxy(1, Sy+3); ClrScr;
end;

procedure Usage;                        {Write usage info}
begin
  writeln;
  writeln('usage:        ngdump filename');
  writeln;
  Halt(1);
end;

procedure slutlort(b:byte);  {Exit on error and display relevant error message}
begin
  if b > 3 then close(f);
  if b > 2 then begin
     writeln('NGDUMP ERROR #', b, ': '+errorinfo[b]+', cannot proceed');
  end;
  if b < 3 then usage;
  halt(0);
end;

procedure sllut(b:byte); {Error handler without exit, just indicating the error type}
var sl:byte;
begin
  sl := 0;
  if b > 3 then close(f);
  writeln(' ',errorinfo[b],' - Press any key');
  erro := 1;
end;

function decrypt(b:byte):byte;          {Decrypt byte from NG format}
begin
(*
  if ((b mod 32)>=16) then b := b-16 else b := b+16;
  if ((b mod 16)>=8) then b := b-8 else b := b+8;
  if ((b mod 4)>=2) then b := b-2 else b := b+2;
  decrypt := b;
*)
  decrypt := b xor (16+8+2);   { this is somewhat more efficient... EVAS}
end;

function read_byte:byte;                {Read and decrypt byte}
var tb:byte;
    numread:word;
begin
  bread(f, tb, 1, numread);
  read_byte := tb xor 26;
end;

function read_word:word;                {Read and decrypt word}
var tb:byte;
begin
  tb := read_byte;
  read_word := word(tb) or (word(read_byte) shl 8);
end;

function read_long:longint;             {Read and decrypt longint}
var tw:word;
begin
  tw := read_word;
  read_long := longint(tw) or (longint(read_word) shl 16);
end;

type BigStr = string[255];

procedure read_string(maxlen:byte; var s:BigStr);
var c,j:byte;
begin
  j := 0;
  repeat
    c := read_byte;
    inc(j);
    s[j] := chr(c);
  until (c = 0) or (j = maxlen);
  s[0] := chr(j-1);
end;

procedure read_menu;             {Read a menu structure into the menu buffer}
var items,i,j:word;
begin
  mennu[menunr,0].filptr := bpos(f)-2;
  bskip(f, 2);
  items := read_word;
  itemlist[menunr] := items;
  bskip(f, 20);
  for i := 1 to items-1 do begin
    mennu[menunr,i].filptr := read_long;
  end;
  bskip(f, items * 8);
  for i := 0 to items-1 do begin
     with mennu[menunr, i] do begin
        read_string( 40, name );
     end;
  end;
  bskip(f, 1);
end;

procedure skip_short_long;       {Skip procedure for the initial menu bseek}
var length:word;
begin
  length := read_word;
  bskip(f, length + 22);
end;

procedure read_header(modf:byte); {Read NG file header and enter the guide name in the screen template}
var buf       : array[0..377] of byte;
    i,numread : word;
begin
  bread(f, buf, sizeof(buf), numread);
  if ((buf[0]<>ord('N')) or (buf[1]<>ord('G'))) then begin
     {If the two first characters in the file are not 'NG', the file is no guide}
     if modf = 0
      then slutlort(4)
      else sllut(4);
  end;

  menuantal := buf[6];
  i := 0;
  repeat
    guidename[i+1] := chr(buf[i+8]);
    inc(i);
  until (buf[i+8] = 0);
  guidename[0] := chr(i);

  ShowGuide( guidename );
  bseek(f, 378);
end;

procedure read_menus(modf:boolean);  {Initial menu bseek, indexing the whole file}
var id : word;
begin
  repeat
    id := read_word;
    if (id < 2) then begin
       skip_short_long
    end
    else if (id = 2) then begin
       read_menu;
       inc(menunr);
    end
    else if (id <> 5) then begin
       if (filesize(f) <> bpos(f)) then begin
          if (not modf)
           then slutlort(5)
           else sllut(5);        {NG file error}
       end
       else id := 5;
    end;
  until (id = 5);

  if (menunr <> menuantal) then begin
     if (not modf)
      then slutlort(6)
      else sllut(6);                {Incomplete file}
  end;
end;

function MakeName:Dos.PathStr;
var fname:Dos.PathStr;
begin
  inc(Nfiles);
  str(Nfiles, fname);
  MakeName := fname;
end;

procedure OpenOutFile(n:word; s:Dos.PathStr);
begin
  assign(outf[n], s); rewrite(outf[n]);
  SetTextBuf(outf[n], OutBuf[n]^, OutBufSize);
end;

procedure read_entry(level:byte; fp:longint); forward;

procedure read_short_entry(level:byte);
{Read short entry from file and wring some information out of it}
var i, items: word;
    subject : line;
    entrypos, subj_pos, p0, p   : longint;
begin
  bskip(f, 2);
  items := read_word;
  bskip(f, 20);
  p0 := bpos(f);
  subj_pos := p0 + longint(items) * 6;
  for i := 1 to items do begin
    bskip(f, 2);
    entrypos := read_long;
    p := bpos(f);
    bseek(f, subj_pos);
    read_string( MaxLineLen, subject );
    subj_pos := bpos(f);
    write(outf[flevel], '!short:'); WriteString(subject);
{}  ShowShort(subject);
    read_entry(level+1, entrypos);
    bseek(f, p);
  end;
end;

procedure read_long_entry;
{Read long entry information}
const MaxSeeAlso = 20;
var i, linens, dlength, seealso_num : word;
    s : line;
begin
  bskip(f, 2);
  linens := read_word;
  dlength := read_word;
{} ShowLong(linens);
  bskip(f, 18);       { 10 + links to prev/next entry (long's) }
  for i := 1 to linens do begin
    read_string( MaxLineLen, s );
    WriteString(s);
  end;

  if dlength <> 0 then begin            {If there are seealso entries, read them}
     seealso_num := read_word;
     { skip the offsets for the SeeAlso-items; }
     bskip(f, seealso_num * 4);
     { read the items; }
     for i := 1 to seealso_num do begin
        if i <= MaxSeeAlso then begin
           read_string( MaxLineLen, s );
           writeln(outf[flevel], '!seealso: "', s, '"');
        end;
     end;
  end;
{} ShowEndLong;
end;

procedure read_entry(level:byte; fp:longint); {Read some kind of file entry}
var id:word; fname:dos.pathstr;
begin
  inc(numentries); ShowCount(numentries);
  bseek(f, fp);
  id := read_word;
  case id of
   0: begin
        if (level > 0) then begin
           fname := MakeName;
           writeln(outf[flevel], '!file: ',fname+'.NGO');
           inc(flevel);
{$ifdef Debug}
           assign(outf[flevel], 'CON'); rewrite(outf[flevel]);
{$else}
           OpenOutFile(flevel, fname+'.DAT');
{$endif}
           read_short_entry(level);
           close(outf[flevel]);
           dec(flevel);
        end
        else begin
           read_short_entry(level);
        end;
      end;
   1: begin
(*
        if (level > 0) and (not odd(level)) then begin
           fname := MakeName;
           writeln(outf[flevel], '!long: ',fname+'.NGO');
           inc(flevel);
{$ifdef Debug}
           assign(outf[flevel], 'CON'); rewrite(outf[flevel]);
{$else}
           OpenOutFile(flevel, fname+'.DAT');
{$endif}
           read_long_entry;
           close(outf[flevel]);
           dec(flevel);
        end
        else begin
           read_long_entry;
        end;
*)
        read_long_entry;
      end;
  end;
end;


procedure Main;
label Next;
var i,j,k:word;
    linkf : text;
    fname : Dos.PathStr;
begin
  numentries := 0;

  { create Menu Link Control File; }
  assign(linkf, 'GUIDE.LCF'); rewrite(linkf);
  writeln(linkf, '!name:'^i, guidename);
  writeln(linkf);

  for i := 0 to menuantal-1 do begin
     writeln(linkf, '!menu:'^i, mennu[i,0].name);
     ShowMenu(mennu[i,0].name);
     for j := 1 to itemlist[i]-1 do begin
        close(outf[flevel]);
        fname := MakeName;
        OpenOutFile(flevel, fname+'.dat');
        ShowMenu(mennu[i,j].name);
        writeln(linkf, ^i, mennu[i,j].name, ^i, fname+'.ngo');
        read_entry( 0, mennu[i,j].filptr );
Next:
     end;
  end;

  close(linkf);

  { write a makefile; }
  assign(linkf, 'MAKEGUID'); rewrite(linkf);
  writeln(linkf, '.dat.ngo:');
  writeln(linkf, ^i'ngc $<');
  writeln(linkf);
  write(linkf, 'OBJECTS=');
  j := 0;
  for i := 1 to Nfiles do begin
     str(i, fname);
     fname := fname + '.ngo ';
     write(linkf, fname);
     inc(j, length(fname));
     if (j > 65) then begin
        write(linkf, '\'^m^j^i);
        j := 0;
     end;
  end;
  writeln(linkf);
  writeln(linkf);
  writeln(linkf, 'guide.ng:	$(OBJECTS)');
  writeln(linkf, ^i'ngml guide.lcf');
  close(linkf);
end;

var i:byte;
begin                        {Main loop and command-line parser}
  flevel := 1;
  Nfiles := 0;
  for i := 1 to MaxLevel do begin
    new(OutBuf[i]);
  end;

{$ifndef Debug}
  assign(outf[flevel], 'CON');
{$else}
  assign(outf[flevel], 'GUIDE.DAT');
{$endif}
  rewrite(outf[flevel]);
  SetTextBuf(outf[flevel], OutBuf[flevel]^, OutBufSize);

  writeln(progname,' ',version,'. ',copyright,'.');
  initvars; {Initialize global variables}

  if ((paramstr(1)='/?') or (paramstr(1)='/h') or (paramstr(1)='/H')) then begin
     Usage;
  end;

  if (ParamCount <> 1) then begin
     Usage;
  end;

  streng := paramstr(1);

  if pos('.',streng)=0
   then streng := streng+'.NG';        {Expand file name}

  assign(f, streng);
{$I-}
  reset(f, 1);
  if ioresult<>0 then slutlort(3);   {If file does not exist, terminate and write cause of death}
{$I+}

  ScreenInit;
  ShowFile(streng);
  ShowMenu('reading menu-info...');
  read_header(0);
  read_menus(False);
  Main;

  close(f);
  close(outf[flevel]);
  ScreenExit;
end.
