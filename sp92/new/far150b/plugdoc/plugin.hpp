#define NM 260

struct PluginPanelItem
{
  WIN32_FIND_DATA FindData;
  DWORD PackSizeHigh;
  DWORD PackSize;
  DWORD Flags;
  DWORD NumberOfLinks;
  char *Description;
  char *Owner;
  char **CustomColumnData;
  int CustomColumnNumber;
  DWORD Reserved[4];
};

#define PPIF_PROCESSDESCR 0x80000000
#define PPIF_SELECTED     0x40000000

enum {
  FMENU_SHOWAMPERSAND=1,
  FMENU_WRAPMODE=2,
  FMENU_AUTOHIGHLIGHT=4,
  FMENU_REVERSEAUTOHIGHLIGHT=8
};


typedef int (WINAPI *FARAPIMENU)(
  int PluginNumber,
  int X,
  int Y,
  int MaxHeight,
  unsigned int Flags,
  char *Title,
  char *Bottom,
  char *HelpTopic,
  int *BreakKeys,
  int *BreakCode,
  struct FarMenuItem *Item,
  int ItemsNumber
);

typedef int (WINAPI *FARAPIDIALOG)(
  int PluginNumber,
  int X1,
  int Y1,
  int X2,
  int Y2,
  char *HelpTopic,
  struct FarDialogItem *Item,
  int ItemsNumber
);

enum {
  FMSG_WARNING=1,
  FMSG_ERRORTYPE=2,
  FMSG_KEEPBACKGROUND=4,
  FMSG_DOWN=8,
  FMSG_LEFTALIGN=16
};

typedef int (WINAPI *FARAPIMESSAGE)(
  int PluginNumber,
  unsigned int Flags,
  char *HelpTopic,
  char **Items,
  int ItemsNumber,
  int ButtonsNumber
);

typedef char* (WINAPI *FARAPIGETMSG)(
  int PluginNumber,
  int MsgId
);


enum DialogItemTypes {
  DI_TEXT,
  DI_VTEXT,
  DI_SINGLEBOX,
  DI_DOUBLEBOX,
  DI_EDIT,
  DI_PSWEDIT,
  DI_FIXEDIT,
  DI_BUTTON,
  DI_CHECKBOX,
  DI_RADIOBUTTON
};

enum FarDialogItemFlags {
  DIF_COLORMASK       =    0xff,
  DIF_SETCOLOR        =   0x100,
  DIF_BOXCOLOR        =   0x200,
  DIF_GROUP           =   0x400,
  DIF_LEFTTEXT        =   0x800,
  DIF_MOVESELECT      =  0x1000,
  DIF_SHOWAMPERSAND   =  0x2000,
  DIF_CENTERGROUP     =  0x4000,
  DIF_NOBRACKETS      =  0x8000,
  DIF_SEPARATOR       = 0x10000,
  DIF_EDITOR          = 0x20000,
  DIF_HISTORY         = 0x40000
};

struct FarDialogItem
{
  int Type;
  int X1,Y1,X2,Y2;
  int Focus;
  int Selected;
  unsigned int Flags;
  int DefaultButton;
  char Data[512];
};


struct FarMenuItem
{
  char Text[128];
  int Selected;
  int Checked;
  int Separator;
};


enum {FCTL_CLOSEPLUGIN,FCTL_GETPANELINFO,FCTL_GETANOTHERPANELINFO,
      FCTL_UPDATEPANEL,FCTL_UPDATEANOTHERPANEL,
      FCTL_REDRAWPANEL,FCTL_REDRAWANOTHERPANEL,
      FCTL_SETANOTHERPANELDIR,FCTL_GETCMDLINE,FCTL_SETCMDLINE,
      FCTL_SETSELECTION,FCTL_SETANOTHERSELECTION
};

enum {PTYPE_FILEPANEL,PTYPE_TREEPANEL,PTYPE_QVIEWPANEL,PTYPE_INFOPANEL};

struct PanelInfo
{
  int PanelType;
  int Plugin;
  RECT PanelRect;
  PluginPanelItem *PanelItems;
  int ItemsNumber;
  PluginPanelItem *SelectedItems;
  int SelectedItemsNumber;
  int CurrentItem;
  int TopPanelItem;
  int Visible;
  int Focus;
  int ViewMode;
  char ColumnTypes[80];
  char ColumnWidths[80];
  char CurDir[NM];
  DWORD Reserved[4];
};


struct PanelRedrawInfo
{
  int CurrentItem;
  int TopPanelItem;
};


typedef int (WINAPI *FARAPICONTROL)(
  HANDLE hPlugin,
  int Command,
  void *Param
);

typedef HANDLE (WINAPI *FARAPISAVESCREEN)(int X1,int Y1,int X2,int Y2);

typedef void (WINAPI *FARAPIRESTORESCREEN)(HANDLE hScreen);

typedef int (WINAPI *FARAPIGETDIRLIST)(
  char *Dir,
  struct PluginPanelItem **pPanelItem,
  int *pItemsNumber
);

typedef int (WINAPI *FARAPIGETPLUGINDIRLIST)(
  int PluginNumber,
  HANDLE hPlugin,
  char *Dir,
  struct PluginPanelItem **pPanelItem,
  int *pItemsNumber
);

typedef void (WINAPI *FARAPIFREEDIRLIST)(struct PluginPanelItem *PanelItem);

typedef int (WINAPI *FARAPIVIEWER)(
  char *FileName,
  char *Title,
  int X1,
  int Y1,
  int X2,
  int Y2,
  DWORD Flags
);

typedef int (WINAPI *FARAPIEDITOR)(
  char *FileName,
  char *Title,
  int X1,
  int Y1,
  int X2,
  int Y2,
  DWORD Flags,
  int StartLine,
  int StartChar
);

typedef int (WINAPI *FARAPICMPNAME)(
  char *Pattern,
  char *String,
  int SkipPath
);

struct PluginStartupInfo
{
  int StructSize;
  char ModuleName[NM];
  int ModuleNumber;
  char *RootKey;
  FARAPIMENU Menu;
  FARAPIDIALOG Dialog;
  FARAPIMESSAGE Message;
  FARAPIGETMSG GetMsg;
  FARAPICONTROL Control;
  FARAPISAVESCREEN SaveScreen;
  FARAPIRESTORESCREEN RestoreScreen;
  FARAPIGETDIRLIST GetDirList;
  FARAPIGETPLUGINDIRLIST GetPluginDirList;
  FARAPIFREEDIRLIST FreeDirList;
  FARAPIVIEWER Viewer;
  FARAPIEDITOR Editor;
  FARAPICMPNAME CmpName;
};


enum PLUGIN_FLAGS {
  PF_PRELOAD = 0x0001
};


struct PluginInfo
{
  int StructSize;
  DWORD Flags;
  char **DiskMenuStrings;
  int *DiskMenuNumbers;
  int DiskMenuStringsNumber;
  char **PluginMenuStrings;
  int PluginMenuStringsNumber;
  char **PluginConfigStrings;
  int PluginConfigStringsNumber;
  char *CommandPrefix;
};


struct InfoPanelLine
{
  char Text[80];
  char Data[80];
  int Separator;
};


struct PanelMode
{
  char *ColumnTypes;
  char *ColumnWidths;
  char **ColumnTitles;
  int FullScreen;
  int DetailedStatus;
  int AlignExtensions;
  int CaseConversion;
  char *StatusColumnTypes;
  char *StatusColumnWidths;
  DWORD Reserved[2];
};


enum OPENPLUGININFO_FLAGS {
  OPIF_USEFILTER               = 0x0001,
  OPIF_USESORTGROUPS           = 0x0002,
  OPIF_USEHIGHLIGHTING         = 0x0004,
  OPIF_ADDDOTS                 = 0x0008,
  OPIF_RAWSELECTION            = 0x0010,
  OPIF_REALNAMES               = 0x0020,
  OPIF_SHOWNAMESONLY           = 0x0040,
  OPIF_SHOWRIGHTALIGNNAMES     = 0x0080,
  OPIF_SHOWPRESERVECASE        = 0x0100,
  OPIF_FINDFOLDERS             = 0x0200,
  OPIF_COMPAREFATTIME          = 0x0400,
  OPIF_EXTERNALGET             = 0x0800,
  OPIF_EXTERNALPUT             = 0x1000,
  OPIF_EXTERNALDELETE          = 0x2000,
  OPIF_EXTERNALMKDIR           = 0x4000
};


enum OPENPLUGININFO_SORTMODES {
  SM_DEFAULT,SM_UNSORTED,SM_NAME,SM_EXT,SM_MTIME,SM_CTIME,
  SM_ATIME,SM_SIZE,SM_DESCR,SM_OWNER
};


struct KeyBarTitles
{
  char *Titles[12];
  char *CtrlTitles[12];
  char *AltTitles[12];
  char *ShiftTitles[12];
};


struct OpenPluginInfo
{
  int StructSize;
  DWORD Flags;
  char *HostFile;
  char *CurDir;
  char *Format;
  char *PanelTitle;
  struct InfoPanelLine *InfoLines;
  int InfoLinesNumber;
  char **DescrFiles;
  int DescrFilesNumber;
  struct PanelMode *PanelModesArray;
  int PanelModesNumber;
  int StartPanelMode;
  int StartSortMode;
  int StartSortOrder;
  struct KeyBarTitles *KeyBar;
  char *ShortcutData;
};

enum {
  OPEN_DISKMENU,
  OPEN_PLUGINSMENU,
  OPEN_FINDLIST,
  OPEN_SHORTCUT,
  OPEN_COMMANDLINE
};

enum {PKF_CONTROL=1,PKF_ALT=2,PKF_SHIFT=4};

enum FAR_EVENTS {
  FE_CHANGEVIEWMODE,
  FE_REDRAW,
  FE_IDLE,
  FE_CLOSE
};

enum OPERATION_MODES {
  OPM_SILENT=1,
  OPM_FIND=2,
  OPM_VIEW=4,
  OPM_EDIT=8,
  OPM_TOPLEVEL=16
};
