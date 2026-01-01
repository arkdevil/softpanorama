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
/* Contributors: mao@physics.su.oz.au                               */
/*                                                                  */
/* **************************************************************** */

/* This set of routines accesses and indexes the dictionary */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "strfn.h"
#if !defined(pyr)
#include <stdlib.h>
#endif
#include "iofn.h"
#include "file.h"
#include "error.h"
#include "config.h"
#include "utility.h"

struct indexelm
{
   char word[HASHWID];
   unsigned long location;
   };

struct indexelm findx[IDXSIZ];

FILE *f;

void initfile(dict)
char *dict;
{
   f=fopen(dict,"rt");
   if  (f == NULL)
   {
	fprintf(stderr, "Unable to open dictionary: %s\n", dict);
	exit(1);
	}
   }

void closefile()
{
   fclose(f);
   }

/* build the index */
void buildindex()
{
    char instr[MAXSTR];
    char prev[MAXSTR];
    unsigned long lastprev;
    unsigned long lastinstr;
    unsigned long filesize;
    long i;
    long j;
  
    /* initialise the index array */ 
    for (i=0; i < IDXSIZ; i++)
      findx[i].location = 0; 

    /* put in the first entry, it has to be zero */
    findx[0].location = ftell(f);
    fgets(instr,MAXSTR-1,f);
    strcpy(prev,instr);
    i = 1;

    /* find the file length */
    fseek(f, 0l, SEEK_END);
    filesize = ftell(f);

    /* put the pointer back */
    fseek(f, 0l, SEEK_SET);

    /* find the other entries */
    while (!feof(f))
    {
       lastinstr = ftell(f);
       if (fgets(instr,MAXSTR-1,f)==NULL)
          break;
       if (stricmp(instr,prev)<0)
       {
          errormesg("Error: In dictionary order! Re-sort dictionary",-2); 
          exit(1);
          }
       if ((lastinstr*IDXSIZ)/ filesize > i)
       {
          strncpy(findx[i].word,instr,HASHWID-1);
          findx[i].location = lastinstr;
          i++;
          }
       strcpy(prev,instr);
       }
    /* guarantee that the list is full */
    i--;     /* incremented so we decrement it */
    for (j=i; j < IDXSIZ; j++)
    {
        /* copy the last good record to pad */
        findx[j].location = findx[i].location;
        strcpy(findx[j].word, findx[i].word);  
        }
    clearerr(f);
    } 

int readindex(indx)
char *indx;
{
   FILE *fi;
   time_t time;
   struct stat statbuf;
   unsigned long t;
 
   fi = fopen(indx,"rb");
   if (fi == NULL)
      return(FAIL);
   /* check that the modify times are concordant */
   fread(&time,sizeof(time_t),1,fi);
   fstat(fileno(f), &statbuf);
   if (time != statbuf.st_mtime)
   {
      fclose(fi);                     /* Mike O'Carroll reminded me of the */
      return(FAIL);                   /* need to close files on exiting this */
      }                               /* routine. M. Castro 4/3/92 */
   fread(&t,sizeof(long),1,fi);
   if (t != IDXSIZ) 
   {
      fclose(fi);
      return(FAIL);
      }
   fread(&t,sizeof(long),1,fi);
   if (t != HASHWID) 
   {
      fclose(fi);
      return(FAIL);
      }
   fread(findx,sizeof(struct indexelm),IDXSIZ,fi);
   fclose(fi);
   return(SUCCESS);
   } 
   
void writeindex(indx)
char *indx;
{
   FILE *fi;
   struct stat statbuf;
   unsigned long t;
 
   fi = fopen(indx,"wb");
   if (fi == NULL)
   {
       fprintf(stderr, "Cannot create index: %s\n",indx);
       return;
       } 
   /* set the modify time and write the file */
   fstat(fileno(f), &statbuf);
   fwrite(&(statbuf.st_mtime),sizeof(time_t),1,fi);
   t = IDXSIZ;
   fwrite(&t,sizeof(long),1,fi);
   t = HASHWID;
   fwrite(&t,sizeof(long),1,fi);
   fwrite(findx,sizeof(struct indexelm),IDXSIZ,fi);
   fclose(fi);
   } 

int searchfile(match, entry)
char *match;
char *entry;
{
   char instr[MAXSTR];
   char *stripped;
   long i;
   /* bsearch additions */
   long up;
   long down;
   long avr;
   int cmp;

   /* search through the list if something is there then fseek it */
/*   i = 0;
   while ((i < IDXSIZ) && (strnicmp(findx[i].word, match,HASHWID-1) <= 0)) 
   {
      i++;
      }
   i--; */   /* subtract one to look at the right location */

   /* bsearch */  
   up = IDXSIZ;
   down = 0;
   while (1)
   {
       avr = (up+down)/2;
       cmp =  strnicmp(findx[avr].word, match, HASHWID-1);
       if (!cmp)
       {
           i = avr - 1;
           break;
           }
       if (up - down < 2)
       {
           i = down;
           break;
           }
       if (cmp < 0)
       {
           down = avr;
           }
       if (cmp > 0)
       {
           up = avr;
           }
       }
   /* catch alls - the second one is not really needed */
   if (i < 0)
      i = 0; 
   if (i > IDXSIZ)
      i = IDXSIZ;
   
   fseek(f,findx[i].location,SEEK_SET);

   while (!feof(f))
   {
       if (fgets(instr,MAXSTR-1,f)==NULL)
	  break;
       stripped = strip(instr,"\r\n");
       if (stricmp(stripped, match) > 0)
	  return(FAIL);
       if (!stricmp(stripped, match))
       {
	   /* it matches send back the matching entry */
	   strcpy(entry, stripped);
	   return(SUCCESS);
	   }
       }
   clearerr(f);
   return(FAIL);
   }
