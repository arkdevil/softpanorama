/* This is file PAGING.C */
/*
** Copyright (C) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
**
** This file is distributed under the terms listed in the document
** "copying.dj", available from DJ Delorie at the address above.
** A copy of "copying.dj" should accompany this file; if not, a copy
** should be available from where this file was obtained.  This file
** may not be distributed without a verbatim copy of "copying.dj".
**
** This file is distributed WITHOUT ANY WARRANTY; without even the implied
** warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

/* History:112,12 */

#include <dos.h>
#include <fcntl.h>
#include <io.h>
#include <sys/stat.h>

#include "build.h"
#include "types.h"
#include "paging.h"
#include "graphics.h"
#include "tss.h"
#include "gdt.h"
#include "valloc.h"
#include "dalloc.h"
#include "utils.h"
#include "aout.h"
#include "mono.h"

#define VERBOSE 0

#if DEBUGGER
#define MAX_PAGING_NUM 1
#else
#define MAX_PAGING_NUM 4
#endif

extern word32 ptr2linear(void far *ptr);

extern TSS *utils_tss;
extern int debug_mode;
extern word16 mem_avail;
extern int self_contained;
extern long header_offset;

typedef struct AREAS {
  word32 first_addr;
  word32 last_addr;
  word32 foffset; /* corresponding to first_addr; -1 = zero fill only */
  } AREAS;

#define MAX_AREA	8
static AREAS areas[MAX_AREA];
static char *aname[MAX_AREA] = {
	"text ",
	"data ",
	"bss  ",
	"arena",
	"stack",
	"vga  ",
	"syms ",
	"emu"
};
static char achar[MAX_AREA] = "tdbmsg?e";
typedef enum {
  A_text,
  A_data,
  A_bss,
  A_arena,
  A_stack,
  A_vga,
  A_syms,
  A_emu
} AREA_TYPES;

static aout_f;
static emu_f;

word32 far *pd = 0;
word32 far *graphics_pt;
extern word32 graphics_pt_lin;
char paging_buffer[4096*MAX_PAGING_NUM];

handle_screen_swap(word32 far *pt)
{
  struct REGPACK r;
  int have_mono=0;
  int have_color=0;
  int have_graphics=0;
  int save, new, i;

  r.r_ax = 0x1200;
  r.r_bx = 0xff10;
  r.r_cx = 0xffff;
  intr(0x10, &r);
  if (r.r_cx == 0xffff)
    pokeb(0x40, 0x84, 25); /* the only size for CGA/MDA */

  save = peekb(screen_seg, 0);
  pokeb(screen_seg, 0, ~save);
  new = peekb(screen_seg, 0);
  pokeb(screen_seg, 0, save);
  if (new == ~save)
    have_color = 1;

  save = peekb(0xb000, 0);
  pokeb(0xb000, 0, ~save);
  new = peekb(0xb000, 0);
  pokeb(0xb000, 0, save);
  if (new == ~save)
    have_mono = 1;

  r.r_ax = 0x0f00;
  intr(0x10, &r);
  if ((r.r_ax & 0xff) > 0x07)
    have_graphics = 1;

  if (have_graphics && have_mono)
    have_color = 1;
  else if (have_graphics && have_color)
    have_mono = 1;

  if (have_color && !have_mono)
  {
    for (i=0; i<8; i++)
      pt[0xb0+i] = pt[0xb8+i];
    return;
  }
  if (have_mono & !have_color)
  {
    for (i=0; i<8; i++)
      pt[0xb8+i] = pt[0xb0+i];
    return;
  }

  if ((biosequip() & 0x0030) == 0x0030) /* mono mode, swap! */
  {
    for (i=0; i<8; i++)
    {
      pt[0xb0+i] ^= pt[0xb8+i];
      pt[0xb8+i] ^= pt[0xb0+i];
      pt[0xb0+i] ^= pt[0xb8+i];
    }
    return;
  }
}

paging_set_file(char *fname)
{
  word32 far *pt;
  FILEHDR filehdr;
  AOUTHDR aouthdr;
  SCNHDR scnhdr[3];
  GNU_AOUT gnu_aout;
  int i;
  aout_f = open(fname, O_RDONLY|O_BINARY);
  if (aout_f < 0)
  {
    printf("Can't open file <%s>\n", fname);
    exit(1);
  }

#if TOPLINEINFO
  for (i=0; fname[i]; i++)
    poke(screen_seg, i*2+10, fname[i] | 0x0700);
#endif

  lseek(aout_f, header_offset, 0);

  read(aout_f, &filehdr, sizeof(filehdr));
  if (filehdr.f_magic != 0x14c)
  {
    lseek(aout_f, header_offset, 0);
    read(aout_f, &gnu_aout, sizeof(gnu_aout));
    a_tss.tss_eip = gnu_aout.entry;
    aouthdr.tsize = gnu_aout.tsize;
    aouthdr.dsize = gnu_aout.dsize;
    aouthdr.bsize = gnu_aout.bsize;
  }
  else
  {
    read(aout_f, &aouthdr, sizeof(aouthdr));
    a_tss.tss_eip = aouthdr.entry;
    read(aout_f, scnhdr, sizeof(scnhdr));
  }
  a_tss.tss_cs = g_acode*8;
  a_tss.tss_ds = g_adata*8;
  a_tss.tss_es = g_adata*8;
  a_tss.tss_fs = g_adata*8;
  a_tss.tss_gs = g_adata*8;
  a_tss.tss_ss = g_adata*8;
  a_tss.tss_esp = 0x7ffffffc;

  if (filehdr.f_magic == 0x14c)
  {
    areas[0].first_addr = aouthdr.text_start + ARENA;
    areas[0].foffset = scnhdr[0].s_scnptr + header_offset;
    areas[0].last_addr = areas[0].first_addr + aouthdr.tsize;
  }
  else if (filehdr.f_magic == 0x10b)
  {
    areas[0].first_addr = ARENA;
    if (a_tss.tss_eip >= 0x1000)	/* leave space for null reference */
      areas[0].first_addr += 0x1000;	/* to cause seg fault */
    areas[0].foffset = header_offset;
    areas[0].last_addr = areas[0].first_addr + aouthdr.tsize + 0x20;
  }
#if DEBUGGER
  else if (filehdr.f_magic == 0x107)
  {
    struct stat sbuf;
    fstat(aout_f, &sbuf);
    areas[0].first_addr = ARENA;
    areas[0].foffset = 0x20 + header_offset;
    areas[0].last_addr = sbuf.st_size + ARENA - 0x20;
  }
  else
  {
    struct stat sbuf;
    fstat(aout_f, &sbuf);
    areas[0].first_addr = ARENA;
    areas[0].foffset = header_offset;
    areas[0].last_addr = sbuf.st_size + ARENA;
  }
#else
  else
  {
    printf("Unknown file type 0x%x (0%o)\n", filehdr.f_magic, filehdr.f_magic);
    exit(-1);
  }
#endif
#if DEBUGGER
  if (debug_mode)
    printf("%ld+", aouthdr.tsize);
#endif

  if (filehdr.f_magic == 0x14c)
  {
    areas[1].first_addr = aouthdr.data_start + ARENA;
    areas[1].foffset = scnhdr[1].s_scnptr + header_offset;
  }
  else
  {
    areas[1].first_addr = (areas[0].last_addr+0x3fffffL)&~0x3fffffL;
    areas[1].foffset = ((aouthdr.tsize + 0x20 + 0xfffL) & ~0xfffL) + header_offset;
  }
  areas[1].last_addr = areas[1].first_addr + aouthdr.dsize - 1;
#if DEBUGGER
  if (debug_mode)
    printf("%ld+", aouthdr.dsize);
#endif

  areas[2].first_addr = areas[1].last_addr + 1;
  areas[2].foffset = -1;
  areas[2].last_addr = areas[2].first_addr + aouthdr.bsize - 1;
#if DEBUGGER
  if (debug_mode)
    printf("%ld = %ld\n", aouthdr.bsize,
      aouthdr.tsize+aouthdr.dsize+aouthdr.bsize);
#endif

  areas[3].first_addr = areas[2].last_addr;
  areas[3].last_addr = areas[3].first_addr;
  areas[3].foffset = -1;

  areas[4].first_addr = 0x50000000;
  areas[4].last_addr = 0x8fffffff;
  areas[4].foffset = -1;

  areas[5].first_addr = 0xe0000000;
  areas[5].last_addr = 0xe03fffff;
  areas[5].foffset = -1;

  areas[A_syms].first_addr = 0xa0000000;
  areas[A_syms].last_addr = 0xafffffff;
  areas[A_syms].foffset = -1;

  pd = (word32 far *)((long)valloc(VA_640) << 24);
  pt = (word32 far *)((long)valloc(VA_640) << 24);
  for (i=0; i<1024; i++)
    pd[i] = 0;
  for (i=0; i<256; i++)
    pt[i] = ((unsigned long)i<<12) | PT_P | PT_W | PT_I;
  for (; i<1024; i++)
    pt[i] = 0;
  pd[0] = ((word32)pt >> 12) | PT_P | PT_W | PT_I;	/* map 0-1M 1:1 */
  pd[0x3c0] = ((word32)pt >> 12) | PT_P | PT_W | PT_I;	/* map also to 0xF0000000 */
  handle_screen_swap(pt);

  graphics_pt = (word32 far *)((long)valloc(VA_640) << 24);
  graphics_pt_lin = ptr2linear(graphics_pt);
  for (i=0; i<1024; i++)
    graphics_pt[i] = 0x000a0000L | ((i * 4096L) & 0xffffL) | PT_W | PT_U;
  pd[0x380] = ((word32)graphics_pt >> 12) | PT_P | PT_W | PT_U;

  c_tss.tss_cr3 = (unsigned long)pd >> 12;
  a_tss.tss_cr3 = (unsigned long)pd >> 12;
  o_tss.tss_cr3 = (unsigned long)pd >> 12;
  i_tss.tss_cr3 = (unsigned long)pd >> 12;
  p_tss.tss_cr3 = (unsigned long)pd >> 12;
  f_tss.tss_cr3 = (unsigned long)pd >> 12;

#if VERBOSE
    for (i=0; i<5; i++)
      printf("%d %-10s %08lx-%08lx (offset 0x%08lx)\n", i, aname[i], areas[i].first_addr, areas[i].last_addr, areas[i].foffset);
#endif
}

#if TOPLINEINFO
static update_status(int c, int col)
{
  int r;
  r = peek(screen_seg, 2*79);
  poke(screen_seg, 2*col, c);
  return r;
}
#endif

word32 paging_brk(word32 b)
{
  word32 r = (areas[3].last_addr - ARENA + 7) & ~7;
  areas[3].last_addr = b + ARENA;
  return r;
}

word32 paging_sbrk(int32 b)
{
  word32 r = (areas[3].last_addr - ARENA + 7) & ~7;
  areas[3].last_addr = r + b + ARENA;
  return r;
}

page_is_valid(word32 vaddr)
{
  int a;
  for (a=0; a<MAX_AREA; a++)
    if ((vaddr <= areas[a].last_addr) && (vaddr >= areas[a].first_addr))
      return 1;
  if (vaddr >= 0xf000000L)
    return 1;
  return 0;
}

page_in()
{
  int old_status;
  TSS *old_util_tss;
  word32 far *pt;
  word32 far *p;
  word32 vaddr, foffset, cnt32;
  word32 eaddr, vtran, vcnt, zaddr;
  int pdi, pti, pn, a, cnt, count;
  unsigned dblock;

#if 0
  unsigned char buf[100];
  sprintf(buf, "0x%08lx", a_tss.tss_cr2 - ARENA);
  for (a=0; buf[a]; a++)
    poke(screen_seg, 80+a*2, 0x0600 | buf[a]);
#endif

  old_util_tss = utils_tss;
  utils_tss = &f_tss;
  vaddr = tss_ptr->tss_cr2;

  for (a=0; a<MAX_AREA; a++)
    if ((vaddr <= areas[a].last_addr) && (vaddr >= areas[a].first_addr))
      goto got_area;

  printf("Segmentation Violation referencing address %#lx\n",
         tss_ptr->tss_cr2-ARENA);
#if !DEBUGGER
/*  exit(1); */
#endif
  return 1;

got_area:
  vaddr &= 0xFFFFF000;	/* points to beginning of page */
#if 0 /* handled in protected mode for speed */
  if (a == A_vga)
    return graphics_fault(vaddr, graphics_pt);
#endif

#if VERBOSE
    printf("area(%d) - ", a);
#endif

  if ((a == 2) & (vaddr < areas[a].first_addr)) /* bss, but data too */
  {
#if VERBOSE
      printf("split page (data/bss) detected - ");
#endif
    a = 1; /* set to page in data */
  }

#if TOPLINEINFO
  old_status = update_status(achar[a] | 0x0a00, 78);
#endif
#if VERBOSE
  printf("Paging in %s block for vaddr %#010lx -", aname[a], tss_ptr->tss_cr2-ARENA);
#endif
  pdi = (vaddr >> 22) & 0x3ff;
  if (!(pd[pdi] & PT_P))	/* put in an empty page table if required */
  {
    pn = valloc(VA_640);
    pt = (word32 far *)((word32)pn << 24);
    pd[pdi] = ((word32)pn<<12) | PT_P | PT_W | PT_I | PT_S;
    for (pti=0; pti<1024; pti++)
      pt[pti] = PT_W | PT_S;
  }
  else
    pt = (word32 far *)((pd[pdi]&~0xFFF) << 12);
  pti = (vaddr >> 12) & 0x3ff;
  if (pt[pti] & PT_P)
  {
    utils_tss = old_util_tss;
#if TOPLINEINFO
    update_status(old_status, 78);
#endif
    return 0;
  }
  count = MAX_PAGING_NUM;
  if (count > mem_avail/4)
    count = mem_avail/4;
  if (pti + count > 1024)
    count = 1024 - pti;
  if (vaddr + count*4096L > areas[a].last_addr+4096L)
    count = (areas[a].last_addr - vaddr + 4095) / 4096;
  if (count < 1)
    count = 1;
  zaddr = eaddr = -1;
  vtran = vaddr;
  vcnt = 0;
  for (; count; count--, pti++, vaddr+=4096)
  {
    if (pt[pti] & PT_P)
      break;
    dblock = pt[pti] >> 12;
    pn = valloc(VA_1M);
    pt[pti] &= 0xfffL & ~(word32)(PT_A | PT_D | PT_C);
    pt[pti] |= ((word32)pn << 12) | PT_P;

    if (pt[pti] & PT_I)
    {
#if VERBOSE
        printf(" swap");
#endif
      dread(paging_buffer, dblock);
      dfree(dblock);
      memput(vaddr, paging_buffer, 4096);
    }
    else
    {
      if (areas[a].foffset != -1)
      {
#if VERBOSE
        if (a == A_emu)
          printf(" emu");
        else
          printf(" exec");
#endif
        if (eaddr == -1)
        {
          eaddr = areas[a].foffset + (vaddr - areas[a].first_addr);
          vtran = vaddr;
        }
        cnt32 = areas[a].last_addr - vaddr + 1;
        if (cnt32 > 4096)
          cnt32 = 4096;
        else
          zaddr = vaddr;
        vcnt += cnt32;
      }
      else
      {
        zero32(vaddr);
#if VERBOSE
        printf(" zero");
#endif
      }
      pt[pti] |= PT_I;
    }
  }
  if (eaddr != -1)
  {
    int cur_f, rsize;
    if (a == A_emu)
      cur_f = emu_f;
    else
      cur_f = aout_f;
    lseek(cur_f, eaddr, 0);
    rsize = read(cur_f, paging_buffer, vcnt);
    if (rsize < vcnt)
      memset(paging_buffer+rsize, 0, vcnt-rsize);
    if (zaddr != -1)
      zero32(zaddr);
    memput(vtran, paging_buffer, vcnt);
  }
#if VERBOSE
  printf("\n");
#endif
  utils_tss = old_util_tss;
#if TOPLINEINFO
  update_status(old_status, 78);
#endif
  return 0;
}

static last_po_pdi = 0;
static last_po_pti = 0;

int page_out() /* return 1 if paged out, 0 if not */
{
  int start_pdi, start_pti, old_status;
  word32 far *pt, v;
  unsigned dblock, pn;
#if TOPLINEINFO
  old_status = update_status('>' | 0x0a00, 79);
#endif
  start_pdi = last_po_pdi;
  start_pti = last_po_pti;
  pt = (word32 far *)((pd[last_po_pdi]&~0xFFF) << 12);
  do {
    if ((pd[last_po_pdi] & (PT_P | PT_S)) == (PT_P | PT_S))
    {
      if ((pt[last_po_pti] & (PT_P | PT_S)) == (PT_P | PT_S))
      {
        pn = pt[last_po_pti] >> 12;
        dblock = dalloc();
        v = ((word32)last_po_pdi << 22) | ((word32)last_po_pti << 12);
        memget(v, paging_buffer, 4096);
        dwrite(paging_buffer, dblock);
        pt[last_po_pti] &= 0xfff & ~PT_P; /* no longer present */
        pt[last_po_pti] |= (long)dblock << 12;
        vfree(pn);
#if TOPLINEINFO
        update_status(old_status, 79);
#endif
        return 1;
      }
    }
    else /* imagine we just checked the last entry */
      last_po_pti = 1023;
    if (++last_po_pti == 1024)
    {
      last_po_pti = 0;
      if (++last_po_pdi == 1024)
        last_po_pdi = 0;
      pt = (word32 far *)((pd[last_po_pdi]&~0xFFF) << 12);
    }
  } while ((start_pdi != last_po_pdi) || (start_pti != last_po_pti));
#if TOPLINEINFO
  update_status(old_status, 79);
#endif
  return 0;
}

unsigned pd_dblock;

page_out_everything()
{
  int pdi;
  unsigned ptb;
  void far *fp;
  while (page_out());
  for (pdi=0; pdi<1024; pdi++)
    if (pd[pdi])
    {
      ptb = dalloc();
      fp = (void far *)((pd[pdi]&~0xFFF)<<12);
      movedata(FP_SEG(fp), FP_OFF(fp), _DS, paging_buffer, 4096);
      dwrite(paging_buffer, ptb);
      vfree(pd[pdi]>>12);
      pd[pdi] = (pd[pdi] & (0xFFF&~PT_P)) | ((word32)ptb<<12);
    }
  movedata(FP_SEG(pd), FP_OFF(pd), _DS, paging_buffer, 4096);
  pd_dblock = dalloc();
  dwrite(paging_buffer, pd_dblock);
  vfree(((word32)pd)>>24);
  xms_free();
}

extern int valloc_initted;

page_in_everything()
{
  int pdi;
  unsigned ptb;
  word32 far *pt;
  unsigned pta;
  valloc_initted = 0;
  pta = valloc(VA_640);
  pd = (word32 far *)((word32)pta << 24);
  dread(paging_buffer, pd_dblock);
  dfree(pd_dblock);
  movedata(_DS, paging_buffer, FP_SEG(pd), FP_OFF(pd), 4096);
  for (pdi=0; pdi<1024; pdi++)
    if (pd[pdi])
    {
      pta = valloc(VA_640);
      pt = (word32 far *)((word32)pta << 24);
      ptb = pd[pdi] >> 12;
      dread(paging_buffer, ptb);
      dfree(ptb);
      movedata(_DS, paging_buffer, FP_SEG(pt), FP_OFF(pt), 4096);
      pd[pdi] = (pd[pdi] & 0xFFF) | ((word32)pta<<12) | PT_P;
    }
  graphics_pt = (word32 far *)((pd[0x380]&~0xfff) << 12);
  graphics_pt_lin = ptr2linear(graphics_pt);
}


int emu_install(char *filename)
{
  GNU_AOUT eh;
  areas[A_emu].first_addr = EMU_TEXT+ARENA;
  areas[A_emu].last_addr = EMU_TEXT-1+ARENA;
  areas[A_emu].foffset = 0;

  if (filename == 0)
    return 0;
  emu_f = open(filename, O_RDONLY|O_BINARY);
  if (emu_f < 0)
  {
    printf("Can't open 80387 emulator file <%s>\n", filename);
    return 0;
  }
  read(emu_f, &eh, sizeof(eh));
  areas[A_emu].last_addr += eh.tsize + eh.dsize + eh.bsize + 0x20;
  return 1;
}
