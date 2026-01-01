/*--------------------------------------------------------------------*/
/*    File transfer information for UUPC/extended                     */
/*                                                                    */
/*    Copyright (c) 1991, Andrew H. Derbyshire                        */
/*--------------------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/*                       standard include files                       */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>

/*--------------------------------------------------------------------*/
/*                    UUPC/extended include files                     */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "dcp.h"
#include "dcpstats.h"
#include "hlib.h"
#include "hostable.h"
#include "hostatus.h"
#include "timestmp.h"

extern requests, totreqs;

/*--------------------------------------------------------------------*/
/*                          Global variables                          */
/*--------------------------------------------------------------------*/

currentfile();

/*--------------------------------------------------------------------*/
/*    d c s t a t s                                                   */
/*                                                                    */
/*    Report transmission information for a connection                */
/*--------------------------------------------------------------------*/

void dcstats(void)
{
   if (hostp == BADHOST)
   {
      printmsg(0,"dcstats: host structure pointer is NULL");
	  panic();
   }

   if (!equal(rmtname , hostp->hostname))
	  return;

   if (remote_stats.lconnect <= 0)
		return;

   {
	  time_t connected;
	  unsigned long bytes;
	  unsigned long bps;

	  connected = time(NULL) - remote_stats.lconnect;
	  remote_stats.connect += connected;
	  bytes = remote_stats.bsent + remote_stats.breceived;
	  if ( connected <= 0 )
		 connected = 1;
	  bps = bytes / connected;

	  if (requests == 0)
		  printmsg(1, "dcstats: no messages sent to %s (%s)",
						 rmtname, hostp->hostname);
	  else
		  printmsg(1, "dcstats: %d message(s) sent to %s (%s)",
						requests, rmtname, hostp->hostname);

	  printmsg(1,"%ld files sent, %ld files received, \
%ld bytes sent, %ld bytes received",
			remote_stats.fsent, remote_stats.freceived ,
			remote_stats.bsent, remote_stats.breceived);
	  printmsg(1, "%ld packets transferred, %ld errors, \
connection time %ld:%02ld, %ld bytes/second",
			(long) remote_stats.packets,
			(long) remote_stats.errors,
			(long) connected / 60L, (long) connected % 60L, bps);

   }

   totreqs += requests;

   if (remote_stats.lconnect > hostp->hstats->lconnect)
      hostp->hstats->lconnect = remote_stats.lconnect;
   if (remote_stats.ltime > hostp->hstats->ltime)
      hostp->hstats->lconnect = remote_stats.lconnect;

   hostp->hstats->connect   += remote_stats.connect;
   hostp->hstats->calls     += remote_stats.calls;
   hostp->hstats->fsent     += remote_stats.fsent;
   hostp->hstats->freceived += remote_stats.freceived;
   hostp->hstats->bsent     += remote_stats.bsent;
   hostp->hstats->breceived += remote_stats.breceived;
   hostp->hstats->errors    += remote_stats.errors;
   hostp->hstats->packets   += remote_stats.packets;

} /* dcstats */

/*--------------------------------------------------------------------*/
/*    d c u p d a t e                                                 */
/*                                                                    */
/*    Update the status of all known hosts                            */
/*--------------------------------------------------------------------*/

void dcupdate( void )
{
   boolean firsthost = TRUE;
   struct HostTable *host;
   FILE *stream;
   size_t len1 = strlen(compilep );
   size_t len2 = strlen(compilev );

   if ((stream  = FOPEN(DCSTATUS, "w", BINARY)) == NULL)
      return;

   fwrite( &len1, sizeof len1, 1, stream );
   fwrite( &len2, sizeof len2, 1, stream );
   fwrite( compilep , 1, len1, stream);
   fwrite( compilev , 1, len2, stream);
   fwrite( &start_stats , sizeof start_stats , 1,  stream);

   while  ((host = nexthost( firsthost )) != BADHOST)
   {
      len1 = strlen( host->hostname );
      len2 = sizeof *(host->hstats);

      firsthost = FALSE;

      fwrite( &len1, sizeof len1, 1, stream );
      fwrite( &len2, sizeof len2, 1, stream );
      fwrite( host->hostname , sizeof hostp->hostname[0], len1, stream);
	  host->hstats->save_hstatus = ( host->hstatus == called ) ?
					 succeeded : host->hstatus;
	  fwrite( host->hstats , len2, 1,  stream);
      memset( host->hstats , '\0', len2); /* Clear totals            */
   }

/*--------------------------------------------------------------------*/
/*         Make we sure got end of file and not an I/O error          */
/*--------------------------------------------------------------------*/

   if (ferror( stream ))
   {
	  printerr( "dcupdate", DCSTATUS );
      clearerr( stream );
   }
   fclose( stream );

} /* dcupdate */
