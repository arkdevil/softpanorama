/* ********************************************************************* */
/*                                                                       */
/*   File:       WHOAMI.CMD                                              */
/*   Version:    1.0                                                     */
/*   Date:       1.7.1993                                                */
/*                                                                       */
/*   (c) EDV Beratung L. Braeuer, 1993                                   */
/*                                                                       */
/*   Purpose:    Test if a user is logged on. If so display his name     */
/*                                                                       */
/* ********************************************************************* */

/*                                                                       */
/*  Initialize REXXLAN                                                   */
/*                                                                       */
call rxfuncadd NetLoadFuncs, RXLAN20, NetLoadFuncs
CALL NetLoadFuncs

/*                                                                       */
/*  Use NetWkstaGetInfo to test if a user is logged on. Write result in  */
/*  "WkInfo". Use level 10 to enable user also to use it.                */
/*                                                                       */
SAY 'Querying workstation info...'
ret =  NetWkstaGetInfo( '', '10', 'WkInfo', '0', '0' )

IF ret = 0 THEN DO
   SAY 'Logged on user : ' || WkInfo.wki10_username
   SAY 'Workstation    : ' || WkInfo.wki10_computername
   SAY 'Logon domain   : ' || WkInfo.wki10_logon_domain
   SAY 'Default domain : ' || WkInfo.wki10_langroup
   END
ELSE DO
   SAY 'Error in NetWkstaGetInfo rc = ' || ret
   END


/*                                                                       */
/* free REXXLAN resources                                                */
/*                                                                       */
CALL Netdropfuncs
