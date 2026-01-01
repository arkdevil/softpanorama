#include <stdio.h>
#include <bios.h>
#include <ctype.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>

//#define EPSON1050

#define MAX_FORMAT  156
#define WRAP_SYMBOL 0xB0
#define CR '\n'
#define LF '\r'
#define FF '\f'
#define TAB '\t'
typedef unsigned char byte;

int set_options (char **argv);
int check_options (void);
int set_printer_options (char *options);
void wait_user (void);
void check_kbd (void);

char *FileName    = NULL;
int Page          = 1;
int MaxStrings    = 56;
int MaxColumns    = 80;
int LeftMargin    = 0;
int ExpandTabs   = 8;
byte PrintElite     = 0;
byte PrintCondensed = 0;
int  PrintLineFeed  = 36;
char Format [MAX_FORMAT+1];
byte BreakPage    = 0;
char *tmp_pointer = NULL;
char Date [15];
char PrinterSetup [20] = {
	27, '8', 27, 'C',
};
FILE *In;
byte First = 1;

void main (int argc, char **argv) {
	byte done;
	char *buff, *ibuff;
	int c;
	int i;
	
	printf ("Simple printing system v2.0  by Wadim (266-31-03)\n");
	if (argc == 1 || set_options (argv)) {
		printf ("\nUsage:     P1 [options] FileName"
				"options are:  -F\"format_string\"\n"
				"              -Pnn   - initial Page number (default is 1)\n"
				"              -Tnn   - expand Tabs to nn spaces (default is 8)\n"
				"              -Nnn   - Number of strings per page (default is 56)\n"
				"              -Mnn   - Left Margin (default is 0)\n"
				"              -Cnn   - number of Columns (default is 80)\n"
				"              -B     - Break page on FormFeed (default is NO)\n"
				"              -S[EC^E^CLnn]   - printer Setup\n"
				"Control sequences in format_string are :\n"
				"     $N   FileName\n"
				"     $nnX repetition of character X nn times\n"
				"     $D   Current Date\n"
				"     $P   Page number\n"
				"Options in printer Setup are :\n"
				"     E   Elite ON (default),         ^E   Elite OFF,\n"
				"     C   Condensed ON (default),     ^C   Condensed OFF,\n"
				"     Lnn     Set nn/216 inches LineFeed (default is 36)\n");
		return;
	}
	if (check_options ())
		return;
	if ((In=fopen (FileName, "r")) == NULL) {
		printf ("\nCan't open %s\n", FileName);
		return;
	}
	if ((ibuff=malloc (LeftMargin+MaxColumns+2)) == NULL) {
		puts ("\nNot Enough Memory");
		return;
	}
	memset (ibuff, ' ', LeftMargin);
	buff = ibuff + LeftMargin;
	done = 0;
	do {
		if (First) {
			printf ("\nInsert paper and press any key\r");
			bioskey (0);
			printf ("Press ESC to interrupt        \n");
			First = 0;
		} else {
			wait_user ();
		}
		fwrite (PrinterSetup, strlen (PrinterSetup), 1, stdprn);
		printf ("Page  %d\r", Page);
		if (Format [0]) {
			sprintf (buff, Format, Page, Page);
			fputs (ibuff, stdprn);
			i = 2;
			fputc (CR, stdprn);
			fputc (CR, stdprn);
		} else i = 0;
		for (; i<MaxStrings && (c=fgetc (In)) != EOF; ++i) {
			byte done = 0;
			byte j = 0;
			done = 0;
			ungetc (c, In);
			memset (buff, ' ', MaxColumns);
			do {
				switch (c=fgetc (In)) {
				case FF:
					if (BreakPage) {
						i = MaxColumns;
						buff [j] = 0;
						done = 1;
					}
					break;
				case TAB:
					if (ExpandTabs == 0) break;
					j = j%ExpandTabs==0 ? j+ExpandTabs :
						j + ExpandTabs - j%ExpandTabs;
					if (j >= MaxColumns) {
						buff [MaxColumns] = WRAP_SYMBOL;
						buff [MaxColumns+1] = 0;
						done = 1;
					}
					break;
				case EOF:
					done = 1;
					buff [j] = 0;
					i = MaxColumns;
					break;
				case CR:
				case LF:
				case 0:
					done = 1;
					buff [j] = 0;
					break;
				default:
					if ((c<15 && c>6) || (c<21 && c>17) || c==24 || c==27 || c==127)
						c = ' ';
					buff [j] = c;
					if (++j >= MaxColumns) {
						buff [MaxColumns] = WRAP_SYMBOL;
						buff [MaxColumns+1] = 0;
						done = 1;
					}
					break;
				}
			} while (!done);
			fputs (ibuff, stdprn);
			fputc (CR, stdprn);
			check_kbd ();
		}
		fputc (FF, stdprn);
		Page++;
	} while (!done);
	putchar ('\7');
}

int set_options (char **argv) {
	int z;
	register char *options;

	for (options = *(argv += 1); options; options=*++argv) {
		if (*options == '/' || *options == '-') {
			switch (*++options) {
			case 'f': case 'F':
				tmp_pointer = *++argv;
				break;
			case 'p': case 'P':
				z=sscanf (++options,"%d",&Page);
				if (z<1 || z==EOF) return 1;
				break;
			case 't': case 'T':
				sscanf (++options, "%d", &ExpandTabs);
				break;
			case 'N': case 'n':
				z=sscanf (++options,"%d",&MaxStrings);
				if (z<1 || z==EOF) return 1;
				break;
			case 'm': case 'M':
				z=sscanf (++options, "%d", &LeftMargin);
				if (z<1 || z==EOF) return 1;
				break;
			case 'c': case 'C':
				z=sscanf (++options, "%d", &MaxColumns);
				if (z<1 || z==EOF) return 1;
				break;
			case 'b': case 'B':
				BreakPage = 1;
				break;
			case 's': case 'S':
				z=set_printer_options (++options);
				if (z) return 1;
				break;
			default:
				return 1;
			}
		} else {
			FileName = options;
		}
	}
	return 0;
}

int check_options (void) {
	struct date d;
	char *b;
	int length;
	int z;
	if (FileName == NULL) {
		printf ("\nFileName absent\n");
		return 1;
	}
	strupr (FileName);
	if (PrintLineFeed > 255)
		PrintLineFeed = 255;
	if (PrintLineFeed < 5)
		PrintLineFeed = 5;
	if (MaxStrings > 255)
		MaxStrings = 255;
	if (MaxStrings < 5)
		MaxStrings = 5;
	if (tmp_pointer) {
		for (b=Format, length=0; *tmp_pointer; tmp_pointer++) {
			if (*tmp_pointer=='$') {
				switch (*++tmp_pointer) {
				case 'n': case 'N': //-----FileName
					length += strlen (FileName);
					if (length > MaxColumns) {
TL:						printf ("\nFormat String too Long\n");
						return 1;
					}
					b = stpcpy (b, FileName);
					break;
				case 'd': case 'D': //-----Date
					getdate (&d);
					sprintf (Date, "%d.%d.%d", d.da_day, d.da_mon, d.da_year);
					length += strlen (Date);
					if (length > MaxColumns)
						goto TL;
					b = stpcpy (b, Date);
					break;
				case 'p': case 'P': //-----Page Number
					*b++ = '%';
					*b++ = 'd';
					length += 5;
					break;
				case '1': case '2': case '3': case '4': case '5':
				case '6': case '7': case '8': case '9':
					z = atoi (tmp_pointer);
					while (isdigit (*tmp_pointer)) tmp_pointer++;
					if (*tmp_pointer == 0) goto IF;
					length += z;
					if (length > MaxColumns)
						goto TL;
					memset (b, *tmp_pointer, z);
					b += z;
					break;
				default:
IF:					printf ("\nIncorrect Format String\n");
					return 1;
				}
			} else {
				if (length > MaxColumns)
					goto TL;
				*b++ = *tmp_pointer;
				length++;
			}
		}
	}
	*b = 0;
	strcat (PrinterSetup, &MaxStrings);
	strcat (PrinterSetup, "3");
	strcat (PrinterSetup, &PrintLineFeed);
	strcat (PrinterSetup, PrintElite ? "M" : "P");
	strcat (PrinterSetup, PrintCondensed ? "" : "");
	return 0;
}

int set_printer_options (char *options) {
	byte done = 0;
	byte not  = 0;

	do {
		switch (*options) {
		case 0:
			done = 1;
			break;
		case 'E': case 'e':
			if (not) PrintElite = 0;
			else PrintElite = 1;
			not = 0;
			break;
		case 'C': case 'c':
			if (not) PrintCondensed = 0;
			else PrintCondensed = 1;
			not = 0;
			break;
		case '^':
			not = 1;
			break;
		case 'L': case 'l':
			options++;
			sscanf (options, "%d", &PrintLineFeed);
			if (PrintLineFeed==0) PrintLineFeed = 27;
			while (isdigit (*options)) options++;
			options--;
			break;
		default:
			return 1;
		}
		options++;
	} while (!done);
	return 0;
}

void wait_user (void) {
#define  DTO (biosprint(2,0,0)&0x01)	/* dev.time out*/
#define  IOE (biosprint(2,0,0)&0x08)	/*io error*/
#define  SEL (biosprint(2,0,0)&0x10)	/*selected*/
#define  OOP (biosprint(2,0,0)&0x20)	/*out of pap.*/
#define  ACK (biosprint(2,0,0)&0x40)	/*acknowlege*/
#define  NOB (biosprint(2,0,0)&0x80)	/*not busy*/

#ifndef EPSON1050
	while (SEL) check_kbd ();
	while (!SEL);
#else
	while (NOB) check_kbd ();
	while (IOE);
#endif
}

void check_kbd (void) {
	byte i;
	if (bioskey (1)) {
		while (bioskey (1)) i = (byte) bioskey (0);
		if (i == 27) {
			printf ("\nPrint interrupted. Continue, "
				"Reset printer and quit, Quit ?  [CRQ]\n");
			switch (i=(byte) bioskey (0)) {
			case 'r': case 'R':
				biosprint (1,0,0);
				exit (0);
			case 'q': case 'Q':
				exit (0);
			default:
				break;
			}
		}
	}
}