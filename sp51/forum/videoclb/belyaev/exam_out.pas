program kartinka2;
uses    pcs_ega;
var	buf :array[1..5120] of byte;
begin
   ekart('exampl2.pcs'#0,buf,5120);
   readln;
   ekart('example.pcs'#0,buf,5120);
   readln
end.
