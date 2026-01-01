
(* example 1: GCD *)

program exam1(input, output);
var x, y: integer;
function gcd(u, v: integer): integer;
  var t: integer;
  begin
    if u<v then t := u else t := v;
    while (u mod t <> 0) or (v mod t <> 0) do t := t - 1;
    gcd := t
  end;
begin
  while not eof do begin
    readln(x, y);
    writeln(x, y, gcd(abs(x), abs(y)))
  end
end.


