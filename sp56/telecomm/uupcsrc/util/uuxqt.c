/*
   d c x q t

   A command formatter for DCP.  RH Lamb

   Sets up stdin and stdout on various machines.
   There is NO command checking so watch what you send and who you let
   to have access to your machine.  "C rm /usr/*.*" could be executed!

   Changes Copyright (C) 1991, Andrew H. Derbyshire


   Change history:

	  Broken out of UUIO, June 1991 Andrew H. Derbyshire
*/

/*--------------------------------------------------------------------*/
/*                        System include files                        */
/*--------------------------------------------------------------------*/

#include <ctype.h>
#include <process.h>
#include <io.h>
#include <dos.h>
#include <dir.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

/*--------------------------------------------------------------------*/
/*                    UUPC/extended include files                     */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "getopt.h"
#include "hlib.h"
#include "hostable.h"
#include "import.h"
#include "pushpop.h"
#include "readdir.h"
#include "timestmp.h"
#include "arpadate.h"
#include "usertabl.h"
#include "screen.h"
unsigned _stklen = 0x3000;

#define LINESIZE (1024+2)   /* Line length in command files */

currentfile();

extern int screen;
static char *user = NULL, *machine = NULL, *requestor = NULL;
static char badjobdir[FILENAME_MAX];

#define SKBSIZE 150  /* Memory(Kb) needed for rmail.exe + uux.exe */
#define CKBSIZE 150	 /* Memory(Kb) needed for compress.exe */
#define ZKBSIZE 150     /*  Memory(Kb) needed for unzip.exe */

int	c_break(void);
int c_ign(void) { return 1; }
boolean BreakPressed = FALSE;
int handled;

/*--------------------------------------------------------------------*/
/*                        Internal prototypes                         */
/*--------------------------------------------------------------------*/

static int  shell(boolean dopath, char *command, char *inname, char *outname,
					 char *errname, const char *remotename);

static void usage( void );

static boolean dcxqt( const char *system );

static void process( const char *fname, const char *remote );

static int rmail(int argc, char* argv[]);

static int rbmail(char *inname, char *rmtname);
static int rzbmail(char *inname, char *rmtname);
static int rnews(int argc, char* argv[]);
static int notimp(int argc, char* argv[]);

void doneinfo(void)
{
	if (handled == 0)
		printmsg(-1, "No messages received.");
	else
		printmsg(-1, "%d message(s) received.", handled);
}

/*--------------------------------------------------------------------*/
/*    m a i n                                                         */
/*                                                                    */
/*    Main program                                                    */
/*--------------------------------------------------------------------*/

void main( int argc, char **argv)
{
   int c;
   extern char *optarg;
   extern int   optind;
   char *system = "all";
   static char logname[FILENAME_MAX];

/*--------------------------------------------------------------------*/
/*        Process our arguments                                       */
/*--------------------------------------------------------------------*/

   while ((c = getopt(argc, argv, "s:x:X:S")) !=  EOF)
	  switch(c) {

	  case 's':
		 system = optarg;
		 break;

	  case 'X':
		 logecho = TRUE;
	  case 'x':
		 debuglevel = atoi( optarg );
		 break;
	  case 'S':
		 screen = 0;
		 break;
	  default:
	  case '?':
		 usage();
   }
   if (optind != argc) {
	  fprintf(stderr, "Extra parameter(s) at end.\n");
	  usage();
   }

   Ssaveplace(1);
   atexit(Srestoreplace);

/*--------------------------------------------------------------------*/
/*     Report our version number and date/time compiled               */
/*--------------------------------------------------------------------*/

   banner( argv );

/*--------------------------------------------------------------------*/
/*                             Initialize                             */
/*--------------------------------------------------------------------*/

   if (!configure())
	  exit(1);   /* system configuration failed */

	/* Trap control C exits */
# ifdef __TURBOC__
	ctrlbrk(c_break);
	setcbrk(1);
# else
	signal(SIGINT, c_break);
	signal(SIGBREAK, c_break);
# endif

   mkfilename(logname, spooldir, "uuxqt.log");
   if (debuglevel > 0 && logecho &&
		(logfile = FOPEN(logname, "w", TEXT)) == nil(FILE)) {
	  logfile = stdout;
	  printerr("main", logname);
   }
   mkfilename(badjobdir, spooldir, "bad.job");

   checkuser( homedir  );     /* Force User Table to initialize      */
   checkreal( mailserv );     /* Force Host Table to initialize      */

   cleantmp();

   handled = 0;
   atexit(doneinfo);

/*--------------------------------------------------------------------*/
/*    Actually invoke the processing routine for the eXecute files    */
/*--------------------------------------------------------------------*/

   dcxqt( system );

   if (BreakPressed)
	exit(100);

   if( equal( system , "all" ) )
	   dcxqt( nodename );

   exit(BreakPressed ? 100 : 0);
} /* main */

/* c_break   -- control break handler to allow graceful shutdown   */
/* of interrupt handlers, etc.               */

int c_break(void) {

#ifdef	__TURBOC__
	setcbrk(0);
	ctrlbrk(c_ign);
#else
	signal(SIGINT, SIG_IGN);
	signal(SIGBREAK, SIG_IGN);
#endif

	printmsg(0, "c_break: program aborted by user Ctrl-Break (wait...)");

	BreakPressed = TRUE;

	return 1;
}


/*--------------------------------------------------------------------*/
/*    d c x q t                                                       */
/*                                                                    */
/*    Processing incoming eXecute (X.*) files for a remote system     */
/*--------------------------------------------------------------------*/

static boolean dcxqt( const char *system )
{
   struct HostTable *hostp;
   char   hostn[15];

/*--------------------------------------------------------------------*/
/*                 Determine if we have a valid host                  */
/*--------------------------------------------------------------------*/

   if( !equal( system , "all" ) )
   {
	  if (equal( system , nodename ))
		  hostp = checkname( system );
	  else
		  hostp = checkreal( system );

	  if (hostp  ==  BADHOST)
	  {
		 printmsg(0, "dcxqt: unknown host \"%s\", program terminating.",
			   system );
		 panic();
	  }
   } /* if */
   else
	  hostp = nexthost( TRUE );

/*--------------------------------------------------------------------*/
/*                  Switch to the spooling directory                  */
/*--------------------------------------------------------------------*/

   PushDir( spooldir );
   atexit( PopDir );

/*--------------------------------------------------------------------*/
/*             Outer loop for processing different hosts              */
/*--------------------------------------------------------------------*/

   while  (hostp != BADHOST)
   {
	  struct file_queue *current;

		if (BreakPressed)
			exit(100);
		 strcpy(hostn,hostp->hostname); hostn[VALIDLEN]='\0';
		 current = (struct file_queue *)
						   xreaddir(NULL, hostn, "X", NULL);
							  /* Get list of files in the directory  */
/*--------------------------------------------------------------------*/
/*           Inner loop for processing files from one host            */
/*--------------------------------------------------------------------*/

		 while (current != NULL )
		 {
			struct file_queue *save_link = current->next_link;

			if (BreakPressed)
				exit(100);
			process( current->name , hostp->hostname );
			free( current );
			current = save_link; /* Step to next file in queue, if any  */
		 } /* current != NULL */

/*--------------------------------------------------------------------*/
/*    If processing all hosts, step to the next host in the queue     */
/*--------------------------------------------------------------------*/

	  if( equal(system,"all") )
		 hostp = nexthost( FALSE );
	  else
		 hostp = BADHOST;

   } /*while nexthost*/

   return FALSE;

} /* dcxqt */

/*--------------------------------------------------------------------*/
/*    p r o c e s s                                                   */
/*                                                                    */
/*    Process a single execute file                                   */
/*--------------------------------------------------------------------*/

void static process( const char *fname, const char *remote )
{
   char *command = NULL,
		*input = NULL,
		*output = NULL,
		*token = NULL;
   static char line[LINESIZE];
   char hostfile[FILENAME_MAX];
   boolean skip = FALSE;
   boolean reject = FALSE;
   int result = 0;
   FILE *fxqt;

   if (requestor != NULL) {
	 free(requestor);
	 requestor = NULL;
   }
   if (user != NULL) {
	  free(user);        /* Release any old name       */
	  user = NULL;
   }
   user = strdup("uucp");   /* user if none given */
							/* must allocate for later free call */
   checkref(user);
   if (machine != NULL) {
	   free(machine);        /* Release any old name       */
	   machine = NULL;
   }

/*--------------------------------------------------------------------*/
/*                         Open the X.* file                          */
/*--------------------------------------------------------------------*/

   fxqt = FOPEN(fname, "r", BINARY);   /* inbound X.* file */
   if (fxqt == NULL)
   {
	  printerr("process", fname);
	  printmsg(0,"process: cannot open file \"%s\"",fname);
	  return;
   }
   else
	  printmsg(2, "process: processing %s", fname);

/*--------------------------------------------------------------------*/
/*                  Begin loop to read the X.* file                   */
/*--------------------------------------------------------------------*/

   while (!skip && fgets(line, sizeof(line) - 1, fxqt) != nil(char))
   {
	  char *cp;

	  line[sizeof(line) - 1] = '\0';
	  if ((cp = strchr(line, '\n')) != nil(char))
		 *cp = '\0';

	  printmsg(8, "process: %s", line);

/*--------------------------------------------------------------------*/
/*            Process the input line according to its type            */
/*--------------------------------------------------------------------*/

	  switch (line[0])
	  {

/*--------------------------------------------------------------------*/
/*                  User which submitted the command                  */
/*--------------------------------------------------------------------*/

	  case 'U':
		 strtok(line," \t\n");      /* Trim off leading "U"       */
		 cp = strtok(NULL," \t\n"); /* Get the user name          */
		 if ( cp == NULL )
		 {
			printmsg(0,"process: no user on U line \
in execute file \"%s\"", fname );
			cp = "uucp";            /* Use a nice default ...     */
		 }
		 user = strdup(cp);     /* Reallocate new user name   */
		 checkref(user);

									/* Get the system name        */
		 if ( (cp = strtok(NULL," \t\n")) == NULL) { /* Did we get a string?       */
			printmsg(0,"process: no node on U line in file \"%s\"", fname );
			cp = (char *) remote;
		 } else if (!equal(cp,remote)) {
			/* Just a message */
			printmsg(-1, "process: node '%s' on U line in file \"%s\" doesn't match remote",
					 cp, fname );
			cp = (char * ) remote;
		 }
		 machine = strdup(cp);     /* Reallocate new node name   */
		 checkref(machine);
		 checkreal(machine);
		 break;

/*--------------------------------------------------------------------*/
/*                       Input file for command                       */
/*--------------------------------------------------------------------*/

	  case 'I':
		 input = strdup( &line[2] );                     /* ahd   */
		 checkref(input);
		 if (!equaln(input,"D.",2)) {
			printmsg(0, "process: invalid input file name: %s", input);
			reject = TRUE;
		 }
		 break;

/*--------------------------------------------------------------------*/
/*                      Output file for command                       */
/*--------------------------------------------------------------------*/

	  case 'O':
		 output = strdup( &line[2] );                    /* ahd   */
		 checkref(output);
		 if (!equaln(output,"D.",2)) {
			printmsg(0, "process: invalid output file name: %s", output);
			reject = TRUE;
		 }
		 break;

/*--------------------------------------------------------------------*/
/*                         Command to execute                         */
/*--------------------------------------------------------------------*/

	  case 'C':
		 command = strdup( &line[2] );                   /* ahd   */
		 checkref(command);                              /* ahd   */
		 break;

/*--------------------------------------------------------------------*/
/*                 Check that a required file exists                  */
/*--------------------------------------------------------------------*/

	  case 'F':
		 token = strtok(&line[1]," \t");
		 importpath(hostfile, token, remote);
		 printmsg(4, "process: check existance of \"%s\"", hostfile);
		 if ( access( hostfile, 0 ))   /* Does the host file exist?  */
		 {
			printmsg(0,"process: missing required file %s (%s) for %s, \
command skipped", token, hostfile, fname);
			skip = TRUE;
		 }
		 break;

/*--------------------------------------------------------------------*/
/*             Requestor name (overrides user name, above)            */
/*--------------------------------------------------------------------*/

	  case 'R':
		 strtok(line," \t\n");      /* Trim off leading "R"       */
									/* Get the user name          */
		 if ( (cp = strtok(NULL," \t\n")) == NULL )
			printmsg(0,"process: no requestor on R line in file \"%s\"", fname );
		 else {
			 requestor = strdup( cp );
			 checkref(requestor);
		 }
		 break;

	  default :
		 break;

	  } /* switch */
   } /* while */

   if ( fxqt != NULL )
	  fclose(fxqt);

   if ((command == NULL) && !skip)
   {
	  printmsg(0,"process: no command supplied for X.* file %s", fname);
	  reject = TRUE;
   } else if (requestor == NULL) {
	  requestor = strdup(user);
	  checkref(requestor);
   }

/*--------------------------------------------------------------------*/
/*           We have the data for this command; process it            */
/*--------------------------------------------------------------------*/

   if ( ! (skip || reject ))
   {
	  if (input == NULL)
		 input = strdup("nul");

	  printmsg(2, "process: %s", command);

	  result = shell(TRUE, command, input, output, nil(char), remote);

	  if (result == 0) {
		  if (   strncmp(command, "rmail", 5) == 0
			  && (!command[5] || isspace(command[5]))
			 )
			 handled++;
		  unlink(fname);       /* Already a local file name            */

		  if (equaln(input,"D.",2)) {
			  importpath(hostfile, input, remote);
			  unlink(hostfile);
		  }
	  }

	  free(input);
	  if ( output != NULL )
	  {
		 if (result == 0) {
			 importpath(hostfile, output, remote);
			 unlink(hostfile);
		 }
		 free(output);
	  }
	  if (result != 0)
		goto skp;
   } /* if (!skip ) */
   else {
	char	name[MAXFILE];
	char	drv[MAXDRIVE];
	char	dir[MAXDIR];
	char	ext[MAXEXT];
skp:
	  printmsg(0,"process: job in file \"%s\" %s, \
\"%s\" return %d", fname, reject ? "rejected" : "skipped",
reject ? "process" : (command == NULL ? "????" : command), result );

	  *name = *ext = '\0';
	  fnsplit(fname, drv, dir, name, ext);
	  strcpy(line, name);
	  strcat(line, ext);
	  mkfilename(hostfile, badjobdir, line);
	  if (RENAME(fname, hostfile) != 0) {
		printmsg(1,"process: can't move \"%s\" to %s, job deleted",
					fname, badjobdir);
		unlink(fname);
	  }
	  else
		printmsg(1,"process: job \"%s\" moved to %s for later perusal",
					fname, badjobdir);
   }

   if (command != NULL)
		free(command);
}

/*--------------------------------------------------------------------*/
/*    s h e l l                                                       */
/*                                                                    */
/*    Simulate a Unix command                                         */
/*                                                                    */
/*    Only the 'rmail', 'rbmail', 'rcbmail' , 'rzbmail' and 'rnews'   */
/*    are currently  supported                                        */
/*--------------------------------------------------------------------*/
#ifdef	__TURBOC__
#pragma argsused
#endif
static int shell(boolean dopath, char *command,
				  char *inname,
				  char *outname,
				  char *errname,
				  const char *remotename)
{

   static char *argv[200];
   int argc;
   char *savcom;
   int result = 0;
   int (*proto)(int, char *[]);
   static char inlocal[FILENAME_MAX]; static char inf[FILENAME_MAX];
   static char outlocal[FILENAME_MAX]; static char outf[FILENAME_MAX];
   static char tmpf[FILENAME_MAX];
   int newout, savein, saveout, i;
   FILE *newin, *argin;

   savcom = strdup(command);
   checkref(savcom);
   argc = getargs(command, argv);
   argv[argc] = NULL;

   if (debuglevel >= 6) {
	  char **argvp = argv;

	  i = 0;
	  while (i < argc)
		 printmsg(6, "shell: argv[%d]=\"%s\"", i++, *argvp++);
   }

   if (   equal(argv[0], "rzbmail")
	   || equal(argv[0], "rcbmail")
	  ) {
	importpath(inf, inname, remotename);
	mkfilename(inlocal, spooldir, inf);

	return rzbmail(inlocal, remotename);
   }

   if (equal(argv[0], "rbmail")) {
	importpath(inf, inname, remotename);
	mkfilename(inlocal, spooldir, inf);

	return rbmail(inlocal, remotename);
   }

   if (equal(argv[0], "rmail"))
	  proto = rmail;
   else if (equal(argv[0], "rnews"))
	  proto = rnews;
   else
	  proto = notimp;

/*--------------------------------------------------------------------*/
/*               We support the command; execute it                   */
/*--------------------------------------------------------------------*/

   *tmpf = '\0';
   fflush(logfile);
   if (logfile != stdout)
	  real_flush(fileno(logfile));
   PushDir(homedir);

/*--------------------------------------------------------------------*/
/*                     Open files for processing                      */
/*--------------------------------------------------------------------*/

   if (inname != NULL && *inname) {
	  if(dopath) {
		importpath(inf, inname, remotename);
		mkfilename(inlocal, spooldir, inf);
	  } else
		strcpy(inlocal, inname);

	  if ((newin = FOPEN(inlocal, "r", BINARY)) == NULL) {
		 printerr("shell", inlocal);
		 printmsg(0, "shell: couldn't open %s (%s), errno=%d.",
			inname, inlocal, errno);
		 result = -1;
		 goto Pop;
	  }
	  fflush(stdin);
	  if ((savein = dup(fileno(stdin))) < 0) {
		 printerr("shell", "dup(0)");
		 fclose(newin);
		 result = -1;
		 goto Pop;
	  }
	  if (proto == rmail) {
		 (void) mktempname(tmpf, "ARG");
		 if ((argin = FOPEN(tmpf, "w+", BINARY)) == NULL) {
			 printerr("shell", tmpf);
			 fclose(newin);
			 result = -1;
			 goto Pop;
		 }
		 for (i = 0; i < argc; i++) {
			fputs(argv[i], argin);
			fputs("\r\n", argin);
			if (ferror(argin)) {
		wrterr:
				printerr("shell", tmpf);
				fclose(newin);
				fclose(argin);
				result = -1;
				goto Pop;
			}
		 }
		 fputs("<<NULL>>\r\n", argin);
		 while ((i = getc(newin)) != EOF)
			if (putc(i, argin) == EOF)
				goto wrterr;
		 (void) fflush(argin);
		 if (ferror(argin) || real_flush(fileno(argin)) < 0)
			goto wrterr;
		 fclose(newin);
		 rewind(argin);
		 newin = argin;
		 argc = 1;
		 argv[argc++] = savcom;	/* Fake argument, needed for recepients list */
		 argv[argc] = NULL;
	  }
	  if (dup2(fileno(newin), fileno(stdin)) < 0) {
		 printerr("shell", "dup2(fileno(newin), 0)");
		 fclose(newin);
		 result = -1;
		 goto Pop;
	  }
	  fclose(newin);
   }

   if (outname != NULL && *outname) {
	   if(dopath) {
		importpath(outf, outname, remotename);
		mkfilename(outlocal, spooldir, outf);
	   } else
		strcpy(outlocal, outname);

	  if ((newout = open(outlocal, O_WRONLY|O_BINARY)) < 0) {
		 printerr("shell", outlocal);
		 printmsg(0, "shell: couldn't open %s (%s), errno=%d.",
			outname, outlocal, errno);
errfound:
		 if (inname != NULL && *inname) {
			if (dup2(savein, fileno(stdin)) < 0) {
				 printerr("shell", "dup2(savein, 0)");
				 result = -1;
				 goto Pop;
			}
			close(savein);
			rewind(stdin);
			clearerr(stdin);
		 }
		 result = -1;
		 goto Pop;
	  }
	  fflush(stdout);
	  if ((saveout = dup(fileno(stdout))) < 0) {
		 printerr("shell", "dup(1)");
		 goto errfound;
	  }
	  if (dup2(newout, fileno(stdout)) < 0) {
		 printerr("shell", "dup2(newout, 1)");
		 goto errfound;
	  }
	  close(newout);
   }

	result = (*proto)(argc, argv);

	if (outname != NULL && *outname) {
		 if (dup2(saveout, fileno(stdout)) < 0) {
			 printerr("shell", "dup2(saveout, 1)");
			 result = -1;
		 }
		 else {
			 close(saveout);
			 clearerr(stdout);
		 }
	 }

	if (inname != NULL && *inname) {
		 if (dup2(savein, fileno(stdin)) < 0) {
			 printerr("shell", "dup2(savein, 0)");
			 result = -1;
			 goto Pop;
		 }
		 close(savein);
		 fflush(stdin); /* Empty input buffer contents... */
		 clearerr(stdin);
	 }

   if (result == -1)       /* Did spawn fail?                     */
	  printerr("shell", argv[0]);   /* Yes --> Report error                */

Pop:
	PopDir();

   free(savcom);
   if (*tmpf)
		unlink(tmpf);
/*--------------------------------------------------------------------*/
/*                     Report results of command                      */
/*--------------------------------------------------------------------*/

   printmsg(8,"Result of spawn is ... %d",result);
   fflush(logfile);

   return result;

} /*shell*/

/*--------------------------------------------------------------------*/
/*    u s a g e                                                       */
/*                                                                    */
/*    Report how to run this program                                  */
/*--------------------------------------------------------------------*/

static void usage( void )
{
   fprintf(stderr, "Usage: uuxqt [-x|X <debug_level>] [-S] [-s <system>|all]\n");
   fprintf(stderr, "Valid remote commands are: rmail, rbmail, rcbmail, rzbmail, rnews\n");
   exit(4);
}

int rmail(int argc, char* argv[]) {
	extern char *sendprog, *calldir;
	static char sendmail[FILENAME_MAX] = "";
	int i;
	char* args[50], *cp, *buf;
	static char ubuf[LINESIZE];
	unsigned segbuf;

	if ((buf = strpbrk(argv[argc - 1], " \t")) == NULL)
		buf = " *nobody*";

	cp = requestor != NULL ? requestor : user;
	i = strlen(machine);
	if (strncmp(machine, cp, i) == 0 && cp[i] == '!')
		strcpy(ubuf, cp);
	else
		sprintf(ubuf, "%s!%s", machine, cp);
	cp = ubuf;
	while ((cp = strchr(cp, '@')) != NULL)
		*cp++ = '%';

	Sftrans(SF_DELIVER, ubuf, buf);

	if (! *sendmail)
		if (sendprog == NULL)
			mkfilename(sendmail, calldir, "rmail.exe");
		else
			strcpy(sendmail, sendprog);
	i = 0;
	args[i++] = argv[0];
	/* args[i++] = "-i"; */
	args[i++] = "-u";	/* From UNIX, needs decoding */
	if (machine != NULL) {
		args[i++] = "-r";
		args[i++] = machine;
	}
	if (user != NULL || requestor != NULL) {
		args[i++] = "-f";
		args[i++] = requestor != NULL ? requestor : user;
	}
	if (screen)
		args[i++] = "-Z";	/* Use screen debug */
	args[i++] = "-l";	/* Use arglist */
	args[i] = NULL;
	printmsg(5, "rmail: (%s) %s executing...", args[0], sendmail);
	i = -1;
	if (   allocmem((unsigned)((SKBSIZE * 1024L) >> 4), &segbuf) != -1
		|| freemem(segbuf)
	   )
		goto NotStarted;
	if ((i = spawnvp (P_WAIT, sendmail, args)) < 0) {
		int nomem;
	NotStarted:
		nomem = (errno == ENOMEM);
		printmsg(0, "rmail: (%s) %s not started: %s", args[0], sendmail, sys_errlist[errno]);
		if (nomem)
			printmsg(0,
				"rmail: I need %dKb of free memory to run SENDMAIL",
				SKBSIZE);
	}
	else
		setcbrk(1);
	if (i == 48)	/* 48 -- MAGIC number */
		i = 0;
	return i;
}

/*
	  r n e w s

	  Receive incoming news into the news directory.

	  This procedure needs to be rewritten to perform real news
	  processing.  Next release(?)
*/
#ifdef	__TURBOC__
#pragma argsused
#endif
int rnews(int argc, char *argv[])
{

   static int count = 1;
   int c;
   static char filename[FILENAME_MAX], format[FILENAME_MAX];
   FILE *f;
   long now = time(nil(long));

/*--------------------------------------------------------------------*/
/*                        Get output file name                        */
/*--------------------------------------------------------------------*/

   mkfilename(format, newsdir, "%08.8lX.%03.3d");  /* make pattern first */

   do {
	  sprintf(filename, format, now, count++);  /* build real file name */
	  f = fopen(filename,"r");
	  if (f != NULL)             /* Does the file exist?             */
		 fclose(f);              /* Yes --> Close the stream         */
   } while (f != NULL);

   printmsg(6, "rnews: delivering incoming news into %s", filename);

   if ((f = FOPEN(filename, "w", BINARY)) == nil(FILE))
   {
	  printmsg(0, "rnews: cannot open %s", filename);
	  return 2;
   }

/*--------------------------------------------------------------------*/
/*                  Main loop to write the file out                   */
/*--------------------------------------------------------------------*/

   while ((c = getchar()) != EOF)
		putc(c, f);

/*--------------------------------------------------------------------*/
/*                     Close open files and exit                      */
/*--------------------------------------------------------------------*/

   fclose(f);

   return 0;

} /*rnews*/

/*
   notimp - "perform" Unix commands which aren't implemented
*/

static
int
notimp(argc, argv)
int argc;
char *argv[];
{
   int i = 1;

   printmsg(0, "notimp: command '%s' not implemented", *argv);
   while (i < argc)
	  printmsg(6, "notimp: argv[%d]=\"%s\"", i++, *argv++);

   return 1;

} /*notimp*/

/*
 * Write a log record
 */
static void rbm_log(char *f, char *a1, char *a2)
{
	int fd;
	char buf[200];
	static char logfile[FILENAME_MAX] = "";
	long now;
	struct tm *t;
	int l;

	sprintf(buf, "rbm_log: ");
	sprintf(buf + strlen(buf), f,a1,a2);
	printmsg(0, buf);
	if (!*logfile)
		mkfilename(logfile, spooldir, "rbmail.log");
	if( (fd = open(logfile, O_WRONLY|O_APPEND|O_CREAT|O_TEXT,0664)) < 0 )
		return;
	time(&now);
	t = localtime(&now);
	sprintf(buf, "%s\t%02d:%02d:%02d %d.%d.%02d\t", machine,
			 t->tm_hour, t->tm_min, t->tm_sec,
			 t->tm_mday, t->tm_mon + 1, t->tm_year % 100);
	sprintf(buf + strlen(buf), f,a1,a2);
	l = strlen(buf);
	if ( buf[l - 1 ] != '\n' ) buf[l++] = '\n';
	write(fd, buf, l);
	close(fd);
}

static void put_warning(FILE *file, char *str)
{
rbm_log(str, NULL, NULL);
fprintf(file,"\n******************************************************************\n");
fprintf(file,  "** ERROR DETECTED DURING BATCH-MAIL PROCESSING                  **\n");
fprintf(file,  "** WHILE RECEIVING BATCH FROM: %10s                       **\n",machine);
fprintf(file,  "** ERROR MESSAGE: %42.42s    **\n",str);
fprintf(file,  "******************************************************************\n");
}

/*
 * Read Batched Mail
 */
static int
rbmail(inname, rmtname)
char	*inname, *rmtname;
{
	extern void xf_koi8(char *);
	unsigned int rcsum, csum;
	char     *p, *err1, **ap;
	static   char     tmpfile[FILENAME_MAX], headerline[LINESIZE];
	static   char     diagheader[LINESIZE], errfile[FILENAME_MAX];
	static   char     curline[LINESIZE], err[256];
	char *rargs[100];
	FILE    *in, *temp = NULL, *temp0 = NULL, *diag = NULL;
	int      c, i;
	long	 len;
	char *op = NULL;
	int syncflg = 0;        /* Find new header */

	(void) mktempname(tmpfile, "RBM");

	if(!(in = FOPEN(inname, "r", BINARY))) {
		printmsg(0, "rbmail: can't open batch %s: %s", inname, strerror(errno));
		return 1;
	}

	while(fgets(headerline, (sizeof headerline)-1, in) != NULL) {
rescan:
		/*
		 * Parse header line
		 */
		rargs[0] = NULL;
		headerline[(sizeof headerline)-1] = '\0';
		(void) strcpy(diagheader, headerline);
		temp = NULL;
		p = strchr(headerline, '\n');
		if (p == NULL) {
			strcpy(err, "Bad header (missing NL)");
filesync:
			syncflg = 1;
			goto do_error;
copy_on_error:
			syncflg = 0;
do_error:
			if (diag == NULL) {
				char buf[20];
				long tt;

				(void) time(&tt);
				sprintf(buf, "%08lx.ERR", tt);
				mkfilename(errfile, badjobdir, buf);
				diag = FOPEN(errfile,"a",TEXT);
			}

			if( diag == NULL ) {
				err1 = strerror(errno);
				printmsg(0, "rbmail: can't create %s: %s", errfile, err1);
				rbm_log("error: can't create %s", errfile, err1);
			}
			else {
				rbm_log("error: %s rest in: %.64s",err,errfile);
				fprintf(diag,"*** from %s, %s\n", machine, err);
				fputs(diagheader, diag);
				if( temp != NULL ) {
					char s[2];

					s[1] = '\0';
					while( (c = getc(temp)) != EOF ) {
						s[0] = c;
						xf_koi8(s);
						putc(s[0], diag);
					}
				}
				headerline[0] = 0;
				op = NULL;
				while( fgets(curline, (sizeof curline)-1, in) != NULL )
				{
					if ( headerline[0] && syncflg && strncmp(curline,"From ",5) == 0 )
					{
						op = curline;
						rbm_log("Rescan from line: %.64s",headerline, NULL);
						goto rescan;
					}
					if ( headerline[0] ) {
						xf_koi8(headerline);
						fputs(headerline,diag);
					}
					strcpy(headerline,curline);
				}
				if ( headerline[0] ) {
					xf_koi8(headerline);
					fputs(headerline,diag);
				}
				fclose(diag);
			}
			fclose(in);
			if (temp0 != NULL)
				fclose(temp0);
			/*
			 * try to send corrupted batch to postmaster
			 */
			if ((diag = FOPEN(tmpfile, "w+", BINARY)) != NULL) {
				fprintf(diag, "From: UUPC/@ Daemon <MAILER-DAEMON@%s>\n", domain);
				fprintf(diag, "To: postmaster\n");
				fprintf(diag, "Subject: Batch Reassembling Error\n");
				fprintf(diag, "Date: %s\n\n", arpadate());
				fprintf(diag, "error: %s rest in: %.64s\n",err,errfile);
				fclose(diag);
				(void) shell(FALSE, "rmail postmaster",
					tmpfile, NULL, NULL, rmtname);
			}
			unlink(tmpfile);
			return 1;
		}
		*p =  '\0';

		/* Length */
		p = headerline;
		len = 0;
		for(i = 0; i < 7; i++) {
			c = *p++;
			if(c < '0' || c > '9') {
				strcpy(err, "Header corrupted (bad char in length)");
				goto filesync;
			}
			len = (len*10) + (c - '0');
		}
		if(*p++ != ' ') {
			strcpy(err, "Header corrupted (no space after length)");
			goto filesync;
		}

		/* Checksum */
		rcsum = 0;
		for(i = 0; i < 4; i++) {
			c = *p++;
			rcsum <<= 4;
			if('0' <= c && c <= '9')
				rcsum |= c - '0';
			else if('A' <= c && c <= 'F')
				rcsum |= c - 'A' + 0xa;
			else if('a' <= c && c <= 'f')
				rcsum |= c - 'a' + 0xa;
			else {
				strcpy(err, "Header corrupted (bad char in checksum)");
				goto filesync;
			}
		}
		if(*p++ != ' ') {
			strcpy(err, "Bad header (no space after checksum)");
			goto filesync;
		}

		/* Destination addressee */
		if( ! *p ) {
			strcpy(err, "Header corrupted (empty dest address)");
			goto filesync;
		}
		ap = &rargs[1];
		for(;;) {
			while( *p == ' ' || *p == '\t' ) p++;
			if( *p == '\0' )
				break;
			if( ap >= &rargs[99] ) {
				strcpy(err, "Header corrupted (too many addressee)");
				goto filesync;
			}
			*ap++ = p;
			for(;;) {
				if( *p == '"' ) {
					do {
						p++;
					} while( *p && *p != '"' );
					if( *p ) p++;
					continue;
				}
				if( *p == ' ' ) {
					*p++ = '\0';
					break;
				}
				if( *p == '\0' )
					break;
				p++;
			}
		}
		*ap = NULL;
		if( ap == &rargs[1] ) {
			strcpy(err, "Header corrupted (no dest address)");
			goto filesync;
		}

		/*
		 * Create temporary file
		 */
		if (temp0 != NULL) {
			rewind(temp0);
			if (chsize(fileno(temp0), 0l) < 0) {
				fclose(temp0);
				goto CreateIt;
			} else
				temp = temp0;
		} else
CreateIt:
			temp = temp0 = FOPEN(tmpfile, "w+", BINARY);

		if (temp == NULL ) {
			sprintf(err, "Can't create temp %s: %s",
						  tmpfile, strerror(errno));
			printmsg(0, "rbmail: %s", err);
			goto copy_on_error;
		}

		/*
		 * Copy into temp. file calculating checksum on the fly
		 */
		csum = 0;
		while(len-- > 0) {
			if ( op ) {
				c = (unsigned char) *op++;
				if ( !*op ) op = NULL;
			} else
				c = getc(in);
			if (c == EOF) {
				put_warning(temp,"EOF before end of package");
				break;
			}
			putc(c, temp);
			if(ferror(temp)) {
	err_wr:
				rewind(temp);
				sprintf(err, "Error writing temp %s: %s",
							  tmpfile, strerror(errno));
				printmsg(0, "rbmail: %s", err);
				goto copy_on_error;
			}
			if(csum & 01)
				csum = (csum>>1) + 0x8000;
			else
				csum >>= 1;
			csum += c;
			csum &= 0xffff;
		}
		if( csum != rcsum ) {
			char buf[64];
			sprintf(buf,"Checksum error: %04x != %04x",csum,rcsum);
			put_warning(temp,buf);
		}
		(void) fflush(temp);
		if (ferror(temp) || real_flush(fileno(temp)) < 0)
			goto err_wr;
		rewind(temp);
		/*
		 * Call rmail
		 */
		strcpy(curline, "rmail");
		for (ap = &rargs[1]; *ap; ap++) {
			strcat(curline, " ");
			strcat(curline, *ap);
		}
		i = shell(FALSE, curline, tmpfile, NULL, NULL, rmtname);
		if (i < 0) {
			sprintf(err, "Can't spawn rmail: %s", strerror(errno));
			printmsg(0, "rbmail: %s", err);
			goto copy_on_error;
		}
		else if (i > 0) {
			sprintf(err, "Rmail error code %d", i);
			printmsg(0, "rbmail: %s", err);
			goto copy_on_error;
		}
		handled++;
	}
	fclose(in);
	if (temp0 != NULL)
		fclose(temp0);
	(void) unlink(tmpfile);

	return 0;
}


/*
 * Read Zipped Batched Mail
 */
static int
rzbmail(inname, rmtname)
char	*inname, *rmtname;
{
	extern char *calldir;
	static char compress[FILENAME_MAX] = "";
	static char tmpfile[FILENAME_MAX];
	int i, newout, saveout;
	char *args[10];
	unsigned segbuf;

	if (! *compress)
		mkfilename(compress, calldir, "gzip.exe");

	i = 0;
	args[i++] = "gzip";
	args[i++] = "-dcq";
	args[i++] = inname;
	args[i] = NULL;

	(void) mktempname(tmpfile, "OUT");
	if ((newout = open(tmpfile, O_WRONLY|O_BINARY|O_CREAT, 0600)) < 0) {
		printerr("r[cz]bmail", tmpfile);
		return -1;
	}
	fflush(stdout);
	if ((saveout = dup(fileno(stdout))) < 0) {
		printerr("r[cz]bmail", "dup(1)");
		(void) unlink(tmpfile);
		return -1;
	}
	if (dup2(newout, fileno(stdout)) < 0) {
		printerr("r[cz]bmail", "dup2(newout, 1)");
		(void) unlink(tmpfile);
		return -1;
	}
	close(newout);

	printmsg(5, "r[cz]bmail: (%s -dcq) %s executing...", args[0], compress);
	i = -1;
	if (   allocmem((unsigned)((ZKBSIZE * 1024L) >> 4), &segbuf) != -1
		|| freemem(segbuf)
	   )
		goto NotStarted;
	setcbrk(0);
	i = spawnvp(P_WAIT, compress, args);
	setcbrk(1);
	if (i < 0) {
		int nomem;
	NotStarted:
		nomem = (errno == ENOMEM);
		printmsg(0, "r[cz]bmail: (%s -dcq) %s not started: %s", args[0], compress, sys_errlist[errno]);
		if (nomem)
			printmsg(0,
					"r[cz]bmail: I need %dKb of free memory to run gzip",
					ZKBSIZE);
	}
	if (dup2(saveout, fileno(stdout)) < 0) {
		printerr("r[cz]bmail", "dup2(saveout, 1)");
		(void) unlink(tmpfile);
		return -1;
	}
	close(saveout);
	rewind(stdout);
	clearerr(stdout);

	if (i != 0) {
		(void) unlink(tmpfile);
		if (i > 0) {
			printmsg(0, "r[cz]bmail: gzip error code %d", i);
			return i;
		}
		return 1;
	}

	i = rbmail(tmpfile, rmtname);
	(void) unlink(tmpfile);

	return i;
}
