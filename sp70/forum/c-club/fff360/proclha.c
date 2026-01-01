#define MYDOS 'M'

#include <stdio.h>
#include <io.h>
#include <dos.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include "fff.h"
#include "lha.h"

#define HDRwork      (unsigned char *)(work +  0)
#define HDRsize      (unsigned char *)(work +  0)
#define HDRwhole     (unsigned char *)(work +  0)
#define HDRsum       (unsigned char *)(work +  1)
#define HDRmethod    (unsigned char *)(work +  2)
#define HDRpacked    (unsigned char *)(work +  7)
#define HDRoriginal  (unsigned char *)(work + 11)
#define HDRtime      (unsigned char *)(work + 15)
#define HDRattr      (unsigned char *)(work + 19)
#define HDRlevel     (unsigned char *)(work + 20)
#define HDRfnlen     (unsigned char *)(work + 21)
#define HDRfname     (unsigned char *)(work + 22)
#define HDRdos       (unsigned char *)(work + 23)
#define HDRextsize   (unsigned char *)(work + 24)

char work[4096];
FILE *LzhFile;
head hpb;

static unsigned long nextpos;

#define Convint(p) (*(int *)(p))
#define Convlong(p) (*(long *)(p))

/***********************************************************************
 * DoLzh is the main routine used to process an entire LZH file.       *
 ***********************************************************************/

void DoLzh (char *Path)
{
   extern int Level; extern int TotalMatch, VerboseSwt, CaseSwt, Spaced, PageSwt;
   extern char V_Name[14], V_Path[65];
   extern ARC_TYPE ArcType;
   extern int Lnno; extern int S[7][3];

   int Status, Printed;

   Printed = 0;
   if ( (LzhFile = fopen(Path, "rb")) == NULL)
      perror(Path);
   else
   {
      inithdr();
      while ( (Status = gethdr()) > 0 )
      {
         ++S[ArcType][1];
         if ( SearchQ(hpb.filename) )
         {
            ++S[ArcType][2];
            ++TotalMatch;
            if (PageSwt) ChkPage();
            strcpy(V_Name, hpb.filename);
            strcpy(V_Path, hpb.pathname);
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
               PrtVerbose(V_Path, V_Name, &hpb.dostime.t.time, &hpb.dostime.t.date,
                              hpb.original);
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
         if (Status==1) free(hpb.pathname);
      }
      if (Status < 0) printf("%s\n", Path);
      fclose(LzhFile);
   }
   if (Printed)
   {
      if (PageSwt) ChkPage();
      printf("\n");
      ++Lnno;
      Spaced = 1;
   }
}

time_t dos2unix(struct ftime *ft)
{
   struct tm tm;

   tm.tm_sec   = ft -> ft_tsec * 2;
   tm.tm_min   = ft -> ft_min;
   tm.tm_hour  = ft -> ft_hour;
   tm.tm_mday  = ft -> ft_day;
   tm.tm_mon   = ft -> ft_month - 1;
   tm.tm_year  = ft -> ft_year + 80;
   tm.tm_isdst = timezone;
   return mktime(&tm);
}

ftime unix2dos(time_t ft)
{

   struct tm *tm;
   ftime  fm;

   tm = gmtime(&ft);

   fm.ft_tsec  = tm->tm_sec / 2;
   fm.ft_min   = tm->tm_min;
   fm.ft_hour  = tm->tm_hour;
   fm.ft_day   = tm->tm_mday;
   fm.ft_month = tm->tm_mon+1;
   fm.ft_year  = tm->tm_year-80;
   timezone    = tm->tm_isdst;
   return fm;
}

inithdr(void)
{
   long pos;
   int c, err;
   char *p;

   pos = 0;
   while ((c = getc(LzhFile)) >= 0)
   {
      pos++;
      if (c == '-')
      {
         c=getc(LzhFile); c=getc(LzhFile); c=getc(LzhFile);
         if (getc(LzhFile) == '-')
         {
            nextpos = pos - 3;
            if (gethdr()==1)
            {
               free(hpb.pathname);
               nextpos = pos - 3;
               return;
            }
         }
         fseek(LzhFile, pos, SEEK_SET);
      }
   }
   nextpos = pos;
   return;
}

/*******************************
  calculate check-sum of header
*******************************/
static char calcsum(void *h)
{
   char *p, *q, i;

   p = (char *)h + 2;
   q = p + *(unsigned char *)h;
   for (i = 0; p < q; p++)
      i += *p;
   return i;
}

static void extheader(char *exthdr, int size)
{
   unsigned char *p;

   p = exthdr + 1;
   switch (*exthdr)
   {
      case 0:
         hpb.headcrc = Convint(p);
         hpb.crcpos = p;
         if (size > 5)
            hpb.info = *(p + 2);
         break;
      case 1:
         hpb.filename = p;
         hpb.filenlen = size - 3;
         break;
      case 2:
         hpb.pathname = p;
         hpb.dirnlen = size - 3;
         break;
      case 0x40:
         if (hpb.dos == MYDOS) {
            hpb.attr = Convint(p);
         }
         break;
   }
}

#define readarc(a,b) fread(a, 1, b, LzhFile)

int gethdr(void)
{
   char *p;
   int namelen, extsize;
   int i;

   hpb.crcpos = NULL;
   *HDRsize = *HDRlevel = 0;
   fseek(LzhFile, nextpos, SEEK_SET);
   if (readarc(HDRwork, 21) != 21 || *HDRsize == 0) return 0;
   hpb.headersize = (int)*HDRsize + 2;
   strncpy(hpb.method, HDRmethod, 5);
   hpb.packed = hpb.skip = Convlong(HDRpacked);
   hpb.original = Convlong(HDRoriginal);
   hpb.level = *HDRlevel;
   hpb.attr = *HDRattr;
   hpb.dirnlen = 0;
   switch(hpb.level)
   {
      case 0:
      case 1:
         hpb.dostime.u = Convlong(HDRtime);
         hpb.utc = dos2unix((struct ftime *)&(hpb.dostime.s));
         if (hpb.headersize < 22) return -1;
         readarc(HDRwork + 21, hpb.headersize - 21);
         if (calcsum(HDRwork) != *HDRsum) return -1;
         namelen = *HDRfnlen;
         hpb.filenlen = namelen;
         hpb.filename = hpb.pathname = HDRfname;
         i = hpb.headersize - namelen;
         if (i >= 24)
         {
            hpb.filecrc = Convint(HDRfname + namelen);
         }
         else
         {
            hpb.level = -1;
         }
         if (i >= 25)
         {
            hpb.dos = *(HDRfname + namelen + 2);
         }
         nextpos = ftell(LzhFile) + hpb.skip;
         if (hpb.level <= 0)
         {
            strncpy(hpb.pathname = malloc(namelen + 1), HDRfname, namelen);
            hpb.pathname[namelen] = '\0';
            if (strchr(hpb.pathname,'\\'))
               hpb.filename = strrchr(hpb.pathname,'\\')+1;
            else
               hpb.filename = hpb.pathname;
            convdelim(hpb.pathname);
            return 1;
         }
         p = HDRwork + *HDRsize;
         while ((extsize = Convint(p)) != 0)
         {
            readarc(p + 2, extsize);
            extheader(p + 2, extsize);
            p += extsize;
         }
         i = p + 2 - HDRwork;
         hpb.packed -= i - hpb.headersize;
         hpb.headersize = i;
         break;
      case 2:
         readarc(HDRwork + 21, (hpb.headersize = Convint(HDRwhole)) - 21);
         hpb.utc = Convlong(HDRtime);
         hpb.dostime.s = unix2dos(hpb.utc);
         hpb.dos = *HDRdos;
         p = HDRextsize;
         while ((extsize = Convint(p)) != 0)
         {
            extheader(p + 2, extsize);
            p += extsize;
         }
         hpb.filecrc = Convint(HDRfnlen);
         nextpos = ftell(LzhFile) + hpb.skip;
         if (hpb.crcpos == NULL)
         {
            return -1;
         }
         break;
      default:
         return -1;
   }
   namelen = hpb.dirnlen + hpb.filenlen;
   p = malloc(namelen + 1);
   hpb.pathname = strncpy(p, hpb.pathname, hpb.dirnlen);
   hpb.filename = strncpy(p + hpb.dirnlen, hpb.filename, hpb.filenlen);
   *(p + namelen) = '\0';
   convdelim(hpb.pathname);
   return 1;
}

