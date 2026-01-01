*FUNCITON: IsChecked - Returns .T. if option num is checked
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function IsChecked
 Parameters str,num
 Private rans

 set talk off

 if Left(Right(str,Len(str)-num+1),1) = "X"
    rans = .T.
 else
    rans = .F.
 endif
Return rans
