/***************************************************************************
 *                                                                         *
 * ARC Processing Functions                                                *
 * These routines are used to process files with an ARC extension.         *
 * Since PAK produces files with the same format as is used by ARC, the    *
 * same routines are used to process files with the PAK extension also     *
 ***************************************************************************/

#include <stdio.h>
#include <string.h>

#include "fff.h"
#include "arc.h"

int Match (char *Str, char *Pat);
void PrtVerbose (char *Path, char *Name, DOS_FILE_TIME *Time,
		 DOS_FILE_DATE *Date,
		 long Size);
void ChkPage (void);
static int GetEntry (FILE *ArcFile, ARCHIVE_HEADER *ArchiveDir);
int  SearchQ (char *Str);

/***********************************************************************
 * DoArc is the main routine for processing ARC and PAK files.         *
 ***********************************************************************/

void DoArc (char *Path)
{
   extern int Level;
   extern int TotalMatch, VerboseSwt, CaseSwt, Spaced, PageSwt;
   extern char V_Name[14], V_Path[66];
   extern ARC_TYPE ArcType;
   extern int Lnno;
   extern S[7][3];

   FILE *ArcFile;
   int Status, Printed;
   ARCHIVE_HEADER ArchiveHead;

   Printed = 0;
   if ( (ArcFile = fopen(Path, "rb")) == NULL) perror(Path);
   else
   {
     while ( (Status = GetEntry(ArcFile, &ArchiveHead)) != 0 )
     {
        if (Status < 0)
        {
           printf("%s\n", Path);
           break;
        }
        else
        {
           ++S[ArcType][1];
           if ( SearchQ(ArchiveHead.Name) )
           {
              ++S[ArcType][2];
              ++TotalMatch;
              if (PageSwt) ChkPage();
              strcpy(V_Name, ArchiveHead.Name);
              strcpy(V_Path, Path);
              if (CaseSwt == ON)
              {
                 strlwr(V_Name);
                 strlwr(V_Path);
              }
              if (VerboseSwt)
              {
                 if (!Printed)
                 {
                    if (!Spaced)
                    {
                       if (PageSwt) ChkPage();
                       printf("\n");
                       ++Lnno;
                    }
                    if (PageSwt) ChkPage();
                    printf("%s\n", V_Path);
                    ++Lnno;
                    Printed = 1;
                 }
                 fputs("* ", stdout);
                 PrtVerbose("", V_Name, &ArchiveHead.Time,
                              &ArchiveHead.Date, ArchiveHead.Length);
              }
              else
              {
                 fputs(V_Path, stdout);
                 fputs("--> (", stdout);
                 fputs(V_Name, stdout);
                 puts(")");
              }
              ++Lnno;
           }
        }
     }
     fclose(ArcFile);
   }
   if (Printed)
   {
      if (PageSwt) ChkPage();
      printf("\n");
      ++Lnno;
      Spaced = 1;
   }
}

/***********************************************************************
 * GetEntry will read and verify the next entry in the distributed     *
 * directory of an ARC or PAK file.                                    *
 ***********************************************************************/

static int GetEntry (FILE *ArcFile, ARCHIVE_HEADER *ArchiveDir)
{
   if (fread(ArchiveDir, sizeof(char), sizeof(ARCHIVE_HEADER), ArcFile) < 2)
   {
      printf("couldn't read header: ");
      return(-1);
   }
   if (ArchiveDir->ArcMark != 0x1A)
   {
      printf("invalid ArcMark: ");
      return(-1);
   }
   if (ArchiveDir->HeaderVersion == 0) return(0);

   fseek(ArcFile, ArchiveDir->Size, SEEK_CUR);
   return(1);
}
