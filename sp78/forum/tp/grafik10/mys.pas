(***************************************************************)
(*                       u n i t   M y s                       *)
(*                       pro PC  v. 1.0                        *)
(*    soubor podprogramu pro ovladani mysi v grafickem modu    *)
(*         TURBO Pascal  v. 5.5 a operacni system MS-DOS       *)
(*                    verze 4.01 a vyssi                       *)
(* Spolupracuje s unit Grafika.pas.                            *)
(*                                                             *)
(*                 Public domain software !                    *)
(*                        D. Trunec                            *)
(*        katedra fyzikalni elektroniky, Prirod. fakulta,      *)
(*      MU Brno, Kotlarska 2, 611 37 Brno, Ceska republika     *)
(*               e-mail  trunec@sci.muni.cz                    *)
(*                       (19.1. 1994)                          *)
(*                                                             *)
(* Tento program je z FTP archivu pro fyziku, ktery je umisten *)
(* na pocitaci ftp.muni.cz v adresari pub/muni.cz/physics.     *)
(* Tento archiv je pristupny pres anonymous FTP nebo pres gop- *)
(* her server gopher.muni.cz.                                  *)
(***************************************************************)

UNIT Mys;

INTERFACE

PROCEDURE ResetMouse;
(**************************************************************)
(* inicializace mysi, tato procedura musi byt volana jako     *)
(* prvni (nyni je volana v inicializacni casti teto unit)     *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE ShowMouse;
(**************************************************************)
(* zobrazi kursor mysi                                        *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE HideMouse;
(**************************************************************)
(* skryje kurzor mysi                                         *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE GetMouse(var button:word;var x,y:real);
(**************************************************************)
(* vraci souradnice polohy kurzoru mysi a informaci o stisku  *)
(* tlacitek mysi                                              *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vystupni                                                *)
(*     button ... nastaven 1. bit - stisknuto leve tlacitko   *)
(*                nastaven 2. bit - stisknuto prave tlacitko  *)
(*                nastaven 3. bit - stisknuto stredni tlacitko*)
(*     [x,y]  ... poloha kurzoru v uzivatelskych jednotkach   *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        zadne                                               *)
(*                                                            *)
(**************************************************************)

PROCEDURE ShowMousePos(var x,y:real);
(**************************************************************)
(* na dolnim radku na obrazovce zobrazuje informaci o poloze  *)
(* kurzoru mysi v uzivatelskych souradnicich, po stisku leve- *)
(* ho tlacitka mysi se procedura ukonci a vraci souradnice    *)
(* posledni polohy kurzoru. Musi byt nastaven graficky mod !  *)
(*                                                            *)
(*  popis parametru:                                          *)
(*                                                            *)
(*  - vystupni                                                *)
(*     [x,y]  ... posledni poloha kurzoru v uzivatelskych     *)
(*                jednotkach                                  *)
(*                                                            *)
(*  - volane podprogramy                                      *)
(*        GetMouse                                            *)
(*                                                            *)
(**************************************************************)

IMPLEMENTATION

USES Dos,Graph,Grafika;

var
 regs:registers;

PROCEDURE Abort(Msg : string);
begin
  Writeln(#7,' Mouse: ',Msg);
  Halt(1);
end;  (* Abort *)

PROCEDURE ResetMouse;
BEGIN
 regs.ax:=0;
 intr($33,regs);
 if regs.ax=0
  then
   begin
    if TestMode
     then
      closegraph;
    Abort('error - mouse driver not present');
   end;
END;  (* ResetMouse *)

PROCEDURE ShowMouse;
BEGIN
 regs.ax:=1;
 Intr($33,regs);
END;  (* ShowMouse *)

PROCEDURE HideMouse;
BEGIN
 regs.ax:=2;
 Intr($33,regs);
END;  (* HideMouse *)

PROCEDURE GetMouse(var button:word;var x,y:real);
var
 gx,gy:word;
BEGIN
 regs.ax:=3;
 Intr($33,regs);
 button:= regs.bx;
 gx:=regs.cx;
 gy:=regs.dx;
 x:=gx/_Graph_KoefXUuGu+_Graph_XminUu;
 y:=gy/_Graph_KoefYUuGu+_Graph_YMaxUu;
END;  (* GetMouse *)

PROCEDURE ShowMousePos(var x,y:real);
var
 xp,yp:real;
 button:word;
 sx,sy:string;
BEGIN
 xp:=0;yp:=0;
 repeat
  GetMouse(button,x,y);
  if (x<>xp) or (y<>yp)
   then
    begin
     str(x:12,sx);
     str(y:12,sy);
     sx:=sx+' '+sy;
     information(sx);
     xp:=x;yp:=y;
    end;
 until button=1;
END;

BEGIN     (* initialisation *)
 ResetMouse;

END.

(**********************************************************)
(*                konec unitu Mys                         *)
(**********************************************************)