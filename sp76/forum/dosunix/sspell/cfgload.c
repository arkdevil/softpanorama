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

#include <stdio.h>
#include "strfn.h"
#include "config.h"
#include "stop.h"

/* fix up some slash problems with MS-DOS */
#ifdef __MSDOS__
extern void dosfix();
#endif

extern char dictpath[];
extern char dictionary[];
extern char rule[];
extern char indexarr[];
extern char sort[];
extern char stop[];

/* load options from configuration file */
void cfgload(cfgname)
char *cfgname;
{
   char cfgline[MAXSTR];
   FILE* cfgfile;
   char *key;
   char *value;

   if ( (cfgfile = fopen(cfgname,"r")) != (FILE *)NULL ) {
      /* obtain new defaults from config file */
      while (fgets(cfgline,MAXSTR,cfgfile)) {
         if (cfgline[0]=='#')
            continue;
         key = strtok(cfgline," \t\r\n\"'");
         if (key == (char *)NULL)
            continue;
         value = strtok((char *)NULL,"\t\r\n\"'");
         if (value == (char *)NULL) {
            fprintf(stderr,"No value for config option: %s\n",key);
            continue;
         }
         if (!strcmp(key, "DICT_PATH")) {
            strcpy(dictpath, value);   
            /* if there is a path, and it does not end in a separator make it */
            if ( strlen(dictpath) && 
                strcmp(dictpath+strlen(dictpath)-strlen(SEPARATOR), SEPARATOR))
               strcat(dictpath, SEPARATOR); 	/* add a separator */
#ifdef __MSDOS__
            dosfix(dictpath);
#endif
            }   
         else if (!strcmp(key, "DICTIONARY")) {
            if (strstr(value, SEPARATOR))
               strcpy(dictionary, value);   
            else {
               strcpy(dictionary, dictpath);
               strcat(dictionary, value);
               }
            }   
         else if (!strcmp(key, "INDEX")) {
            if (strstr(value, SEPARATOR))
               strcpy(indexarr, value);   
            else {
               strcpy(indexarr, dictpath);
               strcat(indexarr, value);
               }
            }   
         else if (!strcmp(key, "RULE")) {
            if (strstr(value, SEPARATOR))
               strcpy(rule, value);   
            else {
               strcpy(rule, dictpath);
               strcat(rule, value);
               }
            }   
         else if (!strcmp(key, "STOP")) {
            if (strstr(value, SEPARATOR))
               strcpy(stop, value);   
            else {
               strcpy(stop, dictpath);
               strcat(stop, value);
               }
            }   
         else if (!strcmp(key, "SORT")) {
            strcpy(sort, value);
            }
         else
            fprintf(stderr,"Unknown config option: %s %s\n",key,value);
         }
      fclose(cfgfile);   
      }
      if (strlen(dictionary)==0) {
      	strcpy(dictionary, dictpath);
      	strcat(dictionary, DICTIONARY);
      }
      if (strlen(indexarr)==0) {
      	strcpy(indexarr, dictpath);
      	strcat(indexarr, INDEX);
      }
      if (strlen(rule)==0) {
      	strcpy(rule, dictpath);
      	strcat(rule, RULE);
      }
      if (strlen(stop)==0) {
      	strcpy(stop, dictpath);
      	strcat(stop, STOP);
      }
      if (strlen(sort)==0) {
      	strcpy(sort, SORT);
      }
#ifdef __MSDOS__
      dosfix(dictionary);
      dosfix(rule);
      dosfix(indexarr);
      dosfix(sort);
      dosfix(stop);
#endif
}
