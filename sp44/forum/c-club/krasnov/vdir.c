#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dir.h>
#include <dos.h>

int clustSize;
int dirs = 0;

void help (void){
    fputs ("Вызов: VDIR [каталог] [/S | /H]\n", stderr);
    fputs ("/S - показать информацию о подкаталогах\n", stderr);
    fputs ("/H - выдать эту подсказку\n", stderr);
}

void error (const char *msg){
    fputs (msg, stderr);
    help ();
    exit (2);
}

void print (const char *direc, long size, long dirSize){
    register i;

    printf ("%s", direc);
    if (strlen (direc) & 1) printf (" ");
    for (i = max (1, (60 - strlen (direc)) / 2); i--;) printf (" .");
    printf (" %8ld %8ld\n", size, dirSize);
}

long ldir (const char *direc, long *size){
    int done;
    long locSize, dirSize = 0;
    struct ffblk fblk;
    char path [MAXPATH];

    fnmerge (path, NULL, direc, "*.*", NULL);
    done = findfirst (path, &fblk, FA_HIDDEN | FA_SYSTEM | FA_DIREC);
    if (done){
	fprintf (stderr, "Нет такого каталога: %s\n", direc);
	exit (1);
    }
    *size = 0;
    while (!done){
	*size += (fblk.ff_fsize + clustSize - 1) /
	    clustSize * clustSize;
	if (fblk.ff_attrib & FA_DIREC &&
	    strcmp (fblk.ff_name, ".") && strcmp (fblk.ff_name, "..")){
	    fnmerge (path, NULL, direc, fblk.ff_name, NULL);
	    dirSize += ldir (path, &locSize);
	}
	done = findnext (&fblk);
    }
    dirSize += *size;
    if (dirs) print (direc, *size, dirSize);
    return dirSize;
}

int main (int argc, char *argv []){
    int narg = 1;
    char *direc = "";
    char drive [MAXDRIVE];
    unsigned char disk;
    struct dfree dtable;
    long size, dirSize;

    fputs ("VDIR  Версия 1.1  Copyright (c) 1989, 1991 Краснов М.М.\n\n", stderr);
    if (argc > 1 && argv [1][0] != '/' && argv [1][0] != '-'){
	direc = argv [1];
	narg++;
    }
    if (argc > narg + 1) error ("Неверное число параметров\n");
    if (argc > narg){
	if (!(argv [narg][0] == '/' || argv [narg][0] == '-') ||
	    argv [narg][1] == '\0' || argv [narg][2] != '\0')
	    error ("Неверный параметр\n");
	switch (argv [narg][1]){
	    case 's': case 'S':
		dirs = 1;
		break;
	    case 'h': case 'H': case '?':
		help ();
		return 0;
	    default:
		error ("Неверная опция\n");
	}
    }
    fnsplit (direc, drive, NULL, NULL, NULL);
    if (*drive == '\0') disk = 0;
    else if ('a' <= *drive && *drive <= 'z') disk = *drive - 'a' + 1;
    else if ('A' <= *drive && *drive <= 'Z') disk = *drive - 'A' + 1;
    else {
	fprintf (stderr, "Неверная спецификация диска: %s\n", drive);
	exit (1);
    }
    getdfree (disk, &dtable);
    if (dtable.df_sclus == 0xFFFF){
	fprintf (stderr, "Нет такого диска: %s\n", drive);
	exit (1);
    }
    clustSize = dtable.df_sclus * dtable.df_bsec;
    strupr (direc);
    dirSize = ldir (direc, &size);
    if (!dirs) print (direc, size, dirSize);
    printf ("\nСвободно на диске %ld байт\n", (long) dtable.df_avail * clustSize);
    return 0;
}
