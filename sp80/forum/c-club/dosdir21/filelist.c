/*
   FILELIST.C

   Example program uses dosdir directory functions (dd_findfirst,
   dd_findnext, dd_fnsplit, and dd_match) on MS-DOS, Unix, and VMS
   platforms demonstrating application portability.

   This program lists files matching the filemask and
   recursively acts on subdirectories (if selected).

   Copyright (C) 1994 Jason Mathews.
   Permission is granted to any individual or institution to use, copy,
   or redistribute this software so long as it is not sold for profit,
   provided this copyright notice is retained.

   Modification history:
    V1.0  17-May-94  Original version.
    V1.1   8-Jun-94  Handle VMS stuff.
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include "dosdir.h"
#include "match.h"

#ifdef VMS
#  define EXIT_OK 1
#  define ALT_SW || *argv[i]=='/'
#  define CHDIR(s) vms_chdir(s)
#else
#  define EXIT_OK 0
#  define CHDIR(s) chdir(s)
#  ifdef MSDOS
#    define ALT_SW || *argv[i]=='/'
#  else /* ?UNIX */
#    define ALT_SW
#  endif /* ?MSDOS */
#endif /* ?VMS */

typedef struct TDirTag {
    char* dirname;
    struct TDirTag *next;
} TDirEntry;

typedef struct {
    TDirEntry *head, *tail;
} TDirList;

/* Global variables */

char filemask[DD_MAXFILE+DD_MAXEXT];
int  attrib = DD_NORMAL;
long total_bytes = 0, dir_bytes;
unsigned total_files = 0, dir_files;
unsigned num_directories = 0;
const char *default_mask = ALL_FILES_MASK;
int (*filematch) OF(( const char*, const char*, int ));

/* Function prototypes */

void findfiles  OF((char* dir));
int  strcompare OF((const char*, const char*, int));
void q_insert   OF((TDirList *list, const char *s));
int  q_remove   OF((TDirList *list, char *s));
void PrintSummary OF((char* title, int flags, char* drive, char* path));

#if defined (VMS)

int vms_chdir(char* dir)
{
  /* kill version number on directories */
  char* s = strchr(dir, ';');
  if (s) *s = '\0';
  return chdir(dir);
}

/*---------------------------------------------------------------------*
Name            strupr - converts a string to upper-case

Description     strupr converts lower-case letters in string str to upper-case.
		No other changes occur.
*---------------------------------------------------------------------*/
char* strupr(const char* s)
{
      register char *ps = s;
      while (*ps)
	{
	    if (islower((unsigned char)*ps))
	    *ps = _toupper((unsigned char)*ps);
	    ps++;
	}
  return s;
}

#elif defined (MSDOS)

/* No valid MS-DOS directories start with a period (.),
 * except for .. or ., so anything with a period prefix
 * must be special.
 */
#  define SpecialDir(f) (*(f) == '.')

#else  /* ? UNIX */

int SpecialDir OF((const char *path));

/* Function: SpecialDir
 *
 * Purpose:  Test for special directories
 *
 * Returns: 1 if path = "." or ".."
 *          0 otherwise.
 */
int SpecialDir(path)
     const char *path;
{
  if (*path != '.') return 0;
  if (*(++path) == '.') path++;
  return (*path=='/' || *path=='\0');
}

#endif /* ?VMS */

int strcompare(s1, s2, ignore_case)
    const char *s1, *s2;
    int ignore_case;
{
    return !strcmp(s1, s2);
}

void findfiles(dir)
    char* dir;
{
  static dd_ffblk fb;       /* file block structure */
  static char tmp[DD_MAXDIR];      /* tmp string buffer */
  int rc;                       /* error code */
  TDirList list;                /* directory queue */

  if (dir)
    {
#ifdef MSDOS
      int len = strlen(dir);
      /* strip ending separator (if present), which DOS doesn't like. */
      if (len > 1 && dir[len-1]==DIR_END) dir[len-1] = 0;
#endif /* ?MSDOS */
      if (CHDIR(dir)) return; /* ?err */
    }

  rc = dd_findfirst( default_mask, &fb, attrib | DD_DIREC );
  list.head = list.tail = 0;
  dir_files = 0;
  dir_bytes = 0;

  while (rc==0)
    {
      if (attrib & DD_DIREC && DD_ISDIREC(fb.dd_mode))
	{
#ifndef VMS
	  /*  Ignore directory entries starting with '.'
	   *  which includes the current and parent directories.
	   */
	 if (!SpecialDir(fb.dd_name))
#endif /* ?!VMS */
	    q_insert(&list, fb.dd_name);
	}

      /* if match then do something with the file */
      if (filematch(fb.dd_name, filemask, 0))
	{
	  char period;
	  struct tm* t = localtime(&fb.dd_time);

	  if (!dir_files++)
	    {
		int len;
		getcwd(tmp, sizeof(tmp));
#ifndef VMS
		len = strlen(tmp);
		if (len==0 || tmp[--len] == DIR_END)
		tmp[len] = '\0';
#endif /* ?!VMS */
		++num_directories; /* increment dir count */
		printf("\nDirectory of %s", tmp);
#ifdef VMS
		printf("%s\n\n", filemask);
#else
		printf("%c%s\n\n", DIR_END, filemask);
#endif /* ?VMS */
	    }

	  if (DD_ISDIREC(fb.dd_mode))
		printf(" <DIR>  ");
	  else
	    {
		dir_bytes += fb.dd_size;
		printf("%8ld", fb.dd_size);
	    }

	  if (t->tm_hour < 12)
	  {
	      /* zero hour in local time might be negative */
	      if (t->tm_hour < 0) t->tm_hour = 0;
	      period = 'a';
	  }
	  else
	    {
	      period = 'p';
	      if (t->tm_hour != 12) t->tm_hour -= 12;
	    }

	  /* Print Date & Time */

	  printf(" %2d-%02d-%2d  %2d:%02d%cm %s\n",
		 t->tm_mon+1, t->tm_mday,
		 t->tm_year, t->tm_hour,
		 t->tm_min, period, fb.dd_name);
	}

      rc = dd_findnext(&fb);
    } /* while !rc */

  if (dir_files)
    {
      printf("\t%8ld bytes in %u file(s)\n", dir_bytes, dir_files);
      total_files += dir_files;
      total_bytes += dir_bytes;
    }

  /* recursively parse subdirectories (if any) */
  while (q_remove(&list, tmp))
    findfiles(tmp);

  if (dir) chdir(DIR_PARENT); /* go to parent directory */
}

/*
 * q_insert - insert directory name to queue
 */
void q_insert(list, s)
     TDirList *list;
     const char *s;
{
  TDirEntry *ptr;
  int len = strlen(s);
  if (!len) return;
  if ((ptr = (TDirEntry*) malloc(sizeof(TDirEntry))) == NULL )
  {
    perror("malloc");
    return;
  }
  if ((ptr->dirname = (char*) malloc(len+1)) == NULL )
  {
      perror("malloc");
      free(ptr);
      return;
  }
  strcpy(ptr->dirname, s);
  ptr->next = NULL;
  if (!list->head) list->head = ptr;
  else list->tail->next = ptr;
  list->tail = ptr;
}

/*
 *  q_remove - remove directory name from queue
 */
int q_remove(list, s)
     TDirList *list;
     char *s;
{
  TDirEntry *ptr = list->head;
  if (!ptr) return 0;		/* queue empty? */
  strcpy(s, ptr->dirname);
  list->head = ptr->next;
  free(ptr->dirname);
  free(ptr);
  return 1;			/* okay */
}

/*
 *  Print summary of file totals
 */
void PrintSummary(title, flags, drive, path)
    int flags;
    char *title, *drive, *path;
{
    printf("%s", title);
    if (flags & DRIVE) printf("%s", drive);
    if (flags & DIRECTORY)
    {
#ifndef VMS
	int len = strlen(path);
	if (len==0 || path[--len] == DIR_END)
	  path[len] = '\0';
#endif /* ?!VMS */
	printf("%s", path);
    }
#ifdef VMS
    printf("%s\n", filemask);
#else
    printf("%c%s\n", DIR_END, filemask);
#endif /* ?VMS */

    if (total_files)
	printf("\t%8ld bytes in %u file(s)\n", total_bytes, total_files);
    else
	printf("\nno files found\n");
}

int main(argc, argv)
     int argc;
     char** argv;
{
  int  i, disk = -1;
  int  flags = 0;
  char *path = 0;
  char homedir[DD_MAXDIR];   /* current working directory */
  char drive[DD_MAXDRIVE];
  char dir[DD_MAXDIR];
  char file[DD_MAXFILE];
  char ext[DD_MAXEXT];

  for (i=1; i < argc; i++)
    {
      if (*argv[i]=='-' ALT_SW)
	switch (argv[i][1]) {
	case 'S':
	case 's':
	  attrib |= DD_DIREC;
	  break;
#ifdef MSDOS
	case 'H':
	case 'h':
	  attrib |= DD_HIDDEN | DD_SYSTEM;
	  break;
#endif /* ?MSDOS */
	default:
	  printf("FILELIST - DOSDIR Application by Jason Mathews\n\n");
#ifdef MSDOS
	  printf("Usage:  filelist [path][file] [-h] [-s]\n");
#else /* ?UNIX/VMS */
	  printf("Usage:  filelist [path][file] [-s]\n");
#endif /* ?MSDOS */
	  printf("  path  = Directory path to start searching.\n");
	  printf("  file  = File(s) to search (Default=%s).\n", default_mask);
#ifdef MSDOS
	  printf("  -h    = Include hidden/system files.\n");
#endif
	  printf("  -s    = Include files in subdirectories.\n\n");
	  printf("Examples:\n");

#ifdef MSDOS
	  printf("  filelist /S\n");
	  printf("  filelist *.[ch] -s\n");
	  printf("  filelist D:\\BC4\\BIN\n");
	  printf("  filelist C:\\DOS\\[a-m]*.EXE\n");
#else /* ?UNIX/VMS */
	  printf("  filelist -s\n");
	  printf("  filelist *.c -s\n");
#  if defined(UNIX)
	  printf("  filelist /home/mathews/bin\n");
	  printf("  filelist /usr/bin/[^a]* -s\n");
#  elif defined(VMS)
	  printf("  filelist [MATHEWS.SRC]%%a*.* -s\n");
	  printf("  filelist NCF_STAFF:[MATHEWS]\n");
#  endif /* ?UNIX */
#endif /* ?MSDOS */
	  return EXIT_OK;
	}
    else
    {
#if (defined(MSDOS) || defined(VMS))
	/* For platforms that are case-insensitive:
	 * convert filemask to uppercase, so a case-insenstive
	 * comparison will not be needed.
	 * Also, the filenames returned from filefirst/filenext
	 * are assumed to be in uppercase characters.
	 */
	strupr(argv[i]);
#endif /* ?MSDOS/VMS */
	flags = dd_fnsplit(argv[i], drive, dir, file, ext);
#ifndef VMS
	if (!dd_iswild(argv[i]))
	{
	  struct stat statbuf;    /* stat structure */
	  char tmp[DD_MAXPATH];
	  int len;
	  strcpy(tmp, drive);
	  strcat(tmp, dir);
	  strcat(tmp, file);
	  strcat(tmp, ext);
	  len = strlen(tmp);
	/*  if argument is a directory and has no terminating separator
	 *  then fnsplit will identify it as a file, but we will treat it
	 *  as a directory instead.
	 */
	  if ( len != 0 && tmp[len-1] != DIR_END &&
		!stat(tmp, &statbuf) && statbuf.st_mode & S_IFDIR)
	  {
		if (flags & FILENAME)
		    strcat(dir, file);
		if (flags & EXTENSION)
		    strcat(dir, ext);
		flags = flags & ~(FILENAME | EXTENSION) | DIRECTORY;
	  }
      }
#endif /* ?!VMS */
    }
  } /* for */

  if (flags & FILENAME)
  {
    strcpy(filemask, file);
  }

  if (flags & EXTENSION)
    {
      if (!(flags & FILENAME)) strcpy(filemask, "*");
      strcat(filemask, ext);
    }

#ifdef MSDOS
  if (flags & DRIVE)
  {
	int destDisk = islower(*drive) ? *drive-'a' : *drive-'A';
	disk = getdisk();
	if (destDisk >= 0 && disk != destDisk)
	{
	    setdisk(destDisk);
	}
    else disk = -1;
  }
#endif /* ?MSDOS */

  if (flags & DIRECTORY)
  {
	getcwd(homedir, DD_MAXDIR);
	path = dir;
  }

  if (!(flags & (FILENAME | EXTENSION)))
  {
	flags |= WILDCARDS;
	strcpy(filemask, default_mask);
  }
#if defined (VMS)
  else if (!strchr(filemask, ';')) strcat(filemask, ";*");
#endif /* ?VMS */

  /* set comparison function */
  filematch = (flags & WILDCARDS) ? *dd_match : *strcompare;

  findfiles( path );

  if (total_files)
  {
     if (num_directories > 1)
	PrintSummary("\n\tTotal for:  ", flags, drive, path);
  }
  else
    PrintSummary("Directory of ", flags, drive, path);

  /* restore original disk & directory (if necessary) */
  if (flags & DIRECTORY) CHDIR(homedir);
  if (disk >= 0) setdisk(disk);
  return EXIT_OK;
}

