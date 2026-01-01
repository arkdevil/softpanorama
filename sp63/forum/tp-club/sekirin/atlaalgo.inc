 var s1,s2:spyektr; gut:boolean; stroka:string[80];
  SryedStrafMax,StrafMax:real; glub,i,iregim:integer;
  magaz:array[1..npolosmax] of record p1,p2:polosa; straf:real end;

  procedure vyvmag(np:integer); var i:integer; a:real;
  begin writeln('--------');
   for i:=1 to np do with magaz[i] do begin
    write(p1.ny:7:0,p1.si,p1.intens:5:3);
    if p2.si<>'nl' then write(p2.ny:7:0,p2.si,p2.intens:5:3)
     else write('       nil    ');
    write(magaz[i].straf:10:3); writeln;
   end; writeln('--------');
   a:=0; for i:=1 to np do a:=a+magaz[i].straf;
   for i:=1 to 28 do write(' '); writeln(a:10:3);
  end;

 procedure iskl(s1:spyektr; i:integer; var s2:spyektr); var j,k:integer;
 begin
  if s1.npolos=0 then begin write('iskl:npolos=0.'); readln end;
  s2.nazv:='Vspomogatyelhn.';
  s2.npolos:=s1.npolos-1;
  k:=0; for j:=1 to s1.npolos do if j<>i then begin
   k:=k+1; s2.arr[k]:=s1.arr[j];
  end;
 end;

 function StrafOtozhd(p1,p2:polosa):real; var d1,d2,shirina,i1,i2:real;
 {p1 - etalonn.polosa, p2 - polosa,s k-roj yeyo pytayemsya otozhd.;
  f-tsiya shtrafa m.b.nyesimm.otnos.pyeryestanovki p1 i p2 !}
 {obosn.:otkaz ot linii -> shtraf=yeyo intens.;
  togda otkaz ot vsyekh lin. -> shtraf=1 -
  udobno, chto nye zav.ot chisla linij i t.p.
  Shtraf=summye shtrafov na sdvig chast.i na razlich.int-styej;
  na sdvig chast.: sdvig na utroyenn.shirinu primyerno ekviv.otkazu ot polosy;
  tryeb.tzh.,chtoby shtraf byl nye ~abs(ny1-ny2), a ~sqr(ny1-ny2) -
  eto zad.vid 1-go chlyena;
  na razl.int-styej: i2=0 dolzhno dath shtraf=i1;
  eto mozhno zadath kak abs(i2-i1);
  no togda shtraf za uvyel.int-sti vdvoye=shtrafu za otkaz,chto plokho;
  kromye togo, slishk.bystro rastyot pri izmyen.int-sti.
  Poetomu pryedlag.kusochno-kvadr.shtraf - sm.tyekst prog.;
  pri etom otozhd.s silhn.lin.vygodnyeye,chem otkaz}
 begin
  if p1.ny<2000.0 then shirina:=20.0
   else if p1.ny<2700 then shirina:=15.0
   else if p1.ny<3100.0 then shirina:=20.0
   else shirina:=50.0; {tipichn.shiriny}
  d1:=0.1*p1.intens*sqr((p1.ny-p2.ny)/shirina);
  i1:=p1.intens; i2:=p2.intens;
  if i2<=i1 then d2:=i1*sqr((i2-i1)/i1)
   else d2:=i1*sqr((i2-i1)/(1-i1));
{  write(p1.ny:7:0,p1.intens:5:2,p2.ny:7:0,p2.intens:5:2);
  writeln(' d1,d2,Straf=',d1:8:2,d2:8:2,(d1+d2):8:2);}
  StrafOtozhd:=d1+d2;
 end;
 function StrafUdal(p:polosa):real;
 begin
{  write(p.ny:7:0,p.intens:5:2);
  writeln(' Straf=',abs(p.intens):8:2);}
  StrafUdal:=abs(p.intens); {kak otozhd.s polosoj s sovp.ny i intens=0}
 end;

 function udovl(s1,s2:spyektr; straf:real):boolean;
 {s1 - etalonn.sp-r, s2 - izuch-myj; v izuch-mom m.b.postoronn.lin.}
  var i,j:integer; d:real; udovl0:boolean; s1new,s2new:spyektr;
 begin
  glub:=glub+1;
  {writeln('udovl:glub=',glub:5,' - .poluch.upr.');
   wyw(s1); wyw(s2); write(' straf=',straf:10:4); readln;}
  if straf>strafmax then udovl0:=false;
  if (straf<=strafmax) and (s1.npolos=0) then begin
   if iregim=1 then udovl0:=true {nye vv.strafa za postoronn.lin.};
   if iregim=2 then begin {straf za postoronn.lin.}
    for i:=1 to s2.npolos do straf:=straf+StrafUdal(s2.arr[i]);
    udovl0:=straf<=strafmax
   end;
  end;
  if (straf<=strafmax) and (s1.npolos>0) then begin
   udovl0:=false;
   {1-yu lin.s1 nado ili otozhd.,ili udalith}
   magaz[glub].p1:=s1.arr[1];
   for j:=1 to s2.npolos do if not(udovl0) then begin
   {otozhd.1-yu lin. s1 i j-yu s2}
    d:=StrafOtozhd(s1.arr[1],s2.arr[j]); if d<=strafmax then begin
     iskl(s1,1,s1new); iskl(s2,j,s2new);
     magaz[glub].p2:=s2.arr[j];
     magaz[glub].straf:=d; {vyvmag(glub); readln;}
     udovl0:=udovl(s1new,s2new,straf+d);
    end;
   end;
   if not(udovl0) then begin {pytayemsya ubr.lin.}
    d:=StrafUdal(s1.arr[1]); if d<=strafmax then begin
     iskl(s1,1,s1new);
     with magaz[glub] do begin
      p2.ny:=p1.ny; p2.si:='nl'; p2.intens:=0; straf:=d
     end; {vyvmag(glub); readln;}
     udovl0:=udovl(s1new,s2,straf+d);
    end;
   end;
  end {if};
  {write('udovl:glub=',glub:5,' - vozvr; udovl0=',udovl0); readln;}
  glub:=glub-1; udovl:=udovl0;
 end {udovl};

 procedure podgotov(var s:spyektr); var a:real; i,j:integer; p:polosa;
 begin
  with s do begin
   a:=0; for i:=1 to npolos do a:=a+arr[i].intens; a:=1/a;
   for i:=1 to npolos do arr[i].intens:=arr[i].intens*a;
   for i:=1 to (npolos-1) do for j:=i+1 to npolos do
     if arr[i].intens<arr[j].intens then begin {uporyad.po ubyv.int-styej}
    p:=arr[i]; arr[i]:=arr[j]; arr[j]:=p
   end;
  end;
 end;

 procedure utochn; var strafmaxold:real; str0,str1:real; gut:boolean;
 begin
  strafmaxold:=strafmax;
  str0:=0; str1:=strafmax; {pri str0 - nye udovl.,pri str1 - udovl.}
  while (str1-str0)>0.01 do begin
   writeln('str0,str1=',str0:10:4,str1:10:4);
   strafmax:=0.5*(str0+str1); gut:=udovl(s1,s2,0);
   if gut then str1:=strafmax else str0:=strafmax;
  end;
  if not(gut) then begin strafmax:=str1; gut:=udovl(s1,s2,0) end;
  {yesli v magaz. - nye ryesheniye,zanos.tuda ryesheniye}
  strafmax:=strafmaxold;
 end;
