/* ********************************************************************* */
/*                                                                       */
/*   File:       GROUPS.CMD                                              */
/*   Version:    1.0                                                     */
/*   Date:       1.7.1993                                                */
/*                                                                       */
/*   (c) EDV Beratung L. Braeuer, 1993                                   */
/*                                                                       */
/*   Purpose:    Display all groups, defined in ther UAS of specified    */
/*               server                                                  */
/*                                                                       */
/* ********************************************************************* */

server = '\\SERVER'

/*                                                                       */
/*  Initialize REXXLAN                                                   */
/*                                                                       */
call rxfuncadd NetLoadFuncs, RXLAN20, NetLoadFuncs
CALL NetLoadFuncs

/*                                                                       */
/*  Query defined groups with outputlevel 1. Write result in variable    */
/*  "Groups". Write number of entries in variable "Read"                 */
/*                                                                       */
SAY 'Searching for group definitions...'
ret = NetGroupEnum( server, '1', 'Groups', '', 'Read', '' )

/*                                                                       */
/*  If the return code is not 0, a error has occured. Otherwise print    */
/*  the found groups.                                                    */
/*                                                                       */
IF ret <> 0 THEN DO
   SAY 'Error in function NetGroupEnum. rc = ' || ret
   END
ELSE DO
   SAY 'Found ' || Read || ' Groups on server ' || server
   SAY
   SAY '    Name         Comment'
   SAY '--------------------------------------------------------------'
   DO i = 0 TO Read-1
      SAY '    ' || left(Groups.i.grpi1_name, 10) || '    ' || Groups.i.grpi1_comment
      END
   END

/*                                                                       */
/* free REXXLAN resources                                                */
/*                                                                       */
CALL Netdropfuncs

