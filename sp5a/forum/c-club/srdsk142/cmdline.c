/* ReSizeable RAMDisk - command line parser
** Copyright (c) 1992 Marko Kohtala
*/

#include "srdisk.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* Variables possibly supplied in command line */
char drive=0;
int force_f=0;        /* Nonzero if ok to format */
int use_old_format_f=0; /* Take undefined parameters from the old format */
int f_set_env=0;      /* Set environment variables */
int verbose=-1;       /* Verbose: 1 banner, */
                      /* 2 + new format, 3 + old format, 4 + long format */


static long parse_narg(char *argp, char **next)
{
  long res;
  if (*argp == ':') argp++, (*next)++;
  res = strtol(argp, next, 10);
  if (argp == *next) return -1L;
  return res;
}

static int ispow2(long size)
{
  long cmp;
  for (cmp = 128; cmp; cmp <<=1)
    if (cmp == size) return 1;
  return 0;
}

static void set_DOS_disk(long size)
{
  static struct {
    int disk_size;
    int media;
    int sector_size;
    int cluster_size;
    int FATs;
    int dir_entries;
    int sec_per_track;
    int sides;
  } dos_disk[] = {
    {    1, 0xFA, 128,  128, 1,   4,  1, 1 },   /* Special format */
    {  160, 0xFE, 512,  512, 2,  64,  8, 1 },
    {  180, 0xFC, 512,  512, 2,  64,  9, 1 },
    {  200, 0xFD, 512, 1024, 2, 112, 10, 1 },   /* FDFORMAT format */
    {  205, 0xFD, 512, 1024, 2, 112, 10, 1 },   /* FDFORMAT format */
    {  320, 0xFF, 512, 1024, 2, 112,  8, 2 },
    {  360, 0xFD, 512, 1024, 2, 112,  9, 2 },
    {  400, 0xFD, 512, 1024, 2, 112, 10, 2 },   /* FDFORMAT format */
    {  410, 0xFD, 512, 1024, 2, 112, 10, 2 },   /* FDFORMAT format */
    {  720, 0xF9, 512, 1024, 2, 112,  9, 2 },
    {  800, 0xF9, 512, 1024, 2, 112, 10, 2 },   /* FDFORMAT format */
    {  820, 0xF9, 512, 1024, 2, 112, 10, 2 },   /* FDFORMAT format */
    { 1200, 0xF9, 512,  512, 2, 224, 15, 2 },
    { 1440, 0xF0, 512,  512, 2, 224, 18, 2 },
    { 1476, 0xF0, 512,  512, 2, 224, 18, 2 },   /* FDFORMAT format */
    { 1600, 0xF0, 512,  512, 2, 224, 20, 2 },   /* FDFORMAT format */
    { 1640, 0xF0, 512,  512, 2, 224, 20, 2 },   /* FDFORMAT format */
    { 1680, 0xF0, 512,  512, 2, 224, 21, 2 },   /* FDFORMAT format */
    { 1722, 0xF0, 512,  512, 2, 224, 21, 2 },   /* FDFORMAT format */
    {0}
  };
  int i;

  for (i=0; dos_disk[i].disk_size; i++)
    if (dos_disk[i].disk_size == size) {
      newf.size = size;
      newf.media = dos_disk[i].media;
      newf.bps = dos_disk[i].sector_size;
      newf.cluster_size = dos_disk[i].cluster_size;
      newf.FATs = dos_disk[i].FATs;
      newf.dir_entries = dos_disk[i].dir_entries;
      newf.sec_per_track = dos_disk[i].sec_per_track;
      newf.sides = dos_disk[i].sides;
      changed_format |= DISK_SIZE
                      | MEDIA
                      | SECTOR_SIZE
                      | CLUSTER_SIZE
                      | NO_OF_FATS
                      | DIR_ENTRIES
                      | SEC_PER_TRACK
                      | SIDES;
      return;
    }

  syntax("Unknown DOS disk size");
}

void parse_cmdline(int argc, char *argv[])
{
  int arg;
  char *argp;
  int i;
  long n;

  for(arg=1; arg < argc; arg++) {
    argp = argv[arg];
    while(*argp) {
      if (*argp == '/' || *argp == '-') {
        argp++;
        switch(toupper(*argp++)) {
        case '?':
        case 'H':
          print_syntax();
          exit(0);
        case 'W':
          switch(*argp) {
          case '-': argp++;
                    newf.RW_access = READ_ACCESS|WRITE_ACCESS;
                    break;
          case '+': argp++;
          default:  newf.RW_access = READ_ACCESS;
          }
          changed_format |= WRITE_PROTECTION;
          break;
        case 'Y':
          force_f++;
          break;
        case 'S': /* Sector size */
          n = parse_narg(argp, &argp);
          if (!ispow2(n) || n > 512)
            syntax("Invalid sector size");
          newf.bps = (int)n;
          changed_format |= SECTOR_SIZE;
          break;
        case 'C': /* Cluster size */
          n = parse_narg(argp, &argp);
          if (!ispow2(n) || n > 8192)
            syntax("Invalid cluster size");
          newf.cluster_size = (int)n;
          changed_format |= CLUSTER_SIZE;
          break;
        case 'D': /* Directory entries */
          n = parse_narg(argp, &argp);
          if (n < 2 || n > 8000)
            syntax("Invalid number of directory entries");
          newf.dir_entries = (int)n;
          changed_format |= DIR_ENTRIES;
          break;
        case 'A': /* FATs */
          n = parse_narg(argp, &argp);
          if (n < 1 || n > 2)
            syntax("Invalid number of FAT copies; only 1 or 2 FATs allowed");
          newf.FATs = (int)n;
          changed_format |= NO_OF_FATS;
          break;
        case 'M': /* MaxK for different partitions */
          memset(newf.subconf, 0, sizeof newf.subconf);
          changed_format |= MAX_PART_SIZES;
          i = 0;
          do {
            if (i == MAX_CHAINED_DRIVERS)
              syntax("Too many /M values - program limit exceeded");
            n = parse_narg(argp, &argp);
            if (n < -1 || n > 0x3FFFFFL)
              syntax("Too large partition size");
            if (n != -1L) {
              newf.subconf[i].maxK = n;
              newf.subconf[i].userdef = 1;
            }
            i++;
          } while(*argp == ':');
          break;
        case 'F': /* DOS disk format */
          n = parse_narg(argp, &argp);
          set_DOS_disk(n);
          break;
        case 'V': /* Verbose level */
          n = parse_narg(argp, &argp);
          if (n < 1 || n > 5)
            syntax("Invalid verbose level");
          verbose = (int)n;
          break;
        case 'O': /* Use old parameters unless overridden */
          use_old_format_f = 1;
          break;
        case 'E': /* Set environment variables to show SRDISKs */
          f_set_env = 1;
          break;
        default:
          syntax("Unknown switch");
        }
      }
      else {
        if (*argp == ' ' || *argp == '\t') argp++;
        else if (isdigit(*argp) && *(argp+1) != ':') {
          n = strtol(argp, &argp, 10);
          if (n > 0x3FFFFFL)
            syntax("Invalid disk size");
          newf.size = n;
          changed_format |= DISK_SIZE;
        }
        else {
          if (drive) syntax("Unrecognised character on command line");
          drive = toupper(*argp++);
          if ( !(   (drive >= 'A' && drive <= 'Z')
                 || (drive >= '1' && drive <= '9')) )
            syntax("Invalid drive");
          if (*argp == ':') argp++;
        }
      }
    }
  }
}


