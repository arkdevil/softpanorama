
{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{    Версия 2.0 от                               }
{************************************************}

{$A+,B-,D+,F-,I-,O-,R-,L+}
Unit Decomp;

Interface

function LZExpand(Var _FO, _FN : String) : Boolean;

Implementation

{$F+}
procedure AntiLz(var Res : Byte; S1, S2 : String); External;
{$L unlzexe.obj}
{$F-}

function LZExpand(Var _FO, _FN : String) : Boolean;
Var
  Result : Byte;
begin
  LZExpand := False;
  AntiLz(Result, _FO, _FN);
  If Result = 0 then LZExpand := True;
end;

End.
