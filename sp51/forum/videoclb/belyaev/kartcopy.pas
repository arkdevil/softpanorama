        program kartinka3;
        uses    pcs_ega;
	var	buf :array[1..5120] of byte;
		pal :array[1..17] of byte;
	        i   :byte;
        begin
           ekart('example.pcs'#0,buf,5120);
	   for i:=1 to 16 do pal[i]:=i; pal[17]:=0;
	   ecran_arc('proba.pcs'#0,pal,buf)
        end.
