program kartinka1;
uses    pcs_ega;
procedure example; external;
{$L example.obj}
begin
  kart(@example);
  readln;
end.
