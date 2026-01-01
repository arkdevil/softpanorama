{Configuration program for E.COM, (C) Jim DeVries, 1990.  A limited license is
granted for anyone to use and share this program without charge, but you are
prohibited from selling it or releasing a modified copy without prior written
approval or releasing ECONFIG.EXE without this file}

Program EConfig;  uses CRT, Dos;

Const
   ProgramLength = 6337;
   ConfigStarts = $40; {offset from beginning of file}
   {offsets}
   cs = 0;  {Status line attributes  }
   ct = 1;  {text attributes         }
   tw = 2;  {tab width               }
   io = 3;  {insert / overwrite flag }
   ai = 4;  {Autoinsert flag         }
   tm = 5;  {text / program mode flag}
   lm = 6;  {right margin            }
   rm = 7;  {left margin             }

   stop = 0;

TYPE
  BufArray = array[0..ProgramLength-1] of byte;

VAR
   Infile, Outfile : file;
   Buffer : BufArray;
   Cmd : integer;
Function ColorWord(CNum : integer):String;
begin
   case CNum of
   0: ColorWord:='black        ';
   1: ColorWord:='blue         ';
   2: ColorWord:='green        ';
   3: ColorWord:='cyan         ';
   4: ColorWord:='red          ';
   5: ColorWord:='magenta      ';
   6: ColorWord:='brown        ';
   7: ColorWord:='white        ';
   8: ColorWord:='dark grey    ';
   9: ColorWord:='light blue   ';
  10: ColorWord:='light green  ';
  11: ColorWord:='light cyan   ';
  12: ColorWord:='light red    ';
  13: ColorWord:='light magenta';
  14: ColorWord:='yellow       ';
  15: ColorWord:='bright white ';
  end; {case}
end;

Procedure PickColor(OffSet : Integer; VAR Buffer : BufArray);
var x,y,fore, back : integer;
begin
   back:=Buffer[ConfigStarts+OffSet] shr 4;
   fore:=Buffer[ConfigStarts+OffSet] and 15;
   textcolor(fore);
   textbackground(back);
   for x:=0 to 3 do
      for y:=0 to 3 do
      begin
         gotoxy(x*15+1,y+21);
         write(x*4+y:2,' ',colorword(x*4+y));
         end;
   textcolor(yellow);
   textbackground(blue);
   gotoxy(1,20);
   clreol;
   repeat
      gotoxy(1,19);
      write('Enter a new foreground color ');
      read(fore);
      until fore IN [0..15];
   repeat
      gotoxy(33,19);
      write(' Enter a new background color (0..7) ');
      read(back);
      until back in [0..7];
   Buffer[ConfigStarts+Offset]:=back*16+fore;
   for y:=19 to 24 do
   begin
      gotoxy(1,y);
      clreol;
      end;
end;

Procedure SetTab(VAR Buffer : BufArray);
var Tab : byte;
begin
   gotoxy(1,20);
   clreol;
   gotoxy(1,22);
   write('Enter tab width ');
   readln(tab);
   Buffer[ConfigStarts+TW]:=tab;
   gotoxy(1,22);
   clreol;
end;

Procedure SetMargins(VAR Buffer : BufArray);
var left, right : byte;
begin
   gotoxy(1,20);
   clreol;
   gotoxy(1,22);
   write  ('...............................................',
           '.................................');
   left:=Buffer[ConfigStarts+LM];
   right:=Buffer[ConfigStarts+RM];
   gotoxy(left,22);
   write(chr(16));
   gotoxy(right,22);
   write(chr(17));
   repeat
      repeat
         gotoxy(1,23);
         write('Enter new left margin ');
         read(left);
         until left in [1..79];
      repeat
         gotoxy(1,24);
         write('Enter new right margin ');
         read(right);
         until right in [1..80];
      if right <= Left then
         begin
            gotoxy(1,25);
            write('The LEFT margin must be to the left of the RIGHT one!!!');
            end;
      until right > left;
   Buffer[ConfigStarts+LM]:=left;
   Buffer[ConfigStarts+RM]:=right;
   for left:=22 to 25 do
   begin
      gotoxy(1,left);
      clreol;
      end;

end;

Procedure OpenFile(VAR Infile:File);
begin
   Assign(infile,'E.COM');
   reset(infile,1);
   BlockRead(infile, buffer, ProgramLength);
   close(infile);
end;

Procedure PrintHeading;
begin
   clrscr;
   gotoxy(1,3);
   writeln('                         E   C O N F I G U R A T I O N');
   writeln;
   writeln('     E.COM               (C) Copyright 1990, David Nye, MD.');
   writeln('     ECONFIG.EXE         (C) Copyright 1990, Jim DeVries');
   writeln;
   write  ('-----------------------------------------------',
           '---------------------------------');
   gotoxy(1,9);
   writeln('                                              Currently:');
   writeln('     1.  Status line colors.................');
   writeln('     2.  Text colors........................');
   writeln('     3.  Tab width..........................');
   writeln('     4.  Toggle Insert / Overwrite mode.....');
   writeln('     5.  Toggle AutoInsert..................');
   writeln('     6.  Toggle Program / Text mode.........');
   writeln('     7.  Change Margins for text mode.......');
end;

Procedure ShowCurrent(VAR Buffer : BufArray);
var r,l, temp, back, fore : byte;
begin
   back:=Buffer[ConfigStarts+CS] shr 4;
   fore:=Buffer[ConfigStarts+Cs] and 15;
   gotoxy(47,10);
   write(ColorWord(fore),' ON ', ColorWord(back));
   clreol;
   back:=Buffer[ConfigStarts+CT] shr 4;
   fore:=Buffer[ConfigStarts+CT] and 15;
   gotoxy(47,11);
   write(ColorWord(fore),' ON ', ColorWord(back));
   clreol;
   temp:=Buffer[ConfigStarts+TW];
   gotoxy(47,12);
   write(Temp);
   temp:=Buffer[ConfigStarts+IO];
   gotoxy(47,13);
   if temp=$FF then Write('INSERT   ')
      else write('OVERWRITE');
   gotoxy(47,14);
   temp:=Buffer[ConfigStarts+AI];
   If temp=$FF then write('ON ')
      else write('OFF');
   gotoxy(47,15);
   temp:=Buffer[ConfigStarts+TM];
   If temp=$FF then write('TEXT MODE   ')
      else write('PROGRAM MODE');
   l:=Buffer[ConfigStarts+LM];
   r:=Buffer[ConfigStarts+RM];
   gotoxy(47,16);
   write(l, ' L & ',r,' R');
   gotoxy(1,20);
   write('     Change (1..7)  Esc to quit');

end;

Procedure GetCommand(VAR Cmd : integer);
var c: char;
begin
   repeat
      c:=readkey;
   until C in ['1'..'7',#27];
   If C=#27 then Cmd:=Stop
      else Cmd:=Ord(C)-Ord('0');
end;

procedure ProcessCmd(Cmd : Integer; VAR Buffer : BufArray);
begin
   Case Cmd of
   Stop : Exit;
   1: PickColor(CS, Buffer);
   2: PickColor(CT, Buffer);
   3: SetTab(Buffer);
   4: Buffer[ConfigStarts+IO]:= Buffer[ConfigStarts+IO] XOR $FF;
   5: Buffer[ConfigStarts+AI]:= Buffer[ConfigStarts+AI] XOR $FF;
   6: Buffer[ConfigStarts+TM]:= Buffer[ConfigStarts+TM] XOR $FF;
   7: SetMargins(Buffer);
   end;

end;

Procedure CloseFile(VAR Buffer : BufArray);
var yn : char;
    fn : string;
    outfile : file;
begin
   gotoxy(1,20);
   clreol;
   write('     Save changes? [Y/N] ');
   repeat
      yn:=readkey;
   until upcase(yn) IN ['Y','N'];
   writeln;
   if upcase(yn) = 'N'
      then exit
   else
   begin
      write('    Save to E.COM? [Y/N] ');
      Repeat
         yn:=readkey;
      until upcase(yn) in ['Y','N'];
      if upcase(YN) = 'N' then
      begin
         writeln;
         write('     Enter new file name: ');
         read(fn);
         end
      else
         fn:='E.COM';
      end;
   assign(outfile,fn);
   if fn = 'E.COM' then
      reset(outfile, 1)
   else
      rewrite(outfile);

   blockwrite(outfile, Buffer, ProgramLength);

   close(outfile);
end;

begin
   OpenFile(Infile);
   PrintHeading;
   repeat
      ShowCurrent(buffer);
      GetCommand(Cmd);
      ProcessCmd(Cmd,Buffer);
      until Cmd = Stop;
   closefile(buffer);
end.