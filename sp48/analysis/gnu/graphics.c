/* This is file GRAPHICS.C */
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

#pragma inline

/* History:42,23 */
#include <dos.h>
#include <fcntl.h>
#include <sys/stat.h>
#include "build.h"
#include "types.h"
#include "paging.h"
#include "graphics.h"
#include "tss.h"
#include "gdt.h"

int gr_def_tw = 0;
int gr_def_th = 0;
int gr_def_gw = 0;
int gr_def_gh = 0;

far (*gr_init_func)();
unsigned gr_paging_offset;
unsigned gr_paging_segment;
word32 gr_paging_func;

typedef struct {
  word16 init_routine;
  word16 paging_routine;
  word16 split_rw;
  word16 def_tw;
  word16 def_th;
  word16 def_gw;
  word16 def_gh;
} GR_DRIVER;

extern GR_DRIVER builtin_gr_driver;
GR_DRIVER *gr_driver;

void setup_graphics_driver(char *drv_name)
{
  int file;
  struct stat sbuf;
  if (stat(drv_name, &sbuf))
  {
    gr_driver = &builtin_gr_driver;
  }
  else
  {
    gr_driver = (GR_DRIVER *)malloc(sbuf.st_size + 16);
    if (gr_driver == 0)
    {
      gr_driver = &builtin_gr_driver;
    }
    else
    {
      gr_driver = (GR_DRIVER *)(((unsigned)gr_driver + 15) & ~15);
      file = open(drv_name, O_RDONLY | O_BINARY);
      read(file, gr_driver, sbuf.st_size);
      close(file);
    }
  }

  if (gr_driver == &builtin_gr_driver)
  {
    gr_init_func = MK_FP(_DS, gr_driver->init_routine);
    gr_paging_segment = _DS;
    gr_paging_offset = gr_driver->paging_routine;
  }
  else
  {
    gr_init_func = MK_FP(_DS + (unsigned)gr_driver/16, gr_driver->init_routine);
    gr_paging_segment = _DS + (unsigned)gr_driver/16;
    gr_paging_offset = gr_driver->paging_routine;
  }

  gr_paging_func = ((word32)g_grdr << 19) + gr_paging_offset;

  if (gr_def_tw) gr_driver->def_tw = gr_def_tw;
  if (gr_def_th) gr_driver->def_th = gr_def_th;
  if (gr_def_gw) gr_driver->def_gw = gr_def_gw;
  if (gr_def_gh) gr_driver->def_gh = gr_def_gh;
}

void graphics_mode(int ax)
{
  int bx, cx, dx;
  bx = tss_ptr->tss_ebx;
  cx = tss_ptr->tss_ecx;
  dx = tss_ptr->tss_edx;
  _AX = ax;
  _CX = cx;
  _DX = dx;
  asm push ds
  asm push ds
  asm pop es
  asm push word ptr gr_init_func+2
  asm pop ds
  asm call dword ptr es:[gr_init_func]
  asm pop ds
  dx = _DX;
  cx = _CX;
  bx = gr_driver->split_rw;
  tss_ptr->tss_ebx = bx;
  tss_ptr->tss_ecx = cx;
  tss_ptr->tss_edx = dx;
}
