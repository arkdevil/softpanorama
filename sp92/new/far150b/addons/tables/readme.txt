This folder contains character tables for viewer, editor and "Find file"
command and character frequency distribution tables.

Read file descriptions for contents of the tables.

Character frequency distribution information is required to autodetect
table in viewer and editor (you do not need it if you use only one
character table). It describes characters frequency for OEM codepage
of concrete language. 0 corresponds to lowest frequency, 254 to highest,
value 255 means that this character should be ignored when analysing file.

The simple C++ program below allows to generate frequency distribution
information for your language. It has only one parameter - name of
large enough typical for your language text file in OEM codepage.


#include <stdio.h>

void main(int Argc, char *Argv[])
{
  if (Argc!=2)
  {
    printf("\nSyntax: DISTR <file>");
    return;
  }
  FILE *SrcFile=fopen(Argv[1],"rb");
  if (SrcFile==NULL)
  {
    printf("\nCannot open %s",Argv[1]);
    return;
  }
  unsigned long Count[256],MaxCount=0;

  for (int I=0;I<sizeof(Count)/sizeof(Count[0]);I++)
    Count[I]=0;

  int Ch,PrevCh=0;
  while ((Ch=fgetc(SrcFile))!=EOF)
    if (Ch!=PrevCh)
      Count[Ch]++;
  fclose(SrcFile);

  for (int I=128;I<sizeof(Count)/sizeof(Count[0]);I++)
    if (MaxCount<Count[I])
      MaxCount=Count[I];
  int Divider=MaxCount/254;
  if (Divider<10)
  {
    printf("\nSource file too small");
    return;
  }
  printf("REGEDIT4\n\n[HKEY_CURRENT_USER\\Software\\Far\\CodeTables]\n\"Distribution\"=hex:\\\n    ");
  for (int I=0;I<256;I++)
  {
    int Value;
    if (I<128 && (I>=32 || Count[I]!=0))
      Value=0xff;
    else
      if ((Value=Count[I]/Divider)>254)
        Value=254;
    printf("%02x%s",Value,I!=255 ? ",":"");
    if (I%16==15 && I!=255)
      printf("\\\n    ");
  }
  printf("\n");
}
