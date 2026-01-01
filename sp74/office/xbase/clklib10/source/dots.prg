*FUNCTION: Dots - Pad the end of a string with dots (.)
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 7 Jul 1994

Function Dots
 Parameters name, size
 Private rstr

 rstr = name + Replicate(".",size-Len(name))

Return rstr
