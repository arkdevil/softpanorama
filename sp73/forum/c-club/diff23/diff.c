/*----------------------------------------------------------------------------

	diff.c -- file compare and change bar inserter for text files
	originally produced by D Krantz, modified for Turbo C by P van Es
	date 4/19/88

        5/2/88  v1.1	options have been UNIX-fied
	5/4/88  v1.2	comparisons made faster
			bugs corrected
			upper case handling rationalised
	6/14/88 v2.0	automatic resync feature added
	6/18/88 v2.1	screen listing switchable
	6/20/88 v2.2	resync made faster for small changes
	6/21/88 v2.3	resync checksum lookup added

  ---------------------------------------------------------------------------*/

/* file difference utility */

#if defined (__COMPACT__)
#else
#error Must be compiled with COMPACT model
#endif

#include <ctype.h>
#include <stdio.h>

typedef unsigned char	byte;	/* define type byte, vals 0-255 */
#define OPT_FLAG  '-'		/* command line option switch recogniser */
#define MAXLINE   83		/* maximum characters in the input line */
#define FORMFEED  'L'-'@'
#define EOF_REACHED	0	/* eof during resync */
#define RE_SYNCED	1	/* we managed to re-sync */
#define NO_SYNC		2	/* no sync but no eof either */

struct LINE {			/* structure defining a line internally */
	int linenum;		/* what line on page */
	int pagenum;		/* what page */
	byte checksum;		/* use a checksum for quick comparison */
	struct LINE *prev;	/* pointer to previous line */
	struct LINE *link;	/* linked list pointer */
	struct LINE *same;	/* pointer to next line with checksum */
	char text [MAXLINE];	/* text of line */
};

typedef struct LINE *line_ptr;
typedef char *char_ptr;
typedef FILE *FILE_PTR;
struct LINE root[3];		/* root of internal linked list */
int line_count[3] = {1,1,1};	/* file's line counter */
int page_count[3] = {1,1,1};	/* file's page counter */
int command_errors = 0;		/* number of command line errors */
char xx1[132], xx2[132];	/* space for file names */
int files = 0;			/* nr of files in command line */
char_ptr infile_name[3] = {NULL,xx1,xx2};
char outfile_name[132];		/* output file name */
FILE_PTR infile[3];		/* input file pointers */
FILE *outfile;			/* changebarred output file ptr */

static line_ptr at[3] = {NULL, &(root[1]), &(root[2])};
static line_ptr same_check [256] [2];

int debug = 0;			/* trace switch */
int trace_enabled = 0;		/* keyboard tracing switch */
int bar_col = 78;		/* column for change bar */
int top_skip = 0;		/* lines to skip at top of page */
int bot_skip = 0;		/* lines to skip at bottom of page */
int page_len = 66;		/* length of a page */
int up_case = 0;		/* boolean - ignore case */
int re_sync = 3;		/* lines that must match for resync */
int output = 0;			/* boolean - is change barred outfile on */
int blanks = 0;			/* boolean - are blank lines significant */
int skip1 = 0;			/* pages in first file to skip */
int skip2 = 0;			/* pages in second file to skip */
int scr_on = 1;			/* screen listing turned on */

#if 0 /* tracing and other debug functions turned off */

#define trace( x )	callstack( x )
#define ret		{ callpop(); return; }
#define ret_val( x )	{ callpop(); return( x ); }
#define TRACER_FUNCTIONS

#else

#define trace( x )	/* nothing */
#define ret		{ return; }
#define ret_val( x )	{ return( x ); }

#endif

/*--------------------------------------------------------------------------*/
main (argc, argv)
	int argc;
	char *argv[];
{
	int i;
	trace ( "main" );
	if (argc == 1)
		help();
	else
		printf ("diff -- version 2.3 6/21/88\n");

	strip_opt (argc, argv);
	if (files<2) {
		printf ("\nError: Must specify two files");
		exit (2);
	}
	open_files();
	if (command_errors)
		exit (2);

	/* set root previous pointers to 0 */
	at[1]->prev = NULL;
	at[2]->prev = NULL;

	page_skip();
	diff();
	ret;
}

/* dont_look - tells us whether or not this line should be considered for
   comparison or is a filler (eg header, blank) line */

dont_look (line)
	line_ptr line;
{
	int i;
	trace ("dont_look");
	if (line == NULL)	/* EOF reached */
		ret_val(NULL);
	if (line->linenum <= top_skip)
		ret_val(1);
	if (line->linenum > page_len - bot_skip)
		ret_val(1);
	if (!blanks)
	{
		for (i=0; i<MAXLINE; i++)
			switch (line->text[i])
			{
				case '\0':
				case '\n': ret_val(1);
				case '\t':
				case ' ':  break;
				default:   ret_val(0);
			}
       	}
	ret_val(0);
}

/* equal - tells us if the pointers 'a' and 'b' point to line buffers
   containing equivalent text or not */

equal (a,b)
	line_ptr a,b;
{
	trace ("equal");
	if ((a==NULL) || (b==NULL))
		ret_val(0);
	if (a->checksum != b->checksum)
		ret_val(0);
	if (up_case)
		ret_val (!strcmp (a->text, b->text))
	else
		/* this function ignores case on comparison */
		ret_val (!stricmp (a->text, b->text))
}

/* position - moves the input pointer for file 'f' such that the next line to
   be read will be 'where' */

position (f,where)
	int f;
	line_ptr where;
{
	trace ("position");
	at[f] = &root[f];
	if (where == NULL)
		ret;
	while (at[f]->link != where)
		at[f] = at[f]->link;
	ret;
}


/* checksum - calculates a simple checksum for the line, and stores it in
   the line buffer.  This allows for faster comparisons */

checksum (a)
	line_ptr a;
{
	int i;
	a->checksum = 0;
	for (i=0; a->text[i] != NULL; i++) {
		if (up_case)
			a->checksum ^= a->text[i];
		else
			/* ignore case */
			a->checksum ^= toupper (a->text[i]);
	}
}


/* next_line - allocates, links and returns the next line from file 'f' if
   no lines are buffered, otherwise returns the next buffered line from 'f'
   and updates the link pointer to the next buffered line; it also inserts
   the line in the correct place in the array same_check */

line_ptr next_line (f)
	int f;
{
	char *malloc();
	line_ptr place_hold, start;

	trace ("next_line");
	if (at[f]->link != NULL) {
		at[f] = at[f]->link;
		ret_val (at[f]);
	}
	else {
		at[f]->link = (line_ptr) malloc (sizeof(struct LINE));
		if (at[f]->link == NULL) {
			printf ("\nError: Out of Memory");
			exit (2);
		}
		place_hold = at[f];
		at[f] = at[f]->link;
		if (place_hold == &(root[f]))
			at[f]->prev = NULL;
		else
			at[f]->prev = place_hold;
		at[f]->link = NULL;
		at[f]->same = NULL;
		if (fgets (at[f]->text, MAXLINE, infile[f]) == NULL) {
			free (at[f]);
			at[f] = place_hold;
			at[f]->link = NULL;
			at[f]->same = NULL;
			ret_val (NULL)
		}
		/* calculate a checksum for the new line of text */
		checksum (at[f]);

#ifdef EMBEDDED_FORMFEEDS
		if ((strchr (at[f]->text, FORMFEED) != NULL) ||
			(line_count[f] > page_len))
#else
		if ((*(at[f]->text) == FORMFEED) ||
			(line_count[f] > page_len))
#endif
		{
			page_count[f]++;
			line_count[f]=1;
		}
		at[f]->linenum = line_count[f]++;
		at[f]->pagenum = page_count[f];

		/* insert it in the correct place in the array unless it is
		   a dont_look line */
		if (!dont_look (at[f])) {
	 		start = same_check [at[f]->checksum][f-1];
			if (start == NULL)
				same_check [at[f]->checksum][f-1] = at[f];
			else {
				while (start->same != NULL)
					start = start->same;
				/* start is NULL now, insert at[f] here */
				start->same = at[f];
			}
		}

		ret_val (at[f]);
	}
}

/* discard - deallocates all buffered lines from the root up to and inclu-
   ding 'to' for file 'f', including from same_check */

discard (f,to)
	int f;
	line_ptr to;
{
	line_ptr temp;
	trace ("discard");
	for (;;) {
		if (root[f].link == NULL || to == NULL)
			break;

		temp = root[f].link;
		/* ok the line exists, now find the record in same_check */
		if (!dont_look (temp)) {
			/* replace with temp->same */
			same_check [temp->checksum][f-1] = temp->same;
		}

		root[f].link = root[f].link->link;
		root[f].link->prev = NULL;
		free (temp);
		if (temp == to)
			break;
	}
	at[f] = &root[f];
	ret;
}

/* put - if change barred output file is turned on, prints all lines from
   the root of file 1 up to and including 'line'.  This is only called if
   a match exists for each significant line in file 2 */

put (line)
	line_ptr line;
{
	line_ptr temp;
	trace ("put");
	if (output)
		for (temp = root[1].link; ;) {
			if (temp == NULL)
				ret
			fputs (temp->text, outfile);
			if (temp == line)
				ret
			temp = temp->link;
		}
	ret;
}

/* change_bar - inserts a change bar into the text pointed to by 'str'
   and returns a pointer to 'str' */

char *change_bar (str)
	char *str;
{
	int i;
	char temp [MAXLINE+1], *dest, *base;
	trace ("change_bar");
	base = str;
	dest = temp;
	i = 0;
	if (bar_col != 0) {
		for (i=0; *str != '\n'; i++) {
			if ((*str == '\r') && (*(str+1) != '\n'))
				i = 0;
			*(dest++) = *(str++);
		}
		while (i++ < bar_col)
			*(str)++ = ' ';
		strcpy (str, "|\n");
	}
	else {
		if (str[0] != ' ') {
			strcpy (temp,str);
			strcpy (str+1,temp);
		}
		str[0] = '|';
	}
	ret_val (base);
}

/* added - prints a change summary for all significant lines from the root
   of file 1 up to and including 'line'.  If output is enabled, adds a
   change bar to the text and outputs the line to the output file */

added (line)
	line_ptr line;
{
	line_ptr temp;
	trace ("added");
	for (temp = root[1].link; ;) {
		if (temp == NULL)
			ret
		if (!dont_look (temp) && scr_on)
			printf ("%.3d:%.2d< %s", temp->pagenum,
				temp->linenum, temp->text);
		if (output)
			if (dont_look (temp))
				fputs (temp->text, outfile);
			else
				fputs (change_bar (temp->text), outfile);
		if (temp == line)
			ret
		temp = temp->link;
	}
}

/* deleted - outputs a change summary for all lines i file 2 from the root
   up to and including 'line' */

deleted (line)
	line_ptr line;
{
	line_ptr temp;
	trace ("deleted");
	for (temp = root[2].link; ;) {
		if (temp == NULL)
			ret
		if (!dont_look (temp) && scr_on)
			printf ("%.3d:%.2d> %s", temp->pagenum,
				temp->linenum, temp->text);
		if (temp == line)
			ret
		temp = temp->link;
	}
}

/* resync - resynchronizes file 1 and file 2 after a difference is detected
   and outputs changed lines and change summaries via added() and deleted().
   Exits with the file inputs pointing at the next two lines that match,
   unless it is impossible to sync up again, in which case all lines in file 1
   are printed via added().  Deallocates lines printed by this function. */

resync (first, second,lookahead)
	line_ptr first, second;
	int lookahead;
{
	line_ptr file1_start, file2_start, last_bad1, last_bad2, t1, t2,
		check;
	int i, j, k, moved1, moved2;
	trace ("resync");

	/* first ensure sufficient lines in memory */
	position (2, second);
        last_bad2 = second;
	for (k=0; k<lookahead && last_bad2 != NULL ; k++)
		last_bad2 = next_line(2);

	/* now reset file pointers */
	moved1 = 0;
	file1_start = first;
	position (1,first);

	for (k=0; k < lookahead; k++) {
		while (dont_look (file1_start = next_line(1)));
		if (file1_start == NULL) goto no_sy;
		moved2 = 0;

		/* now see if there is a matching line at all */
		check = same_check [file1_start->checksum][1];
		while (check != NULL) {
			/* look for matching entries */
			while (!equal (check, file1_start)) {
				check = check->same;
				if (check == NULL)
					break;
			}

			if (check != NULL) {
				/* ok we have a hit */
				t1 = file1_start;
				file2_start = check;
				t2 = file2_start;
				position (1, file1_start);
				position (2, file2_start);
				for (i=0; (i<re_sync) && equal (t1,t2); i++) {
					while (dont_look (t1 = next_line (1)));
					while (dont_look (t2 = next_line (2)));
					if ((t1 == NULL) || (t2 == NULL))
						break;
				}
				if (i == re_sync) {
					moved2++;
					if ((last_bad2 = file2_start->prev) == NULL)
						moved2 = 0;
					goto synced;
				}
				/* get next entry */
				check = check->same;
			} /* if check != NULL */
		} /* end of while check != NULL */

		/* else no sync, no matching entries yet, loop the for list */
		last_bad1 = file1_start;
		position (1, file1_start);
		while (dont_look (file1_start = next_line (1)));
		moved1++;

	} /* for each line in file 1 lookahead */
        ret_val (NO_SYNC);

no_sy:
	position (1,first);
	while ((first = next_line(1)) != NULL) {
		added (first);
		discard (1, first);
	}
	ret_val (EOF_REACHED);

synced:
	if (moved1) {
		added (last_bad1);
		discard (1, last_bad1);
	}
	position (1, file1_start);
	if (moved2) {
		deleted (last_bad2);
		discard (2, last_bad2);
	}
	position (2, file2_start);
	if (scr_on)
		printf ("\n");
	ret_val (RE_SYNCED);
}

/* diff - differencing executive.  Prints and deallocates all lines up to
   where a difference is detected, at which point resync() is called.  Exits
   on end of file 1 */

diff()
{
	int look_lines, result;
	line_ptr first, second;

	trace ("diff");
	for (;;) {
		while (dont_look (first = next_line (1)));
		if (first == NULL) {
			put (first);
			ret;
		}
		while (dont_look (second = next_line (2)));
		if (equal (first, second)) {
			put (first);
			discard (1,first);
			discard (2,second);
		}
		else {
			look_lines = 10;   /* start with 10 lines look-ahead */
			result = NO_SYNC;
                        while (result == NO_SYNC) {
				result = resync (first, second, look_lines);
				look_lines *= 2;
				/* when look_lines reaches 80, assume a large
				   difference and set it to 400 */
				if (look_lines == 80)
					look_lines = 400;
			}
		}

		if (second == NULL)
			ret
	}
}

/* page_skip - skips the first 'skip1' pages of file 1, and then the first
   'skip2' pages of file 2.  This is useful to jump over tables of contents */

page_skip()
{
	line_ptr first, second;
	trace ("page_skip");
	for (;;) {
		first = next_line (1);
		if ((first == NULL) || (first->pagenum > skip1))
			break;
		put (first);
		discard (1, first);
	}
	if (first != NULL)
		position (1, first);
	for (;;) {
		second = next_line (2);
		if ((second == NULL) || (second->pagenum > skip2))
			break;
		discard (2,second);
	}
	if (second != NULL)
		position (2,second);
	ret;
}

/* help - outputs usage information */
help()
{
	printf ("\ndiff - text file differencer and change barrer"
		"\nusage: diff [option{option}] newfile oldfile [barfile]"
		"\n"
		"\noptions:");
#ifdef TRACER_FUNCTIONS
	printf ("\n   -t   trace operation, default off");
#endif
	printf ("\n   -b n column of barfile for change bar, default 78"
		"\n   -h n lines at top of page to skip for headers, default 0"
		"\n   -f n lines at bottom of page to skip for footers, default = 0"
		"\n   -p n lines per page (embedded form feeds override) default = 66"
		"\n   -c   uppercase/lowercase is significant (default is off)"
		"\n   -r n lines that must match before files are considered synced"
		"\n        after differences are found. default = 3"
		"\n   -w   blank lines are considered significant (default is not)"
		"\n   -s   screen listing off (default is on)"
		"\n   -n n pages in NEWFILE to skip before compare.  Also sets -o. default = 0"
		"\n   -o n pages in OLDFILE to skip before compare.  Must come after -n."
		"\n        default = 0");
	exit (0);
}

/* open_files - opens the input and the output files */
open_files()
{
	int i;
	trace ("open_files");
	for (i=1; i<3; i++)
		if ((infile[i] = fopen (infile_name[i], "r")) == NULL) {
			printf ("\nError: can't open %s", infile_name[i]);
			command_errors++;
		}
	if (files>2)
		if ((outfile = fopen (outfile_name, "w")) == NULL) {
			printf ("\nError: can't create %s", outfile_name);
			command_errors++;
		}
	ret;
}


/* strip_opt - processes each command line option */
strip_opt (ac,av)
	int ac;
	char *av[];
{
	int i;
	trace ("strip_opt");
	for (i=1; i<ac; i++) {
		if (av[i][0] == OPT_FLAG) {
			switch (av[i][1]) {
				case 'b': bar_col = atoi (av[++i]);
					  break;
				case 'h': top_skip = atoi (av[++i]);
					  break;
				case 'f': bot_skip = atoi (av[++i]);
					  break;
				case 'p': page_len = atoi (av[++i]);
					  break;
				case 'c': up_case = 1;
					  break;
				case 'r': re_sync = atoi (av[++i]);
					  break;
				case 'w': blanks = 1;
					  break;
				case 's': scr_on = 0;
					  break;
				case 'n': skip1 = skip2 = atoi (av[++i]);
					  break;
				case 'o': skip2 = atoi (av[++i]);
					  break;
#ifdef TRACER_FUNCTIONS
				case 't': trace_enabled = debug = 1;
					  break;
#endif
				default:  printf ("\nUnrecognised option %s",av[i]);
					  command_errors++;
			} /* switch av[i][1] */
		}
		else {
			switch (files) {
				case 0:	strcpy (infile_name[1], av[i]);
					break;
				case 1: strcpy (infile_name[2], av[i]);
					break;
				case 2: strcpy (outfile_name, av[i]);
					output = 1;
					break;
				default:
					printf ("\nError: too many files at %s",av[i]);
					command_errors++;
			}
			files++;
		}
	} /* for each command line argument */
	if (!scr_on && !output) {
		printf ("\nError: no output file or screen listing will be generated.");
		command_errors++;
	}
	ret;
}

#ifdef TRACER_FUNCTIONS

char_ptr names[20];
int stack = 0;

callstack (str)
	char *str;
{
	int i;
	char c;

	names[stack++] = str;
	if (debug) {
		for (i=0; i<stack; i++)
			printf ("   ");
		printf ("Entering %s\n",str);
	}
	if (trace_enabled && kbhit()) {
		switch (getch()) {
			case 't':
			case 'T': debug = !debug;
				  break;
			case 's':
			case 'S': printf ("\n------------");
				  for (i = stack-1; i>=0; i--)
					printf ("\n%s", names[i]);
				  printf ("\n------------\n");
				  printf ("free: %lu\n", coreleft());
				  break;
			default:  break;
		}
	}
}

callpop()
{
	int i;
	if (debug) {
		for (i=0; i<stack; i++)
			printf ("   ");
		printf ("Exiting %s\n", names[stack-1]);
	}
	stack--;
}

printentry (lp, title)
	line_ptr lp;
	char *title;
{
        if (debug) {
		if (lp == NULL)
			printf ("at %s: NULL entry\n");
		else
			printf ("at %s:  p %.3d:%.2d check %.3d\n",title,lp->pagenum,
				lp->linenum, lp->checksum);
			printf ("%s",lp->text);
			if (lp->link != NULL)
				printf ("next line : %s",lp->link->text);
			if (lp->same != NULL)
				printf ("same line : %s",lp->same->text);
			if (lp->prev != NULL)
				printf ("prev line : %s",lp->prev->text);
			printf ("\n");
	}
}

#endif




