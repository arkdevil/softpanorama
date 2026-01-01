#include <windows.h>
#include <string.h>
#include <dos.h>
#include "..\\fmt.hpp"
#include "plugin.hpp"

static HANDLE ArcHandle;
static DWORD NextPosition,SFXSize,FileSize;
static int ArcComment,ArcVolume;

BOOL WINAPI _export IsArchive(char *Name,const unsigned char *Data,int DataSize)
{
  for (int I=0;I<DataSize-4;I++)
  {
    const unsigned char *D=Data+I;
    if (D[0]==0x60 && D[1]==0xea && D[3]<0xb && D[5]<0x40 && D[6]<0x40 &&
        D[7]<0x20 && (I==0 || I>0x20 && Data[0x1c]=='R' && Data[0x1d]=='J' &&
        Data[0x1e]=='S' && Data[0x1f]=='X'))
    {
      SFXSize=I;
      return(TRUE);
    }
  }
  return(FALSE);
}


BOOL WINAPI _export OpenArchive(char *Name,int *Type)
{
  struct ARJHd1
  {
    WORD Mark;
    WORD HeadSize;
    BYTE FirstHeadSize;
    BYTE ARJVer;
    BYTE ARJExtrVer;
    BYTE HostOS;
    BYTE Flags;
    BYTE Reserved1;
    BYTE FileType;
    BYTE Reserved2;
    DWORD ftime;
    DWORD Reserved3;
    DWORD Reserved4;
    DWORD Reserved5;
    WORD FileSpec;
  } ArjHeader;

  DWORD ReadSize;
  WORD ARJComm,ExtHdSize;
  ArcHandle=CreateFile(Name,GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE,
                       NULL,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,NULL);
  if (ArcHandle==INVALID_HANDLE_VALUE)
    return(FALSE);

  *Type=0;

  FileSize=GetFileSize(ArcHandle,NULL);

  SetFilePointer(ArcHandle,SFXSize,NULL,FILE_BEGIN);
  ReadFile(ArcHandle,&ArjHeader,sizeof(ArjHeader),&ReadSize,NULL);
  SetFilePointer(ArcHandle,SFXSize+ArjHeader.HeadSize+2,NULL,FILE_BEGIN);
  ReadFile(ArcHandle,&ARJComm,sizeof(ARJComm),&ReadSize,NULL);

  ArcComment=ArcVolume=FALSE;
  if (ArjHeader.Flags & 4)
    ArcVolume=TRUE;
  if (ARJComm!=0)
    ArcComment=TRUE;
  NextPosition=SetFilePointer(ArcHandle,4,NULL,FILE_CURRENT);
  ReadFile(ArcHandle,&ExtHdSize,sizeof(ExtHdSize),&ReadSize,NULL);
  NextPosition+=2;
  if (ExtHdSize>0)
    NextPosition+=ExtHdSize+4;
  return(TRUE);
}


int WINAPI _export GetArcItem(struct PluginPanelItem *Item,struct ArcItemInfo *Info)
{
  struct ARJHd2
  {
    WORD Mark;
    WORD HeadSize;
    BYTE FirstHeadSize;
    BYTE ARJVer;
    BYTE ARJExtrVer;
    BYTE HostOS;
    BYTE Flags;
    BYTE Method;
    BYTE FileType;
    BYTE Reserved;
    DWORD ftime;
    DWORD PackSize;
    DWORD UnpSize;
    DWORD CRC;
    WORD FileSpec;
    WORD AccessMode;
    WORD HostData;
  } ArjHeader;

  DWORD ReadSize;

  NextPosition=SetFilePointer(ArcHandle,NextPosition,NULL,FILE_BEGIN);
  if (NextPosition==0xFFFFFFFF)
    return(GETARC_READERROR);
  if (NextPosition>FileSize)
    return(GETARC_UNEXPEOF);
  if (!ReadFile(ArcHandle,&ArjHeader,sizeof(ArjHeader),&ReadSize,NULL))
    return(GETARC_READERROR);
  if (ReadSize==0 || ArjHeader.HeadSize==0)
    return(GETARC_EOF);
  if (ArjHeader.Flags & 8)
    SetFilePointer(ArcHandle,4,NULL,FILE_CURRENT);
  char Name[NM+1];
  if (!ReadFile(ArcHandle,Name,sizeof(Name),&ReadSize,NULL) || ReadSize==0)
    return(GETARC_READERROR);
  if (Name[strlen(Name)+1]!=0)
    Info->Comment=TRUE;
  strcpy(Item->FindData.cFileName,Name);

  DWORD PrevPosition=NextPosition;
  NextPosition+=8+ArjHeader.HeadSize;
  SetFilePointer(ArcHandle,NextPosition,NULL,FILE_BEGIN);
  WORD ExtHdSize;
  ReadFile(ArcHandle,&ExtHdSize,sizeof(ExtHdSize),&ReadSize,NULL);
  NextPosition+=2+ArjHeader.PackSize;
  if (ExtHdSize>0)
    NextPosition+=ExtHdSize+4;
  if (PrevPosition>=NextPosition)
    return(GETARC_BROKEN);

  if (ArjHeader.Flags & 1)
    Info->Encrypted=TRUE;
  Info->DictSize=32;

  Item->FindData.dwFileAttributes=ArjHeader.AccessMode & 0x3f;
  Item->PackSize=ArjHeader.PackSize;
  Item->FindData.nFileSizeLow=ArjHeader.UnpSize;
  FILETIME lft;
  DosDateTimeToFileTime(HIWORD(ArjHeader.ftime),LOWORD(ArjHeader.ftime),&lft);
  LocalFileTimeToFileTime(&lft,&Item->FindData.ftLastWriteTime);
  return(GETARC_SUCCESS);
}


BOOL WINAPI _export CloseArchive(struct ArcInfo *Info)
{
  Info->SFXSize=SFXSize;
  Info->Volume=ArcVolume;
  Info->Comment=ArcComment;
  return(CloseHandle(ArcHandle));
}


BOOL WINAPI _export GetFormatName(int Type,char *FormatName,char *DefaultExt)
{
  if (Type==0)
  {
    strcpy(FormatName,"ARJ");
    strcpy(DefaultExt,"ARJ");
    return(TRUE);
  }
  return(FALSE);
}


BOOL WINAPI _export GetDefaultCommands(int Type,int Command,char *Dest)
{
  if (Type==0)
  {
    static char *Commands[]={
      "arj x -+ {-g%%P} -v -y %%a !%%LM",
      "arj e -+ {-g%%P} -v -y %%a !%%LM",
      "arj t -+ -y {-g%%P} -v %%a !%%LM",
      "arj d -+ -y {-w%%W} %%A !%%LM",
      "arj c -+ -y {-w%%W} -z %%A",
      "arj c -+ -y {-w%%W} %%A !%%LM",
      "arj y -+ -je -y %%A",
      "",
      "",
      "",
      "arj a -+ -y -a1 {-g%%P} {-w%%W} %%A !%%LM",
      "arj m -+ -y -a1 {-g%%P} {-w%%W} %%A !%%LM",
      "arj a -+ -r -y -a1 {-g%%P} {-w%%W} %%A !%%LM",
      "arj m -+ -r -y -a1 {-g%%P} {-w%%W} %%A !%%LM",
      "*.*"
    };
    if (Command<sizeof(Commands)/sizeof(Commands[0]))
    {
      strcpy(Dest,Commands[Command]);
      return(TRUE);
    }
  }
  return(FALSE);
}

