/*--------------------------------------------------------------------------*
 *      FFF.COM - Fast-File-Find, a fully public domain program to search   *
 *        for files on one or more disks (functionally similar to           *
 *                the  familiar  "WHERE" program.  FFF  will also  search   *
 *        inside of  ARC, PAK, ZIP, ZOO, LZH and  ARJ archives to           *
 *        the first level.                                                  *
 *                                                                          *
 *      Version:  3.6.0                                                     *
 *      Date:     June 12, 1991                                             *
 *      Author:   Don A. Williams & Peter Knoerrich & Martin Rausche        *
 *                                                                          *
       *********************  NOTICE  ************************
       *  Contrary to the current trend in MS-DOS  software  *
       *  this  program,  for whatever it is worth,  is NOT  *
       *  copyrighted (with the exception  of  the  runtime  *
       *  library  from  the C compiler)!  The program,  in  *
       *  whole or in part,  may  be  used  freely  in  any  *
       *  fashion or environment desired.  If you find this  *
       *  program  to  be  useful  to you,  do NOT send any  *
       *  contribution to the author;  in the words of Rick  *
       *  Conn,   'Enjoy!'   However,   if   you  make  any  *
       *  improvements,  I would enjoy receiving a copy  of  *
       *  the  modified source.  I can be reached,  usually  *
       *  within 24  hours,  by  messages  on  any  of  the  *
       *  following Phoenix, AZ systems (the Phoenix systems *
       *  can all be reached through StarLink node #9532):   *
       *                                                     *
       *     The Tool Shop BBS       [PCBOARD] [PC-Pursuit]  *
       *         (602) 279-2673   1200/2400/9600 bps         *
       *     Technoids Anonymous     [PCBOARD]               *
       *         (602) 899-4876   300/1200/2400 bps          *
       *         (602) 899-5233                              *
       *         (602) 786-9131                              *
       *     Inn On The Park         [PCBOARD]               *
       *         (602) 957-0631   1200/2400/9600 bps         *
       *     Pascalaholics Anonymous [WBBS]                  *
       *         (602) 484-9356   1200/2400 bps              *
       *                                                     *
       *  or:                                                *
       *     Blue Ridge Express     [RBBS] Richmond, VA      *
       *         (804) 790-1675   2400 bps [StarLink #413]   *
       *                                                     *
       *     The Lunacy BBS         [PCBOARD] Van Nuys, CA   *
       *         (805) 251-7052   2400/9600 [StarLink 6295]  *
       *         (805) 251-8637   2400/9600 [StarLink 6295]  *
       *                                                     *
       *  or:                                                *
       *     GEnie, mail address: DON-WILL                   *
       *     CompuServ:           75410,543                  *
       *                                                     *
       *  Every  effort  has  been  made to avoid error and  *
       *  moderately extensive testing has  been  performed  *
       *  on  this  program,  however,  the author does not  *
       *  warrant it to be fit for any  purpose  or  to  be  *
       *  free  from  error and disclaims any liability for  *
       *  actual or any other damage arising from  the  use  *
       *  of this program.                                   *
       *                                                     *
       *  ARJ  Handling added and  a lot of  bugs fixed  by  *
       *  Peter Knoerrich and Martin Rausche.                *
       *  We can be reached on by messages on Internet:      *
       *                                                     *
       *  EMail:                                             *
       *   prknoerr@faui41.informatik.uni-erlangen.de        *
       *   mnrausch@immd4.informatik.uni-erlangen.de         *
       *                                                     *
       *  (These EMail addresses can change, because we are  *
       *  students of Computer Science in Erlangen/Germany)  *
       *******************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <dos.h>
#include <dir.h>
#include <conio.h>
#include <stddef.h>
#include <stdarg.h>
#include <io.h>
#include <conio.h>

#define MAIN

#define VERSION "Version 3.6.0"
#define VER_DATE "June 12, 1991"

#define FIND_FIRST(Name,Block,Attrib) findfirst(Name, Block, Attrib)
#define FIND_NEXT(Block) findnext(Block)

#define DIR_ENTRY ffblk	   /* Name of the directory entry structure */
#define D_ATTRIB ff_attrib /* Attribute filed in directory entry    */
#define D_TIME ff_ftime	   /* Time field in directory entry	        */
#define D_DATE ff_fdate	   /* Date field in directory entry         */
#define D_SIZE ff_fsize	   /* File size field in directory entry    */
#define D_NAME ff_name	   /* File name field in directory entry    */

#define A_RDONLY FA_RDONLY /* Read only attribute mask              */
#define A_HIDDEN FA_HIDDEN /* Hidden attribute mask                 */
#define A_SYSTEM FA_SYSTEM /* System attribute mask                 */
#define A_VOLID FA_LABEL   /* Volume Label attribute mask           */
#define A_DIREC FA_DIREC   /* Subdirectory attribute mask           */
#define A_ARCH FA_ARCH	   /* Archived attribute mask               */

#include "fff.h"
#include "queue.h"
#include "arc.h"
#include "zip.h"
#include "zoo.h"
#include "lha.h"
#include "arj.h"


void            WalkTree (QUE_DEF * Q);
int             SearchQ (char *Str);
int             Match (char *Str, char *Pat);
void            PrtVerbose (char *Path, char *Name,
                            DOS_FILE_TIME * Time,
                            DOS_FILE_DATE * Date, long Size);
void            Usage (void);
void            ChkPage (void);

void            ErrorExit (char *Format,...);
void            GetProgName (char *Name, char *argv);


char            Path[65];     /* Current directory path to search      */
char            T_Path[65];   /* Temporary directory path to search    */
char            Temp[66];     /* Temporary working storage             */
char            V_Name[14];
char            V_Path[66];

char            CurDir[67];    /* Full path of the current directory    */
unsigned long   Position;
char            ProgName[9];   /* File name of this program             */

int             Spaced = 0;    /* Indicates if blank line separator     */
int             Lnno = 1;      /* Line count for paged output           */
int             TotalFiles = 0;/* Total files processed                 */
int             TotalMatch = 0;/* Count of all files matched            */

ARC_TYPE        ArcType;

struct Archives {          /* Structure to identify archive files       */
	char            Ext[4];	   /* processed by Extent                   */
	ARC_TYPE        Type;
	}               Arcs[7] = {
		{"ARC", arc},
		{"PAK", pak},
		{"ZIP", zip},
		{"ZOO", zoo},
		{"LZH", lzh},
		{"ARJ", arj},
		{"", none}
		};

int             S[7][3] = {
	{0, 0, 0},				  	/* Arc File Stats */
	{0, 0, 0},					/* Pak File Stats */
	{0, 0, 0},					/* Zip File Stats */
	{0, 0, 0},					/* Zoo File Stats */
	{0, 0, 0},					/* Lzh File Stats */
	{0, 0, 0},					/* Arj File Stats */
	{0, 0, 0} 					/* Dummy          */
	};

/*---  Option Switches  --- */

int             ArcSwt = 1;     /* Search inside of archives - default ON   */
int             PageSwt = 0;    /* Paginate output - default OFF            */
int             VerboseSwt = 0; /* Verbose out put - default OFF            */
int             QuietSwt = 0;   /* Supress stats   - default OFF            */
int             DateSwt = 0;    /* International date formaat - default OFF */
int             UsDateSwt = 0;  /* US date format - defualt OFF             */
int             CaseSwt = 0;    /* Output in lower case -default OFF        */

/*---  End Option Switches  --- */


char           *Legend[] = {
	 "ARC", "PAK", "ZIP", "ZOO", "LZH", "ARJ", "NONE", ""
	};

char            Devices[16] = "";

QUE_DEF         PatQue;

void main (int argc, char *argv[])
{
   int  CurDisk, i;
   char *p, *pe, *p2, *Temp;

   GetProgName(ProgName, argv[0]);
   fprintf(stderr, "%s: FastFileFind - %s: %s\n\n", ProgName,
           VERSION, VER_DATE);
   InitQueue(&PatQue);
   CurDisk=getdisk();
   CurDir[0] = (char) (CurDisk + 'A');
   CurDir[1] = ':';
   CurDir[2] = '\\';
   getcurdir(CurDisk + 1, CurDir + 3);
   strupr(CurDir);
   strcpy(Path, "C:\\");
   p = getenv("FFF");

/* Interpret the Environment Variable, if any				    */

   if (p != NULL)
   {
      Temp = malloc(strlen(p) + 1);
      strcpy(Temp, p);
      p = Temp;
      while ( (p != NULL) && (*p != '\0') )
      {
         pe = &p[strspn(p, " ")];
         if (*pe == '\0') break;
         p = pe;
         if ((pe = strchr(p, ' ')) != NULL) *pe++ = '\0';
         if (*p != '-')
         {
            if ((p2 = strchr(p, ':')) != NULL) *p2 = '\0';
               strcpy(Devices, p);
               p = pe;
         }
         else
         {
            while (*++p != '\0') switch (tolower(*p))
            {
               case 'a':
                  ArcSwt ^= ON;
                  break;
               case 'v':
                  VerboseSwt ^= ON;
                  break;
               case 'p':
                  PageSwt ^= ON;
                  break;
               case 'q':
                  QuietSwt ^= ON;
                  break;
               case 'f':
                  DateSwt = ON;
                  if (UsDateSwt) UsDateSwt = OFF;
                  break;
               case 'u':
                  UsDateSwt = ON;
                  if (DateSwt) DateSwt = OFF;
                  break;
               case 'c':
                  CaseSwt ^= ON;
                  break;
               default:
                  fprintf(stderr, "Invalid option in Environment: %c\n", *p);
                  fprintf(stderr, "    Ignored.\n");
                  break;
            }
         }
      }
      free(Temp);
   }

/* If no devices in Environment Variable, make default current disk	    */

   Devices[0] = '\0';

/* Interpret Command Line arguments					    */

   if (argc < 2) Usage();
   for (i = 1; i < argc; ++i)
   {
      if (argv[i][0] == '-')
      {
         for (p = &argv[i][1]; *p != '\0'; ++p)
         switch (tolower(*p))
         {
            case 'a':
               ArcSwt ^= ON;
               break;
            case 'v':
               VerboseSwt ^= ON;
               break;
            case 'p':
               PageSwt ^= ON;
               break;
            case 'q':
               QuietSwt ^= ON;
               break;
            case 'f':
               DateSwt ^= ON;
               if (UsDateSwt) UsDateSwt = OFF;
               break;
            case 'u':
               UsDateSwt ^= ON;
               if (DateSwt) DateSwt = OFF;
               break;
            case 'c':
               CaseSwt ^= ON;
               break;
            default:
               fprintf(stderr, "Invalid argument: %c\n", argv[i][1]);
               Usage();
               break;
         }
      }
      else
      {
         p = argv[i];
         strupr(p);
         if ((p2 = strchr(p, ':')) != NULL)
         {
            *p2++ = '\0';
            strcat(Devices, p);
            p = p2;
            Enque(&PatQue, p);
         }
         else if ((p2 = strrchr(p, '\\')) != NULL) strcpy(Path, p);
              else Enque(&PatQue, p);
      }
   }

   if (Devices[0] == '\0')
   {
      Devices[0] = (char) (CurDisk + 'A');
      Devices[1] = '\0';
   }
   else
   {
      i = 1;
      while (i<strlen(Devices))
      {
         if (strchr(Devices,Devices[i])<Devices+i)
            strcpy(Devices+i,Devices+i+1);
         else
            i++;
      }
   }


/* This does the work by walking the directory structure for each specified */
/* disk									    */

   p = Devices;
   while (*p != '\0')
   {
      strcpy(T_Path, Path);
      T_Path[0] = *p++;
      WalkTree(&PatQue);
   }

/* Display statistics							    */

   if (!QuietSwt)
   {
      if (PageSwt) ChkPage();
      if (!Spaced) printf("\n");
      printf("Total Files = %6d  Total Matched Files = %d\n", TotalFiles, TotalMatch);
      for (i = 0; Legend[i][0] != '\0'; ++i)
      {
         if (S[i][0] != 0)
         {
            printf("\n%s Files  = %6d  ", Legend[i], S[i][0]);
            if (ArcSwt) printf("%sed Files = %6d %s Matches = %4d",
                                 Legend[i], S[i][1], Legend[i],S[i][2]);
         }
      }
      printf("\n");
   }
}

/*----------------------------------------------------------------------*/
/* WalkTree is a recursive routine that walks the directory structure	*/
/* specifed by the external T_Path.  It bypasses Volume IDs and builds	*/
/* a linked list queue of directories that is processed after all of	   */
/* the file entries have been processed.                                */

void WalkTree (QUE_DEF *Q)
{
   extern int       VerboseSwt, CaseSwt, Spaced;
   extern struct    Archives Arcs[7];

   int              Status, i;
   char		        Reply;
   QUE_DEF          Direc;
   QUE_ENTRY        *t, *u;
   char             *p;
   struct DIR_ENTRY DirBlk;    /* Directory Entry structure   */
   DOS_FILE_TIME    Time;
   DOS_FILE_DATE    Date;

   InitQueue(&Direc);
   strcat(T_Path, "*.*");
   Status = FIND_FIRST(T_Path, &DirBlk, 0xFF);
   *(strrchr(T_Path, '\\') + 1) = '\0';
   while (!Status)
   {

      if (kbhit())
      {
         Reply = getch();
         if (Reply == 0x1b)
         {
            fprintf(stderr, "    FFF terminated by user request.\n");
            exit(1);
         }
      }

      if ((DirBlk.D_ATTRIB & A_VOLID) != 0)
      {                                         /* Bypass Volume Label  */
         Status = FIND_NEXT(&DirBlk);
         continue;
      }
      if ((DirBlk.D_ATTRIB & A_DIREC) != 0)
      {                                        /* Process subdirectory */
         if (DirBlk.D_NAME[0] != '.')
         {
            Enque(&Direc, DirBlk.D_NAME);
         }
      }
      else
      {                                                /* Process file entry    */
         ++TotalFiles;
         if ( SearchQ(DirBlk.D_NAME) )
         {
            ++TotalMatch;
            if (PageSwt) ChkPage();
            strcpy(V_Name, DirBlk.D_NAME);
            strcpy(V_Path, T_Path);
            if (CaseSwt == ON)
            {
               strlwr(V_Name);
               strlwr(V_Path);
            }
            if (VerboseSwt)
            {
               fputs("  ", stdout);
               Time.u = DirBlk.D_TIME;
               Date.u = DirBlk.D_DATE;
               PrtVerbose(V_Path, V_Name, &Time, &Date,
                          DirBlk.D_SIZE);
            }
            else
            {
               fputs(V_Path, stdout);
               puts(V_Name);
            }
            ++Lnno;
            Spaced = 0;
         }

/* Check the file name for the various archive identifying extensions	    */

         if ((p = strchr(DirBlk.D_NAME, '.')) != NULL)
         {
            for (i = 0; Arcs[i].Ext[0] != '\0' && stricmp(p + 1, Arcs[i].Ext); ++i);
            ArcType = Arcs[i].Type;
            switch (ArcType)
            {
               case arc:
               case pak:
                  ++S[ArcType][0];
                  if (ArcSwt)
                  {
                     strcat(T_Path, DirBlk.D_NAME);
                     DoArc(T_Path);
                     *(strrchr(T_Path, '\\') + 1) = '\0';
                  }
                  break;
               case zip:
                  ++S[ArcType][0];
                  if (ArcSwt)
                  {
                     strcat(T_Path, DirBlk.D_NAME);
                     DoZip(T_Path);
                     *(strrchr(T_Path, '\\') + 1) = '\0';
                  }
                  break;
               case zoo:
                  ++S[ArcType][0];
                  if (ArcSwt)
                  {
                     strcat(T_Path, DirBlk.D_NAME);
                     DoZOO(T_Path);
                     *(strrchr(T_Path, '\\') + 1) = '\0';
                  }
                  break;
               case lzh:
                  ++S[ArcType][0];
                  if (ArcSwt)
                  {
                     strcat(T_Path, DirBlk.D_NAME);
                     DoLzh(T_Path);
                     *(strrchr(T_Path, '\\') + 1) = '\0';
                  }
                  break;
               case arj:
                  ++S[ArcType][0];
                  if (ArcSwt)
                  {
                     strcat(T_Path, DirBlk.D_NAME);
                     DoArj(T_Path);
                     *(strrchr(T_Path, '\\') + 1) = '\0';
                  }
                  break;
            }
         }
      }
      Status = FIND_NEXT(&DirBlk);
   }
   p = strrchr(T_Path, '\\') + 1;

/* Process any entries in the linked list of subdirectories		    */

   for (t = Direc.Head; t != NULL;)
   {
      *p = '\0';
      strcat(T_Path, t->Body);
      strcat(T_Path, "\\");
      WalkTree(Q);
      u = t->Next;
      free(t->Body);
      free(t);
      t = u;
   }
}


/*----------------------------------------------------------------------*/
/* SearchQ takes a file name as input and matches it against all of the	*/
/* patterns in the linked list of patterns built from command line		*/
/* arguments.  The pattern list is an external.                         */

int SearchQ (char *Str)
{
   extern QUE_DEF PatQue;
   QUE_ENTRY      *t;
   int            Result;

   for (t = PatQue.Head; t != NULL; t = t->Next)
   {
      Result = Match(Str, t->Body);
      if (Result != 0) return (Result);
   }
   return (0);
}

/*----------------------------------------------------------------------*/
/* ErrorExit is a general routine used to print an error message and	   */
/* exit the program.                                                    */

void ErrorExit (char *Format, ...)
{
   va_list         ArgPtr;
   extern char     ProgName[];

   fprintf(stderr, "%s: ", ProgName);
   va_start(ArgPtr, Format);
   vfprintf(stderr, Format, ArgPtr);
   va_end(ArgPtr);
   if (errno) perror("    ");
   fprintf(stderr, "\n");
   exit(1);
}

/*----------------------------------------------------------------------*/
/* GetProgName interprets argv[0] to find the program name for error	   */
/* messages.  It does NOT work for versions of MS-DOS prior to 3.0.     */

void GetProgName (char *Name, char *argv)
{
   char *p, *p1;

   if ( (p = strrchr(argv, '\\')) != NULL ) ++p;
   else p = argv;
   if ( (p1 = strchr(p, '.')) != NULL ) *p1 = '\0';
   strcpy(Name, p);
}

/*----------------------------------------------------------------------*/
/* PrtVerbose displays the "verbose" line for matched files.  It 	      */
/* displays the file size (in bytes), file date, and file time as well	*/
/* the file name.  By default, it shows the month is 3-character alpha	*/
/* form.																                  */

void PrtVerbose (char *Path, char *Name, DOS_FILE_TIME * Time,
	    DOS_FILE_DATE * Date,
	    long Size)
{
   extern int DateSwt, UsDateSwt;
   extern int CaseSwt;

   static char    *MonTab[] =
   {
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
      "Oct", "Nov", "Dec"
   };

   strcpy(V_Name, Name);
   if (CaseSwt == ON) strlwr(V_Name);
   strcpy(V_Path, Path);
   if (CaseSwt == ON) strlwr(V_Path);
   if (DateSwt)
   {
      printf("%-13s   %02d-%02d-%02d   %02u:%02u %8ld   %s\n", V_Name,
                      Date->b.Year + 80, Date->b.Month, Date->b.Day, Time->b.Hour,
		      Time->b.Minute, Size, V_Path);
   }
   else if (UsDateSwt)
   {
      printf("%-13s   %02d/%02d/%02d   %02u:%02u %8ld   %s\n", V_Name,
                      Date->b.Month, Date->b.Day, Date->b.Year + 80, Time->b.Hour,
		      Time->b.Minute, Size, V_Path);
   }
   else
   {
      printf("%-13s   %02u %s %02u   %02u:%02u %8ld   %s\n", V_Name, Date->b.Day,
                      MonTab[Date->b.Month - 1], Date->b.Year + 80, Time->b.Hour,
		      Time->b.Minute, Size, V_Path);
   }
}

/*----------------------------------------------------------------------*/
/* Usage is a pretty conventional routine to display a brief "help"	   */
/* message if the program is evoked with no command line arguments	   */

void Usage (void)
{
   fprintf(stderr, "USAGE: %s [device(s):[path]pattern [options]\n", ProgName);
   fprintf(stderr, "\nOptions:\n\n");
   fprintf(stderr, "    -a Suppress searching inside of archive files.\n");
   fprintf(stderr, "    -v Display Date/Time and File Size as well as name\n");
   fprintf(stderr, "       and path for all matched files.\n");
   fprintf(stderr, "    -f Modify the date in the Verbose output for sorting\n");
   fprintf(stderr, "       YY/MM/DD form\n");
   fprintf(stderr, "    -u Modify the date in the Verbose output to US normal\n");
   fprintf(stderr, "       form - MM/DD/YY\n");
   fprintf(stderr, "    -p Paginate output every 23 lines\n");
   fprintf(stderr, "    -q Supress the printing of the statistics on files\n");
   fprintf(stderr, "       searched and matched\n");
   fprintf(stderr, "    -c Output in lower case instead of upper case\n\n");
   fprintf(stderr, "    Press \"ESC\" at any time to terminate the search.\n");
   exit(1);
}


/*----------------------------------------------------------------------*/
/* ChkPage is used if "paging" is specified on the command line or in	*/
/* the Environment Variable.  It pauses the program for user input	   */
/* 23 lines to prevent the scrolling entries off the screen before the	*/
/* user has read them.													            */

void ChkPage (void)
{
   int Reply;

   if (Lnno >= 24)
   {
      clreol();
      printf("More?...");
      Reply = tolower(getche());
      if ((Reply == 'n') || (Reply == 0x03) || (Reply == 0x1b) ) exit(1);
      printf("\r");
      clreol();
      Lnno = 1;
   }
}

/*----------------------------------------------------------------------*/
/* convdelim  is used  for changing  all kinds of path delimeters to an */
/* unique form                                                          */

char *convdelim(char *path)
{
   unsigned char c;
   unsigned char *p;

   for (p = path; (c = *p) != 0; p++)
   {
      if (c == '\\' || c == '/' || c == (unsigned char)'\xff')
      {
         *p = '\\';
	 path = p + 1;
      }
   }
   return path;
}
