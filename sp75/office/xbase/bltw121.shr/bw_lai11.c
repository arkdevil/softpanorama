
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "BULLET.h"

#pragma pack(1)		/* C7 packs to EVEN by default
			Must pack any Bullet-used data 
			structures to standard byte-
			alignment with any compiler! 
			YOUR PROGRAM WILL NOT RUN CORRECTLY
			UNLESS THIS IS SO!
			*/
			   
/* 
   12-Jul-94
   BW_LAI11.C -chh
   
   The RC resource compiler may generate a warning about the use of
   hard-code data segment loads with the DGROUP value.  The warning is
   relevant to a multi-instanced program, which Bullet code won't be
   (can't be). Future versions will remove this limitation (i.e., a 
   DLL version will be available).
   
   18-Mar-94
   BW_LAI11.C -chh
   
   Minor modifications from the previous BC_LAI10.C (a little understanding
   helps) but essentially done for the Bullet Windows (QuickWin of C7)
   test program. Running from Windows Standard Mode fails because Windows
   does not properly handle INT21/65xx calls. In order to run from Standard
   Mode you must either supply your own collate table (demonstrated below), 
   or use a straight ASCII sort. Windows does handle INT21/65xx from Enhanced
   Mode correctly.
*/
   
/* Country code 001 collate table from US MS-DOS 6.20 */

unsigned char cc001[256] =
{
0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,
0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,
0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,
0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,
0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,
0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F,
0x60,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,
0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x7B,0x7C,0x7D,0x7E,0x7F,
0x43,0x55,0x45,0x41,0x41,0x41,0x41,0x43,0x45,0x45,0x45,0x49,0x49,0x49,0x41,0x41,
0x45,0x41,0x41,0x4F,0x4F,0x4F,0x55,0x55,0x59,0x4F,0x55,0x24,0x24,0x24,0x24,0x24,
0x41,0x49,0x4F,0x55,0x4E,0x4E,0xA6,0xA7,0x3F,0xA9,0xAA,0xAB,0xAC,0x21,0x22,0x22,
0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF,
0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,
0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF,
0xE0,0x53,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,
0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF
};

			
/* --test raw speed using 32-bit long integer key, unique
   1) this test uses a non-standard binary field as a sort field
   2) this code is for raw speed tests--it's straight inline
   
   Note: memory model must be medium, large, or huge */

struct memorypack MP;
struct initpack IP;
struct exitpack EP;
struct fielddesctype fieldlist[2];
struct createdatapack CDP;
struct createkeypack CKP;
struct dosfilepack DFP;
struct openpack OP;
struct accesspack AP;
struct exitpack EP;

int	rez, level, ccflag;
div_t	div_rez;
time_t	starttime, endtime;

char	tmpstr[129];

char 	NameDAT[] = ".\\BINTEST.DBB";
char 	NameIX1[] = ".\\BINTEST.IX1";

char	kx1[] = "CODENUMBER";

unsigned handdat, handix1;

struct testrectype {
	char  tag;
	long  codenumber;
	char  codename[11];
}; /* test program record length=16 bytes */
struct testrectype testrec;

char	keybuffer[64];		/* MUST supply a work buffer for keys */
							/* a single one can be shared unless you */
							/* want to preserve the key buffer for each */
							/* access pack */
							
long	recs2add;
long	low;
long	high;
long	i;
	      
#pragma pack()


int main()
{

   strcpy(fieldlist[0].fieldname, "CODENUMBER");
   strcpy(fieldlist[0].fieldtype, "B");
   fieldlist[0].fieldlen = 4;
   fieldlist[0].fielddc = 0;
   strcpy(fieldlist[1].fieldname, "CODENAME");
   strcpy(fieldlist[1].fieldtype, "C");
   fieldlist[1].fieldlen = 11;
   fieldlist[1].fielddc = 0;

   /* excuses, excuses */

   printf("BC_LAI11.C - LONG INT, SIGNED, UNIQUE long int, add/reindex speed test\n");
   printf("--uses non-standard data files with binary field values, not DBF\n");
   printf(">> USING DIRECTORY : .\\ \n\n");

   level = 100;
   MP.func = MEMORYXB;
   rez = BULLET(&MP);
   printf("memory avail   : %lu\n",MP.memory);

   if (MP.memory < 40000L) {
      rez = 8;
      goto Abend;
   }
			  
   ccflag = 0;
   printf("Override machine default collate and use embedded table? (Y/N)");
   gets(tmpstr);
   if (toupper(*tmpstr) == 'Y') 
   {
      ccflag = 1;
      printf("Using embedded collate table (country code=001)\n");
   }
   else
    printf("Using machine default collate table\n");
  
   
   level = 110;
   IP.func = INITXB;
   IP.jftmode = 0;
   rez = BULLET(&IP);
   if (rez != 0) goto Abend;

#if 0
   level = 120;
   EP.func = ATEXITXB;
   rez = BULLET(&EP);
   if (rez != 0) goto Abend;
#endif

   level = 130;				/* disregard not found errors */
   DFP.func = DELETEFILEDOS;
   DFP.filenameptr = NameDAT;
   rez = BULLET(&DFP);
   DFP.filenameptr = NameIX1;
   rez = BULLET(&DFP);

   level = 1000;
   CDP.func = CREATEDXB;
   CDP.filenameptr = NameDAT;
   CDP.nofields = 2;
   CDP.fieldlistptr = fieldlist;
   CDP.fileid = 255;
   rez = BULLET(&CDP);
   if (rez !=0) goto Abend;

   level = 1010;
   OP.func = OPENDXB;
   OP.filenameptr = NameDAT;
   OP.asmode = READWRITE | DENYNONE;
   rez = BULLET(&OP);
   if (rez !=0) goto Abend;
   handdat = OP.handle;

   level = 1100;
   CKP.func = CREATEKXB;
   CKP.filenameptr = NameIX1;
   CKP.keyexpptr = kx1;
   CKP.xblink = handdat;
   CKP.keyflags = cLONG | cSIGNED | cUNIQUE;
   if (ccflag) 
   {
      CKP.codepageid = 437;	/* identify collate sequence -- must be */
      CKP.countrycode = 1;	/* non-zero else collateptr ignored */
      CKP.collateptr = cc001; /* these values are specifically for */
      						/* the table cc001, coded above */
   }
   else
   { 
      CKP.codepageid = -1;  /* use this unless you specifically */
      CKP.countrycode = -1; /* need to use your own collate table */
      CKP.collateptr = NULL; /* as shown directly above */
   }
   rez = BULLET(&CKP);
   if (rez !=0) goto Abend;

   level = 1110;
   OP.func = OPENKXB;
   OP.filenameptr = NameIX1;
   OP.asmode = READWRITE | DENYNONE;
   OP.xblink = handdat;
   rez = BULLET(&OP);
   if (rez !=0) goto Abend;
   handix1 = OP.handle;

   AP.func = ADDRECORDXB;
   AP.handle = handdat;
   AP.recptr = &testrec;
   AP.keyptr = keybuffer;
   AP.nextptr = NULL;

   testrec.tag = ' ';
   strcpy(testrec.codename, "xxxSAMExxx");

   printf("Recs to add/reindex: ");
   gets(tmpstr);
   recs2add = atol(tmpstr);
   if (recs2add == 0L) recs2add = 5L;

   level = 1200;
   low = -3L;
   high = low + recs2add - 1L;
   printf("Adding %ld records ( keys %ld to %ld )... ",recs2add,low,high);

   time(&starttime);
   for (i = low; i < (recs2add+low); i++) {
      testrec.codenumber = i;
      rez = BULLET(&AP);
      if (rez !=0) goto Abend;
   }
   time(&endtime);
   printf("%lu secs.\n",(endtime - starttime));

   level = 1210;
   printf("Reindexing... ");
   AP.func = REINDEXXB;
   AP.handle = handix1;
   time(&starttime);
   rez = BULLET(&AP);
   time(&endtime);
   if (rez != 0) {
      rez = AP.stat;    /* MUST take AP.stat since a xaction routine */
      goto Abend;       /* see docs and !README2.TXT for more */
   }
   printf("%lu secs\n\n",(endtime - starttime));

   level = 1300;
   AP.func = GETFIRSTXB;
   rez = BULLET(&AP);
   printf("  The first 5 key/recs\n");
   printf("%7lu %7ld %.10s\n",AP.recno,testrec.codenumber,testrec.codename);
   for (i=1;i < 5; i++) {
      if (rez != 0) break;
      AP.func = GETNEXTXB;
      rez = BULLET(&AP);
      printf("%7lu %7ld %.10s\n",AP.recno,testrec.codenumber,testrec.codename);
   }
   if (rez == 202) rez = 0;
   if (rez != 0) goto Abend;
   puts(" ");

   level = 1310;
   AP.func = GETLASTXB;
   rez = BULLET(&AP);
   printf("  The last 5 key/recs\n");
   printf("%7lu %7ld %.10s\n",AP.recno,testrec.codenumber,testrec.codename);
   for (i=1;i < 5; i++) {
      if (rez != 0) break;
      AP.func = GETPREVXB;
      rez = BULLET(&AP);
      printf("%7lu %7ld %.10s\n",AP.recno,testrec.codenumber,testrec.codename);
   }
   if (rez == 203) rez = 0;
   if (rez != 0) goto Abend;
   
   level = 1311;
   printf("  Finding the last gotten key, (in AP.keybuffer already)\n");
   AP.func = GETEQUALXB;
   rez = BULLET(&AP);
   printf("%7lu %7ld %.10s\n",AP.recno,testrec.codenumber,testrec.codename);
   if (rez != 0) goto Abend;
   
   level = 1312;
   printf("  Finding key of 5\n");
   AP.func = GETEQUALXB;
   *((long *)keybuffer) = 5L;
   rez = BULLET(&AP);
   printf("%7lu %7ld %.10s\n",AP.recno,testrec.codenumber,testrec.codename);
   if (rez != 0) goto Abend;
   
   puts("Okay.");
   EP.func = EXITXB;
   rez = BULLET(&EP);
   return(0);
   /* program exit */


   /*----------------------------------------------*/
   /* that's right, we go to a termination routine */

Abend:
   printf("Error: %u at level %u while performing ",rez,level);
   switch (level) {
   case 100:
      printf("a memory request of 140K.\n");
      break;
   default:
      printf("(See source)\n");    /* just check the source */
   }

   exit(1);
}

