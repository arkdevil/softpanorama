#include <string.h>

/*LINTLIBRARY*/
#ifndef NULL
#define NULL	0
#endif
#ifndef EOF
#define EOF	(-1)
#endif
#define ERR(s, c)	if(opterr){\
	char errbuf[3];\
	errbuf[0] = c; errbuf[1] = '\r'; errbuf[2] = '\n';\
	(void) write(2, argv[0], (unsigned)strlen(argv[0]));\
	(void) write(2, s, (unsigned)strlen(s));\
	(void) write(2, errbuf, 3);}

extern int strcmp();
extern char *strchr();

int	opterr = 1;
int	Optind = 1;
int	optopt;
char	*optarg;


int
getopt(int argc, char **argv, char *opts)
{
	static int sp = 1;
	register int c;
	register char *cp;

	if(sp == 1)
		if(Optind >= argc ||
		   argv[Optind][0] != '-' || argv[Optind][1] == '\0')
			return(EOF);
		else if(strcmp(argv[Optind], "--") == NULL) {
			Optind++;
			return(EOF);
		}
	optopt = c = argv[Optind][sp];
	if(c == ':' || (cp=strchr(opts, c)) == NULL) {
		ERR(": illegal option -- ", c);
		if(argv[Optind][++sp] == '\0') {
			Optind++;
			sp = 1;
		}
		return('\0');
	}
	if(*++cp == ':') {
		if(argv[Optind][sp+1] != '\0')
			optarg = &argv[Optind++][sp+1];
		else if(++Optind >= argc) {
			ERR(": option requires an argument -- ", c);
			sp = 1;
			return('\0');
		} else
			optarg = argv[Optind++];
		sp = 1;
	} else {
		if(argv[Optind][++sp] == '\0') {
			sp = 1;
			Optind++;
		}
		optarg = NULL;
	}
	return(c);
}

