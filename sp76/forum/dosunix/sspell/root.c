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

/* determine the root of a word using the rules in the rule file */

#include <stdio.h>
#if !defined(pyr)
#include <stdlib.h>
#endif
#include "strfn.h"
#include "root.h"
#include "error.h"
#include "utility.h"
#include "string.h"

#define MAXSTR 128
#define PRE 0
#define POST 1

typedef struct rule
{
    char *presuf;             /* prefix / suffix */
    char *required;           /* character string  required at end of word */
    char *forbid;             /* character string forbidden at end of word */
    char *del;                /* characters to be deleted from end of word */
    struct rule *next;
    } RULE;

RULE *prefixlist;
RULE *suffixlist;

void badline(lno)
int lno;
{
   fprintf(stderr, "Warning: line %d in the rule file is badly formed\n",
           lno);
   }

void memfail()
{
   errormesg("Error: Out of Memory! Terminating",-3);
   }

/* read the rules file */
/* this file is made up of lines of the form: 
/*     pre|post <prefix/suffix> <required> <forbiden> <delete> */
/* Any blank fields should contain a single "-" all fields separated by */
/* white space. A "#" in the first character position indicates a comment */

void initroot(file)
char *file;
{
    FILE *f;
    char instr[MAXSTR];
    char *token;
    int lno;
    char *presuf;             /* prefix / suffix */
    char *required;           /* character string  required at end of word */
    char *forbid;             /* character string forbidden at end of word */
    char *del;                /* characters to be deleted from end of word */
    int prepost;
    RULE *newitem;
    RULE *prefixlast;
    RULE *suffixlast;

    prefixlist = NULL;
    suffixlist = NULL;
   
    f = fopen(file,"rt");
    lno = -1;
    while (!feof(f))
    {
       if (fgets(instr,MAXSTR-1,f)==NULL)
          break;
       lno++;
       if (instr[0] == '#') 
          continue;                    /* handle comments */
       token = strtok(instr," \t\n");
       if (!strcmp(token, "pre")) 
           prepost = PRE;
       else if (!strcmp(token, "post")) 
           prepost = POST;
       else
       {
           badline(lno);
           continue;
           }

       /* deal with the rest of line */
       token = strtok(NULL," \t\n");
       if (token == NULL) 
       {
          badline(lno);
          continue;
          }
       if (!strcmp(token,"-")) 
           presuf = NULL;
       else
       {
           presuf = (char *) malloc(strlen(token)+1); 
           if (presuf == NULL) memfail();
           lstrcpy(presuf,token);
           }
       token = strtok(NULL," \t\n");
       if (token == NULL)
       {
          badline(lno);
          continue;
          }
       if (!strcmp(token,"-")) 
           required = NULL;
       else
       {
           required = (char *) malloc(strlen(token)+1); 
           if (required == NULL) memfail();
           lstrcpy(required,token);
           }
       token = strtok(NULL," \t\n");
       if (token == NULL) 
       {
          badline(lno);
          continue;
          }
       if (!strcmp(token,"-")) 
           forbid = NULL;
       else
       {
           forbid = (char *) malloc(strlen(token)+1); 
           if (forbid == NULL) memfail();
           lstrcpy(forbid,token);
           }
       token = strtok(NULL," \t\n");
       if (token == NULL) 
       {
          badline(lno);
          continue;
          }
       if (!strcmp(token,"-")) 
           del = NULL;
       else
       {
           del = (char *) malloc(strlen(token)+1); 
           if (del == NULL) memfail();
           lstrcpy(del,token);
           }
       newitem = (RULE *) malloc(sizeof(RULE));
       if (newitem == NULL) memfail();
       (*newitem).presuf = presuf;
       (*newitem).required = required;
       (*newitem).forbid = forbid;
       (*newitem).del = del;
       (*newitem).next = NULL;
       if (prepost == PRE)
       {
           if (prefixlist == NULL)
           {
              prefixlist = newitem;
              prefixlast = newitem;
              }
           else
           {
              (*prefixlast).next = newitem;
              prefixlast = newitem;
              }
           }
       else
       {
           if (suffixlist == NULL)
           {
              suffixlist = newitem;
              suffixlast = newitem;
              }
           else
           {
              (*suffixlast).next = newitem;
              suffixlast = newitem;
              }
           }
       }
    fclose(f);
    }

int compend(a, b)
char *a;
char *b;
{
   char *sstr;

   sstr = a+strlen(a)-strlen(b);
   if (!stricmp(sstr,b))
       return(1);
   return(0);    
   }

/* determine the root of a given word */
int prefix(in, outlst)
char *in;
WORDLST **outlst;
{
   RULE *pt;
   char *sstr;
   int idx;
   int outflg;
   WORDLST *newitem;

   *outlst = NULL;
   outflg = 0;

   pt = prefixlist;
   while (pt != NULL)
   {
      if (!strnicmp(pt->presuf, in, strlen(pt->presuf)))
      { 
         outflg = 1;
         in += (strlen(pt->presuf));
         /* add it to the output list */
         newitem = (WORDLST *) malloc (sizeof(WORDLST));
         newitem->prefix = NULL;
         newitem->suffix = NULL;
         if (newitem == NULL) 
         {
            memfail();
            } 
         newitem->word = (char *) malloc(strlen(in)+1);
         if (newitem->word == NULL) 
         {
            memfail();
            } 
         lstrcpy(newitem->word, in);
         newitem->prefix = (char *) malloc(strlen(pt->presuf)+2);
         if (newitem->prefix == NULL) 
         {
            memfail();
            } 
         lstrcpy(newitem->prefix, pt->presuf);
         strcat(newitem->prefix, "+");
         newitem->next = *outlst;
         *outlst = newitem;
         }
      pt = pt->next;
      }
   if (outflg) return(1);
   return(0);
   }

int suffix(in, outlst)
char *in;
WORDLST **outlst;
{
   RULE *pt;
   char *sstr;
   int idx;
   char buf[MAXSTR];
   char out[MAXSTR];
   int flag;
   int outflg;
   WORDLST *newitem;
   char *hold;

   *outlst = NULL;
   outflg = 0;

   pt = suffixlist;
   while (pt != NULL)
   {
      idx = strlen(in)-strlen(pt->presuf);
      if (idx < 0)
      {
          pt = pt->next;
          continue;        /* if it is negative there is no point */
          }
      sstr = in+idx;
      if (stricmp(sstr,pt->presuf)) 
      {
         pt = pt->next;
         continue; /* no match with ending so forget it */
         }
      lstrcpy(out,in);                 /* let us work on it */
      *(out+idx) = NULL; /* delete the matching ending */
      if (pt->del != NULL)            /* needed because of suns */
         strcat(out,pt->del);            /* add on any deleted bits */
      if (pt->required != NULL)
      {
          lstrcpy(buf,pt->required);
          flag = 0;
          sstr = strltok(buf," ,",&hold);
          while (sstr != NULL)
          {
             if (compend(out,sstr)) flag = 1;
             sstr = strltok(NULL, " ,",&hold);
             } 
          }
      else
          flag = 1;  /* nothing required so better say OK unless forbidden */
      if (pt->forbid != NULL)
      {
          lstrcpy(buf,pt->forbid);
          sstr = strltok(buf," ,",&hold);
          while (sstr != NULL)
          {
             if (compend(out,sstr)) flag = 0;
             sstr = strltok(NULL, " ,",&hold);
             } 
          }
      if (flag) 
      {
         outflg = 1; /* it matched! */
         /* add it to the output list */
         newitem = (WORDLST *) malloc (sizeof(WORDLST));
         newitem->prefix = NULL;
         newitem->suffix = NULL;
         if (newitem == NULL) 
         {
            memfail();
            } 
         newitem->word = (char *) malloc(strlen(out)+1);
         if (newitem->word == NULL) 
         {
            memfail();
            } 
         lstrcpy(newitem->word, out);
         if (pt->del ==NULL)
         {
            newitem->suffix = (char *) malloc(strlen(pt->presuf)+2);
            if (newitem->suffix == NULL) 
            {
               memfail();
               } 
            lstrcpy(newitem->suffix, "+");
            strcat(newitem->suffix, pt->presuf);
            }
         else
         {
            newitem->suffix = (char *) malloc(strlen(pt->presuf)+3+strlen(pt->del));
            if (newitem->suffix == NULL) 
            {
               memfail();
               } 
            lstrcpy(newitem->suffix, "-");
            strcat(newitem->suffix, pt->del);
            strcat(newitem->suffix, "+");
            strcat(newitem->suffix, pt->presuf);
            }
         newitem->next = *outlst;
         *outlst = newitem;
         }
      pt = pt->next;
      }
   if (outflg) return(1);
   return(0);
   }

void root(in, outlst)
char *in;
WORDLST **outlst;
{
   WORDLST *prelst;
   WORDLST *suflst;
   WORDLST *end;
   char prefbuf[MAXSTR];

   *outlst = NULL;
   end = NULL;
   /* check if there is a set of prefixes that fits */
   if (prefix(in, &prelst))
   {
      /* add it to the output list */
      *outlst = prelst;
      end = *outlst;
      while (end->next != NULL)
      {
          end = end->next;           /* trace to end of list */
          }
      while (prelst != NULL)
      {
         lstrcpy(prefbuf, prelst->prefix);
         if (suffix(prelst->word, &suflst))
         {
            end->next = suflst; 
            while (end->next != NULL)
            {
                if ((end->next->prefix = (char *) malloc(strlen(prefbuf)+1)) == NULL)
                {
                   memfail();
                   }
                else
                {
                   lstrcpy(end->next->prefix, prefbuf);
                   }
                end = end->next;           /* trace to end of list */
                }
            }
         prelst = prelst->next;
         }
      }
   if (suffix(in, &suflst))
   {
      if (*outlst != NULL)
         end->next = suflst; 
      else
         *outlst = suflst;
      }
   }

void destroy(a)
WORDLST *a;
{
   WORDLST *b;
   while (a != NULL)
   {
       if (a->word != NULL) free(a->word);
       if (a->prefix != NULL) free(a->prefix);
       if (a->suffix != NULL) free(a->suffix);
       b = a;
       a = a->next;
       free(b);
       }
   }

/* debugging code */

void prtrules(a)
RULE *a;
{
   while (a!=NULL)
   {
       printf("item: %s required: %s forbidden: %s delete %s\n",
               a->presuf, a->required, a->forbid, a->del);
       a = a->next;
       }
   }

