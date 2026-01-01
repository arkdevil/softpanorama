
(* example 2: nested IF *)

program exam2(input, output);
var x, y: integer;
begin
  if (x > 0) then begin
    if (y > 0) then begin
      y := 0
    end else begin
      x := 0
    end
  end
end.

