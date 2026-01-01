/***************************************************************************
 *                                                                         *
 * ARJ Processing Functions                                                *
 * These routines process archive files with the ARJ extension.            *
 *                                                                         *
 ***************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "fff.h"
#include "arj.h"

int Match (char *Str, char *Pat);
void PrtVerbose (char *Path, char *Name, DOS_FILE_TIME *Time,
		 DOS_FILE_DATE *Date,
		 long Size);
static int GetEntry (FILE *ArjFile, ARJ_HEADER *ArjDir);
void ChkPage (void);
int  SearchQ (char *Str);

extern char Pattern[66];

static char *Name;

int fget_byte(FILE *f)
{
    int c;

    if ((c = fgetc(f)) == EOF)
       fprintf(stderr,"Can't read file or unexpected end of file\n");
    return c & 0xFF;
}

uint fget_word(FILE *f)
{
    uint b0, b1;

    b0 = fget_byte(f);
    b1 = fget_byte(f);
    return (b1 << 8) + b0;
}

/***********************************************************************
 * DoArj is the main routine used to process an entire ARJ file.       *
 ***********************************************************************/

void DoArj (char *Path)
{
   extern int Level; extern int TotalMatch, VerboseSwt, CaseSwt, Spaced, PageSwt;
   extern char V_Name[14], V_Path[65];
   extern ARC_TYPE ArcType;
   extern int Lnno; extern int S[7][3];

   FILE *ArjFile;
   int Status, Printed;
   ARJ_HEADER ArjHead;
   char *p;

   Printed = 0;
   if ( (ArjFile = fopen(Path, "rb")) == NULL) perror(Path);
   else
   {
      if (GetEntry(ArjFile,&ArjHead)==1) free(Name);
      while ( (Status = GetEntry(ArjFile, &ArjHead)) > 0 )
      {
         if ( (p = strrchr(Name, '\\')) != NULL) ++p;
         else p = Name;
         ++S[ArcType][1];
         if ( SearchQ(p) )
         {
            ++S[ArcType][2];
            ++TotalMatch;
            if (PageSwt) ChkPage();
            strcpy(V_Name, p);
            strcpy(V_Path, Name);
            if (CaseSwt == ON)
            {
               strlwr(V_Name);
               strlwr(V_Path);
               strlwr(Path);
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
                  printf("%s\n", Path);
                  ++Lnno;
                  Printed = 1;
               }
               fputs("* ", stdout);
               if (strcmp(V_Name,V_Path))
                  *(strrchr(V_Path,'\\')+1) = '\0';
               else
                  *V_Path = '\0';
               PrtVerbose(V_Path, V_Name, &ArjHead.Time, &ArjHead.Date,
                            ArjHead.OriginalSize);
            }
            else
            {
               fputs(Path, stdout);
               fputs("--> (", stdout);
               fputs(V_Path, stdout);
               puts(")");
            }
            ++Lnno;
         }
         if (Status==1) free(Name);
      }
      if (Status < 0) printf("%s\n", Path);
      fclose(ArjFile);
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
 * GetEntry reads and verifys the next entry in the distributed        *
 * directory of an ARJ file.                                           *
 ***********************************************************************/

static int GetEntry (FILE *ArjFile, ARJ_HEADER *ArjDir)
{
   size_t hsize;
   char buffer[HEADERSIZE_MAX+4];

   if (fget_word(ArjFile) != 60000U) return (-1);

   if ((hsize = fget_word(ArjFile))==0) return(0);

   if ( fread(buffer, 1, hsize+4, ArjFile) != hsize+4)
   {
      printf("Couldn't read header: ");
      return(-1);
   }

   memcpy(ArjDir,buffer,sizeof(ARJ_HEADER));
   buffer[ArjDir->FirstHeaderSize+FNAME_MAX] = '\0';

   if ( (Name = malloc(1+strlen(&buffer[ArjDir->FirstHeaderSize]))) == NULL)
   {
      printf("Insufficient memory for file name: ");
      return(-1);
   }
   strcpy(Name, &buffer[ArjDir->FirstHeaderSize]);

   convdelim(Name);

   while ((hsize=fget_word(ArjFile))!=0)
      fseek(ArjFile,hsize+2,SEEK_CUR);

   fseek(ArjFile,ArjDir->CompressedSize,SEEK_CUR);

   return(1);
}
