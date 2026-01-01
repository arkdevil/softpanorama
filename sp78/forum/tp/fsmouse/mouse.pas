uses crt, fsmouse;

var Mouse : TMouse;
    a : byte;
begin
  clrscr;
  Mouse.Init;
  writeln('Number of buttons : ', Mouse.GetNumberOfButtons);
  Mouse.ShowMouse;
  repeat
    a := Mouse.ButtonPressed;
    if a <> 0 then
      begin
        Mouse.HideMouse;
        case a of
          1 : writeln('Left   ', Mouse.GetY, ',', Mouse.GetX);
          2 : writeln('Right  ', Mouse.GetY, ',', Mouse.GetX);
          3 : writeln('Middle ', Mouse.GetY, ',', Mouse.GetX);
        end;
        Mouse.ShowMouse;
      end;
  until keypressed;
  Mouse.HideMouse;
end.

