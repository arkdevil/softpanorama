Program atlatest;
{provyer.ots.grub.osh.nabivki v atlasye dlya prog.poiska
 w atlasye spyektrov,pokhozh.na zadann.}

 {$i atlashvv.inc}

 var s1:spyektr; gut:boolean; stroka:string[80]; chislo:integer;

 procedure povozrast(s:spyektr); var i:integer;
 begin
  with s do begin
   for i:=2 to npolos do if arr[i-1].ny>=arr[i].ny then begin
    writeln('nye po vozrast.:');
    write((i-1):5,i:5,arr[i-1].ny:10:4,arr[i].ny:10:4); readln;
   end;
  end;
 end;

Begin writeln;
 writeln('Nachalo prosm.atlasa.');
 assign(b,'atlamill.dat'); reset(b);
 stroka:=''; repeat
  readln(b,stroka); writeln(stroka);
 until stroka='^$^'; writeln; {readln;}
 chislo:=0;
 while not eof(b) do begin
  wwo(s1); chislo:=chislo+1; writeln(chislo:5); wyw(s1); povozrast(s1):
  writeln; {readln;}
 end; close(b);
 writeln('Konyets prosl.atlasa; chislo=',chislo:5,'.');
 {readln}
End.
