{$M $800,0,0}
{eto stack, heapmin, heapmax;
  yesli eto ubrath, -> mem.alloc.err.,system halted;
  standart - 16K,0,640K;
  stack=16K - prokhodit, heapmax=2K - tozhe, heapmax=640K -> syst.halted;
  prichina nyeyasna}
{ryekomyend.translir.: pri ots.soprots. - tpc arifmyet /$N- ,
  pri nalich. - tpc arifmyet /$N+ /$E- ;
  byez klyuchej pri nalich.soprots. -> exe-fajl s vyborom sposoba
  vychisl.v zav.ot nalich.soprots. -> yego dlina - ~18 kb ( N- -> ~7 kb,
  N+E- -> ~9 kb)}
Program kensa; uses dos{,crt};
 {obrashch.k proc.h nyeobkh.,inache v exe-fajl h nye popad.!}
 {mozhno byez param.: procedure h; interrupt; (cheryez tochk.s zapyat.)}
 {eksperim.pokaz.: v ottransl.prog.uchastok zanyes.ryeg.v stek v nachalye
  i izvlyech.v kontse nye zav.ot ukaz.v opis.proc-ry paramyetrov - ot etogo
  zavit.tk.smyeshch.,po k-rym prog.byeryot ikh v stekye. T.ye.posl.para-
  myetr - imyenno bp i t.d.; t.o., nastoyashch.param.nado ukaz.
  pyeryed FG}
 {nye najd.dokum.spos.uzn.EnvSeg;
   pokhozhe,=CS (obshch.dlya h i dlya gol.prog.);
   proshche ispolhz.keep, chem obr.k intr($21) s zapasom po razmyeru}
 type s5=string[17]; us5=^s5;
 var re1,re2,re3:real; ss:s5;
 var i:integer;
{$F+}
 procedure arifmyet(
   flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
 {pyeryed ryegistrami mozhno opis.fiktiv.word-pyeryemyenn.
   (3 dlya Cheryezova, 2 dlya Larionova - ikh zanosit intr), a pyeryed nimi -
   istinn.fortovsk.word-pyeryem.,zasylayemyye pyeryed intr;
   eto m.b.polyezn.dlya rab.s razn.syegmyentami, nyeposr.real-param. i t.p.}
 {dizass.pokaz.:vnutr.pyeryem.raspolag.v stekye, i ikh znach.nye sokhr.!}
 {dlya dann.vyers.:
  ds - obshch.dlya vsyekh dannykh syegmyent;
  ax - smyeshch.1-go opyeranda ;
  bx -   -//-   2-go opyeranda (yesli on tryeb.) ili dop.par.dlya str;
  cx -   -//-   ryezulhtata;
  dx - na vkh. - kod opyer.; na vykh. - kod osh. (0 - norma);
    nye smyeshch.,a nyeposr.!
  bx,si,di - dopoln.param.dlya str (real -> string).
 }
 {pryedusm. (Nr'a - 16-ichn.):
  1..4 - string<->real,integer<->real;
  5 - trunc (polyezyen pri rasch.tsepn.drobyej);
  11,12 - =,>;
  21,22,23,24 - +,-,* /;
  31..3B - frac,int,abs,pi,sqr,sqrt,exp,ln,sin,cos,arctan;
  41,42 - -x, 1/x (s soprots.1/x - ~50 mksec, a a/x s a=1.0 - ~70 mksec (?!));
  nye vvyedyeny: random; <, >=, <=, <> .
 }
  var r1,r2,r3:real; s:s5; i:integer; b:boolean;
    ur1,ur2,ur3:^real; us:^s5; ui:^integer; ub:^boolean;
 begin
  inline($90/$90/$90/$90);
  {inline($FB/$EB/$FE);} {dlya otladki}
  case dx of
   $01: {string -> real} begin
    us:=ptr(ds,ax); s:=us^; val(s,r3,dx); ur3:=ptr(ds,cx); ur3^:=r3;
   end;
   $02: {real -> string} begin
    ur1:=ptr(ds,ax); r1:=ur1^;
    case bx of
     0: begin if si>17 then si:=17; if di>17 then di:=17; str(r1:si:di,s) end;
     1: begin if si>17 then si:=17; str(r1:si,s) end;
     else str(r1,s);
    end {case bx};
    us:=ptr(ds,cx); us^:=s;
   end { $02};
   $03: {integer -> real} begin
    ui:=ptr(ds,ax); i:=ui^; r3:=i; ur3:=ptr(ds,cx); ur3^:=r3;
   end;
   $04..$05: {round,trunc} begin
    ur1:=ptr(ds,ax); r1:=ur1^;
    case dx of $04: i:=round(r1); $05: i:=trunc(r1); end;
    ui:=ptr(ds,cx); ui^:=i;
   end;
   $11..$12: {=,>} begin
    ur1:=ptr(ds,ax); r1:=ur1^; ur2:=ptr(ds,bx); r2:=ur2^;
    case dx of
     $11: if r1=r2 then i:=-1 else i:=0;
     $12: if r1>r2 then i:=-1 else i:=0;
    end;
    ui:=ptr(ds,cx); ui^:=i;
   end;
   $21..$24: {+,-,* /} begin {napomin.:unarn.'-' nye vklyuchen!}
    ur1:=ptr(ds,ax); r1:=ur1^; ur2:=ptr(ds,bx); r2:=ur2^;
    case dx of
     $21: r3:=r1+r2; $22: r3:=r1-r2; $23: r3:=r1*r2; $24: r3:=r1/r2;
    end;
    ur3:=ptr(ds,cx); ur3^:=r3;
   end;
   $31: {pi} begin
    ur3:=ptr(ds,cx); r3:=pi; ur3^:=r3;
   end;
   $32..$3B,$41..$42: {frac,int,abs,sqr,sqrt,exp,ln,sin,cos,arctan,-x,1/x}begin
    ur1:=ptr(ds,ax); r1:=ur1^;
    case dx of
     $32: r3:=frac(r1); $33: r3:=int(r1); $34: r3:=abs(r1); $35: r3:=sqr(r1);
     $36: if r1<0 then begin dx:=$FFFF end else begin r3:=sqrt(r1); dx:=0 end;
     $37: r3:=exp(r1); $38: r3:=ln(r1);
     $39: r3:=sin(r1); $3A: r3:=cos(r1); $3B: r3:=arctan(r1);
     $41: r3:=-r1; $42: r3:=1/r1;
    end;
    ur3:=ptr(ds,cx); ur3^:=r3;
   end;
  end {case dx};
  inline($90/$90/$90/$90);
 end;
 procedure otlad(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
 begin
  inline($90/$90/$90/$90);
  inline($B8/$00/$B8);                         {mov ax,0B800h}
  inline($8E/$C0);                             {mov es,ax}
  inline($26/$C7/$06/$00/$06/$30/$30);         {mov word ptr es:[0600h],3030h}
  {inline($FB/$EB/$FE/$EB/$FE);}               {dlya otladki}
  inline($90/$90/$90/$90);
 end;
{$F-}

Begin
 writeln('+++');
 {zhelat.provyer.,nye zanyaty li pyeryeopr.vyektory
   (vyekt<>nil i obr-chik<>iret)}
 setintvec($51,addr(arifmyet));
 setintvec($52,addr(otlad));
 keep(0);
End.
