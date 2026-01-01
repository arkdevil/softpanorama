(***************************************************************)
(*                u n i t   G  r  a  f  i  k  a                *)
(*                      pro PC  v. 1.0                         *)
(*                 soubor grafickych podprogramu               *)
(*         TURBO Pascal  v. 5.5 a operacni system MS-DOS       *)
(*                    verze 4.01 a vyssi                       *)
(*    uzivatelsky prijemne procedury pro malovani uzivatels-   *)
(*                         keho grafu:                         *)
(*           automaticka volba optimalniho meritka,            *)
(*     kresleni spojite funkce, vyneseni bodu ( lib. znak )    *)
(*              ostatni moznosti nejsou omezeny                *)
(*                    doporuceno pro fyziky !                  *)
(* V  hlavnim programu je nutno pouzit unit crt a graph.       *)
(* Aby bylo mozne delat snadno hardcopy na tiskarnu je nasta-  *)
(* vena cerna (pozadi) a bila (inkoust) barva jako default.    *)
(* Je-li na zacatku teto unit uvedena direktiva {$DEFINE LINK} *)
(* automaticky se do vysledneho programu prilinkuji unity      *)
(* bgidriv.tpu a bgifont.tpu . Pokud tuto direktivu vypustite, *)
(* musite pak nastavit spravne drahu k souborum *.bgi a tyto   *)
(* se pak pokazde nahravaji do pameti pri spusteni vysledneho  *)
(* programu.                                                   *)
(*                 Public domain software !                    *)
(*                        A. Brablec                           *)
(*        katedra fyzikalni elektroniky, Prirod. fakulta,      *)
(*      MU Brno, Kotlarska 2, 611 37 Brno, Ceska republika     *)
(*               e-mail   brablec@csbrmu11.bitnet              *)
(*                       (  1.4.1993 )                         *)
(*                                                             *)
(* Tento program je z FTP archivu pro fyziku, ktery je umisten *)
(* na pocitaci ftp.muni.cz v adresari pub/muni.cz/physics.     *)
(* Tento archiv je pristupny pres anonymous FTP nebo pres gop- *)
(* her server gopher.muni.cz.                                  *)
(***************************************************************)

UNIT grafika;
{ $DEFINE LINK}
INTERFACE

{$IFDEF LINK}
USES crt,graph,bgidriv,bgifont;
{$ELSE}
USES crt,graph;
{$ENDIF}

type                                    (* povinne deklarace *)
    fun         = function(x:real):real;
    _Graph_OutString = string[128];
const
    PathToBgi = 'c:\bp\bgi\';
var
    _Graph_XminUu, _Graph_XmaxUu, _Graph_KoefXUuGu : real;
    _Graph_YminUu, _Graph_YmaxUu, _Graph_KoefYUuGu : real;
    _Graph_XmaxGu, _Graph_YmaxGu                   : integer;
    _Graph_XminLUu, _Graph_XmaxLUu                 : real;
    _Graph_YminLUu, _Graph_YmaxLUu                 : real;
    _Graph_MaxColor, _Graph_K1                     : integer;
    _Graph_CharX, _Graph_CharY                     : real;
    _Graph_Center                                  : boolean;

PROCEDURE InitGraphics;
(**************************************************************)
(* inicializace grafiky, tato procedura musi byt volana jako  *)
(* prvni                                                      *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

FUNCTION TestMode:boolean;
(**************************************************************)
(* testuje nastaveny mod. Pro graficky mod vraci true, pro    *)
(* pro textovy mod vraci false.                               *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vystupni                                                *)
(*     TestMode ... true  pro graficky mod                    *)
(*              ... false pro textovy mod                     *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE Frame;
(**************************************************************)
(* Oramuje graficke pole                                      *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE Scale(Xmin,Xmax,Ymin,Ymax:real);
(**************************************************************)
(* Nastaveni uzivatelskych jednotek, musi byt Xmax > Xmin a   *)
(* Ymax > Ymin, jinak se nic neprovede                        *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     [Xmin,Ymin] ... poloha leveho dolniho rohu grafickeho  *)
(*                     pole v uzivatelskych jednotkach        *)
(*     [Xmax,Ymax] ... poloha praveho horniho rohu grafickeho *)
(*                     pole v uzivatelskych jednotkach        *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE Move(x,y: real);
(**************************************************************)
(* Presun pera do bodu [x,y]                                  *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     [x,y] ... souradnice bodu v uzivatelskych jednotkach   *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE Plot(x,y:real);
(**************************************************************)
(* Vykresli bod o souradnicich [x,y]                          *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     [x,y] ... souradnice bodu v uzivatelskych jednotkach   *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE Draw(x,y: real);
(**************************************************************)
(* Nakresleni usecky ze soucasne pozice pera do bodu [x,y]    *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     [x,y] ... poloha koncoveho bodu usecky v uzivatelskych *)
(*               souradnicich                                 *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE Xax(Xmin,Xmax,offset,stepX,begX:real;markX:integer);
(**************************************************************)
(* Nakresli osu x se zadanym  offsetem vcetne znacek na ose   *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     Xmin, Xmax ... zacatek a konec osy x v uzivatelskych   *)
(*                souradnicich                                *)
(*     offset ... poloha osy x vzhledem k ose y               *)
(*     stepX  ... velikost dilku na ose x                     *)
(*     begX   ... poloha prvniho dilku                        *)
(*     markX  =  1 znacky smeruji nahoru od osy x             *)
(*            = -1 znacky smeruji dolu od osy x               *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        move, draw                                          *)
(*                                                            *)
(**************************************************************)

PROCEDURE Yax(Ymin,Ymax,offset,stepY,begY:real;markY:integer);
(**************************************************************)
(* Nakresli osu y se zadanym  offsetem vcetne znacek na ose   *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     Ymin, Ymax ... zacatek a konec osy y v uzivatelskych   *)
(*                souradnicich                                *)
(*     offset ... poloha osy y vzhledem k ose x               *)
(*     stepY  ... velikost dilku na ose y                     *)
(*     begY   ... poloha prvniho dilku                        *)
(*     markY  =  1 znacky smeruji vpravo od osy y             *)
(*            = -1 znacky smeruji vlevo od osy y              *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        move, draw                                          *)
(*                                                            *)
(**************************************************************)

PROCEDURE Axes(Xmin,Ymin,Xmax,Ymax : real;TextX,TextY:_Graph_OutString);
(**************************************************************)
(* Automaticky nakresli osy grafu s optimalni volbou velikos- *)
(* ti dilku a popisu na obou osach. Graf maximalne vyuziva    *)
(* plochu obrazovky. Pri hornim a dolnim okraji obrazovky je  *)
(* automaticky vynechano misto pro popis grafu, orientacni    *)
(* zpravy, apod. Znacky jsou na vsech 4 osach a smeruji dov-  *)
(* nitr grafu.                                                *)
(* Jsou zavedeny promenne :                                   *)
(*          _Graph_XminLUu, _Graph_XmaxLUu                    *)
(*          _Graph_YminLUu, _Graph_YmaxLUu                    *)
(* ktere vymezuji kreslici pole pomoci Xmin, Ymin, Xmax, Ymax.*)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     [Xmin,Ymin] ... souradnice leveho dolniho rohu os      *)
(*                 ( kresliciho pole ) v uzivatelskych jed-   *)
(*                   notkach                                  *)
(*     [Xmax,Ymax] ... souradnice praveho horniho rohu os     *)
(*                 ( kresliciho pole ) v uzivatelskych jed-   *)
(*                   notkach                                  *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        xax, yax, draw, move                                *)
(*                                                            *)
(**************************************************************)

PROCEDURE DrawFunction(a,b:real; fff:fun);
(**************************************************************)
(* Nakresli spojitou krivku mezi body a, b  tvar krivky je    *)
(* popsan uzivatelskou funkci fff                             *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     a   ... levy okraj intervalu nezavisle promenne        *)
(*     b   ... pravy okraj inetrvalu nezavisle promenne       *)
(*     fff ... jmeno uzivatelske funkce, ktera se bude kres-  *)
(*             lit (typ fff(x:real):real)                     *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        move, draw                                          *)
(*                                                            *)
(*  - metoda                                                  *)
(*     Funkce 'fff' je pocitana v bodech intervalu <a,b>      *)
(*     s krokem odpovidajicim maximalnimu rozliseni monitoru. *)
(*     Funkce musi byt obalena direktivami {$F+} a {$F-}      *)
(*                                                            *)
(**************************************************************)

PROCEDURE Point(xg,yg:real; symbol: char);
(**************************************************************)
(* vykresli jeden znak centrovane do polohy [xg,yg]           *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     [xg,yg] ... souradnice bodu, kde se ma centrovane na-  *)
(*                 kreslit znak                               *)
(*     symbol  ... kresleny znak                              *)
(*                 '*','+','0'..'9','A'..'Z','b','d','f','h', *)
(*                 'k','l','t','a','c','e','i','m'..'o','r',  *)
(*                 's','u'..'x','z','g','j','p','q','y','.'   *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        move                                                *)
(*                                                            *)
(**************************************************************)

PROCEDURE Information(Inform : _Graph_Outstring);
(**************************************************************)
(* do dolniho rezervovaneho radku pod grafem se centrovane    *)
(* vypise zadana informace ( max. 128 znaku ASCII, pokud to   *)
(* dovoli rozlisovaci schopnost monitoru)                     *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     inform ... retezec znaku                               *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        move                                                *)
(*                                                            *)
(**************************************************************)

FUNCTION Question(inform : _Graph_Outstring):boolean;
(**************************************************************)
(* do dolniho rezervovaneho radku pod grafem se zleva vypise  *)
(* zadany dotaz, na ktery se odpovi stiskem klavesy A nebo N  *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     inform ... retezec znaku                               *)
(*                                                            *)
(*  - vystupni                                                *)
(*      po stisknuti klavesy A je vysledkem hodnota true,     *)
(*      po stisknuti klavesy N je vysledkem hodnota false     *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        information                                         *)
(*                                                            *)
(**************************************************************)

PROCEDURE Show(TextX,TextY:_Graph_Outstring;n:integer;var x,y);
(**************************************************************)
(* podle zadanych vektoru x,y zvoli meritko pro osy, vykres-  *)
(* li osy a n bodu se souradnicemi (x[i],y[i]). Musi byt      *)
(* nastaven graficky mod !  Vstupni parametry x, y jsou libo- *)
(* volna realna pole.                                         *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     TextX ... popis osy x                                  *)
(*     TextY ... popis osy y                                  *)
(*     n  ... pocet bodu                                      *)
(*     x  ... x-ove souradnice bodu                           *)
(*     y  ... y-ove souradnice bodu                           *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        Axes                                                *)
(*                                                            *)
(**************************************************************)

PROCEDURE ShowFunction(a,b:real;f:fun;TextX,TextY:_Graph_Outstring);
(**************************************************************)
(* pro zadnou funkci f zvoli meritko pro osy, vykresli osy a  *)
(* graf funkce f. Musi byt nastaven graficky mod !            *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vstupni                                                 *)
(*     a   ... levy okraj intervalu nezavisle promenne        *)
(*     b   ... pravy okraj intervalu nezavisle promenne       *)
(*     f   ... jmeno uzivatelske funkce, ktera se bude kres-  *)
(*             lit (typ f(x:real):real)                       *)
(*     TextX ... popis osy x                                  *)
(*     TextY ... popis osy y                                  *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        Show                                                *)
(*                                                            *)
(*  - metoda                                                  *)
(*     Funkce f je pocitana v bodech intervalu <a,b>          *)
(*     s krokem odpovidajicim maximalnimu rozliseni monitoru. *)
(*     Funkce f musi byt obalena direktivami {$F+} a {$F-}.   *)
(**************************************************************)

IMPLEMENTATION

PROCEDURE Abort(Msg : string);
begin
  Writeln(#7,' Grafika: ',Msg);
  Halt(1);
end;  (* Abort *)

FUNCTION TestMode:boolean;
var
 mode:byte;
BEGIN
 asm
   mov ah,15
   int 16
   mov mode,al
  end;
 if (mode in [4,5,6]) or (mode>=13)
  then
   TestMode:=true
  else
   TestMode:=false;
END;  (* TestMode *)

PROCEDURE InitGraphics;
var
   driver,mode,graph_res: integer;
BEGIN
{$IFDEF LINK}
  if RegisterBGIdriver(@CGADriverProc) < 0 then
    Abort('error RegisterBGIdriver CGA');
  if RegisterBGIdriver(@EGAVGADriverProc) < 0 then
    Abort('error RegisterBGIdriver EGA/VGA');
  if RegisterBGIdriver(@HercDriverProc) < 0 then
    Abort('error RegisterBGIdriver Herc');
  if RegisterBGIdriver(@ATTDriverProc) < 0 then
    Abort('error RegisterBGIdriver AT&T');
  if RegisterBGIdriver(@PC3270DriverProc) < 0 then
    Abort('error RegisterBGIdriver PC 3270');


  { Register all the fonts }
  if RegisterBGIfont(@GothicFontProc) < 0 then
    Abort('error RegisterBGIfont Gothic');
  if RegisterBGIfont(@SansSerifFontProc) < 0 then
    Abort('error RegisterBGIfont SansSerif');
  if RegisterBGIfont(@SmallFontProc) < 0 then
    Abort('error RegisterBGIfont Small');
  if RegisterBGIfont(@TriplexFontProc) < 0 then
    Abort('error RegisterBGIfont Triplex');
  driver:=detect;
  initgraph(driver,mode,'');
{$ELSE}
  driver:=detect;
  initgraph(driver,mode,PathToBgi);
{$ENDIF}
  graph_res:=graphresult;
  if graph_res<0
   then
    Abort(' error initgraph - '+GraphErrorMsg(graph_res));
  cleardevice;
  _Graph_XmaxGu      :=getmaxX;  _Graph_YmaxGu      :=getmaxY;
  _Graph_XminUu      := 0;       _Graph_XmaxUu      :=_Graph_XmaxGu;
  _Graph_KoefXUuGu   := 1;
  _Graph_YminUu      := 0;       _Graph_YmaxUu      :=_Graph_YmaxGu;
  _Graph_KoefYUuGu   := 1;
  _Graph_XminLUu    := 0;         _Graph_XmaxLUu    :=_Graph_XmaxGu;
  _Graph_KoefXUuGu  := 1;
  _Graph_YminLUu    := 0;         _Graph_YmaxLUu    :=_Graph_YmaxGu;
  _Graph_KoefYUuGu  := -1;
  _Graph_MaxColor:=getmaxcolor;
  _Graph_k1:=8;
  _Graph_Center:=true;
  _Graph_CharX:=(_Graph_XmaxUu-_Graph_XminUu)/_Graph_XmaxGu*_Graph_k1;
  _Graph_CharY:=(_Graph_YmaxUu-_Graph_YminUu)/_Graph_YmaxGu*_Graph_k1;
END (* InitGraphics *);

PROCEDURE Frame;
BEGIN
  moveto(0,0);lineto(_Graph_XmaxGu,0);
  lineto(_Graph_XmaxGu,_Graph_YmaxGu);
  lineto(0,_Graph_YmaxGu);lineto(0,0);
END; (* Frame *)

PROCEDURE Scale(Xmin,Xmax,Ymin,Ymax:real);
BEGIN
  if (Xmax>Xmin)and(Ymax>Ymin) then
    begin
     _Graph_XminUu := Xmin; _Graph_XmaxUu := Xmax;
     _Graph_KoefXUuGu := _Graph_XmaxGu/(_Graph_XmaxUu-_Graph_XminUu);
     _Graph_YminUu := Ymin; _Graph_YmaxUu := Ymax;
     _Graph_KoefYUuGu := _Graph_YmaxGu/(_Graph_YminUu-_Graph_YmaxUu);
     _Graph_XminLUu:=Xmin;_Graph_XmaxLUu:=Xmax;  (* zavedeni Limit *)
     _Graph_YminLUu:=Ymin;_Graph_YmaxLUu:=Ymax;
    end
   else
    begin closegraph; Abort('error Scale  Xmax<=Xmin or Ymax<=Ymin');end;
END; (* Scale *)

PROCEDURE Move(x,y: real);
var
  xgu,ygu: integer;
BEGIN
  xgu := round(_Graph_KoefXUuGu*(x-_Graph_XminUu));
  ygu := round(_Graph_KoefYUuGu*(y-_Graph_YmaxUu));
  moveto(xgu,ygu);
END; (* Move *)

PROCEDURE Plot(x,y:real);
var
  xgu,ygu:integer;
BEGIN
  xgu := round(_Graph_KoefXUuGu*(x-_Graph_XminUu));
  ygu := round(_Graph_KoefYUuGu*(y-_Graph_YmaxUu));
  putpixel(xgu,ygu,_Graph_MaxColor);
END; (* Plot *)

PROCEDURE Draw(x,y: real);
var
  xgu,ygu: integer;
BEGIN
  xgu := round(_Graph_KoefXUuGu*(x-_Graph_XminUu));
  ygu := round(_Graph_KoefYUuGu*(y-_Graph_YmaxUu));
  lineto(xgu,ygu);
END; (* Draw *)

PROCEDURE xax(Xmin,Xmax,offset,stepX,begX:real;markX:integer);
         (* nakresli osu x se zadanym  offsetem vcetne kreslen *)
var
   x,py  :   real;
BEGIN
     move(Xmin,offset);Draw(Xmax,offset);
     x:=begX;py:=offset+markX*(_Graph_YmaxUu-_Graph_YminUu)/80;
     while x<Xmax do
        begin
          move(x,offset);draw(x,py); x:=x+stepX;
        end;
END; (* xax *)

PROCEDURE Yax(Ymin,Ymax,offset,stepY,begY:real;markY:integer);
var
   y,px  :   real;
BEGIN
     move(offset,Ymin);Draw(offset,Ymax);
     y:=begY;px:=offset+markY*(_Graph_XmaxUu - _Graph_XminUu)/200;
     while y<Ymax do
        begin
             move(offset,y);draw(px,y);y:=y+stepY;
        end;
END; (* Yax *)

PROCEDURE Axes(Xmin,Ymin,Xmax,Ymax : real;TextX,TextY:_Graph_OutString);
FUNCTION rad(p1:real):integer;
var
   p2       : integer;
   pom      : real;
BEGIN
    if p1<>0 then
        begin
           pom:=ln(abs(p1))/ln(10);p2:=Trunc(pom);
           if pom<0 then p2:=p2-1;rad:=p2;
        end
   else rad:=0;
END;

PROCEDURE deleniosy(zac,kon:real; var dilek,prvniznacka:real;
                    var mocnina : integer);
var
   m,k,i,j,pocet           : integer;
   ki                      : real;
BEGIN
   m:=11;pocet:=20;
   while pocet>10 do
     begin
       m:=m-1;ki:=(kon-zac)/m; mocnina:=rad(ki);
       if mocnina>0 then for j:=1 to mocnina do ki:=ki/10;
       if mocnina<0 then for j:=1 to abs(mocnina) do ki:=ki*10;
          if (ki>=1) and (ki<=1.5) then k:=1;
          if (ki>1.5) and (ki<=3.5) then k:=2;
          if ki>3.5 then k:=5;
       dilek:=k; pocet:=mocnina;
          while pocet<>0 do
            begin
              if mocnina>0 then
                  begin dilek:=dilek*10;pocet:=pocet-1;end;
              if mocnina<0 then
                  begin dilek:=dilek/10;pocet:=pocet+1;end;
          end;
       prvniznacka:=dilek*int(zac/dilek);
          if prvniznacka<zac
               then prvniznacka:=prvniznacka+dilek;
       pocet:=trunc((kon-prvniznacka)/dilek);
     end;
END;

PROCEDURE uprpopisu(p1,p2,dilek,znacka : real;mocn : integer;
                var pdil,pznacka : real; var pmoc : integer);
BEGIN
     pmoc:=mocn;pdil:=dilek; pznacka:=znacka;
     if mocn<-2 then
        while pmoc<0 do
          begin
            pdil:=pdil*10;pznacka:=pznacka*10;pmoc:=pmoc+1;
          end;
     if mocn>3 then
        while pmoc>0 do
          begin
            pdil:=pdil/10;pznacka:=pznacka/10;pmoc:=pmoc-1;
          end;
      if (mocn>=0) and (mocn<=3)
        then pmoc:=0;
END;

PROCEDURE popisosy(gpznacka,gdilek,gkon,pznacka,dilek : real;
                   uprmocn,mocn,rezim : integer;
                   var s1,lpism : integer);
var
   pp,pp1,p5,p6                      : real;
   pm,s2,pdesmist,lmax                       : integer;
   strl                                 : _Graph_Outstring;
BEGIN
  lpism:=0;pp:=pznacka-s1*dilek; pdesmist:=Trunc(abs(uprmocn));
  pp1:=gpznacka-s1*gdilek;  lmax:=0;
  while pp1<gkon do
    begin
      pp:=pp+s1*dilek;pm:=rad(pp);pp1:=pp1+s1*gdilek;
      if pm<0 then pm:=0;
      if pp<0 then pm:=pm+1;
      str(pp:(pm+pdesmist+2):pdesmist,strl);
      if pos(' ',strl)=1 then Delete(strl,1,1);
      lpism:=length(strl);  if lpism>=lmax then lmax:=lpism;
      case rezim of
       2 : begin
             s2:=1;
             while (s2*gdilek<(lpism+1)*_Graph_CharX) do
              begin s2:=s2+1;if s2>s1 then s1:=s2;end;
           end;
       3 : begin
             move(pp1-lpism*_Graph_CharX/2,_Graph_YminLUu-1.5*_Graph_CharY);
             if (mocn<=3) and (mocn>=-2) and
                (pp1+lpism*_Graph_CharX/2<gkon) then outtext(strl)
              else
              if (pp1+lpism*_Graph_CharX/2+_Graph_k1*_Graph_CharX<gkon) then
                   outtext(strl);
           end;
       4 : begin
             move(_Graph_XminLUu-(lpism+1)*_Graph_CharX,pp1+_Graph_CharY/2);
             if (pp1+_Graph_CharY<gkon) then outtext(strl);
           end;
      end;
    end;        lpism:=lmax;
END; (* popisosy *)

var
   dilekx,pznackax,pdilx,pznx           : real;
   dileky,pznackay,pdily,pzny           : real;
   mx,my,mocnx,mocny                    : integer;
   p1,p2,p3,p4,p5,p6                    : real;
   s1,lpism                             : integer;
   strl                                 : _Graph_Outstring;
   delka                                : real;
   oldstyle                             : textsettingstype;
BEGIN
  if not TestMode
   then
    Abort('error - Axes not in graphics mode ');
  deleniosy(Xmin,Xmax,dilekx,pznackax,mocnx);
  deleniosy(Ymin,Ymax,dileky,pznackay,mocny);
  uprpopisu(Xmin,Xmax,dilekx,pznackax,mocnx,pdilx,pznx,mx);
  uprpopisu(Ymin,Ymax,dileky,pznackay,mocny,pdily,pzny,my);
                                     (* scale a nakresleni os *)
  p3:=Xmax;p2:=1.2*Ymin-0.2*Ymax;p4:=1.1*Ymax-0.1*Ymin;s1:=1;
  popisosy(pznackay,dileky,Ymax,pzny,pdily,my,mocny,1,s1,lpism);
                                    (* max. delka popisu na Y *)
  lpism:=(lpism+3)*_Graph_k1;
  p1:=(lpism*Xmax-_Graph_XmaxGu*Xmin)/(lpism-_Graph_XmaxGu);
  scale(p1,p3,p2,p4);
  _Graph_XminLUu:=Xmin;_Graph_XmaxLUu:=Xmax;(* zavedeni Limit *)
  _Graph_YminLUu:=Ymin;_Graph_YmaxLUu:=Ymax;
  p5:=pznackax; p6:=pznackay;
  if (pznackax-dilekx/2>Xmin) then p5:=p5-dilekx/2;
  if (pznackay-dileky/2>Ymin) then p6:=p6-dileky/2;
  xax(Xmin,Xmax,Ymin,dilekx/2,p5,1);
  yax(Ymin,Ymax,Xmin,dileky/2,p6,1);
  xax(Xmin,Xmax,Ymax,dilekx/2,p5,-1);
  yax(Ymin,Ymax,Xmax,dileky/2,p6,-1);
  _Graph_CharX:=(p3-p1)/_Graph_XmaxGu*_Graph_k1;(* sirka pismena v u.j. *)
  _Graph_CharY:=(p4-p2)/_Graph_YmaxGu*_Graph_k1;(* vyska pismena v u.j. *)
                                               (* popis osy x *)
                           (* urcuje kolikaty dilek se popise *)
  popisosy(pznackax,dilekx,Xmax,pznx,pdilx,mx,mocnx,2,s1,lpism);
                           (*         vlastni popis           *)
  popisosy(pznackax,dilekx,Xmax,pznx,pdilx,mx,mocnx,3,s1,lpism);
  if ( mocnx>3) or (mocnx<-2) then
     begin
       move(p3-6*_Graph_CharX,_Graph_YminLUu-1.5*_Graph_CharY);
       str(mocnx,strl);strl:='x1E'+strl;outtext(strl);
     end;
                                               (* popis osy y *)
  s1:=1;                                 (* puvodni nastaveni *)
  popisosy(pznackay,dileky,Ymax,pzny,pdily,my,mocny,4,s1,lpism);
  if ( mocny>3) or (mocny<-2) then
     begin
       str(mocny,strl);
       move(_Graph_XminLUu-2*_Graph_CharX,Ymax+3*_Graph_CharY/2);
       strl:='x1E'+strl;outtext(strl);
     end;
  delka:=(length(TextX)+2)*_Graph_CharX;           (* popis X *)
  if delka<=(_Graph_XmaxLUu-_Graph_XminLUu) then
    move(_Graph_XmaxLUu-delka,_Graph_YminUu+5*_Graph_CharY)
    else move(_Graph_XminUu,_Graph_YminUu+5*_Graph_CharY);
  outtext(TextX);
  _Graph_CharY:=(_Graph_YmaxUu-_Graph_YminUu)/_Graph_YmaxGu*_Graph_k1;
                                                   (* popis Y *)
  move(_Graph_XminUu+_Graph_CharX,_Graph_YmaxLUu-2*_Graph_CharY);
  gettextsettings(oldstyle);
  with oldstyle do settextstyle(font,vertdir,charsize);
  outtext(TextY);
  with oldstyle do settextstyle(font,Horizdir,charsize);
END; (* Axes *)

PROCEDURE DrawFunction(a,b:real; fff:fun);
var
   p6,p7            :  real;
   ig,im            :  integer;
BEGIN
  p6:=b;
  b:=0.8*(_Graph_XmaxLUu-_Graph_XminLUu)/_Graph_XmaxGu;
  im:=Round((p6-a)/b);
  p6:=a;p7:=fff(a);
  if p6<_Graph_XminLUu then p6:=_Graph_XminLUu;
  if p6>_Graph_XmaxLUu then p6:=_Graph_XmaxLUu;
  if p7<_Graph_YminLUu then p7:=_Graph_YminLUu;
  if p7>_Graph_YmaxLUu then p7:=_Graph_YmaxLUu;
  move(p6,p7);
  for ig:= 1 to im do
    begin
      p6:=a+ig*b;p7:=fff(p6);
      if p6<_Graph_XminLUu then p6:=_Graph_XminLUu;
      if p6>_Graph_XmaxLUu then p6:=_Graph_XmaxLUu;
      if p7<_Graph_YminLUu then p7:=_Graph_YminLUu;
      if p7>_Graph_YmaxLUu then p7:=_Graph_YmaxLUu;
      draw(p6,p7)
    end;
END; (* DrawFunction *)

PROCEDURE Point(xg,yg:real; symbol:char);
var
   p1,p2,p6,p7,p8            :  real;
BEGIN
  p8:=_Graph_k1/2; p1:=-_Graph_CharX/_Graph_k1; p2:=-_Graph_CharY/_Graph_k1;
  case symbol of
    '*','+','0'..'9','A'..'Z','b','d','f','h','k','l','t' :
             begin p1:=p1*3;p2:=-p2*3;end;
    'a','c','e','i','m'..'o','r','s','u'..'x','z','g','j','p','q','y' :
             begin p1:=p1*(p8-1);p2:=-p2*9/2;end;
    '.' :    begin p1:=p1*3;p2:=-p2*5.5;end
     else
             begin symbol:='*';p1:=-p1*p8;p2:=p2*(p8-1.5);end;
  end;
  p6:=p1+xg;p7:=yg+p2;
  if (p6>=_Graph_XminLUu) and (p6<=_Graph_XmaxLUu) and
     (p7>=_Graph_YminLUu) and (p7<=_Graph_YmaxLUu) then
        begin move(p6,p7);outtext(symbol); end;
END; (* Point *)

PROCEDURE Information(inform : _Graph_Outstring);
type
  pointtype = array[1..2] of integer;
const
   k = 20;
var
   ik               : integer;
   ny               : real;
   obd              : array[1..4] of Pointtype;
   delka            : real;
BEGIN
  obd[1,1]:=0;obd[1,2]:=_Graph_YmaxGu-k;
  obd[2,1]:=_Graph_XmaxGu;obd[2,2]:=_Graph_YmaxGu-k;
  obd[3,1]:=_Graph_XmaxGu;obd[3,2]:=_Graph_YmaxGu;
  obd[4,1]:=0;obd[4,2]:=_Graph_YmaxGu;
  SetColor(black);                 (* mazani puvodniho napisu *)
  SetFillStyle(SolidFill,black);  FillPoly(4,obd);
  SetFillStyle(SolidFill,white);
  SetColor(white);                  (* puvodni barva inkoustu *)
  delka:=length(inform)*_Graph_CharX;
  if _Graph_Center and (delka<=(_Graph_XmaxLUu-_Graph_XminLUu)) then
    move((_Graph_XmaxLUu+_Graph_XminLUu)/2-delka/2,_Graph_YminUu+2*_Graph_CharY)
    else move(_Graph_XminUu,_Graph_YminUu+2*_Graph_CharY);
  outtext(inform);
END; (* Information *)

FUNCTION Question(inform : _Graph_Outstring):boolean;
var
  i                 : integer;
BEGIN
  information(inform); repeat i:=ord(readkey) until i in [65,97,78,110];
  if (i=65) or (i=97) then question:=true else question:=false;
END; (* Question *)


PROCEDURE Show(TextX,TextY:_Graph_Outstring;n:integer;var x,y);
type
 vectors=array [1..8000] of real;
 pvectors=^vectors;

PROCEDURE Minmax(n:integer;var x:vectors;var min,max:real);
var
 i : integer;
BEGIN
  max:=x[1];min:=max;
  for i:=1 to n do
  if x[i]>max then max:=x[i]
              else if x[i]<min then min:=x[i];
END;

var
 xp,yp                           : pvectors;
 xmax,xmin,ymin,ymax,px,py       : real;
 i                               : integer;

BEGIN
  if not TestMode
   then
    Abort('error - Show not in graphics mode ');
  xp:=@vectors(x);yp:=@vectors(y);
  minmax(n,xp^,xmin,xmax);
  minmax(n,yp^,ymin,ymax);
  px:=0.05*(xmax-xmin);
  py:=0.05*(ymax-ymin);
  axes(xmin-px,ymin-py,xmax+px,ymax+py,TextX,TextY);
  for i:=1 to n do
  plot(xp^[i],yp^[i]);
END;   (* Show *)

PROCEDURE ShowFunction(a,b:real;f:fun;TextX,TextY:_Graph_Outstring);
var
 x,y:array [0..800] of real;   (* for VGA mode 640*480 *)
 i,n:integer;
 p:real;
BEGIN
 if not TestMode
  then
   Abort('error - ShowFunction not in graphics mode ');
 if a>b
  then
   begin
    p:=b;b:=a;a:=p;
   end;
 p:=0.8*(b-a)/_Graph_XmaxGu;
 x[0]:=a;
 i:=0;
 while x[i]<b do
  begin
   y[i]:=f(x[i]);
   Inc(i);
   x[i]:=i*p+a;
  end;
 x[i]:=b;
 y[i]:=f(b);
 n:=i+1;
 show(TextX,TextY,n,x,y);
 move(a,y[0]);
 for i:=1 to n-1 do
  draw(x[i],y[i]);
END;   (* ShowFunction *)

END.

(**********************************************************)
(*                konec unitu Grafika                     *)
(**********************************************************)
