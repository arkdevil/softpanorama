
{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{    Версия 1.0 от 11.11.1991 14.00.45.55        }
{************************************************}


{$A+,B-,D-,F-,I-,O-,R-,L-}

Unit Compress;

Interface

Function UnLz( Var _FO, _FN : String ) : Boolean;

Implementation

{$F+}
Procedure AntiLz( var Res : Byte; S1, S2 : String ); External;
{$L unlzexe.obj}
{$F-}

Function UnLz;
Var
   Result : Byte;
Begin
     UnLz := False;
     AntiLz( Result, _FO, _FN );
     If Result = 0 then UnLz := True;
End;

End.
