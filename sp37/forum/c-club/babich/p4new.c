//-----This file was compiled by Turbo C++
#include <alloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <conio.h>
#include <dos.h>
#include <bios.h>

//#define EPSON1050     /*-----Set this line, if You have Epson-1050-----*/
#define MAX_FORMAT 128
#define WRAP_SYMBOL 0xB0
#define CR '\n'
#define LF '\r'
#define FF '\f'
#define TAB '\t'

typedef unsigned char byte;

void main (int argc, char **argv);
int set_options (char **argv);
int check_options (void);
int set_printer_options (char *options);
int memory_allocation (void);
void print_buffers (void);
byte fill_buffers (void);
void reset_buffers (void);
byte fill_b (char **pb, int offset, int pageoff);
void wait_user (void);
void check_kbd (void);

char *FileName    = NULL;
int Page          = 1;
byte Quoter       = 1;
int Size;
int MaxStrings    = 39;
int MaxColumns    = 76;
int LeftMargin    = 0;
int CenterMargin  = 26;
int ExpandTabs    = 8;
int  PrintLineFeed  = 36;
byte PrintElite     = 0;
byte PrintCondensed = 1;
char Format [MAX_FORMAT+1];
byte BreakPage    = 0;
char *tmp_pointer = NULL;
char Date [15];
char *Buff41;
char *Buff23;
char **Pb41;
char **Pb23;
char PrinterSetup [20] = {
	27, '8', 27, 'C',
};
FILE *In;
byte First = 1;
extern unsigned _stklen = 500;
void main (int argc, char **argv) {
	byte done = 1;

	printf ("Four-column printing system v2.0   (Wadim 266-31-03)\n");
	if (argc == 1 || set_options (argv)) {
		printf ("\nUsage:    P4 [options] FILENAME\n"
				"options are:  -F\"format_string\"\n"
				"              -Pnn   - initial Page number (default is 1)\n"
				"              -Qn    - initial Quoter (default is 1)\n"
				"              -Tnn   - expand Tabs to nn spaces (default is 8)\n"
				"              -Nnn   - Number of strings per page (default is 39)\n"
				"              -MLnn  - Left Margin (default is 0)\n"
				"              -MCnn  - Center Margin (default is 26)\n"
				"              -Cnn   - number of Columns (default is 76)\n"
				"              -B     - Break page on FormFeed (default is NO)\n"
				"              -S[EC^E^CLnn]   - printer Setup\n"
				"Control sequences in format_string are :\n"
				"     $N   FileName\n"
				"     $nnX repetition of character X nn times\n"
				"     $D   Current Date\n"
				"     $P   Page number\n"
				"Options in printer Setup are :\n"
				"     E   Elite ON,                   ^E   Elite OFF (default),\n"
				"     C   Condensed ON (default),     ^C   Condensed OFF,\n"
				"     Lnn     Set nn/216 inches LineFeed (default is 36)\n");
		return;
	}
	if (check_options ())
		return;
	if ((In=fopen (FileName, "rt")) == NULL) {
		printf ("Can't open %s\n", FileName);
		return;
	}
	if (memory_allocation ()) {
		printf ("Not Enough Memory\n");
		return;
	}
	do {
		done = fill_buffers ();
		print_buffers ();
		Page += 4;
	} while (done);
	fclose (In);
	putch ('\7');
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
			case 'q': case 'Q':
				z=sscanf (++options,"%d",&Quoter);
				if (z<1 || z==EOF) return 1;
				if (Quoter>4 || Quoter<1) return 1;
				break;
			case 't': case 'T':
				sscanf (++options, "%d", &ExpandTabs);
				break;
			case 'N': case 'n':
				z=sscanf (++options,"%d",&MaxStrings);
				if (z<1 || z==EOF) return 1;
				break;
			case 'm': case 'M':
				switch (*++options) {
				case 'l': case 'L':
					z=sscanf (++options, "%d", &LeftMargin);
					if (z<1 || z==EOF) return 1;
					break;
				case 'c': case 'C':
					z=sscanf (++options, "%d", &CenterMargin);
					if (z<1 || z==EOF) return 1;
					break;
				default:
					return 1;
				}
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
		puts ("\nFileName absent\n");
		return 1;
	}
	strupr (FileName);
	if (MaxStrings > 255)
		MaxStrings = 255;
	if (MaxStrings < 5)
		MaxStrings = 5;
	if (PrintLineFeed > 255)
		PrintLineFeed = 255;
	if (PrintLineFeed < 5)
		PrintLineFeed = 5;
	if (tmp_pointer) {
		for (b=Format, length=0; *tmp_pointer; tmp_pointer++) {
			if (*tmp_pointer=='$') {
				switch (*++tmp_pointer) {
				case 'n': case 'N': //-----FileName
					length += strlen (FileName);
					if (length > MaxColumns) {
TL:						printf ("\n<<<ERROR>>>   Format String too Long\n");
						return 1;
					}
					b = stpcpy (b, FileName);
					break;
				case 'd': case 'D': //-----Date
					getdate (&d);
					sprintf (Date, "%d.%d.%d", d.da_day, d.da_mon, d.da_year);
					length += strlen (Date);
					if (length > MaxColumns) goto TL;
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
					if (length > MaxColumns) goto TL;
					memset (b, *tmp_pointer, z);
					b += z;
					break;
				default:
IF:					printf ("\n<<<ERROR>>>  Incorrect Format String\n");
					return 1;
				}
			} else {
				if (length > MaxColumns) goto TL;
				*b++ = *tmp_pointer;
				length++;
			}
		}
	}
	*b = 0;
	if (length > MaxColumns) goto TL;
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

int memory_allocation (void) {
	int i;

	Size = LeftMargin + MaxColumns*2 + CenterMargin + 3;
	if ((Buff41 = (char *) calloc (MaxStrings, Size))==NULL)
		return 1;
	if ((Buff23 = (char *) calloc (MaxStrings, Size))==NULL)
		return 1;
	if ((Pb41  = (char **)calloc (MaxStrings, sizeof (char *)))==NULL)
		return 1;
	if ((Pb23  = (char **)calloc (MaxStrings, sizeof (char *)))==NULL)
		return 1;
	for (i=0; i<MaxStrings; ++i) {
		Pb41 [i] = Buff41 + i*Size;
		Pb23 [i] = Buff23 + i*Size;
	}
	return 0;
}

byte fill_buffers (void) {
	byte result;
	int c;

	reset_buffers ();
	switch (Quoter) {
	case 1:
		result = fill_b (Pb41, LeftMargin+MaxColumns+CenterMargin, 0);
		if (result == 0) break;
	case 2:
		result = fill_b (Pb23, LeftMargin, 1);
		if (result == 0) break;
	case 3:
		result = fill_b (Pb23, LeftMargin+MaxColumns+CenterMargin, 2);
		if (result == 0) break;
	case 4:
		result = fill_b (Pb41, LeftMargin, 3);
		break;
	}
	if ((c=fgetc (In)) == EOF) return 0;
	ungetc (c, In);
	Quoter = 1;
	return result;
}

void reset_buffers (void) {
	int i;
	for (i=0; i<MaxStrings; ++i) {
		memset (Pb41 [i], ' ', Size-1);
		memset (Pb23 [i], ' ', Size-1);
		*(Pb41 [i] + Size) = 0;
		*(Pb23 [i] + Size) = 0;
	}
	**Pb41 = 0;
	**Pb23 = 0;
}

byte fill_b (char **pb, int offset, int pageoff) {
	int c;
	byte done;
	int j;
	char *s;
	int i = 0;

	if ((c=fgetc (In)) == EOF) return 0;
	ungetc (c, In);
	if (**pb == 0) **pb = ' ';
	if (Format [0]) {
		sprintf (*pb + offset, Format, Page+pageoff, Page+pageoff);
		*(*pb + strlen (*pb) + offset) = ' ';
		i = 2;
	}
	for (; i<MaxStrings; ++i) {
		s = pb [i] + offset;
		j = 0;
		done = 0;
		do {
			c = fgetc (In);
			switch (c) {
			case FF:
				if (BreakPage)
					return 1;
				break;
			case TAB:
				if (ExpandTabs == 0) break;
				j = j%ExpandTabs==0 ? j+ExpandTabs :
					j + ExpandTabs - j%ExpandTabs;
				if (j >= MaxColumns) {
					s [MaxColumns] = WRAP_SYMBOL;
					done = 1;
				}
				break;
			case EOF:
				done = 1;
				break;
			case CR:
			case LF:
			case 0:
				done = 1;
				break;
			default:
				if ((c<15 && c>6) || (c<21 && c>17) || c==24 || c==27 || c==127)
					c = ' ';
				s [j] = c;
				if (++j == MaxColumns) {
					s [j] = WRAP_SYMBOL;
					done = 1;
				}
				break;
			}
		} while (!done);
	}
	return 1;
}

void print_buffers (void) {
	int i;

	if (First == 0) {
		wait_user ();
	} else {
		First = 0;
		printf ("\nInsert parer and press any key\r");
		bioskey (0);
		printf ("Press ESC to interrupt            \n");
	}
	fwrite (PrinterSetup, strlen (PrinterSetup), 1, stdprn);
	printf ("Pages %d and %d\r", Page+3, Page);
	if (**Pb41 != 0) {
		for (i=0; i<MaxStrings; ++i) {
			fwrite (Pb41 [i], Size-1, 1, stdprn);
			fputc (CR, stdprn);
			check_kbd ();
		}
	}
	fputc (FF, stdprn);
	wait_user ();
	fwrite (PrinterSetup, strlen (PrinterSetup), 1, stdprn);
	printf ("Pages %d and %d\r", Page+1, Page+2);
	if (**Pb23 != 0) {
		for (i=0; i<MaxStrings; ++i) {
			fwrite (Pb23 [i], Size-1, 1, stdprn);
			fputc (CR, stdprn);
			check_kbd ();
		}
	}
	fputc (FF, stdprn);
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