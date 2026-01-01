#include "rcv.h"
extern char *malloc();

struct fp {
	FILE *fp;
	struct fp *link;
};
static struct fp *fp_head;

FILE *
Fopen(file, mode)
	char *file, *mode;
{
	FILE *fp;

	if ((fp = fopen(file, mode)) != NULL)
		register_file(fp);
	return fp;
}

FILE *
Fdopen(fd, mode)
	char *mode;
{
	FILE *fp;

	if ((fp = fdopen(fd, mode)) != NULL)
		register_file(fp);
	return fp;
}

Fclose(fp)
	FILE *fp;
{
	if (fp == NULL)
		return 0;
	unregister_file(fp);
	return fclose(fp);
}

close_all_files()
{
	while (fp_head)
		(void) Fclose(fp_head->fp);
}

register_file(fp)
	FILE *fp;
{
	struct fp *fpp;

	if ((fpp = (struct fp *) malloc(sizeof *fpp)) == NULL)
		panic("Out of memory");
	fpp->fp = fp;
	fpp->link = fp_head;
	fp_head = fpp;
}

unregister_file(fp)
	FILE *fp;
{
	struct fp **pp, *p;

	for (pp = &fp_head; p = *pp; pp = &p->link)
		if (p->fp == fp) {
			*pp = p->link;
			free((char *) p);
			return;
		}
	/* XXX
	 * Ignore this for now; there may still be uncaught
	 * duplicate closes.
	panic("Invalid file pointer");
	*/
}

char *BestBuffer(f)
FILE *f;
{
	char *buf;
	int n = 0;

	if ((buf = value("BUFSIZ")) == NULL)
		return NULL;

	if ((n = atoi(buf)) <= 0) {
		fprintf(stderr, ediag("%s: bad buffer size\n",
				      "%s: плохой размер буфера\n"),
				 buf);
		return NULL;
	}
	if (n <= BUFSIZ)        /* Not less then system depended */
		return NULL;

	if ((buf = malloc(n)) != NULL)
		VBUF(f, buf, n);
	else
		fprintf(stderr, ediag(
"WARNING: can't allocate %d bytes for I/O buffer\n",
"ПРЕДУПРЕЖДЕНИЕ: нельзя заказать %d байт для буферизации в/в\n"), n);

	return buf;
}

#ifndef _NFILE
#define _NFILE  20
#endif

static struct {
	char *t_name;
	char *t_buf;
	FILE *t_f;
} TmpTable[_NFILE];

static short TmpCount = 0;


FILE *
TmpOpen(name, mode)
char *name, *mode;
{
	int i;
	FILE *f;
	int first = -1;

	for (i = 0; i < TmpCount; i++) {
		if (TmpTable[i].t_name == NULL) {
			if (first < 0)
				first = i;
		}
#ifdef MSDOS
		else if (strcmp(TmpTable[i].t_name, name) == 0) {
			char buf[100];

			sprintf(buf, ediag("temp name %s already in use!",
					   "временное имя %s уже используется!"),
				     name);
			_error(buf);
		}
#endif
	}
	if ((f = fopen(name, mode)) == NULL)
		return NULL;
#ifndef MSDOS
	remove(name);
#endif
	if (first < 0)
		first = TmpCount++;

	if ((TmpTable[first].t_name = calloc(strlen(name) + 1, 1)) == NULL)
		_error(ediag("no memory for temp file name!",
			     "нет памяти для имени временного файла!"));
	strcpy(TmpTable[first].t_name, name);

	TmpTable[first].t_f = f;

	TmpTable[first].t_buf = BestBuffer(f);

	return f;
}

void
TmpDel(f)
FILE *f;
{
	int i;

	if (f == NULL)
		return;

	for (i = 0; i < TmpCount; i++)
		if (TmpTable[i].t_name != NULL && TmpTable[i].t_f == f) {
			fclose(f);
			if (f == image)
				image = NULL;
			if (f == tf)
				tf = NULL;
#ifdef  MSDOS
			remove(TmpTable[i].t_name);
#endif
			free(TmpTable[i].t_name);
			TmpTable[i].t_name = NULL;
			if (TmpTable[i].t_buf != NULL) {
				free(TmpTable[i].t_buf);
				TmpTable[i].t_buf = NULL;
			}
			return;
		}
	_error(ediag("temp name not found!", "не найдено имя временного файла!"));
}


void
TmpDelAll()
{
	int i;

	for (i = 0; i < TmpCount; i++)
		if (   TmpTable[i].t_name != NULL
		    && TmpTable[i].t_f != tf
		   )
			TmpDel(TmpTable[i].t_f);
}

