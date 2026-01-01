
/* BULLET.H   5-Jan-95-chh
 * 9-Jan-95-chh added "far" to *PSZ def
 *
 *  Bullet header for DOS 16-bit C/C++
 *
 */

#ifndef __BULLET_H
#define __BULLET_H

#pragma pack(1)

#define VOID void
#define SHORT short
#define LONG long

typedef unsigned char BYTE;
typedef unsigned short USHORT;
typedef unsigned long ULONG;
typedef unsigned char far *PSZ;
typedef VOID far *PVOID;

#ifdef __cplusplus
   extern "C" {
#endif
int  far pascal BULLET(PVOID);
#ifdef __cplusplus
   }
#endif

#define INITXB          0  /* system */
#define EXITXB          1
#define ATEXITXB        2
#define MEMORYXB        3
#define BREAKXB         4
#define BACKUPFILEXB    5
#define STATHANDLEXB    6
#define GETEXTERRORXB   7
#define DVMONCXB        9

#define CREATEDXB       10 /* data control mid-level */
#define OPENDXB         11
#define CLOSEDXB        12
#define STATDXB         13
#define READDHXB        14
#define FLUSHDHXB       15
#define COPYDHXB        16
#define ZAPDHXB         17

#define CREATEKXB       20 /* key control mid-level */
#define OPENKXB         21
#define CLOSEKXB        22
#define STATKXB         23
#define READKHXB        24
#define FLUSHKHXB       25
#define COPYKHXB        26
#define ZAPKHXB         27

#define GETDESCRIPTORXB 30 /* data access mid-level */
#define GETRECORDXB     31
#define ADDRECORDXB     32
#define UPDATERECORDXB  33
#define DELETERECORDXB  34
#define UNDELETERECORDXB 35
#define PACKRECORDSXB   36

#define FIRSTKEYXB      40 /* key access mid-level */
#define EQUALKEYXB      41
#define NEXTKEYXB       42
#define PREVKEYXB       43
#define LASTKEYXB       44
#define STOREKEYXB      45
#define DELETEKEYXB     46
#define BUILDKEYXB      47
#define CURRENTKEYXB    48

#define GETFIRSTXB      60 /* key and data access high-level */
#define GETEQUALXB      61
#define GETNEXTXB       62
#define GETPREVXB       63
#define GETLASTXB       64
#define INSERTXB        65
#define UPDATEXB        66
#define REINDEXXB       67

#define LOCKXB          80 /* network control */
#define UNLOCKXB        81
#define LOCKKEYXB       82
#define UNLOCKKEYXB     83
#define LOCKDATAXB      84
#define UNLOCKDATAXB    85
#define DRIVEREMOTEXB   86
#define FILEREMOTEXB    87
#define SETRETRIESXB    88

#define DELETEFILEDOS   100/* DOS file I/O low-level */
#define RENAMEFILEDOS   101
#define CREATEFILEDOS   102
#define OPENFILEDOS     103
#define SEEKFILEDOS     104
#define READFILEDOS     105
#define WRITEFILEDOS    106
#define CLOSEFILEDOS    107
#define ACCESSFILEDOS   108
#define EXPANDFILEDOS   109
#define MAKEDIRDOS      110

#define cUNIQUE         1  /* key type flags */
#define cCHAR           2
#define cINTEGER        16
#define cLONG           32
#define cNLS            0x4000  /* note: cNLS is set by BULLET */
#define cSIGNED         0x8000

#define READONLY        0  /* do NOT use O_RDONLY,O_WRONLY,O_RDWR */
#define WRITEONLY       1
#define READWRITE       2

#define COMPAT          0X0000  /* okay to use SH_DENYRW, etc. */
#define DENYREADWRITE   0x0010  /* or O_DENYREADWRITE, etc.    */
#define DENYWRITE       0x0020
#define DENYREAD        0x0030
#define DENYNONE        0x0040
#define NOINHERIT       0x0080


struct AccessPack {
USHORT  func;
USHORT  stat;
USHORT  handle;
LONG    recNo;  /* signed */
PVOID   recPtr;
PVOID   keyPtr;
PVOID   nextPtr;
};

struct BreakPack {
USHORT  func;
USHORT  stat;
USHORT  mode;
};

struct CopyPack {
USHORT  func;
USHORT  stat;
USHORT  handle;
PSZ     filenamePtr;
};

struct CreateDataPack {
USHORT  func;
USHORT  stat;
PSZ     filenamePtr;
USHORT  noFields;
PVOID   fieldListPtr;
USHORT  fileID;
};

struct CreateKeyPack {
USHORT  func;
USHORT  stat;
PSZ     filenamePtr;
PSZ     keyExpPtr;
USHORT  xbLink;
USHORT  keyFlags;
USHORT  codePageID;
USHORT  countryCode;
PVOID   collatePtr;
};

struct FieldDescType {
BYTE    fieldName[11];
BYTE    fieldType;
LONG    fieldDA;
BYTE    fieldLen;
BYTE    fieldDC;
LONG    fieldRez;
BYTE    filler[10];
};

struct DescriptorPack {
USHORT  func;
USHORT  stat;
USHORT  handle;
USHORT  fieldnumber;
struct  FieldDescType fd;
};

struct DosFilePack {
USHORT  func;
USHORT  stat;
PSZ     filenamePtr;
USHORT  handle;
USHORT  asMode;
USHORT  bytes;
LONG    seekOffset;
USHORT  method;
PVOID   bufferPtr;
USHORT  attr;
PSZ     newNamePtr;
};

struct DVmonPack {
USHORT  func;
USHORT  stat;
USHORT  mode;
USHORT  handle;
USHORT  vs;
};

struct ExitPack {
USHORT  func;
USHORT  stat;
};

struct HandlePack {
USHORT  func;
USHORT  stat;
USHORT  handle;
};

struct InitPack {
USHORT  func;
USHORT  stat;
USHORT  JFTmode;
USHORT  DOSver;
USHORT  version;
USHORT  OSversion;
ULONG   exitPtr;
};

struct MemoryPack {
USHORT  func;
USHORT  stat;
ULONG   memory;
};

struct OpenPack {
USHORT  func;
USHORT  stat;
USHORT  handle;
PSZ     filenamePtr;
USHORT  asMode;
USHORT  xbLink;
};

struct RemotePack {
USHORT  func;
USHORT  stat;
USHORT  handle;
USHORT  isRemote;
USHORT  flags;
USHORT  isShare;
};

struct SetRetriesPack {
USHORT  func;
USHORT  stat;
USHORT  mode;
USHORT  pause;
USHORT  retries;
};

struct StatDataPack {
USHORT  func;
USHORT  stat;
USHORT  handle;
BYTE    fileType;
BYTE    dirty;
ULONG   recs;
USHORT  recLen;
USHORT  fields;
BYTE    f1;
BYTE    LUyear;
BYTE    LUmonth;
BYTE    LUday;
USHORT  hereseg;
BYTE    filler[10];
};

struct StatKeyPack {
USHORT  func;
USHORT  stat;
USHORT  handle;
BYTE    fileType;
BYTE    dirty;
ULONG   keys;
USHORT  keyLen;
USHORT  xbLink;
ULONG   xbRecNo;
USHORT  hereSeg;
USHORT  codePageID;
USHORT  countryCode;
USHORT  collateTableSize;
USHORT  keyFlags;
BYTE    filler[2];
};

struct StatHandlePack {
USHORT  func;
USHORT  stat;
USHORT  handle;
USHORT  ID;
PSZ     filenamePtr;
};

struct XerrorPack {
USHORT  func;
USHORT  stat;
USHORT  errclass;
USHORT  action;
USHORT  location;
};

#pragma pack()

#endif /* ifndef __BULLET_H */
