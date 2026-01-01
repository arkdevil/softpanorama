*PROCEDURE: Clear the keyboard buffer.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure ClearKBD
 do while (InKey() <> 0)
 enddo 
Return
