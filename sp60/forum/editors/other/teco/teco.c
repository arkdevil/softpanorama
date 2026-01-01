/*  TECO - Context Editor

(C) COPYRIGHT 1986 by Y.N. Miles; ALL RIGHTS RESSERVED

	Description:

		This program implements a subset of the commands for the
		context editor TECO, which was developed at MIT in the
		early 1960s, and was supported on most of the earlier
		Digital Equipment machines (PDP-8, PDP-10, PDP-11).
		This program was based on the "PDP-11 Teco User's Guide",
		by Digital Equipment, 1980, Order Number DEC-11-UTECA-B-D,
		and was written by the author in utter *PANIC* when it was
		realized that Digital Equipment was quietly dropping the
		support for TECO in its MicroVax family of computers.
		By rewriting TECO in the popular portable programming
		language "C", the author hopes to be able to continue
		using TECO independent of Digital Equipment's corporate
		policies, and also hopes to be able to make it available
		to the many users who have been unfortunate enough not
		to have access to an Operating System which had a working
		version of the best non-visual text editor around...

	Instructions:

		This version is based on the "PDP-11 Teco Users Guide",
		published 1980 as order no "DEC-11-UTECA-B-D", from:

			TECO SIG,
			c/o DECUS, MR2-3/E55
			One Iron Way
			Marlboro, MA 01752

	Language:

		Microsoft "C" version 3.00

	License Agreement:

		All users are granted a limited license to make copies
		of this program, and to distribute them at will for
		non-commercial use, provided no fee or consideration
		is received without the express consent of the Author

			Y.N. Miles
			TRIUMF, U.B.C.
			4004 Wesbrook Mall
			Vancouver, B.C.
			Canada, V6T 2A3

			Phone (604) 222-1047
*/
#include <ctype.h>
#include <fcntl.h>
#include <io.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>

char bkname[128],bkpath[128],bktype[5]; /* Backup name,path,type */
char inname[128],inpath[128],intype[5]; /* Input  name,path,type */
char otname[128],otpath[128],ottype[5]; /* Output name,path,type */

FILE *in; /* Input  stream */
FILE *ot; /* Output stream */

char buffer[32001];/* Work buffer area */
int  bufptr=0     ;/* --> last in bfr  */
int  bufptx=0     ;/* --> char in bfr  */
int  bufsiz=32000 ;/* Size of work buf */

char getbuf[8193]; /* User keyboard buffer */
int  getptr=0    ; /* --> last in key bfr  */
int  getptx=0    ; /* --> char in key bfr  */
int  getsiz=8192 ; /* Characters in getbuf */

int adverb	;  /* Qualifier  for  verb */
int cancel	;  /* Non-zero if ^O typed */
int number	;  /* Value    for command */
int verb	;  /* Name     of  command */

main(argc,argv) /* Excized Teco Editor */
int argc;
char *argv[];
{
#include "teco.h"

	FILE *fopen();
	int abort();
	char *p,*q;

	fprintf(stderr,"TECO ver X1.04\n");

	if (argc ==1 ) {
		fprintf(stderr,"?NFI, No file for input\n\7");
                exit(1);
	} else {
		if (argc !=2 ) {
			fprintf(stderr,"? What does '%s",strupr(argv[2]));
			fprintf(stderr,"' mean ?\n\7");
			exit(1);
			}
		}
	p=strchr(argv[1],'=');
	if (!p) {
		strcpy(inname,strupr(argv[1]));
		q=strrchr(inname,'.');
		if (!q) strcat(inname,".");
		q=strrchr(inname,'.');
		strncpy(intype,q,4);
		*q='\0';
		strcpy(inpath,inname);
		strcat(inpath,intype);
		strcpy(otpath,inname);
		strcat(otpath,".TMP");
	} else {
		strcpy(inname,strupr(p+1));
		q=strrchr(inname,'.');
		if (!q) strcat(inname,".");
		q=strrchr(inname,'.');
		strncpy(intype,q,4);
		*q='\0';
		strcpy(inpath,inname);
		strcat(inpath,intype);
		strcpy(otname,strupr(argv[1]));
		q=strchr(otname,'=');
		*q='\0';
		q=strrchr(otname,'.');
		if (!q) strcat(otname,".");
		q=strrchr(otname,'.');
		strncpy(ottype,q,4);
		*q='\0';
		strcpy(otpath,otname);
		strcat(otpath,ottype);
			}
	if ((in = fopen(inpath,"r")) == NULL) {
			fprintf(stderr,"?FNF, File not found '%s'\n\7",inpath);
			exit(1);
		}
	setmode(fileno(in),O_BINARY);
	if ((ot = fopen(otpath,"w")) == NULL) {
			fprintf(stderr,"?FNC, File not created '%s'\n\7",otpath);
			exit(1);
		}
	setmode(fileno(ot),O_BINARY);

	signal(SIGINT,abort);		/* Enable trap */
	work();				/* Do the teco */
	signal(SIGINT,SIG_DFL);		/* Disabl trap */

	fclose(in);
	fclose(ot);
	if (!p) {
		strcpy(bkpath,inname);
		strcat(bkpath,".BAK");
		unlink(bkpath)       ; /* Ignore error */
		rename(bkpath,inpath);
		rename(inpath,otpath);
	}
}
