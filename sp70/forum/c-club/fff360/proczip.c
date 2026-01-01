/***************************************************************************
 *                                                                         *
 * ZIP Processing Functions                                                *
 * These routines are used to process files with the ZIP entension.        *
 ***************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#undef MAIN

#include "fff.h"
#include "zip.h"
#include "queue.h"

int Match (char *Str, char *Pat);
void PrtVerbose (char *Path, char *Name, DOS_FILE_TIME *Time,
		 DOS_FILE_DATE *Date,
		 long Size);
void ChkPage (void);
int  SearchQ (char *Str);

/***********************************************************************
 * DoZip is the main routine to process an entire ZIP file             *
 ***********************************************************************/

void DoZip (char *Name)
{
   FILE *ZIPFile;

   if ( (ZIPFile = fopen(Name, "rb")) == NULL )
   {
      fprintf(stderr, "%s", Name);
      perror("");
   }
   ProcessHeaders(ZIPFile, Name);
   fclose(ZIPFile);
}

/***********************************************************************
 * Unlike the other PC-based archivers, PKZip produces files that have *
 * both a distributed directory and a central directory.  For programs *
 * such as FFF which are not interested in the content of the files in *
 * the ZIP but in their directory data, a great deal of time can be    *
 * saved by processing the central directory rather than reading the   *
 * entire file just to find the entries in the distributed directory!  *
 * The central directory of a ZIP file is located at the "back end" of *
 * the file, however, finding it it slightly complicate by the fact    *
 * the file may have a variable number of non-relevant characters      *
 * appended by some of the file transfer protocols (one main-frame     *
 * Kermit protocol can append as many as 1,440 non-relevant characters *
 ***********************************************************************/

void ProcessHeaders (FILE *ZIPFile, char *Path)
{
   extern int TotalMatch, VerboseSwt, CaseSwt, Spaced, PageSwt;
   extern char V_Name[14];
   extern char V_Path[66];
   extern ARC_TYPE ArcType;
   extern int Lnno;
   extern S[7][3];

   int i, Printed, Index, ZipLen;
   long FileLen;
   char *Buffer, *Name, *p;
   char DireName[65];
   unsigned Count;
   long Offset, S_Offset, Block;
   unsigned long *Ptr;
   unsigned long CentralSig;
   END_CENTRAL_DIRECTORY_RECORD *EndPtr;
   CENTRAL_DIRECTORY_FILE_HEADER *CentralHeader;

/*----------------------------------------------------------------------*/
/* Establish the buffer to search the "back end" of the file.           */
/* SEARCH_SIZE (#defined in zip.h) establishes the buffer size and      */
/* should be no less than 1024 bytes.  I have found 2048 to be a little	*/
/* more sure.								*/

   if ( (Buffer = malloc(SEARCH_SIZE)) == NULL)
   {
      fprintf(stderr, "Insufficient memory!\n");
      exit(1);
   }

/* Position to the end of the ZIP file and get the file size in bytes   */

   fseek(ZIPFile, 0L, SEEK_END);
   FileLen = ftell(ZIPFile);

/* Reset the ZIP file position to the beginning of the file             */

   fseek(ZIPFile, 0L, SEEK_SET);
   if (FileLen < SEARCH_SIZE)
   {
      ZipLen = fread(Buffer, (size_t) 1, (size_t) FileLen, ZIPFile);
   }
   else
   {
      fseek(ZIPFile, (long) -SEARCH_SIZE, SEEK_END);
      ZipLen = fread(Buffer, 1, SEARCH_SIZE, ZIPFile);
   }

/* Search backwards for the "End of Central Directory" entry            */

   for (i = ZipLen - 4; i >= 0; --i)
   {
      Ptr = (unsigned long *) &Buffer[i];
      if (*Ptr == END_CENTRAL_DIR_SIGNATURE) break;
   }
   if (i < 0)
   {
      fprintf(stderr, "%s: Invalid ZIP format\n", Path);
      fprintf(stderr, "      - No \"End-of-Central-Directory\" record!\n");
      free(Buffer);
      return;
   }

/* The "End of Central Directory" entry contains the count of the entries */
/* and the offset of the first entry in the Central Directory             */

   EndPtr = (END_CENTRAL_DIRECTORY_RECORD *) &Buffer[i + 4];
   Count = EndPtr->CentralDirEntries_ThisDisk;
   S_Offset = Offset = EndPtr->OffsetStartCentralDirectory;

/* This may be a problem with VERY large ZIPs!  If the length of the      */
/* Central Directory exceeds 64K, this will NOT work!                     */

   Block = FileLen - Offset;
   free(Buffer);

/* Read the entire Central Directory into memory and process each entry   */

   Buffer = malloc( (size_t) Block);
   fseek(ZIPFile, S_Offset, SEEK_SET);
   fread(Buffer, (size_t) 1, (size_t) Block, ZIPFile);
   Printed = 0;
   for (Index = i = 0; i < Count; ++i)
   {
      ++S[ArcType][1];
      memmove(&CentralSig, &Buffer[Index], 4);
      if (CentralSig != CENTRAL_FILE_HEADER_SIGNATURE)
      {
         fprintf(stderr, "%s: Invalid ZIP format\n", Path);
         fprintf(stderr, "     - bad \"Central Directory\" record!\n");
         free(Buffer);
         return;
      }
      Index += 4;
      CentralHeader = (CENTRAL_DIRECTORY_FILE_HEADER *) &Buffer[Index];
      Index += sizeof(CENTRAL_DIRECTORY_FILE_HEADER);
      Name = malloc(CentralHeader->FileNameLength + 1);
      memmove(Name, &Buffer[Index], CentralHeader->FileNameLength);
      Name[CentralHeader->FileNameLength] = '\0';
      Index += CentralHeader->FileNameLength
                    + CentralHeader->FileCommentLength
                    + CentralHeader->ExtraFieldLength;
      if ( (p = strrchr(Name, '/')) != NULL)
      {
         *p = '\0';
         strcpy(DireName, Name); strcat(DireName, "/");
         ++p;
      }
      else
      {
         DireName[0] = '\0';
         p = Name;
      }
      if ( SearchQ(p) )
      {
         ++S[ArcType][2];
         ++TotalMatch;
         if (PageSwt) ChkPage();
         strcpy(V_Name, p);
         strcpy(V_Path, Path);
         if (CaseSwt == ON)
         {
            strlwr(V_Name);
            strlwr(V_Path);
            strlwr(DireName);
         }
         convdelim(DireName);
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
            PrtVerbose(DireName, V_Name, &CentralHeader->LastModFileTime,
                               &CentralHeader->LastModFileDate,
                               CentralHeader->UncompressedSize);
         }
         else printf("%s--> (%s%s)\n", V_Path, DireName, V_Name);
         ++Lnno;
      }
      free(Name);
   }
   free(Buffer);
   if (Printed)
   {
      if (PageSwt) ChkPage();
      printf("\n");
      ++Lnno;
      Spaced = 1;
   }
}
