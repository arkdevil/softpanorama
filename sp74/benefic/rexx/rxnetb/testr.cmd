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

Myname=left('Sample',16,' ')
RemoteName =left('*',16,' ')

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
/* If we are on the network now,                                 */
/* Listen  for a call now                                        */
/*                                                               */
  parse value netbios('Listen',0,MyName,RemoteName,0,0) with rc lsn CallerName .

/*                                                               */
/* If Listen succeeded wait for a message                        */
/*                                                               */
  if rc=0 then do
    rc=netbios('Receive',0,lsn,1000,'data.')
/*                                                               */
/* If receive succeeded report the received message              */
/*                                                               */
    if rc=0 then do
      say 'We received the following message from "' || strip(CallerName) || '"'
      say data.0
/*                                                               */
/* and send it back with some additional info                    */
/*                                                               */
      call netbios 'Send',0,lsn,data.0 'Response'
    end
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