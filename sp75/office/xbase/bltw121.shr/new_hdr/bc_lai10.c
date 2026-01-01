        
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#include "bullet.h"

#pragma pack(1)
			
/* --test raw speed using 32-bit long integer key, unique
   1) this test uses a non-standard binary field as a sort field
   2) this code is for raw speed tests--it's straight inline

 To compile, just set you compiler to large memory model, have it
 link in BULLET.LIB, and that's it.  Borland compilers use BULLET_L.LIB.

*/

struct MemoryPack MP;
struct InitPack IP;
struct ExitPack EP;
struct FieldDescType fieldList[2];
struct CreateDataPack CDP;
struct CreateKeyPack CKP;
struct DosFilePack DFP;
struct OpenPack OP;
struct AccessPack AP;
struct ExitPack EP;

int	rez, level;
div_t	div_rez;
time_t  startTime, endTime;

char    tmpStr[129];

char    nameDat[] = ".\\BINTEST.DBB";
char    nameIx1[] = ".\\BINTEST.IX1";

char	kx1[] = "CODENUMBER";

unsigned handDat, handIx1;

struct TestRecType {
 char  tag;
 long  codeNumber;
 char  codeName[11];
}; /* test program record length=16 bytes */
struct TestRecType testRec;

char    keyBuffer[64]; /* MUST supply a work buffer for keys */
                       /* a single one can be shared unless you */
                       /* want to preserve the key buffer for each */
                       /* access pack.  You read a gotten key from */
                       /* here, and also specify key to find here */
                       /* READ THE DOCS on exact matches, et al., */
                       /* especially about "enumerator word", partial */
                       /* match (follow with GetNext/Prev), and so on */

long	recs2add;
long	low;
long	high;
long	i;

#pragma pack()

int main()
{

/* implicit is the tag field at the first byte, then comes... */
strcpy(fieldList[0].fieldName, "CODENUMBER");
fieldList[0].fieldType = 'B';
fieldList[0].fieldLen = 4;
fieldList[0].fieldDC = 0;
strcpy(fieldList[1].fieldName, "CODENAME\0\0");  /* must be 0-filled */
fieldList[1].fieldType = 'C';
fieldList[1].fieldLen = 11;   /* 10 and 1 for eos */
fieldList[1].fieldDC = 0;

puts("BC_LAI10.C - LONG INT, SIGNED, UNIQUE long int, add/reindex speed test");
puts("-Uses non-standard data files with binary field values, not DBF (in this test)");
puts("-If TMP= defined in environment, reindex routine uses that path for temporary");
puts("workspace, otherwise the current directory is used.\n");

level = 100;
MP.func = MEMORYXB;
rez = BULLET(&MP);   /* not really significant */
printf("memory avail   : %lu\n",MP.memory);
if (MP.memory < 40000l) {
   rez = 8;
   goto Abend;
}

level = 110;
IP.func = INITXB;
IP.JFTmode = 0;
rez = BULLET(&IP);
if (rez != 0) goto Abend;

level = 120;
EP.func = ATEXITXB;
rez = BULLET(&EP);
if (rez != 0) goto Abend;    /* actually, not a fatal error */

level = 130;                         /* disregard not found errors */
DFP.func = DELETEFILEDOS;
DFP.filenamePtr = nameDat;
rez = BULLET(&DFP);
DFP.filenamePtr = nameIx1;
rez = BULLET(&DFP);

level = 1000;
CDP.func = CREATEDXB;
CDP.filenamePtr = nameDat;
CDP.noFields = 2;
CDP.fieldListPtr = fieldList;
CDP.fileID = 255;
rez = BULLET(&CDP);
if (rez !=0) goto Abend;

level = 1010;
OP.func = OPENDXB;
OP.filenamePtr = nameDat;
OP.asMode = READWRITE | DENYNONE;
rez = BULLET(&OP);
if (rez !=0) goto Abend;
handDat = OP.handle;

level = 1100;
CKP.func = CREATEKXB;
CKP.filenamePtr = nameIx1;
CKP.keyExpPtr = kx1;
CKP.xbLink = handDat;
CKP.keyFlags = cLONG | cSIGNED | cUNIQUE;
CKP.codePageID = -1;
CKP.countryCode = -1;
CKP.collatePtr = NULL;
rez = BULLET(&CKP);
if (rez !=0) goto Abend;

level = 1110;
OP.func = OPENKXB;
OP.filenamePtr = nameIx1;
OP.asMode = READWRITE | DENYNONE;
OP.xbLink = handDat;
rez = BULLET(&OP);
if (rez !=0) goto Abend;
handIx1 = OP.handle;

AP.func = ADDRECORDXB;
AP.handle = handDat;
AP.recPtr = &testRec;
AP.keyPtr = keyBuffer;       /* set here and used throughout  */
AP.nextPtr = NULL;

testRec.tag = ' ';
strcpy(testRec.codeName, "xxSAME-Oxx");

printf("Recs to add/reindex: ");
gets(tmpStr);
recs2add = atol(tmpStr);
if (recs2add == 0L) recs2add = 5L;

level = 1200;
low = -3L;
high = low + recs2add - 1L;
printf("Adding %ld records ( keys %ld to %ld )...\n",recs2add,low,high);

time(&startTime);
for (i = low; i < (recs2add+low); i++) {
   testRec.codeNumber = i;
   rez = BULLET(&AP);
   if (rez !=0) goto Abend;
}
time(&endTime);
printf("...took %lu secs.\n",(endTime - startTime));

level = 1210;
printf("Reindexing...\n");
AP.func = REINDEXXB;
AP.handle = handIx1;
time(&startTime);
rez = BULLET(&AP);
time(&endTime);
if (rez != 0) {
   rez = AP.stat;    /* MUST take AP.stat since a xaction routine */
   goto Abend;       /* see docs and !README2.TXT for more */
}
printf("...took %lu secs\n\n",(endTime - startTime));

level = 1300;
AP.func = GETFIRSTXB;
rez = BULLET(&AP);
printf("  The first 5 key/recs  (recNo --- key - data)\n");
printf("%7lu %7ld %.10s\n",AP.recNo,testRec.codeNumber,testRec.codeName);
for (i=1;i < 5; i++) {
   if (rez != 0) break;
   AP.func = GETNEXTXB;
   rez = BULLET(&AP);
   printf("%7lu %7ld %.10s\n",AP.recNo,testRec.codeNumber,testRec.codeName);
}
if (rez == 202) rez = 0;
if (rez != 0) goto Abend;
puts(" ");

level = 1310;
AP.func = GETLASTXB;
rez = BULLET(&AP);
printf("  The last 5 key/recs\n");
printf("%7lu %7ld %.10s\n",AP.recNo,testRec.codeNumber,testRec.codeName);
for (i=1;i < 5; i++) {
   if (rez != 0) break;
   AP.func = GETPREVXB;
   rez = BULLET(&AP);
   printf("%7lu %7ld %.10s\n",AP.recNo,testRec.codeNumber,testRec.codeName);
}
if (rez == 203) rez = 0;
if (rez != 0) goto Abend;

level = 1311;
printf("  Finding the last gotten key, (in AP.keybuffer already)\n");
AP.func = GETEQUALXB;
rez = BULLET(&AP);
printf("%7lu %7ld %.10s\n",AP.recNo,testRec.codeNumber,testRec.codeName);
if (rez != 0) goto Abend;

level = 1312;
printf("  Finding key of 5\n");
AP.func = GETEQUALXB;
*((long *)keyBuffer) = 5L;
rez = BULLET(&AP);
printf("%7lu %7ld %.10s\n",AP.recNo,testRec.codeNumber,testRec.codeName);
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
   exit(1);
}
