Program p5tester;
(* Tests the p5 FDIV error *)
uses crt;

var x: real;
    y: real;
    z: real;
   z2: real;
    
begin
   clrscr;
   textbackground(1);
   textcolor(12+128);
   Writeln('Pentium FDIV tester');
   textcolor(14);
   writeln;
   Writeln('This test uses the following numbers and equation to test the');
   Writeln('floating point portion of any x86 cpu equipped with a math');
   Writeln('co-processor.');
   writeln;
   textcolor(14);
   Writeln('X:=5505001');
   Writeln('Y:=294911');
   Writeln('Z:=(X/Y)*Y-X');
   Writeln('Expected Answer  : 0.00000000000');
   Write('Your answer for Z: ');
   x:=5505001;
   y:=294911;
   z:=(x/y)*y-x;
   Writeln(z:1:11);
   Writeln;
   writeln;
   Writeln('X:=4195835');
   Writeln('Y:=2.9999991');
   Writeln('Z:=(X/Y)*Y-X');
   Writeln('Expected Answer  : 0.00000000000');
   Write('Your answer for Z: ');
   x:=4195835;
   y:=2.9999991;
   z2:=(x/y)*y-x;
   Writeln(z2:1:11);
   Writeln;

   if (z<>0) or (z2<>0) then begin
     textcolor(12);
     writeln('Your cpu is a pentium with the FDIV bug!');
     Writeln('Intel claims that the average user will only run into this');
     Writeln('problem, once in every 27,000 years!!!');
     Writeln;
     end
   else begin
     textcolor(12+128);
     Writeln('You have either a fixed Pentium or 486 or lower cpu, that tests fine!');
     end;
end.
