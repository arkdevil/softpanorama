*FUNCTION: GetMsg - Get a message from a rc dbf file.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function GetMsg
 Parameters rcfile,ptopic
 Private mtext
 
 set exact on
 set talk off

 select select()
 use &rcfile. order topic
 
 if seek(ptopic, rcfile)
   mtext = message
 else
   mtext = "Message not found."
 endif

 close database

Return mtext
  
