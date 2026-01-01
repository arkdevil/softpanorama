#include <io.h>
#include <fcntl.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys\stat.h>

#define	BUFL	16384
#define	MAX	512		/* entries in data base */

typedef	unsigned int	word;
typedef unsigned char	byte;
typedef struct	ffblk	ffblk;
typedef struct	stat	ustat;

typedef struct
{
	char	name[12];	/* file name */
	long	ts;		/* modification time */
	long	size;		/* file size */
	word	cs;		/* checksum */
} data;

char*	base	= "CHECK.SUM";
int	recur	= 0;		/* -r flag */
int	cflag	= 0;		/* -c flag */
int	verbo	= 0;		/* -v flag */
int	count	= 0;		/* actual arg count */
int	fd	= -1;		/* current log file */
int 	n	= 0;		/* log data length in bytes */
int	m	= 0;		/* # of log records */
word	ones	= 0xFFFF;	/* standard checksum */
int	wflag	= 0;		/* update log file */
int	ronly	= 0;		/* log file is read-only */
char	cwd[MAXDIR];		/* current directory */
data	dp[MAX+1];		/* data base in memory */
char	fbuf[BUFL];		/* data file buffer */

void	badflag	(char*);
void	usage	(void);
int	setflag (char*);
word	csum	(void*, int);
void	ckdir	(char*);
void	ckdev	(char*);
word	fsum	(char*);
void	add	(ffblk*, long, word);
void	strange	(char*, char*);
int	yes	(void);
void	repl	(ffblk*, long, data*);
int	intp	(void);

void	main(argc, argv)
char**	argv;
{
	char*	p;
	_fmode = O_BINARY;
	ctrlbrk(intp);
	getcwd(cwd, MAXDIR);
	while (p = *++argv, --argc > 0)
	if (p[0] == '-') {
		if (setflag(p+1)) continue;
		else badflag(p);
	} else
	if (p[1] == ':' && p[2] == 0) ckdev(p);
	else ckdir(p);
	if (count == 0) ckdir(cwd);
	exit(0);
}

int	setflag(s)
char*	s;
{
loop:	switch (*s++) {
	case 'r':
		recur++; goto loop;
	case 'c':
		cflag++; goto loop;
	case 'v':
		verbo++; goto loop;
	case 0:
		return 1;
	default:
		return 0;
	}
}

void	badflag(p)
char*	p;
{
	cprintf("Bad flag: '%s'\n\r", p);
	cputs("Usage: check [ flags ] [ args ] - check file checksums\n\r"
	      "Flags: -c : create SUM files\n\r"
	      "       -r : check subdirectories recursively\n\r"
	      "       -v : verbose\n\r"
	      "Args : directory or device names; "
	      "default is current directory\n\r"
/*	      "Copyright (C) 1989  B. Gontar (Kiev)\n\r"  */);
	exit(1);
}

int	intp()
{
	cputs("Program aborted\n\r");
	return 0;
}

word	csum(buf, n)
void*	buf;
{
	byte*	p = buf;
	word	s = 0;
	int	c = 0;
	while (--n >= 0)
	switch (c++ & 03) {
	case 0:
		s += *p++; break;
	case 1:
		s += ~(*p++); break;
	case 2:
		s += (*p++) << 1; break;
	case 3:
		s -= *p++; break;
	}
	return s;
}

word	fsum(name)
char*	name;
{
	int	cf;
	word	s, k;
	if ((cf = open(name, O_RDONLY)) < 0) {
		cprintf("Cannot read file '%.12s'\n\r", name);
		return 0;
	}
	s = 0;
	while ((k = read(cf, fbuf, BUFL)) > 0)
		s += csum(fbuf, k);
	close(cf);
	if (s == ones) s = 0;
	return ~s;
}

void	ckdev(dev)
char*	dev;
{
	int	d, n;
	d = getdisk(); n = toupper(dev[0]) - 'A';
	if (n < 0 || n >= setdisk(d)) {
		cprintf("No such device: '%s'\n\r", dev);
		return;
	}
	setdisk(n); count++;
	cprintf("Checking device %s\n\r", dev);
	ckdir("\\");
	setdisk(d);
}

void	ckdir(dir)
char*	dir;
{
	char	cd[MAXDIR], sd[MAXDIR];
	long	l;
	int	i;
	data*	p;
	ffblk	w;
	ustat	b, x;
	getcwd(cd, MAXDIR);
	if (chdir(dir) < 0) {
		cprintf("Cannot change directory to '%s'\n\r", dir);
		return;
	}
	getcwd(sd, MAXDIR);
	count++;
	if (stat(base, &b) < 0) ronly = 0;
	else ronly = (b.st_mode & S_IWRITE) == 0;
	if ((fd = open(base, ronly ? O_RDONLY : O_RDWR)) < 0) {
		if (verbo && !cflag)
			cprintf("Cannot access SUM file in '%s'\n\r", sd);
		if (cflag)
			cprintf("Creating new SUM file in '%s'\n\r", sd);
		if (!cflag) goto out;
		if ((fd = open(base, O_RDWR|O_CREAT, S_IWRITE)) < 0) {
			strange("Cannot create SUM file", 0);
			goto out;
		}
		else {
			fstat(fd, &b);
			write(fd, &ones, 2);
			lseek(fd, 0l, 0); wflag++;
		}
	}
	cprintf("Checking directory '%s'\n\r", sd);
	l = filelength(fd); n = (word) l;
	if (l <= 0 || l > MAX*sizeof(data) || n % sizeof(data) != 2) {
		cprintf("Bad size of SUM file - directory not checked\n\r");
		goto out;
	}
	if (read(fd, dp, n) != n) {
		cprintf("Error reading SUM file\n\r");
		goto out;
	}
	m = (n -= 2) / sizeof(data);
	if (csum(dp, n) + *(word*)((char*)dp + n) != ones) {
		cprintf("Bad SUM file - directory not checked\n\r");
		goto out;
	}
	i = FA_RDONLY | FA_HIDDEN | FA_SYSTEM;
	for (i = findfirst("*.*", &w, i); i == 0; i = findnext(&w)) {
		if (strcmp(w.ff_name, base) == 0) continue;
		for (i=m, p=dp; --i >= 0; p++)
		if (strncmp(p->name, w.ff_name, 12) == 0)
			break;
		stat(w.ff_name, &x);
		if (i < 0) {		/* new file */
			if (x.st_mtime > b.st_mtime || cflag)
				add(&w, x.st_mtime, 0);
			else {
				strange("No information about '%.12s'",
					w.ff_name);
				if (!ronly) {
					cprintf("Add it to SUM file ? ");
					if (yes()) add(&w, x.st_mtime, 0);
				}
			}
		}
		else {		/* file is both in log and in dir */
			if (p->size == w.ff_fsize
			 && p->cs == fsum(w.ff_name)) {	   /* no change */
				if (p->ts != x.st_mtime) {
					strange("File '%.12s' is still the same, "
						"but its date has changed",
						w.ff_name);
					if (!ronly) {
					    cprintf("Correct the SUM file ? ");
					    if(yes()) repl(&w, x.st_mtime, p);
					}
				}
			 }
			 else {		/* there's a change */
				if (x.st_mtime <= p->ts) {
					strange("File '%.12s' was updated without"
						" updating the date",
						w.ff_name);
					if (!ronly) {
					    cprintf("Correct the SUM file ? ");
					    if(yes()) repl(&w, x.st_mtime, p);
					}
				}
				else repl(&w, x.st_mtime, p);
			 };
			 p->name[0] |= 0x80;	/* found in dir */
		}
	};
	for (i=m, p=dp; --i >= 0; p++)
	if (p->name[0] & 0x80) p->name[0] &= 0x7F;
	else {
		if (verbo || ronly)
			cprintf("File '%.12s' was deleted\n\r", p->name);
		if (i > 0) memcpy(p, p+1, i*sizeof(data));
		wflag++; --p;
	};
	if (wflag) {
		wflag = 0;
		if (ronly)
			cprintf("SUM file is read-only - cannot update\n\r");
		else {
			m = p - dp;
			n = m * sizeof(data);
			*(word*)p = ~csum(dp, n); n += 2;
			lseek(fd, 0l, 0);
			if (write(fd, dp, n) != n) {
				cprintf("Error writing SUM file\n\r");
				goto out;
			}
			chsize(fd, (long)n);
		}
	};
	close(fd); fd = -1;
	if (recur)
	for (i = findfirst("*.*", &w, FA_DIREC); i == 0; i = findnext(&w)) {
		if (w.ff_name[0] == '.') continue;
		if (w.ff_attrib & FA_DIREC) ckdir(w.ff_name);
	}
out:	if (fd >= 0) close(fd);
	chdir(cd);
}

void	add(q, mtime, cs)
ffblk*	q;
long	mtime;
word	cs;
{
	data*	p;
	if (ronly) {
		cprintf("Cannot add '%.12s' to SUM file\n\r", q->ff_name);
		return;
	}
	if (m == MAX-1) {
		cprintf("SUM file is exhausted\n\r");
		return;
	};
	if (verbo)
		cprintf("File '%.12s' is added \n\r", q->ff_name);
	p = &dp[m];
	strncpy(p->name, q->ff_name, 12);
	p->name[0] |= 0x80;
	p->ts = mtime;
	p->size = q->ff_fsize;
	if ((p->cs = cs) == 0) p->cs = fsum(q->ff_name);
	m++; wflag++;
}

void	repl(q, mtime, p)
ffblk*	q;
long	mtime;
data*	p;
{
	if (ronly) {
		cprintf("Cannot update '%.12s' in SUM file\n\r", q->ff_name);
		return;
	}
	p->ts = mtime;
	p->size = q->ff_fsize;
	p->cs = fsum(q->ff_name);
	if (verbo)
		cprintf("File '%.12s' was updated \n\r", q->ff_name);
	wflag++;
}

void	strange(txt, p)
char	*txt, *p;
{
	highvideo();
	cprintf("STRANGE: ");
	normvideo();
	cprintf(txt, p);
	highvideo();
	cprintf(" !\n\r");
	normvideo();
}

int	yes()
{
	char	c;
	c = getche(); cputs("\n\r");
	return c == 'y' || c == 'Y';
}
