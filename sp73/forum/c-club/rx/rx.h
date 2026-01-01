/*--------------------------------------------------------------------      */
/* rxvar.h                                                                  */
/*NOTE:                                                                     */
/*This is a completly experimental program in it's pre-beta version.        */
/*It is not guaranteed to work properly under all circumstances, although   */
/*it has been tested for a couple of weeks. Everyone who uses this program  */
/*does this on his own risk, so if your machine explodes, don't tell me     */
/*you didn't know.                                                          */
/*                                                                          */
/*Andreas Gruen releases this software "as is", with no express or          */
/*implied warranty, including, but not limited to, the implied warranties   */
/*of merchantability and fitness for a particular purpose.                  */
/*                                                                          */
/*This program is completly free for everyone.                              */
/*You can do with it and its sources whatever you want, but it would        */
/*be fine to leave my name somewhere in the program or startup-banner.      */
/*---------------------------------------------------------------------     */

typedef unsigned char UCHAR;
typedef unsigned short USHORT;
typedef unsigned long ULONG;

struct _doshead {           /* DOS EXE-header*/
  USHORT sign;              /* 'MZ' byte-swapped*/
  USHORT bonlpage;          /* bytes in last page */
  USHORT npageexe;          /* total # of pages (512 byte) in EXE*/
  USHORT nreloc;            /* # of relocation entries*/
  USHORT nparhead;
  USHORT minalloc;
  USHORT maxalloc;
  USHORT sp;
  USHORT ss;
  USHORT chksum;
  USHORT ip;
  USHORT cs;
  USHORT posreloc;
  USHORT overlay;
  UCHAR  reserv[28];
  UCHAR  oeminfo[4];
  ULONG  posnewhead;
  };

typedef struct _doshead DOSHEAD;

struct _oshead {
  USHORT sign;
  USHORT linkver;   /*swap*/
  USHORT posentrytab;
  USHORT szentrytab;   /* in Bytes */
  ULONG  crc;
  USHORT exeflags;
  USHORT ordautoseg;
  USHORT szheapsize;
  USHORT szdstack;
  USHORT ip;
  USHORT cs;
  USHORT sp;
  USHORT ss;
  USHORT nsegtab;
  USHORT nmodulref;
  USHORT sznrestab;
  USHORT possegtab;   /*from new head*/
  USHORT posrctab;
  USHORT posrestab;
  USHORT posmoduletab;
  USHORT posimporttab;
  USHORT posnrestab;
  USHORT nmoventry;
  USHORT nldsectsiz;
  USHORT reserv[12];
  };

typedef struct _oshead OSHEAD;

struct _rcentry {
  USHORT datp;
  USHORT len;
  USHORT flags;
  USHORT id;
  USHORT handle;
  USHORT nload;
  };

typedef struct _rcentry RCENTRY;

struct _bmhead {             /* that's a short Windows BITMAPINFOHEADER*/
  ULONG size;
  ULONG width;
  ULONG height;
  USHORT planes;
  USHORT bitcount;
  };

typedef struct _bmhead BMHEAD;

struct _iconhead {
  USHORT reserv1;                     /*0*/
  USHORT rctype;                      /*1*/
  USHORT count;                       /*1 images in file*/
  UCHAR  wid;
  UCHAR  hei;
  UCHAR  colors;
  UCHAR  reserv2;
  USHORT xhot;                         /* Hotspot x-position, currently 0*/
  USHORT yhot;
  ULONG  DIBsize;
  ULONG  DIBoff;
  };

typedef struct _iconhead ICONHEAD;
typedef struct _iconhead CURSORHEAD;   /*quite the same*/

struct _bmfhead {             /* that's Windows BITMAPFILEHEADER*/
  USHORT sign;
  ULONG fsize;
  USHORT reserv1;
  USHORT reserv2;
  ULONG offset;
  };

typedef struct _bmfhead BMFHEAD;

/* Menu-flags*/
#define MF_GRAYED       0x0001
#define MF_DISABLED     0x0002
#define MF_CHECKED      0x0008
#define MF_POPUP        0x0010
#define MF_MENUBARBREAK 0x0020
#define MF_MENUBREAK    0x0040
#define MF_END          0x0080

/*Dialog-defines*/
#define WS_OVERLAPPED       0x00000000L
#define WS_POPUP            0x80000000L
#define WS_CHILD            0x40000000L
#define WS_MINIMIZE         0x20000000L
#define WS_VISIBLE          0x10000000L
#define WS_DISABLED         0x08000000L
#define WS_CLIPSIBLINGS     0x04000000L
#define WS_CLIPCHILDREN     0x02000000L
#define WS_MAXIMIZE         0x01000000L
#define WS_CAPTION          0x00C00000L     /* !!!*/
#define WS_BORDER           0x00800000L
#define WS_DLGFRAME         0x00400000L
#define WS_VSCROLL          0x00200000L
#define WS_HSCROLL          0x00100000L
#define WS_SYSMENU          0x00080000L
#define WS_THICKFRAME       0x00040000L
#define WS_GROUP            0x00020000L
#define WS_TABSTOP          0x00010000L

#define WS_MINIMIZEBOX      0x00020000L
#define WS_MAXIMIZEBOX      0x00010000L

#define WS_EX_DLGMODALFRAME 0x00000001L
#define WS_EX_NOPARENTNOTIFY 0x00000004L

#define ES_LEFT             0x0000L
#define ES_CENTER           0x0001L
#define ES_RIGHT            0x0002L
#define ES_MULTILINE        0x0004L
#define ES_UPPERCASE        0x0008L
#define ES_LOWERCASE        0x0010L
#define ES_PASSWORD         0x0020L
#define ES_AUTOVSCROLL      0x0040L
#define ES_AUTOHSCROLL      0x0080L
#define ES_NOHIDESEL        0x0100L
#define ES_OEMCONVERT       0x0400L

#define LBS_NOTIFY            0x0001L
#define LBS_SORT              0x0002L
#define LBS_NOREDRAW          0x0004L
#define LBS_MULTIPLESEL       0x0008L
#define LBS_OWNERDRAWFIXED    0x0010L
#define LBS_OWNERDRAWVARIABLE 0x0020L
#define LBS_HASSTRINGS        0x0040L
#define LBS_USETABSTOPS       0x0080L
#define LBS_NOINTEGRALHEIGHT  0x0100L
#define LBS_MULTICOLUMN       0x0200L
#define LBS_WANTKEYBOARDINPUT 0x0400L
#define LBS_EXTENDEDSEL       0x0800L

#define CBS_SIMPLE            0x0001L
#define CBS_DROPDOWN          0x0002L
#define CBS_DROPDOWNLIST      0x0003L
#define CBS_OWNERDRAWFIXED    0x0010L
#define CBS_OWNERDRAWVARIABLE 0x0020L
#define CBS_AUTOHSCROLL       0x0040L
#define CBS_OEMCONVERT        0x0080L
#define CBS_SORT              0x0100L
#define CBS_HASSTRINGS        0x0200L
#define CBS_NOINTEGRALHEIGHT        0x0400L

#define SBS_HORZ                    0x0000L
#define SBS_VERT                    0x0001L
#define SBS_TOPALIGN                0x0002L
#define SBS_LEFTALIGN               0x0002L
#define SBS_BOTTOMALIGN             0x0004L
#define SBS_RIGHTALIGN              0x0004L
#define SBS_SIZEBOXTOPLEFTALIGN     0x0002L
#define SBS_SIZEBOXBOTTOMRIGHTALIGN 0x0004L
#define SBS_SIZEBOX                 0x0008L

#define BS_PUSHBUTTON      0x00L
#define BS_DEFPUSHBUTTON   0x01L
#define BS_CHECKBOX        0x02L
#define BS_AUTOCHECKBOX    0x03L
#define BS_RADIOBUTTON     0x04L
#define BS_3STATE          0x05L
#define BS_AUTO3STATE      0x06L
#define BS_GROUPBOX        0x07L
#define BS_USERBUTTON      0x08L
#define BS_AUTORADIOBUTTON 0x09L
#define BS_PUSHBOX         0x0AL
#define BS_OWNERDRAW       0x0BL
#define BS_LEFTTEXT        0x20L

#define SS_LEFT            0x00L
#define SS_CENTER          0x01L
#define SS_RIGHT           0x02L
#define SS_ICON            0x03L
#define SS_BLACKRECT       0x04L
#define SS_GRAYRECT        0x05L
#define SS_WHITERECT       0x06L
#define SS_BLACKFRAME      0x07L
#define SS_GRAYFRAME       0x08L
#define SS_WHITEFRAME      0x09L
#define SS_USERITEM        0x0AL
#define SS_SIMPLE          0x0BL
#define SS_LEFTNOWORDWRAP  0x0CL
#define SS_NOPREFIX        0x80L

#define DS_ABSALIGN         0x01L
#define DS_SYSMODAL         0x02L
#define DS_LOCALEDIT        0x20L
#define DS_SETFONT          0x40L
#define DS_MODALFRAME       0x80L
#define DS_NOIDLEMSG        0x100L

struct _nametab {
  USHORT type;
  USHORT num;
  char name[64];
} nametab [512];
