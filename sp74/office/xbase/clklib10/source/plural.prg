*FUNCTION: Plural - Make most words plural
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Plural
 Parameters word
 Private rstr
 
 set talk off

 store Trim(word) to tstr
 
 do case
    case Upper(Right(tstr,2)) = "'S"
       rstr = Left(tstr,Len(tstr)-2) + "s'"

    case Right(tstr,1) $ "sS"
       rstr = tstr
          
    case (Right(tstr,1) $ "hH") .or. (Upper(Right(tstr,2)) = "SS")
       rstr = tstr + "es"

    case Upper(Right(tstr,2)) = "S'"
       rstr = tstr

    otherwise
       rstr = tstr + "s"
 endcase 

Return rstr
