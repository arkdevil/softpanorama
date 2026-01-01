#ifndef fallthrough		/* "fallthrough" is in opus.h */
typedef unsigned    char    byte;
typedef unsigned    int     word;
#endif


/****** General purpose Symbolic constants:  *********/
#define TRUE	1		/* general purpose true truth value */
#define FALSE	0		/* general purpose false truth value */
#define ERROR	-1		/* General "on error" return value */
#define OK	0		/* General "no error" return value */
#define EOS	'\0'		/* standard end of string */

#define MAX_PATH    78		/* max. length of full pathname		*/
#define MAX_DIR     66		/* max. length of full directory name	*/

#define FOSSIL      0x0001		/* running remotely */
#define MORE        0x0002		/* User wants More? prompts */
#define WANTS_MORE  0x0004		/* User has more in User.BBS */
#define VIEW        0x0008		/* View text files inside archive */
#define	WATCH	    0x0010		/* Use FOSSIL watchdog */

#define ARC         0x1000		/* ARC/PAK file */
#define ZIP         0x2000		/* PKZIP file */
#define ZOO         0x4000		/* ZOO File */
#define DWC         0x8000		/* DWC File */
#define ARJ         0x0200		/* ARJ File */
/*----------------------------------------------------------------------*/
/*		 Information for file date conversion			*/
/*----------------------------------------------------------------------*/
#define MONTH_SHIFT     5
#define MONTH_MASK      0x0F
#define DAY_MASK	0x1F
#define YEAR_SHIFT      9
#define DOS_EPOCH       80
#define HOUR_SHIFT      11
#define HOUR_MASK       0x1F
#define MINUTE_SHIFT    5
#define MINUTE_MASK     0x3F


/*----------------------------------------------------------------------*/
/*			  archive list junk				*/
/*----------------------------------------------------------------------*/
#define ARCMARK 26	/* special archive marker */
#define ARCVER 10	/* highest compression code used */

#pragma pack(1)		/* req'd by MSC to keep struct byte aligned */ 
struct heads		/* archive entry header format */
{   
    char mbrname[13];	/* file name */
    long mbrsize;	/* size of file in archive, bytes */
    unsigned mbrdate;	/* creation date */
    unsigned mbrtime;	/* creation time */
    int mbrcrc;		/* cyclic redundancy check */
    long mbrlen;	/* true file size, bytes */
};
#pragma pack()		/* we now return to our regular programming */


/*--------------------------------------------------------------------------*/
/* Garbage for ZOO listing                                                  */
/*--------------------------------------------------------------------------*/

#define MAJOR_VER 1        /* needed to manipulate archive */
#define MINOR_VER 4

#define MAJOR_EXT_VER 1    /* needed to extract file */
#define MINOR_EXT_VER 0

#define CTRL_Z 26
#define ZOO_TAG ((unsigned long) 0xFDC4A7DC) /* A random choice */
#define TEXT "ZOO 1.50 Archive.\032"   /* Header text for archive. */
#define SIZ_TEXT  20                   /* Size of header text */

#define PATHSIZE 256                   /* Max length of pathname */
#define FNAMESIZE 13                   /* Size of DOS filename */
#define LFNAMESIZE 256                 /* Size of long filename */
#define ROOTSIZE 8                     /* Size of fname without extension */
#define EXTLEN 3                       /* Size of extension */
#define FILE_LEADER  "@)#("            /* Allowing location of file data */
#define SIZ_FLDR  5                    /* 4 chars plus null */
#define MAX_PACK 1                     /* max packing method we can handle */
#define BACKUP_EXT ".bak"              /* extension of backup file */

#ifdef OOZ
#define FIRST_ARG 2
#endif

#ifdef ZOO
#define FIRST_ARG 3        /* argument position of filename list */
#endif

/* WARNING:  Static initialization in zooadd.c or zooext.c depends on the 
   order of fields in struct zoo_header */
struct zoo_header {
   char text[SIZ_TEXT];       /* archive header text */
   unsigned long zoo_tag;     /* identifies archives           */
   long zoo_start;            /* where the archive's data starts        */
   long zoo_minus;      /* for consistency checking of zoo_start  */
   char major_ver;
   char minor_ver;            /* minimum version to extract all files   */
};

/* Note:  Microsoft C aligns data at word boundaries.  So, to keep things
   compact, always try to pair up character fields. */
struct direntry {
   unsigned long zoo_tag;     /* tag -- redundancy check */
   char type;                 /* type of directory entry.  always 1 for now */
   char packing_method;       /* 0 = no packing, 1 = normal LZW */
   long next;                 /* pos'n of next directory entry */
   long offset;               /* position of this file */
   unsigned int date;         /* DOS format date */
   unsigned int time;         /* DOS format time */
   unsigned int file_crc;     /* CRC of this file */
   long org_size;
   long size_now;
   char major_ver;
   char minor_ver;            /* minimum version needed to extract */
   char deleted;              /* will be 1 if deleted, 0 if not */
   char struc;                /* file structure if any */
   long comment;              /* points to comment;  zero if none */
   unsigned int cmt_size; /* length of comment, 0 if none */
   char fname[FNAMESIZE]; /* filename */

   int var_dir_len;           /* length of variable part of dir entry */
   char tz;                   /* timezone where file was archived */
   unsigned int dir_crc;      /* CRC of directory entry */

   /* fields for variable part of directory entry follow */
   char namlen;               /* length of long filename */
   char dirlen;               /* length of directory name */
   char lfname[LFNAMESIZE];   /* long filename */
   char dirname[PATHSIZE];    /* directory name */
   int system_id;             /* Filesystem ID */
};

/* Values for direntry.system_id */
#define SYSID_NIX       0     /* UNIX and similar filesystems */
#define SYSID_MS        1     /* MS-DOS filesystem */
#define SYSID_PORTABLE  2     /* Portable syntax */

/*-End of Zoo stuff---------------------------------------------------------*/
/*-Start of DWC stuff-------------------------------------------------------*/
#pragma pack(1)		/* req'd by MSC to keep struct byte aligned	*/ 

/* ENTRY - information that is stored for each file in the DWC archive.      */

struct dwc_entry {
   char     name[13];      /* ... File name, Note: path is not saved here    */
   long     size;          /* ... Size of file before compression in bytes   */
   long     time;          /* ... Time stamp on file before added to archive */
   long     new_size;      /* ... Size of compressed file                    */
   long     pos;           /* ... Position of file in archive file           */
   char     method;        /* ... Method of compression used on file         */
   char     sz_c;          /* ... Size of comment added to file              */
   char     sz_d;          /* ... Size of directory name recorded on add     */
   unsigned crc;           /* ... CRC value computed for this file           */
};

/* ARCHIVE - information that is stored at the end of every achive.          */

struct dwc_arc {
   unsigned size;          /* ... Size of archive structure, future expansion*/
   char     ent_sz;        /* ... Size of directory entry, future expansion  */
   char     header[13];    /* ... Name of Header file to print on listings   */
   long     time;          /* ... Time stamp of last modification to archive */
   long     entries;       /* ... Number of entries in archive               */
   char     id[3];         /* ... the string "DWC" to identify archive       */
};
#pragma pack()
/*-End of DWC stuff---------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* PKZIP (Phil Katz)                                                        */
/*--------------------------------------------------------------------------*/

struct ID_Hdr {
    word    PK_ID;		/* Always = PK = 0x4B50  */
    word    Head_Type;		/* Identifiles which type of header this is */
};

#define     LOCAL_HEADER    0x0403		/* PK local header 0x04034B50 */
#define     CENTRAL_DIR     0x0201		/* "Central header"towards end of file */
#define     CENTRAL_REC     0x0605		/* Last header in file */

struct Local_Hdr {
    word    extract_ver;	/* check program ver needed to unpack */
    word    GP_flags;		/* General purpose flags, see below */
    word    compression;	/* Compression method */
    word    mod_time;		/* Modification time */
    word    mod_date;		/* Modification date */
    long    crc;		    /* File's CRC */
    long    size_now;   	/* compressed size */
    long    real_size;		/* un-compressed file size */
    word    name_length;		/* FileName length */
    word    Xfield_length;		/* Extra field length */
};

/* Filename follows, no null terminator! */
/* Extra field, no null terminator. */

/*--------------------------------------------------------------------------*/
/* Flags used with extract_ver                                              */
/*--------------------------------------------------------------------------*/
#define     IBM     0x0001		/* MS-DOS version of PKZIP */
#define     AMIGA   0x0002		/* Amiga version of PKZIP */
#define     VMS     0x0004		/* VMS version of PKZIP */
#define     UNIX    0x0008		/* UNIX version of PKZIP (C) Bell Labs */

/*--------------------------------------------------------------------------*/
/* Flags used with general purpose flags                                    */
/*--------------------------------------------------------------------------*/
#define     ENCRYPT 0x0001		/* File is encrypted */
  
struct  Central_File {
    word    extract_ver;	/* check program ver needed to unpack */
    word    GP_flags;		/* General purpose flags, see below */
    word    compression;	/* Compression method */
    word    mod_time;		/* Modification time */
    word    mod_date;		/* Modification date */
    long    crc;		    /* File's CRC */
    long    size_now;   	/* compressed size */
    long    real_size;		/* un-compressed file size */
    word    name_length;		/* FileName length */
    word    Xfield_length;		/* Extra field length */
    word    comment_length;		/* File comment length */
    word    disk_start;		/* "Number of disk on which this file begins" */
    word    int_attrib;		/* See internal flags below */
    long    ext_attrib;		/* file's original attributes */
    long    rel_offset;		/* Offset from start of disk/ZIP to local header */
};
/* File Name    */
/* Extra Field  */
/* Comment      */

/*--------------------------------------------------------------------------*/
/* Internal Flags                                                           */
/*--------------------------------------------------------------------------*/
 
#define     IS_TEXT     0x0001		/* This file is probably text */

struct  Central_Directory {
    word    disk_number;		/* Number of this disk */
    word    center_disk;		/* Number of disk where Central Dir starts */
    word    total_disk;		    /* Total # of entries on this disk */
    word    total_entry;		/* Total # of files in this Zipfile */
    long    central_size;		/* Size of the entire central directory */
    long    start_offset;		/*  */
    word    zip_cmnt_len;		/* Length of comment for entire file */
};

/* Zipfile comment */

/*--------------------------------------------------------------------------*/
/* LHARC                                                                    */
/*--------------------------------------------------------------------------*/

struct dostime {
   word    time;
   word    date;
};

union _orig {
   struct  dostime  dtime;
   long utc;
};

#pragma pack(1)
struct Lharc_Hdr {
    int     size_header;		/* No. bytes in header - 2 (0 = EOF) */
    char    type[5];		/* Compression type, no NULL terminator! */
    long    size_now;		/* Size of compressed file */
	long    orig_size;		/* Original size of file */
   union   _orig   orig;
    byte    attrib;		/* file attribute */
    byte    level;
};
/*  char    file_name;   Not terminated!                                                   */
/*  char    crc_char[2]; */


/*----------------------------------------------------------------------*/
/* COLORS for BIOS display                                              */
/*----------------------------------------------------------------------*/
#define	BLUE		1
#define	GREEN		2
#define	RED		    4
#define	INTENSE		8
#define	BLUE_BACK	16
#define GREEN_BACK	32
#define RED_BACK	64
#define BLINK		128
#define CYAN        BLUE|GREEN
#define MAGENTA     BLUE|RED
#define YELLOW      RED|GREEN
#define WHITE       RED|GREEN|BLUE
#define WHITE_BACK  BLUE_BACK|RED_BACK|GREEN_BACK

#define REG         WHITE
#define REV         WHITE_BACK
#define BRIGHT      INTENSE|WHITE


#define FOSSIL_INT   0x14
 
/*---------------------------------------------------------------------*/
/* comm fossil line and modem status in AX.  Status bits returned are: */
/*---------------------------------------------------------------------*/
                     /* In AH: */
#define RDA  0x0100  /* input data is available in buffer */
#define OVRN 0x0200  /* the input buffer has been overrun */
#define THRE 0x2000  /* room is available in output buffer */
#define TSRE 0x4000  /* output buffer is empty */
                     /* In AL: */
#define FRDY 0x0008  /* fossil ready - Always 1 */
#define DCD  0x0080  /* carrier detect */


/* StuffIt.h: contains declarations for SIT headers */

typedef struct sitHdr {       /* 22 bytes */
	char  signature[4];     /* = 'SIT!' -- for verification */
   unsigned short numFiles;   /* number of files in archive */
   unsigned long  arcLength;  /* length of entire archive incl.
                  hdr. -- for verification */
	char  signature2[4];    /* = 'rLau' -- for verification */
   unsigned char  version; /* version number */
   char reserved[7];
};

typedef struct fileHdr {      /* 112 bytes */
   unsigned char  compRMethod;   /* rsrc fork compression method */
   unsigned char  compDMethod;   /* data fork compression method */
   unsigned char  fName[64];  /* a STR63 */
	char   fType[4];         /* file type */
	char   fCreator[4];      /* er... */
   short FndrFlags;     /* copy of Finder flags.  For our
                  purposes, we can clear:
                  busy,onDesk */
   unsigned long  creationDate;
   unsigned long  modDate; /* !restored-compat w/backup prgms */
   unsigned long  rsrcLength; /* decompressed lengths */
   unsigned long  dataLength;
   unsigned long  compRLength;   /* compressed lengths */
   unsigned long  compDLength;
   unsigned short rsrcCRC;    /* crc of rsrc fork */
   unsigned short dataCRC;    /* crc of data fork */
   char reserved[6];
   unsigned short hdrCRC;     /* crc of file header */
};


/* file format is:
   sitArchiveHdr
      file1Hdr
         file1RsrcFork
         file1DataFork
      file2Hdr
         file2RsrcFork
         file2DataFork
      .
      .
      .
      fileNHdr
         fileNRsrcFork
         fileNDataFork
*/



/* compression methods */
#define noComp    0  /* just read each byte and write it to archive */
#define repComp 1 /* RLE compression */
#define lpzComp 2 /* LZW compression */
#define hufComp 3 /* Huffman compression */

/* all other numbers are reserved */


struct _ARJ_stamp {
   word    time;
   word    date;
}; 

struct _ARJ_main {
   word    base_size;
   byte    first_size;
   byte    arc_vers;
   byte    min_vers;
   byte    host_OS;
   byte    arj_flag;
   byte    method;
   byte    type;
   byte    reserved;
   struct  _ARJ_stamp stamp; 
/*   long    stamp; */
   long    c_size;
   long    o_size;
   long    crc;
   word    pos;
   word    mode;
   word    host_data;		/* 34 bytes */
};

