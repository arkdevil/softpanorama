/* ReSizeable RAMDisk - disk formatting
** Copyright (c) 1992 Marko Kohtala
*/

#include "srdisk.h"
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <dir.h>
#include <direct.h>

/*
**  Format printing
*/

char *stringisize_flags(int flags)
{
  static char _string[60];
  _string[0] = 0;
  if (!flags) {
    return " NONE";
  } else {
    if (flags & C_APPENDED) strcat(_string, " APPENDED");
    if (flags & C_MULTIPLE) strcat(_string, " MULTIPLE");
    if (flags & C_32BITSEC) strcat(_string, " 32BITSEC");
    if (flags & C_NOALLOC) strcat(_string, " NOALLOC");
    if (flags & C_UNKNOWN) strcat(_string, " unknown");
  }
  return _string;
}

void print_format(struct format_s *f)
{
  printf("\n"
         "Drive %c:\n"
         "  Disk size: %luK\n"
         "  Cluster size: %d bytes\n"
         "  Sector size: %d bytes\n"
         "  Directory entries: %d\n"
         "  FAT copies: %d\n"
         "  Bytes available: %ld\n"
         "  Write protection: %s\n"
         ,drive
         ,f->size
         ,f->cluster_size
         ,f->bps
         ,f->dir_entries
         ,f->FATs
         ,f->clusters*f->cluster_size
         ,((f->RW_access & WRITE_ACCESS) ? "OFF" : "ON")
         );
  if (verbose > 3)
    printf("  Sectors: %lu\n"
           "  Reserved sectors: %d\n"
           "  FAT sectors: %d\n"
           "  Directory sectors: %d\n"
           "  Sectors per cluster: %d\n"
           "  Clusters: %lu\n"
           "  FAT type: %u bit\n"
           "  Max size: %luK\n"
           ,f->sectors
           ,f->reserved
           ,f->FAT_sectors
           ,f->dir_sectors
           ,f->spc
           ,f->clusters
           ,f->FAT_type
           ,f->max_size
           );
}

/*
**  Count the files in root directory
*/

static int count_root(void)
{
  byte *sp;
  int si;
  dword sector = f.dir_start;
  int entries = f.dir_entries;
  int files = 0;

  if (!f.size)
    return 0;

  sp = xalloc(f.bps);

  while(entries) {
    read_sector(1, sector, sp);
    for(si = 0; si < f.bps && entries; si += 32) {
      if (sp[si] == 0) goto end;    /* Unused, end of directory */
      if (sp[si] != 0xE5            /* Not deleted */
      && !(sp[si+11] & 8))          /* and not label */
        files++;                    /* so it is a file (or directory) */
      entries--;
    }
    sector++;
  }

 end:
  free(sp);
  return files;
}

/*
**  PERMISSION TO DELETE DATA
*/

int licence_to_kill(void)
{
  if (!force_f && root_files > 0) {
    printf("\n\aAbout to destroy all files on drive %c!\n\a"
           "Continue (Y/N) ? ", drive);
    if (!getYN()) {
      printf("\nOperation aborted\n");
      return 0;
    }
  }
  return 1;
}

/*
**  COUNT MAX KBYTES FOR DRIVERS IN CHAIN
*/

static void count_maxK(void)
{
  int i;
  int changed = 0;

  for (i = MAX_CHAINED_DRIVERS; i >= f.chain_len; i--)
    if (newf.subconf[i].userdef) {
      error("Too many /M values");
      return;
    }

  newf.max_size = 0;
  for (i = 0; i < MAX_CHAINED_DRIVERS; i++)
  {
    if (!newf.subconf[i].userdef)
      newf.subconf[i].maxK = f.subconf[i].maxK;
    else if (newf.subconf[i].maxK != f.subconf[i].maxK)
      changed++;
    newf.max_size += newf.subconf[i].maxK;
  }
  if (!changed) changed_format &= ~MAX_PART_SIZES;
}

/*
**  FILL AND ADJUST THE newf
**
**  Fills newf fields with the user specified data
*/

static void make_newf(void)
{
  int suggest_bps, suggest_bpc, suggest_dir, suggest_FATs;

  newf.chain_len = f.chain_len;
  newf.reserved = 1;

  #define dochange(change,new,old,default)  \
    if (!(changed_format & (change)))       \
      (new) = (default);                    \
    else if ((new) == (old))                \
      changed_format &= ~(change);

  /* Make values for the fields the user did not supply */
  if (!(changed_format & DISK_SIZE))
    newf.size = f.size;
  if (!(changed_format & MEDIA) || !f.media)
    newf.media = 0xFA;
  if (!(changed_format & SEC_PER_TRACK))
    newf.sec_per_track = 1;
  if (!(changed_format & SIDES))
    newf.sides = 1;
  if (!(changed_format & WRITE_PROTECTION))
    newf.RW_access = WRITE_ACCESS;

  count_maxK();

  if (use_old_format_f) {
    suggest_bps = f.bps;
    suggest_bpc = f.cluster_size;
    suggest_dir = f.dir_entries;
    suggest_FATs = f.FATs;
  }
  else {
    if (!(changed_format & SECTOR_SIZE)) {
      if (changed_format & CLUSTER_SIZE && newf.cluster_size < max_bps)
        suggest_bps = newf.cluster_size;
      else
        suggest_bps = max_bps;
    }
    else
        suggest_bps = newf.bps;
    if (!(changed_format & CLUSTER_SIZE)) {
      /* !!!! Make better estimate */
      suggest_bpc = newf.size <= 1536L   ? 512  :
                    newf.size <= 30000L  ? 1024 : 2048;
    }
    if (!(changed_format & DIR_ENTRIES)) {
      if (newf.size > 16*512)
        suggest_dir = 512;
      else {
        int entries_per_sec;
        suggest_dir = (int)(newf.size / 16);
        entries_per_sec = suggest_bps / 32;
        suggest_dir += entries_per_sec - suggest_dir % entries_per_sec;
      }
    }
    if (!(changed_format & NO_OF_FATS))
      suggest_FATs = 1;
  }

  dochange(SECTOR_SIZE, newf.bps, f.bps, suggest_bps)
  dochange(CLUSTER_SIZE, newf.cluster_size, f.cluster_size, suggest_bpc)
  dochange(DIR_ENTRIES, newf.dir_entries, f.dir_entries, suggest_dir)
  dochange(NO_OF_FATS, newf.FATs, f.FATs, suggest_FATs)
  #undef dochange
}

static int count_new_format(void)
{
  newf.FAT_type = 12;        /* By default try to use 12 bit FAT */

  /* Make sure sectors are big enough for the disk */
  while((newf.sectors = newf.size * 1024 / newf.bps) >
      ((conf->flags & C_32BITSEC) ? 0x7FFFFFL : 0xFFFFL) )
    newf.bps <<= 1;
  if (newf.bps > 512)
    warning("Sector size larger than 512 bytes, may crash DOS");

  if (newf.cluster_size < newf.bps)
    newf.cluster_size = newf.bps;

  { div_t divr;
    divr = div(newf.dir_entries * 32, newf.bps);
    newf.dir_sectors = divr.quot + (divr.rem ? 1 : 0);
  }

 count_clusters:
  newf.system_sectors = newf.reserved + newf.dir_sectors;
  newf.data_sectors = max(newf.sectors - newf.system_sectors, 0);

  newf.spc = newf.cluster_size / newf.bps;

  { ldiv_t divr;
    long spFAT;
    divr = ldiv(((long)newf.data_sectors + 2 * newf.spc) * newf.FAT_type,
                (long)8 * newf.cluster_size + newf.FATs * newf.FAT_type);
    spFAT = divr.quot + (divr.rem ? 1 : 0);
    if (spFAT > 0xFFFF) {
      if (newf.bps < 512) {
        newf.bps <<= 1;
        if (newf.cluster_size < newf.bps)
          newf.cluster_size = newf.bps;
      }
      else
        newf.cluster_size <<= 1;
      goto count_clusters;
    }
    newf.spFAT = (word)spFAT;
  }

  newf.FAT_sectors = newf.spFAT * newf.FATs;
  newf.system_sectors += newf.FAT_sectors;
  newf.data_sectors = max(newf.data_sectors - newf.FAT_sectors, 0);

  newf.clusters = newf.data_sectors / newf.spc;

  /* Make sure we use the right FAT type */
  if (newf.FAT_type < 16 && newf.clusters > 4077) {
    newf.FAT_type = 16;
    goto count_clusters;
  }
  if (newf.FAT_type > 12 && newf.clusters < 4088 || newf.clusters > 65518L) {
    newf.FAT_type = 12;
    newf.cluster_size <<= 1;
    goto count_clusters;
  }

  newf.dir_start = newf.reserved + newf.FAT_sectors;

  /* If Disk will be disabled */
  if (!newf.size) {
    newf.data_sectors = 0;
    newf.clusters = 0;
    return 1;
  }

  if (newf.sectors <= newf.system_sectors || !newf.clusters)
    return 0;

  /* Remove extra sectors that do not fit into any cluster from the end */
  /* !!?? Extra kilobytes are still left there */
  newf.sectors -= newf.data_sectors % newf.spc;

  return 1;
}

/*
**  CONFIGURE DRIVE FOR FORMAT newf
**
**  Disable drive and configure it. RW_access must be set by caller.
**
**  Return 0 if format is impossible
*/

int configure_drive(void)
{
  long Kleft = newf.size;
  struct config_s far *subconf;
  dword alloc, lastalloc;
  int err = 0;
  int i;

  conf->RW_access = 0;  /* Disable DOS access to drive */

  if (changed_format & MAX_PART_SIZES) {
    for (subconf = conf, i = 0; subconf; subconf = conf_ptr(subconf->next), i++)
      subconf->maxK = newf.subconf[i].maxK;
    if (verbose > 1) {
      printf("\nAdjusted max allocation sizes");
      if (!format_f) printf(" - reformat disk to enable change");
      puts("");
    }
  }

  if (newf.size != f.current_size || changed_format & MAX_PART_SIZES) {
    for(subconf = conf; subconf; subconf = conf_ptr(subconf->next)) {
      alloc = max(min(subconf->maxK, Kleft), 0);
      lastalloc = disk_alloc(subconf, alloc);
      if (lastalloc != alloc && (err = !lastalloc) != 0) break;
      subconf->size = lastalloc;

      Kleft -= lastalloc;
    }

    if (Kleft > 0) {    /* If not enough memory could be allocated */
      err = 1;
      if (!conf->next) {   /* If single drive, try to preserve it */
        if (disk_alloc(conf, f.current_size) == f.current_size) {
          conf->size = f.current_size;      /* Fix back what was changed */
          conf->sectors = (long)f.current_size * 1024 / f.bps;
          conf->RW_access = f.RW_access;    /* Enable the disk */
          error("Failed to allocate memory");
          return 0;                         /* Return failure */
        }
      }
      /* Free all memory */
      for (subconf = conf; subconf; subconf = conf_ptr(subconf->next)) {
        if (!disk_alloc(subconf, 0)) {
          subconf->size = 0;
          subconf->sectors = 0;
        }
      }
      newf.size = 0;
      newf.sectors = 0;
      error("Failed to allocate memory - disk disabled");
    }

    if (Kleft < 0 && verbose > 1)
      printf("\n%ldKbytes extra allocated,\n"
             "Perhaps you should make your disk that much larger.\n"
             ,-Kleft);
  }

  for(subconf = conf; subconf; subconf = conf_ptr(subconf->next)) {
    subconf->sectors = subconf->size * 1024 / newf.bps;
    subconf->BPB_bps = newf.bps;
  }

  conf->BPB_spc = newf.spc;
  conf->BPB_reserved = newf.reserved;
  conf->BPB_FATs = newf.FATs;
  conf->BPB_dir = newf.dir_entries;
  conf->BPB_sectors = (conf->flags & C_32BITSEC && newf.sectors > 0xFFFEL) ?
                      0 : newf.sectors;
  conf->BPB_media = newf.media;
  conf->BPB_FATsectors = newf.spFAT;
  conf->BPB_spt = newf.sec_per_track;
  conf->BPB_heads = newf.sides;
  conf->BPB_hidden = 0L;
  conf->BPB_tsectors = newf.sectors;
  conf->tsize = newf.size;
  conf->open_files = 0;
  if (format_f) conf->media_change = -1;

  return !err;
}

void format_disk(void)
{
  int Fsec;
  int i;
  byte *sector;

  make_newf();

  if (!format_f) {
    warning("No change in format - disk remains untouched");
    if (changed_format & WRITE_PROTECTION)  /* The main() won't do it now */
      set_write_protect();
    return;
  }

  if (newf.size > newf.max_size) {
    error("Not enough memory for disk available");
    return;
  }

  if (!force_f && conf->open_files) {
    error("Files open on drive");
    return;
  }

  if (!count_new_format())
  {
    error("Impossible format for disk");
    return;
  }

  root_files = count_root();

  /* If Disk will be disabled */
  if (!newf.size) {
    if (!f.size) {
      /* If was disabled also before */
      configure_drive();
      if (verbose > 1) printf("\nNew configuration saved for later use\n");
    } else {
      /* If disk now get's disabled */
      if (!licence_to_kill()) return;
      configure_drive();
      if (verbose > 1) printf("\nRAMDisk disabled\n");
    }
    return;
  }
  if (verbose > 1) {
    printf("\nNew disk configuration:\n");
    print_format(&newf);
  }

  if (f.size && !licence_to_kill()) return;

  /* Request the new disk space and configure the driver(s) */
  if (!configure_drive()) return;

  sector = xalloc(newf.bps);

  /* Write the new disk */

  /* Make the boot sector */
  memset(sector, 0, newf.bps);
  { struct boot_s {
      word jump;
      byte nop;
      char oem[8];
      word bps;
      byte spc;
      word reserved;
      byte FATs;
      word dir_entries;
      word sectors;
      byte media;
      word spFAT;
      word spt;
      word sides;
      dword hidden;
      dword sectors32;
      byte physical;
      byte :8;
      byte signature;
      dword serial;
      char label[11];
      char filesystem[8];
      word bootcode;
    } *b = (struct boot_s*)sector;

    b->jump = 0x3CEB;                     /* Boot record JMP instruction */
    b->nop = 0x90;                        /* NOP instruction */
    memcpy(&b->oem, "SRD "VERSION, 8);    /* OEM code and version */
    b->bps = newf.bps;
    b->spc = newf.spc;
    b->reserved = newf.reserved;
    b->FATs = newf.FATs;
    b->dir_entries = newf.dir_entries;
    b->sectors = (conf->flags & C_32BITSEC && newf.sectors > 0xFFFEL) ?
                 0 : newf.sectors;
    b->media = newf.media;                /* Media */
    b->spFAT = newf.spFAT;
    b->spt = newf.sec_per_track;          /* Sectors per track */
    b->sides = newf.sides;                /* Sides */
    b->hidden = 0;                        /* Hidden sectors */
    b->sectors32 = newf.sectors;          /* Total number of sectors */
    b->physical = -1;                     /* Physical drive number */
    b->signature = 0x29;                  /* Signature byte */
    b->serial = time(NULL);               /* Serial number */
    _fmemcpy(&b->label,
             ((struct dev_hdr far *)MK_FP(FP_SEG(conf), 0))->u.volume,
             11);                         /* Volume label */
    memcpy(&b->filesystem, newf.FAT_type == 12 ? "FAT12   " :
                           newf.FAT_type == 16 ? "FAT16   " : "        "
                           ,8);
    b->bootcode = 0xFEEB;           /* Boot code (JMP $) */
  }
  *(word  *)(sector+newf.bps-2) = 0xAA55;      /* Validity code */
  write_sector(1, 0, sector);           /* Write boot sector */

  for (i = 0; i < newf.FATs; i++) {
    word sector_n =
        newf.reserved + newf.spFAT * i;
    /* Write 1st FAT sector */
    memset(sector, 0, newf.bps);  /* Make 1st FAT sector */
    ((word *)sector)[0] = newf.media | 0xFF00;
    ((word *)sector)[1] = newf.FAT_type == 12 ? 0xFF : 0xFFFF;
    write_sector(1, sector_n++, sector);

    /* Write FAT sectors from 2nd to last */
    *(dword *)sector = 0L;
    for (Fsec = 1; Fsec < newf.spFAT; Fsec++)
        write_sector(1, sector_n++, sector);
  }

  /* Write 1st directory sector */
  newf.dir_start = newf.reserved + newf.FAT_sectors;
  _fmemcpy(sector, ((struct dev_hdr far *)MK_FP(FP_SEG(conf), 0))->u.volume, 11);
  sector[11] = FA_LABEL;
  *(dword *)(sector+22) = DOS_time(time(NULL));
  write_sector(1, newf.dir_start, sector);

  /* Write directory sectors from 2nd to last */
  memset(sector, 0, 32);
  for (Fsec = 1; Fsec < newf.dir_sectors; Fsec++)
      write_sector(1, newf.dir_start+Fsec, sector);

  conf->RW_access = READ_ACCESS | newf.RW_access;

  /* This is to get around some DOS 5 bug when the sector size is made
     larger than before: DOS 5 calculates the size wrong. Thus we access
     the disk through DOS and set media change flag again.
  */

  if (_osmajor == 5 && newf.bps > f.bps) {
    char dir[MAXPATH];
    asm {
        mov ax,0x4409
        mov bl,byte ptr drive
        sub bl,'A'-1
        jc no_fix       /* Bad drive letter */
        int 0x21
        jc no_fix       /* Failed access drive */
        test dh,0x80
        jnz no_fix      /* SUBSTed drive */
    }
    _getdcwd(drive-'A'+1, dir, sizeof dir);
    conf->media_change = -1;
   no_fix:;
  }

  free(sector);

  if (verbose > 1) printf("\nDisk formatted\n");
}


