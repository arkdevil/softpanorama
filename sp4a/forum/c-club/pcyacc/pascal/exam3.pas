
(* example 3: CASE *)

program exam3(input, output);
var a, b, c: real;
begin
  d2 := b*b - 4*a*c;
  if d2 < 0 then flag := -1 else
  if d2 = 0 then flag := 0 else flag := 1;
  case d2 of
    -1: writeln('Complex root');
     0: writeln('One real root');
     1: writeln('Two real roots')
  end
end.

