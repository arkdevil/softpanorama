/* ReSizeable RAMDisk - srdisk header file
** Copyright (c) 1992 Marko Kohtala
*/

#ifndef _SRDISK_H
#define _SRDISK_H

/* Byte aligned compilation is a must */
#pragma option -a-
#pragma pack(1)

#define VERSION "1.42"

#define MAX_CHAINED_DRIVERS 5

#include <stdlib.h>
#include <time.h>       /* Only for DOS_time declaration */

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned long dword;

#define MULTIPLEXAH 0x72
#define V_FORMAT 0      /* config_s structure format version used here */

#define C_APPENDED  1   /* Capable of having appended drivers */
#define C_MULTIPLE  2   /* Capable of driving many disks */
#define C_32BITSEC  4   /* Capable of handling over 32-bit sector addresses */
#define C_NOALLOC   8   /* Incapable of allocating it's owm memory */
#define C_UNKNOWN 0xF0

#define READ_ACCESS  1  /* Bit masks for RW_access in IOCTL_msg_s */
#define WRITE_ACCESS 2


/* Configuration structure internal to device driver (byte aligned) */
struct dev_hdr {
  struct dev_hdr far *next;
  word attr;
  word strategy;
  word commands;
  byte units;
  union {
    char volume[12];            /* Volume label combined of fields below */
    struct {
      char ID[3];               /* Identification string 'SRD' */
      char memory[4];           /* Memory type string */
      char version[4];          /* Device driver version string */
      char null;
    } s;
  } u;
  byte v_format;                /* Config_s format version */
  struct config_s near *conf;   /* Offset to config_s */
};

struct config_s {               /* The whole structure */
  byte drive;                   /* Drive letter of this driver */
  byte flags;                   /* Capability flags */
  word (far *disk_IO)(void);    /* Disk I/O routine entry */
  dword (near *malloc_off)(dword _s); /* Memory allocation routine entry offset */
  struct dev_hdr _seg *next;    /* Next chained driver */
  dword maxK;                   /* Maximum memory allowed for disk */
  dword size;                   /* Current size in Kbytes */
  dword sectors;                /* Total sectors in this part of the disk */

  word BPB_bps;                 /* BPB - bytes per sector */
  /* The rest is removed from chained drivers, used only in the main driver */
  byte BPB_spc;                 /* BPB - sectors per cluster */
  word BPB_reserved;            /* BPB - reserved sectors in the beginning */
  byte BPB_FATs;                /* BPB - number of FATs on disk */
  word BPB_dir;                 /* BPB - root directory entries */
  word BPB_sectors;             /* BPB - sectors on disk (16-bit) */
  byte BPB_media;               /* BPB - identifies the media (default 0xFA) */
  word BPB_FATsectors;          /* BPB - sectors per FAT */
  word BPB_spt;                 /* BPB - sectors per track (imaginary) */
  word BPB_heads;               /* BPB - heads (imaginary) */
  dword BPB_hidden;             /* BPB - hidden sectors */
  dword BPB_tsectors;           /* BPB - sectors on disk (32-bit) */

  dword tsize;                  /* Total size for the disk */

  byte RW_access;               /* b0 = enable, b1 = write */
  signed char media_change;     /* -1 if media changed, 1 if not */
  word open_files;              /* Number of open files on disk */
  struct dev_hdr _seg *next_drive;/* Next SRDISK drive */
};

extern struct config_s far *mainconf;
extern struct config_s far *conf;

#define WRITE_PROTECTION 1
#define DISK_SIZE 2
#define SECTOR_SIZE 4
#define CLUSTER_SIZE 8
#define DIR_ENTRIES 0x10
#define NO_OF_FATS 0x20
#define MAX_PART_SIZES 0x40
#define MEDIA 0x80
#define SEC_PER_TRACK 0x100
#define SIDES 0x200

/* format_f tells if a real reformat really needed */
#define format_f (changed_format & ( DISK_SIZE | SECTOR_SIZE \
  | CLUSTER_SIZE | DIR_ENTRIES | NO_OF_FATS | MAX_PART_SIZES | MEDIA \
  | SEC_PER_TRACK | SIDES))

struct format_s {                 /* Disk format/configuration description */
  /* User defined parameters */
  byte RW_access;               /* Read/write access flags */
  dword size;                   /* Defined current size */
  int bps;                      /* Bytes per sector */
  int cluster_size;             /* Size of one cluster in bytes */
  int FATs;                     /* Number of FAT copies */
  int dir_entries;              /* Directory entries in the root directory */
  byte media;                   /* Media */
  int sec_per_track;            /* Sectors per track */
  int sides;                    /* Sides on disk */
  struct subconf_s {            /* List of the drivers chained to this disk */
    dword maxK;                 /* The maximum size of this part */
    int userdef:1;              /* True if used defined new max size */
  } subconf[MAX_CHAINED_DRIVERS];
  /* Derived parameters */
  int chain_len;                /* Number of drivers chained to this drive */
  dword max_size;               /* Largest possible disk size (truth may be less) */
  dword current_size;           /* Counted current size from the driver chain */
  int reserved;                 /* Reserved sectors in the beginning (boot) */
  int spFAT;                    /* Sectors per FAT */
  dword sectors;                /* Total sectors on drive */
  int FAT_sectors;              /* Total FAT sectors */
  int dir_sectors;              /* Directory sectors */
  int dir_start;                /* First root directory sector */
  int system_sectors;           /* Boot, FAT and root dir sectors combined */
  long data_sectors;            /* Total number of usable data sectors */
  int spc;                      /* Sectors per cluster */
  dword clusters;               /* Total number of clusters */
  int FAT_type;                 /* Number of bits in one FAT entry (12 or 16) */
};

extern struct format_s f, newf;
extern int changed_format;

extern int root_files;  /* Number of files in root directory */

/* Variables possibly supplied in command line */
extern char drive;          /* Drive letter of drive to format */
extern int force_f;         /* Nonzero if ok to format */
extern int use_old_format_f; /* Take undefined parameters from the old format */
extern int f_set_env;       /* Set environment variables */
extern int verbose;   /* Verbose: 1 banner, */
                      /* 2 + new format, 3 + old format, 4 + long format */

/*
**  Declarations
*/

extern int max_bps;     /* Maximum sector size allowed on system */

void parse_cmdline(int, char *[]);
void print_syntax(void);
void set_write_protect(void);

/*  Error handling functions */
void syntax(char *err);
void fatal(char *err);
void error(char *err);
void warning(char *err);

/* Utility */
void *xalloc(size_t s);
struct config_s far *conf_ptr(struct dev_hdr _seg *dev);
int getYN(void);
dword DOS_time(time_t);

/* Environment */
void set_env(void);

/* disk I/O module */
int read_sector(int count, dword start, void *buffer);
int write_sector(int count, dword start, void *buffer);
dword disk_alloc(struct config_s far *conf, dword size);

/* Disk Initialization module */
void init_drive(void);

/* Format module */
void format_disk(void);
void print_format(struct format_s *);
char *stringisize_flags(int flags);

#endif

