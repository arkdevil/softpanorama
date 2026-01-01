/* ********************************************************************* */
/*                                                                       */
/*   File:       ALIAS.CMD                                               */
/*   Version:    1.0                                                     */
/*   Date:       1.7.1993                                                */
/*                                                                       */
/*   (c) EDV Beratung L. Braeuer, 1993                                   */
/*                                                                       */
/*   Purpose:    Enumerates defined aliases                              */
/*                                                                       */
/* ********************************************************************* */

server = '\\SERVER'

/*                                                                       */
/*  Initialize REXXLAN                                                   */
/*                                                                       */
call rxfuncadd NetLoadFuncs, RXLAN30, NetLoadFuncs
CALL NetLoadFuncs

/*                                                                       */
/*  Query defined aliases with outputlevel 1. Write result in variable   */
/*  "Alias". Write number of entries in variable "Read". Get info about  */
/*  all types of aliases: 1 (File) + 2 (Printer) + 4 (Serial) = 7        */
/*                                                                       */
SAY 'Enumerating aliases...'
ret = NetAliasEnum( server, '1', '7', 'Alias', '', 'Read', '' )

IF ret == 0 THEN DO
   SAY 'Found ' || Read || ' Aliases on server ' || server
   SAY
   SAY '    Name         Type        Comment'
   SAY '--------------------------------------------------------------'
   DO i = 0 TO Read-1
      SELECT
         WHEN Alias.i.ai1_type = 1 THEN type = 'FILE'
         WHEN Alias.i.ai1_type = 2 THEN type = 'PRINTER'
         WHEN Alias.i.ai1_type = 4 THEN type = 'SERIAL'
         OTHERWISE type = 'UNKNOWN'
         END
      SAY '    ' || left(Alias.i.ai1_alias, 10) || '   ' || left(type,10) || '  ' || Alias.i.ai1_remark
      END
   END
ELSE DO
   SAY 'Error in function NetAliasEnum. rc = ' || ret
   END
CALL Netdropfuncs
