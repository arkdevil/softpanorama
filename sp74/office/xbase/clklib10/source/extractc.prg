*FUNCTION: ExtractCh - Get the num-th char from a string.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function ExtractCh
 Parameters str,num

Return Left(Right(str,Len(str)-num+1),1)
