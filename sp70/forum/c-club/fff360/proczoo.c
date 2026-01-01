/***************************************************************************
 *                                                                         *
 * ZOO Processing Functions                                                *
 *                                                                         *
 ***************************************************************************/
#include <stdio.h>
#include <string.h>
#include <io.h>

#include "fff.h"
#include "zoo.h"

int Match (char *Str, char *Pat);
void PrtVerbose (char *Path, char *Name, DOS_FILE_TIME *Time,
		 DOS_FILE_DATE *Date,
		 long Size);
void ChkPage (void);
int  SearchQ (char *Str);

extern char Pattern[66];

static int Printed;

void DoZOO (char *ZOOFileName)
{
   extern int Spaced, PageSwt, Lnno;

   FILE *ZOOFile;
   unsigned long ZOOPos;
   ZOO_FIXED_TYPE ZOOEntry;

   if ( (ZOOFile = fopen(ZOOFileName, "rb")) == NULL)
   {
      fprintf(stderr, "%s", ZOOFileName);
      perror("");
   }
   if ( !GetZOOHeader(ZOOFile, &ZOOPos) )
   {
      Printed = 0;
      while ( !GetNextZOOEntry(ZOOFile, &ZOOPos, &ZOOEntry) )
              DisplayZOOEntry(ZOOFile, ZOOFileName, &ZOOEntry);
      if (Printed)
      {
         if (PageSwt) ChkPage();
         printf("\n");
         ++Lnno;
         Spaced = 1;
      }
   }
}

int GetZOOHeader (FILE *ZOOFile, unsigned long *ZOOPos)
{
   ZOO_HEADER_TYPE ZOOHeader;

   if ( !fread(&ZOOHeader, sizeof(ZOOHeader), 1, ZOOFile) )
      return(FORMAT_ERROR);
   else if (ZOOHeader.ZOOTag != VALID_ZOO) return(FORMAT_ERROR);
   else *ZOOPos = ZOOHeader.ZOOStart;
   return(0);
}

int GetNextZOOEntry (FILE *ZOOFile, unsigned long *ZOOPos, ZOO_FIXED_TYPE *ZOOEntry)
{
   fseek(ZOOFile, *ZOOPos, SEEK_SET);
   if ( !fread(ZOOEntry, sizeof(*ZOOEntry), 1, ZOOFile) )
      return(FORMAT_ERROR);
   else if (ZOOEntry->ZOOTag != VALID_ZOO) return(FORMAT_ERROR);
   else if ( (*ZOOPos = ZOOEntry->Next) == 0) return(END_OF_FILE);
   return(0);
}

void DisplayZOOEntry (FILE *ZOOFile, char *ZOOFileName, ZOO_FIXED_TYPE *ZOOEntry)
{
   extern int TotalMatch, VerboseSwt, CaseSwt, Spaced, PageSwt;
   extern char V_Name[14], V_Path[66];
   extern ARC_TYPE ArcType;
   extern int Lnno;
   extern int S[7][3];

   char FileName[13];
   char DirectName[65];
   char LongName[65];
   int DelFile;
   ZOO_VARYING_TYPE ZOOVarying;
   unsigned char NamLen;
   unsigned char DirLen;
   char *p;
   int SystemID;

   strcpy(FileName, ZOOEntry->FName);
   DelFile = (ZOOEntry->Deleted == 1);
   strcpy(LongName, ""); strcpy(DirectName, "");
   if (DelFile) strcpy(LongName, "  (Deleted");
   else if (ZOOEntry->VarDirLen)
   {
      if (fread(ZOOVarying, (size_t) ZOOEntry->VarDirLen, (size_t) 1, ZOOFile))
      {
         NamLen = ZOOVarying[0];
         DirLen = ZOOVarying[1];
         if ( (long) (NamLen + DirLen + 2) < ZOOEntry->VarDirLen)
            strncpy( (char *) &SystemID, &ZOOVarying[NamLen + DirLen + 2], 2);
         else SystemID = 4095;
         if ( DirLen || NamLen)
         {
            if (NamLen)
            {
               strncpy(FileName, (char *) &ZOOVarying[2], NamLen);
               FileName[NamLen] = '\0';
            }
            else
               strcpy(FileName, ZOOEntry->FName);
            if (DirLen)
            {
               strncpy(DirectName, &ZOOVarying[NamLen+2], DirLen);
               DirectName[DirLen] = '\0';
               if (SystemID <= 2)
                  if (DirectName[strlen(DirectName)-1] != '/')
                     strcat(DirectName, "/");
            }
         }
      }
      ++S[ArcType][1];
      strcpy(LongName, DirectName); strcat(LongName, FileName);
      if (DirectName[0] != '\0')
      {
         if (DirectName[strlen(DirectName)-1] != '/')
            strcat(DirectName, "/");
      }
      strupr(LongName);
      if ( (p = strrchr(LongName, '/')) != NULL)
         ++p;
      else
         p = LongName;
      if ( SearchQ(p) )
      {
         ++S[ArcType][2];
         ++TotalMatch;
         if (PageSwt) ChkPage();
         if (CaseSwt == ON)
         {
            strlwr(DirectName);
            strlwr(FileName);
            strlwr(LongName);
            strlwr(ZOOFileName);
         }
         else
         {
            strupr(DirectName);
            strupr(FileName);
            strupr(ZOOFileName);
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
               printf("%s\n", ZOOFileName);
               ++Lnno;
               Printed = 1;
            }
            fputs("* ", stdout);
            convdelim(DirectName);
            PrtVerbose(DirectName, FileName, &ZOOEntry->Time,
                            &ZOOEntry->Date, ZOOEntry->OrgSize);
         }
         else
         {
            fputs(ZOOFileName, stdout);
            fputs("--> (", stdout);
            convdelim(LongName);
            fputs(LongName, stdout);
            puts(")");
         }
         ++Lnno;
      }
   }
}
