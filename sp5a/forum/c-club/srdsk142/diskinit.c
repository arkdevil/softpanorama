/* ReSizeable RAMDisk - disk initialization
** Copyright (c) 1992 Marko Kohtala
*/

#include "srdisk.h"
#include <stdio.h>
#include <dos.h>
#include <string.h>

/*
**  Resolves a drive letter in configuration structure
**
**  No must to return in error.
**  Must set a usable drive letter into conf->drive.
*/

static void resolve_drive(struct config_s far *conf)
{
  byte far *dpb;
  int device, next;
  struct devhdr far *dev;
  byte far *cp;
  int drives_searched = 0;

  asm {
    mov ah,0x52     /* SYSVARS call */
    int 0x21        /* Call DOS */
  }
  dpb = *(byte far * far *)MK_FP(_ES,_BX);

  if (_osmajor < 4) {
    device = 0x12;
    next = 0x18;
  }
  else {
    device = 0x13;
    next = 0x19;
  }

  do {
    if ( *dpb > 25 || drives_searched > 25) {
      warning("Cannot read DOS Drive Parameter Block chain");
      goto failed_return;
    }
    dev = *(struct devhdr far * far *)(dpb+device);
    if ( FP_SEG(dev) == FP_SEG(conf)
    ||   ( *(cp = MK_FP(FP_SEG(dev), dev->dh_strat)) == 0xEA
          && *(word far *)(cp+3) == FP_SEG(conf)
        && *(cp = MK_FP(FP_SEG(dev), dev->dh_inter)) == 0xEA
          && *(word far *)(cp+3) == FP_SEG(conf) ) )
    {
      conf->drive = *dpb + 'A';
      return;
    }
    dpb = *(byte far * far *)(dpb+next);
    drives_searched++;
  } while ( FP_OFF(dpb) != 0xFFFF );

  warning("SRDISK drive not in DOS Drive Parameter Block chain");
 failed_return:
  fprintf(stderr, "\nYou should define the proper drive letter in CONFIG.SYS\n"
                  "Example: DEVICE=SRDISK.SYS D:\n");
  { struct config_s far *c = mainconf;
    int drive = 1;
    while (c != conf) c = conf_ptr(c->next_drive), drive++;
    conf->drive = '0' + drive;
  }
}

/*
**  RETRIEVE OLD FORMAT FOR DISK
**
**  Must collect and fill global structure f to hold the old format of
**  the disk.
**  Expected to not return if error detected.
*/

static void retrieve_old_format(void)
{
  struct config_s far *subconf;
  int i;
  int has_32bitsec = 1;

  memset(&f, 0, sizeof f);

  /* Scan the chain of drivers linked to the same drive */
  for (subconf = conf, i = 0; subconf; subconf = conf_ptr(subconf->next), i++) {
    /* Make sure f.max_size does not overflow */
    if (f.max_size && -f.max_size <= subconf->maxK)
      f.max_size = -1;
    else
      f.max_size += subconf->maxK;
    f.current_size += subconf->size;
    f.subconf[i].maxK = subconf->maxK;
    if (!(subconf->flags & C_32BITSEC))
      has_32bitsec = 0;
    f.chain_len++;
  }

  if (!has_32bitsec)
    f.max_size = 32768L;

  f.RW_access = conf->RW_access;
  f.size = conf->tsize;
  f.bps = conf->BPB_bps;
  f.spc = conf->BPB_spc;
  f.reserved = conf->BPB_reserved;
  f.FATs = conf->BPB_FATs;
  f.dir_entries = conf->BPB_dir;
  f.spFAT = conf->BPB_FATsectors;
  f.sectors = conf->BPB_tsectors;
  f.sec_per_track = conf->BPB_spt;
  f.sides = conf->BPB_heads;
  f.media = conf->BPB_media;
  f.FAT_sectors = f.spFAT * f.FATs;
  { div_t divr;
    divr = div(f.dir_entries * 32, f.bps);
    f.dir_sectors = divr.quot + (divr.rem ? 1 : 0);
  }
  f.dir_start = f.reserved + f.FAT_sectors;
  f.system_sectors = f.dir_start + f.dir_sectors;
  f.cluster_size = f.spc * f.bps;
  if (f.size) {
    f.data_sectors = f.sectors - f.system_sectors;
    f.clusters = f.data_sectors / f.spc;
  }
  f.FAT_type = f.clusters > 4086 ? 16 : 12;
}

/*
**  Initialize device driver interface by locating the proper driver
**
**  Expected not to return if error found.
*/

void init_drive(void)
{
  struct dev_hdr _seg *dev;
  char installed;
  char suggest_drive;

  asm {
    mov ax,MULTIPLEXAH * 0x100
    xor bx,bx
    xor cx,cx
    xor dx,dx
    push bp
    push si
    push di
    push es
    push ds
    pushf
    int 0x2F
    popf
    pop ds
    pop es
    pop di
    pop si
    pop bp
    mov installed,al
  }
  if (installed != -1)
    fatal("No SRDISK driver installed");

  asm {
    mov ax,MULTIPLEXAH * 0x100 + 1
    push es
    push si
    push di
    push ds
    push bp
    pushf
    int 0x2F
    popf
    pop bp
    pop ds
    pop di
    pop si
    mov dev,es
    pop es
  }

  if (!dev
   || dev->u.s.ID[0] != 'S'
   || dev->u.s.ID[1] != 'R'
   || dev->u.s.ID[2] != 'D')
  {
    fatal("Some other driver found at SRDISK multiplex number");
  }
  else if (dev->v_format != V_FORMAT) {
    fatal("Invalid SRDISK driver version");
  }
  conf = mainconf = conf_ptr(dev);

  /* Check if driver does not know yet what drive it is */
  do {
    if ( conf->drive == '$' ) {
      resolve_drive(conf);
    }
    conf = conf_ptr(conf->next_drive);
  } while ( conf );
  conf = mainconf;

  suggest_drive = drive ? drive : _getdrive() - 1 + 'A';

  while(conf->drive != suggest_drive) {
    if ( ! (conf = conf_ptr(conf->next_drive)) )
      if (drive)
        fatal("Drive not ReSizeable RAMDisk");
      else {
        conf = mainconf;
        suggest_drive = conf->drive;
      }
  }
  drive = suggest_drive;

  { /* This is to solve a strange problem I am having with DR-DOS 5
       DR-DOS 5 seems to get into infinite loop reading FAT if sector
       size is larger than 128 bytes!
    */
    max_bps = 512;
    asm {
      mov ax,0x4452
      stc
      int 0x21
      jc notDRDOS
      cmp ax,dx
      jne notDRDOS
      cmp ax,0x1065
      jne notDRDOS /* Actually "not DR-DOS 5" */
    }
    /* It is DR-DOS 5, so limit the sector size */
    max_bps = 128;
    if (newf.bps > max_bps) {
      warning("Sector size is limited to 128 bytes under DR-DOS 5");
      newf.bps = max_bps;
    }
   notDRDOS:
  }

  retrieve_old_format();    /* Setup f */

  if (verbose > 3) print_format(&f);
  if (verbose > 4) {
    struct config_s far *subconf = conf;
    int part = 1;
    for( ; subconf; subconf = conf_ptr(subconf->next), part++) {
      printf("Driver %d of %d\n"
             "  Version %.4Fs\n"
             "  Memory: %.4Fs\n"
             "  Flags:%s\n"
             "  Max size: %luK\n"
             "  Size: %luK\n"
             "  Sectors: %lu\n"
             ,part, f.chain_len
             ,((struct dev_hdr _seg *)FP_SEG(subconf))->u.s.version
             ,((struct dev_hdr _seg *)FP_SEG(subconf))->u.s.memory
             ,stringisize_flags(subconf->flags)
             ,subconf->maxK
             ,subconf->size
             ,subconf->sectors
             );
    }
  }
}


