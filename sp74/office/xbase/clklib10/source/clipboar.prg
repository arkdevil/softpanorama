**FILE: Clipboard routines - ShowClip, Cut, Paste, Copy

*PROCEDURE: ShowClip - Dump the clipboard at given position.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure ShowClip
 Parameters row1,col1,fcolor
 Public jClipBoard

 @row1,col1 say jClipBoard color &fcolor.
Return


*PROCEDURE: Cut - Remove the contents of the current field to the cb.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure Cut
 Parameters field
 Public jClipBoard
 Private ch

 set talk off

 store Type(field) to ch
 store &field. to jClipBoard

 do case
   case "C" = ch
     store "" to &field.
   case "N" = ch
     store 0 to &field.
   case "L" = ch
     store .T. to &field.
   case "D" = ch
     store {} to &field.
   case "F" = ch
     store 0.0 to &field.
 endcase
Return

*PROCEDURE: Copy - Copy the contents of the cur. field to the cb.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure Copy
 Parameters field
 Public jClipBoard

 set talk off
 store &field. to jClipBoard

Return

*PROCEDURE: Paste - Copy the contents of the cb to the cur. field.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure Paste
 Parameters field
 Public jClipBoard

 set talk off
 store &field.+jClipBoard to &field.
Return

*PROCEDURE: ClipBoard - Store text to the clipboard.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994
**NOTE    : This procedure MUST be called before any of the above!

Procedure ClipBoard
 Parameters text
 Public jClipBoard

 set talk off
 store text to jClipBoard
Return
