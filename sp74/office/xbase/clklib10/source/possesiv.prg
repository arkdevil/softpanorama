*FUNCTION: Possesive - Make most words possesive
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Possesive
 Parameters word
 Private tstr

 set talk off
 store Trim(word) to tstr

 do case
   case (Right(tstr,1) = "'") .or. (Upper(Right(tstr,2)) = "'S")
      rstr = tstr
   case Right(tstr,1) $ "sS"
      rstr = tstr + "'"
   otherwise
      rstr = tstr + "'s"
 endcase
Return rstr
