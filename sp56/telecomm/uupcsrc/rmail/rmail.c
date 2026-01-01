/*
 * History:4,1
 * Mon May 15 19:56:44 1989 Add c_break handler                   ahd
 * 20 Sep 1989 Add check for SYSDEBUG in MS-DOS environment       ahd
 * 22 Sep 1989 Delete kermit and password environment
			   variables (now in password file).                  ahd

   IBM-PC host program
*/

# include	<stdio.h>
# include	<setjmp.h>
# include	<errno.h>
# ifdef MSDOS
# include	<malloc.h>
# else
# include	<alloc.h>
# endif
# ifdef MSDOS
# include	<direct.h>
# else
# include	<dir.h>
# endif
# include	<fcntl.h>
# include	<conio.h>
# ifdef MSDOS
# include	<signal.h>
# else
# include    <dos.h>
# endif
# include	<string.h>
# include	<stdlib.h>

# include	"lib.h"
# include	"hlib.h"
# include	"timestmp.h"
# include 	"arpadate.h"
# include	"pcmail.h"
# include	"pushpop.h"
# include   "getopt.h"

unsigned _stklen = 0x4000;

currentfile();

#define MAXARGS 500

static char *receipt = NULL;
char *GradeList = NULL;
boolean doreceipt = FALSE;

static struct Table table[] = {
	"RECEIPT",	&receipt,	TRUE,  TRUE, FALSE, NULL,
	"GRADES",	&GradeList, FALSE, TRUE, FALSE, NULL,
	nil(char)
}; /* table */

extern int lmail(int argc, char *argv[]);

char*	replyto;
extern	verbose;
extern boolean ignsigs;
extern boolean force_redirect;
int	c_break(void);
int null(void) { return 1; }
boolean 	filelist = FALSE;
int nargc = 0;
char *nargv[MAXARGS];

int main(int argc, char** argv) {
	FILE *fp;
	static char buf[MAXPATH];
	char **sargv = argv;

	force_redirect = TRUE;

	if (!parse_args(argc,argv))
		return 4;

	if (ignsigs) {
#ifdef	__MSDOS__
		setcbrk(0);
		ctrlbrk(null);
#else
		signal(SIGINT, SIG_IGN);
		signal(SIGBREAK, SIG_IGN);
#endif
	}
	else {
#ifdef	__MSDOS__
		setcbrk(1);
		ctrlbrk(c_break);
#endif
	}

	if (filelist) {
		static char buf[1024+2], *s;

		while (fgets(buf, sizeof(buf) - 1, stdin) != NULL) {
			buf[sizeof(buf) - 1] = '\0';
			if ((s = strchr(buf, '\n')) != NULL)
				*s = '\0';
			if (strcmp(buf, "<<NULL>>") == 0) {
				nargv[nargc] = NULL;
				argc = nargc;
				argv = nargv;
				init_getopt();
				if (!parse_args(argc, argv))
					return 4;
				goto Done;
			}
			else {
				if (nargc >= MAXARGS) {
					fprintf(stderr, "arg count > %d\n", MAXARGS);
					return 4;
				}
				nargv[nargc] = strdup(buf);
				checkref(nargv[nargc]);
				nargc++;
			}
		}
		fprintf(stderr, "End Of Arg list not found\n");
		return 4;
	}

Done:
	banner(sargv);

	if (!configure())
		return 4;		/* system configuration failed */

	mkfilename(buf, spooldir, "rmail.log");
	if (debuglevel > 0 && logecho &&
			(logfile = FOPEN(buf, "a", TEXT)) == nil(FILE)) {
		logfile = stdout;
		printerr("main", buf);
	}
	if (logfile != stdout)
		fprintf(logfile, "\n>>>> Log started %s\n", arpadate());
	if (filelist)
		printmsg(7, "main: arguments passes via stdin (-l switch)");
	else
		printmsg(7, "main: arguments passed via command line (128 limit)");

	mkfilename (buf, confdir, "sendmail.cf");
	if ((fp = FOPEN(buf, "r", TEXT)) == nil(FILE)) {
		printerr("main", buf);
		printmsg(0, "main: Cannot open sendmail configuration file `%s'", buf);
		return 1;
	}
	getconfig(fp, TRUE, table);
	fclose(fp);
	if (receipt == NULL || strchr("YyNn", *receipt) == NULL) {
		printmsg(0, "main: incorrect 'RECEIPT' settings in %s file", buf);
		return 1;
	}
	doreceipt = (strchr("Yy", *receipt) != NULL);
	if (GradeList != NULL && strlen(GradeList) != 4) {
		printmsg(0, "main: incorrect 'GRADES' settings in %s file", buf);
		return 1;
	}
	if (GradeList == NULL)
		GradeList = "LMNU";

	/* move to the spooling directory */
	PushDir(spooldir);
	atexit(PopDir);

	cleantmp();

	return lmail(argc, argv);
} /*main*/

/* c_break   -- control break handler to allow graceful shutdown   */
/* of interrupt handlers, etc.               */

int c_break(void) {
#ifdef	__MSDOS__
	setcbrk(0);
	ctrlbrk(null);
#else
	signal(SIGINT, SIG_IGN);
#endif
	printmsg(0, "c_break: program aborted by user Ctrl-Break");

	exit(100);              /* Allow program to abort */
	return 0;
}
