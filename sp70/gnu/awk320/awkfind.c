/*
 * wildcard expansion 
 *
 * Copyright (C) 1988, 1989, 1990 by Rob Duff
 * All rights reserved
 */

#include <stddef.h>
#include <string.h>

#ifdef __TURBOC__
#include <dir.h>

#else
#include <dos.h>
#define ffblk find_t
#define ff_attrib attrib
#define ff_ftime wr_time
#define ff_fdata wr_date
#define ff_fsize size
#define ff_name name
#define findfirst(n, a, s) _dos_findfirst(n, s, a)
#define findnext _dos_findnext

#define MAXPATH   80
#define MAXDRIVE  3
#define MAXDIR    66
#define MAXFILE   9
#define MAXEXT    5

#define fnsplit _splitpath
#define fnmerge _makepath
#endif

#define bits 0x21           /* archive and readonly bits */

static struct ffblk area;
static char path[MAXPATH] = "";
static char drive[MAXDRIVE];
static char dir[MAXDIR];
static char file[MAXFILE];
static char ext[MAXEXT];

char *awkfind(buff, name, attr)
char *buff;
char *name;
int attr;
{
 more:
    if (stricmp(name, path)) {
        if (strlen(name) > MAXPATH) {
            path[0] = '\0';
            return(NULL);
        }
        strcpy(path, name);
        strupr(path);
        if (findfirst(path, &area, attr)) {
            path[0] = '\0';
            return(NULL);
        }
    }
    else
        if (findnext(&area)) {
            path[0] = '\0';
            return(NULL);
        }
    if (area.ff_name[0] == '\0') {
        path[0] = '\0';
        return(NULL);
    }
    if ((attr & bits) && !(area.ff_attrib & (attr & bits)))
        goto more;
    fnsplit(path, drive, dir, file, ext);
    fnmerge(buff, drive, dir, "", "");
    strcat(buff, area.ff_name);
    return(buff);
}

