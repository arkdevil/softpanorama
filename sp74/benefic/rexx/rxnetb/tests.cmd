/*                                                               */
/*      REXX/NETBIOS Sample Client Pgm                           */
/*                                                               */
/*                                                               */
/*      Tell REXX there is a new function available              */
/*                                                               */

call rxfuncadd 'netbios', 'rexxnetb', 'netbiossrv'


/*                                                               */
/*      Client station name, must be 16 bytes                    */
/*                                                               */

Myname=left('Test',16,' ')
RemoteName =left('Sample',16,' ')

/*                                                               */
/*      call netbios and get resources from the global pool      */
/*      defined in PROTOCOL.INI                                  */
/*                                                               */

rc=netbios('Reset',0,1,1,1)

/*                                                               */
/* if resources available                                        */
/*                                                               */

if rc=0 then do

/*                                                               */
/* add our name to the network, and get the name number          */
/*                                                               */
  parse value netbios('AddName',0,MyName) with rc name_num .

/*                                                               */
/* If we are on the network now, call our partner                */
/*                                                               */

  parse value netbios('Call',0,MyName,RemoteName,0,0) with rc lsn .

/*                                                               */
/* If call succeeded send a message                              */
/*                                                               */
  if rc=0 then do
    rc=netbios('Send',0,lsn,'test data')
/*                                                               */
/* If send succeeded wait for a response                         */
/*                                                               */
    if rc=0 then do
/*                                                               */
/* If receive succeeded report the received message              */
/*                                                               */
      rc=netbios('Receive',0,lsn,1000,'data.')
      if rc=0 then do
        say
        say 'We received the following message from "' || strip(RemoteName) || '"'
        say data.0
      end
      else say 'Receive failed rc=' || rc
    end
    else say 'Send failed rc=' || rc
/*                                                               */
/* end session now as we are done                                */
/*                                                               */
    call netbios 'Hangup',0,lsn
  end

/*                                                               */
/* return our netbios resources to the global pool               */
/*                                                               */
  call netbios 'Close',0

end
/*                                                               */
/* oops, either no Netbios resources are available or            */
/*       Netbios is not installed                                */
/*                                                               */
else say 'Netbios resources not available rc='rc
