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

#include "check.h"
#include "cache.h"
#include "file.h"
#include <stdio.h>
#include "config.h"
#include "strfn.h"
#include "root.h"
#include "utility.h"
#include "stop.h"

extern FILE *fout;
extern int prtderive;
extern int prtroot;

int isupper(a)
char a;
{
   if (('A' <= a) && (a <= 'Z')) return(1);
   return(0);
   }

int isnumber(a)
char *a;
{
    while (*a != NULL)
    {
        if (!(('0' <= *a) && (*a <= '9'))) return (0);
        a++;
        }
    return(1);
    }

int chkcaps(dict, test)
char *dict;
char *test;
{
   /* check that any capitalized letter in the dictionary is matched */
   /* by a capitalized letter in the word */
   while (*dict != NULL)
   {
      if ((isupper(*dict)) && (*dict != *test)) 
         return(0);
      dict++;
      test++;
      }
   return(1);
   }

int checkword(word)
char *word;
{
   char indict[MAXSTR];

   if (word == NULL)
      return(0); /* fail */
   if (searchcache(word,indict))
   {
       /* if it is not an exact match - check a bit more closely */
       if (strcmp(indict,word))
          if (!chkcaps(indict,word)) 
             return(0);
       }
   else
   {
       if (searchfile(word,indict))
       {
           /* something close is in the file put it in the cache */
           addtocache(indict);
           if (strcmp(indict,word))
              if (!chkcaps(indict,word)) 
                 return(0);
           }
       else
           return(0);
       }
   return(1);
   }

void dump(a)
WORDLST *a;
{
   while (a != NULL)
   {
      fprintf(fout,"=%s\n",a->word); 
      a = a->next;
      }
   }

int checkgroup(word)
char *word;
{
   WORDLST *a;
   WORDLST *b;

   /* earliest opportunity to check if it is a number after looking for */
   /* hyphens */

   if (isnumber(word)) return(1);
   if (checkword(word)) return(1);  /* try the dictionary first */
   if (instop(word)) 		    /* we know this is not a word. Give up */
	return(0);

   /* the word is not in the dictionary try to find root */

   root(word, &a); 
   b = a;
   while (a != NULL)
   {
      if (checkword(a->word)) 
      {
         if (prtderive)
         {
            if ((a->prefix != NULL) && (a->suffix != NULL)) fprintf(fout,"%s%s%s\n",
                a->prefix, a->word, a->suffix);
            else if (a->prefix != NULL) fprintf(fout,"%s%s\n",
                a->prefix, a->word);
            else if (a->suffix != NULL) fprintf(fout,"%s%s\n",
                a->word, a->suffix);
            }
         if (prtroot) 
            dump(b);
         destroy(b);
         return(1);  /* found it! */
         }
      a = a->next;
      }
   destroy(b);
   return(0);
   }

int checkhyphen(a)
char *a;
{
   char *hold;
   char *token;
   char cpstr[MAXSTR];

   if (checkgroup(a)) return(1);
   strcpy(cpstr, a);
   token = strltok(cpstr,"-",&hold);
   while (token != NULL)
   {
       if (!checkgroup(token)) return(0);
       token = strltok(NULL,"-",&hold);
       } 
   return(1);
   }

void checkspell(f)
FILE *f;
{
   char instr[MAXSTR];
   char *token;
   char *hold;

   while (!feof(f))
   {
       if (fgets(instr,MAXSTR-1,f)==NULL)
          break;
       token = strltok(instr,SEPSTR,&hold); 
       while (token != NULL)
       {
           if (!checkhyphen(token))
           {
               fprintf(fout,"%s\n",token);
               }
           token = strltok(NULL,SEPSTR,&hold); 
           }
       }
   }
