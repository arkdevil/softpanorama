/* RM - Remove files and/or directory subtrees

Copyright (C) 1989, 1990, 1991 Brian B. McGuinness
                               15 Kevin Road
                               Scotch Plains, NJ 07076

This program is free software; you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software 
Foundation; either version 1, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT 
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
details.

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 675 Mass 
Ave, Cambridge, MA 02139, USA. 

This is an extended MS-DOS implementation of the *NIX RM utility.

Syntax:  RM [/AEFIRSV?] {name | @}...

/A = Detect all files, even hidden and system files, which are not normally 
     detected.  If RM is used to remove files in the root directory of a 
     bootable disk, especially a hard disk, /A should not be used with /F 
     as there is a risk of removing the system files IBMBIO.COM (IO.SYS) and 
     IBMDOS.COM (MSDOS.SYS).  This would make it impossible to boot the system 
     from that disk.  

/E = Only delete matching files whose file size is zero.  Normally, we delete 
     matching files regardless of their size.  This option is useful for 
     disposing of empty "junk" files produced by programs or by failed 
     attempts at I/O redirection.  For example, to remove ALL empty files from 
     drive C:, use the command  RM /ES C:\*.*  (/S is explained below).  Note 
     that empty files use up no disk space but they do use up a directory entry.

/F = Force deletion of files without asking.  Normally, we prompt the user for 
     confirmation before removing read-only, hidden, or system files or before 
     assuming "\*.*" at the end of a directory name (see /R below).  If the /F 
     switch is used, these files are removed without any prompt being given. 

/I = Interactive mode: the user is prompted for confirmation before each file 
     is removed, regardless of the file's attributes.

/R = Recursively delete entire subtrees.  Normally, when a directory name 
     appears on the command line it is treated as if "\*.*" was appended to 
     it.  If the /R switch is used, RM will recursively descend through any 
     directory whose name is given and will remove the entire subtree that 
     begins with that directory. 

/S = Delete matching files in entire subtree.  For example, entering 
     RM \UTIL\*.BAK  will delete all files in the \UTIL directory which have 
     the extension .BAK.  Typing  RM /S \UTIL\*.BAK  will delete all .BAK 
     files in the \UTIL directory and all subdirectories of \UTIL.  Typing 
     RM /S *.DOC  will remove all .DOC files in the current default directory 
     and all of its subdirectories.  /S ignores directory names: e.g., if you 
     have a directory called \ASM, then typing RM /S \ASM will do nothing.  To 
     remove all files in \ASM and its subdirectories, type RM /S \ASM\*.*.  
     This will only remove files, not directories.  Use /R to remove a whole 
     subtree.

/V = Verbose: display the name of each file or directory as it is removed.

/? = Display instructions for using this program

Note: Switches become active as they are encountered on the command line.  If 
      a switch is to affect a given file, it must appear before the file's 
      name on the command line.

name = name of a file or directory to be removed.  Wildcards may be used.

@    = Read a list of names and/or switches from the standard input device and 
       treat each of these as if it had been typed on the command line as an 
       argument of RM.  More than one name and/or switch may appear on each 
       line of input.  When an EOF is encountered, processing of the command 
       line resumes.  

       This feature is useful when used with a file containing a lengthy list 
       of names of files to be deleted.  It may also be used with any program 
       which writes a list of file names to standard output: e.g. a program 
       which lists all files in a given directory which have not been modified 
       since a certain date. 

If the environment string VERBOSE exists and has the value ON, then RM will 
act as though the /V switch is in effect even if /V is not included on the 
command line.  

1.00 August 1989    - Original version.
1.01 August 1989    - If the user presses a special key (e.g. F10) after being 
                      prompted for a yes or no answer, don't echo a weird char.
                      Also speed up character string output.
1.02 September 1989 - Allow the use of Esc to exit from the program.
1.03 May 1990       - Minor bug fixes and code cleanup.
1.10 July 1991      - /E switch added, messages improved.

Version 1.10          C language 
----------------------------------------------------------------------------- */

#include <stdio.h>
#include <direct.h>     /* for remove() */
#include <io.h>         /* for chmod() */

/* IF THE FOLLOWING KEYSTROKE IS READ IN RESPONSE TO A YES/NO PROMPT, THIS 
   PROGRAM WILL IMMEDIATELY TERMINATE EXECUTION */

#define ESCAPE 27

/* DEFINE ERROR CODES */

#define SUCCESS     0
#define BADSYNTAX  11
#define BADSWITCH  13

/* DEFINE FILE ATTRIBUTES */

#define NORMAL     0
#define READONLY   1
#define HIDDEN     2
#define SYSTEM     4
#define DIRECTORY 16
#define ARCHIVE   32

/* DEFINE FLAG VALUES FOR COMMAND LINE SWITCHES */

#define EMPTY        1          /* /E */
#define FORCED       2          /* /F */
#define INTERACTIVE  4          /* /I */
#define RECURSIVE    8          /* /R */
#define GLOBAL      16          /* /S */
#define VERBOSE     32          /* /V */

/* DEFINE DATA STRUCTURE RETURNED FROM findfile() */
/* Note: In the time, S = seconds / 2; in the date, Y = year - 1980 */

struct DIRINFO {
  char reserved[21];            /* Undocumented (varies with DOS version) */
  unsigned char attrib;         /* Attribute byte: 00ADVSHR */
  unsigned short time;          /* Time file was saved: HHHHHMMMMMMSSSSS */
  unsigned short date;          /* Date file was saved: YYYYYYYMMMMDDDDD */
  unsigned long size;           /* File size in bytes */
  char name[13];                /* File name */
};

/*----------------------------------------------------------------------------*/
main (int argc, char **argv) {

void delete    (char *pathname, struct DIRINFO *file, int flags);   /* Remove a file */
int  delglobal (char *fname, int attributes, int flags, char *end); /* Delete file in all subdirectories */
int  delmatch  (char *fname, int attributes, int flags, char *end); /* Delete matching files */

int fexpand (char *relname, char *absname);                 /* Fully qualify file name */
int findfile (char *fname, int srchattr, struct DIRINFO *); /* Search directory for a file */
int getkeyn();                                              /* Read keystroke and print newline */
short getmode (char *fname);                                /* Get file attributes */
char *nexttok (int *argc, char ***argv, int *inpflag);      /* Get next argument */
void recurse (char *path, int attributes, int flags);       /* Remove a subtree */
void usage (char switchar);                                 /* Display instructions */

char switchar;  /* Current MS-DOS switch character */
int attrib;     /* Attributes to use to search for matching files */
int flags;      /* Keeps track of command line switches */
int filecnt;    /* Keeps track of how many names we've found on cmd line */
int inpflag;    /* 0 = get tokens from cmd line, otherwise get them from stdin */
char *token;    /* Command line token */
int i;

char fullname[84];      /* Buffer for fully qualified file/directory name */
char *end;              /* Location of end of fully qualified file name */

char defdir[80];        /* Buffer for default directory name */
int  cdlen;             /* Length of name of current default directory */

/* SET UP DEFAULT PARAMETERS */
attrib=ARCHIVE | READONLY;      /* Only search for normal & read-only files */
flags=0;                        /* No switches found yet */
inpflag=0;                      /* Read tokens from command line */
filecnt=0;                      /* No file names found yet */

token=getenv ("VERBOSE");       /* If VERBOSE=ON, set flag accordingly */
if (token != NULL && !stricmp (token, "ON")) flags=VERBOSE;

switchar=getswchr();    /* Get the current DOS switch char */
fexpand (".", defdir);  /* Get current default directory, fully qualified */
for (cdlen=0; defdir[cdlen]; cdlen++);

/* Process each token on the command line */

while ((token=nexttok (&argc, &argv, &inpflag)) != NULL) {

  if (*token == switchar) {                          /* It's a switch */
    while (*++token) switch (toupper (*token)) {
      case 'A': attrib |= HIDDEN | SYSTEM;
                break;

      case 'E': flags |= EMPTY;
                break;

      case 'F': flags |= FORCED;
                flags &= ~INTERACTIVE;
                break;

      case 'I': flags |= INTERACTIVE;
                flags &= ~FORCED;
                break;

      case 'R': flags |= RECURSIVE;
                break;

      case 'S': flags |= GLOBAL;
                break;

      case 'V': flags |= VERBOSE;
                break;

      case '?': usage (switchar);
                break;

      default: iprintf ("rm: Unknown switch: %c%c\n", switchar, *token);
               exit (BADSWITCH);
    }
  }

  else {                                             /* It's a filespec */
    filecnt++;
    if (fexpand (token, fullname)) {  /* Expand token to fully-qualified name */
      iprintf ("rm: Invalid name: %s\n", token);
      continue;
    }
    for (end=fullname; *end; end++);    /* Find the end of the name */

    if (end[-2] == ':') {       /* DOS doesn't recognize root as a directory */
      i=DIRECTORY;
      end--;
    } else {
      if (end[-1] == '\\') *--end = '\0';
      i=getmode (fullname);
    }

    if (i != -1 && i & DIRECTORY) {     /* DEAL WITH A DIRECTORY */

      if (flags & RECURSIVE) {  /* DELETE ENTIRE SUBTREE */
        i=end - fullname;
        if (cdlen >= i && !strnicmp (defdir, fullname, i)) {
          iprintf ("rm: Can't remove tree containing current directory:\n    %s\n ",
                   fullname);
        }
        else recurse (fullname, attrib, flags);
      }

      else {                    /* DELETE ALL FILES IN THE DIRECTORY */
        if (!(flags & FORCED)) {
          iprintf ("Delete all files in directory %s [n]? ", fullname);
          i=toupper(getkeyn());
          if (i == ESCAPE) exit (SUCCESS);
          if (i != 'Y') continue;
        }
        strcpy (end++, "\\*.*");
        delmatch (fullname, attrib, flags, end);
      }
    }
    else {      /* IT'S NOT A DIRECTORY, SO DELETE ALL MATCHING FILES */ 
      for (; end > fullname && end[-1] != '\\' && end[-1] != ':'; end--);

      if (flags & GLOBAL) i=delglobal (fullname, attrib, flags, end);
      else i=delmatch (fullname, attrib, flags, end);
      if (!i) iprintf ("rm: Not found: %s\n", token);
    }
  }   /* end of "arg is a pathname" */
}     /* end of "while more cmd line args" */

/* IF NO PATHNAMES WERE GIVEN, PRINT SYNTAX AND EXIT WITH ERROR CODE */
if (!filecnt) {
  usage (switchar);
  exit (BADSYNTAX);
}
exit (SUCCESS);
}

/*----------------------------------------------------------------------------*/
/* delete() - Delete a specified file                                         */
/*                                                                            */
/* filename = pathname of file to be deleted                                  */
/* attrib   = attributes of file to be deleted                                */
/* flags    = flags set by command line switches                              */
/*----------------------------------------------------------------------------*/
void delete (char *pathname, struct DIRINFO *file, int flags) {
  int i;
  static char attr[]="RHSVDA";
  static char *month[] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

  /* FOR SPECIAL FILES, OR IF IN INTERACTIVE MODE, MAKE SURE THAT THE USER 
     REALLY WANTS TO DELETE THE FILE */

  if ((flags & INTERACTIVE) || 
      ((file->attrib & (HIDDEN | SYSTEM | READONLY)) && !(flags & FORCED))) {
    iprintf ("Delete %s  %ld  %d %s %04d  %d:%02d  ", pathname, file->size, 
      file->date & 0x001F, month[((file->date & 0x01E0) >> 5) - 1],
      1980 + (file->date >> 9), file->time >> 11, (file->time & 0x07E0) >> 5);
    for (i=5; i >= 0; i--) iprintf ("%c", (file->attrib & (1 << i)) ? attr[i] : '-');
    iprintf ("  [N]? ");
    i=toupper(getkeyn());
    if (i == ESCAPE) exit (SUCCESS);
    if (i != 'Y') return;
  }

#ifdef DEBUG
  iprintf ("remove (%s)\n", pathname);
#else

  /* MODIFY ATTRIBUTES, IF NECESSARY, SO WE CAN DELETE THE FILE */
  if (file->attrib & (HIDDEN | SYSTEM | READONLY)) chmod (pathname, NORMAL);

  if (remove (pathname)) iprintf ("rm: Can't delete %s\n", pathname);
  else if (flags & VERBOSE) iprintf ("%s\n", pathname);
#endif
}

/*----------------------------------------------------------------------------*/
/* delglobal() - Delete all matching files in a subtree                       */
/*                                                                            */
/* name       = file specification for files to be removed                    */
/* attributes = attributes to be used in file search                          */
/* flags      = flags set by command line switches                            */
/* end        = pointer to beginning of file name (just beyond path)          */
/*                                                                            */
/* We return the number of matching files found.                              */
/*----------------------------------------------------------------------------*/

int delglobal (char *fname, int attributes, int flags, char *end) {

  struct DIRINFO dir;
  int i, nfiles;
  char *cp, filespec[13];

  strcpy (filespec, end);       /* Save pattern to match in file search */

  /* DELETE MATCHING FILES IN CURRENT DIRECTORY */
  nfiles=delmatch (fname, attributes, flags, end);

  /* DELETE MATCHING FILES IN ALL SUBDIRECTORIES */
  attributes |= DIRECTORY;
  strcpy (end,"*.*");
  i=findfile (fname, attributes, &dir);
  attributes &= ~DIRECTORY;   /* Restore attributes to their original state */
  while (!i) {
    /* IGNORE THE "." AND ".." FILES */
    if ((dir.name[0] != '.') || (dir.name[1] && (dir.name[1] != '.' || dir.name[2]))) {
      if (dir.attrib & DIRECTORY) {
        strcpy (end, dir.name); /* Append directory name to the path */
        for (cp=end; *cp; cp++); /* Append file spec to the directory name */
        *cp++='\\';
        strcpy (cp, filespec);
        nfiles += delglobal (fname, attributes, flags, cp);
      }
    }
    i=findfile (NULL, 0, &dir);
  }
  end[-1]='\0';               /* Restore path to its original state */
  return nfiles;
}

/*----------------------------------------------------------------------------*/
/* delmatch() - Delete all files matching a given file specification          */
/*                                                                            */
/* name       = file specification for files to be removed                    */
/* attributes = attributes to be used in file search                          */
/* flags      = flags set by command line switches                            */
/* end        = pointer to beginning of file name (just beyond path)          */
/*                                                                            */
/* We return the number of matching files found.                              */
/*----------------------------------------------------------------------------*/

int delmatch (char *fname, int attributes, int flags, char *end) {

  struct DIRINFO file;
  int i, nfiles;

  nfiles=0;     /* Keep track of how many matching files we find */

  i=findfile (fname, attributes, &file);
  while (!i) {
    nfiles++;
    strcpy (end, file.name);
    if (!(file.size && (flags & EMPTY))) delete (fname, &file, flags);
    i=findfile (NULL, 0, &file);
  }
  return nfiles;
}

/*----------------------------------------------------------------------------*/
/* recurse() - Recursively delete a subtree                                   */
/*                                                                            */
/* path       = full path of directory to be removed                          */
/* attributes = attributes to be used in file search                          */
/* flags      = flags set by command line switches                            */
/*----------------------------------------------------------------------------*/

void recurse (char *path, int attributes, int flags) {

  char *pathend;
  int i;
  struct DIRINFO file;

  /* FOR INTERACTIVE MODE, CHECK IF WE'RE TO REMOVE THIS DIRECTORY */
  if (flags & INTERACTIVE) {
    iprintf ("Remove directory %s [N]? ", path);
    i=toupper(getkeyn());
    if (i == ESCAPE) exit (SUCCESS);
    if (i != 'Y') return;
  }

  /* FIND END OF PATH STRING AND SAVE ITS LOCATION */
  for (pathend=path; *pathend; pathend++);

  strcpy (pathend++, "\\*.*");    /* Append '\*.*' to the path. */

  attributes |= DIRECTORY;        /* Search for directories as well as files */

  /* REMOVE EACH FILE AND SUBTREE IN THIS DIRECTORY */
  i=findfile (path, attributes, &file);
  while (!i) {
    /* IGNORE THE "." AND ".." FILES */
    if ((file.name[0] != '.') || (file.name[1] && (file.name[1] != '.' || file.name[2]))) {

      strcpy (pathend, file.name); /* Append current file name to the path */

      if (file.attrib & DIRECTORY) recurse (path, attributes, flags);
      else if (!(file.size && (flags & EMPTY))) delete (path, &file, flags);

    }
    i=findfile (NULL, 0, &file);
  }
  pathend[-1]='\0';             /* Restore path to its original state */
  attributes &= ~DIRECTORY;     /* Restore attributes to their original state */

#ifdef DEBUG
  iprintf ("rmdir (%s)\n", path);
#else
  if (rmdir (path)) {           /* Remove the directory */
    iprintf ("rm: Can't remove directory: %s\n", path);
  }
  else if (flags & VERBOSE) iprintf ("[%s]\n", path);
#endif
}

/*------------------------------------------------------------------------------
  usage() - Display instructions for using this program
------------------------------------------------------------------------------*/
void usage (char c) {
  static int displayed=0;       /* Only display instructions once */

  if (!displayed++) {
    iprintf ("RM - Remove files and/or directory subtrees\n"
      "Copyright (C) 1989, 1990, 1991 Brian B. McGuinness\n\n"
      "Syntax: RM [%cAEFIRSV?] {name | @}...\n"
      "  %cA = Remove ALL matching files, even hidden & system files (careful!)\n"
      "  %cE = Only remove empty (size zero) files\n"
      "  %cF = Force removal even if hidden or read-only (don't ask user)\n"
      "  %cI = Interactive: ask user to confirm each removal\n"
      "  %cR = Recursively remove entire subtrees\n", c, c, c, c, c, c);
    iprintf ("  %cS = Remove matching files from subtrees\n"
      "  %cV = Verbose: display the name of each object as it is removed\n"
      "  %c? = Display instructions\n\n"
      "  @ = Read pathnames and switches from standard input until end-of-file is\n"
      "      encountered.  Then continue processing the command line.\n\n", c, c, c);
    iprintf ("Setting the environment variable VERBOSE=ON is equivalent to %cV\n\n"
      "This program is free software; you can redistribute it and/or modify it under\n"
      "the terms of the GNU General Public License as published by the Free Software\n" 
      "Foundation; either version 1, or (at your option) any later version.\n", c);
  }
}
