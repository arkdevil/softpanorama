#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ENTRY {
	ENTRY          *before, *after;
	ENTRY          *same;
	unsigned char  *line;
	unsigned char  *sort_ptr;
	                ENTRY();
	               ~ENTRY();
};

ENTRY::ENTRY()
{
	before = after = same = 0;
	line = sort_ptr = 0;
}

ENTRY::~ENTRY()
{
	if (before)
		delete          before;
	if (after)
		delete          after;
	if (same)
		delete          same;
	if (line)
		delete          line;
}

int             column_flag = 0;
int             uniq_flag = 0;
int             num_flag = 0;
int             rev_flag = 0;
ENTRY          *eroot = 0;

void            read_one_data(unsigned char *s)
{
	ENTRY          *e, **eptr;

	e = new ENTRY;
	e->line = strdup(s);
	e->sort_ptr = e->line;
	for (int i = 0; i < column_flag; i++) {
		while ((*e->sort_ptr <= ' ') && *e->sort_ptr)
			e->sort_ptr++;
		while (*e->sort_ptr > ' ')
			e->sort_ptr++;
		while ((*e->sort_ptr <= ' ') && *e->sort_ptr)
			e->sort_ptr++;
	}

	eptr = &eroot;
	while (*eptr) {
		int             cmp;
		if (num_flag)
			cmp = atoi(e->sort_ptr) - atoi((*eptr)->sort_ptr);
		else
			cmp = strcmp(e->sort_ptr, (*eptr)->sort_ptr);
		if (cmp == 0) {
			while (*eptr)
				eptr = &((*eptr)->same);
			*eptr = e;
			return;
		} else if (cmp < 0) {
			eptr = &((*eptr)->before);
		} else {
			eptr = &((*eptr)->after);
		}
	}
	*eptr = e;
}

void            read_data(FILE * f)
{
	unsigned char   buf[1024];
	while (fgets(buf, 1024, f) != NULL) {
		buf[strlen(buf) - 1] = 0;
		read_one_data(buf);
	}
}

void            print_data(ENTRY * e)
{
	if (!e)
		return;
	if (rev_flag)
		print_data(e->after);
	else
		print_data(e->before);
	puts(e->line);
	if (!uniq_flag)
		print_data(e->same);
	if (rev_flag)
		print_data(e->before);
	else
		print_data(e->after);
}

main(int argc, char **argv)
{
	int             i;
	while (1) {
		if (argv[1][0] == '+') {
			column_flag = atoi(argv[1] + 1);
			argc--;
			argv++;
		} else if (argv[1][0] == '-') {
			switch (argv[1][1]) {
			case 'u':
				uniq_flag = 1;
				break;
			case 'n':
				num_flag = 1;
				break;
			case 'r':
				rev_flag = 1;
				break;
			}
			argc--;
			argv++;
		} else
			break;
	}
	if (argc > 1) {
		FILE           *f;
		f = fopen(argv[1], "r");
		if (!f) {
			printf("Can't open file %s\n", argv[1]);
			exit(1);
		}
		read_data(f);
		fclose(f);
	} else
		read_data(stdin);
	print_data(eroot);
}
