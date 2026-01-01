{ $M 65520,0,655360} {ryekom.v vyers.tr-ra >=5.0}
Program atlasik2;
{Uproshch.prog.poiska w atlasye spyektrov,pokhozh.na zadann.
 Int-sti - po 5-ballhn.shkalye; shyriny ignor.
 Liniyu mozhno otozhd.s odnoj iz prisutstv.v spyektrye ili vybroshith
 (shtraf zavis.ot razn.chastot i int-styej ili ot int-sti vybras-moj linii).
 Zhelat.iskath linii etalonn.spyektrov v zadannom, a nye naob. -
 togda primyesi nye dolzhny myeshath. No mozhno vv.shtraf za lin.,ots.v
 etalonn.sp-rye - togda budyet simmyetr.
 Spyektr zad.kak 3..10 naib.intens.polos.
 Nyedost.:nye uchit.vozm-sth rasshchyepl.polos.; dlya uchota nado nye
 ubir.polosu obraztsa pri otozhd.,a pomyech.int-sth kak umyenhsh. ili nulh.}

 {$i atlashvv.inc}

 {$i atlaalgo.inc}

Begin writeln;
 assign(b,'c6h6herz.dat'); reset(b);
 stroka:=''; repeat
  readln(b,stroka); writeln(stroka);
 until stroka='^$^';
  wwo(s2); {writeln;} {writeln(s2.nazv);} wyw(s2); podgotov(s2); wyw(s2);
 close(b);
 iregim:=1;
 writeln('Nachalo prosm.atlasa.');
 assign(b,'atlarast.dat'); reset(b);
 stroka:=''; repeat readln(b,stroka); writeln(stroka) until stroka='^$^';
 while not eof(b) do begin
  wwo(s1); {writeln;} writeln(s1.nazv); {wyw(s1);} podgotov(s1);
  glub:=0;
  strafmax:=0.5; gut:=udovl(s1,s2,0);
  {writeln('gut=',gut);}
  if gut then begin utochn; writeln; wyw(s1); vyvmag(s1.npolos); readln end;
 end; close(b);
 writeln('Konyets prosm.atlasa.');
End.
