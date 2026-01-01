#include <stdlib.h>
#include <string.h>

static int I_Match (char *Str, char *Pat);
static int S_Match (char *S, char *P, int Anchor);


int Match (char *Str, char *Pat)
{
   char S_Name[66], S_Ext[4];
   char P_Name[66], P_Ext[4];
   char *p1;

   if ( (p1 = strrchr(Str, '.')) != NULL )
   {
      *p1 = '\0';
      strcpy(S_Name, Str);
      strcpy(S_Ext, p1+1);
      *p1 = '.';
   }
   else
   {
      strcpy(S_Name, Str);
      S_Ext[0] = '\0';
   }

   if ( (p1 = strchr(Pat, '.')) != NULL )
   {
      *p1 = '\0';
      strcpy(P_Name, Pat);
      strcpy(P_Ext, p1+1);
      *p1 = '.';
   }
   else
   {
      strcpy(P_Name, Pat);
      strcpy(P_Ext, "*");
   }

   if ( !I_Match(S_Name, P_Name) ) return(0);
   if ( (P_Ext[0] == '\0') && (S_Ext[0] != '\0') ) return(0);
   if ( !I_Match(S_Ext, P_Ext) ) return(0);
   return(1);
}


static int I_Match (char *Str, char *Pat)
{
   char *p, *p1, *p2, Hold;
   int t;

   if ( (p1 = strchr(Pat, '*')) == NULL)
      return( S_Match(Str, Pat, 1) );
   if (Pat[0] != '*')
   {
      *p1 = '\0';
      t = S_Match(Str, Pat, 0);
      *p1 = '*';
      if (!t) return(0);
   }
   if (Pat[strlen(Pat)-1] != '*')
   {
      p2 = strrchr(Pat, '*') + 1;
      if (strlen(Str) < strlen(p2)) return(0);
      if ( !S_Match(&Str[strlen(Str) - strlen(p2)], p2, 1) )
         return(0);
   }

   p = Str;
   while ( (p2 = strchr(++p1, '*')) != NULL )
   {
      *p2 = '\0';
      Hold = p1[0];
      while ( (p = strchr(p, Hold)) != NULL )
      {
         if ( S_Match(p, p1, 0) ) break;
         ++p;
      }
      if (p == NULL) return(0);
      p += strlen(p1);
      *p2 = '*';
      p1 = p2;
   }
   return(1);
}


static int S_Match (char *S, char *P, int Anchor)
{
   while ( (*P != '\0') && (*S != '\0') )
   {
      if ( (*S == *P) || (*P == '?') )
      {
         S++;
         P++;
      }
      else return(0);
   }
   if (*P != '\0') return(0);
   if ( Anchor && (*S != '\0') ) return(0);
   return(1);
}
