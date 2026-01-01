/* This is file VALLOC.C */
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

/* History:126,1 */

#include <stdio.h>
#include <dos.h>

#include "build.h"
#include "types.h"
#include "valloc.h"
#include "xms.h"
#include "mono.h"

#define VA_FREE	0
#define VA_USED	1

int valloc_initted = 0;
static word8 map[4096];
word16 mem_avail, mem_used;
static word16 left_lo, left_hi;

static unsigned pn_lo_first, pn_lo_last, pn_hi_first, pn_hi_last;

extern int debug_mode;

#if TOPLINEINFO
valloc_update_status()
{
  char buf[20];
  int i;
#if 0
  if (!debug_mode)
    return;
#endif
  if (!valloc_initted)
    return;
  sprintf(buf, "%5dk", mem_avail);
  for (i=0; i<6; i++)
    poke(screen_seg, (i+70)*2, buf[i] | 0x0a00);
  sprintf(buf, "%5dk", mem_used);
  for (i=0; i<6; i++)
    poke(screen_seg, (i+62)*2, buf[i] | 0x0a00);
}
#endif

static void vset(unsigned i, int b)
{
  unsigned o, m;
  o = i>>3;
  m = 1<<(i&7);
  if (b)
  {
    if (!(map[o] & m))
    {
#if TOPLINEINFO
      mem_avail -= 4;
      mem_used += 4;
      valloc_update_status();
#endif
      map[o] |= m;
    }
  }
  else
  {
    if (map[o] & m)
    {
#if TOPLINEINFO
      mem_avail += 4;
      mem_used -= 4;
      valloc_update_status();
#endif
      map[o] &= ~m;
    }
  }
}

static int vtest(unsigned i)
{
  unsigned o, m;
  o = i>>3;
  m = 1<<(i&7);
  return map[o] & m;
}


emb_handle_t emb_handle;

void
xms_free(void) {
	if(xms_installed()) {
		xms_unlock_emb(emb_handle);
		xms_emb_free(emb_handle);
#if DEBUGGER
	printf("XMS memory freed\n");
#endif
	}
}

void
xms_alloc_init(void) {
	xms_extended_info *x = xms_query_extended_memory();
	emb_off_t linear_base;
	emb_size_K_t emb_size;
#if DEBUGGER
	printf("XMS driver detected\n");
#endif
	emb_size = x->max_free_block;
	emb_handle = xms_emb_allocate(emb_size);
	linear_base = xms_lock_emb(emb_handle);
	pn_hi_first = (linear_base + 4095)/4096;
	pn_hi_last = pn_hi_first + emb_size / 4 - 1;
}


static valloc_init()
{
  unsigned char far *vdisk;
  int has_vdisk=1;
  unsigned long vdisk_top;
  unsigned los, i, lol;
  struct REGPACK r;
  
  /*
  ** try xms allocation
  */
  if(xms_installed()) {
	  xms_alloc_init();
  } else {
	/*
	** int 15/vdisk memory allocation
	*/
	r.r_ax = 0x8800;	/* get extended memory size */
	intr(0x15, &r);
	pn_hi_last = r.r_ax / 4 + 255;

	/* get ivec 19h, seg only */
	vdisk = (char far *)(*(long far *)0x64L & 0xFFFF0000L);
	for (i=0; i<5; i++)
	  if (vdisk[i+18] != "VDISK"[i])
		has_vdisk = 0;
	if (has_vdisk)
	{
	  vdisk_top = vdisk[46] * 65536L + vdisk[45] * 256 + vdisk[44];
	  pn_hi_first = (vdisk_top + 4095) / 4096;
	}
	else
	  pn_hi_first = 256;
  }

  r.r_ax= 0x4800;	/* get real memory size */
  r.r_bx = 0xffff;
  intr(0x21, &r);	/* lol == size of largest free memory block */
  lol = r.r_bx;
  r.r_ax = 0x4800;
  intr(0x21, &r);	/* get the block */
  pn_lo_first = (r.r_ax+0xFF) >> 8;	/* lowest real mem 4K block */
  pn_lo_last = (r.r_ax+lol-1) >> 8; /* highest real mem 4K block */

  r.r_es = r.r_ax;	/* free the block just allocated */
  r.r_ax = 0x4900;
  intr(0x21, &r);

  mem_avail = 0;
  for (i=0; i<4096; i++)
    map[i] = 0xff;
  for (i=pn_lo_first; i<=pn_lo_last; i++)
    vset(i, VA_FREE);
  for (i=pn_hi_first; i<=pn_hi_last; i++)
    vset(i, VA_FREE);

/*  mem_avail = (pn_lo_last-pn_lo_first+1)*4 + (pn_hi_last-pn_hi_first+1)*4; */
#if DEBUGGER
  if (debug_mode)
    printf("%d Kb conventional, %d Kb extended - %d Kb total RAM available\n",
      (pn_lo_last-pn_lo_first+1)*4,
      (pn_hi_last-pn_hi_first+1)*4,
      mem_avail);
#endif

  mem_used = 0;
  left_lo = (pn_lo_last-pn_lo_first+1)*4;
  left_hi = (pn_hi_last-pn_hi_first+1)*4;
#if TOPLINEINFO
  valloc_update_status();
#endif
  valloc_initted = 1;
}

unsigned valloc(where)
{
  unsigned pn;
  if (!valloc_initted)
    valloc_init();
  switch (where)
  {
    case VA_640:
      more_640:
      for (pn=pn_lo_first; pn<=pn_lo_last; pn++)
        if (vtest(pn) == VA_FREE)
        {
          left_lo -= 4;
          vset(pn, VA_USED);
          return pn;
        }
      page_out(where);
      goto more_640;
    case VA_1M:
      more_1m:
      for (pn=pn_hi_first; pn<=pn_hi_last; pn++)
        if (vtest(pn) == VA_FREE)
        {
          left_hi -= 4;
          vset(pn, VA_USED);
          return pn;
        }
      for (pn=pn_lo_first; pn<=pn_lo_last; pn++)
        if (vtest(pn) == VA_FREE)
        {
          left_lo -= 4;
          vset(pn, VA_USED);
          return pn;
        }
      page_out(where);
      goto more_1m;
  }
  return 0;
}

void vfree(unsigned pn)
{
  vset(pn, VA_FREE);
}
