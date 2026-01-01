/* **************************************************************** */
/*             sspell - similar to Unix spell                       */
/*                        version 1.4                               */
/*                                                                  */
/* Author: Maurice Castro                                           */
/* Release Date:  4 Jul 1992                                         */
/* Bug Reports: maurice@bruce.cs.monash.edu.au                      */
/*                                                                  */
/* This code has been placed by the Author into the Public Domain.  */
/* The code is NOT covered by any warranty, the user of the code is */
/* solely responsible for determining the fitness of the program    */
/* for their purpose. No liability is accepted by the author for    */
/* the direct or indirect losses incurred through the use of this   */
/* program.                                                         */
/*                                                                  */
/* Segments of this code may be used for any purpose that the user  */
/* deems appropriate. It would be polite to acknowledge the source  */
/* of the code. If you modify the code and redistribute it please   */
/* include a message indicating your changes and how users may      */
/* contact you for support.                                         */
/*                                                                  */
/* The author reserves the right to issue the official version of   */
/* this program. If you have useful suggestions or changes for the  */
/* code, please forward them to the author so that they might be    */
/* incorporated into the official version                           */
/*                                                                  */
/* Please forward bug reports to the author via Internet.           */
/*                                                                  */
/* **************************************************************** */

#include "cache.h"
#include "file.h"
#include <stdio.h>
#include "strfn.h"
#include "config.h"
#include "check.h"
#include <signal.h>
#ifdef __TURBOC__
#include <dir.h>
#endif
#include "error.h"
#include "stop.h"
#if !defined(pyr)
#include <stdlib.h>
#endif

extern void cfgload();

/* fix up some slash problems with MS-DOS */
#ifdef __MSDOS__
extern void dosfix();
#endif

FILE *fout;
int prtderive;
int prtroot;
char progname[MAXSTR];
char ftmp1[MAXSTR];
char ftmp2[MAXSTR];

char dictpath[MAXSTR];
char rule[MAXSTR];
char indexarr[MAXSTR];
char dictionary[MAXSTR];
char sort[MAXSTR];
char stop[MAXSTR];

void emergencyshutdown();


void errormesg(mesg,val)
char *mesg;
int val;
{
   fprintf(stderr,"%s: %s\n",progname, mesg);
   exit(val);
   }

void usage()
{
   fprintf(stderr,"%s: Usage:\n",progname);
   fprintf(stderr,"%s [-u] [-v] [-x] [-c config] [-D dict] [-I index] [-R rule]\n\t[-C cachesize] [-S stop] [file] ...\n",progname);
   emergencyshutdown();
   exit(1);
   }

void emergencyshutdown()
{
   FILE *f;
   if (fout != NULL) fclose(fout);
   f = fopen(ftmp1,"rt");
   if (f != NULL)
   {
      fclose(f);
      unlink(ftmp1);
      }
   f = fopen(ftmp2,"rt");
   if (f != NULL)
   {
      fclose(f);
      unlink(ftmp2);
      }
   exit(-10);
   }

void main(argc, argv)
int argc;
char *argv[];
{
   char ssys[MAXSTR];
   char tstr1[MAXSTR];
   char tstr2[MAXSTR];
   char cfgname[MAXSTR];
   int cachesize;
   int pt;
   FILE *f;
   char *tmpdir;
   char *dictdir;
   int sortout = 1;

   /* setup */
   strcpy(ftmp1,"");
   strcpy(ftmp2,"");
#if defined(pyr) || defined(__TURBOC__)
   signal(SIGABRT, emergencyshutdown);
#endif
   signal(SIGINT, emergencyshutdown);
   signal(SIGTERM, emergencyshutdown); 
#ifdef __TURBOC__
   atexit(emergencyshutdown);
#endif
   prtderive = 0;
   prtroot = 0;
   strcpy(progname,argv[0]);

   /* make the temporary file name */
   tmpdir = getenv("TMP");		/* retrieve path from environment */
   if (tmpdir == NULL)			/* Suggested Mike O'Carroll */
	tmpdir = getenv("TEMP");	/* M. Castro 2/7/92 */

   if (tmpdir == NULL)
   	strcpy(ftmp1, "");
   else
   {
   	strcpy(ftmp1, tmpdir);
#ifdef __MSDOS__
	dosfix(ftmp1);
#endif
	if (strcmp(ftmp1,""))
	    if (strcmp(ftmp1+strlen(ftmp1)-strlen(SEPARATOR), SEPARATOR))
	    {					/* add a separator */
		strcat(ftmp1, SEPARATOR);
	    	}
	}

   strcat(ftmp1, ROOTNAME);
   strcpy(ftmp2, ftmp1);

   strcat(ftmp1,"1");
   strcat(ftmp1,"XXXXXX");
   mktemp(ftmp1);
   strcat(ftmp2,"2");
   strcat(ftmp2,"XXXXXX");
   mktemp(ftmp2);
   fout = fopen(ftmp1,"wt");
   if (fout == NULL)
   {
       errormesg("Unable to open temporary file. Aborting",-1);
       }

   /* startup */
   dictdir = getenv("SSPELL");		/* retrieve path from environment */
   if (dictdir == NULL)			/* Suggested Mike O'Carroll */
	strcpy(dictpath, DICT_PATH); 	/* M. Castro 2/7/92 */
   else
	strcpy(dictpath, dictdir);

#ifdef __MSDOS__
   dosfix(dictpath);
#endif
   /* if there is a path, and it does not end in a separator make it */
   if (strcmp(dictpath,""))
      if (strcmp(dictpath+strlen(dictpath)-strlen(SEPARATOR), SEPARATOR))
         strcat(dictpath, SEPARATOR); 	/* add a separator */

   rule[0] = NULL;
   indexarr[0] = NULL;
   dictionary[0] = NULL;
   sort[0] = NULL;
   stop[0] = NULL;
   
   strcpy(cfgname, dictpath);
   strcat(cfgname, CFGNAME);
   cfgload(cfgname);

   cachesize = CACHESIZE;

   pt = 1;
   while ((pt < argc) && (*(argv[pt]) == '-'))
   {
       if (!strcmp(argv[pt], "-c"))
       {
          pt++;
          if (pt == argc) usage();
          strcpy(cfgname,argv[pt]);
          cfgload(cfgname);
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-v"))
       {
          prtderive = 1;
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-u"))
       {
          sortout = 0;
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-x"))
       {
          prtroot = 1;
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-D"))
       {
          pt++;
          if (pt == argc) usage();
          strcpy(dictionary,argv[pt]);
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-R"))
       {
          pt++;
          if (pt == argc) usage();
          strcpy(rule,argv[pt]);
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-S"))
       {
          pt++;
          if (pt == argc) usage();
          strcpy(stop,argv[pt]);
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-I"))
       {
          pt++;
          if (pt == argc) usage();
          strcpy(indexarr,argv[pt]);
          pt++;
          continue;
          }
       if (!strcmp(argv[pt], "-C"))
       {
          pt++;
          if (pt == argc) usage();
          cachesize = atoi(argv[pt]);
          if (cachesize < 1) cachesize = 1;
          pt++;
          continue;
          }
       usage();
       }

   initcache(cachesize);
   initfile(dictionary);
   initroot(rule);
   initstop(stop);
   
   if (FAIL == readindex(indexarr))
   {
      buildindex();
      writeindex(indexarr);
      }
 
   /* check spelling for each file */
   if (pt < argc)
      while (pt < argc)
      {
          f = fopen(argv[pt],"rt");
          if (f == NULL)
          {
              fprintf(stderr,"Unable to open file: %s\n",argv[pt]);
              pt++;
              continue;
              }
          checkspell(f);
          fclose(f);
          pt++;
          }
   else
       checkspell(stdin);

   /* close down */
   closefile();
   fclose(fout);

   if (sortout)
   {
	/* We have made the wordlist now sort it using systems provided sort */
	strcpy(ssys, sort);
	strcat(ssys, " < ");
	strcat(ssys, ftmp1);
	strcat(ssys, " > ");
	strcat(ssys, ftmp2);
#ifdef __MSDOS__
	dosfix(ssys);
#endif
	system(ssys);
	unlink(ftmp1);

	/* Output preventing duplication */
	fout = fopen(ftmp2,"rt");
	strcpy(tstr2,"");
	while (!feof(fout))
	{
	    if (fgets(tstr1,MAXSTR-1,fout)==NULL)
	       break;
	    if (strcmp(tstr1, tstr2))
	       printf("%s",tstr1);
	    strcpy(tstr2, tstr1);
	    }
	fclose(fout);
	unlink(ftmp2);
	}
   else
   {
	/* output results as found */
	fout = fopen(ftmp1,"rt");
	while (!feof(fout))
	{
	    if (fgets(tstr1,MAXSTR-1,fout)==NULL)
	       break;
       	    printf("%s",tstr1);
	    }
	fclose(fout);
	unlink(ftmp1);
	}
   }

