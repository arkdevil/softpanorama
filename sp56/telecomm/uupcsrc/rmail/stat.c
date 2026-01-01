#include <stdio.h>
#include <string.h>
#ifdef __TURBOC__
#include <dir.h>
#else
#include <direct.h>
#endif
#include <stdlib.h>
#include <time.h>
#include "lib.h"
#include "hlib.h"
#include "address.h"
#include "pcmail.h"

currentfile();

static char * altdate(void);
extern boolean remote_address(char *);
static void putaddress(char *,char *,char *,long, char *);

static FILE * F;

boolean
init_stat() {
	char buf[MAXPATH];

	mkfilename(buf,spooldir,"mailstat");
	if ((F = FOPEN(buf,"a",TEXT)) == nil(FILE)) {
		printerr("init_stat", buf);
		printmsg(0,"init_stat: can't open statistics file %s",buf);
		return FALSE;
	}
	fd_lock(buf, fileno(F));
	return TRUE;
}

void write_stat(fromuser,fromnode,address,hispath,sz)
char * address, * fromuser, * fromnode, * hispath;
long sz;
{
	char *s, *cp, *pd;
	char user[MAXADDR];
	boolean NotSame = FALSE;

	if ((s = strchr(fromuser, '!')) != NULL) {
		*s = '\0';
		NotSame = (strcmp(nodename, fromuser) != 0);
		*s = '!';
	}
	else
		NotSame = TRUE;
	if (NotSame) {
		sprintf(user, "%s!%s", fromnode, fromuser);
		for (s = user; *s; s++)
			if (*s == '@')
				*s = '%';
	}
	else
		strcpy(user, fromuser);
	pd = altdate();
	cp = strdup(address);
	checkref(cp);
	if ((s = strtok(cp, " \t")) != NULL && *s) {
		putaddress(user, s, hispath, sz, pd);
		while((s = strtok(NULL, " \t")) != NULL && *s)
			putaddress(user, s, hispath, sz, pd);
	}
	free(cp);
}

static
void putaddress(fromuser,address,hispath,sz,pd)
char * address, * fromuser, * hispath, *pd;
long sz;
{
	char *s;
	boolean NotSame = FALSE;

	fprintf(F,"%s\t",fromuser);
	if (remote_address(address)) {
		if ((s = strchr(address, '!')) != NULL) {
			*s = '\0';
			NotSame = (strcmp(hispath, address) != 0);
			*s = '!';
		}
		else
			NotSame = TRUE;
	}
	if (NotSame) {
		fprintf(F, "%s!", hispath);
		for (s = address; *s; s++)
			if (*s == '@')
				*s = '%';
	}
	fprintf(F,"%s\t%ld\t%s\n",address,sz,pd);
}

static
char *altdate(void)
{
	static char dout[40];
	time_t now;
	struct tm *t;

	time(&now);
	t = localtime(&now);
	sprintf(dout, "%02d:%02d:%02d %02d.%02d.%02d",
			 t->tm_hour, t->tm_min, t->tm_sec,
			 t->tm_mday, t->tm_mon+1, t->tm_year );
	return dout;
}
