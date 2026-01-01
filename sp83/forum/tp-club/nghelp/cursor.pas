{$A+,B-,E+,F-,I-,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit Cursor;

Interface

Uses YNSystem;


Type CursorShapeOBJ = Object
      C : Array [1..5] of Word;
      P : Byte;
      {Methods...}
      Procedure Init;
      Procedure Done;
      Procedure PushCursor;
      Procedure PopCursor;
     End;

Implementation

Procedure CursorShapeOBJ.Init;
Begin
 P := 0;
End;

Procedure CursorShapeOBJ.Done;
Begin

End;

Procedure CursorShapeOBJ.PushCursor;
Begin
 Inc(P);
 C[P] := GetCursorShape;
End;

Procedure CursorShapeOBJ.PopCursor;
Begin
 if P > 0 then
  Begin
   SetCursorShape(C[P]);
   Dec(P);
  End;
End;

End.