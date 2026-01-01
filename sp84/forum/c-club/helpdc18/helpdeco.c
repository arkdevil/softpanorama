/* HELPDECO - Utility-Programm zum Zerlegen von Windows Hilfedateien
// HELPDECO - utility program to dissect Windows help files
//
// HELPDECO zerlegt eine HLP-Datei von Windows 3.0, 3.1, 3.11 und '95 und
// viele MVB-Dateien des Multimedia-Viewers in alle für den jeweiligen
// Hilfecompiler HC30, HC31, HCP, HCW, HCRTF, WMVC, MMVC oder MVC zum
// erneuten Zusammenbau erforderlichen Dateien. Dazu gehören:
// HPJ - die Projektdatei, als Parameter für den Hilfecompiler anzugeben
// MVP - die Multimediaprojektdatei, als Parameter für den MM-Compiler
// RTF - die Textdatei mit dem gesamten Hilfetext und allen Fußnoten
// PH  - die Phrasen-Datei (wie sie auch vom Hilfecompiler erzeugt wird)
// ICO - ein eventuell der Hilfedatei zugeordnetes Icon
// BMP/WMF/SHG/MRB - alle Bilder in Dateien mit passendem Format
// Baggage - alle als Baggage in der Hilfedatei enthaltenen Dateien
//
// HELPDECO dissects Windows 3.0, 3.1, 3.11 und '95 HLP files and many
// multi media viewer MVB files into all files required for a rebuild using
// appropriate help compiler HC30, HC31, HCP, HCW, HCRTF, WMVC, MMVC or MVC:
// HPJ - help project file, use as parameter when calling help compiler
// MVP - multi media project file, parameter for multi media help compiler
// RTF - text file containing whole content of help file and all footnotes
// PH  - phrases file (same as produced by help compiler)
// ICO - icon of help file if embedded
// BMP/WMF/SHG/MRB - embedded pictures in appropriate format
// Baggage - all baggage files contained in help file
//
// HELPDECO wird von der MS-DOS Kommandozeile aus mit dem Namen der zu
// bearbeitenden Datei, eventuell dem Namen einer internen Datei und
// eventuellen Optionen aufgerufen. HELPDECO läuft von der Kommandozeile
// von Windows 95 oder Windows NT als 32-bit Applikation.
// Call HELPDECO from MS-DOS command line. Supply name of help file
// to use, optional name of internal file, and options if appropriate.
// HELPDECO executes from Windows 95 or Windows NT command line as 32 bit
// application.
//
// HELPDECO
// Zeigt Benutzungshinweise
// Displays usage
//
// HELPDECO helpfilename
// Zerlegt die Hilfedatei in alle zum erneuten Zusammenbau benötigten
// Dateien. Diese Dateien werden im aktuellen (möglichst leeren)
// Verzeichnis abgelegt. Existierende Dateien werden ohne Rückfrage
// überschrieben wenn die Option /y angegeben wird.
// Decompiles help file into all sources needed for rebuild. All files
// are created in current directory (should be empty). Existing files
// will be overwritten without asking if option /y was specified.
//
// Options: /m kann verwendet werden, um das Durchsuchen von macros
//             nach Topicnamen zu verhindern, wenn dabei Probleme
//             auftreten. Hilfecompiler wird Warnung 4131 melden.
//             May be used to stop parsing macros for topic names.
//             Help compiler will emit Warning 4131.
//          /b kann verwendet werden, um das Auflösen von Browse-
//             Sequenzen zu verhindern, wenn dabei Probleme auftreten.
//             Hilfequelltextdatei enthält dann keine +-Fußnoten.
//             May be used to stop resolving browse sequences. Help
//             source file than contains no + footnotes.
//          /w Erlaubt die Anzeige von Warnungen, die die Meldung 'HELPDECO
//             had problems with' erklären.
//             Enables display of warnings explaining message 'HELPDECO
//             had problems with'.
//
// HELPDECO helpfilename /a [annotationfilename.ANN]
// Wie HELPDECO helpfilename, fügt aber zusätzlich alle Anmerkungen aus der
// Anmerkungsdatei als Anmerkungen des Benutzers ANN in die RTF-Datei ein.
// Fehlt der annotationfilename, verwendet HELPDECO helpfilename.ANN dafür.
// Works like HELPDECO helpfilename, but additionally adds all annotations
// from annotationfile as hidden annotations from user ANN into RTF file.
// Default annotationfilename is helpfilename.ANN.
//
// HELPDECO helpfilename /r
// Erzeugt aus der Hilfedatei eine RTF-Datei, die von WinWord geladen
// dasselbe Aussehen hat wie die von WinHelp angezeigten Hilfeseiten.
// Damit kann eine Hilfedatei komplett gedruckt oder weiterverarbeitet
// werden.
// Converts help file into RTF file of same appearance if loaded into
// WinWord as if displayed by WinHelp. To print or work with complete
// content.
//
// HELPDECO helpfilename /c
// Erzeugt aus der Hilfedatei eine *.CNT-Datei für WinHlp32, die alle
// Kapitel mit Überschriften in der Reihenfolge enthält, in der sie in
// der Hilfedatei auftreten. Die Datei muß dann mit HCW 4.00 oder einem
// Texteditor in eine hierarchische Struktur überarbeitet werden.
// Generates a *.CNT file used by WinHlp32, containing all chapters that
// have titles assigned in the order they appear in the helpfile. This
// file should then be edited using HCW 4.00 or any text editor into a
// hierarchical order.
//
// HELPDECO helpfilename /e
// Zeigt alle Referenzen auf externe Hilfedateien. Option /f zeigt zusätzlich
// die Titel der Topics an, wo die externen Referenzen auftraten.
// Lists all references to external help files. Option /f additionally shows
// titles of topics that contained the external references.
//
// HELPDECO helpfilename /p
// Prüft Referenzen auf externe Hilfedateien.
// Checks references to external help files.
//
// HELPDECO helpfilename /d
// Zeigt das interne Inhaltsverzeichnis der Hilfedatei. Es kann auch eine
// *.ANN Datei anstelle der Hilfedatei angegeben werden.
// Displays internal directory of help file. You may supply an *.ANN file
// instead of the help file name.
//
// HELPDECO helpfilename /x
// Zeigt das interne Inhaltsverzeichnis als HexDump
// Displays hex dump of internal directory
//
// HELPDECO helpfilename "internalfilename"
// Zeigt die genannte interne Datei in einem passenden Format an, soweit
// die interne Datei anzeigbar ist, sonst als HexDump
// Displays internal file in appropriate format if known, else hex dump
//
// HELPDECO helpfilename "internalfilename" /x
// Zeigt die genannte interne Datei als HexDump
// Displays hex dump of internal file
//
// HELPDECO helpfilename "internalfilename" filename
// Exportiert die genanntet interne Datei in filename
// Exports internal file into filename
//
// *.ANN, *.CAC, *.AUX
// Diese Dateien sind auch wie Hilfedateien formatiert, HELPDECO kann aber
// nur verwendet werden, um ihr Inhaltsverzeichnis anzuzeigen oder um
// einzelne Dateien anzuzeigen oder zu exportieren.
// These files are formatted like helpfiles, but HELPDECO can only be used
// to display their internal directory or display or export embedded files.
//
// HELPDECO wurde erstellt von / was written by
// Manfred Winterhoff, Geschw.-Scholl-Ring 17, 38444 Wolfsburg, Germany
// CIS 100326,2776
//
// Informieren Sie mich, wenn Sie HELPDECO modifizieren oder erweitern um
// mehr Features und größere Hilfedateien zu bearbeiten. Sie wollen wirklich
// kommentierte Quelltexte ? HELPDECO.C ist bereits 250k gross.
// Please give me a note if you modify HELPDECO to handle more formats or
// bigger help files. You really want commented source ? HELPDECO.C is
// already at 250k.
//
// HELPDECO basiert auf HELPDUMP von Pete Davis veröffentlicht in:
// HELPDECO is based upon HELPDUMP from Pete Davis published in:
// The Windows Help File Format, Dr. Dobbs Journal, Sep/Oct 1993
//
// Die neueste Version von HELPDECO befindet sich stets in:
// The newest public version of HELPDECO is always available at:
// CompuServe Dr. Dobbs Journal DDJFOR Undocumented Corner HELPDCxx.ZIP
//
// HELPDECO ist public domain Software. Der Einsatz erfolgt auf eigene
// Gefahr. Kein Programmteil darf kommerziell verwendet werden. Für das
// Kopieren dürfen keine Gebühren verlangt werden (Sharewarehandel
// Finger weg). Immer auch die Quelltexte weitergeben, da es für einige
// Hilfedateien erforderlich sein kann, das Programm zu verändern.
// HELPDECO is donated to the public domain. Use at your own risk. No
// part of the program may be used commercially. No fees may be charged
// on distributing the program (shareware distributors keep off).
// Always distribute with source as it may be neccessary to modify the
// program to handle certain help files.
//
// Version 1.8: used some spare days to clean up the to-do list...
// better tracking of TopicOffset during decompilation
// lists and checks references to external files, shows referencing topics
// can add annotations from .ANN file to decompiled .RTF file
// fixed bug in handling of pictures containing JumpId-macro hotspots
// changed parsing of macros (3rd attempt to guess what Microsoft did)
// fixed bug in popup/jump to external file / secondary window
// fixed bug in > footnote / |VIOLA internal file handling
// fixed bug in keyword assignment
// now removes LZ77 compression from exported SHGs/MRBs
// recreates Win 95 (HCW 4.00) [MACROS] section from internal |Rose file
// 32 bit version available
// handles LANGUAGE, [CHARTAB] and [GROUP] section of media view files
//
// Version 1.7
// removed unneccessary output statement
//
// Version 1.6 can now check references to external help files plus:
// duplicate macro names preceeding picture hotspot info skipped
// does not write Win95 commands to multi-media help project files
// changed unhash to circumvent Microsoft-C++ float rounding error
// handles keywords defined inside topic text
//
// Version 1.5
// fixed static on buffer of TopicName function (affected HC30 files)
//
// Version 1.4 fixes some bugs reported by different users:
// buffer overflow in expanding LZ77&RunLen (byPacked 3) images fixed
// embedded images {bmxwd} larger than 32k supported
// extract topic names from jump into external file if no file specified
// handles more phrases on HCRTF generated (Win95) help files
// Windows 3.1 (HC31) |Phrases always Zeck compressed
// LinkData2 buffer enlarged 1 byte to store trailing NUL character
//
// Version 1.3
// parses examples of {bmc} etc. statements contained in help text correctly
// can now generate a *.CNT content file for Windows 95 / WinHlp32
// Microsoft C: ctype macros (isalnum/isprint) don't work with signed char
//
// Version 1.2 fixes some severe bugs introduced in version 1.1 and:
// tells you which help compiler to use
// collects multiple keyword footnotes into single lines
// handles \r\n in COPYRIGHT
// converts SPC-macro (but only in [CONFIG] section)
// does not generate duplicate MAP-statements if possible
// {button} and {mci,mci_left,mci_right} commands supported
// [BITMAP]-section in HCRTF help files irritated transparent bitmaps
//
// Version 1.1 now supports more features of Win95/HCRTF 4.00/WinHlp32:
// Supports LCID, CHARSET, AUTO-SIZE HEIGHT, CNT, INDEX_SEPARATORS
// Additional Win95 Macros (to extract original topic names)
// [CONFIG:n] of Win95 supported (internal file |CFn)
// Secondary windows with > footnote supported (internal file |VIOLA)
// Transparent bitmaps supported (bmct,bmlt,bmrt)
// Expanded internal limits as HCRTF allows larger items
// Now does RunLen compressed device dependend bitmaps
// Bugs in handling of metafiles removed
// Bug in placement of pack(1) removed
// Parsing of macros changed (is it really better now ?)
//
// HELPDECO wurde mit über 500 Hilfedateien getestet. Aber einige gehen nicht:
// HELPDECO was tested with more than 500 help files. But some don't work:
// PRINTMAN.HLP      50.743 03/10/92  3:10 (Hilfe zum Druck-Manager) corrupt
// WHATSNEW.HLP      92.649 09/26/94 11:38 (Dr. GUI's Espresso Stand -- October 1994)
//   HELPDECO does not mark 'Espresso Stand' in Topic 'The Back Page' correctly.
//   HCP issued Warning 4171: topic..13 of WHATSNEW.RTF : Cannot use secondary window with popup....
// DK_DOC.MVB     3.974.572 11/18/93 23:00 (VfW 1.1e) Can not link...
// DK_DOC.HLP     2.673.969 11/19/93  0:00 Can not link...
// WIN31WH.HLP    3.390.373  8/14/93 17:28 (Windows 3.1 SDK) Can not link...
*/
#include <time.h>
#include <malloc.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>

/* compile in large memory model if large help files should be handled
// neccessary compiler options using Borland C/C++:
//   bcc -ml -K -Os helpdeco.c
// To compile using Microsoft VC4.0 create a new workspace for a WIN32
// console application, insert HELPDECO.C into it and compile.
// byte align !
*/
#ifdef __TURBOC__
typedef struct { char a,b,c; } align;
#if sizeof(align)!=3
#error Compile bytealigned
#endif
#else
#pragma pack(1)
#endif

typedef struct               /* structure at beginning of help file */
{
    long Magic;              /* 0x00035F3F */
    long DirectoryStart;     /* offset of FILEHEADER of internal direcory */
    long NonDirectoryStart;  /* offset of FILEHEADER or -1L */
    long EntireFileSize;     /* size of entire help file in bytes */
}
HELPHEADER;

typedef struct FILEHEADER    /* structure at FileOffset of each internal file */
{
    long ReservedSpace;      /* reserved space in help file incl. FILEHEADER */
    long UsedSpace;          /* used space in help file excl. FILEHEADER */
    unsigned char FileFlags; /* normally 4 */
}
FILEHEADER;

typedef struct BTREEHEADER   /* structure after FILEHEADER of each Btree */
{
    unsigned short Magic;    /* 0x293B */
    unsigned short Flags;    /* bit 0x0002 always 1, bit 0x0400 1 if direcory */
    unsigned short PageSize; /* 0x0400=1k if directory, 0x0800=2k else */
    unsigned char Structure[16]; /* string describing structure of data */
    short MustBeZero;        /* 0 */
    short PageSplits;        /* number of page splits Btree has suffered */
    short RootPage;          /* page number of Btree root page */
    short MustBeNegOne;      /* 0xFFFF */
    short TotalPages;        /* number of Btree pages */
    short NLevels;           /* number of levels of Btree */
    long TotalBtreeEntries;  /* number of entries in Btree */
}
BTREEHEADER;

typedef struct BTREEINDEXHEADER /* structure at beginning of every index-page */
{
    unsigned short Unknown;  /* sorry, no ID to identify an index-page */
    short NEntries;          /* number of entries in this index-page */
    short PreviousPage;      /* page number of previous page */
}
BTREEINDEXHEADER;

typedef struct BTREENODEHEADER /* structure at beginning of every leaf-page */
{
    unsigned short Unknown;  /* Sorry, no ID to identify a leaf-oage */
    short NEntries;          /* number of entires in this leaf-page */
    short PreviousPage;      /* page number of preceeding leaf-page or -1 */
    short NextPage;          /* page number of next leaf-page or -1 */
}
BTREENODEHEADER;

typedef struct SYSTEMHEADER  /* structure at beginning of |SYSTEM file */
{
    unsigned short Magic;    /* 0x036C */
    unsigned char Version;   /* version number */
    unsigned char Always0;
    unsigned short Always1;
    time_t GenDate;          /* date/time that the help file was generated or 0 */
    unsigned short Flags;    /* tells you how the help file is compressed */
}
SYSTEMHEADER;

typedef struct               /* internal structure */
{
    FILE *File;
    long SavePos;
    long Remaining;
    unsigned short RecordType; /* type of data in record */
    unsigned short DataSize;   /* size of data */
    char Data[1];
}
SYSTEMRECORD;

typedef struct SECWINDOW     /* structure of data following RecordType 6 */
{
    unsigned short Flags;    /* flags (See Below) */
    char Type[10];           /* type of window */
    char Name[9];            /* window name */
    char Caption[51];        /* caption for window */
    short X;                 /* x coordinate of windows (0..1000) */
    short Y;                 /* y coordinate of window (0..1000) */
    short Width;             /* width of windows (0..1000) */
    short Height;            /* height of windows (0..1000) */
    short Maximize;          /* maximize flag and window styles */
    unsigned char Rgb[3];    /* color of scrollable region */
    unsigned char Unknown1;
    unsigned char RgbNsr[3]; /* color of non-scrollable region */
    unsigned char Unknown2;
}
SECWINDOW;

typedef struct               /* structure of data following RecordType 14 */
{
    char btreename[10];
    char mapname[10];
    char dataname[10];
    char title[80];
}
KEYINDEX;

#define WSYSFLAG_TYPE           0x0001  /* Type is valid */
#define WSYSFLAG_NAME           0x0002  /* Name is valid */
#define WSYSFLAG_CAPTION        0x0004  /* Caption is valid */
#define WSYSFLAG_X              0x0008  /* X is valid */
#define WSYSFLAG_Y              0x0010  /* Y is valid */
#define WSYSFLAG_WIDTH          0x0020  /* Width is valid */
#define WSYSFLAG_HEIGHT         0x0040  /* Height is valid */
#define WSYSFLAG_MAXIMIZE       0x0080  /* Maximize is valid */
#define WSYSFLAG_RGB            0x0100  /* Rgb is valid */
#define WSYSFLAG_RGBNSR         0x0200  /* RgbNsr is valid */
#define WSYSFLAG_TOP            0x0400  /* On top was set in HPJ file */
#define WSYSFLAG_AUTOSIZEHEIGHT 0x0800  /* Auto-Size Height */

typedef struct PHRINDEXHDR   /* structure of beginning of |PhrIndex file */
{
    long always4A01;              /* sometimes 0x0001 */
    long entries;                 /* number of phrases */
    long compressedsize;          /* size of PhrIndex file */
    long phrimagesize;            /* size of decompressed PhrImage file */
    long phrimagecompressedsize;  /* size of PhrImage file */
    long always0;
    unsigned short bits:4;
    unsigned short unknown:12;
    unsigned short always4A00;    /* sometimes 0x4A01, 0x4A02 */
}
PHRINDEXHDR;

typedef struct FONTHEADER    /* structure of beginning of |FONT file */
{
    unsigned short NumFacenames;       /* number of face names */
    unsigned short NumDescriptors;     /* number of font descriptors */
    unsigned short FacenamesOffset;    /* offset of face name array */
    unsigned short DescriptorsOffset;  /* offset of descriptors array */
    unsigned short NumFormats;         /* only if FacenamesOffset >= 12 */
    unsigned short FormatsOffset;      /* offset of formats array */
    unsigned short NumCharmaps;
    unsigned short CharmapsOffset;
}
FONTHEADER;

typedef struct FONTDESCRIPTOR /* internal font descriptor */
{
    unsigned char Attributes;
    unsigned char HalfPoints;
    unsigned char FontFamily;
    unsigned short FontName;
    unsigned char FGRGB[3];
    unsigned char BGRGB[3];
    unsigned short style;
    short expndtw;
    signed char up;
}
FONTDESCRIPTOR;

typedef struct                /* non-Multimedia font descriptor */
{
    unsigned char Attributes; /* Font Attributes See values below */
    unsigned char HalfPoints; /* PointSize * 2 */
    unsigned char FontFamily; /* Font Family. See values below */
    unsigned short FontName;  /* Number of newfont in Font List */
    unsigned char FGRGB[3];   /* RGB values of foreground */
    unsigned char BGRGB[3];   /* unused background RGB Values */
}
OLDFONT;

typedef struct NEWFONT        /* structure located at DescriptorsOffset */
{
    unsigned char unknown1;
    short FontName;
    unsigned char FGRGB[3];
    unsigned char BGRGB[3];
    unsigned char unknown5;
    unsigned char unknown6;
    unsigned char unknown7;
    unsigned char unknown8;
    unsigned char unknown9;
    long Height;
    unsigned char mostlyzero[12];
    short Weight;
    unsigned char unknown10;
    unsigned char unknown11;
    unsigned char Italic;
    unsigned char Underline;
    unsigned char StrikeOut;
    unsigned char DoubleUnderline;
    unsigned char SmallCaps;
    unsigned char unknown17;
    unsigned char unknown18;
    unsigned char PitchAndFamily;
}
NEWFONT;

typedef struct
{
    unsigned short StyleNum;
    unsigned short BasedOn;
    NEWFONT font;
    char unknown[35];
    char StyleName[65];
}
NEWSTYLE;

typedef struct MVBFONT        /* structure located at DescriptorsOffset */
{
    short FontName;
    short expndtw;
    unsigned short style;
    unsigned char FGRGB[3];
    unsigned char BGRGB[3];
    long Height;
    unsigned char mostlyzero[12];
    short Weight;
    unsigned char unknown10;
    unsigned char unknown11;
    unsigned char Italic;
    unsigned char Underline;
    unsigned char StrikeOut;
    unsigned char DoubleUnderline;
    unsigned char SmallCaps;
    unsigned char unknown17;
    unsigned char unknown18;
    unsigned char PitchAndFamily;
    unsigned char unknown20;
    signed char up;
}
MVBFONT;

typedef struct
{
    unsigned short StyleNum;
    unsigned short BasedOn;
    MVBFONT font;
    char unknown[35];
    char StyleName[65];
}
MVBSTYLE;

typedef struct
{
    unsigned short Magic; /* 0x5555 */
    unsigned short Size;
    unsigned short Unknown1;
    unsigned short Unknown2;
    unsigned short Entries;
    unsigned short Ligatures;
    unsigned short LigLen;
    unsigned short Unknown[13];
}
CHARMAPHEADER;
/* Font Attributes */
#define FONT_NORM 0x00 /* Normal */
#define FONT_BOLD 0x01 /* Bold */
#define FONT_ITAL 0x02 /* Italics */
#define FONT_UNDR 0x04 /* Underline */
#define FONT_STRK 0x08 /* Strike Through */
#define FONT_DBUN 0x10 /* Dbl Underline */
#define FONT_SMCP 0x20 /* Small Caps */
/* Font Families */
#define FAM_MODERN 0x01
#define FAM_ROMAN  0x02
#define FAM_SWISS  0x03
#define FAM_TECH   0x03
#define FAM_NIL    0x03
#define FAM_SCRIPT 0x04
#define FAM_DECOR  0x05

typedef struct KWMAPREC       /* structure of |xWMAP leaf-page entries */
{
    long FirstRec;            /* index number of first keyword on leaf page */
    unsigned short PageNum;   /* page number that keywords are associated with */
}
KWMAPREC;

typedef struct TOPICBLOCKHEADER /* structure every TopicBlockSize of |TOPIC */
{
    long LastTopicLink;       /* offset of last topic link in previous block */
    long TopicData;           /* offset of topic data start */
    long LastTopicHeader;     /* offset of last topic header in previous block */
}
TOPICBLOCKHEADER;

typedef struct TOPICLINK      /* structure pointed to be TopicData */
{
    long BlockSize;           /* size of this link + LinkData1 + LinkData2 */
    long DataLen2;            /* length of decompressed LinkData2 */
    long PrevBlock;           /* relative to first byte of |TOPIC */
    long NextBlock;           /* relative to first byte of |TOPIC */
    long DataLen1;            /* includes size of TOPICLINK */
    unsigned char RecordType; /* See below */
}
TOPICLINK;
/* Known RecordTypes for TOPICLINK */
#define TL_DISPLAY30 0x01     /* version 3.0 displayable information */
#define TL_TOPICHDR  0x02     /* topic header information */
#define TL_DISPLAY   0x20     /* version 3.1 displayable information */
#define TL_TABLE     0x23     /* version 3.1 table */

typedef struct TOPICHEADER    /* structure of LinkData1 of RecordType 2 */
{
    long BlockSize; /* size of topic, including internal topic links */
    long BrowseBck; /* topic offset for prev topic in browse sequence */
    long BrowseFor; /* topic offset for next topic in browse sequence */
    long TopicNum;  /* topic Number */
    long NonScroll; /* start of non-scrolling region (topic offset) or -1 */
    long Scroll;    /* start of scrolling region (topic offset) */
    long NextTopic; /* start of next type 2 record */
}
TOPICHEADER;

typedef struct TOPICHEADER30  /* structure of LinkData1 of RecordType 2 */
{
    long BlockSize;
    short PrevTopicNum;
    short unused1;
    short NextTopicNum;
    short unused2;
}
TOPICHEADER30;

typedef struct CTXOMAPREC     /* structure of |CTXOMAP file entries */
{
    long MapID;
    long TopicOffset;
}
CTXOMAPREC;

typedef struct CONTEXTREC     /* structure of |CONTEXT leaf-page entry */
{
    long HashValue;           /* Hash value of Topic Name */
    long TopicOffset;         /* Topic offset */
}
CONTEXTREC;

typedef struct                /* structure of *.GRP file header */
{
    unsigned long Magic;       /* 0x000A3333 */
    unsigned long BitmapSize;
    unsigned long LastTopic;
    unsigned long FirstTopic;
    unsigned long TopicsUsed;
    unsigned long TopicCount;
    unsigned long GroupType;
    unsigned long Unknown1;
    unsigned long Unknown2;
    unsigned long Unknown3;
}
GROUPHEADER;

typedef struct                        /* internal use */
{
    GROUPHEADER GroupHeader;
    char *Name;
    unsigned char *Bitmap;
}
GROUP;

typedef struct
{
    unsigned long Magic; /* 0x00082222 */
    unsigned short BytesUsed;
    unsigned short Unused[17];
}
STOPHEADER;

typedef struct VIOLAREC       /* structure of |VIOLA leaf-page entry */
{
    long TopicOffset;         /* topic offset */
    long WindowNumber;        /* number of window assigned to topic */
}
VIOLAREC;

typedef struct
{
   unsigned short magic;      /* 0x1111 */
   unsigned short always8;
   unsigned short always4;
   long entries;
   unsigned char zero[30];
}
CATALOGHEADER;

typedef struct tagBITMAPFILEHEADER
{
    unsigned short bfType;
    unsigned long bfSize;
    unsigned short bfReserved1;
    unsigned short bfReserved2;
    unsigned long bfOffBits;
}
BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER
{
    unsigned long biSize;
    long biWidth;
    long biHeight;
    unsigned short biPlanes;
    unsigned short biBitCount;
    unsigned long biCompression;
    unsigned long biSizeImage;
    long biXPelsPerMeter;
    long biYPelsPerMeter;
    unsigned long biClrUsed;
    unsigned long biClrImportant;
}
BITMAPINFOHEADER;

typedef struct tagRECT
{
    short left;
    short top;
    short right;
    short bottom;
}
RECT;

typedef struct tagAPMFILEHEADER
{
    unsigned long dwKey;
    unsigned short hMF;
    RECT rcBBox;
    unsigned short wInch;
    unsigned long dwReserved;
    unsigned short wChecksum;
}
APMFILEHEADER;

typedef struct
{
    unsigned char id0,id1,id2;
    unsigned short x,y,w,h;
    unsigned long hash;
}
HOTSPOT;

typedef enum {FALSE,TRUE} BOOL;

typedef struct BUFFER         /* structure used as buf of GetFirstPage */
{
    long FirstLeaf;
    unsigned short PageSize;
    short NextPage;
}
BUFFER;

typedef struct browse /* internal use. max. 3640 / 64k */
{
    long StartTopic;
    long NextTopic;
    long PrevTopic;
    short BrowseNum;
    short Start;
    short Count;
}
BROWSE;

typedef struct start /* internal use. max. 8191 / 64k */
{
    long StartTopic;
    short BrowseNum;
    short Start;
}
START;

typedef struct hashrec /* internal use. max. 8191 / 64k */
{
    char *name;
    long hash;
}
HASHREC;

typedef struct
{
    BOOL KeyIndex;
    char Footnote;
    char *Keyword;
    long TopicOffset;
}
KEYWORDREC;

#define MAGIC 0x5774

typedef struct /* a class would be more appropriate */
{
    int magic;
    char *ptr;
    char *end;
}
MFILE;

typedef struct placerec
{
   struct placerec *next;
   char topicname[1];
}
PLACEREC;

typedef struct checkrec
{
    struct checkrec *next;
    enum { TOPIC, CONTEXT } type;
    long hash;
    char *id;
    PLACEREC *here;
}
CHECKREC;

typedef struct fileref
{
    struct fileref *next;
    CHECKREC *check;
    char filename[1];
}
FILEREF;

FILEREF *external;
char drive[_MAX_DRIVE];
char dir[_MAX_DIR];
char name[_MAX_FNAME];
char ext[_MAX_EXT];
long Directory;
FILE *AnnoFile;
HASHREC *hashrec;
BROWSE *browse;
int scaling=10;
int browses;
int browsenums;
START *start;
int starts;
int hashrecs=0;
BOOL before31;
BOOL win95=FALSE;
BOOL warn=FALSE;
BOOL warnings=FALSE;
int missing=0;
BOOL lzcompressed;
long *Topic;
int Topics;                         /* max. 16348 Topics */
int groups;
GROUP *group;
CONTEXTREC *ContextRec;
BOOL overwrite=FALSE;
BOOL extractmacros=TRUE;
BOOL listtopic=FALSE;
BOOL resolvebrowse=TRUE;
BOOL checkexternal=FALSE;
BOOL exportplain=FALSE;
int NextKeywordRec,KeywordRecs;
KEYWORDREC *KeywordRec;
char helpcomp[10];
char HelpFileTitle[81];
char TopicTitle[256];
int ContextRecs;                    /* max. 8191 Context Records */
long TopicFileStart=0L;
unsigned short *Offsets;
unsigned int *NewOffsets;
unsigned int PhraseCount;
int TopicUse;
long TopicFileLength;
int TopicBlockSize; /* 2k or 4k */
int DecompressSize; /* 4k or 16k */
long CurrentTopicOffset;
long CurrentTopicPos;
BOOL dontCount;
unsigned char TopicBuffer[0x4800]; /* BACKSDK.MVB needs more than 0x4000 */
char buffer[4096];
char index_separators[40]=",;";
char *extension;
int extensions=0;
/* index into bmpext: bit 0=multiresolution bit 1=bitmap, bit 2=metafile, bit 3=hotspot data, bit 4=embedded, bit 5=transparent */
char *bmpext[]={"???","MRB","BMP","MRB","WMF","MRB","MRB","MRB","SHG","MRB","SHG","MRB","SHG","MRB","SHG","MRB"};
BOOL mvp;
BOOL multi;
char **stopwordfilename;
int stopwordfiles;
char **fontname;
int fontnames;
int fonts;
FONTDESCRIPTOR *font;
char *NewPhrases;
char **windowname;
int windownames;
BOOL NotInAnyTopic;
BOOL lists['z'-'0'+1];
BOOL keyindex['z'-'0'+1];
unsigned char table[256];
signed char count; /* for run len decompression */

void error(char *format,...)
{
    va_list arg;

    va_start(arg,format);
    vfprintf(stderr,format,arg);
    va_end(arg);
    fprintf(stderr,"Press CR to continue at your own risk, any other key to exit.\n");
    if(getch()!='\r') exit(1);
}

long myFTell(MFILE *f)
{
    if(f->magic!=MAGIC) return ftell((FILE *)f);
    return (long)f->ptr;
}

void myFSeek(MFILE *f,long offset)
{
    if(f->magic!=MAGIC)
    {
        fseek((FILE *)f,offset,SEEK_SET);
    }
    else
    {
        f->ptr=(char *)offset;
    }
}

void *myMalloc(long bytes) /* save malloc function */
{
    void *ptr;

    if(bytes<1L||((size_t)bytes!=bytes)||(ptr=malloc((size_t)bytes))==NULL)
    {    
        fprintf(stderr,"Allocation of %ld bytes failed. File too big.\n",bytes);
        exit(1);
    }
    return ptr;
}

void *myReAlloc(void *ptr,long bytes) /* save realloc function */
{
    if(!ptr) return myMalloc(bytes);
    if(bytes<1L||bytes!=(size_t)bytes||(ptr=realloc(ptr,(size_t)bytes))==NULL)
    {
        fprintf(stderr,"Reallocation to %ld bytes failed. File too big.\n",bytes);
        exit(1);
    }
    return ptr;
}

char *myStrDup(char *ptr) /* save strdup function */
{
    size_t len;
    char *dup;

    if(!ptr) return NULL;
    len=strlen(ptr);
    dup=myMalloc(len+1);
    strcpy(dup,ptr);
    return dup;
}

long hash(char *name) /* convert 3.1 topic name to hash value */
{
    long hash;
    unsigned char *ptr;

    if(*name=='\0') return 1L;
    for(hash=0L,ptr=(unsigned char *)name;*ptr;ptr++)
    {
        if(table[*ptr]==0)
        {
            fprintf(stderr,"Illegal char %c in Topic Name %s\n",*ptr,name);
            warnings=TRUE;
            return 0L;
        }
        hash=(hash*0x2BU)+table[*ptr];
    }
    return hash;
}

char *unhash(unsigned long hash) /* deliver 3.1 topic name that fits hash value */
{
    static unsigned char untable[]={0,'1','2','3','4','5','6','7','8','9','0',0,'.','_',0,0,0,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    unsigned int i,n,f,t;
    long double x;
    static char buffer[15];

    for(i=0;i<hashrecs;i++) if(hashrec[i].hash==hash) return hashrec[i].name;
    for(t=0;t<65535U;t++)
    {
        x=hash+256.0*256.0*256.0*256.0*t;
        buffer[i=14]='\0';
        while(1)
        {
            n=(int)fmodl(x,43.0);
            f=untable[n];
            if(!f) break;
            x-=n;
            buffer[--i]=f;
            x/=43.0;
            if(x<1.0) return buffer+i;
        }
    }
    /* should never happen */
    error("Can not find a matching string for hash value %08lx\n",hash);
    sprintf(buffer,"HASH%08lx",hash);
    return buffer;
}

size_t myFRead(void *ptr,long bytes,FILE *f) /* save fread function */
{
    size_t result;

    if(bytes==0) return 0;
    if(bytes<0||bytes!=(size_t)bytes||(result=fread(ptr,1,(size_t)bytes,f))!=bytes)
    {
        error("myFRead(%ld) at %ld failed\n",bytes,ftell(f));
    }
    return result;
}

size_t BlockRead(void *ptr,long bytes,MFILE *f) /* save fread function */
{
    if(f->magic!=MAGIC) return myFRead(ptr,bytes,(FILE *)f);
    if(bytes<0||bytes>f->end-f->ptr)
    {
        error("myFRead(%ld) at %ld failed\n",bytes);
        bytes=f->end-f->ptr;
    }
    memcpy(ptr,f->ptr,bytes);
    f->ptr+=bytes;
    return bytes;
}

void myFClose(FILE *f) /* checks if disk is full */
{
    if(ferror(f)!=0)
    {
        fprintf(stderr,"File write error. Program aborted.\n");
        exit(2);
    }
    fclose(f);
}

FILE *myFOpen(const char *filename,const char *mode) /* save fopen function */
{
    FILE *f;
    char ch;

    if(!overwrite)
    {
        f=fopen(filename,"rb");
        if(f)
        {
            fclose(f);
            fprintf(stderr,"File %s already exists. Overwrite (Y/N/All) ? Y\b",filename);
            do
            {
                ch=getch();
            }
            while(ch!='a'&&ch!='A'&&ch!='y'&&ch!='Y'&&ch!='n'&&ch!='N'&&ch!='\r'&&ch!='\x1B');
            if(ch=='\r') ch='Y';
            if(ch=='\x1B') ch='N';
            printf("%c\n",ch);
            if(ch=='A'||ch=='a')
            {
                ch='Y';
                overwrite=TRUE;
            }
            if(ch=='n'||ch=='N') exit(0);
        }
    }
    f=fopen(filename,mode);
    if(!f)
    {
        error("Can not create '%s'.\n",filename);
    }
    else if(((MFILE *)f)->magic==MAGIC)
    {
        fprintf(stderr,"Error creating %s...\n",filename);
        fclose(f);
        f=NULL;
    }
    else
    {
        fprintf(stderr,"Creating %s...\n",filename);
    }
    return f;
}

unsigned short myGetW(FILE *f)
{
    int ch;

    ch=getc(f);
    return ch|(getc(f)<<8);
}

void myPutW(unsigned short w,FILE *f)
{
    putc((w&0xFF),f);
    putc((w>>8),f);
}

char *WindowName(long n) /* secondary window name from secondary window number */
{
    if(windowname==NULL||n<0||n>=windownames||windowname[n]==NULL) return "main";
    return windowname[n];
}

void AddTopic(char *TopicName) /* adds a known topic name to hash decode list */
{
    long x;
    int i;

    for(i=0;TopicName[i];i++) if(table[(unsigned char)TopicName[i]]==0)
    {
        fprintf(stderr,"Illegal context id %s\n",TopicName);
        return;
    }
    x=hash(TopicName);
    for(i=0;i<hashrecs;i++)
    {
        if(hashrec[i].hash==x)
        {
            if(stricmp(TopicName,hashrec[i].name)!=0)
            {
                fprintf(stderr,"Context id %s already defined as %s\n",TopicName,hashrec[i].name);
            }
            return;
        }
    }
    if(hashrecs%100==0) hashrec=myReAlloc(hashrec,(hashrecs+100)*sizeof(HASHREC));
    hashrec[hashrecs].name=myStrDup(TopicName);
    hashrec[hashrecs++].hash=x;
}

MFILE *CreateMap(char *ptr,size_t size) /* assign a memory mapped file */
{
    MFILE *f;

    f=myMalloc(sizeof(MFILE));
    f->magic=MAGIC;
    f->ptr=ptr;
    f->end=ptr+size;
    return f;
}

void CloseMap(MFILE *f) /* close a memory mapped file */
{
    if(f) free(f);
}

int PutChar(char c,MFILE *f) /* putc to memory mapped file or regular file */
{
    if(f->magic!=MAGIC)
    {
        putc(c,(FILE *)f);
    }
    else if(f->ptr>=f->end)
    {
        error("Buffer overrun\n");
        exit(1);
    }
    else
    {
        *f->ptr++=c;
    }
    return 1;
}

int GetChar(MFILE *f) /* getc from memory mapped file or regular file */
{
    if(f->magic!=MAGIC) return getc((FILE *)f);
    if(f->ptr>=f->end) return -1;
    return *f->ptr++;
}

int GetWord(MFILE *f) /* myGetW from memory mapped file or regular file */
{
    if(f->magic!=MAGIC) return myGetW((FILE *)f);
    if(f->ptr+1>=f->end) return -1;
    return *((unsigned short *)f->ptr)++;
}

unsigned short GetCWord(MFILE *f) /* get compressed word */
{
    unsigned char b;

    b=GetChar(f);
    if(b&1) return (((unsigned short)GetChar(f)<<8)|(unsigned short)b)>>1;
    return ((unsigned short)b>>1);
}

unsigned long GetCDWord(MFILE *f) /* get compressed long */
{
    unsigned short w;

    w=GetWord(f);
    if(w&1) return (((unsigned long)GetWord(f)<<16)|(unsigned long)w)>>1;
    return ((unsigned long)w>>1);
}

unsigned long GetDWord(MFILE *f) /* get long */
{
    unsigned short w;

    w=GetWord(f);
    return ((unsigned long)GetWord(f)<<16)|(unsigned long)w;
}

size_t StringRead(char *ptr,size_t size,MFILE *f) /* read nul terminated string */
{
    size_t i;
    int c;

    i=0;
    while((c=GetChar(f))>0)
    {
        if(i>=size-1)
        {
            fprintf(stderr,"String length exceeds decompiler limit.\n");
            exit(1);
        }
        ptr[i++]=c;
    }
    ptr[i]='\0';
    return i;
}

size_t myGetS(char *ptr,size_t size,FILE *f)
{
    size_t i;
    int c;

    i=0;
    while((c=getc(f))>0)
    {
        if(i>=size-1)
        {
            fprintf(stderr,"String length exceeds decompiler limit.\n");
            exit(1);
        }
        ptr[i++]=c;
    }
    ptr[i]='\0';
    return i;
}

/* locates internal file FileName or internal directory if FileName is NULL
// reads FILEHEADER and returns TRUE with current position in HelpFile set
// to first byte of data of FileName or returns FALSE if not found
// stores UsedSpace in FileLength if FileLength isn't NULL */
BOOL SearchFile(FILE *HelpFile,char *FileName,long *FileLength)
{
    HELPHEADER Header;
    FILEHEADER FileHdr;
    BTREEHEADER BtreeHdr;
    BTREENODEHEADER CurrNode;
    long offset;
    char TempFile[19];
    int i,n;

    fseek(HelpFile,0L,SEEK_SET);
    myFRead(&Header,sizeof(Header),HelpFile);
    if(Header.Magic!=0x00035F3FL) return FALSE;
    if(FileName&&strcmp(FileName,".")==0)
    {
        if(Header.NonDirectoryStart==-1L) return FALSE;
        fseek(HelpFile,Header.NonDirectoryStart,SEEK_SET);
        myFRead(&FileHdr,sizeof(FileHdr),HelpFile);
        if(FileLength) *FileLength=FileHdr.ReservedSpace-9;
        return TRUE;
    }
    fseek(HelpFile,Header.DirectoryStart,SEEK_SET);
    myFRead(&FileHdr,sizeof(FileHdr),HelpFile);
    if(!FileName)
    {
        if(FileLength) *FileLength=FileHdr.UsedSpace;
        return TRUE;
    }
    myFRead(&BtreeHdr,sizeof(BtreeHdr),HelpFile);
    offset=ftell(HelpFile);
    fseek(HelpFile,offset+BtreeHdr.RootPage*(long)BtreeHdr.PageSize,SEEK_SET);
    for(n=1;n<BtreeHdr.NLevels;n++)
    {
        myFRead(&CurrNode,sizeof(BTREEINDEXHEADER),HelpFile);
        for(i=0;i<CurrNode.NEntries;i++)
        {
            myGetS(TempFile,sizeof(TempFile),HelpFile);
            if(strcmp(FileName,TempFile)<0) break;
            myFRead(&CurrNode.PreviousPage,sizeof(CurrNode.PreviousPage),HelpFile);
        }
        fseek(HelpFile,offset+CurrNode.PreviousPage*(long)BtreeHdr.PageSize,SEEK_SET);
    }
    myFRead(&CurrNode,sizeof(CurrNode),HelpFile);
    for(i=0;i<CurrNode.NEntries;i++)
    {
        myGetS(TempFile,sizeof(TempFile),HelpFile);
        myFRead(&offset,sizeof(long),HelpFile);
        if(strcmp(TempFile,FileName)==0)
        {
            fseek(HelpFile,offset,SEEK_SET);
            myFRead(&FileHdr,sizeof(FileHdr),HelpFile);
            if(FileLength) *FileLength=FileHdr.UsedSpace;
            return TRUE;
        }
    }
    return FALSE;
}

short GetFirstPage(FILE *HelpFile,BUFFER *buf,long *TotalEntries) /* walk Btree */
{
    int CurrLevel;
    BTREEHEADER BTreeHdr;
    BTREENODEHEADER CurrNode;

    myFRead(&BTreeHdr,sizeof(BTreeHdr),HelpFile);
    if(TotalEntries) *TotalEntries=BTreeHdr.TotalBtreeEntries;
    if(!BTreeHdr.TotalBtreeEntries) return 0;
    buf->FirstLeaf=ftell(HelpFile);
    buf->PageSize=BTreeHdr.PageSize;
    fseek(HelpFile,buf->FirstLeaf+BTreeHdr.RootPage*(long)BTreeHdr.PageSize,SEEK_SET);
    for(CurrLevel=1;CurrLevel<BTreeHdr.NLevels;CurrLevel++)
    {
        myFRead(&CurrNode,sizeof(BTREEINDEXHEADER),HelpFile);
        fseek(HelpFile,buf->FirstLeaf+CurrNode.PreviousPage*(long)BTreeHdr.PageSize,SEEK_SET);
    }
    myFRead(&CurrNode,sizeof(CurrNode),HelpFile);
    buf->NextPage=CurrNode.NextPage;
    return CurrNode.NEntries;
}

short GetNextPage(FILE *HelpFile,BUFFER *buf) /* walk Btree */
{
    BTREENODEHEADER CurrNode;

    if(buf->NextPage==-1) return 0;
    fseek(HelpFile,buf->FirstLeaf+buf->NextPage*(long)buf->PageSize,SEEK_SET);
    myFRead(&CurrNode,sizeof(CurrNode),HelpFile);
    buf->NextPage=CurrNode.NextPage;
    return CurrNode.NEntries;
}

SYSTEMRECORD *GetNextSystemRecord(SYSTEMRECORD *SysRec)
{
    if(SysRec->Remaining<4)
    {
        free(SysRec);
        return NULL;
    }
    fseek(SysRec->File,SysRec->SavePos,SEEK_SET);
    SysRec->RecordType=myGetW(SysRec->File);
    SysRec->DataSize=myGetW(SysRec->File);
    SysRec->Remaining-=4;
    if(SysRec->Remaining<SysRec->DataSize)
    {
        free(SysRec);
        return NULL;
    }
    SysRec=myReAlloc(SysRec,sizeof(SYSTEMRECORD)+SysRec->DataSize+10);
    myFRead(SysRec->Data,SysRec->DataSize,SysRec->File);
    SysRec->Data[SysRec->DataSize]='\0';
    SysRec->Remaining-=SysRec->DataSize;
    SysRec->SavePos=ftell(SysRec->File);
    return SysRec;
}

SYSTEMRECORD *GetFirstSystemRecord(FILE *HelpFile)
{
    SYSTEMHEADER SysHdr;
    SYSTEMRECORD *SysRec;
    long FileLength;

    if(!SearchFile(HelpFile,"|SYSTEM",&FileLength)) return NULL;
    myFRead(&SysHdr,sizeof(SysHdr),HelpFile);
    if(SysHdr.Version<16) return NULL;
    SysRec=myMalloc(sizeof(SYSTEMRECORD));
    SysRec->File=HelpFile;
    SysRec->SavePos=ftell(HelpFile);
    SysRec->Remaining=FileLength-sizeof(SYSTEMHEADER);
    return GetNextSystemRecord(SysRec);
}

void SysLoad(FILE *HelpFile) /* gets global values from SYSTEM file */
{
    SYSTEMRECORD *SysRec;
    SYSTEMHEADER SysHdr;

    if(!SearchFile(HelpFile,"|SYSTEM",NULL))
    {
        fprintf(stderr,"Internal |SYSTEM file not found. Can't continue.\n");
        exit(1);
    }
    myFRead(&SysHdr,sizeof(SysHdr),HelpFile);
    before31=SysHdr.Version<16;
    multi=SysHdr.Version==27;
    lzcompressed=!before31&&(SysHdr.Flags==4||SysHdr.Flags==8);
    if(before31)
    {
        DecompressSize=TopicBlockSize=2048;
    }
    else
    {
        DecompressSize=0x4000;
        if(SysHdr.Flags==8)
        {
            TopicBlockSize=2048;
        }
        else
        {
            TopicBlockSize=4096;
        }
    }
    if(before31)
    {
        myGetS(HelpFileTitle,33,HelpFile);
    }
    else for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
    {
        if(SysRec->RecordType==0x0001) strcpy(HelpFileTitle,SysRec->Data);
    }
}

/*********************************************************************************

  GRAPHICS STUFF
  ==============
  ExtractBitmap(..) extracts the graphics stored as |bmXXX in the Windows
  HelpFile to separate files. In this version multiple resolution pictures
  (with and without hotspots) are saved as MRB's, pictures with hotspots are
  converted to the SHG-format, single resolution Bitmaps without hotspots
  to standard BMP-format and all Metafiles without hotspots to the Aldus
  Placeable Metafile WMF format.

  GENERAL NOTES ABOUT |bmXXX
  --------------------------

  |bmXXX contains one MRB-File. This can be directly recompiled. If hotspots
  in the graphics contained in the MRB-File shall be added or changed with
  SHED, the MRB-File has to be split into one SHG file for each graphic. This
  is very easy as the graphics-data will only be slightly rewrapped. If the
  graphics themselves shall be edited with a standard drawing program, the
  SHG files have to be converted into bitmaps or metafiles (as flagged in
  the SHG). The hotspot data is lost by this step.

  MRB-FILES
  ---------

  MRBC takes the input-file(s), converts them to "lp"-Files if needed, adds
  a resolution specification if none is given in the file and finally outputs
  a "lp"-File with the ending ".MRB". Depending on the given display type
  MRBC sets the following resolutions:

	       |           |               | x-resolution | y-resolution
  display-type | extension | std-extension |    (ppi)     |    (ppi)
  -------------+-----------+---------------+--------------+-------------
       CGA     |   ".C*"   |     ".CGA"    |      96      |      48
       EGA     |   ".E*"   |     ".EGA"    |      96      |      72
       VGA     |   ".V*"   |     ".VGA"    |      96      |      96
       8514    |   ".8*"   |     ".854"    |     120      |     120

  SHG-Files
  ---------

  Structure of SHG-Data:

   Offset    | Size       | Ref | Description
   ----------+------------+-----+-----------------------------------------------
      0      | 1 Byte     |     | always 0x01, maybe a version-number
      1      | 1 Word     |  N  | the number of hotspots
      3      | 1 DWord    |  M  | size of macro-data (in bytes)
      7      | 15xN Bytes | HSD | Hotspot-Data (see below)
    7 + 15*N | M Bytes    |     | Macro-Data (ASCIIZ-Strings)
    7+15*N+M | 2*N*ASCIIZ |     | Hotspot-Id and Context- or Macro-Name as
	     |		  |	| ASCIIZ-String

  Structure of Hotspot-Data:

   Offset    | Size       | Ref | Description
   ----------+------------+-----+-------------------------------------------------
      0      | 3 Bytes    |     | Hotspot-Type: 0xE3 0x00 0x00 = jump, visible
	     |		  |	|               0xE7 0x04 0x00 = jump, invisible
	     |		  |	|               0xE2 0x00 0x00 = pop-up, visible
	     |            |     |               0xE6 0x04 0x00 = pop-up, invisible
	     |            |     |               0xC8 0x00 0x00 = macro, visible
	     |            |     |               0xCC 0x04 0x00 = macro, invisible
      3      | 1 Word     |     | Left border of hotspot
      5      | 1 Word     |     | Top border of hotspot
      7      | 1 Word     |     | Right border - Left border
      9      | 1 Word     |     | Bottom border - Top border
     11      | 1 DWord    |     | 0x00000000 => nothing
	     |            |     | 0x00000001 => this is a macro-hotspot
	     |            |     |   others   => hash-value of the context-string
	     |            |     |               according to the WinHelp standard

  03-06-1995 Holger Haase
**********************************************************************************/

long copy(FILE *f,long bytes,FILE *out)
{
    long length;
    int size;

    for(length=0;length<bytes;length+=size)
    {
        size=(int)(bytes-length>sizeof(buffer)?sizeof(buffer):bytes-length);
        myFRead(buffer,size,f);
        fwrite(buffer,size,1,out);
    }
    return length;
}

long CopyBytes(MFILE *f,long bytes,FILE *out)
{
    if(f->magic!=MAGIC) return copy((FILE *)f,bytes,out);
    if(bytes>(size_t)(f->end-f->ptr)) bytes=(size_t)(f->end-f->ptr);
    fwrite(f->ptr,(size_t)bytes,1,out);
    f->ptr+=(size_t)bytes;
    return bytes;
}

int DeRun(char c,MFILE *f) /* expand runlen compressed data */
{
    int i;

    if(count&0x7F)
    {
        if(count&0x80)
        {
            PutChar(c,f);
            count--;
            return 1;
        }
        for(i=0;i<count;i++)
        {
            PutChar(c,f);
        }
        count=0;
        return i;
    }
    count=(signed char)c;
    return 0;
}

long decompress(int method,MFILE *f,long bytes,MFILE *fTarget)
{
    static unsigned char lzbuffer[0x1000];
    int (*Emit)(char c,MFILE *f);
    unsigned char bits,mask;
    int pos,len,back;
    long n;

    n=0;
    if(method&1)
    {
        Emit=DeRun;
        count=0;
    }
    else
    {
        Emit=PutChar;
    }
    if(method&2)
    {
        mask=0;
        pos=0;
        while(bytes-->0L)
        {
            if(!mask)
            {
                bits=GetChar(f);
                mask=1;
            }
            else
            {
                if(bits&mask)
                {
                    if(bytes--==0) break;
                    back=GetWord(f);
                    len=((back>>12)&15)+3;
                    back=pos-(back&0xFFF)-1;
                    while(len-->0)
                    {
                        n+=Emit(lzbuffer[pos++&0xFFF]=lzbuffer[back++&0xFFF],fTarget);
                    }
                }
                else
                {
                    n+=Emit(lzbuffer[pos++&0xFFF]=GetChar(f),fTarget);
                }
                mask<<=1;
            }
        }
    }
    else
    {
        while(bytes-->0L) n+=Emit(GetChar(f),fTarget);
    }
    return n;
}

int filenamecmp(const char *a,const char *b)
{
    char aname[_MAX_FNAME],bname[_MAX_FNAME];
    char aext[_MAX_EXT],bext[_MAX_EXT];
    int i;

    _splitpath(a,NULL,NULL,aname,aext);
    _splitpath(b,NULL,NULL,bname,bext);
    if(aext[0]=='\0') strcpy(aext,".HLP");
    if(bext[0]=='\0') strcpy(bext,".HLP");
    i=strcmpi(aname,bname);
    if(i) return i;
    return strcmpi(aext,bext);
}

void CheckExternal(char *filename,int type,char *id,long hash)
{
    CHECKREC *ptr;
    FILEREF *ref;
    PLACEREC *place;

    for(ref=external;ref;ref=ref->next)
    {
        if(filenamecmp(filename,ref->filename)==0) break;
    }
    if(!ref)
    {
        ref=myMalloc(sizeof(FILEREF)+strlen(filename));
        strcpy(ref->filename,filename);
        ref->check=NULL;
        ref->next=external;
        external=ref;
    }
    for(ptr=ref->check;ptr;ptr=ptr->next)
    {
        if(ptr->type==type&&ptr->hash==hash) break;
    }
    if(!ptr)
    {
        ptr=myMalloc(sizeof(CHECKREC));
        ptr->type=type;
        ptr->hash=hash;
        ptr->id=myStrDup(id);
        ptr->here=NULL;
        ptr->next=ref->check;
        ref->check=ptr;
    }
    if(listtopic&&TopicTitle[0])
    {
        place=myMalloc(sizeof(PLACEREC)+strlen(TopicTitle));
        strcpy(place->topicname,TopicTitle);
        place->next=ptr->here;
        ptr->here=place;
    }
}

void CheckReferences(void)
{
    FILEREF *ref;
    CHECKREC *ptr;
    FILE *f;
    BOOL found;
    long offset;
    int i,n;
    CTXOMAPREC CTXORec;
    BTREEHEADER BTreeHdr;
    BTREENODEHEADER CurrNode;
    CONTEXTREC ContextRec;

    for(ref=external;ref;ref=ref->next)
    {
        f=fopen(ref->filename,"rb");
        if(!f)
        {
            printf("%s not found\n",ref->filename);
        }
        else
        {
            if(SearchFile(f,NULL,NULL))
            {
                for(ptr=ref->check;ptr;ptr=ptr->next)
                {
                    found=FALSE;
                    if(ptr->type==CONTEXT)
                    {
                        if(SearchFile(f,"|CTXOMAP",NULL))
                        {
                            n=myGetW(f);
                            for(i=0;i<n;i++)
                            {
                                myFRead(&CTXORec,sizeof(CTXORec),f);
                                if(CTXORec.MapID==ptr->hash) /* hash is context id */
                                {
                                    found=TRUE;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        if(SearchFile(f,"|CONTEXT",NULL))
                        {
                            myFRead(&BTreeHdr,sizeof(BTreeHdr),f);
                            offset=ftell(f);
                            CurrNode.PreviousPage=BTreeHdr.RootPage;
                            for(n=1;n<BTreeHdr.NLevels;n++)
                            {
                                fseek(f,offset+CurrNode.PreviousPage*(long)BTreeHdr.PageSize,SEEK_SET);
                                myFRead(&CurrNode,sizeof(BTREEINDEXHEADER),f);
                                for(i=0;i<CurrNode.NEntries;i++)
                                {
                                    myFRead(&ContextRec.HashValue,sizeof(ContextRec.HashValue),f);
                                    if(ContextRec.HashValue>ptr->hash) break;
                                    CurrNode.PreviousPage=myGetW(f); /* Page */
                                }
                            }
                            fseek(f,offset+CurrNode.PreviousPage*(long)BTreeHdr.PageSize,SEEK_SET);
                            myFRead(&CurrNode,sizeof(BTREENODEHEADER),f);
                            for(i=0;i<CurrNode.NEntries;i++)
                            {
                                myFRead(&ContextRec,sizeof(ContextRec),f);
                                if(ContextRec.HashValue==ptr->hash) found=TRUE;
                                if(ContextRec.HashValue>=ptr->hash) break;
                            }
                        }
                    }
                    if(!found)
                    {
                        if(ptr->id)
                        {
                            printf("%s@%s not found\n",ptr->id,ref->filename);
                        }
                        else
                        {
                            printf("0x%08lx@%s not found\n",ptr->hash,ref->filename);
                        }
                        while(ptr->here)
                        {
                            printf("  %s\n",ptr->here->topicname);
                            ptr->here=ptr->here->next;
                        }
                    }
                }
            }
            else
            {
                printf("%s isn't a valid WinHelp file !\n",ref->filename);
            }
            fclose(f);
        }
    }
}

void ListReferences(void)
{
    FILEREF *ref;
    CHECKREC *ptr;

    hashrecs=0;
    for(ref=external;ref;ref=ref->next)
    {
        for(ptr=ref->check;ptr;ptr=ptr->next)
        {
            printf("%s ",ref->filename);
            switch(ptr->type)
            {
            case TOPIC:
                printf("topic id ");
                if(ptr->id)
                {
                    printf("'%s'",ptr->id);
                }
                else
                {
                    printf("0x%08lx='%s'",ptr->hash,unhash(ptr->hash));
                }
                break;
            case CONTEXT:
                printf("[MAP] id ");
                if(ptr->id)
                {
                    printf("'%s'",ptr->id);
                }
                else
                {
                    printf("0x%08lx=(%ld)",ptr->hash,ptr->hash);
                }
                break;
            }
            if(ptr->here)
            {
                printf(" referenced from:");
                while(ptr->here)
                {
                    printf("\n  %s",ptr->here->topicname);
                    ptr->here=ptr->here->next;
                }
            }
            putchar('\n');
        }
    }
}

BOOL CheckMacroX(char *ptr)
{
    static char *macro[]=
    {
        "AddAccelerator(ssm","AA(ssm",
        "AppendItem(sssm","AI(sssm",
        "AL(ssts",
        "ChangeButtonBinding(sm","CBB(sm",
        "CB(ssm",
        "CE(sm",
        "ChangeItemBinding(sm","CIB(sm",
        "ExtInsertItem(sssmss",
        "IfThen(mm","IT(mm",
        "IfThenElse(mmm","IE(mmm",
        "ExecFile(sssm","EF(sssm",
        "InsertItem(sssms","II(sssms",
        "JumpContext(x","JC(x","JumpContext(fx","JC(fx",
        "JumpHash(h","JH(h","JumpHash(fh","JH(fh",
        "JumpId(c","JI(c","JumpId(fc","JI(fc",
        "KL(ssts",
        "MPrintID(c",
        "Not(m",
        "PopupId(c","PI(c","PopupId(fc","PI(fc",
        "PopupContext(x","PC(x","PopupContext(fx","PC(fx",
        "PopupHash(h","PopupHash(fh",
        "SetContents(fx",
        "SE(sssssc",
        "SH(sssst",
        "UpdateWindow(fc","UW(fc"
    };
    char *p;
    int namelen,parms,i,n,l;
    char *parm[20];

    while(1)
    {
        while(*ptr==' ') ptr++;
        if(*ptr=='\0') return TRUE;
        if(!isalpha(*ptr)) return FALSE;
        p=ptr;
        ptr++;
        for(namelen=1;isalnum(*ptr)||*ptr=='_';namelen++) ptr++;
        while(*ptr==' ') ptr++;
        if(*ptr!='(') return FALSE;
        parms=0;
        while(1)
        {
            parm[parms]=ptr;
            while(*ptr==' ') ptr++;
            if(*ptr=='"')
            {
                parm[parms++]=++ptr;
                while(*ptr!='"')
                {
                    if(*ptr=='\0') return FALSE;
                    if(ptr[0]=='\\'&&(ptr[1]=='"'||ptr[1]=='`'||ptr[1]=='\''||ptr[1]=='\\')) ptr++;
                    ptr++;
                }
                *ptr++='\0';
            }
            else if(*ptr=='`')
            {
                parm[parms++]=++ptr;
                while(*ptr!='\'')
                {
                    if(*ptr=='\0') return FALSE;
                    if(ptr[0]=='\\'&&(ptr[1]=='"'||ptr[1]=='`'||ptr[1]=='\''||ptr[1]=='\\')) ptr++;
                    ptr++;
                }
                *ptr++='\0';
            }
            else if(*ptr!=')')
            {
                while(*ptr!=','&&*ptr!=')'&&*ptr!='\0') ptr++;
            }
            while(*ptr==' ') ptr++;
            if(*ptr==')') break;
            if(*ptr!=',') return FALSE;
            *ptr++='\0';
        }
        *ptr++='\0';
        for(i=0;i<sizeof(macro)/sizeof(macro[0]);i++)
        {
            if(strcspn(macro[i],"(")==namelen&&memicmp(macro[i],p,namelen)==0&&strlen(macro[i]+namelen+1)>=parms) break;
        }
        if(i<sizeof(macro)/sizeof(macro[0])) /* macro of interest */
        {
            char *at;

            for(n=0;n<parms;n++)
            {
                if(macro[i][namelen+1+n]=='m')
                {
                    CheckMacroX(parm[n]); /* recursive */
                }
                else if(macro[i][namelen+1+n]=='c')
                {
                    if(extractmacros)
                    {
                        while(parm[n][0]==' ') parm[n]++;
                        for(l=strlen(parm[n]);l>0&&parm[n][l-1]==' ';l--) ;
                        parm[n][l]='\0';
                        AddTopic(parm[n]);
                    }
                }
                else if(macro[i][namelen+1+n]=='f')
                {
                    at=strchr(parm[n],'>');
                    if(at)
                    {
                        if(filenamecmp(parm[n],name)!=0)
                        {
                            if(macro[i][namelen+2+n]=='c')
                            {
                                CheckExternal(parm[n],TOPIC,parm[n+1],hash(parm[n+1]));
                                n++;
                            }
                            else if(macro[i][namelen+2+n]=='x')
                            {
                                CheckExternal(parm[n],CONTEXT,parm[n-1],strtoul(parm[n+1],NULL,0));
                                n++;
                            }
                            else if(macro[i][namelen+2+n]=='h')
                            {
                                CheckExternal(parm[n],TOPIC,parm[n+1],strtoul(parm[n+1],NULL,0));
                                n++;
                            }
                        }
                    }
                }
                else if(macro[i][namelen+1+n]=='t')
                {
                    at=strchr(parm[n],'@');
                    if(at)
                    {
                        if(filenamecmp(at+1,name)!=0)
                        {
                            *at='\0';
                            CheckExternal(at+1,TOPIC,parm[n],hash(parm[n]));
                        }
                        else
                        {
                            AddTopic(parm[n]);
                        }
                    }
                    else
                    {
                        AddTopic(parm[n]);
                    }
                }
            }
        }
        while(*ptr==' ') ptr++;
        if(*ptr!=':'&&*ptr!=';') break;
        ptr++;
    }
    return TRUE;
}

void CheckMacro(char *ptr)
{
    char *temp;

    if(!multi)
    {
        temp=myStrDup(ptr);
        if(!CheckMacroX(temp)) fprintf(stderr,"Bad macro: %s\n",ptr);
        free(temp);
    }
}

void putcdw(unsigned long x,FILE *f)
{
    if(x>32767L)
    {
        myPutW((unsigned int)(x<<1)+1,f);
        myPutW(x>>15,f);
    }
    else
    {
        myPutW(x<<1,f);
    }
}

void putcw(unsigned int x,FILE *f)
{
    if(x>127)
    {
        myPutW((x<<1)+1,f);
    }
    else
    {
        putc(x<<1,f);
    }
}

void putdw(unsigned long x,FILE *f)
{
    fwrite(&x,sizeof(unsigned long),1,f);
}

int ExtractBitmap(char *szFilename,MFILE *f)
{
    FILE *fTarget;
    char *filename;
    int type;
    unsigned int i,n,j;
    unsigned char byType,byPacked;
    long l,pos,offset,nextpict,FileStart;
    BITMAPFILEHEADER bmfh;
    BITMAPINFOHEADER bmih;
    APMFILEHEADER afh;
    unsigned short *wp;
    unsigned short wMagic,mapmode,colors;
    unsigned long dwRawSize,dwDataSize,dwHotspotOffset,dwOffsBitmap,dwHotspotSize,dwPictureOffset,xPels,yPels;

    FileStart=myFTell(f);
    wMagic=GetWord(f);
    if((wMagic&0xDFFF)!=0x506C)
    {
        fprintf(stderr,"Picture '%s' unknown magic %04X (%c%c)\n",szFilename,wMagic,wMagic&0x00FF,wMagic>>8);
        return 0;
    }
    /* wMagic & 0x2000 unknown */
    fTarget=NULL;
    n=GetWord(f);
    type=!exportplain&&n>1; /* contains multiple resolutions */
    nextpict=4+4*n;
    for(j=0;j<n;j++)
    {
        myFSeek(f,FileStart+4+4*j);
        dwOffsBitmap=GetDWord(f);
        myFSeek(f,FileStart+dwOffsBitmap);
        byType=GetChar(f); /* type of picture: 5=DDB, 6=DIB, 8=METAFILE */
        byPacked=GetChar(f); /* packing method: 0=unpacked, 1=RunLen, 2=LZ77, 3=both */
        if(byType==6&&byPacked<4||byType==5&&byPacked<2)
        {
            type|=2; /* contains bitmap */
            memset(&bmfh,0,sizeof(bmfh));
            memset(&bmih,0,sizeof(bmih));
            bmfh.bfType=0x4D42; /* bitmap magic ("BM") */
            bmih.biSize=sizeof(bmih);
            /* HC30 doesn't like certain PelsPerMeter, so let them be 0 */
            /* bmih.biXPelsPerMeter = 40L* */ xPels=GetCDWord(f);
            /* bmih.biYPelsPerMeter = 40L* */ yPels=GetCDWord(f);
            bmih.biPlanes=GetCWord(f);
            bmih.biBitCount=GetCWord(f);
            bmih.biWidth=GetCDWord(f);
            bmih.biHeight=GetCDWord(f);
            colors=(int)(bmih.biClrUsed=GetCDWord(f));
            if(!colors) colors=1<<bmih.biBitCount;
            bmih.biClrImportant=GetCDWord(f);
            if(win95&&bmih.biClrImportant==1) type|=0x20; /* contains transparent bitmap */
            dwDataSize=GetCDWord(f);
            dwHotspotSize=GetCDWord(f);
            dwPictureOffset=GetDWord(f);
            dwHotspotOffset=GetDWord(f);
            if(exportplain||n==1&&(dwHotspotOffset==0L||dwHotspotSize==0L))
            {
                if(checkexternal) break;
                strcat(szFilename,".BMP");
                fTarget=myFOpen(szFilename,"wb");
                if(fTarget)
                {
                    fwrite(&bmfh,1,sizeof(bmfh),fTarget);
                    fwrite(&bmih,1,sizeof(bmih),fTarget);
                    if(byType==6)
                    {
                        CopyBytes(f,colors*4L,fTarget);
                    }
                    else
                    {
                        putdw(0x000000L,fTarget);
                        putdw(0xFFFFFFL,fTarget);
                    }
                    bmfh.bfOffBits=sizeof(bmfh)+sizeof(bmih)+colors*4L;
                    bmih.biSizeImage=(((bmih.biWidth*bmih.biBitCount+31)/32)*4)*bmih.biHeight;
                    if(byType==5) /* convert 3.0 DDB to 3.1 DIB */
                    {
                        long width,length;
                        unsigned char count,value;
                        int pad;

                        width=((bmih.biWidth*bmih.biBitCount+15)/16)*2;
                        pad=(int)(((width+3)/4)*4-width);
                        count=value=0;
                        for(l=0;l<bmih.biHeight;l++)
                        {
                            if(byPacked==1)
                            {
                                for(length=0;length<width;length++)
                                {
                                    if((count&0x7F)==0)
                                    {
                                        count=GetChar(f);
                                        value=GetChar(f);
                                    }
                                    else if(count&0x80)
                                    {
                                        value=GetChar(f);
                                    }
                                    putc(value,fTarget);
                                    count--;
                                }
                            }
                            else
                            {
                                CopyBytes(f,width,fTarget);
                            }
                            if(pad) fwrite(buffer,pad,1,fTarget);
                        }
                    }
                    else
                    {
                        decompress(byPacked,f,dwDataSize,(MFILE *)fTarget);
                    }
                    /* update bitmap headers */
                    bmfh.bfSize=ftell(fTarget);
                    fseek(fTarget,0L,SEEK_SET);
                    fwrite(&bmfh,1,sizeof(bmfh),fTarget);
                    fwrite(&bmih,1,sizeof(bmih),fTarget);
                }
                break;
            }
        }
        else if(byType==8&&byPacked<4) /* Windows MetaFile */
        {
            type|=4; /* contains metafile */
            memset(&afh,0,sizeof(afh));
            mapmode=GetCWord(f); /* mapping mode */
            afh.rcBBox.right=GetWord(f); /* width of metafile-picture */
            afh.rcBBox.bottom=GetWord(f); /* height of metafile-picture */
            dwRawSize=GetCDWord(f);
            dwDataSize=GetCDWord(f);
            dwHotspotSize=GetCDWord(f);
            dwPictureOffset=GetDWord(f);
            dwHotspotOffset=GetDWord(f);
            if(exportplain||n==1&&(dwHotspotOffset==0L||dwHotspotSize==0L))
            {
                if(checkexternal) break;
                afh.dwKey=0x9AC6CDD7L;
                afh.wInch=2540;
                wp=(unsigned short *)&afh;
                for(i=0;i<10;i++) afh.wChecksum^=*wp++;
                strcat(szFilename,".WMF");
                fTarget=myFOpen(szFilename,"wb");
                if(fTarget)
                {
                    fwrite(&afh,1,sizeof(afh),fTarget);
                    decompress(byPacked,f,dwDataSize,(MFILE *)fTarget);
                }
                break;
            }
        }
        else
        {
            fprintf(stderr,"Picture '%s' unknown format (%d) or packing method (%d)\n",szFilename,byType,byPacked);
            break;
        }
        type|=8; /* contains hotspot info (set before accessing bmpext) */
        if(!checkexternal)
        {
            if(!fTarget)
            {
                strcat(szFilename,".");
                strcat(szFilename,bmpext[type&0x0F]);
                fTarget=myFOpen(szFilename,"wb");
                if(!fTarget) break;
                myPutW(wMagic,fTarget);
                myPutW(n,fTarget);
            }
            fseek(fTarget,4+4*j,SEEK_SET);
            putdw(nextpict,fTarget);
            fseek(fTarget,nextpict,SEEK_SET);
            putc(byType,fTarget);
            putc(byPacked&1,fTarget);
            if(byType==8)
            {
                putcw(mapmode,fTarget); /* mapping mode */
                myPutW(afh.rcBBox.right,fTarget); /* width of metafile-picture */
                myPutW(afh.rcBBox.bottom,fTarget); /* height of metafile-picture */
                putcdw(dwRawSize,fTarget);
            }
            else
            {
                putcdw(xPels,fTarget);
                putcdw(yPels,fTarget);
                putcw(bmih.biPlanes,fTarget);
                putcw(bmih.biBitCount,fTarget);
                putcdw(bmih.biWidth,fTarget);
                putcdw(bmih.biHeight,fTarget);
                putcdw(bmih.biClrUsed,fTarget);
                putcdw(bmih.biClrImportant,fTarget);
            }
            pos=ftell(fTarget);
            putdw(0,fTarget); /* changed later ! */
            putdw(0,fTarget); /* changed later ! */
            putdw(0,fTarget); /* changed later ! */
            putdw(0,fTarget); /* changed later ! */
            if(byType==6) CopyBytes(f,colors*4L,fTarget);
            offset=ftell(fTarget);
            myFSeek(f,FileStart+dwOffsBitmap+dwPictureOffset);
            dwDataSize=decompress(byPacked&2,f,dwDataSize,(MFILE *)fTarget);
        }
        if(dwHotspotSize)
        {
            myFSeek(f,FileStart+dwOffsBitmap+dwHotspotOffset);
            if(GetChar(f)!=1)
            {
                fprintf(stderr,"No hotspots\n");
                dwHotspotSize=0L;
            }
            else
            {
                unsigned int hotspots,n,j,l;
                unsigned long MacroDataSize;
                char *ptr;
                HOTSPOT *hotspot;

                hotspots=GetWord(f);
                MacroDataSize=GetDWord(f);
                hotspot=myMalloc(hotspots*sizeof(HOTSPOT));
                BlockRead(hotspot,sizeof(HOTSPOT)*hotspots,f);
                if(checkexternal)
                {
                    while(MacroDataSize-->0) GetChar(f);
                }
                else
                {
                    putc(1,fTarget);
                    myPutW(hotspots,fTarget);
                    putdw(MacroDataSize,fTarget);
                    fwrite(hotspot,sizeof(HOTSPOT),hotspots,fTarget);
                    if(MacroDataSize) CopyBytes(f,MacroDataSize,fTarget);
                }
                for(n=0;n<hotspots;n++)
                {
                    j=StringRead(buffer,sizeof(buffer),f)+1;
                    l=j+StringRead(buffer+j,sizeof(buffer)-j,f)+1;
                    if(fTarget) fwrite(buffer,l,1,fTarget);
                    if(extractmacros) switch(hotspot[n].id0)
                    {
                    case 0xC8: /* macro (never seen) */
                    case 0xCC: /* macro without font change */
                        CheckMacro(buffer+j);
                        break;
                    case 0xE0: /* popup jump HC30 */
                    case 0xE1: /* topic jump HC30 */
                    case 0xE2: /* popup jump HC31 */
                    case 0xE3: /* topic jump HC31 */
                    case 0xE6: /* popup jump without font change */
                    case 0xE7: /* topic jump without font change */
                        if(hash(buffer+j)!=hotspot[n].hash)
                        {
                            fprintf(stderr,"Wrong hash %08lx instead %08lx for '%s'\n",hotspot[n].hash,hash(buffer+j),buffer+j);
                        }
                        AddTopic(buffer+j);
                        break;
                    case 0xEA: /* popup jump into external file */
                    case 0xEB: /* topic jump into external file / secondary window */
                    case 0xEE: /* popup jump into external file without font change */
                    case 0xEF: /* topic jump into external file / secondary window without font change */
                        if(hotspot[n].id1!=0&&hotspot[n].id1!=1&&hotspot[n].id1!=4&&hotspot[n].id1!=6||hotspot[n].id2!=0)
                        {
                        }
                        else
                        {
                            filename=strchr(buffer+j,'@');
                            if(filename) *filename++='\0';
                            ptr=strchr(buffer+j,'>');
                            if(ptr) *ptr='\0';
                            if(filename)
                            {
                                CheckExternal(filename,TOPIC,buffer+j,hash(buffer+j));
                            }
                            else
                            {
                                AddTopic(buffer+j);
                            }
                            break;
                        }
                    default:
                        error("Unknown hotspot %02x %02x %02x X=%u Y=%u W=%u H=%u %08lx,%s,%s\n",hotspot[n].id0,hotspot[n].id1,hotspot[n].id2,hotspot[n].x,hotspot[n].y,hotspot[n].w,hotspot[n].h,hotspot[n].hash,buffer,buffer+j);
                    }
                }
                free(hotspot);
            }
        }
        if(!checkexternal)
        {
            dwPictureOffset=offset-nextpict;
            nextpict=ftell(fTarget);
            /* fix up some locations */
            fseek(fTarget,pos,SEEK_SET);
            putdw((dwDataSize<<1)+1,fTarget);
            putdw((dwHotspotSize<<1)+1,fTarget);
            putdw(dwPictureOffset,fTarget);
            if(dwHotspotSize) putdw(dwPictureOffset+dwDataSize,fTarget);
        }
    }
    if(fTarget) myFClose(fTarget);
    return type;
}
/****************************************************************************
// END OF GRAPHICS STUFF
//**************************************************************************/

void HexDump(FILE *f,long FileLength)
{
    unsigned char b[16];
    long l;
    int n,i;

    printf("[-Addr-] [--------------------Data---------------------] [-----Text-----]\n");
    for(l=0;l<FileLength;l+=16)
    {
        printf("%08lX ",l);
        n=(int)(FileLength-l>16?16:FileLength-l);
        for(i=0;i<n;i++) printf("%02X ",b[i]=getc(f));
        while(i++<16) printf("   ");
        for(i=0;i<n;i++) putchar(isprint(b[i])?b[i]:'.');
        putchar('\n');
    }
}

void HexDumpMemory(unsigned char *bypMem,unsigned int FileLength)
{
    unsigned char b[16];
    unsigned int l;
    int n,i;

    printf("[-Addr-] [--------------------Data---------------------] [-----Text-----]\n");
    for(l=0;l<FileLength;l+=16)
    {
        printf("%08lX ",l);
        n=(int)(FileLength-l>16?16:FileLength-l);
        for(i=0;i<n;i++) printf("%02X ",b[i]=*bypMem++);
        while(i++<16) printf("   ");
        for(i=0;i<n;i++) putchar(isprint(b[i])?b[i]:'.');
        putchar('\n');
    }
}

void ListFiles(FILE *HelpFile)
{
    BUFFER buf;
    char FileName[20];
    long FileOffset;
    int j,i,n;

    printf("FileName                FileOffset | FileName                FileOffset\n");
    printf("-----------------------------------+-----------------------------------\n");
    j=0;
    for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
    {
        for(i=0;i<n;i++)
        {
            myGetS(FileName,sizeof(FileName),HelpFile);
            myFRead(&FileOffset,sizeof(FileOffset),HelpFile);
            printf("%-23s 0x%08lX",FileName,FileOffset);
            if(j++&1) putchar('\n'); else printf(" | ");
        }
    }
    if(j&1) putchar('\n');
}

char *getbitmapname(unsigned int n)
{
    static char name[12];

    if(n<extensions&&extension[n])
    {
        sprintf(name,"bm%u.%s",n,bmpext[extension[n]&0x0F]);
    }
    else if(n==65535U)
    {
        missing++;
        fprintf(stderr,"There was a picture file missing on creation of helpfile.\n");
        strcpy(name,"missing.bmp");
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Bitmap bm%u not exported\n",n);
        sprintf(name,"bm%u.bmp",n);
    }
    return name;
}

void ListBitmaps(FILE *hpj)
{
    int i;

    if(hpj&&extensions)
    {
        fprintf(hpj,"[BITMAPS]\n");
        for(i=0;i<extensions;i++) if(extension[i])
        {
            fprintf(hpj,"bm%u.%s\n",i,bmpext[extension[i]&0x0F]);
        }
        putc('\n',hpj);
    }
}

void ExportBitmaps(FILE *HelpFile)
{
    BUFFER buf;
    char *leader;
    char FileName[20];
    long FileOffset,FileLength;
    int i,num,n,type;
    long savepos;

    leader="|bm"+before31;
    SearchFile(HelpFile,NULL,NULL);
    for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
    {
        for(i=0;i<n;i++)
        {
            myGetS(FileName,sizeof(FileName),HelpFile);
            myFRead(&FileOffset,sizeof(FileOffset),HelpFile);
            if(memcmp(FileName,leader,strlen(leader))==0)
            {
                savepos=ftell(HelpFile);
                if(SearchFile(HelpFile,FileName,&FileLength))
                {
                    type=ExtractBitmap(FileName+(FileName[0]=='|'),(MFILE *)HelpFile);
                    if(type)
                    {
                        num=atoi(FileName+(FileName[0]=='|')+2);
                        if(num>=extensions)
                        {
                            extension=myReAlloc(extension,(num+1)*sizeof(char));
                            while(extensions<=num) extension[extensions++]=0;
                        }
                        extension[num]=type;
                    }
                }
                fseek(HelpFile,savepos,SEEK_SET);
            }
        }
    }
}

void ListBaggage(FILE *HelpFile,FILE *hpj)
{
    BOOL headerwritten;
    char *leader;
    char FileName[20];
    long FileOffset,FileLength;
    BUFFER buf;
    int i,n;
    FILE *f;
    long savepos;

    headerwritten=FALSE;
    leader="|bm"+before31;
    SearchFile(HelpFile,NULL,NULL);
    for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
    {
        for(i=0;i<n;i++)
        {
            myGetS(FileName,sizeof(FileName),HelpFile);
            myFRead(&FileOffset,sizeof(FileOffset),HelpFile);
            if(FileName[0]!='|'&&memcmp(FileName,leader,strlen(leader))!=0&&!strstr(FileName,".GRP")&&!strstr(FileName,".tbl"))
            {
                savepos=ftell(HelpFile);
                if(SearchFile(HelpFile,FileName,&FileLength))
                {
                    if(!headerwritten)
                    {
                        fprintf(hpj,"[BAGGAGE]\n");
                        headerwritten=TRUE;
                    }
                    fprintf(hpj,"%s\n",FileName);
                    f=myFOpen(FileName,"wb");
                    if(f)
                    {
                        copy(HelpFile,FileLength,f);
                        myFClose(f);
                    }
                }
                fseek(HelpFile,savepos,SEEK_SET);
            }
        }
    }
    if(headerwritten) putc('\n',hpj);
}

void PhrImageDump(FILE *HelpFile)
{
    long FileLength;
    unsigned int bytes;
    PHRINDEXHDR PhrIndexHdr;
    unsigned char *ptr;
    MFILE *f;

    if(SearchFile(HelpFile,"|PhrIndex",NULL))
    {
        myFRead(&PhrIndexHdr,sizeof(PhrIndexHdr),HelpFile);
        if(SearchFile(HelpFile,"|PhrImage",&FileLength))
        {
            if(PhrIndexHdr.phrimagesize==PhrIndexHdr.phrimagecompressedsize)
            {
                HexDump(HelpFile,FileLength);
            }
            else
            {
                if(FileLength!=PhrIndexHdr.phrimagecompressedsize)
                {
                    fprintf(stderr,"PhrImage FileSize %ld, in PhrIndex.FileHdr %ld\n",PhrIndexHdr.phrimagecompressedsize,FileLength);
                }
                ptr=myMalloc(PhrIndexHdr.phrimagesize);
                f=CreateMap(ptr,PhrIndexHdr.phrimagesize);
                bytes=decompress(2,(MFILE *)HelpFile,FileLength,f);
                CloseMap(f);
                if(bytes!=PhrIndexHdr.phrimagesize)
                {
                    fprintf(stderr,"PhrImage Size %ld, in PhrIndex %ld\n",PhrIndexHdr.phrimagesize,FileLength);
                }
                HexDumpMemory(ptr,bytes);
                free(ptr);
            }
        }
    }
}

char *TopicName(long topic)
{
    static char name[20];
    int i;

    if(before31)
    {
        if(topic==0L) topic=Topic[0];
        for(i=16;i<Topics;i++) if(Topic[i]==topic)
        {
            sprintf(name,"TOPIC%d",i);
            return name;
        }
    }
    else
    {
        if(topic==-1L)
        {
            NotInAnyTopic=TRUE;
            return "21KSYK4"; /* evaluates to -1 without generating help compiler warning */
        }
        for(i=0;i<ContextRecs;i++)
        {
            if(ContextRec[i].TopicOffset==topic)
            {
                return unhash(ContextRec[i].HashValue);
            }
        }
    }
    fprintf(stderr,"Can not find topic offset %08lx\n",topic);
    return NULL;
}

void SysList(FILE *HelpFile,FILE *hpj,char *IconFileName)
{
    long FileLength;
    SYSTEMHEADER SysHdr;
    SYSTEMRECORD *SysRec;
    STOPHEADER StopHdr;
    SECWINDOW *SWin;
    char name[51];
    char kwdata[10];
    char kwbtree[10];
    char *ptr;
    long color;
    FILE *f;
    int fbreak,macro,windows,i,keyword,dllmaps,n;

    if(hpj&&SearchFile(HelpFile,"|SYSTEM",NULL))
    {
        myFRead(&SysHdr,sizeof(SysHdr),HelpFile);
        if(SysHdr.Version==15)
        {
            strcpy(helpcomp,"HC30");
        }
        else if(SysHdr.Version==21)
        {
            strcpy(helpcomp,"HC31");
        }
        else if(SysHdr.Version==27)
        {
            strcpy(helpcomp,"WMVC/MVCC");
        }
        else if(SysHdr.Version==33)
        {
            if(mvp)
            {
                strcpy(helpcomp,"MVC");
            }
            else
            {
                strcpy(helpcomp,"HCRTF");
                win95=TRUE;
            }
        }
        fprintf(hpj,"[OPTIONS]\n");
        if(before31) /* If 3.0 get title */
        {
            myGetS(HelpFileTitle,33,HelpFile);
            if(HelpFileTitle[0]!='\0'&&HelpFileTitle[0]!='\n')
            {
                fprintf(hpj,"TITLE=%s\n",HelpFileTitle);
                fprintf(hpj,"INDEX=%s\n",TopicName(0L));
            }
            if(PhraseCount)
            {
                fprintf(hpj,"COMPRESS=TRUE\n");
            }
            else
            {
                fprintf(hpj,"COMPRESS=FALSE\n");
            }
            for(i='A';i<='z';i++)
            {
                sprintf(kwdata,"|%cWDATA",i);
                sprintf(kwbtree,"|%cWBTREE",i);
                if(SearchFile(HelpFile,kwdata,NULL)&&SearchFile(HelpFile,kwbtree,NULL))
                {
                    lists[i-'0']=TRUE;
                    if(i!='K') fprintf(hpj,"MULTIKEY=%c\n",i);
                }
            }
            putc('\n',hpj);
        }
        else  /* else get 3.1 System records */
        {
            macro=0;
            fbreak=0;
            windows=0;
            keyword=0;
            dllmaps=0;
            for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
            {
                switch(SysRec->RecordType)
                {
                case 0x0001:
                    if(SysRec->Data[0]) fprintf(hpj,"TITLE=%s\n",SysRec->Data);
                    break;
                case 0x0002:
                    ptr=strchr(SysRec->Data,'\r');
                    if(ptr) strcpy(ptr,"%date");
                    if(SysRec->Data[0]) fprintf(hpj,"COPYRIGHT=%s\n",SysRec->Data);
                    break;
                case 0x0003:
                    if(*(long *)SysRec->Data!=0L)
                    {
                        ptr=TopicName(*(long *)SysRec->Data);
                        if(ptr) fprintf(hpj,"CONTENTS=%s\n",ptr);
                    }
                    break;
                case 0x0004:
                    macro=1;
                    break;
                case 0x0005:
                    fprintf(hpj,"ICON=%s\n",IconFileName);
                    f=myFOpen(IconFileName,"wb");
                    if(f)
                    {
                        fwrite(SysRec->Data,SysRec->DataSize,1,f);
                        myFClose(f);
                    }
                    break;
                case 0x0006:
                    windows++;
                    break;
                case 0x0008:
                    if(SysRec->Data[0]) fprintf(hpj,"CITATION=%s\n",SysRec->Data);
                    break;
                case 0x0009:
                    if(!mvp) fprintf(hpj,"LCID=0x%X 0x%X 0x%X\n",*(short *)(SysRec->Data+8),*(short *)SysRec->Data,*(short *)(SysRec->Data+2));
                    break;
                case 0x000A:
                    if(!mvp&&SysRec->Data[0]) fprintf(hpj,"CNT=%s\n",SysRec->Data);
                    break;
                case 0x000B:
                    if(!mvp) fprintf(hpj,"CHARSET=%d\n",*(unsigned char *)(SysRec->Data+1));
                    break;
                case 0x000C:
                    if(mvp)
                    {
                        fbreak=1;
                    }
                    else
                    {
                        fprintf(hpj,"DEFFONT=%s,%d,%d\n",SysRec->Data+2,*(unsigned char *)SysRec->Data,*(unsigned char *)(SysRec->Data+1));
                    }
                    break;
                case 0x000D:
                    if(mvp) groups++;
                    break;
                case 0x000E:
                    if(mvp)
                    {
                        keyword=1;
                    }
                    else
                    {
                        fprintf(hpj,"INDEX_SEPARATORS=\"%s\"\n",SysRec->Data);
                        strcpy(index_separators,SysRec->Data);
                    }
                    break;
                case 0x0012:
                    if(SysRec->Data[0]) fprintf(hpj,"LANGUAGE=%s\n",SysRec->Data);
                    break;
                case 0x0013:
                    dllmaps=1;
                    break;
                }
            }
            if(win95)
            {
                i=0;
                if(lzcompressed) i|=8;
                if(NewPhrases) i|=4; else if(PhraseCount) i|=2;
                fprintf(hpj,"COMPRESS=%d\n",i);
            }
            else if(!lzcompressed)
            {
                fprintf(hpj,"COMPRESS=FALSE\n");
            }
            else if(PhraseCount)
            {
                fprintf(hpj,"COMPRESS=TRUE\n");
            }
            else
            {
                fprintf(hpj,"COMPRESS=MEDIUM\n");
            }
            if(SysHdr.Flags==8) fprintf(hpj,"CDROMOPT=TRUE\n");
            for(i='A';i<='z';i++)
            {
                sprintf(kwdata,"|%cWDATA",i);
                sprintf(kwbtree,"|%cWBTREE",i);
                if(SearchFile(HelpFile,kwdata,NULL)&&SearchFile(HelpFile,kwbtree,NULL))
                {
                    lists[i-'0']=TRUE;
                    if(i!='K'&&(i!='A'||!win95))
                    {
                        fprintf(hpj,"MULTIKEY=%c\n",i);
                    }
                }
            }
            putc('\n',hpj);
            if(windows)
            {
                windowname=myMalloc(windows*sizeof(char *));
                windownames=windows;
                for(i=0;i<windows;i++) windowname[i]=NULL;
                fprintf(hpj,"[WINDOWS]\n");
                i=0;
                for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
                {
                    if(SysRec->RecordType==0x0006)
                    {
                        SWin=(SECWINDOW *)SysRec->Data;
                        if(SWin->Flags&WSYSFLAG_NAME)
                        {
                            fprintf(hpj,"%s",SWin->Name);
                            windowname[i]=myStrDup(SWin->Name);
                        }
                        i++;
                        fprintf(hpj,"=");
                        if(SWin->Flags&WSYSFLAG_CAPTION) fprintf(hpj,"\"%s\"",SWin->Caption);
                        fprintf(hpj,",");
                        if(SWin->Flags&(WSYSFLAG_X|WSYSFLAG_Y|WSYSFLAG_WIDTH|WSYSFLAG_HEIGHT))
                        {
                            fprintf(hpj,"(");
                            if(SWin->Flags&WSYSFLAG_X) fprintf(hpj,"%d",SWin->X);
                            fprintf(hpj,",");
                            if(SWin->Flags&WSYSFLAG_Y) fprintf(hpj,"%d",SWin->Y);
                            fprintf(hpj,",");
                            if(SWin->Flags&WSYSFLAG_WIDTH) fprintf(hpj,"%d",SWin->Width);
                            fprintf(hpj,",");
                            if(SWin->Flags&WSYSFLAG_HEIGHT) fprintf(hpj,"%d",SWin->Height);
                            fprintf(hpj,")");
                        }
                        fprintf(hpj,",");
                        if(SWin->Maximize) fprintf(hpj,"%d",SWin->Maximize);
                        fprintf(hpj,",");
                        if(SWin->Flags&WSYSFLAG_RGB) fprintf(hpj,"(%d,%d,%d)",SWin->Rgb[0],SWin->Rgb[1],SWin->Rgb[2]);
                        fprintf(hpj,",");
                        if(SWin->Flags&WSYSFLAG_RGBNSR) fprintf(hpj,"(%d,%d,%d)",SWin->RgbNsr[0],SWin->RgbNsr[1],SWin->RgbNsr[2]);
                        if(SWin->Flags&(WSYSFLAG_TOP|WSYSFLAG_AUTOSIZEHEIGHT))
                        {
                            if(SWin->Flags&WSYSFLAG_AUTOSIZEHEIGHT)
                            {
                                if(SWin->Flags&WSYSFLAG_TOP)
                                {
                                    fprintf(hpj,",f3");
                                }
                                else
                                {
                                    fprintf(hpj,",f2");
                                }
                            }
                            else fprintf(hpj,",1");
                        }
                        putc('\n',hpj);
                    }
                }
                putc('\n',hpj);
            }
            if(macro)
            {
                fprintf(hpj,"[CONFIG]\n");
                for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
                {
                    if(SysRec->RecordType==0x0004)
                    {
                        if(sscanf(SysRec->Data,"SPC(%ld)%n",&color,&n)>0)
                        {
                            fprintf(hpj,"SPC(%u,%u,%u)%s\n",(unsigned char)(color),(unsigned char)(color>>8),(unsigned char)(color>>16),SysRec->Data+n);
                        }
                        else
                        {
                            fprintf(hpj,"%s\n",SysRec->Data);
                        }
                    }
                }
                putc('\n',hpj);
            }
            if(fbreak)
            {
                fprintf(hpj,"[FTINDEX]\n");
                for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
                {
                    if(SysRec->RecordType==0x000C)
                    {
                        ptr=strtok(SysRec->Data," ");
                        if(ptr)
                        {
                            fprintf(hpj,"dtype%s",ptr);
                            ptr=strtok(NULL," ");
                            if(ptr)
                            {
                                fprintf(hpj,"=%s",ptr);
                                ptr=strtok(NULL," ");
                                if(ptr)
                                {
                                    fprintf(hpj,"!%s",ptr);
                                    ptr=strtok(NULL," ");
                                    if(ptr)
                                    {
                                        fprintf(hpj,",%s",ptr+1);
                                        if(SearchFile(HelpFile,ptr,NULL))
                                        {
                                            for(n=0;n<stopwordfiles;n++)
                                            {
                                                if(strcmp(stopwordfilename[n],ptr)==0) break;
                                            }
                                            if(n==stopwordfiles)
                                            {
                                                stopwordfilename=myReAlloc(stopwordfilename,(stopwordfiles+1)*sizeof(char *));
                                                stopwordfilename[stopwordfiles++]=myStrDup(ptr);
                                                f=myFOpen(ptr+1,"wt");
                                                if(f)
                                                {
                                                    myFRead(&StopHdr,sizeof(StopHdr),HelpFile);
                                                    for(n=0;n<StopHdr.BytesUsed;n+=1+strlen(buffer))
                                                    {
                                                        i=getc(HelpFile);
                                                        myFRead(buffer,i,HelpFile);
                                                        buffer[i]='\0';
                                                        fprintf(f,"%s\n",buffer);
                                                    }
                                                    myFClose(f);
                                                }
                                            }
                                        }
                                        ptr=strtok(NULL," ");
                                        if(ptr) fprintf(hpj,",%s",ptr);
                                    }
                                }
                            }
                            putc('\n',hpj);
                        }
                    }
                }
                putc('\n',hpj);
            }
            if(groups||multi&&browsenums>1)
            {
                group=myMalloc(groups*sizeof(GROUP));
                fprintf(hpj,"[GROUPS]\n");
                i=0;
                for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
                {
                    if(SysRec->RecordType==0x000D)
                    {
                        ptr=strchr(SysRec->Data,' ');
                        if(ptr) *ptr++='\0';
                        if(SearchFile(HelpFile,SysRec->Data,NULL))
                        {
                            n=strcspn(SysRec->Data,".");
                            SysRec->Data[n]='\0';
                            if(ptr&&strcmp(ptr,"\"\" ")==0)
                            {
                                fprintf(hpj,"group=%s\n",SysRec->Data);
                            }
                            else
                            {
                                fprintf(hpj,"group=%s,%s\n",SysRec->Data,ptr);
                            }
                            group[i].Name=myStrDup(SysRec->Data);
                            myFRead(&group[i].GroupHeader,sizeof(group[i].GroupHeader),HelpFile);
                            if(group[i].GroupHeader.GroupType==2)
                            {
                                group[i].Bitmap=myMalloc(group[i].GroupHeader.BitmapSize);
                                myFRead(group[i].Bitmap,group[i].GroupHeader.BitmapSize,HelpFile);
                            }
                        }
                        i++;
                    }
                }
                if(multi) for(i=1;i<browsenums;i++) fprintf(hpj,"group=BROWSE%04x\n",i);
                putc('\n',hpj);
            }
            if(dllmaps)
            {
                fprintf(hpj,"[DLLMAPS]\n");
                for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
                {
                    if(SysRec->RecordType==0x0013)
                    {
                        if(strcmp(SysRec->Data,"MVMCI")!=0&&strcmp(SysRec->Data,"MVIMAGE")!=0&&strcmp(SysRec->Data,"MVBRKR")!=0)
                        {
                            ptr=SysRec->Data+strlen(SysRec->Data)+1;
                            fprintf(hpj,"%s=%s,",SysRec->Data,ptr);
                            ptr=ptr+strlen(ptr)+1;
                            fprintf(hpj,"%s,",ptr);
                            ptr=ptr+strlen(ptr)+1;
                            fprintf(hpj,"%s,",ptr);
                            ptr=ptr+strlen(ptr)+1;
                            fprintf(hpj,"%s\n",ptr);
                        }
                    }
                }
                putc('\n',hpj);
            }
            if(keyword)
            {
                fprintf(hpj,"[KEYINDEX]\n");
                for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
                {
                    if(SysRec->RecordType==0x000E)
                    {
                        fprintf(hpj,"keyword=%c,\"%s\"\n",SysRec->Data[1],SysRec->Data+30);
                        keyindex[SysRec->Data[1]-'0']=TRUE;
                    }
                }
                putc('\n',hpj);
            }
            for(i=0;i<windows;i++)
            {
                sprintf(name,"|CF%d",i);
                if(SearchFile(HelpFile,name,&FileLength))
                {
                    fprintf(hpj,"[CONFIG:%d]\n",i);
                    /* may use [CONFIG-WindowName] instead, but WindowName need not be defined */
                    for(n=0;n<FileLength;n+=strlen(buffer)+1)
                    {
                        myGetS(buffer,sizeof(buffer),HelpFile);
                        fprintf(hpj,"%s\n",buffer);
                    }
                    putc('\n',hpj);
                }
            }
        }
    }
}

char *PrintPhrase(unsigned int PhraseNum,char *out,FILE *f)
{
    char *ptr;
    char *end;

    if(PhraseNum>=PhraseCount)
    {
        error("Phrase %u does not exist\n",PhraseNum);
        return out;
    }
    if(NewPhrases)
    {
        ptr=NewPhrases+NewOffsets[PhraseNum];
        end=NewPhrases+NewOffsets[PhraseNum+1];
    }
    else
    {
        ptr=(char *)Offsets+Offsets[PhraseNum];
        end=(char *)Offsets+Offsets[PhraseNum+1];
    }
    while(ptr<end)
    {
        if(out)
        {
            *out++=*ptr++;
        }
        else if(f)
        {
            putc(*ptr++,f);
        }
        else if(isprint((unsigned char)*ptr))
        {
            putchar(*ptr++);
        }
        else
        {
            printf("(%02x)",*(unsigned char *)ptr++);
        }
    }
    if(out) *out='\0';
    return out;
}

BOOL GetBit(FILE *f)
{
    static unsigned long mask;
    static unsigned long value;

    if(f)
    {
        mask<<=1;
        if(!mask)
        {
            value=GetDWord((MFILE *)f);
            mask=1L;
        }
    }
    else
    {
        mask=0L; /* initialize */
    }
    return (value&mask)!=0L;
}

BOOL PhraseLoad(FILE *HelpFile)
{
    long FileLength;
    char junk[30];
    BOOL newphrases;
    PHRINDEXHDR PhrIndexHdr;
    unsigned int n;
    long l,offset;
    char *ptr;
    MFILE *f;
    long SavePos;

    if(SearchFile(HelpFile,"|Phrases",&FileLength))
    {
        offset=ftell(HelpFile);
        PhraseCount=myGetW(HelpFile);
        newphrases=PhraseCount==0x0800;
        if(newphrases) PhraseCount=myGetW(HelpFile);
        if(myGetW(HelpFile)!=0x0100)
        {
            fprintf(stderr,"Phrases file structure unknown\n");
            return FALSE;
        }
        if(PhraseCount)
        {
            if(before31)
            {
                Offsets=myMalloc(FileLength-4);
                myFRead(Offsets,FileLength-4,HelpFile);
            }
            else
            {
                myFRead(&l,sizeof(l),HelpFile);
                if(newphrases) myFRead(&junk,sizeof(junk),HelpFile);
                Offsets=myMalloc(2*(PhraseCount+1)+l);
                ptr=(char *)(Offsets+PhraseCount+1);
                myFRead(Offsets,2*(PhraseCount+1),HelpFile);
                f=CreateMap(ptr,l);
                n=decompress(2,(MFILE *)HelpFile,FileLength-(ftell(HelpFile)-offset),f);
                CloseMap(f);
                if(n!=l)
                {
                    error("Phrases decompressed into %u instead %ld\n",n,l);
                }
            }
            printf("%u phrases loaded\n",PhraseCount);
        }
        return TRUE;
    }
    else if(SearchFile(HelpFile,"|PhrIndex",NULL))
    {
        myFRead(&PhrIndexHdr,sizeof(PhrIndexHdr),HelpFile);
        if(PhrIndexHdr.always4A01!=1&&PhrIndexHdr.always4A01!=0x4A01) fprintf(stderr,"PhrIndexHdr.always4A01=%04x\n",PhrIndexHdr.always4A01);
        if(PhrIndexHdr.always0!=0) fprintf(stderr,"PhrIndexHdr.always0=%04x\n",PhrIndexHdr.always0);
        if(PhrIndexHdr.always4A00!=0x4A00&&PhrIndexHdr.always4A00!=0x4A01&&PhrIndexHdr.always4A00!=0x4A02) fprintf(stderr,"PhrIndexHdr.always4A00=%04x\n",PhrIndexHdr.always4A00);
        SavePos=ftell(HelpFile);
        if(SearchFile(HelpFile,"|PhrImage",&FileLength))
        {
            if(FileLength!=PhrIndexHdr.phrimagecompressedsize)
            {
                fprintf(stderr,"PhrImage FileSize %ld, in PhrIndex.FileHdr %ld\n",PhrIndexHdr.phrimagecompressedsize,FileLength);
            }
            PhraseCount=(unsigned int)PhrIndexHdr.entries;
            NewOffsets=myMalloc(sizeof(unsigned int)*(PhraseCount+1));
            NewPhrases=myMalloc(PhrIndexHdr.phrimagesize);
            if(PhrIndexHdr.phrimagesize==PhrIndexHdr.phrimagecompressedsize)
            {
                myFRead(NewPhrases,PhrIndexHdr.phrimagesize,HelpFile);
            }
            else
            {
                f=CreateMap(NewPhrases,PhrIndexHdr.phrimagesize);
                n=decompress(2,(MFILE *)HelpFile,FileLength,f);
                CloseMap(f);
                if(n!=PhrIndexHdr.phrimagesize)
                {
                    fprintf(stderr,"PhrImage Size %ld, in PhrIndex %u\n",PhrIndexHdr.phrimagesize,n);
                }
            }
            fseek(HelpFile,SavePos,SEEK_SET);
            GetBit(NULL);
            offset=0;
            NewOffsets[0]=offset;
            for(l=0;l<PhrIndexHdr.entries;l++)
            {
                for(n=1;GetBit(HelpFile);n+=1<<PhrIndexHdr.bits) ;
                if(GetBit(HelpFile)) n+=1;
                if(PhrIndexHdr.bits>1) if(GetBit(HelpFile)) n+=2;
                if(PhrIndexHdr.bits>2) if(GetBit(HelpFile)) n+=4;
                if(PhrIndexHdr.bits>3) if(GetBit(HelpFile)) n+=8;
                if(PhrIndexHdr.bits>4) if(GetBit(HelpFile)) n+=16;
                offset+=n;
                NewOffsets[(int)l+1]=offset;
            }
        }
        printf("%u phrases loaded\n",PhraseCount);
        return TRUE;
    }
    return FALSE;
}

void PhraseList(char *FileName)
{
    FILE *f;
    unsigned int n;

    if(PhraseCount)
    {
        f=myFOpen(FileName,"wt");
        if(f)
        {
            for(n=0;n<PhraseCount;n++)
            {
                PrintPhrase(n,NULL,f);
                putc('\n',f);
            }
            myFClose(f);
        }
    }
}

char *FontFamily(unsigned int i)
{
    static char *familyname[]={"swiss","modern","roman","swiss","script","decor"};

    if(i>0&&i<6) return familyname[i];
    return familyname[0];
}

void FontLoad(FILE *HelpFile,FILE *rtf,FILE *hpj)
{
    CHARMAPHEADER CharmapHeader;
    FONTHEADER FontHdr;
    FILE *f;
    char FontName[33];
    char CharMap[33];
    char *ptr;
    char *p;
    long FontStart;
    int i,j,k,l,n;
    struct { unsigned char r,g,b; } color[128];
    unsigned char *family;
    int colors;
    BOOL charmap;
    MVBFONT mvbfont;
    MVBSTYLE *mvbstyle;
    NEWFONT newfont;
    OLDFONT oldfont;

    if(SearchFile(HelpFile,"|FONT",NULL))
    {
        FontStart=ftell(HelpFile);
        myFRead(&FontHdr,sizeof(FontHdr),HelpFile);
        fontnames=FontHdr.NumFacenames;
        n=(FontHdr.DescriptorsOffset-FontHdr.FacenamesOffset)/fontnames;
        fontname=myMalloc(fontnames*sizeof(char *));
        family=myMalloc(fontnames*sizeof(unsigned char));
        for(i=0;i<fontnames;i++) family[i]=0;
        charmap=FALSE;
        for(i=0;i<fontnames;i++)
        {
            fseek(HelpFile,FontStart+FontHdr.FacenamesOffset+n*i,SEEK_SET);
            myFRead(FontName,n,HelpFile);
            FontName[n]='\0';
            ptr=strchr(FontName,',');
            if(ptr&&FontHdr.FacenamesOffset>=16)
            {
                *ptr++='\0';
                fseek(HelpFile,FontStart+FontHdr.CharmapsOffset,SEEK_SET);
                for(j=0;hpj&&j<FontHdr.NumCharmaps;j++)
                {
                    myFRead(CharMap,32,HelpFile);
                    CharMap[32]='\0';
                    p=strchr(CharMap,',');
                    if(p&&strcmp(p+1,ptr)==0&&strcmp(CharMap,"|MVCHARTAB,0")!=0)
                    {
                        if(!charmap)
                        {
                            fprintf(hpj,"[CHARMAP]\n");
                            charmap=TRUE;
                        }
                        *p++='\0';
                        if(strcmp(p,"0")==0)
                        {
                            fprintf(hpj,"DEFAULT=%s\n",CharMap);
                        }
                        else
                        {
                            fprintf(hpj,"%s=%s\n",FontName,CharMap);
                        }
                        break;
                    }
                }
            }
            fontname[i]=myStrDup(FontName);
        }
        if(charmap) putc('\n',hpj);
        if(FontHdr.FacenamesOffset>=16) for(j=0;j<FontHdr.NumCharmaps;j++)
        {
            fseek(HelpFile,FontStart+FontHdr.CharmapsOffset+j*32,SEEK_SET);
            myFRead(CharMap,32,HelpFile);
            CharMap[32]='\0';
            p=strchr(CharMap,',');
            if(p&&strcmp(CharMap,"|MVCHARTAB,0")!=0)
            {
                *p++='\0';
                if(SearchFile(HelpFile,CharMap,NULL))
                {
                    myFRead(&CharmapHeader,sizeof(CHARMAPHEADER),HelpFile);
                    f=myFOpen(CharMap,"wt");
                    if(f)
                    {
                        fprintf(f,"%d,\n",CharmapHeader.Entries);
                        for(k=0;k<CharmapHeader.Entries;k++)
                        {
                            fprintf(f,"%5u,",myGetW(HelpFile));
                            fprintf(f,"%5u,",myGetW(HelpFile));
                            fprintf(f,"%3u,",getc(HelpFile));
                            fprintf(f,"%3u,",getc(HelpFile));
                            fprintf(f,"%3u,",getc(HelpFile));
                            fprintf(f,"%3u,\n",getc(HelpFile));
                            myGetW(HelpFile);
                        }
                        fprintf(f,"%d,\n",CharmapHeader.Ligatures);
                        for(k=0;k<CharmapHeader.Ligatures;k++)
                        {
                            for(l=0;l<CharmapHeader.LigLen;l++)
                            {
                                fprintf(f,"%3u,",getc(HelpFile));
                            }
                            putc('\n',f);
                        }
                        myFClose(f);
                    }
                }
            }
        }
        fseek(HelpFile,FontStart+FontHdr.DescriptorsOffset,SEEK_SET);
        colors=1;     /* auto */
        color[0].r=1;
        color[0].g=1;
        color[0].b=0;
        fonts=FontHdr.NumDescriptors;
        font=myMalloc(fonts*sizeof(FONTDESCRIPTOR));
        memset(font,0,fonts*sizeof(FONTDESCRIPTOR));
        if(FontHdr.FacenamesOffset>=16)
        {
            scaling=1;
            for(i=0;i<FontHdr.NumDescriptors;i++)
            {
                myFRead(&mvbfont,sizeof(mvbfont),HelpFile);
                font[i].FontName=mvbfont.FontName;
                font[i].HalfPoints=-2L*mvbfont.Height;
                font[i].Attributes=0;
                if(mvbfont.Weight>500) font[i].Attributes|=FONT_BOLD;
                if(mvbfont.Italic) font[i].Attributes|=FONT_ITAL;
                if(mvbfont.Underline) font[i].Attributes|=FONT_UNDR;
                if(mvbfont.StrikeOut) font[i].Attributes|=FONT_STRK;
                if(mvbfont.DoubleUnderline) font[i].Attributes|=FONT_DBUN;
                if(mvbfont.SmallCaps) font[i].Attributes|=FONT_SMCP;
                font[i].FGRGB[0]=mvbfont.FGRGB[0];
                font[i].FGRGB[1]=mvbfont.FGRGB[1];
                font[i].FGRGB[2]=mvbfont.FGRGB[2];
                font[i].BGRGB[0]=mvbfont.BGRGB[0];
                font[i].BGRGB[1]=mvbfont.BGRGB[1];
                font[i].BGRGB[2]=mvbfont.BGRGB[2];
                font[i].FontFamily=mvbfont.PitchAndFamily>>4;
                font[i].style=mvbfont.style;
                font[i].up=mvbfont.up;
                font[i].expndtw=mvbfont.expndtw;
            }
        }
        else if(FontHdr.FacenamesOffset>=12)
        {
            scaling=1;
            for(i=0;i<FontHdr.NumDescriptors;i++)
            {
                myFRead(&newfont,sizeof(NEWFONT),HelpFile);
                font[i].Attributes=0;
                if(newfont.Weight>500) font[i].Attributes|=FONT_BOLD;
                if(newfont.Italic) font[i].Attributes|=FONT_ITAL;
                if(newfont.Underline) font[i].Attributes|=FONT_UNDR;
                if(newfont.StrikeOut) font[i].Attributes|=FONT_STRK;
                if(newfont.DoubleUnderline) font[i].Attributes|=FONT_DBUN;
                if(newfont.SmallCaps) font[i].Attributes|=FONT_SMCP;
                font[i].FontName=newfont.FontName;
                font[i].HalfPoints=-2L*newfont.Height;
                font[i].FGRGB[0]=newfont.FGRGB[0];
                font[i].FGRGB[1]=newfont.FGRGB[1];
                font[i].FGRGB[2]=newfont.FGRGB[2];
                font[i].BGRGB[0]=newfont.BGRGB[0];
                font[i].BGRGB[1]=newfont.BGRGB[1];
                font[i].BGRGB[2]=newfont.BGRGB[2];
                font[i].FontFamily=newfont.PitchAndFamily>>4;
            }
        }
        else
        {
            for(i=0;i<FontHdr.NumDescriptors;i++)
            {
                myFRead(&oldfont,sizeof(OLDFONT),HelpFile);
                font[i].Attributes=oldfont.Attributes;
                font[i].FontName=oldfont.FontName;
                font[i].HalfPoints=oldfont.HalfPoints;
                font[i].FGRGB[0]=oldfont.FGRGB[0];
                font[i].FGRGB[1]=oldfont.FGRGB[1];
                font[i].FGRGB[2]=oldfont.FGRGB[2];
                font[i].BGRGB[0]=oldfont.BGRGB[0];
                font[i].BGRGB[1]=oldfont.BGRGB[1];
                font[i].BGRGB[2]=oldfont.BGRGB[2];
                font[i].FontFamily=oldfont.FontFamily;
            }
        }
        for(i=0;i<FontHdr.NumDescriptors;i++)
        {
            if(font[i].FontName<fontnames)
            {
                 family[font[i].FontName]=font[i].FontFamily;
            }
            for(n=0;n<colors;n++)
            {
                if(font[i].FGRGB[0]==color[n].r&&font[i].FGRGB[1]==color[n].g&&font[i].FGRGB[2]==color[n].b) break;
            }
            if(n==colors)
            {
                color[colors].r=font[i].FGRGB[0];
                color[colors].g=font[i].FGRGB[1];
                color[colors].b=font[i].FGRGB[2];
                colors++;
            }
            font[i].FGRGB[0]=n;
        }
        if(FontHdr.FacenamesOffset>=16)
        {
            fseek(HelpFile,FontStart+FontHdr.FormatsOffset,SEEK_SET);
            mvbstyle=myMalloc(FontHdr.NumFormats*sizeof(MVBSTYLE));
            myFRead(mvbstyle,FontHdr.NumFormats*sizeof(MVBSTYLE),HelpFile);
            for(i=0;i<FontHdr.NumFormats;i++)
            {
                for(n=0;n<colors;n++)
                {
                    if(mvbstyle[i].font.FGRGB[0]==color[n].r&&mvbstyle[i].font.FGRGB[1]==color[n].g&&mvbstyle[i].font.FGRGB[2]==color[n].b) break;
                }
                if(n==colors)
                {
                    color[colors].r=mvbstyle[i].font.FGRGB[0];
                    color[colors].g=mvbstyle[i].font.FGRGB[1];
                    color[colors].b=mvbstyle[i].font.FGRGB[2];
                    colors++;
                }
                mvbstyle[i].font.FGRGB[0]=n;
            }
        }
        fprintf(rtf,"{\\fonttbl");
        for(n=0;n<fontnames;n++) fprintf(rtf,"{\\f%d\\f%s %s;}",n,FontFamily(family[n]),fontname[n]);
        fprintf(rtf,"}\n");
        if(colors>1)
        {
            fprintf(rtf,"{\\colortbl;");
            for(n=1;n<colors;n++) fprintf(rtf,"\\red%d\\green%d\\blue%d;",color[n].r,color[n].g,color[n].b);
            fprintf(rtf,"}\n");
        }
        printf("%u font names, %u font descriptors",fontnames,FontHdr.NumDescriptors);
        fprintf(rtf,"{\\stylesheet{\\fs%d \\snext0 Normal;}\n",font[0].HalfPoints);
        if(FontHdr.FacenamesOffset>=16&&mvbstyle)
        {
            for(i=0;i<FontHdr.NumFormats;i++)
            {
                fprintf(rtf,"{\\*\\cs%u \\additive",mvbstyle[i].StyleNum+9);
                if(mvbstyle[i].BasedOn)
                {
                    n=mvbstyle[i].BasedOn-1;
                    if(mvbstyle[i].font.FontName!=mvbstyle[n].font.FontName) fprintf(rtf,"\\f%d",mvbstyle[i].font.FontName);
                    if(mvbstyle[i].font.expndtw!=mvbstyle[n].font.expndtw) fprintf(rtf,"\\expndtw%d",mvbstyle[i].font.expndtw);
                    if(mvbstyle[i].font.FGRGB[0]!=mvbstyle[n].font.FGRGB[0]) fprintf(rtf,"\\cf%d",mvbstyle[i].font.FGRGB[0]);
                    if(mvbstyle[i].font.Height!=mvbstyle[n].font.Height) fprintf(rtf,"\\fs%d",-2L*mvbstyle[i].font.Height);
                    if((mvbstyle[i].font.Weight>500)!=(mvbstyle[n].font.Weight>500)) fprintf(rtf,"\\b%d",mvbstyle[i].font.Weight>500);
                    if(mvbstyle[i].font.Italic!=mvbstyle[n].font.Italic) fprintf(rtf,"\\i%d",mvbstyle[i].font.Italic);
                    if(mvbstyle[i].font.Underline!=mvbstyle[n].font.Underline) fprintf(rtf,"\\ul%d",mvbstyle[i].font.Underline);
                    if(mvbstyle[i].font.StrikeOut!=mvbstyle[n].font.StrikeOut) fprintf(rtf,"\\strike%d",mvbstyle[i].font.StrikeOut);
                    if(mvbstyle[i].font.DoubleUnderline!=mvbstyle[n].font.DoubleUnderline) fprintf(rtf,"\\uldb%d",mvbstyle[i].font.DoubleUnderline);
                    if(mvbstyle[i].font.SmallCaps!=mvbstyle[n].font.SmallCaps) fprintf(rtf,"\\scaps%d",mvbstyle[i].font.SmallCaps);
                    if(mvbstyle[i].font.up!=mvbstyle[n].font.up) if(mvbstyle[i].font.up>0) fprintf(rtf,"\\up%d",mvbstyle[i].font.up); else fprintf(rtf,"\\dn%d",-mvbstyle[i].font.up);
                    fprintf(rtf," \\sbasedon%u",mvbstyle[i].BasedOn+9);
                }
                fprintf(rtf," %s;}\n",mvbstyle[i].StyleName);
            }
            free(mvbstyle);
            printf(", %u font styles",FontHdr.NumFormats);
        }
        putc('}',rtf);
        printf(" loaded\n");
        if(family) free(family);
    }
}

void ToMapLoad(FILE *HelpFile)
{
    long FileLength;

    if(SearchFile(HelpFile,"|TOMAP",&FileLength))
    {
        Topic=myMalloc(FileLength);
        myFRead(Topic,FileLength,HelpFile);
        Topics=(int)(FileLength/sizeof(long));
    }
}

long TopicRead(FILE *HelpFile,long TopicAddress,void *dest,long NumBytes)
{
    static long NextTopic;
    static long BlockNum;
    long NewBlockNum;
    unsigned char *Dest;
    unsigned int BytesToRead;
    static unsigned int DecompSize;
    static unsigned int offset;
    TOPICLINK *TopicLink;
    unsigned int BytesRead;
    static long BytesInBlock;
    long here;
    MFILE *f;

    Dest=dest;
    if(TopicAddress)
    {
        if(!TopicFileStart)
        {
            TopicFileStart=ftell(HelpFile);
            NextTopic=12L;
            BlockNum=-1L;
        }
        NewBlockNum=TopicAddress/DecompressSize;
        if(BlockNum!=NewBlockNum)
        {
            if(NewBlockNum*TopicBlockSize>=TopicFileLength) return 0;
            BlockNum=NewBlockNum;
            CurrentTopicOffset=BlockNum*0x8000L;
            dontCount=TRUE;
            fseek(HelpFile,TopicFileStart+TopicBlockSize*NewBlockNum,SEEK_SET);
            BytesToRead=TopicBlockSize;
            if(TopicFileLength-TopicBlockSize*NewBlockNum<BytesToRead)
            {
                BytesToRead=(unsigned int)(TopicFileLength-TopicBlockSize*NewBlockNum);
            }
            myFRead(TopicBuffer,sizeof(TOPICBLOCKHEADER),HelpFile);
            BytesToRead-=sizeof(TOPICBLOCKHEADER);
            if(lzcompressed)
            {
                f=CreateMap(TopicBuffer+sizeof(TOPICBLOCKHEADER),sizeof(TopicBuffer)-sizeof(TOPICBLOCKHEADER));
                DecompSize=decompress(2,(MFILE *)HelpFile,BytesToRead,f);
                CloseMap(f);
            }
            else
            {
                DecompSize=myFRead(TopicBuffer+sizeof(TOPICBLOCKHEADER),BytesToRead,HelpFile);
            }
            DecompSize+=sizeof(TOPICBLOCKHEADER);
        }
        offset=(unsigned int)(TopicAddress%DecompressSize);
        if(offset>=DecompSize) return 0L;
        TopicLink=(TOPICLINK *)(TopicBuffer+offset);
        if(before31)
        {
            NextTopic=TopicLink->NextBlock+TopicAddress;
        }
        else
        {
            NextTopic=TopicLink->NextBlock;
        }
        BytesInBlock=TopicLink->BlockSize;
    }
    here=BlockNum*DecompressSize+offset;
    for(BytesRead=0;BytesRead<NumBytes;BytesRead++)
    {
        if(BytesInBlock<=0)
        {
            return TopicRead(HelpFile,NextTopic,Dest,NumBytes-BytesRead)+BytesRead;
        }
        if(offset>=DecompSize)
        {
            NewBlockNum=BlockNum+1;
            if(NewBlockNum*TopicBlockSize>=TopicFileLength) break;
            fseek(HelpFile,TopicFileStart+TopicBlockSize*NewBlockNum,SEEK_SET);
            BlockNum=NewBlockNum;
            CurrentTopicOffset=BlockNum*0x8000L;
            dontCount=TRUE;
            BytesToRead=TopicBlockSize;
            if(TopicFileLength-TopicBlockSize*NewBlockNum<BytesToRead)
            {
                BytesToRead=(unsigned int)(TopicFileLength-TopicBlockSize*NewBlockNum);
            }
            myFRead(TopicBuffer,sizeof(TOPICBLOCKHEADER),HelpFile);
            BytesToRead-=sizeof(TOPICBLOCKHEADER);
            if(lzcompressed)
            {
                f=CreateMap(TopicBuffer+sizeof(TOPICBLOCKHEADER),sizeof(TopicBuffer)-sizeof(TOPICBLOCKHEADER));
                DecompSize=decompress(2,(MFILE *)HelpFile,BytesToRead,f);
                CloseMap(f);
            }
            else
            {
                DecompSize=myFRead(TopicBuffer+sizeof(TOPICBLOCKHEADER),BytesToRead,HelpFile);
            }
            DecompSize+=sizeof(TOPICBLOCKHEADER);
            offset=sizeof(TOPICBLOCKHEADER);
        }
        *Dest++=TopicBuffer[offset++];
        BytesInBlock--;
    }
    CurrentTopicPos=here;
    return BytesRead;
}

/**************************************************
   Phrase replacement of a string from topic record.
   Expands to out, returns end of expanded string.
   Expands to stdout if out==NULL, returns NULL then.
****************************************************/
char *StringPrint(unsigned char *String,long Length,char *out)
{
    int CurChar;

    if(NewPhrases)
    {
        while(Length)
        {
            CurChar=*String++;
            Length--;
            if((CurChar&1)==0) /* phrases 0..127 */
            {
                out=PrintPhrase(CurChar/2,out,NULL);
            }
            else if((CurChar&3)==1) /* phrases 128..16511 */
            {
                CurChar=128+(CurChar/4)*256+*String++;
                Length--;
                out=PrintPhrase(CurChar,out,NULL);
            }
            else if((CurChar&7)==3) /* copy next n characters */
            {
                while(CurChar>0)
                {
                    if(out)
                    {
                        *out++=*String++;
                    }
                    else if(isprint((unsigned char)*String))
                    {
                        putchar(*String++);
                    }
                    else
                    {
                        printf("(%02x)",*String++);
                    }
                    Length--;
                    CurChar-=8;
                }
            }
            else if((CurChar&0x0F)==0x07)
            {
                while(CurChar>0)
                {
                    if(out)
                    {
                        *out++=' ';
                    }
                    else
                    {
                        putchar(' ');
                    }
                    CurChar-=16;
                }
            }
            else /* if((CurChar&0x0F)==0x0F) */
            {
                while(CurChar>0)
                {
                    if(out)
                    {
                        *out++='\0';
                    }
                    else
                    {
                        printf("(00)");
                    }
                    CurChar-=16;
                }
            }
        }
    }
    else
    {
        while(Length)
        {
            CurChar=*String++;
            Length--;
            if(CurChar>0&&CurChar<16) /* phrase 0..1919 */
            {
                CurChar=256*(CurChar-1)+*String++;
                Length--;
                out=PrintPhrase(CurChar/2,out,NULL);
                if(CurChar&1)
                {
                    if(out)
                    {
                        *out++=' ';
                    }
                    else
                    {
                        putchar(' ');
                    }
                }
            }
            else if(out)
            {
                *out++=CurChar;
            }
            else if(isprint((unsigned char)CurChar))
            {
                putchar(CurChar);
            }
            else
            {
                printf("(%02x)",CurChar);
            }
        }
    }
    if(out) *out='\0';
    return out;
}

void putrtf(FILE *rtf,char *str)
{
    if(rtf) while(*str)
    {
        if(*str=='{'||*str=='}'||*str=='\\')
        {
            putc('\\',rtf);
            putc(*str++,rtf);
        }
        else if(isprint((unsigned char)*str))
        {
            putc(*str++,rtf);
        }
        else
        {
            fprintf(rtf,"\\'%02x",(unsigned char)*str++);
        }
    }
}

int KeywordRecCmp(const void *a,const void *b)
{
    const KEYWORDREC *A;
    const KEYWORDREC *B;

    A=(const KEYWORDREC *)a;
    B=(const KEYWORDREC *)b;
    if(A->TopicOffset<B->TopicOffset) return -1;
    if(A->TopicOffset>B->TopicOffset) return 1;
    return 0;
}

long NextTopicOffset(FILE *HelpFile,long topic)
{
    long pos;
    char Title[256];
    int n,i;
    long TopicOffset;
    BUFFER buf;

    pos=ftell(HelpFile);
    if(SearchFile(HelpFile,"|TTLBTREE",NULL))
    {
        for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
        {
            for(i=0;i<n;i++)
            {
                myFRead(&TopicOffset,sizeof(TopicOffset),HelpFile);
                if(TopicOffset>topic)
                {
                    fseek(HelpFile,pos,SEEK_SET);
                    return TopicOffset;
                }
                myGetS(Title,sizeof(Title),HelpFile);
            }
        }
    }
    fseek(HelpFile,pos,SEEK_SET);
    return 0x7FFFFFFFL;
}

void Annotate(long pos,FILE *rtf)
{
    long FileLength;
    char FileName[19];
    int i;
    long l;

    sprintf(FileName,"%ld!0",pos);
    if(SearchFile(AnnoFile,FileName,&FileLength))
    {
        fprintf(rtf,"{\\v {\\*\\atnid ANN}\\chatn {\\*\\annotation \\pard\\plain {\\chatn }");
        for(l=0;l<FileLength&&(i=getc(AnnoFile))!=-1;l++)
        {
            if(i==0x0D)
            {
                fprintf(rtf,"\\par\n");
            }
            else if(i!='{'&&i!='}'&&i!='\\'&&isprint(i))
            {
                putc(i,rtf);
            }
            else if(i=='{')
            {
                fprintf(rtf,"\\{\\-");
            }
            else if(i!='\0'&&i!=0x0A)
            {
                fprintf(rtf,"\\'%02x",i);
            }
        }
        fprintf(rtf,"}}");
    }
}

void CollectKeywords(FILE *HelpFile,long from,long upto)
{
    unsigned short j,m;
    int i,n,k,map;
    long FileLength,savepos,KWDataOffset;
    char Keyword[512];  /* variable length keyword */
    long *keytopic;
    BUFFER buf;
    char kwdata[10];
    char kwbtree[10];

    if(KeywordRecs&&KeywordRec) /* free old keywords */
    {
        for(i=0;i<KeywordRecs;i++)
        {
            if(KeywordRec[i].Keyword) free(KeywordRec[i].Keyword);
        }
        free(KeywordRec);
        KeywordRec=NULL;
        NextKeywordRec=KeywordRecs=0;
    }
    savepos=ftell(HelpFile);
    for(k=0;k<2;k++) for(map='0';map<='z';map++)
    {
        if(k)
        {
            if(!keyindex[map-'0']) continue;
            sprintf(kwdata,"|%cKWDATA",map);
            sprintf(kwbtree,"|%cKWBTREE",map);
        }
        else
        {
            if(!lists[map-'0']) continue;
            sprintf(kwdata,"|%cWDATA",map);
            sprintf(kwbtree,"|%cWBTREE",map);
        }
        if(SearchFile(HelpFile,kwdata,&FileLength))
        {
            keytopic=myMalloc(FileLength);
            myFRead(keytopic,FileLength,HelpFile);
            if(SearchFile(HelpFile,kwbtree,NULL))
            {
                for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
                {
                    for(i=0;i<n;i++)
                    {
                       myGetS(Keyword,sizeof(Keyword),HelpFile);
                       myFRead(&m,sizeof(m),HelpFile);
                       myFRead(&KWDataOffset,sizeof(KWDataOffset),HelpFile);
                       for(j=0;j<m;j++)
                       {
                           if(keytopic[KWDataOffset/4+j]>=from&&keytopic[KWDataOffset/4+j]<upto)
                           {
                               if(KeywordRecs%100==0) KeywordRec=myReAlloc(KeywordRec,(KeywordRecs+100)*sizeof(KEYWORDREC));
                               KeywordRec[KeywordRecs].KeyIndex=k>0;
                               KeywordRec[KeywordRecs].Footnote=map;
                               KeywordRec[KeywordRecs].Keyword=myStrDup(Keyword);
                               KeywordRec[KeywordRecs].TopicOffset=keytopic[KWDataOffset/4+j];
                               KeywordRecs++;
                           }
                       }
                    }
                }
                free(keytopic);
            }
        }
        if(KeywordRec) qsort(KeywordRec,KeywordRecs,sizeof(KEYWORDREC),KeywordRecCmp);
    }
    fseek(HelpFile,savepos,SEEK_SET);
}

void ListKeywords(FILE *HelpFile,FILE *rtf,long topic)
{
    unsigned short j,m;
    int i,k,len,map,n;
    long FileLength,savepos,KWDataOffset;
    char Keyword[512];  /* variable length keyword */
    long *keytopic;
    BUFFER buf;
    char kwdata[10];
    char kwbtree[10];

    savepos=ftell(HelpFile);
    for(k=0;k<2;k++) for(map='0';map<='z';map++)
    {
        if(k)
        {
            if(!keyindex[map-'0']) continue;
            sprintf(kwdata,"|%cKWDATA",map);
            sprintf(kwbtree,"|%cKWBTREE",map);
        }
        else
        {
            if(!lists[map-'0']) continue;
            sprintf(kwdata,"|%cWDATA",map);
            sprintf(kwbtree,"|%cWBTREE",map);
        }
        if(SearchFile(HelpFile,kwdata,&FileLength))
        {
            len=0;
            keytopic=myMalloc(FileLength);
            myFRead(keytopic,FileLength,HelpFile);
            if(SearchFile(HelpFile,kwbtree,NULL))
            {
                for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
                {
                    for(i=0;i<n;i++)
                    {
                       myGetS(Keyword,sizeof(Keyword),HelpFile);
                       myFRead(&m,sizeof(m),HelpFile);
                       myFRead(&KWDataOffset,sizeof(KWDataOffset),HelpFile);
                       for(j=0;j<m;j++)
                       {
                           if(keytopic[KWDataOffset/4+j]==topic)
                           {
                               if(len+strlen(Keyword)>1000)
                               {
                                   fprintf(rtf,"}\n");
                                   len=0;
                               }
                               if(len==0)
                               {
                                   if(k)
                                   {
                                       fprintf(rtf,"K{\\footnote K %c:",map);
                                   }
                                   else
                                   {
                                       fprintf(rtf,"%c{\\footnote %c ",map,map);
                                   }
                               }
                               else
                               {
                                   putc(';',rtf);
                                   len++;
                               }
                               len+=strlen(Keyword);
                               putrtf(rtf,Keyword);
                           }
                       }
                    }
                }
                if(len) fprintf(rtf,"}\n");
                free(keytopic);
            }
        }
    }
    fseek(HelpFile,savepos,SEEK_SET);
}

void ListWindows(FILE *HelpFile,FILE *rtf,long topic)
{
    long savepos;
    static int n,i;
    static BUFFER buf;
    static int VIOLAfound=-1;
    static VIOLAREC *Viola;

    if(VIOLAfound==0) return;
    savepos=ftell(HelpFile);
    if(VIOLAfound==-1)
    {
        VIOLAfound=0;
        if(SearchFile(HelpFile,"|VIOLA",NULL))
        {
            n=GetFirstPage(HelpFile,&buf,NULL);
            if(n)
            {
                Viola=myMalloc(n*sizeof(VIOLAREC));
                myFRead(Viola,n*sizeof(VIOLAREC),HelpFile);
                i=0;
                VIOLAfound=1;
            }
        }
    }
    if(VIOLAfound==1)
    {
        while(i>=n||topic>Viola[i].TopicOffset)
        {
            if(i>=n)
            {
                free(Viola);
                n=GetNextPage(HelpFile,&buf);
                if(n==0)
                {
                    VIOLAfound=0;
                    break;
                }
                Viola=myMalloc(n*sizeof(VIOLAREC));
                myFRead(Viola,n*sizeof(VIOLAREC),HelpFile);
                i=0;
            }
            else
            {
                i++;
            }
        }
        if(i<n&&Viola[i].TopicOffset==topic)
        {
            fprintf(rtf,">{\\footnote > %s}\n",WindowName(Viola[i].WindowNumber));
        }
    }
    fseek(HelpFile,savepos,SEEK_SET);
}

void AddStart(long StartTopic,int BrowseNum,int Count)
{
    start=myReAlloc(start,(starts+1)*sizeof(START));
    start[starts].StartTopic=StartTopic;
    start[starts].BrowseNum=BrowseNum;
    start[starts].Start=Count;
    starts++;
}

void FixStart(int BrowseNum,int NewBrowseNum,int AddCount)
{
    int i;

    for(i=0;i<starts;i++) if(start[i].BrowseNum==BrowseNum)
    {
        start[i].BrowseNum=NewBrowseNum;
        start[i].Start+=AddCount;
    }
}

void AddBrowse(long StartTopic,long NextTopic,long PrevTopic)
{
    int i;

    for(i=0;i<browses;i++) if(browse[i].StartTopic==-1L) break; /* empty space in array ? */
    if(i==browses) /* no empty space, add to array */
    {
        browse=myReAlloc(browse,++browses*sizeof(BROWSE));
    }
    browse[i].StartTopic=StartTopic;
    browse[i].NextTopic=NextTopic;
    browse[i].PrevTopic=PrevTopic;
    browse[i].BrowseNum=browsenums++;
    browse[i].Start=1;
    browse[i].Count=1;
}

void MergeBrowse(long TopicOffset,long OtherTopicOffset,long NextTopic,long PrevTopic)
{
    int i,j;

    for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
    {
        if(browse[i].NextTopic==TopicOffset||browse[i].NextTopic==OtherTopicOffset) break;
    }
    for(j=0;j<browses;j++) if(browse[j].StartTopic!=-1L)
    {
        if(browse[j].PrevTopic==TopicOffset||browse[j].PrevTopic==OtherTopicOffset) break;
    }
    if(i<browses&&j<browses)
    {
        browse[i].Count++;
        browse[i].NextTopic=browse[j].NextTopic;
        FixStart(browse[j].BrowseNum,browse[i].BrowseNum,browse[i].Count);
        browse[j].Start+=browse[i].Count;
        AddStart(browse[j].StartTopic,browse[i].BrowseNum,browse[j].Start);
        browse[i].Count+=browse[j].Count;
        browse[j].StartTopic=-1L;
        if(browse[i].NextTopic==-1L&&browse[i].PrevTopic==-1L)
        {
            AddStart(browse[i].StartTopic,browse[i].BrowseNum,browse[i].Start);
            browse[i].StartTopic=-1L;
        }
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Can not merge %08lx %08lx %08lx\n",TopicOffset,NextTopic,PrevTopic);
    }
}

void LinkBrowse(long TopicOffset,long OtherTopicOffset,long NextTopic,long PrevTopic)
{
    int i;

    for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
    {
        if(browse[i].NextTopic==TopicOffset||browse[i].NextTopic==OtherTopicOffset) break;
    }
    if(i<browses)
    {
        browse[i].NextTopic=NextTopic;
        browse[i].Count++;
        if(browse[i].NextTopic==-1L&&browse[i].PrevTopic==-1L)
        {
            AddStart(browse[i].StartTopic,browse[i].BrowseNum,browse[i].Start);
            browse[i].StartTopic=-1L;
        }
    }
    else
    {
        warnings=TRUE;
        if(warn)
        {
            fprintf(stderr,"Can not link %08lx %08lx %08lx\n",TopicOffset,NextTopic,PrevTopic);
            for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
            {
                fprintf(stderr,"Open %08lx %08lx\n",browse[i].PrevTopic,browse[i].NextTopic);
            }
        }
    }
}

void BackLinkBrowse(long TopicOffset,long OtherTopicOffset,long NextTopic,long PrevTopic)
{
    int i;

    for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
    {
        if(browse[i].PrevTopic==TopicOffset||browse[i].PrevTopic==OtherTopicOffset) break;
    }
    if(i<browses)
    {
        browse[i].PrevTopic=PrevTopic;
        browse[i].Count++;
        browse[i].Start++;
        FixStart(browse[i].BrowseNum,browse[i].BrowseNum,1);
        if(browse[i].NextTopic==-1L&&browse[i].PrevTopic==-1L)
        {
            AddStart(browse[i].StartTopic,browse[i].BrowseNum,browse[i].Start);
            browse[i].StartTopic=-1L;
        }
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Can not backlink %08lx %08lx %08lx\n",TopicOffset,NextTopic,PrevTopic);
    }
}

unsigned long AddLink(long StartTopic,long NextTopic,long PrevTopic)
{
    int i,j;
    unsigned long result;

    result=0L;
    for(i=0;i<browses;i++) if(browse[i].StartTopic==-1L) break;
    if(i==browses) browse=myReAlloc(browse,++browses*sizeof(BROWSE));
    for(j=0;j<starts;j++) if(start[j].StartTopic==StartTopic) break;
    if(j<starts)
    {
        browse[i].StartTopic=start[j].StartTopic;
        browse[i].BrowseNum=start[j].BrowseNum;
        browse[i].Start=start[j].Start;
        browse[i].Count=start[j].Start;
        browse[i].NextTopic=NextTopic;
        browse[i].PrevTopic=PrevTopic;
        result=browse[i].BrowseNum+((long)browse[i].Start<<16);
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Browse start %08lx not found\n",StartTopic);
    }
    return result;
}

unsigned long MergeLink(long TopicOffset,long OtherTopicOffset,long NextTopic,long PrevTopic)
{
    int i,j;
    unsigned long result;

    result=0L;
    for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
    {
        if(browse[i].NextTopic==TopicOffset||browse[i].NextTopic==OtherTopicOffset) break;
    }
    for(j=0;j<browses;j++) if(browse[j].StartTopic!=-1L)
    {
        if(browse[j].PrevTopic==TopicOffset||browse[j].PrevTopic==OtherTopicOffset) break;
    }
    if(i<browses&&j<browses)
    {
        browse[i].Count++;
        browse[j].Start--;
        if(browse[i].Count!=browse[j].Start)
        {
            warnings=TRUE;
            if(warn) fprintf(stderr,"Prev browse end %d doen't match next browse start %d\n",browse[i].Count,browse[j].Start);
        }
        result=browse[i].BrowseNum+((long)browse[i].Count<<16);
        browse[i].NextTopic=browse[j].NextTopic;
        browse[i].Count=browse[j].Count;
        browse[j].StartTopic=-1L;
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Can not merge %08lx %08lx %08lx\n",TopicOffset,NextTopic,PrevTopic);
    }
    return result;
}

unsigned long LinkLink(long TopicOffset,long OtherTopicOffset,long NextTopic,long PrevTopic)
{
    int i;
    unsigned long result;

    result=0L;
    for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
    {
        if(browse[i].NextTopic==TopicOffset||browse[i].NextTopic==OtherTopicOffset) break;
    }
    if(i<browses)
    {
        browse[i].NextTopic=NextTopic;
        browse[i].Count++;
        result=browse[i].BrowseNum+((long)browse[i].Count<<16);
        if(browse[i].NextTopic==-1L&&browse[i].PrevTopic==-1L)
        {
            browse[i].StartTopic=-1L;
        }
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Can not link %08lx %08lx %08lx\n",TopicOffset,NextTopic,PrevTopic);
    }
    return result;
}

unsigned long BackLinkLink(long TopicOffset,long OtherTopicOffset,long NextTopic,long PrevTopic)
{
    int i;
    unsigned long result;

    result=0L;
    for(i=0;i<browses;i++) if(browse[i].StartTopic!=-1L)
    {
        if(browse[i].PrevTopic==TopicOffset||browse[i].PrevTopic==OtherTopicOffset) break;
    }
    if(i<browses)
    {
        browse[i].PrevTopic=PrevTopic;
        browse[i].Start--;
        result=browse[i].BrowseNum+((long)browse[i].Start<<16);
        if(browse[i].NextTopic==-1L&&browse[i].PrevTopic==-1L)
        {
            browse[i].StartTopic=-1L;
        }
    }
    else
    {
        warnings=TRUE;
        if(warn) fprintf(stderr,"Can not backlink %08lx %08lx %08lx\n",TopicOffset,NextTopic,PrevTopic);
    }
    return result;
}

char *scanint(char *ptr,short *val)
{
    if(*ptr&1)
    {
        *val=(*(unsigned short *)(ptr)>>1)-0x4000;
        ptr+=2;
    }
    else
    {
        *val=(*(unsigned char *)(ptr)>>1)-0x40;
        ptr++;
    }
    return ptr;
}

char *scanword(char *ptr,unsigned short *val)
{
    if(*ptr&1)
    {
        *val=*(unsigned short *)(ptr)>>1;
        ptr+=2;
    }
    else
    {
        *val=*(unsigned char *)(ptr)>>1;
        ptr++;
    }
    return ptr;
}

char *scanlong(char *ptr,long *val)
{
    if(*(short *)ptr&1)
    {
        *val=(*(unsigned long *)(ptr)>>1)-0x40000000L;
        ptr+=4;
    }
    else
    {
        *val=(*(unsigned short *)(ptr)>>1)-0x4000;
        ptr+=2;
    }
    return ptr;
}

char *scandword(char *ptr,unsigned long *val)
{
    if(*(short *)ptr&1)
    {
        *val=*(unsigned long *)(ptr)>>1;
        ptr+=2;
    }
    else
    {
        *val=*(unsigned short *)(ptr)>>1;
        ptr+=2;
    }
    return ptr;
}

void ChangeFont(FILE *rtf,unsigned int i,BOOL ul,BOOL uldb)
{
    if(i<fonts)
    {
        if(font[i].style)
        {
            fprintf(rtf,"}{\\cs%d",font[i].style+9);
            if(ul) fprintf(rtf,"\\ul");
            if(uldb) fprintf(rtf,"\\uldb");
        }
        else
        {
            fprintf(rtf,"}{\\f%d",font[i].FontName);
            if(font[i].Attributes&FONT_ITAL) fprintf(rtf,"\\i");
            if(font[i].Attributes&FONT_BOLD) fprintf(rtf,"\\b");
            if(ul||(font[i].Attributes&FONT_UNDR)) fprintf(rtf,"\\ul");
            if(font[i].Attributes&FONT_STRK) fprintf(rtf,"\\strike");
            if(uldb||(font[i].Attributes&FONT_DBUN)) fprintf(rtf,"\\uldb");
            if(font[i].Attributes&FONT_SMCP) fprintf(rtf,"\\scaps");
            if(font[i].expndtw) fprintf(rtf,"\\expndtw%d",font[i].expndtw);
            if(font[i].up>0) fprintf(rtf,"\\up%d",font[i].up);
            else if(font[i].up<0) fprintf(rtf,"\\dn%d",-font[i].up);
            fprintf(rtf,"\\fs%d",font[i].HalfPoints);
            fprintf(rtf,"\\cf%d",font[i].FGRGB[0]);
        }
        putc(' ',rtf);
    }
}

void ListGroups(FILE *rtf,long topic,unsigned long browse)
{
    int i;
    BOOL grouplisted;

    grouplisted=FALSE;
    for(i=0;i<groups;i++)
    {
        if(topic>=group[i].GroupHeader.FirstTopic&&topic<=group[i].GroupHeader.LastTopic&&(group[i].GroupHeader.GroupType==1||group[i].GroupHeader.GroupType==2&&(group[i].Bitmap[topic>>3]&(1<<(topic&7)))))
        {
            if(!grouplisted)
            {
                fprintf(rtf,"{+{\\footnote + ");
                if(browse) fprintf(rtf,"BROWSE%04x:%04x",(unsigned short)browse,(unsigned short)(browse>>16));
                grouplisted=TRUE;
            }
            fprintf(rtf,";%s",group[i].Name);
        }
    }
    if(grouplisted)
    {
        fprintf(rtf,"}}\n");
    }
    else if(browse)
    {
        fprintf(rtf,"{+{\\footnote + BROWSE%04x:%04x}}\n",(unsigned short)browse,(unsigned short)(browse>>16));
    }
}

void TopicDump(FILE *HelpFile,FILE *rtf,BOOL doc)
{
    TOPICLINK TopicLink;
    TOPICLINK NextTopicLink;
    char *LinkData1;  /* Data associated with this link */
    long nonscroll=-1L;
    char *LinkData2;  /* Second set of data */
    char *end;
    int fontset;
    int NextContextRec;
    unsigned long BrowseNum;
    int BytesRead;
    long ActualTopicOffset;
    long MaxTopicOffset;
    char *hotspot;
    char *arg;
    long pos;
    BOOL firsttopic=TRUE;
    BOOL ul,uldb;
    int nextbitmap;
    long TopicNum;

#ifdef _WIN32 /* more efficient */
    CollectKeywords(HelpFile,0L,0x7FFFFFFFL);
#endif
    if(SearchFile(HelpFile,"|TOPIC",&TopicFileLength))
    {
        dontCount=FALSE;
        fontset=-1;
        nextbitmap=1;
        if(browse) free(browse);
        browse=NULL;
        browses=0;
        NextContextRec=0;
        TopicNum=16;
        ul=uldb=FALSE;
        hotspot=NULL;
        MaxTopicOffset=0L;
        BytesRead=(int)TopicRead(HelpFile,12L,&TopicLink,sizeof(TopicLink));
        while(BytesRead==sizeof(TOPICLINK))
        {
            pos=CurrentTopicPos;
            ActualTopicOffset=CurrentTopicOffset;
            if(TopicLink.DataLen1>sizeof(TOPICLINK))
            {
                LinkData1=myMalloc(TopicLink.DataLen1-sizeof(TOPICLINK)+1);
                TopicRead(HelpFile,0L,LinkData1,TopicLink.DataLen1-sizeof(TOPICLINK));
            }
            else
            {
                LinkData1=NULL;
            }
            if(TopicLink.DataLen1<TopicLink.BlockSize) /* read LinkData2 without phrase replacement */
            {
                LinkData2=myMalloc(TopicLink.BlockSize-TopicLink.DataLen1+1);
                TopicRead(HelpFile,0L,LinkData2,TopicLink.BlockSize-TopicLink.DataLen1);
            }
            else
            {
                LinkData2=NULL;
            }
            BytesRead=(int)TopicRead(HelpFile,0L,&NextTopicLink,sizeof(NextTopicLink));
            if(LinkData1&&TopicLink.RecordType==TL_TOPICHDR) /* display a Topic Header record */
            {
                if(!firsttopic) fprintf(rtf,"\\page\n");
                firsttopic=FALSE;
                fprintf(stderr,"Topic %ld\r",TopicNum-15);
                if(!doc)
                {
                    BrowseNum=0L;
                    if(before31)
                    {
                        TOPICHEADER30 *TopicHdr;

                        TopicHdr=(TOPICHEADER30 *)LinkData1;
                        fprintf(rtf,"{#{\\footnote # TOPIC%ld}}\n",TopicNum);
                        if(resolvebrowse)
                        {
                            if(TopicHdr->NextTopicNum>TopicNum&&TopicHdr->PrevTopicNum>TopicNum
                            || TopicHdr->NextTopicNum==-1&&TopicHdr->PrevTopicNum>TopicNum
                            || TopicHdr->NextTopicNum>TopicNum&&TopicHdr->PrevTopicNum==-1)
                            {
                                BrowseNum=AddLink(TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                            }
                            else if(TopicHdr->NextTopicNum!=-1&&TopicHdr->NextTopicNum<TopicNum&&TopicHdr->PrevTopicNum!=-1&&TopicHdr->PrevTopicNum<TopicNum)
                            {
                                BrowseNum=MergeLink(TopicNum,TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                            }
                            else if(TopicHdr->NextTopicNum!=-1&&TopicHdr->NextTopicNum<TopicNum&&(TopicHdr->PrevTopicNum==-1||TopicHdr->PrevTopicNum>TopicNum))
                            {
                                BrowseNum=BackLinkLink(TopicNum,TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                            }
                            else if(TopicHdr->PrevTopicNum!=-1&&TopicHdr->PrevTopicNum<TopicNum&&(TopicHdr->NextTopicNum==-1||TopicHdr->NextTopicNum>TopicNum))
                            {
                                BrowseNum=LinkLink(TopicNum,TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                            }
                        }
                        ListKeywords(HelpFile,rtf,pos);
                    }
                    else
                    {
                        TOPICHEADER *TopicHdr;

                        TopicHdr=(TOPICHEADER *)LinkData1;
                        if(TopicHdr->Scroll!=-1L)
                        {
                            nonscroll=TopicHdr->Scroll;
                        }
                        else
                        {
                            nonscroll=TopicHdr->NextTopic;
                        }
                        while(NextContextRec<ContextRecs&&ContextRec[NextContextRec].TopicOffset<=CurrentTopicOffset)
                        {
                            fprintf(rtf,"{#{\\footnote # %s}}\n",unhash(ContextRec[NextContextRec].HashValue));
                            while(NextContextRec<ContextRecs&&ContextRec[NextContextRec].TopicOffset==ContextRec[NextContextRec+1].TopicOffset)
                            {
                                NextContextRec++;
                            }
                            NextContextRec++;
                        }
                        if(resolvebrowse)
                        {
                            if(TopicHdr->BrowseFor>CurrentTopicOffset&&TopicHdr->BrowseBck>CurrentTopicOffset
                            || TopicHdr->BrowseFor==-1L&&TopicHdr->BrowseBck>CurrentTopicOffset
                            || TopicHdr->BrowseFor>CurrentTopicOffset&&TopicHdr->BrowseBck==-1L)
                            {
                                BrowseNum=AddLink(CurrentTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                            }
                            else if(TopicHdr->BrowseFor!=-1L&&TopicHdr->BrowseFor<CurrentTopicOffset&&TopicHdr->BrowseBck!=-1L&&TopicHdr->BrowseBck<CurrentTopicOffset)
                            {
                                BrowseNum=MergeLink(CurrentTopicOffset,ActualTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                            }
                            else if(TopicHdr->BrowseFor!=-1L&&TopicHdr->BrowseFor<CurrentTopicOffset&&(TopicHdr->BrowseBck==-1L||TopicHdr->BrowseBck>CurrentTopicOffset))
                            {
                                BrowseNum=BackLinkLink(CurrentTopicOffset,ActualTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                            }
                            else if(TopicHdr->BrowseBck!=-1L&&TopicHdr->BrowseBck<CurrentTopicOffset&&(TopicHdr->BrowseFor==-1L||TopicHdr->BrowseFor>CurrentTopicOffset))
                            {
                                BrowseNum=LinkLink(CurrentTopicOffset,ActualTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                            }
                        }
#ifndef _WIN32
                        CollectKeywords(HelpFile,MaxTopicOffset,NextTopicOffset(HelpFile,CurrentTopicOffset));
#endif
                        ActualTopicOffset=CurrentTopicOffset;
                    }
                    ListGroups(rtf,TopicNum-16,BrowseNum);
                    if(LinkData2&&TopicLink.DataLen2>0)
                    {
                        char *q;
                        unsigned i;

                        if(TopicLink.DataLen2<=TopicLink.BlockSize-TopicLink.DataLen1)
                        {
                            end=LinkData2+TopicLink.DataLen2;
                        }
                        else
                        {
                            q=myMalloc(TopicLink.DataLen2+1);
                            end=StringPrint(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1,q);
                            free(LinkData2);
                            LinkData2=q;
                            if(end>LinkData2+TopicLink.DataLen2)
                            {
                                error("Phrase replacement delivers %u instead of %ld bytes\n",(unsigned int)(end-LinkData2),TopicLink.DataLen2);
                            }
                            while(end<LinkData2+TopicLink.DataLen2) *end++='\0';
                        }
                        *end='\0';
                        fprintf(rtf,"${\\footnote $ ");
                        putrtf(rtf,LinkData2);
                        fprintf(rtf,"}\n");
                        for(i=strlen(LinkData2)+1;i<TopicLink.DataLen2;i+=strlen(LinkData2+i)+1)
                        {
                            fprintf(rtf,"!{\\footnote ! ");
                            putrtf(rtf,LinkData2+i);
                            fprintf(rtf,"}\n");
                        }
                    }
                    ListWindows(HelpFile,rtf,ActualTopicOffset);
                }
                TopicNum++;
            }
            else if(LinkData1&&LinkData2&&TopicLink.RecordType==TL_DISPLAY30||TopicLink.RecordType==TL_DISPLAY||TopicLink.RecordType==TL_TABLE)
            {
                int col,cols,lastcol;
                short *iptr;
                unsigned short x1,x2,x3,x4;
                short y1;
                long l1;
                char *ptr;
                char *cmd;
                char *end;
                char *q;
                unsigned int bits;

                if(AnnoFile) Annotate(pos,rtf);
                ptr=scanlong(LinkData1,&l1);
                if(TopicLink.RecordType==TL_DISPLAY||TopicLink.RecordType==TL_TABLE)
                {
                    ptr=scanword(ptr,&x3);
                    if(!dontCount) CurrentTopicOffset+=x3;
                    MaxTopicOffset=ActualTopicOffset+x3;
                }
                if(TopicLink.RecordType==TL_TABLE)
                {
                    fprintf(rtf,"\\trowd ");
                    cols=(unsigned char)*ptr++;
                    x4=(unsigned char)*ptr++;
                    switch(x4)
                    {
                    case 0:
                    case 2:
                        l1=*(short *)ptr; /* min table width */
                        ptr+=2;
                        fprintf(rtf,"\\trqc");
                        break;
                    case 1:
                        l1=32767L;
                        break;
                    case 3:
                        l1=3276L; /* scaling is 1 instead of 10 */
                        break;
                    default:
                        error("\nunknown column data modifier %02x found\n",x4);
                    }
                    iptr=(short *)ptr;
                    if(cols>1)
                    {
                        x1=iptr[0]+iptr[1]+iptr[3]/2;
                        fprintf(rtf,"\\trgaph%ld\\trleft%ld \\cellx%ld\\cellx%ld",(iptr[3]*l1)/3276,((iptr[1]-iptr[3])*l1-32767)/3276,(x1*l1)/3276,((x1+iptr[2]+iptr[3])*l1)/3276);
                        x1+=iptr[2]+iptr[3];
                        for(col=2;col<cols;col++)
                        {
                            x1+=iptr[2*col]+iptr[2*col+1];
                            fprintf(rtf,"\\cellx%ld",(x1*l1)/3276);
                        }
                    }
                    else
                    {
                        fprintf(rtf,"\\trleft%ld \\cellx%ld ",(iptr[1]*l1-32767)/3276,(iptr[0]*l1)/3276);
                    }
                    ptr=(char *)(iptr+2*cols);
                }
                /* do phrase replacement of LinkData2 */
                if(TopicLink.DataLen2<=TopicLink.BlockSize-TopicLink.DataLen1)
                {
                    end=LinkData2+TopicLink.DataLen2;
                    q=LinkData2;
                }
                else
                {
                    q=myMalloc(TopicLink.DataLen2+1);
                    end=StringPrint(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1,q);
                    if(end>q+TopicLink.DataLen2)
                    {
                        error("phrase replacement delivers %u instead of %ld bytes\n",(unsigned int)(end-q),TopicLink.DataLen2);
                        HexDumpMemory(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1);
                        StringPrint(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1,NULL);
                        exit(1);
                    }
                    while(end<q+TopicLink.DataLen2) *end++='\0';
                    free(LinkData2);
                    LinkData2=q;
                }
                *end='\0';
                lastcol=-1;
                for(col=0;(TopicLink.RecordType==TL_TABLE?*(short *)ptr!=-1:col==0)&&ptr<LinkData1+TopicLink.DataLen1-sizeof(TOPICLINK);col++)
                {
                    fprintf(rtf,"\\pard ");
                    if(pos<nonscroll) fprintf(rtf,"\\keepn ");
                    if(TopicLink.RecordType==TL_TABLE)
                    {
                        fprintf(rtf,"\\intbl ");
                        lastcol=*(short *)ptr;
                        ptr+=5;
                    }
                    ptr+=4;
                    bits=*(unsigned short *)ptr;
                    ptr+=2;
                    if(bits&0x1000) fprintf(rtf,"\\keep ");
                    if(bits&0x0400) fprintf(rtf,"\\qr ");
                    if(bits&0x0800) fprintf(rtf,"\\qc ");
                    if(bits&0x0001)
                    {
                        ptr=scanlong(ptr,&l1);
                    }
                    if(bits&0x0002)
                    {
                        ptr=scanint(ptr,&y1);
                        fprintf(rtf,"\\sb%d ",y1*scaling);
                    }
                    if(bits&0x0004)
                    {
                        ptr=scanint(ptr,&y1);
                        fprintf(rtf,"\\sa%d ",y1*scaling);
                    }
                    if(bits&0x0008)
                    {
                        ptr=scanint(ptr,&y1);
                        fprintf(rtf,"\\sl%d ",y1*scaling);
                    }
                    if(bits&0x0010)
                    {
                        ptr=scanint(ptr,&y1);
                        fprintf(rtf,"\\li%d ",y1*scaling);
                    }
                    if(bits&0x0020)
                    {
                        ptr=scanint(ptr,&y1);
                        fprintf(rtf,"\\ri%d ",y1*scaling);
                    }
                    if(bits&0x0040)
                    {
                        ptr=scanint(ptr,&y1);
                        fprintf(rtf,"\\fi%d ",y1*scaling);
                    }
                    if(bits&0x0100)
                    {
                        x1=(unsigned char)*ptr++;
                        if(x1&1) fprintf(rtf,"\\box ");
                        if(x1&2) fprintf(rtf,"\\brdrt ");
                        if(x1&4) fprintf(rtf,"\\brdrl ");
                        if(x1&8) fprintf(rtf,"\\brdrb ");
                        if(x1&0x10) fprintf(rtf,"\\brdrr ");
                        if(x1&0x20) fprintf(rtf,"\\brdrth "); else fprintf(rtf,"\\brdrs ");
                        if(x1&0x40) fprintf(rtf,"\\brdrdb ");
                        ptr+=2;
                    }
                    if(bits&0x0200)
                    {
                        ptr=scanint(ptr,&y1);
                        while(y1-->0)
                        {
                            ptr=scanword(ptr,&x1);
                            if(x1&0x4000)
                            {
                                ptr=scanword(ptr,&x2); /* tab */
                                switch(x2)
                                {
                                case 1:
                                    fprintf(rtf,"\\tqr");
                                    break;
                                case 2:
                                    fprintf(rtf,"\\tqc");
                                    break;
                                }
                            }
                            fprintf(rtf,"\\tx%d ",(x1&0x3FFF)*scaling);
                        }
                    }
                    putc('{',rtf);
                    while(1) /* ptr<LinkData1+TopicLink.DataLen1-sizeof(TOPICLINK)&&q<end) */
                    {
                        if(*q&&fontset>=0&&fontset<fonts&&font&&(font[fontset].Attributes&FONT_SMCP)) strlwr(q);
                        do
                        {
                            if(!doc)
                            {
                                int len,footnote,keyindex;

                                while(NextContextRec<ContextRecs&&ContextRec[NextContextRec].TopicOffset<=ActualTopicOffset&&ContextRec[NextContextRec].TopicOffset<MaxTopicOffset)
                                {
                                    fprintf(rtf,"{#{\\footnote # %s}}\n",unhash(ContextRec[NextContextRec].HashValue));
                                    while(NextContextRec<ContextRecs&&ContextRec[NextContextRec].TopicOffset==ContextRec[NextContextRec+1].TopicOffset)
                                    {
                                        NextContextRec++;
                                    }
                                    NextContextRec++;
                                }
                                footnote=keyindex=len=0;
                                while(NextKeywordRec<KeywordRecs&&KeywordRec[NextKeywordRec].TopicOffset<=ActualTopicOffset&&KeywordRec[NextKeywordRec].TopicOffset<MaxTopicOffset)
                                {
                                    if(len&&(KeywordRec[NextKeywordRec].Footnote!=footnote||KeywordRec[NextKeywordRec].KeyIndex!=keyindex||len+strlen(KeywordRec[NextKeywordRec].Keyword)>1000))
                                    {
                                        fprintf(rtf,"}\n");
                                        len=0;
                                    }
                                    if(len==0)
                                    {
                                        if(KeywordRec[NextKeywordRec].KeyIndex)
                                        {
                                            len=fprintf(rtf,"K{\\footnote K %c:",KeywordRec[NextKeywordRec].Footnote);
                                        }
                                        else
                                        {
                                            len=fprintf(rtf,"%c{\\footnote %c ",KeywordRec[NextKeywordRec].Footnote,KeywordRec[NextKeywordRec].Footnote);
                                        }
                                    }
                                    else
                                    {
                                        putc(';',rtf);
                                        len++;
                                    }
                                    len+=strlen(KeywordRec[NextKeywordRec].Keyword);
                                    putrtf(rtf,KeywordRec[NextKeywordRec].Keyword);
                                    footnote=KeywordRec[NextKeywordRec].Footnote;
                                    keyindex=KeywordRec[NextKeywordRec].KeyIndex;
                                    NextKeywordRec++;
                                }
                                if(len) fprintf(rtf,"}\n");
                            }
                            if(*q!='{'&&*q!='}'&&*q!='\\'&&isprint((unsigned char)*q))
                            {
                                putc(*q,rtf);
                            }
                            else if(!doc&&*q=='{')
                            {
                                fprintf(rtf,"\\{\\-"); /* emit invisible dash after { brace */
                                /* because bmc or another legal command my follow, but this */
                                /* command was not parsed the help file was build, so it was */
                                /* used just as an example. The dash will be eaten up by the */
                                /* help compiler on recompile. */
                            }
                            else if(*q)
                            {
                                fprintf(rtf,"\\'%02x",(unsigned char)*q);
                            }
                            if(ActualTopicOffset<MaxTopicOffset) ActualTopicOffset++;
                        }
                        while(*q++);
                        if((unsigned char)ptr[0]==0xFF)
                        {
                            ptr++;
                            break;
                        }
                        else switch((unsigned char)ptr[0])
                        {
                        case 0x20: /* vfld MVB */
                            if(*(long *)(ptr+1))
                            {
                                fprintf(rtf,"\\{vfld%ld\\}",*(long *)(ptr+1));
                            }
                            else
                            {
                                fprintf(rtf,"\\{vfld\\}");
                            }
                            ptr+=5;
                            break;
                        case 0x21: /* dtype MVB */
                            if(*(short *)(ptr+1))
                            {
                                fprintf(rtf,"\\{dtype%d\\}",*(short *)(ptr+1));
                            }
                            else
                            {
                                fprintf(rtf,"\\{dtype\\}");
                            }
                            ptr+=3;
                            break;
                        case 0x80: /* font change */
                            ChangeFont(rtf,fontset=*(short *)(ptr+1),ul,uldb);
                            ptr+=3;
                            break;
                        case 0x81:
                            fprintf(rtf,"\\line\n");
                            ptr++;
                            break;
                        case 0x82:
                            if(TopicLink.RecordType==TL_TABLE)
                            {
                                if((unsigned char)ptr[1]!=0xFF)
                                {
                                    fprintf(rtf,"\n\\par \\intbl ");
                                }
                                else if(*(short *)(ptr+2)==-1)
                                {
                                    fprintf(rtf,"\\cell \\intbl \\row\n");
                                }
                                else if(*(short *)(ptr+2)==lastcol)
                                {
                                    fprintf(rtf,"\\par \\pard ");
                                }
                                else
                                {
                                    fprintf(rtf,"\\cell \\pard ");
                                }
                            }
                            else
                            {
                                fprintf(rtf,"\n\\par ");
                            }
                            ptr++;
                            break;
                        case 0x83:
                            fprintf(rtf,"\\tab ");
                            ptr++;
                            break;
                        case 0x86:
                            x3=(unsigned char)*ptr++;
                            x1=*ptr++;
                            if(x1==0x05) cmd="ewc"; else cmd="bmc";
                            goto picture;
                        case 0x87:
                            x3=(unsigned char)*ptr++;
                            x1=*ptr++;
                            if(x1==0x05) cmd="ewl"; else cmd="bml";
                            goto picture;
                        case 0x88:
                            x3=(unsigned char)*ptr++;
                            x1=*ptr++;
                            if(x1==0x05) cmd="ewr"; else cmd="bmr";
                            goto picture;
                        picture:
                            ptr=scanlong(ptr,&l1);
                            switch(x1)
                            {
                            case 0x22: /* HC31 */
                                ptr=scanword(ptr,&x1);
                                ActualTopicOffset+=x1; /* number of hotspots in picture */
                                if(ActualTopicOffset>MaxTopicOffset) ActualTopicOffset=MaxTopicOffset;
                                /* fall thru */
                            case 0x03: /* HC30 */
                                x1=((unsigned short *)ptr)[0];
                                switch(x1)
                                {
                                case 1:
                                    while(nextbitmap<extensions&&extension[nextbitmap]<0x10) nextbitmap++;
                                    if(nextbitmap>=extensions)
                                    {
                                        error("Bitmap never saved\n");
                                        break;
                                    }
                                    x2=nextbitmap++;
                                    goto other;
                                case 0:
                                    x2=((unsigned short *)ptr)[1];
                                other:
                                    if(doc)
                                    {
                                        switch(x3)
                                        {
                                        case 0x86:
                                            fprintf(rtf,"{\\field {\\*\\fldinst import %s \\* Mergeformat}}",getbitmapname(x2));
                                            break;
                                        case 0x87:
                                            fprintf(rtf,"{\\pvpara {\\field {\\*\\fldinst import %s \\* Mergeformat}}\\par}\n",getbitmapname(x2));
                                            break;
                                        case 0x88:
                                            fprintf(rtf,"{\\pvpara\\posxr{\\field {\\*\\fldinst import %s \\* Mergeformat}}\\par}\n",getbitmapname(x2));
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        if(x2<extensions&&(extension[x2]&0x20))
                                        {
                                            if(strcmp(cmd,"bmc")==0) cmd="bmct";
                                            else if(strcmp(cmd,"bml")==0) cmd="bmlt";
                                            else if(strcmp(cmd,"bmr")==0) cmd="bmrt";
                                        }
                                        fprintf(rtf,"\\{%s %s\\}",cmd,getbitmapname(x2));
                                    }
                                    break;
                                }
                                break;
                            case 0x05: /* ewc,ewl,ewr */
                                if(ptr[6]=='!')
                                {
                                    fprintf(rtf,"\\{button %s\\}",ptr+7);
                                }
                                else if(ptr[6]=='*')
                                {
                                    char *plus;
                                    int n,c1,c2;

                                    sscanf(ptr+7,"%d,%d,%n",&c1,&c2,&n);
                                    plus=strchr(ptr+7+n,'+');
                                    if((c1&0xFFF5)!=0x8400) fprintf(stderr,"mci c1=%04x\n",c1);
                                    fprintf(rtf,"\\{mci");
                                    if(cmd[2]=='r') fprintf(rtf,"_right");
                                    if(cmd[2]=='l') fprintf(rtf,"_left");
                                    if(c2==1) fprintf(rtf," REPEAT");
                                    if(c2==2) fprintf(rtf," PLAY");
                                    if(!plus) fprintf(rtf," EXTERNAL");
                                    if(c1&8) fprintf(rtf," NOMENU");
                                    if(c1&2) fprintf(rtf," NOPLAYBAR");
                                    fprintf(rtf,",%s\\}\n",plus?plus+1:ptr+7+n);
                                }
                                else
                                {
                                    fprintf(rtf,"\\{%s %s\\}",cmd,ptr+6);
                                }
                                break;
                            default:
                                error("Unknown picture flags %02x\n",x1);
                            }
                            ptr+=l1;
                            break;
                        case 0x89: /* end of hotspot */
                            ChangeFont(rtf,fontset,ul=FALSE,uldb=FALSE);
                            fprintf(rtf,"{\\v %s}",multi&&hotspot[0]=='*'?hotspot+1:hotspot);
                            ptr++;
                            break;
                        case 0xC8: /* macro */
                            ChangeFont(rtf,fontset,FALSE,uldb=TRUE);
                            hotspot=myReAlloc(hotspot,strlen(ptr+3)+2);
                            sprintf(hotspot,"!%s",ptr+3);
                            ptr+=*(short *)(ptr+1)+3;
                            break;
                        case 0xCC: /* macro without font change */
                            ChangeFont(rtf,fontset,FALSE,uldb=TRUE);
                            hotspot=myReAlloc(hotspot,strlen(ptr+3)+3);
                            sprintf(hotspot,"*!%s",ptr+3);
                            ptr+=*(short *)(ptr+1)+3;
                            break;
                        case 0xE0: /* popup jump HC30 */
                            ChangeFont(rtf,fontset,ul=TRUE,FALSE);
                            goto label0;
                        case 0xE1: /* topic jump HC30 */
                            ChangeFont(rtf,fontset,FALSE,uldb=TRUE);
                        label0:
                            hotspot=myReAlloc(hotspot,128);
                            sprintf(hotspot,"TOPIC%ld",*(long *)(ptr+1));
                            ptr+=5;
                            break;
                        case 0xE2: /* popup jump HC31 */
                            ChangeFont(rtf,fontset,ul=TRUE,FALSE);
                            goto label1;
                        case 0xE3: /* topic jump HC31 */
                            ChangeFont(rtf,fontset,FALSE,uldb=TRUE);
                        label1:
                            arg=unhash(*(long *)(ptr+1));
                            hotspot=myReAlloc(hotspot,strlen(arg)+1);
                            sprintf(hotspot,"%s",arg);
                            ptr+=5;
                            break;
                        case 0xE6: /* popup jump without font change */
                            ChangeFont(rtf,fontset,ul=TRUE,FALSE);
                            goto label2;
                        case 0xE7: /* topic jump without font change */
                            ChangeFont(rtf,fontset,FALSE,uldb=TRUE);
                        label2:
                            arg=unhash(*(long *)(ptr+1));
                            hotspot=myReAlloc(hotspot,strlen(arg)+2);
                            sprintf(hotspot,"*%s",arg);
                            ptr+=5;
                            break;
                        case 0xEA: /* popup jump into external file */
                        case 0xEE:
                            ChangeFont(rtf,fontset,ul=TRUE,FALSE);
                            goto label3;
                        case 0xEB: /* topic jump into external file / secondary window */
                        case 0xEF:
                            ChangeFont(rtf,fontset,FALSE,uldb=TRUE);
                        label3:
                            if((unsigned char)ptr[0]==0xEE||(unsigned char)ptr[0]==0xEF)
                            {
                                cmd="*";
                            }
                            else
                            {
                                cmd="";
                            }
                            arg=unhash(*(long *)(ptr+4));
                            switch((unsigned char)ptr[3])
                            {
                            case 0:
                                hotspot=myReAlloc(hotspot,strlen(cmd)+strlen(arg)+1);
                                sprintf(hotspot,"%s%s",cmd,arg);
                                break;
                            case 1:
                                hotspot=myReAlloc(hotspot,strlen(cmd)+strlen(arg)+1+strlen(WindowName(ptr[8]))+1);
                                sprintf(hotspot,"%s%s>%s",cmd,arg,WindowName(ptr[8]));
                                break;
                            case 4:
                                hotspot=myReAlloc(hotspot,strlen(cmd)+strlen(arg)+1+strlen(ptr+8)+1);
                                sprintf(hotspot,"%s%s@%s",cmd,arg,ptr+8);
                                break;
                            case 6:
                                hotspot=myReAlloc(hotspot,strlen(cmd)+strlen(arg)+1+strlen(ptr+8)+1+strlen(strchr(ptr+8,'\0')+1)+1);
                                sprintf(hotspot,"%s%s>%s@%s",cmd,arg,ptr+8,strchr(ptr+8,'\0')+1);
                                break;
                            default:
                                error("Unknown modifier %02x in tag %02x\n",(unsigned char)ptr[3],(unsigned char)ptr[0]);
                            }
                            ptr+=*(short *)(ptr+1)+3;
                            break;
                        case 0x8B:
                            fprintf(rtf,"\\~");
                            ptr++;
                            break;
                        case 0x8C:
                            fprintf(rtf,"\\-");
                            ptr++;
                            break;
                        default:
                            fprintf(stderr,"%02x unknown\n",(unsigned char)ptr[0]);
                            ptr++;
                        }
                    }
                    putc('}',rtf);
                }
            }
            else
            {
                if(LinkData1)
                {
                    printf("LinkData1:\n");
                    HexDumpMemory(LinkData1,TopicLink.DataLen1-sizeof(TOPICLINK));
                }
                if(LinkData2)
                {
                    printf("LinkData2:\n");
                    HexDumpMemory(LinkData2,TopicLink.DataLen2);
                }
            }
            if(LinkData1) free(LinkData1);
            if(LinkData2) free(LinkData2);
            dontCount=FALSE;
            memcpy(&TopicLink,&NextTopicLink,sizeof(TopicLink));
        }
    }
}

int ContextRecCmp(const void *a,const void *b)
{
    const CONTEXTREC *A;
    const CONTEXTREC *B;

    A=(const CONTEXTREC *)a;
    B=(const CONTEXTREC *)b;
    if(A->TopicOffset<B->TopicOffset) return -1;
    if(A->TopicOffset>B->TopicOffset) return 1;
    return 0;
}

void ContextLoad(FILE *HelpFile)
{
    BUFFER buf;
    int n;
    long entries;

    if(SearchFile(HelpFile,"|CONTEXT",NULL))
    {
        n=GetFirstPage(HelpFile,&buf,&entries);
        if(entries)
        {
            ContextRec=myMalloc(entries*sizeof(CONTEXTREC));
            ContextRecs=0;
            while(n)
            {
                myFRead(ContextRec+ContextRecs,n*sizeof(CONTEXTREC),HelpFile);
                ContextRecs+=n;
                n=GetNextPage(HelpFile,&buf);
            }
            printf("%d topic offsets and hash values loaded\n",ContextRecs);
            qsort(ContextRec,ContextRecs,sizeof(CONTEXTREC),ContextRecCmp);
        }
    }
}

void GenerateContent(FILE *HelpFile,FILE *ContentFile)
{
    SYSTEMRECORD *SysRec;
    SECWINDOW *SWin;
    VIOLAREC *WindowRec;
    long FileLength,offset;
    int n,i,j,WindowRecs;
    BUFFER buf;
    char *ptr;

    fprintf(ContentFile,":Base %s%s>main\n",name,ext);
    if(HelpFileTitle[0]) fprintf(ContentFile,":Title %s\n",HelpFileTitle);
    windownames=0;
    for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
    {
        if(SysRec->RecordType==0x0006) windownames++;
    }
    if(windownames)
    {
        windowname=myMalloc(windownames*sizeof(char *));
        for(i=0;i<=windownames;i++) windowname[i]=NULL;
        i=0;
        for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
        {
            if(SysRec->RecordType==0x0006)
            {
                SWin=(SECWINDOW *)SysRec->Data;
                if(SWin->Flags&WSYSFLAG_NAME)
                {
                    windowname[i]=myStrDup(SWin->Name);
                }
                i++;
            }
        }
    }
    WindowRecs=0;
    if(SearchFile(HelpFile,"|VIOLA",NULL))
    {
        n=GetFirstPage(HelpFile,&buf,&FileLength);
        if(FileLength)
        {
            WindowRec=myMalloc(FileLength*sizeof(VIOLAREC));
            while(n)
            {
                myFRead(WindowRec+WindowRecs,n*sizeof(VIOLAREC),HelpFile);
                WindowRecs+=n;
                n=GetNextPage(HelpFile,&buf);
            }
        }
    }
    if(SearchFile(HelpFile,"|TTLBTREE",NULL))
    {
        for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
        {
            for(i=0;i<n;i++)
            {
                myFRead(&offset,sizeof(offset),HelpFile);
                if(myGetS(buffer,sizeof(buffer),HelpFile))
                {
                    ptr=TopicName(offset);
                    if(ptr)
                    {
                        fprintf(ContentFile,"1 %s=%s",buffer,ptr);
                        for(j=0;j<WindowRecs;j++)
                        {
                            if(WindowRec[j].TopicOffset==offset)
                            {
                                fprintf(ContentFile,">%s",WindowName(WindowRec[j].WindowNumber));
                                break;
                            }
                        }
                        putc('\n',ContentFile);
                    }
                }
            }
        }
    }
}

void ListRose(FILE *HelpFile,FILE *hpj)
{
    long FileLength,offset,hash,h,pos,savepos;
    unsigned char *ptr;
    long *keytopic;
    int n,i,l,e;
    unsigned short j,count;
    BUFFER buf,buf2;
    char keyword[256];

    static signed char table[256]=
    {
        '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
        '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
        '\xF0', '\x0B', '\xF2', '\xF3', '\xF4', '\xF5', '\xF6', '\xF7', '\xF8', '\xF9', '\xFA', '\xFB', '\xFC', '\xFD', '\x0C', '\xFF',
        '\x0A', '\x01', '\x02', '\x03', '\x04', '\x05', '\x06', '\x07', '\x08', '\x09', '\x0A', '\x0B', '\x0C', '\x0D', '\x0E', '\x0F',
        '\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1A', '\x1B', '\x1C', '\x1D', '\x1E', '\x1F',
        '\x20', '\x21', '\x22', '\x23', '\x24', '\x25', '\x26', '\x27', '\x28', '\x29', '\x2A', '\x0B', '\x0C', '\x0D', '\x0E', '\x0D',
        '\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1A', '\x1B', '\x1C', '\x1D', '\x1E', '\x1F',
        '\x20', '\x21', '\x22', '\x23', '\x24', '\x25', '\x26', '\x27', '\x28', '\x29', '\x2A', '\x2B', '\x2C', '\x2D', '\x2E', '\x2F',
        '\x50', '\x51', '\x52', '\x53', '\x54', '\x55', '\x56', '\x57', '\x58', '\x59', '\x5A', '\x5B', '\x5C', '\x5D', '\x5E', '\x5F',
        '\x60', '\x61', '\x62', '\x63', '\x64', '\x65', '\x66', '\x67', '\x68', '\x69', '\x6A', '\x6B', '\x6C', '\x6D', '\x6E', '\x6F',
        '\x70', '\x71', '\x72', '\x73', '\x74', '\x75', '\x76', '\x77', '\x78', '\x79', '\x7A', '\x7B', '\x7C', '\x7D', '\x7E', '\x7F',
        '\x80', '\x81', '\x82', '\x83', '\x0B', '\x85', '\x86', '\x87', '\x88', '\x89', '\x8A', '\x8B', '\x8C', '\x8D', '\x8E', '\x8F',
        '\x90', '\x91', '\x92', '\x93', '\x94', '\x95', '\x96', '\x97', '\x98', '\x99', '\x9A', '\x9B', '\x9C', '\x9D', '\x9E', '\x9F',
        '\xA0', '\xA1', '\xA2', '\xA3', '\xA4', '\xA5', '\xA6', '\xA7', '\xA8', '\xA9', '\xAA', '\xAB', '\xAC', '\xAD', '\xAE', '\xAF',
        '\xB0', '\xB1', '\xB2', '\xB3', '\xB4', '\xB5', '\xB6', '\xB7', '\xB8', '\xB9', '\xBA', '\xBB', '\xBC', '\xBD', '\xBE', '\xBF',
        '\xC0', '\xC1', '\xC2', '\xC3', '\xC4', '\xC5', '\xC6', '\xC7', '\xC8', '\xC9', '\xCA', '\xCB', '\xCC', '\xCD', '\xCE', '\xCF'
    };

    if(SearchFile(HelpFile,"|Rose",NULL))
    {
        savepos=ftell(HelpFile);
        if(SearchFile(HelpFile,"|KWDATA",&FileLength))
        {
            keytopic=myMalloc(FileLength);
            myFRead(keytopic,FileLength,HelpFile);
            if(SearchFile(HelpFile,"|KWBTREE",NULL))
            {
                fprintf(hpj,"[MACROS]\n");
                for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
                {
                    for(i=0;i<n;i++)
                    {
                        myGetS(keyword,sizeof(keyword),HelpFile);
                        for(hash=0L,ptr=(unsigned char *)keyword;*ptr;ptr++)
                        {
                            hash=(hash*0x2BU)+table[*ptr];
                        }
                        myFRead(&count,sizeof(count),HelpFile);
                        myFRead(&offset,sizeof(offset),HelpFile);
                        for(j=0;j<count;j++)
                        {
                            if(keytopic[offset/4+j]==-1L)
                            {
                                pos=ftell(HelpFile);
                                fseek(HelpFile,savepos,SEEK_SET);
                                for(l=GetFirstPage(HelpFile,&buf2,NULL);l;l=GetNextPage(HelpFile,&buf2))
                                {
                                    for(e=0;e<l;e++)
                                    {
                                        myFRead(&h,sizeof(long),HelpFile);
                                        myGetS(buffer,sizeof(buffer),HelpFile);
                                        if(h==hash)
                                        {
                                            fprintf(hpj,"%s\n%s\n",keyword,buffer);
                                            myGetS(buffer,sizeof(buffer),HelpFile);
                                            fprintf(hpj,"%s\n",buffer);
                                        }
                                        else
                                        {
                                            myGetS(buffer,sizeof(buffer),HelpFile);
                                        }
                                    }
                                }
                                fseek(HelpFile,pos,SEEK_SET);
                                break;
                            }
                        }
                    }
                }
                putc('\n',hpj);
            }
            free(keytopic);
        }
    }
}

void PrintNewFont(int i,NEWFONT *newfont)
{
    printf("%3d: %-32.32s %6ld %-6s %02X%02X%02X %02X%02X%02X ",i,fontname[newfont->FontName],newfont->Height,FontFamily(newfont->PitchAndFamily>>4),newfont->FGRGB[2],newfont->FGRGB[1],newfont->FGRGB[0],newfont->BGRGB[2],newfont->BGRGB[1],newfont->BGRGB[0]);
    if(newfont->Weight>500) putchar('b');
    if(newfont->Italic) putchar('i');
    if(newfont->Underline) putchar('u');
    if(newfont->StrikeOut) putchar('s');
    if(newfont->DoubleUnderline) putchar('d');
    if(newfont->SmallCaps) putchar('c');
    putchar('\n');
}

void PrintMvbFont(int i,MVBFONT *mvbfont)
{
    printf("%3d: %-32.32s %6ld %-6s %02X%02X%02X %02X%02X%02X ",i,fontname[mvbfont->FontName],mvbfont->Height,FontFamily(mvbfont->PitchAndFamily>>4),mvbfont->FGRGB[2],mvbfont->FGRGB[1],mvbfont->FGRGB[0],mvbfont->BGRGB[2],mvbfont->BGRGB[1],mvbfont->BGRGB[0]);
    if(mvbfont->Weight>500) putchar('b');
    if(mvbfont->Italic) putchar('i');
    if(mvbfont->Underline) putchar('u');
    if(mvbfont->StrikeOut) putchar('s');
    if(mvbfont->DoubleUnderline) putchar('d');
    if(mvbfont->SmallCaps) putchar('c');
    putchar('\n');
}

void FontDump(FILE *HelpFile)
{
    FONTHEADER FontHdr;
    long FileStart;
    OLDFONT oldfont;
    NEWFONT newfont;
    NEWSTYLE newstyle;
    MVBFONT mvbfont;
    MVBSTYLE mvbstyle;
    int i,n;

    /* Go to the FONT file and get the headers */
    FileStart=ftell(HelpFile);
    myFRead(&FontHdr,sizeof(FontHdr),HelpFile);
    n=(FontHdr.DescriptorsOffset-FontHdr.FacenamesOffset)/FontHdr.NumFacenames;
    fontname=myMalloc(FontHdr.NumFacenames*sizeof(char *));
    fseek(HelpFile,FileStart+FontHdr.FacenamesOffset,SEEK_SET);
    for(i=0;i<FontHdr.NumFacenames;i++)
    {
        myFRead(buffer,n,HelpFile);
        buffer[n]='\0';
        printf("Font name %d: %s\n",i,buffer);
        fontname[i]=myStrDup(buffer);
    }
    printf("Font Facename                         Height Family Foregr Backgr Style\n");
    fseek(HelpFile,FileStart+FontHdr.DescriptorsOffset,SEEK_SET);
    if(FontHdr.FacenamesOffset>=16)
    {
        for(i=0;i<FontHdr.NumDescriptors;i++)
        {
            myFRead(&mvbfont,sizeof(mvbfont),HelpFile);
            PrintMvbFont(i,&mvbfont);
        }
        fseek(HelpFile,FileStart+FontHdr.FormatsOffset,SEEK_SET);
        for(i=0;i<FontHdr.NumFormats;i++)
        {
            myFRead(&mvbstyle,sizeof(mvbstyle),HelpFile);
            printf("Style %d based on %d named '%s':\n",mvbstyle.StyleNum,mvbstyle.BasedOn,mvbstyle.StyleName);
            PrintMvbFont(i,&mvbstyle.font);
        }
    }
    else if(FontHdr.FacenamesOffset>=12)
    {
        for(i=0;i<FontHdr.NumDescriptors;i++)
        {
            myFRead(&newfont,sizeof(newfont),HelpFile);
            PrintNewFont(i,&newfont);
        }
        fseek(HelpFile,FileStart+FontHdr.FormatsOffset,SEEK_SET);
        for(i=0;i<FontHdr.NumFormats;i++)
        {
            myFRead(&newstyle,sizeof(newstyle),HelpFile);
            printf("Style %d based on %d named '%s':\n",newstyle.StyleNum,newstyle.BasedOn,newstyle.StyleName);
            PrintNewFont(i,&newstyle.font);
        }
    }
    else
    {
        for(i=0;i<FontHdr.NumDescriptors;i++)
        {
            myFRead(&oldfont,sizeof(oldfont),HelpFile);
            printf("%3d: %-32.32s %6.1f %-6s %02X%02X%02X %02X%02X%02X ",i+1,fontname[oldfont.FontName],oldfont.HalfPoints/2.0,FontFamily(oldfont.FontFamily),oldfont.FGRGB[2],oldfont.FGRGB[1],oldfont.FGRGB[0],oldfont.BGRGB[2],oldfont.BGRGB[1],oldfont.BGRGB[0]);
            if(oldfont.Attributes&FONT_BOLD) putchar('b');
            if(oldfont.Attributes&FONT_ITAL) putchar('i');
            if(oldfont.Attributes&FONT_UNDR) putchar('u');
            if(oldfont.Attributes&FONT_STRK) putchar('s');
            if(oldfont.Attributes&FONT_DBUN) putchar('d');
            if(oldfont.Attributes&FONT_SMCP) putchar('c');
            putchar('\n');
        }
    }
}

void BTreeDump(FILE *HelpFile,char text[])
{
    int n,i,j;
    BUFFER buf;
    char format[10];
    unsigned short s;
    long l;
    char *ptr;

    n=GetFirstPage(HelpFile,&buf,&l);
    while(n)
    {
        for(i=0;i<n;i++)
        {
            for(ptr=text;*ptr;ptr++)
            {
                if(*ptr=='%')
                {
                    j=strcspn(ptr,"sdux");
                    memcpy(format,ptr,j+1);
                    format[j+1]='\0';
                    if(format[j]=='s')
                    {
                        myGetS(buffer,sizeof(buffer),HelpFile);
                        printf(format,buffer);
                    }
                    else if(strchr(format,'l'))
                    {
                        myFRead(&l,sizeof(l),HelpFile);
                        printf(format,l);
                    }
                    else
                    {
                        s=myGetW(HelpFile);
                        printf(format,s);
                    }
                    ptr+=j;
                }
                else
                {
                    putchar(*ptr);
                }
            }
        }
        n=GetNextPage(HelpFile,&buf);
    }
}

void ToMapDump(FILE *HelpFile,long FileLength)
{
    long TopicOffset,i;

    for(i=0;i*4L<FileLength;i++)
    {
        myFRead(&TopicOffset,sizeof(TopicOffset),HelpFile);
        printf("TopicNum: %-12ld TopicOffset: 0x%08lX\n",i,TopicOffset);
    }
}

void PhraseDump(void)
{
    unsigned int n;

    for(n=0;n<PhraseCount;n++)
    {
        printf("%-5d - ",n);
        PrintPhrase(n,NULL,NULL);
        putchar('\n');
    }
}

void SysDump(FILE *HelpFile)
{
    SYSTEMHEADER SysHdr;
    SYSTEMRECORD *SysRec;
    struct tm *TimeRec;
    SECWINDOW *SWin;
    char *ptr;

    myFRead(&SysHdr,sizeof(SysHdr),HelpFile);
    if(SysHdr.Version==15)
    {
        ptr="HC30";
    }
    else if(SysHdr.Version==21)
    {
        ptr="HC31";
    }
    else if(SysHdr.Version==27)
    {
        ptr="WMVC/MVCC";
    }
    else if(SysHdr.Version==33)
    {
        if(mvp)
        {
            ptr="MVC";
        }
        else
        {
            ptr="HCRTF";
        }
    }
    else ptr="Unknown";
    printf("%s Help Compiler used.\n",ptr);
    printf("System Flags & Compression Method=0x%04x\n",SysHdr.Flags);
    TimeRec=localtime(&SysHdr.GenDate);
    printf("Help File Generated: %s",asctime(TimeRec));
    if(SysHdr.Version<16)
    {
        myGetS(HelpFileTitle,33,HelpFile);
        printf("TITLE=%s\n",HelpFileTitle);
    }
    else for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
    {
        switch(SysRec->RecordType)
        {
        case 0x0001:
            printf("TITLE=%s\n",SysRec->Data);
            break;
        case 0x0002:
            ptr=strchr(SysRec->Data,'\r');
            if(ptr) strcpy(ptr,"%date");
            printf("COPYRIGHT=%s\n",SysRec->Data);
            break;
        case 0x0003:
            printf("CONTENTS=0x%08lX\n",*(long *)SysRec->Data);
            break;
        case 0x0004:
            printf("[MACRO] %s\n",SysRec->Data);
            break;
        case 0x0005:
            printf("Icon in System record\n");
            break;
        case 0x0006:
            SWin=(SECWINDOW *)SysRec->Data;
            if(SWin->Flags&WSYSFLAG_TYPE) printf("Type: %s\n",SWin->Type);
            if(SWin->Flags&WSYSFLAG_NAME) printf("Name: %s\n",SWin->Name);
            if(SWin->Flags&WSYSFLAG_CAPTION) printf("Caption: %s\n",SWin->Caption);
            if(SWin->Flags&WSYSFLAG_X) printf("X: %d\n",SWin->X);
            if(SWin->Flags&WSYSFLAG_Y) printf("Y: %d\n",SWin->Y);
            if(SWin->Flags&WSYSFLAG_WIDTH) printf("Width: %d\n",SWin->Width);
            if(SWin->Flags&WSYSFLAG_HEIGHT) printf("Height: %d\n",SWin->Height);
            if(SWin->Maximize) printf("State&Buttons: 0x%04x\n",SWin->Maximize);
            if(SWin->Flags&WSYSFLAG_RGB) printf("RGB Foreground Colors Set\n");
            if(SWin->Flags&WSYSFLAG_RGBNSR) printf("RGB For Non-Scrollable Region Set\n");
            if(SWin->Flags&WSYSFLAG_TOP) printf("Always On Top\n");
            if(SWin->Flags&WSYSFLAG_AUTOSIZEHEIGHT) printf("Auto-Size Height\n");
            if(SWin->Flags&0xF000) printf("Additional Flags: 0x%04x\n",SWin->Flags);
            break;
        case 0x0008:
            printf("CITATION=%s\n",SysRec->Data);
            break;
        case 0x0009:
            if(!mvp) printf("LCID=0x%X 0x%X 0x%X\n",*(short *)(SysRec->Data+8),*(short *)SysRec->Data,*(short *)(SysRec->Data+2));
            break;
        case 0x000A:
            if(!mvp) printf("CNT=%s\n",SysRec->Data);
            break;
        case 0x000B:
            if(!mvp) printf("CHARSET=%d\n",*(unsigned char *)(SysRec->Data+1));
            break;
        case 0x000C:
            if(mvp)
            {
                printf("[FTINDEX] dtype %s\n",SysRec->Data);
            }
            else
            {
                printf("DEFFONT=%s,%d,%d\n",SysRec->Data+2,*(unsigned char *)SysRec->Data,*(unsigned char *)(SysRec->Data+1));
            }
            break;
        case 0x000D:
            if(mvp) printf("[GROUPS] %s\n",SysRec->Data);
            break;
        case 0x000E:
            if(mvp)
            {
                printf("[KEYINDEX] keyword=%c, \"%s\"\n",SysRec->Data[1],SysRec->Data+30);
            }
            else
            {
                printf("INDEX_SEPARATORS=\"%s\"\n",SysRec->Data);
            }
            break;
        case 0x0012:
            if(SysRec->Data[0]) printf("LANGUAGE=%s\n",SysRec->Data);
            break;
        case 0x0013:
            ptr=SysRec->Data+strlen(SysRec->Data)+1;
            printf("[DLLMAPS] %s=%s,",SysRec->Data,ptr);
            ptr=ptr+strlen(ptr)+1;
            printf("%s,",ptr);
            ptr=ptr+strlen(ptr)+1;
            printf("%s,",ptr);
            ptr=ptr+strlen(ptr)+1;
            printf("%s\n",ptr);
            break;
        default:
            fprintf(stderr,"Unknown record type: 0x%04X\n",SysRec->RecordType);
	    HexDumpMemory(SysRec->Data,SysRec->DataSize);
        }
    }
}

void GroupDump(FILE *HelpFile)
{
    GROUPHEADER GroupHeader;
    char *ptr;
    unsigned long i;

    myFRead(&GroupHeader,sizeof(GroupHeader),HelpFile);
    switch(GroupHeader.GroupType)
    {
    case 2:
        ptr=myMalloc(GroupHeader.BitmapSize);
        myFRead(ptr,GroupHeader.BitmapSize,HelpFile);
    case 1:
        for(i=GroupHeader.FirstTopic;i<=GroupHeader.LastTopic;i++)
        {
            if(GroupHeader.GroupType==1||ptr[i>>3]&(1<<(i&7))) printf("TopicNumber: %lu\n",i);
        }
        break;
    default:
        fprintf(stderr,"GroupHeader GroupType %ld unknown\n",GroupHeader.GroupType);
    }
}

void KWMapDump(FILE *HelpFile)
{
    unsigned short n,i;
    KWMAPREC KeywordMap;

    n=myGetW(HelpFile);
    for(i=0;i<n;i++)
    {
        myFRead(&KeywordMap,sizeof(KWMAPREC),HelpFile);
        printf("Keyword: %-12ld LeafPage: %u\n",KeywordMap.FirstRec,KeywordMap.PageNum);
    }
}

void KWDataDump(FILE *HelpFile,long FileLength)
{
    long i,TopicOffset;

    for(i=0;i<FileLength;i+=4)
    {
        myFRead(&TopicOffset,sizeof(TopicOffset),HelpFile);
        printf("KWDataAddress: 0x%08lx TopicOffset: 0x%08lX\n",i,TopicOffset);
    }
}

void CatalogDump(FILE *HelpFile)
{
    CATALOGHEADER catalog;
    long n;
    long TopicOffset;

    myFRead(&catalog,sizeof(catalog),HelpFile);
    for(n=0;n<catalog.entries;n++)
    {
        myFRead(&TopicOffset,sizeof(TopicOffset),HelpFile);
        printf("Topic: %-12ld TopicOffset: 0x%08lx\n",n+1,TopicOffset);
    }
}

void CTXOMAPDump(FILE *HelpFile)
{
    CTXOMAPREC CTXORec;
    unsigned short n,i;

    n=myGetW(HelpFile);
    for(i=0;i<n;i++)
    {
        myFRead(&CTXORec,sizeof(CTXORec),HelpFile);
        printf("MapId: %-12ld TopicOffset: 0x%08lX\n",CTXORec.MapID,CTXORec.TopicOffset);
    }
}

void LinkDump(FILE *HelpFile)
{
    long data[3];
    int n,i;

    n=myGetW(HelpFile);
    for(i=0;i<n;i++)
    {
        myFRead(data,sizeof(data),HelpFile);
        printf("Annotation for topic 0x%08lx 0x%08lx 0x%08lx\n",data[0],data[1],data[2]);
    }
}

void AnnotationDump(FILE *HelpFile,long FileLength,char *name)
{
    long l;

    printf("Annotation %s for topic 0x%08lx:\n",name,atol(name));
    for(l=0;l<FileLength;l++) putchar(getc(HelpFile));
    putchar('\n');
}

void DumpTopic(FILE *HelpFile)
{
    TOPICLINK TopicLink;
    TOPICLINK NextTopicLink;
    char *LinkData1;
    char *LinkData2;
    long TopicNum=16;
    int BytesRead;

    if(!SearchFile(HelpFile,"|TOPIC",&TopicFileLength)) return;
    BytesRead=(int)TopicRead(HelpFile,12L,&TopicLink,sizeof(TopicLink));
    dontCount=FALSE;
    while(BytesRead==sizeof(TOPICLINK))
    {
        printf("----------------------------------------------------------------------------\n");
        printf("TopicLink Type %02x: BlockSize=%08lx DataLen1=%08lx DataLen2=%08lx\n",TopicLink.RecordType,TopicLink.BlockSize,TopicLink.DataLen1,TopicLink.DataLen2);
        printf("TopicPos=%08lx TopicOffset=%08lx PrevBlock=%08lx NextBlock=%08lx\n",CurrentTopicPos,CurrentTopicOffset,TopicLink.PrevBlock,TopicLink.NextBlock);
        if(TopicLink.DataLen1>sizeof(TOPICLINK))
        {
            LinkData1=myMalloc(TopicLink.DataLen1-sizeof(TOPICLINK));
            TopicRead(HelpFile,0L,LinkData1,TopicLink.DataLen1-sizeof(TOPICLINK));
        }
        else LinkData1=NULL;
        if(TopicLink.DataLen1<TopicLink.BlockSize) /* read LinkData2 without phrase replacement */
        {
            LinkData2=myMalloc(TopicLink.BlockSize-TopicLink.DataLen1);
            TopicRead(HelpFile,0L,LinkData2,TopicLink.BlockSize-TopicLink.DataLen1);
        }
        else LinkData2=NULL;
        BytesRead=(int)TopicRead(HelpFile,0L,&NextTopicLink,sizeof(NextTopicLink));
        if(LinkData1) HexDumpMemory(LinkData1,TopicLink.DataLen1-sizeof(TOPICLINK));
        if(TopicLink.RecordType==TL_TOPICHDR&&before31)
        {
            TOPICHEADER30 *TopicHdr;

            TopicHdr=(TOPICHEADER30 *)LinkData1;
            printf("============================================================================\n");
            printf("TopicHeader %ld: BlockSize=%ld PrevTopicNum=%ld NextTopicNum=%ld\n",TopicNum,TopicHdr->BlockSize,TopicHdr->PrevTopicNum,TopicHdr->NextTopicNum);
            TopicNum++;
        }
        else if(TopicLink.RecordType==TL_TOPICHDR&&!before31)
        {
            TOPICHEADER *TopicHdr;

            TopicHdr=(TOPICHEADER *)LinkData1;
            printf("============================================================================\n");
            printf("TopicHeader %ld: BlockSize=%ld TopicOffset=%08lx NextTopic=%08lx\n",TopicHdr->TopicNum,TopicHdr->BlockSize,CurrentTopicOffset,TopicHdr->NextTopic);
            printf("NonScroll=%08lx Scroll=%08lx BrowseBck=%08lx BrowseFor=%08lx\n",TopicHdr->NonScroll,TopicHdr->Scroll,TopicHdr->BrowseBck,TopicHdr->BrowseFor);
        }
        else if(TopicLink.RecordType==TL_DISPLAY30||TopicLink.RecordType==TL_DISPLAY||TopicLink.RecordType==TL_TABLE)
        {
            char *ptr;
            char *str;
            char *cmd;
            long l;
            unsigned short w,bits;
            unsigned char b,cols,col;
            short i;

            switch(TopicLink.RecordType)
            {
            case TL_DISPLAY30:
                printf("Text ");
                break;
            case TL_DISPLAY:
                printf("Display ");
                break;
            case TL_TABLE:
                printf("Table ");
                break;
            }
            ptr=scanlong(LinkData1,&l);
            printf("expandedsize=%ld ",l);
            if(TopicLink.RecordType==TL_DISPLAY||TopicLink.RecordType==TL_TABLE)
            {
                ptr=scanword(ptr,&w);
                if(!dontCount) CurrentTopicOffset+=w;
                printf("topicoffsetincrement=%u ",w);
            }
            if(TopicLink.RecordType==TL_TABLE)
            {
                cols=*ptr++;
                printf("columns=%d ",cols);
                b=*ptr++;
                printf("type=%d ",b);
                switch(b)
                {
                case 0:
                case 2:
                    printf("minwidth=%d ",*(short *)ptr);
                    ptr+=2;
                case 1:
                case 3:
                    break;
                default:
                    printf("unknown ");
                }
                for(i=0;i<cols;i++)
                {
                    printf("width=%d ",((short *)ptr)[0]);
                    printf("gap=%d ",((short *)ptr)[1]);
                    ptr+=4;
                }
            }
            putchar('\n');
            if(TopicLink.DataLen2<=TopicLink.BlockSize-TopicLink.DataLen1)
            {
                str=LinkData2;
            }
            else
            {
                str=myMalloc(TopicLink.DataLen2+1);
                StringPrint(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1,str);
                free(LinkData2);
                LinkData2=str;
            }
            for(col=0;(TopicLink.RecordType==TL_TABLE?*(short *)ptr!=-1:col==0)&&ptr<LinkData1+TopicLink.DataLen1-sizeof(TOPICLINK);col++)
            {
                if(TopicLink.RecordType==TL_TABLE)
                {
                    printf("column=%d ",*(short *)ptr);
                    ptr+=2;
                    printf("%04x ",*(unsigned short *)ptr);
                    ptr+=2;
                    printf("%d ",(unsigned char)*ptr++-0x80);
                }
                printf("%02x ",*ptr++);
                printf("%d ",(unsigned char)*ptr++-0x80);
                printf("id=%04x ",*(unsigned short *)ptr);
                ptr+=2;
                bits=*(unsigned short *)ptr;
                ptr+=2;
                if(bits&0x0001) /* found in MSDNCD9.MVB, purpose unknown */
                {
                    ptr=scanlong(ptr,&l);
                    printf("unknownbit01=%ld ",l);
                }
                if(bits&0x0002)
                {
                    ptr=scanint(ptr,&i);
                    printf("topspacing=%d ",i);
                }
                if(bits&0x0004)
                {
                    ptr=scanint(ptr,&i);
                    printf("bottomspacing=%d ",i);
                }
                if(bits&0x0008)
                {
                    ptr=scanint(ptr,&i);
                    printf("linespacing=%d ",i);
                }
                if(bits&0x0010)
                {
                    ptr=scanint(ptr,&i);
                    printf("leftindent=%d ",i);
                }
                if(bits&0x0020)
                {
                    ptr=scanint(ptr,&i);
                    printf("rightindent=%d ",i);
                }
                if(bits&0x0040)
                {
                    ptr=scanint(ptr,&i);
                    printf("firstlineindent=%d ",i);
                }
                if(bits&0x0080) printf("unknownbit80set ");
                if(bits&0x0100)
                {
                    b=(unsigned char)*ptr++;
                    if(b&1) printf("box ");
                    if(b&2) printf("topborder ");
                    if(b&4) printf("leftborder ");
                    if(b&8) printf("bottomborder ");
                    if(b&0x10) printf("rightborder ");
                    if(b&0x20) printf("thickborder ");
                    if(b&0x40) printf("doubleborder ");
                    if(b&0x80) printf("unknownborder ");
                    printf("%04x ",*(unsigned short *)ptr);
                    ptr+=2;
                }
                if(bits&0x0200)
                {
                    ptr=scanint(ptr,&i);
                    printf("tabs=%d ",i);
                    while(i-->0)
                    {
                        ptr=scanword(ptr,&w);
                        printf("stop=%d ",w&0x3FFF);
                        if(w&0x4000)
                        {
                            ptr=scanword(ptr,&w);
                            if(w==1)
                            {
                                printf("right ");
                            }
                            else if(w==2)
                            {
                                printf("center ");
                            }
                            else
                            {
                                printf("unknowntabmodifier=%02x ",w);
                            }
                        }
                    }
                }
                if(bits&0x0400) printf("rightalign ");
                if(bits&0x0800) printf("centeralign ");
                if(bits&0x1000) printf("keeplinestogether ");
                if(bits&0x2000) printf("unknownbit2000set "); /* found in PRINTMAN.HLP */
                if(bits&0x4000) printf("unknownbit4000set "); /* found in PRINTMAN.HLP */
                if(bits&0x8000) printf("unknownbit8000set ");
                putchar('\n');
                while(1)
                {
                    while(*str)
                    {
                        if(isprint((unsigned char)*str))
                        {
                            putchar(*str++);
                        }
                        else
                        {
                            printf("(%02x)",*(unsigned char *)str++);
                        }
                    }
                    str++;
                    if((unsigned char)ptr[0]==0xFF)
                    {
                        ptr++;
                        break;
                    }
                    else switch((unsigned char)ptr[0])
                    {
                    case 0x20:
                        printf("{vfld%ld}",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0x21:
                        printf("{dtype%d}",*(short *)(ptr+1));
                        ptr+=3;
                        break;
                    case 0x80: /* font change */
                        printf("[font=%u]",*(short *)(ptr+1));
                        ptr+=3;
                        break;
                    case 0x81:
                        printf("[LF]\n");
                        ptr++;
                        break;
                    case 0x82:
                        printf("[CR]\n");
                        ptr++;
                        break;
                    case 0x83:
                        printf("[TAB]");
                        ptr++;
                        break;
                    case 0x86:
                        ptr++;
                        b=*ptr++;
                        if(b==0x05) cmd="ewc"; else cmd="bmc";
                        goto picture;
                    case 0x87:
                        ptr++;
                        b=*ptr++;
                        if(b==0x05) cmd="ewl"; else cmd="bml";
                        goto picture;
                    case 0x88:
                        ptr++;
                        b=*ptr++;
                        if(b==0x05) cmd="ewr"; else cmd="bmr";
                    picture:
                        printf("[%s %02x ",cmd,b);
                        ptr=scanlong(ptr,&l);
                        switch(b)
                        {
                        case 0x22: /* HC31 */
                            ptr=scanword(ptr,&w);
                            printf("hotspots=%u ",w);
                        case 0x03: /* HC30 */
                            switch(*(unsigned short *)ptr)
                            {
                            case 0:
                                printf("baggage ");
                                break;
                            case 1:
                                printf("embedded ");
                                break;
                            default:
                                printf("%04x ",((unsigned short *)ptr)[0]);
                            }
                            printf("bm%u]",((unsigned short *)ptr)[1]);
                            break;
                        case 0x05:
                            printf("%04x ",((unsigned short *)ptr)[0]);
                            printf("%04x ",((unsigned short *)ptr)[1]);
                            printf("%04x ",((unsigned short *)ptr)[2]);
                            printf("%s]",ptr+6);
                            break;
                        default:
                            error("Unknown picture flags %02x\n",b);
                        }
                        ptr+=l;
                        break;
                    case 0x89: /* end of hot spot */
                        printf("[U]");
                        ptr++;
                        break;
                    case 0x8B:
                        printf("\\~");
                        ptr++;
                        break;
                    case 0x8C:
                        printf("\\-");
                        ptr++;
                        break;
                    case 0xC8: /* macro */
                        printf("[!%s]",ptr+3);
                        ptr+=*(short *)(ptr+1)+3;
                        break;
                    case 0xCC: /* macro without font change */
                        printf("[*!%s]",ptr+3);
                        ptr+=*(short *)(ptr+1)+3;
                        break;
                    case 0xE0: /* Popup HC30 */
                        printf("[^TOPIC%ld]",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0xE1: /* Jump HC30 */
                        printf("[TOPIC%ld]",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0xE2: /* Popup HC31 */
                        printf("[^%08lx]",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0xE3: /* Jump HC31 */
                        printf("[%08lx]",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0xE6: /* Popup without font change */
                        printf("[*^%08lx]",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0xE7: /* Jump without font change */
                        printf("[*%08lx]",*(long *)(ptr+1));
                        ptr+=5;
                        break;
                    case 0xEA: /* Popup into external file / secondary window */
                        cmd="^";
                        goto jump;
                    case 0xEB: /* Jump into external file / secondary window */
                        cmd="";
                        goto jump;
                    case 0xEE: /* Popup into external file / secondary window without font change */
                        cmd="^*";
                        goto jump;
                    case 0xEF: /* Jump into external file / secondary window without font change */
                        cmd="*";
                    jump:
                        switch(ptr[3])
                        {
                        case 0:
                            printf("[%s%08lx] ",cmd,*(long *)(ptr+4));
                            break;
                        case 1: /* Popup into secondary window (silly) */
                            printf("[%s%08lx>%d]",cmd,*(long *)(ptr+4),(unsigned char)ptr[8]);
                            break;
                        case 4:
                            printf("[%s%08lx@%s] ",cmd,*(long *)(ptr+4),ptr+8);
                            break;
                        case 6: /* Popup into external file / secondary window (silly) */
                            printf("[%s%08lx>%s@%s] ",cmd,*(long *)(ptr+4),ptr+8,strchr(ptr+8,'\0')+1);
                            break;
                        default:
                            printf("[");
                            for(i=0;i<*(short *)(ptr+1);i++) printf("%02x",(unsigned char)ptr[i]);
                            printf("]");
                        }
                        ptr+=*(short *)(ptr+1)+3;
                        break;
                    default:
                        printf("[%02x]",(unsigned char)*ptr++);
                    }
                }
                putchar('\n');
            }
            free(LinkData2);
            LinkData2=NULL;
        }
        if(LinkData2)
        {
            if(TopicLink.DataLen2<=TopicLink.BlockSize-TopicLink.DataLen1)
            {
                char *ptr;
                char *end;

                end=LinkData2+TopicLink.DataLen2;
                for(ptr=LinkData2;ptr<end;ptr++)
                {
                    if(isprint((unsigned char)*ptr))
                    {
                        putchar(*ptr);
                    }
                    else
                    {
                        printf("(%02x)",*(unsigned char *)ptr);
                    }
                }
            }
            else
            {
                StringPrint(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1,NULL);
            }
            putchar('\n');
        }
        if(LinkData1) free(LinkData1);
        if(LinkData2) free(LinkData2);
        dontCount=FALSE;
        memcpy(&TopicLink,&NextTopicLink,sizeof(TopicLink));
    }
}

void AliasList(FILE *hpj)
{
    int i,n;
    BOOL headerwritten;

    headerwritten=FALSE;
    for(i=0;i<ContextRecs;i=n)
    {
        for(n=i+1;n<ContextRecs&&ContextRec[i].TopicOffset==ContextRec[n].TopicOffset;n++)
        {
            if(!headerwritten)
            {
                fprintf(stderr,"Creating [ALIAS] section...\n");
                fprintf(hpj,"[ALIAS]\n");
                headerwritten=TRUE;
            }
            fprintf(hpj,"%s=",unhash(ContextRec[n].HashValue));
            fprintf(hpj,"%s\n",unhash(ContextRec[i].HashValue));
        }
    }
    if(headerwritten) putc('\n',hpj);
}

void CTXOMAPList(FILE *HelpFile,FILE *hpj)
{
    CTXOMAPREC CTXORec;
    unsigned short n,i;

    if(SearchFile(HelpFile,"|CTXOMAP",NULL))
    {
        n=myGetW(HelpFile);
        if(n)
        {
            fprintf(stderr,"Creating [MAP] section...\n");
            fprintf(hpj,"[MAP]\n");
            for(i=0;i<n;i++)
            {
                myFRead(&CTXORec,sizeof(CTXORec),HelpFile);
                fprintf(hpj,"%s %ld\n",TopicName(CTXORec.TopicOffset),CTXORec.MapID);
            }
            putc('\n',hpj);
        }
    }
}

/* 1. extract topic names from topic macros, embedded pictures, and hotspot macros */
/* 2. build browse sequence start list */
/* 3. extract embedded pictures */
void FirstPass(FILE *HelpFile)
{
    long TopicNum,ActualTopicOffset;
    int BytesRead;
    SYSTEMRECORD *SysRec;

    if(extractmacros)
    {
        for(SysRec=GetFirstSystemRecord(HelpFile);SysRec;SysRec=GetNextSystemRecord(SysRec))
        {
            if(SysRec->RecordType==0x0004)
            {
                strcpy(TopicTitle,"[CONFIG] section");
                CheckMacro(SysRec->Data);
            }
        }
        if(SearchFile(HelpFile,"|TopicId",NULL))
        {
            int n,i;
            long offset;
            BUFFER buf;

            for(n=GetFirstPage(HelpFile,&buf,NULL);n;n=GetNextPage(HelpFile,&buf))
            {
                for(i=0;i<n;i++)
                {
                    myFRead(&offset,sizeof(offset),HelpFile);
                    myGetS(buffer,sizeof(buffer),HelpFile);
                    AddTopic(buffer);
                }
            }
        }
    }
    TopicNum=16;
    TopicUse=TRUE;
    /* extract macros from topic headers */
    browses=0;
    browsenums=1;
    if(SearchFile(HelpFile,"|TOPIC",&TopicFileLength))
    {
        TOPICLINK TopicLink;
        TOPICLINK NextTopicLink;
        char *LinkData1;
        char *LinkData2;

        dontCount=FALSE;
        ActualTopicOffset=0L;
        BytesRead=(int)TopicRead(HelpFile,12L,&TopicLink,sizeof(TopicLink));
        while(BytesRead==sizeof(TOPICLINK))
        {
            if(TopicLink.DataLen1>sizeof(TOPICLINK))
            {
                LinkData1=myMalloc(TopicLink.DataLen1-sizeof(TOPICLINK)+1);
                if(!TopicRead(HelpFile,0L,LinkData1,TopicLink.DataLen1-sizeof(TOPICLINK))) break;
            }
            else LinkData1=NULL;
            if(TopicLink.DataLen1<TopicLink.BlockSize) /* read LinkData2 without phrase replacement */
            {
                LinkData2=myMalloc(TopicLink.BlockSize-TopicLink.DataLen1+1);
                if(!TopicRead(HelpFile,0L,LinkData2,TopicLink.BlockSize-TopicLink.DataLen1)) break;
            }
            else LinkData2=NULL;
            BytesRead=(int)TopicRead(HelpFile,0L,&NextTopicLink,sizeof(NextTopicLink));
            if(TopicLink.RecordType==TL_TOPICHDR) /* display a topic header record */
            {
                fprintf(stderr,"Topic %ld\r",TopicNum-15);
                if(before31)
                {
                    TOPICHEADER30 *TopicHdr;

                    TopicHdr=(TOPICHEADER30 *)LinkData1;
                    if(resolvebrowse)
                    {
                        if(TopicHdr->NextTopicNum>TopicNum&&TopicHdr->PrevTopicNum>TopicNum
                        || TopicHdr->NextTopicNum==-1&&TopicHdr->PrevTopicNum>TopicNum
                        || TopicHdr->NextTopicNum>TopicNum&&TopicHdr->PrevTopicNum==-1)
                        {
                            AddBrowse(TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                        }
                        else if(TopicHdr->NextTopicNum!=-1&&TopicHdr->NextTopicNum<TopicNum&&TopicHdr->PrevTopicNum!=-1&&TopicHdr->PrevTopicNum<TopicNum)
                        {
                            MergeBrowse(TopicNum,TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                        }
                        else if(TopicHdr->NextTopicNum!=-1&&TopicHdr->NextTopicNum<TopicNum&&(TopicHdr->PrevTopicNum==-1||TopicHdr->PrevTopicNum>TopicNum))
                        {
                            BackLinkBrowse(TopicNum,TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                        }
                        else if(TopicHdr->PrevTopicNum!=-1&&TopicHdr->PrevTopicNum<TopicNum&&(TopicHdr->NextTopicNum==-1||TopicHdr->NextTopicNum>TopicNum))
                        {
                            LinkBrowse(TopicNum,TopicNum,TopicHdr->NextTopicNum,TopicHdr->PrevTopicNum);
                        }
                    }
                }
                else
                {
                    TOPICHEADER *TopicHdr;

                    TopicHdr=(TOPICHEADER *)LinkData1;
                    if(resolvebrowse)
                    {
                        if(TopicHdr->BrowseFor>CurrentTopicOffset&&TopicHdr->BrowseBck>CurrentTopicOffset
                        || TopicHdr->BrowseFor==-1L&&TopicHdr->BrowseBck>CurrentTopicOffset
                        || TopicHdr->BrowseFor>CurrentTopicOffset&&TopicHdr->BrowseBck==-1L)
                        {
                            AddBrowse(CurrentTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                        }
                        else if(TopicHdr->BrowseFor!=-1L&&TopicHdr->BrowseFor<CurrentTopicOffset&&TopicHdr->BrowseBck!=-1L&&TopicHdr->BrowseBck<CurrentTopicOffset)
                        {
                            MergeBrowse(CurrentTopicOffset,ActualTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                        }
                        else if(TopicHdr->BrowseFor!=-1L&&TopicHdr->BrowseFor<CurrentTopicOffset&&(TopicHdr->BrowseBck==-1L||TopicHdr->BrowseBck>CurrentTopicOffset))
                        {
                            BackLinkBrowse(CurrentTopicOffset,ActualTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                        }
                        else if(TopicHdr->BrowseBck!=-1L&&TopicHdr->BrowseBck<CurrentTopicOffset&&(TopicHdr->BrowseFor==-1L||TopicHdr->BrowseFor>CurrentTopicOffset))
                        {
                            LinkBrowse(CurrentTopicOffset,ActualTopicOffset,TopicHdr->BrowseFor,TopicHdr->BrowseBck);
                        }
                    }
                    if(extractmacros)
                    {
                        if(TopicLink.DataLen2>0)
                        {
                            int i,n;
                            char *end;

                            if(TopicLink.DataLen2<=TopicLink.BlockSize-TopicLink.DataLen1)
                            {
                                end=LinkData2+TopicLink.DataLen2;
                            }
                            else
                            {
                                char *q;

                                q=myMalloc(TopicLink.DataLen2+1);
                                end=StringPrint(LinkData2,TopicLink.BlockSize-TopicLink.DataLen1,q);
                                if(end>q+TopicLink.DataLen2)
                                {
                                    error("Phrase replacement delivers %u instead of %ld bytes\n",(unsigned int)(end-q),TopicLink.DataLen2);
                                }
                                free(LinkData2);
                                LinkData2=q;
                            }
                            *end='\0';
                            strcpy(TopicTitle,LinkData2);
                            for(i=strlen(LinkData2)+1;i<TopicLink.DataLen2;i+=n+1)
                            {
                                n=strlen(LinkData2+i); /* because CheckMacro destroys string */
                                CheckMacro(LinkData2+i);
                            }
                        }
                        else
                        {
                            strcpy(TopicTitle,"<< untitled topic >>");
                        }
                    }
                    ActualTopicOffset=CurrentTopicOffset;
                }
                TopicNum++;
            }
            else if(TopicLink.RecordType==TL_DISPLAY30||TopicLink.RecordType==TL_DISPLAY||TopicLink.RecordType==TL_TABLE)
            {
                int col,cols;
                char filename[20];
                unsigned short x1,x2,x3,x4;
                short y1;
                long l1;
                char *ptr;
                unsigned short bits;
                MFILE *f;

                ptr=scanlong(LinkData1,&l1);
                if(TopicLink.RecordType==TL_DISPLAY||TopicLink.RecordType==TL_TABLE)
                {
                    ptr=scanword(ptr,&x3);
                    if(!dontCount) CurrentTopicOffset+=x3;
                    ActualTopicOffset+=x3;
                }
                if(TopicLink.RecordType==TL_TABLE)
                {
                    cols=(unsigned char)*ptr++;
                    x4=(unsigned char)*ptr++;
                    switch(x4)
                    {
                    case 0: /* found in CALC.HLP and TERMINAL.HLP */
                    case 2:
                        ptr+=2;
                    case 1:
                    case 3:
                        break;
                    default:
                        error("\nunknown column modifier %02x found\n",x4);
                    }
                    ptr+=4*cols;
                }
                for(col=0;(TopicLink.RecordType==TL_TABLE?*(short *)ptr!=-1:col==0)&&ptr<LinkData1+TopicLink.DataLen1-sizeof(TOPICLINK);col++)
                {
                    if(TopicLink.RecordType==TL_TABLE) ptr+=5;
                    ptr+=4;
                    bits=*(unsigned short *)ptr;
                    ptr+=2;
                    if(bits&0x0001) ptr=scanlong(ptr,&l1); /* found in MSDNCD9.MVB, purpose unknown */
                    if(bits&0x0002) ptr=scanint(ptr,&y1);
                    if(bits&0x0004) ptr=scanint(ptr,&y1);
                    if(bits&0x0008) ptr=scanint(ptr,&y1);
                    if(bits&0x0010) ptr=scanint(ptr,&y1);
                    if(bits&0x0020) ptr=scanint(ptr,&y1);
                    if(bits&0x0040) ptr=scanint(ptr,&y1);
                    if(bits&0x0100) ptr+=3;
                    if(bits&0x0200)
                    {
                        ptr=scanint(ptr,&y1);
                        while(y1-->0)
                        {
                            ptr=scanword(ptr,&x1);
                            if(x1&0x4000) ptr=scanword(ptr,&x2);
                        }
                    }
                    while(ptr<LinkData1+TopicLink.DataLen1-sizeof(TOPICLINK))
                    {
                        if((unsigned char)ptr[0]==0xFF)
                        {
                            ptr++;
                            break;
                        }
                        else switch((unsigned char)ptr[0])
                        {
                        case 0x21: /* dtype (MVB) */
                        case 0x80: /* font change */
                            ptr+=3;
                            break;
                        case 0x81:
                        case 0x82:
                        case 0x83:
                        case 0x89: /* end of hotspot */
                        case 0x8B: /* non-break-space */
                        case 0x8C: /* non-break-hyphen */
                            ptr++;
                            break;
                        case 0x86:
                        case 0x87:
                        case 0x88:
                            ptr++;
                            x1=*ptr++;
                            ptr=scanlong(ptr,&l1);
                            switch(x1)
                            {
                            case 0x22: /* HC31 */
                                ptr=scanword(ptr,&x1);
                                /* fall thru */
                            case 0x03: /* HC30 */
                                switch(((unsigned short *)ptr)[0])
                                {
                                case 1:
                                    for(x2=1;x2<extensions;x2++) if(!extension[x2]) break;
                                    if(x2>=extensions)
                                    {
                                        extension=myReAlloc(extension,(x2+1)*sizeof(char));
                                        while(extensions<=x2) extension[extensions++]=0;
                                    }
                                    sprintf(filename,"bm%u",x2);
                                    f=CreateMap(ptr+2,l1-2);
                                    x1=ExtractBitmap(filename,f);
                                    CloseMap(f);
                                    extension[x2]=x1|0x10;
                                    break;
                                }
                                break;
                            case 0x05:
                                if(ptr[6]=='!'&&strchr(ptr+7,','))
                                {
                                    CheckMacro(strchr(ptr+7,',')+1);
                                }
                                break;
                            }
                            ptr+=l1;
                            break;
                        case 0xC8: /* macro */
                        case 0xCC: /* macro without font change */
                            CheckMacro(ptr+3);
                            ptr+=*(short *)(ptr+1)+3;
                            break;
                        case 0x20: /* vfld (MVC) */
                        case 0xE0: /* popup jump HC30 */
                        case 0xE1: /* topic jump HC30 */
                        case 0xE2: /* popup jump HC31 */
                        case 0xE3: /* jump jump HC31 */
                        case 0xE6: /* popup jump without font change */
                        case 0xE7: /* jump jump without font change */
                            ptr+=5;
                            break;
                        case 0xEA: /* popup jump into external file */
                        case 0xEB: /* topic jump into external file / secondary window */
                        case 0xEE: /* popup jump into external file without font change */
                        case 0xEF: /* topic jump into external file / secondary window without font change */
                            switch((unsigned char)ptr[3])
                            {
                            case 0:
                            case 1:
                                break;
                            case 4:
                                CheckExternal(ptr+8,TOPIC,NULL,*(long *)(ptr+4));
                                break;
                            case 6:
                                CheckExternal(strchr(ptr+8,'\0')+1,TOPIC,NULL,*(long *)(ptr+4));
                                break;
                            default:
                                error("Unknown modifier %02x in tag %02x\n",(unsigned char)ptr[3],(unsigned char)ptr[0]);
                            }
                            ptr+=*(short *)(ptr+1)+3;
                            break;
                        default:
                            fprintf(stderr,"%02x unknown",(unsigned char)ptr[0]);
                            ptr++;
                        }
                    }
                }
            }
            if(LinkData1) free(LinkData1);
            if(LinkData2) free(LinkData2);
            dontCount=FALSE;
            memcpy(&TopicLink,&NextTopicLink,sizeof(TopicLink));
        }
    }
    TopicFileStart=0L;
}

BOOL HelpDeCompile(FILE *HelpFile,char *dumpfile,int mode,char *exportname)
{
    char filename[81];
    long FileLength;
    FILE *rtf;
    FILE *hpj;
    int d;
    long topic;

    if(!SearchFile(HelpFile,NULL,&FileLength)) return FALSE;
    if(!dumpfile)
    {
        switch(mode)
        {
        case 0:
            SysLoad(HelpFile);
            fprintf(stderr,"Decompiling %s...\n",HelpFileTitle);
            if(before31)
            {
                ToMapLoad(HelpFile);
            }
            else
            {
                ContextLoad(HelpFile);
            }
            PhraseLoad(HelpFile);
            ExportBitmaps(HelpFile);
            fprintf(stderr,"Pass 1...\n");
            FirstPass(HelpFile); /* valid only after ExportBitmaps */
            putc('\n',stderr);
            _makepath(filename,NULL,NULL,name,mvp?".MVP":".HPJ");
            hpj=myFOpen(filename,"wt");
            if(hpj)
            {
                _makepath(filename,NULL,NULL,name,".ICO");
                SysList(HelpFile,hpj,filename);
                ListBaggage(HelpFile,hpj);
                AliasList(hpj); /* after ContextLoad, before TopicDump */
                _makepath(filename,NULL,NULL,name,".PH");
                PhraseList(filename); /* after PhraseLoad */
                _makepath(filename,NULL,NULL,name,".RTF");
                rtf=myFOpen(filename,"wt");
                if(rtf)
                {
                    fprintf(hpj,"[FILES]\n%s\n\n",filename);
                    fprintf(rtf,"{\\rtf1\\ansi \\deff0\n");
                    FontLoad(HelpFile,rtf,hpj);
                    fprintf(rtf,"{\\info{\\creatim\\yr1995\\mo2\\dy22\\hr2\\min22}{\\revtim\\yr1995\\mo2\\dy26\\hr22\\min24}{\\version9}{\\edmins0}{\\nofpages0}{\\nofwords0}{\\nofchars0}{\\vern16433}}\n"
                    "\\paperw11906\\paperh16838\\margl1417\\margr1417\\margt1417\\margb1134\\gutter0 \\deftab709\\widowctrl\\ftnbj\\hyphhotz425 \\sectd \\linex0\\headery709\\footery709\\colsx709\\endnhere \\pard\\plain \\fs20\\lang1031\n");
                    fprintf(stderr,"Pass 2...\n");
                    TopicDump(HelpFile,rtf,FALSE);
                    putc('}',rtf);
                    putc('\n',stderr);
                    myFClose(rtf);
                }
                NotInAnyTopic=FALSE;
                CTXOMAPList(HelpFile,hpj);
                if(extensions&&!win95) ListBitmaps(hpj);
                if(win95) ListRose(HelpFile,hpj);
                myFClose(hpj);
            }
            if(win95)
            {
                if(Offsets||NewOffsets) printf("Help Compiler will issue Note HC1002: Using existing phrase table\n");
            }
            else
            {
                if(Offsets||NewOffsets) printf("Help Compiler will issue Warning 5098: Using old key-phrase table\n");
            }
            if(missing) printf("Help Compiler will issue Error 1230: File 'missing.bmp' not found\n");
            if(NotInAnyTopic) printf("Help Compiler will issue Warning 4098: Context string(s) in [MAP] section not defined in any topic\n");
            if(!extractmacros) printf("Help Compiler may issue Warning 4131: Hash conflict between 'x' and 'y'.\n");
            if(warnings)
            {
                _makepath(filename,drive,dir,name,ext);
                printf("HELPDECO had problems with %s. Rebuilt helpfile may behave bad.\n",filename);
            }
            if(helpcomp[0])
            {
                _makepath(filename,NULL,NULL,name,mvp?".MVP":".HPJ");
                if(win95&&SearchFile(HelpFile,"|Petra",NULL)) strcat(helpcomp," /a");
                printf("Use %s %s to recompile %shelpfile.\n",helpcomp,filename,AnnoFile?"annotated ":"");
            }
            break;
        case 1:
            HexDump(HelpFile,FileLength);
            break;
        case 2:
            ListFiles(HelpFile);
            break;
        case 3:
            SysLoad(HelpFile);
            exportplain=TRUE;
            ExportBitmaps(HelpFile);
            PhraseLoad(HelpFile);
            _makepath(filename,NULL,NULL,name,".RTF");
            rtf=myFOpen(filename,"wt");
            if(rtf)
            {
                fprintf(rtf,"{\\rtf1\\ansi \\deff0\n");
                FontLoad(HelpFile,rtf,NULL);
                fprintf(rtf,"{\\info{\\creatim\\yr1995\\mo2\\dy22\\hr2\\min22}{\\revtim\\yr1995\\mo2\\dy26\\hr22\\min24}{\\version9}{\\edmins0}{\\nofpages0}{\\nofwords0}{\\nofchars0}{\\vern16433}}\n"
                "\\paperw11906\\paperh16838\\margl1417\\margr1417\\margt1417\\margb1134\\gutter0 \\deftab709\\widowctrl\\ftnbj\\hyphhotz425 \\sectd \\linex0\\headery709\\footery709\\colsx709\\endnhere \\pard\\plain \\fs20\\lang1031\n");
                TopicDump(HelpFile,rtf,TRUE);
                putc('}',rtf);
                putc('\n',stderr);
                myFClose(rtf);
            }
            break;
        case 4:
            SysLoad(HelpFile);
            if(before31)
            {
                ToMapLoad(HelpFile);
            }
            else
            {
                ContextLoad(HelpFile);
            }
            PhraseLoad(HelpFile);
            fprintf(stderr,"Scanning %s...\n",HelpFileTitle);
            checkexternal=TRUE;
            ExportBitmaps(HelpFile);
            FirstPass(HelpFile);
            putc('\n',stderr);
            _makepath(filename,NULL,NULL,name,".CNT");
            rtf=myFOpen(filename,"wt");
            if(rtf)
            {
                GenerateContent(HelpFile,rtf);
                myFClose(rtf);
            }
            break;
        case 6: /* check external references */
        case 7:
            resolvebrowse=FALSE;
            checkexternal=TRUE;
            SysLoad(HelpFile);
            fprintf(stderr,"Checking %s...\n",HelpFileTitle);
            PhraseLoad(HelpFile);
            FirstPass(HelpFile);
            putc('\n',stderr);
            if(!external)
            {
                _makepath(filename,drive,dir,name,ext);
                printf("No references to external files found in %s.\n",filename);
            }
            else if(mode==6)
            {
                CheckReferences();
            }
            else
            {
                ListReferences();
            }
            break;
        }
    }
    else
    {
        if(!SearchFile(HelpFile,dumpfile,&FileLength))
        {
            filename[0]='|';
            strcpy(filename+1,dumpfile);
            if(!SearchFile(HelpFile,filename,&FileLength))
            {
                fprintf(stderr,"Internal file %s not found.\n",dumpfile);
                return TRUE;
            }
            dumpfile=filename;
        }
        printf("FileName: %s FileSize: %ld\n",dumpfile,FileLength);
        if(exportname) /* export internal file */
        {
            FILE *f;

            f=myFOpen(exportname,"wb");
            if(f)
            {
                copy(HelpFile,FileLength,f);
                myFClose(f);
            }
        }
        else if(mode==1)
        {
            HexDump(HelpFile,FileLength);
        }
#ifdef _WIN32
        else if(strcmp(dumpfile,"|TOPIC")==0)
        {
            SysLoad(HelpFile);
            PhraseLoad(HelpFile);
            DumpTopic(HelpFile);
        }
#endif
        else if(strcmp(dumpfile+strlen(dumpfile)-4,".GRP")==0)
        {
            GroupDump(HelpFile);
        }
        else if(strcmp(dumpfile,"@LINK")==0)
        {
            LinkDump(HelpFile);
        }
        else if(sscanf(dumpfile,"%ld!%d",&topic,&d)==2&&topic!=0L&&d==0)
        {
            AnnotationDump(HelpFile,FileLength,dumpfile);
        }
        else if(strcmp(dumpfile,"|Phrases")==0||strcmp(dumpfile,"|PhrIndex")==0)
        {
            SysLoad(HelpFile);
            PhraseLoad(HelpFile);
            PhraseDump();
        }
        else if(strcmp(dumpfile,"|SYSTEM")==0)
        {
            SysDump(HelpFile);
        }
        else if(strcmp(dumpfile,"|TOMAP")==0)
        {
            ToMapDump(HelpFile,FileLength);
        }
        else if(strcmp(dumpfile,"|CONTEXT")==0)
        {
            BTreeDump(HelpFile,"HashValue: 0x%08lx TopicOffset: 0x%08lx\n");
        }
        else if(dumpfile[0]=='|'&&(strcmp(dumpfile+2,"WBTREE")==0||strcmp(dumpfile+2,"KWBTREE")==0))
        {
            BTreeDump(HelpFile,"Keyword: %s Count: %u KWDataAddress: 0x%08lx\n");
        }
        else if(dumpfile[0]=='|'&&(strcmp(dumpfile+2,"WMAP")==0||strcmp(dumpfile+2,"KWMAP")==0))
        {
            KWMapDump(HelpFile);
        }
        else if(dumpfile[0]=='|'&&(strcmp(dumpfile+2,"WDATA")==0||strcmp(dumpfile+2,"KWDATA")==0))
        {
            KWDataDump(HelpFile,FileLength);
        }
        else if(strcmp(dumpfile,"|VIOLA")==0)
        {
            BTreeDump(HelpFile,"TopicOffset: 0x%08lx WindowNumber: %ld\n");
        }
        else if(strcmp(dumpfile,"|CTXOMAP")==0)
        {
            CTXOMAPDump(HelpFile);
        }
        else if(strcmp(dumpfile,"|CATALOG")==0)
        {
            CatalogDump(HelpFile);
        }
        else if(strcmp(dumpfile,"|Petra")==0)
        {
            BTreeDump(HelpFile,"TopicOffset: 0x%08lx SourceFileName: %s\n");
        }
        else if(strcmp(dumpfile,"|TopicId")==0)
        {
            BTreeDump(HelpFile,"TopicOffset: 0x%08lx ContextId: %s\n");
        }
        else if(strcmp(dumpfile,"|Rose")==0)
        {
            BTreeDump(HelpFile,"KeywordHashValue: 0x%08lx\nMacro: %s\nTitle: %s\n");
        }
        else if(strcmp(dumpfile,"|TTLBTREE")==0)
        {
            BTreeDump(HelpFile,"TopicOffset: 0x%08lx TopicTitle: %s\n");
        }
        else if(strcmp(dumpfile,"|FONT")==0)
        {
            FontDump(HelpFile);
        }
        else
        {
            topic=ftell(HelpFile);
            if(myGetW(HelpFile)==0x293B)
            {
                myGetW(HelpFile);
                myGetW(HelpFile);
                filename[0]='\0';
                while((d=getc(HelpFile))>0)
                {
                    switch(d)
                    {
                    case 'L':
                    case '4':
                        strcat(filename,"0x%08lx ");
                        break;
                    case '2':
                        strcat(filename,"%5u ");
                        break;
                    case 'F':
                    case 'i':
                    case 'z':
                        strcat(filename,"'%s' ");
                        break;
                    default:
                        error("Unknown Btree field type '%c'\n",d);
                    }
                }
                strcat(filename,"\n");
                fseek(HelpFile,topic,SEEK_SET);
                BTreeDump(HelpFile,filename);
            }
            else
            {
                fseek(HelpFile,topic,SEEK_SET);
	        HexDump(HelpFile,FileLength);
            }
        }
    }
    return TRUE;
}

int main(int argc,char *argv[])
{
    char AnnoFileName[81];
    char HelpFileName[81];
    FILE *f;
    int mode;
    BOOL annotate;
    char *filename;
    char *dumpfile;
    char *exportname;
    int i;

    memset(table,0,sizeof(table));
    for(i=0;i<9;i++) table['1'+i]=i+1;
    table['0']=10;
    table['.']=12;
    table['_']=13;
    for(i=0;i<26;i++) table['A'+i]=table['a'+i]=17+i;
    exportname=dumpfile=filename=NULL;
    AnnoFileName[0]='\0';
    mode=0;
    annotate=FALSE;
    for(i=1;i<argc;i++)
    {
        if(argv[i][0]=='/'||argv[i][0]=='-') switch(tolower((unsigned char)argv[i][1]))
        {
        case 'f':
            listtopic=TRUE;
            break;
        case 'e':
            mode=7;
            break;
        case 'p':
            mode=6;
            break;
        case 'y':
            overwrite=TRUE;
            break;
        case 'c':
            mode=4;
            break;
        case 'x':
            mode=1;
            break;
        case 'd':
            mode=2;
            break;
        case 'r':
            mode=3;
            break;
        case 'a':
            if(argv[i][2])
            {
                strcpy(AnnoFileName,argv[i+1]+1);
            }
            else if(argv[i+1]&&argv[i+1][0]!='/'&&argv[i+1][0]!='-')
            {
                strcpy(AnnoFileName,argv[i+1]);
                i++;
            }
            annotate=TRUE;
            break;
        case 'w':
            warn=TRUE;
            break;
        case 'm':
            extractmacros=FALSE;
            break;
        case 'b':
            resolvebrowse=FALSE;
            break;
        default:
            fprintf(stderr,"unknown option '%s' ignored\n",argv[i]);
        }
        else if(exportname)
        {
            fprintf(stderr,"additional parameter '%s' ignored\n",argv[i]);
        }
        else if(dumpfile)
        {
            exportname=argv[i];
        }
        else if(filename)
        {
            dumpfile=argv[i];
        }
        else
        {
            filename=argv[i];
        }
    }
    if(filename)
    {
        strupr(filename);
        _splitpath(filename,drive,dir,name,ext);
        if(ext[0]=='\0') strcpy(ext,".HLP");
        mvp=ext[1]=='M';
        _makepath(HelpFileName,drive,dir,name,ext);
        f=fopen(HelpFileName,"rb");
        if(f)
        {
            if(((MFILE *)f)->magic==MAGIC)
            {
                fprintf(stderr,"Error opening '%s'\n",HelpFileName);
            }
            else
            {
                if(annotate)
                {
                    if(AnnoFileName[0]=='\0') _makepath(AnnoFileName,drive,dir,name,".ANN");
                    AnnoFile=fopen(AnnoFileName,"rb");
                    if(!AnnoFile)
                    {
                        fprintf(stderr,"Couldn't find annotation file '%s'\n",AnnoFileName);
                    }
                }
                if(!HelpDeCompile(f,dumpfile,mode,exportname))
                {
                    fprintf(stderr,"%s isn't a valid WinHelp file !\n",HelpFileName);
                }
                if(annotate&&AnnoFile) fclose(AnnoFile);
            }
            myFClose(f);
        }
        else
        {
            fprintf(stderr,"Can not open '%s'\n",HelpFileName);
        }
    }
    else
    {
        fprintf(stderr,"HELPDECO - decompile *.HLP/*.MVB files of Windows 3.x / 95 - %d bit Version 1.8\n"
                       "M.Winterhoff, Geschw.-Scholl-Ring 17, 38444 Wolfsburg, Germany, CIS 100326,2776\n"
                       "\n"
                       "usage:   HELPDECO helpfile[.hlp]    [/y]  - decompile helpfile into all sources\n"
                       "         HELPDECO helpfile[.hlp]    [/y] /a[annfile.ANN]  - and add annotations\n"
                       "         HELPDECO helpfile[.hlp] /r [/y]  - decompile into lookalike RTF\n"
                       "         HELPDECO helpfile[.hlp] /c [/y]  - generate Win95 content (*.CNT) file\n"
                       "         HELPDECO helpfile[.hlp] /e [/f]  - list references to other helpfiles\n"
                       "         HELPDECO helpfile[.hlp] /p [/f]  - check references to other helpfiles\n"
                       "         HELPDECO helpfile[.hlp] /d [/x]  - display internal directory\n"
                       "         HELPDECO helpfile[.hlp] \"internalfile\" [/x]    - display internal file\n"
                       "         HELPDECO helpfile[.hlp] \"internalfile\" filename - export internal file\n"
                       "options: /y overwrite without warning, /f list referencing topics, /x hex dump\n"
                       "\n"
                       "To recreate all source files neccessary to rebuild a Windows helpfile, create\n"
                       "a directory, change to this directory and call HELPDECO with the path and name\n"
                       "of the helpfile to dissect. HELPDECO will extract all files contained in the\n"
                       "helpfile in two passes and deposit them in the current directory. You may then\n"
                       "rebuild the helpfile using the appropriate help compiler HC30, HC31, HCP, HCW,\n"
                       "HCRTF, MVC, WMVC or MVCC. The file will not be identical, but should look and\n"
                       "work like the original.",sizeof(int)*8);
#ifndef _WIN32
                       printf(" Launch from Win95/WinNT to handle larger helpfiles.");
#endif
                       printf("\nThis program is public domain. Use at your own risk. No part of it may be used\n"
                       "commercially. No fees may be charged on copying.\n");
    }
    return 0;
}
