/*
   For best results in visual layout while viewing this file, set
   tab stops to every 4 columns.
*/

/*
   pcmail.c

   copyright (C) 1987 Stuart Lynne
   Changes copyright (C) 1989 Andrew H. Derbyshure

   Copying and use of this program are controlled by the terms of the
   Free Software Foundations GNU Emacs General Public License.

*/
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>                                               /* ahd */
#include <time.h>
#ifdef	__TURBOC__
#include <dos.h>
#else
#include <signal.h>
#endif
#include <ctype.h>
#include <fcntl.h>

#ifdef __TURBOC__
#include <dir.h>
#else
#include <direct.h>
#endif
#include <process.h>
#include <errno.h>

#include "lib.h"
#include "arpadate.h"
#include "hlib.h"
#include "hostable.h"
#include "import.h"
#include "address.h"
#include "timestmp.h"											  /* ahd */
#include "getopt.h"
#include "getseq.h"
#include "pushpop.h"
#include "usertabl.h"
#include "pcmail.h"

currentfile();

/* #define UUX /* Use UUX call instead of direct spool writing */

boolean remote_address(char *address);
extern boolean ishead(char *);

#define  MOPLEN 	 9 		 /* Length of formatted header lines */
#define  LISTSIZ	 1000	 /* Unix stack limit */
#define  SKBSIZE 60

static boolean sendone(char *address, boolean remote);

static FILE *mailfile, *tempfile, *tf;
int hflag;
boolean ignsigs = TRUE;
boolean WasForwarded = FALSE;
boolean CurrentForward = FALSE;
extern boolean doreceipt;
extern int null(void);
boolean verbose = FALSE, metoo = FALSE, volapyuk = FALSE;
extern char compiled[];
static char buf[LINESIZE];
static char *tfilename = NULL;
static char *tinpcopy = NULL;
static char grade = 'L';
extern char *GradeList;
#ifndef	UUX
static char subseq( void );
#endif
void seekctlz(FILE *);

char *fromnode = NULL;	  /* For UUCP From line 	ahd   */
char *fromuser = NULL;	  /* For UUCP From line	      ahd   */

extern int debuglevel;
static int SpoolRemote = 0;

extern char *udate(void);
extern void write_stat(char *, char *, char *, char *, long);
extern boolean init_stat(void);   /*DK*/

boolean     fromunix = FALSE;
extern boolean 	filelist;
extern boolean visual_output;

void		 xt_koi8(unsigned char*);
void		 xf_koi8(unsigned char*);
void		 unctrl(unsigned char*);
void		 init_volapyuk(void);
void		 xf_volapyuk(unsigned char *, unsigned char *);
void		 xt_volapyuk(unsigned char *, unsigned char *, int);

boolean parse_args(int argc, char *argv[]) {
	int option;

	if (argc <= 1) {
Usage:
		fprintf(stderr, "Usage:\trmail [-ilvmVuZ] [-r <remote>] [-f <from>]\n\
\t[-h <hop_count>] [-X|x <debug_level>] [-l|<address> ...]\n");
		return FALSE;
	}
	while((option = getopt(argc, argv, "r:h:vilmVf:x:X:uZ")) != EOF)
		switch (option) {

		case 'h':
			hflag = atoi(optarg) + 1;
			break;

		case 'v':
			verbose = TRUE;
			break;

		case 'r':
			fromnode = optarg;
			break;

		case 'f':
			fromuser = optarg;
			break;

		case 'i':	/* Interactive mode */
			ignsigs = FALSE;
			break;

		case 'm':
			metoo = TRUE;
			break;

		case 'X':
			logecho = TRUE;
		case 'x':
			debuglevel = atoi(optarg);
			break;

		case 'u':
			fromunix = TRUE;
			break;

		case 'V':
			volapyuk = TRUE;
			break;

		case 'l':
			filelist = TRUE;
			break;

		case 'Z':
			visual_output = TRUE;
			break;

		case '?':
			goto Usage;
		}

	if (optind >= argc && !filelist)
		goto Usage;

	return TRUE;
}

void receive_by_me(FILE *tempfile)
{
	char *p = strchr(compilev, ' ');

	if (p != NULL)
		*p = '\0';

	  /*    Also create an RFC-822 Received: header               */
	  fprintf(tempfile,"%-*s by %s (%s %s, %2.2s%3.3s%2.2s);\n%-*s %s\n",
		MOPLEN, "Received:", domain, compilep, compilev,
			   &compiled[4], &compiled[0], &compiled[9],
			   MOPLEN, " ", arpadate());
	if (p != NULL)
		*p = ' ';
}

lmail(int argc, char *argv[])
{
   int argcount, errcnt, i, lines;
   char **argvec;
   static char remotes[LISTSIZ];
   static char rawlist[LISTSIZ];
   static char badlist[LISTSIZ];
   static char forlist[LISTSIZ];
   char *myname;
   char currentpath[MAXADDR];
   char retaddr[MAXADDR];
   register char *p, *q;
   boolean firstline, messbody, devolapyuk, receipt, putrec, WasLocal,
		   gotfrom, lastnl;

   assert((tfilename == NULL) && (tinpcopy == NULL));
									/* Should be freed at end of routine   */
   tfilename   = malloc(MAXPATH);
   tinpcopy    = malloc(MAXPATH);

   checkref(tfilename);
   checkref(tinpcopy);

   currentpath[0] = '\0';
	if (fromnode == NULL)
		fromnode = nodename;
	if ((myname = getenv("USER")) == NULL)
		myname = mailbox;
	if (fromuser == NULL)
		fromuser = myname;
	if (fromuser == NULL) {
		fprintf(stderr,"\nsendmail: USER variable or -f option must be set.\n");
		return(1);
	}

   if (debuglevel > 5) {
	  printmsg(5, "lmail: argc %d ", argc);
	  argcount = argc;
	  argvec = argv;
	  while (argcount--)
		 printmsg(5, " \"%s\"", *argvec++);
   }

   /*    Generate a temporary file name    */
   tinpcopy = mktempname(tinpcopy, "TMP");
   printmsg(5, "lmail: opening %s", tinpcopy);
   if ((tempfile = FOPEN(tinpcopy, "w+", BINARY)) == nil(FILE)) {
	  printerr("lmail", tinpcopy);
	  printmsg(0, "lmail: can't open %s\n", tinpcopy);
	  return(1);
   }

   if (!init_stat())		/*DK*/
	return(1);

   /*
	  Copy stdin to tempfile, adding an empty line if needed to separate
	  the body of a new message from the header, which we will generate
	  below.
	*/
   firstline = TRUE;
   devolapyuk = FALSE;
   messbody = FALSE;
   receipt = FALSE;
   putrec = FALSE;
   *retaddr = '\0';
   lines = 0;
   gotfrom = FALSE;
   lastnl = FALSE;

	while (fgets(buf, sizeof(buf), stdin) != nil(char)) {
Again:
		i = strlen(buf);
		if (i > 0 && buf[i-1] == '\n')
			buf[i-1] = '\0';

		if (!messbody) {
			if (*buf == '\0')
				messbody = TRUE;
			else if (!messbody && fromunix && strncmpi(buf, "encoding:", 8) == 0) {
				p = buf + 8;
				while (*p == ' ' || *p == '\t') p++;
				if (strncmp(p, "X-VOL", 5) == 0) {
					devolapyuk = TRUE;
					continue; /* Ignore THIS line */
				}
			}
			else if (strncmpi(buf, "return-receipt-to:", 18) == 0) {
				p = buf + 18;
				while (*p == ' ' || *p == '\t') p++;
				receipt = TRUE;
				strcpy(retaddr, p);
				firstline = FALSE;
				if (!putrec) {
					receive_by_me(tempfile);
					putrec = TRUE;
				}
				if (fputs(buf, tempfile) == EOF || fputc('\n', tempfile) == EOF) {
					printerr("lmail", tinpcopy);
					printmsg(0, "lmail: file %s, write #1 error", tinpcopy);
					return(1);
				}
				while (   (p = fgets(buf, sizeof(buf), stdin)) != nil(char)
					   && *buf == ' ' || *buf == '\t'
					  ) {
					p = buf + 1;
					while (*p == ' ' || *p == '\t') p++;
					i = strlen(p);
					if (i > 0 && p[i-1] == '\n')
						p[i-1] = '\0';
					strcat(retaddr, " ");
					strcat(retaddr, p);
					if (fputs(buf, tempfile) == EOF || fputc('\n', tempfile) == EOF) {
						printerr("lmail", tinpcopy);
						printmsg(0, "lmail: file %s, write #2 error", tinpcopy);
						return(1);
					}
				}
				if (p == nil(char))
					break;
				goto Again;
			}
			else if (strncmpi(buf, "lines:", 6) == 0)
				continue;
		}
		else
			lines++;

		if (ishead(buf)) {
			if (!messbody)
				gotfrom = TRUE;
			if (!firstline || !fromunix) {
				if (messbody)
					fputc('>', tempfile);
			}
			else if (!messbody) {
				/*
				 * Process old ugly From ... remote from ...
				 * uucp rmail header line.
				 */
#define SPLIT 400
				static char remotename[LINESIZE];

				firstline = FALSE;
				if (strstr(buf + 5, " remote from ") == NULL) {
					sscanf(buf + 5, "%s", remotename);
					if ((p = strrchr(remotename, '!')) != NULL) {
						*p++ = '\0';
						fromuser = p;
						fromnode = remotename;
					}
					else
						fromuser = remotename;
					continue;
				}
				/* Copy user name */
				p = &buf[5];
				q = &remotename[SPLIT];
				while( *p != ' ' && *p != '\t' && *p != '\0' )
					*q++ = *p++;
				*q = '\0';
				q = &remotename[SPLIT];
				/* Find 'remote from' */
				while( *p != '\0' ) {
					if( strncmp(p++, "remote from ", 12) )
						continue;
					while( *p ) p++;
					/* Strip trailing blanks */
					while( --p >= &buf[5] && *p == ' ' || *p == '\t' )
						;
					/* add an uucp part separated by ! */
					*--q = /*'!'*/'\0';	/* At SPLIT */
					while( p >= &buf[5] && *p != ' ' && *p != '\t' )
						*--q = *p--;
					/* if there was an Internet address,
					   change all '@'s to '%'s (sigh) */
					for (p = &remotename[SPLIT] + 1; *p; p++)
						if (*p == '@')
							*p = '%';
					break;
				}
				fromnode = q;
				fromuser = &remotename[SPLIT];
				continue;
			}
		}

		if (!putrec) {
			receive_by_me(tempfile);
			putrec = TRUE;
		}

		firstline = FALSE;
		strcat(buf, "\n");
		lastnl = (*buf == '\n');
		if (fputs(buf, tempfile) == EOF) {
			printerr("lmail", tinpcopy);
			printmsg(0, "lmail: file %s, write #3 error", tinpcopy);
			return(1);
		}
	} /* while */

	if (gotfrom && lastnl && --lines < 0)
		lines = 0;

	if (!receipt)
		strcpy(retaddr, fromuser);

   tfilename = mktempname(tfilename, "TMP");
   printmsg(5, "lmail: opening %s", tfilename);
   if ((tf = FOPEN(tfilename, "w", BINARY)) == nil(FILE)) {
	  printerr("lmail", tfilename);
	  printmsg(0, "lmail: can't open %s", tfilename);
	  return(1);
   }

	if (devolapyuk)
		init_volapyuk();

	rewind(tempfile);

	messbody = FALSE;
	while (fgets(buf, sizeof(buf), tempfile) != nil(char)) {
		if (*buf == '\n') {
			if (!messbody) {
				sprintf(buf, "Lines: %d\n\n", lines);
				messbody = TRUE;
			}
		}
		else {
			if (devolapyuk)
				xf_volapyuk(buf, buf);
			if (fromunix || devolapyuk)
				xf_koi8(buf);
			else
				unctrl(buf);
		}

		if (fputs(buf, tf) == EOF) {
			printerr("lmail", tfilename);
			printmsg(0, "lmail: file %s, write error", tfilename);
			return(1);
		}
	}

 /*
	  UUPC's mail depends on each message having a validly terminated
	  header.  If this mail was not terminated by a header, (common
	  for mail sent from VMS Internet sites), add terminator now.

	  Another option would be to add a check for a completely blank
	  line, that need not be of zero (0) length (the VMS mail has
	  one or two blanks), but this takes care of the basic problem.
  */

	if (fclose(tf) == EOF) {
		printerr("lmail", tfilename);
		printmsg(0, "lmail: file %s, close error", tfilename);
		return(1);
	}

   /* loop on args, copying to appropriate postbox, doing remote only once
	  remote checking is done empirically, could be better */

	argcount = argc - optind + 1;
	argvec = argv + optind - 1;
	*remotes = '\0';
	*rawlist = *badlist = *forlist = '\0';

	WasLocal = FALSE;
	errcnt = 0;
	while (--argcount > 0) {
		char *address = *++argvec;

		printmsg(5, "lmail: argv[%d]=%s", argcount, address);

		if (metoo && equal(address, mailbox))
			continue;

		if (remote_address(address)) {
			int rlen;
			char hisnode[MAXADDR];
			char hispath[MAXADDR];
			char hisuser[MAXADDR];

			user_at_node(address,hispath,hisnode,hisuser);
			printmsg(5, "lmail: remote address via %s",hispath);

   /* If this mail is going via the same path as any previously      */
   /* queued remote mail and the address will fit in the current     */
   /* output buffer, add it to the current remote host request.      */
   /* If multiple addresses routed via the same path are separated   */
   /* by requests queued for a different (non-local) path, then      */
   /* at least three separate files will be created.  This can only  */
   /* be corrected by sorting the list in path order, which is not   */
   /* not currently done.					      */

			rlen = strlen(remotes);
			if (
				rlen > 0 &&
				(
				 rlen + 1 + strlen(address) > LISTSIZ ||
				 !equal(hispath,currentpath)
				)
			   ) {
				/* no, too bad, dump it then */
				if (sendone(remotes + 1, TRUE)) {	 /* remote delivery */
					strcat(rawlist, remotes + 1);
					strcat(rawlist, "\n");
				}
				else {
					errcnt++;
					strcat(badlist, remotes + 1);
					strcat(badlist, "\n");
				}
				*remotes = '\0';
			}

		/* add *arvgvec to list of remotes */
			strcat(remotes, " ");
			strcat(remotes, address);
			strcpy(currentpath, hispath);
		} else {	/* Local */
			CurrentForward = FALSE;
			if (sendone(address, FALSE)) {	/* local delivery */
				WasLocal = TRUE;
				if (CurrentForward) {
					strcat(forlist, address);
					strcat(forlist, "\n");
				}
				else {
					strcat(rawlist, address);
					strcat(rawlist, "\n");
				}
			}	/* if */
			else {
				errcnt++;
				strcat(badlist, address);
				strcat(badlist, "\n");
			}
		 }
	}

   /* dump any remotes if necessary */
   if (strlen(remotes) > 1) {
	  if (sendone(remotes + 1, TRUE)) {   /* remote delivery */
		strcat(rawlist, remotes + 1);
		strcat(rawlist, "\n");
	  }
	  else {
		errcnt++;
		strcat(badlist, remotes + 1);
		strcat(badlist, "\n");
	  }
   }

   unlink(tfilename);

   if (   *retaddr
	   && (   receipt && doreceipt && WasLocal
		   || errcnt > 0
		   || WasForwarded
		  )
	  ) {
	   printmsg(5, "lmail: send %s results to <%s>",
				   errcnt > 0 || WasForwarded ? "bad" : "good",
				   retaddr);
	   if ((tf = FOPEN(tfilename, "w", BINARY)) == nil(FILE)) {
		  printerr("lmail", tfilename);
		  printmsg(0, "lmail: can't open %s", tfilename);
		  return(1);
	   }
	   fromuser = "MAILER-DAEMON";
	   fromnode = nodename;
	   fprintf(tf, "From: \"UUPC/@ Daemon\" <%s@%s>\n", fromuser, domain);
	   fprintf(tf, "To: %s\n", retaddr);
	   fprintf(tf, "Subject: %s",
				   receipt ? "Return Receipt" : "Delivering Errors");
	   if (receipt && (errcnt > 0 || WasForwarded))
			fprintf(tf, ": Errors");
	   fprintf(tf, "\nDate: %s\n", arpadate());
	   if (*forlist && WasForwarded) {
			fprintf(tf, "\nUnknown local user name(s):\n\n");
			for (p = forlist; *p; p++)
				if (*p == ' ')
					*p = '\n';
			fprintf(tf,"%s\nYour message forwarded to postmaster@%s\n",
						forlist, domain);
	   } /* if */
	   if (*rawlist && receipt) {
			char *start;
			boolean first;
			int len;

			first = TRUE;
			start = rawlist;
			do {
				len = strcspn(start, " \n");
				if (len > 0)
					start[len] = '\0';
				if (!remote_address(start)) {
					if (first) {
						first = FALSE;
						fprintf(tf, "\nYour message sucessfully delivered to:\n\n");
					}
					fprintf(tf, "%s\n", start);
				}
				start += len + 1;
			}
			while (len > 0 && *start);
	   }
	   if (*badlist && (errcnt > 0 || WasForwarded)) {
			for (p = badlist; *p; p++)
				if (*p == ' ')
					*p = '\n';
		   fprintf(tf, "\nI can't deliver your message to:\n\n%s", badlist);
	   }
	   fprintf(tf, "\n  ----- Message header follows -----\n");
	   rewind(tempfile);
	   while (fgets(buf, sizeof(buf), tempfile) != NULL) {
			if (*buf == '\n')
				break;
			if (devolapyuk)
				xf_volapyuk(buf, buf);
			if (fromunix || devolapyuk)
				xf_koi8(buf);
			else
				unctrl(buf);
			fputs(buf, tf);
	   }
	   if (fclose(tf) == EOF) {
		  printerr("lmail", tfilename);
		  printmsg(0, "lmail: file %s, close error", tfilename);
		  return(1);
	   }
	   ExtractAddress(buf, retaddr, FALSE);
	   p = strdup(buf);
	   if (!sendone(p, remote_address(p)))
				errcnt++;
	   free(p);
	   unlink(tfilename);
   }
   if (WasForwarded)	/* One got it! */
	  errcnt = 0;

   fclose(tempfile);
   unlink(tinpcopy);

   free(tfilename);
   tfilename = NULL;
   return errcnt > 0 ? 1 : SpoolRemote ? 48 : 0 /* 48 -- MAGIC number */;

} /*lmail*/

boolean CantDeliver = FALSE;
char mastername[] = "Postmaster";

/*
   sendone - copies file plus headers to appropriate mailbox
*/
static boolean sendone(char *address, boolean remote)
{

   char hidfile[MAXPATH]; /* host's idfile  */
   char *orgaddr = address;
   char hispath[MAXADDR];
   char hisnode[MAXADDR];
   char hisuser[MAXADDR];
   struct UserTable *user;
   boolean messbody;
   int fd;
   long letter_size;
   FILE *pf;
   long msgsz;		/*DK*/
   char *sh;			/*DK*/
   boolean filter = FALSE;	/*DK*/

   printmsg(2, "calling sendone(%s, %d)", address, remote);

	if (!remote) {  /******************** Local **********************/
		char forfile[MAXPATH];

		user_at_node(address, hispath, hisnode, hisuser);
		printmsg(5,"sendone: hisuser=%s", hisuser);
		if ((user = checkuser(hisuser)) == BADUSER) {
			if (CantDeliver) {
				printmsg(0, "sendone: %s's alias loop, check %s!", mastername, PASSWD);
				return FALSE;
			}
			CantDeliver = TRUE;
			user = checkuser(mastername);
			if (user == BADUSER) {
				printmsg(0, "sendone: can't find %s in %s", mastername, PASSWD);
				return FALSE;
			}
			address = mastername;
			strcpy(hidfile,"*NOFILE*");
		}
		else {
			filter = (sh = user->sh) != nil(char);  	/*DK*/
			/* postbox file name */
			if (strchr(hisuser, SEPCHAR) == nil(char)) {
				mkfilename(hidfile, maildir, "boxes/");
				strcat(hidfile, hisuser);
			}
			else
				strcpy(hidfile, hisuser);
			CantDeliver = FALSE;
		}

		printmsg(5, "sendone: hidfile=%s", hidfile);

		/* Handle local delivery                  */

		/* check for forwarding */
		mkfilename(forfile, user->homedir, "forward");
		printmsg(5, "sendone: checking for forwarding: %s", forfile);
		if ((mailfile = FOPEN(forfile, "r", TEXT)) != nil(FILE))
		{
			char *cp = NULL;

			if (!isatty(fileno(mailfile)))	 /* Is target normal file?  */
				cp = fgets(buf, sizeof(buf), mailfile);     /* Yes--> Read line */

			fclose(mailfile);
			if (cp != nil(char))
			{
				boolean status, oldCant, OldRemote, NewRemote;
				char *h, *s, *pcoll, sa[MAXADDR];

				for (s = &cp[strlen(cp) - 1]; s >= cp && isspace(*s); s--)
					*s = '\0';
				for ( ; *cp && isspace(*cp); cp++)
					;
				if (strlen(cp) == 0) {
					printmsg(0, "sendone: empty forward in \"%s\"", forfile);
					return FALSE;
				}
				if (   strncmpi(cp, mastername, sizeof(mastername)-1) == 0
					&& !remote_address(cp)
					&& (   cp[sizeof(mastername)-1] == '\0'
						|| cp[sizeof(mastername)-1] == '@'
					   )
				   ) {
					printmsg(0, "sendone: must be actual user name in \"%s\"", forfile);
					return FALSE;
				}
				oldCant = CantDeliver;
				status = FALSE;

				cp = strdup(cp);
				checkref(cp);
				pcoll = malloc(strlen(cp) + 1);
				checkref(pcoll);
				*pcoll = '\0';
				h = cp;
				s = NULL;
				if (*h && (s = strpbrk(h, " \t")) != NULL) {
					*s++ = '\0';
					while(isspace(*s)) s++;
				}
				if (*h) {
					strcpy(sa, h);
					OldRemote = remote_address(sa);
					strcpy(pcoll, sa);
				}
				if (s != NULL) {
					h = s;
					while (*h && (s = strpbrk(h, " \t")) != NULL) {
						*s++ = '\0';
						while(isspace(*s)) s++;
						strcpy(sa, h);
						h = s;
					Once:
						NewRemote = remote_address(sa);
						if (   NewRemote != OldRemote
							|| !OldRemote
							|| strlen(pcoll) > LISTSIZ
						   ) { /* Dump it! */
							if (sendone(pcoll, OldRemote))
								status = TRUE;
							*pcoll = '\0';
							OldRemote = NewRemote;
						}
						else
							strcat(pcoll, " ");
						strcat(pcoll, sa);
					}
					if (*h) {
						strcpy(sa, h);
						*h = '\0';
						goto Once;
					}
				}
				if (*pcoll) {
					if (sendone(pcoll, OldRemote))
						status = TRUE;
				}
				free(pcoll);
				free(cp);

				if (oldCant && status && !CantDeliver)
					WasForwarded = CurrentForward = TRUE;
				return status;
			 }
			 else if (CantDeliver) {
				 printmsg(0, "sendone: can't read %s's \"%s\"", mastername, forfile);
				 return FALSE;
			 }
		}
		else if (CantDeliver) {
			 printmsg(0, "sendone: can't open %s's \"%s\"", mastername, forfile);
			 return FALSE;
		}

		/* mailbox exist? */
		if ((fd = open(hidfile, O_RDWR)) < 0) {
			if (verbose)
				printmsg(1, "sendone: mailbox %s does not exist, creating", hidfile);
			if ((fd = creat(hidfile, 0600)) < 0) {
				printerr("sendone", hidfile);
				printmsg(0, "sendone: can't create new mailbox %s", hidfile);
				return FALSE;
			}
			(void) close(fd);
		}
		else
			(void) close (fd);

		/* open mailfile */
		if ((mailfile = FOPEN(hidfile, "r+", TEXT)) == nil(FILE)) {
			printerr("sendone", hidfile);
			printmsg(0, "sendone: cannot append to %s", hidfile);
			return FALSE;
		}
		fd_lock(hidfile, fileno(mailfile));
		seekctlz(mailfile);

	} else { /******************* Remote ****************************/
		char *p;
#ifdef	UUX
		char *h;
#endif

		/* All have the same path */
		if ((p = strchr(address, ' ')) != NULL)
			*p = '\0';
		user_at_node(address, hispath, hisnode, hisuser);
		if (p != NULL)
			*p = ' ';

		(void) mktempname(hidfile, "TMP");
		if ((mailfile = FOPEN(hidfile, "w", BINARY)) == nil(FILE)) {
			printerr("sendone", hidfile);
			printmsg(0, "sendone: cannot open to \"%s\"", hidfile);
			return FALSE;
		}
#ifdef	UUX
		fputs(hispath, mailfile);
		fputs("!rmail\n", mailfile);
		h = strdup(address);
		checkref(h);
		if ((p = strtok(h, " \t")) != NULL && *p) {
			fprintf(mailfile, "(%s)\n", p);
			while ((p = strtok(NULL, " \t")) != NULL && *p)
				fprintf(mailfile, "(%s)\n", p);
		}
		free(h);
		fputs("<<NULL>>\n", mailfile);
		if (ferror(mailfile))
			goto Ewr;
#endif	/* UUX */
	}

   msgsz = ftell(mailfile);			/*DK*/

   printmsg(5, "sendone: writing to mailfile \"%s\"", hidfile);

   /*    Create standard UUCP header for the remote system     */
	if (remote || !equal(fromnode, nodename)) {
		assert(fromnode != NULL);
		assert(fromuser != NULL);
		if (remote)	/* RFC 1123 */
				fprintf(mailfile, "From %s!%s %s remote from %s\n",
								domain, fromuser, udate(), fromnode);
		else
			fprintf(mailfile, "From %s!%s %s\n",
				fromnode, fromuser, udate());
	}
	else
		fprintf(mailfile,"From %s %s\n",
						  CantDeliver ? "MAILER-DAEMON" : fromuser,
						  udate());

	 if (CantDeliver) {
		fprintf(mailfile, "Subject: Troubles delivering the message\n\
\n\
Could not deliver a message to the following address:\n\
\n\
\t\t%s\n\
\n",
	orgaddr);
		fprintf(mailfile, "Mailer SENDMAIL.EXE, mail from %s!%s\n\
\n\
\n\
\t--------- The unsent message follows -----------\n",
						   fromnode, fromuser);
	   CantDeliver = FALSE;
   }

   /* copy tempfile to mailbox file */
   printmsg(4, "sendone: copying tempfile (%s) to mailfile (%s)",
	  tfilename, hidfile);
   if ((pf = FOPEN(tfilename, "r", BINARY)) == nil(FILE)) {
	  printerr("sendone", tfilename);
	  printmsg(0, "sendone: can't re-open %s", tfilename);
	  fclose(mailfile);
	  return FALSE;
   }

   messbody = FALSE;
   init_volapyuk();
   letter_size = 0;
   while (fgets(buf, sizeof(buf), pf) != nil(char)) {
	  char *p;
	  int len;
	  char nbuf[LINESIZE];

	  p = buf;
	  if (!messbody && *p == '\n') {
		messbody = TRUE;
		if (remote && volapyuk) {
			static char enc[] = "Encoding: X-VOL\n";

			if (fputs(enc, mailfile) == EOF) {
Ewr:
				printerr("sendone", hidfile);
				printmsg(0, "sendone: disk write error on %s", hidfile);
				fclose(mailfile);
				return FALSE;
			}
			letter_size += sizeof(enc) - 1;
		}
	  }

	  if (remote) {
		xt_koi8(p);
		if (volapyuk) {
			xt_volapyuk(p, nbuf, !messbody);
			p = nbuf;
		}
	  }
	  else
		unctrl(p);
	  fputs(p, mailfile);
	  if (ferror(mailfile))
		 goto Ewr;
	  len = strlen(p);
	  letter_size += len;
	  if (p[len-1] != '\n') {
		 putc('\n', mailfile);
		 letter_size++;
	  }
   }
   if (!remote)
		putc('\n', mailfile);

	fclose(pf);
	/* close files */
	(void) fflush(mailfile);
	if (ferror(mailfile) || real_flush(fileno(mailfile)) < 0)
		goto Ewr;

	msgsz = ftell(mailfile) - msgsz;	/*DK*/

	if (!remote)
		fclose(mailfile);
	else {
#ifndef	UUX
		static char spool_fmt[] = SPOOLFMT;   /* spool file name */
		static char dataf_fmt[] = DATAFFMT;
		char		*jobid_fmt = spool_fmt + 3;
		static char send_cmd[] = "S %s %s uucp - %s 0666 uucp\n";
		long seqno;
		char *seq = nil(char);
		char icfile[MAXPATH];  /* local C file      */
		char ixfile[32];  /* local X file      */
		char hixfile[MAXPATH]; /* host's ixfile  */
		char idfile[32];  /* local D file      */
		char rxfile[32];  /* remote X file  */
		char rdfile[32];  /* remote D file  */
		char tmfile[32];  /* temporary storage */
#else
		char *argv[20];
		int argc = 0;
		char retaddr[MAXADDR];
		char dbuf[20];
		static char gbuf[] = "-gX";
		int savein, i;
		unsigned segbuf;
		static char uux[MAXPATH] = "";
		extern char *calldir;
#endif

		if (letter_size < 5000)
			grade = GradeList[0];
		else if (letter_size < 20000)
			grade = GradeList[1];
		else if (letter_size < 50000L)
			grade = GradeList[2];
		else
			grade = GradeList[3];
#ifndef UUX
		fclose(mailfile);

		/* sprintf all required file names */
		seqno = getseq();
		seq = JobNumber( seqno );

		/****************** name of local C (call) file **************/
		sprintf(tmfile, spool_fmt, 'C', hispath, grade, seq);
		importpath(icfile, tmfile, hispath);
		printmsg(8, "tmfile=%s, icfile=%s", tmfile, icfile);

		/****************** name of remote D (data) file **************/
		sprintf(rdfile, dataf_fmt, 'D', nodename, subseq(), seq);
		/****************** name of remote X (xqt) file ***************/
		sprintf(rxfile, spool_fmt, 'X', nodename, grade, seq);

		/****************** name of local D (data) file ***************/
		sprintf(idfile, dataf_fmt, 'D', nodename, subseq(), seq);
		strcpy(buf, hidfile);
		importpath(hidfile, idfile, hispath);
		/****************** name of local X (xqt) file **************/
		sprintf(ixfile, spool_fmt, 'D', nodename, grade, seq);
		importpath(hixfile, ixfile , hispath);

		/**************** create local D (data) file *******************/
		if (RENAME(buf, hidfile) != 0) {
			printerr("sendone", buf);
			printmsg(0, "sendone: can't rename %s to D file %s", buf, hidfile);
			return FALSE;
		}
		/**************** end local D (data) file *******************/

		/**************** create remote X (xqt) file *******************/
		if ((mailfile = FOPEN(hixfile, "w", BINARY)) == nil(FILE)) {
			printerr("sendone", hixfile);
			printmsg(0, "sendone: can't open X file %s", hixfile);
			return FALSE;
		}

		sprintf(buf, jobid_fmt, hispath, grade, seq);
		/* RFC 1123 */
		fprintf(mailfile, "U uucp %s\nR %s!%s\nJ %s\nF %s\nI %s\nC rmail %s\n",
				nodename, domain, fromuser, buf, rdfile, rdfile, address);
		if (fclose(mailfile) == EOF)
			goto Ewr;
		/**************** end remote X (xqt) file *******************/

		/****************** create local C (call) file **************/
		mailfile = FOPEN(icfile, "w", TEXT);
		if (mailfile == nil(FILE)) {
			printerr("sendone", icfile);
			printmsg(0, "sendone: cannot open C file %s", icfile);
			return FALSE;
		}
		fprintf(mailfile, send_cmd, idfile, rdfile, idfile);
		fprintf(mailfile, send_cmd, ixfile, rxfile, ixfile);
		if (fclose(mailfile) == EOF)
			goto Ewr;
		/****************** end local C (call) file **************/
#else	/* UUX */
		argv[argc++] = "uux";
		if (debuglevel > 0) {
			sprintf(dbuf, "-%c%d", logecho ? 'X' : 'x', debuglevel);
			argv[argc++] = dbuf;
		}
		sprintf(retaddr, "-a%s!%s", domain, fromuser);
		argv[argc++] = retaddr;
		gbuf[2] = grade;
		argv[argc++] = gbuf;
		argv[argc++] = "-r";
		argv[argc++] = "-l";
		argv[argc++] = "-";
		argv[argc] = NULL;

		if (!*uux)
			mkfilename(uux, calldir, "uux.exe");

		rewind(mailfile);
		if ((savein = dup(fileno(stdin))) < 0) {
			printerr("shell", "dup(0)");
			printmsg(0, "sendone: can't prepare for uux");
			return FALSE;
		}
		if (dup2(fileno(mailfile), fileno(stdin)) < 0) {
			printerr("shell", "dup2(mailfile, 0)");
			printmsg(0, "sendone: can't prepare for uux");
			return FALSE;
		}
		fclose(mailfile);

		printmsg(5, "sendone: (%s) %s executing...", argv[0], uux);
		if (debuglevel >= 10) {
			printmsg(10, "sendone: args list:");
			for (i = 0; i < argc; i++)
				printmsg(10, "  argv[%d] = '%s'", i, argv[i]);
		}
		i = -1;
		if (   allocmem((unsigned)((SKBSIZE * 1024L) >> 4), &segbuf) != -1
			|| freemem(segbuf)
		)
			goto NotStarted;
		if ((i = spawnvp (P_WAIT, uux, argv)) < 0) {
			int nomem;
	NotStarted:
			nomem = (errno == ENOMEM);
			printmsg(0, "sendone: (%s) %s not started: %s", argv[0], uux, sys_errlist[errno]);
			if (nomem)
				printmsg(0,
					"sendone: I need %dKb of free memory to run UUX",
					SKBSIZE);
		}
		else
			setcbrk(!ignsigs);

		if (dup2(savein, fileno(stdin)) < 0) {
			printerr("shell", "dup2(savein, 0)");
			printmsg(0, "sendone: can't recover after uux");
			return FALSE;
		}
		fflush(stdin);
		clearerr(stdin);
		close(savein);
		remove(hidfile);

		if (i > 0)
			printmsg(0, "sendone: uux error code %d", i);
		if (i != 0)
			return FALSE;
#endif	/* UUX */
		SpoolRemote++;
		if (verbose)
			fprintf(stderr, "Message for remote system %s queued\n", hispath);
	}

	if (filter) { int i;
		if ((i = spawnl(P_WAIT,sh,sh,hidfile,NULL)) != 0)	/*DK*/
			printmsg(0,"sendone: error %d while executing %s %s",
						i,sh,hidfile);
		else
			setcbrk(!ignsigs);
		remove(hidfile);
		if (i != 0)
			return FALSE;
	}	/*DK*/

	write_stat(fromuser,fromnode,address,hispath,msgsz);		/*DK*/

	return TRUE;
} /*sendone*/


/* Determine if a given address is remote or local		  */
/* Strips address down to user id if the address is local.        */
/* Written 14 May 1989 by ahd                                     */

boolean remote_address(char *address)
{
   char  hisnode[MAXADDR];
   char  hispath[MAXADDR];
   char  hisuser[MAXADDR];
   boolean result;
   char *s;

   user_at_node(address,hispath,hisnode,hisuser);

   if (equali(hispath,nodename))  /* Local user?                           */
   {                          /* Yes --> Shorten address and report local  */
	  strcpy(address,hisuser);
	  if ((s = strchr(address,'%')) != NULL)
		*s = '\0';
	  result = FALSE;
   }
   else
	  result = TRUE;          /* No -->   Report user is remote            */

   printmsg(4, "remote_address: %s is %s", address,
										   result ? "remote" : "local");

   return result;

}/* remote_address */

#ifndef	UUX
/*--------------------------------------------------------------------*/
/*    s u b s e  q                                                    */
/*                                                                    */
/*    Generate a valid sub-sequence number                            */
/*--------------------------------------------------------------------*/

static char subseq( void )
{
   static char next = '0' - 1;

   do {
	   switch( next )
	   {
		  case '9':
			 next = 'A';
			 break;

		  case 'Z':
			 next = 'a';
			 break;

		  default:
			 next++;
	   } /* switch */
   } while (next == grade);

   return next;

} /* subseq */
#endif	/* UUX */

void
seekctlz(f)
FILE *f;
{
	long size, offset;

	fseek(f, 0L, 2);
	size = ftell(f);
	for (offset = 1; offset <= size; offset++) {
		fseek(f, -offset, 2);
		if (getc(f) != ('Z'&037)) {
			fseek(f, 0L, 1);	/* One seek between read and write */
			return;
		}
	}
	rewind(f);
}
