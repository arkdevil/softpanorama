/* ********************************************************************* */
/*                                                                       */
/*   File:       MAIL.CMD                                                */
/*   Version:    1.0                                                     */
/*   Date:       1.7.1993                                                */
/*                                                                       */
/*   (c) EDV Beratung L. Braeuer, 1993                                   */
/*                                                                       */
/*   Purpose:    Ask for a user to send message then pull message.       */
/*                                                                       */
/* ********************************************************************* */

/*                                                                       */
/*  Initialize REXXLAN                                                   */
/*                                                                       */
call rxfuncadd NetLoadFuncs, RXLAN20, NetLoadFuncs
CALL NetLoadFuncs

/*                                                                       */
/*  Pull destination address                                             */
/*                                                                       */
SAY 'Destination : '
name = LINEIN()

/*                                                                       */
/*  Pull message text.                                                   */
/*                                                                       */
SAY 'Enter Message : '
message = LINEIN()

SAY 'NetMessageBufferSend rc = ' || NetMessageBufferSend( '', name, message, '0' )

/*                                                                       */
/* free REXXLAN resources                                                */
/*                                                                       */
CALL Netdropfuncs
