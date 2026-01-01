: S.
   Depth
   If
      Depth 0
      Do
         Depth i - 1- Pick . Space
      Loop
   Else
      ." Stack is empty"
   Then
;

: DUMP ( Addr Bytes --> )
   16/ 1+ 0
   Do
      Dup .Hex ." : "
      16 0 Do
         Dup i + c@ .HByte Space
      Loop
      16 0 Do
         Dup i + c@ Dup Bl < If Drop c" . Then Emit
      Loop
      16 + Cr
   Loop
   Drop
;

: FORTHLOOP
   Begin
      ." \r\n>"
      129 78 Expect
      Span @
      If
         Cr
         Span @ 128 c!
         128 Load
         State @
         IfNot
            ."  - Ok"
         Then
      Then
   Again
;

: FORTH
   Decimal
   ." \r\n            Forth system   Version "
   $ 103 c@ . c" . Emit $ 104 c@ .
   ." \r\nCopyright (C), 1992 by The Golden Porcupine Software"
   ." \r\n                * * * * * * * * * *\r\n"
   ForthLoop
;

: FORTHERR
   ErrNo @ True =
   IfNot
      Base @ >r Decimal
      ." Error #" ErrNo @ . ."    "
      r> Base !
      ?Messages
      If
         ErrNo @ ErrorMessage .ASCIIz
      Then
   Then
   0 State !
   DropAll
   RDropAll
   ForthLoop
;

' ForthErr ErrorProc !

Restart Forth
Save fs.com
